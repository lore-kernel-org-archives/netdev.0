From: Flavio Leitner <fleitner@redhat.com>
Subject: [PATCH] netconsole: queue console messages to send later
Date: Mon,  7 Jun 2010 16:24:52 -0300
Message-ID: <1275938692-26997-1-git-send-email-fleitner@redhat.com>
References: <24059.1275417767@death.nxdomain.ibm.com>
Cc: David Miller <davem@davemloft.net>, Cong Wang <amwang@redhat.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Flavio Leitner <fbl@sysclose.org>,
	Matt Mackall <mpm@selenic.com>,
	Andy Gospodarek <gospo@redhat.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Jeff Moyer <jmoyer@redhat.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	lkml <linux-kernel@vger.kernel.org>,
	<bridge@lists.linux-foundation.org>,
	<bonding-devel@lists.sourceforge.net>,
	Flavio Leitner <fleitner@redhat.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <24059.1275417767@death.nxdomain.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There are some networking drivers that hold a lock in the
transmit path. Therefore, if a console message is printed
after that, netconsole will push it through the transmit path,
resulting in a deadlock.

This patch fixes the re-injection problem by queuing the console
messages in a preallocated circular buffer and then scheduling a
workqueue to send them later with another context.

Signed-off-by: Flavio Leitner <fleitner@redhat.com>
---
 drivers/net/netconsole.c |  156 +++++++++++++++++++++++++++++++++++++++-------
 1 files changed, 133 insertions(+), 23 deletions(-)

diff --git a/drivers/net/netconsole.c b/drivers/net/netconsole.c
index ca142c4..874376d 100644
--- a/drivers/net/netconsole.c
+++ b/drivers/net/netconsole.c
@@ -44,6 +44,8 @@
 #include <linux/netpoll.h>
 #include <linux/inet.h>
 #include <linux/configfs.h>
+#include <linux/workqueue.h>
+#include <linux/circ_buf.h>
 
 MODULE_AUTHOR("Maintainer: Matt Mackall <mpm@selenic.com>");
 MODULE_DESCRIPTION("Console driver for network interfaces");
@@ -56,6 +58,10 @@ static char config[MAX_PARAM_LENGTH];
 module_param_string(netconsole, config, MAX_PARAM_LENGTH, 0);
 MODULE_PARM_DESC(netconsole, " netconsole=[src-port]@[src-ip]/[dev],[tgt-port]@<tgt-ip>/[tgt-macaddr]");
 
+static int logsize = PAGE_SIZE;
+module_param(logsize, int, 0444);
+MODULE_PARM_DESC(logsize, "netconsole buffer size");
+
 #ifndef	MODULE
 static int __init option_setup(char *opt)
 {
@@ -100,6 +106,75 @@ struct netconsole_target {
 	struct netpoll		np;
 };
 
+struct netconsole_msg_ctl {
+	struct circ_buf		messages;
+	unsigned long		ring_size;
+	struct page		*buffer_page;
+	struct work_struct 	tx_work;
+};
+static struct netconsole_msg_ctl *netconsole_ctl;
+
+#define RING_INC_POS(pos, inc, size) ((pos + inc) & (size - 1))
+
+static void netconsole_target_get(struct netconsole_target *nt);
+static void netconsole_target_put(struct netconsole_target *nt);
+
+static void netconsole_start_xmit(const char *msg, unsigned int length)
+{
+	int frag, left;
+	unsigned long flags;
+	struct netconsole_target *nt;
+	const char *tmp;
+
+	/* Avoid taking lock and disabling interrupts unnecessarily */
+	if (list_empty(&target_list))
+		return;
+
+	spin_lock_irqsave(&target_list_lock, flags);
+	list_for_each_entry(nt, &target_list, list) {
+		netconsole_target_get(nt);
+		if (nt->enabled && netif_running(nt->np.dev)) {
+			/*
+			 * We nest this inside the for-each-target loop above
+			 * so that we're able to get as much logging out to
+			 * at least one target if we die inside here, instead
+			 * of unnecessarily keeping all targets in lock-step.
+			 */
+			tmp = msg;
+			for (left = length; left;) {
+				frag = min(left, MAX_PRINT_CHUNK);
+				netpoll_send_udp(&nt->np, tmp, frag);
+				tmp += frag;
+				left -= frag;
+			}
+		}
+		netconsole_target_put(nt);
+	}
+	spin_unlock_irqrestore(&target_list_lock, flags);
+}
+
+static void netconsole_process_queue(struct work_struct *work)
+{
+	struct circ_buf *messages = &netconsole_ctl->messages;
+	unsigned long ring_size = netconsole_ctl->ring_size;
+	unsigned long head = ACCESS_ONCE(messages->head);
+	unsigned long len;
+
+	while (CIRC_CNT(head, messages->tail, ring_size) >= 1) {
+		/* read index before reading contents at that index */
+		smp_read_barrier_depends();
+
+		/* pick up a length that don't wrap in the middle */
+		len = CIRC_CNT_TO_END(head, messages->tail, ring_size);
+		netconsole_start_xmit(&messages->buf[messages->tail], len);
+
+		/* finish reading descriptor before incrementing tail */
+		smp_mb();
+		messages->tail = RING_INC_POS(messages->tail, len, ring_size);
+		head = ACCESS_ONCE(messages->head);
+	}
+}
+
 #ifdef	CONFIG_NETCONSOLE_DYNAMIC
 
 static struct configfs_subsystem netconsole_subsys;
@@ -702,38 +777,43 @@ static struct notifier_block netconsole_netdev_notifier = {
 	.notifier_call  = netconsole_netdev_event,
 };
 
+/* called with console sem, interrupts disabled */
 static void write_msg(struct console *con, const char *msg, unsigned int len)
 {
-	int frag, left;
-	unsigned long flags;
-	struct netconsole_target *nt;
-	const char *tmp;
+	struct circ_buf *messages = &netconsole_ctl->messages;
+	unsigned long ring_size = netconsole_ctl->ring_size;
+	unsigned long tail = ACCESS_ONCE(messages->tail);
+	unsigned long left;
+	unsigned long end;
+	unsigned long pos;
 
 	/* Avoid taking lock and disabling interrupts unnecessarily */
 	if (list_empty(&target_list))
 		return;
 
-	spin_lock_irqsave(&target_list_lock, flags);
-	list_for_each_entry(nt, &target_list, list) {
-		netconsole_target_get(nt);
-		if (nt->enabled && netif_running(nt->np.dev)) {
-			/*
-			 * We nest this inside the for-each-target loop above
-			 * so that we're able to get as much logging out to
-			 * at least one target if we die inside here, instead
-			 * of unnecessarily keeping all targets in lock-step.
-			 */
-			tmp = msg;
-			for (left = len; left;) {
-				frag = min(left, MAX_PRINT_CHUNK);
-				netpoll_send_udp(&nt->np, tmp, frag);
-				tmp += frag;
-				left -= frag;
-			}
+	pos = 0;
+	left = len;
+	while (left && CIRC_SPACE(messages->head, tail, ring_size) >= 1) {
+		end = CIRC_SPACE_TO_END(messages->head, tail, ring_size);
+		/* fast path, no wrapping is needed */
+		if (end >= left) {
+			memcpy(&messages->buf[messages->head], &msg[pos], left);
+			smp_wmb(); 
+			messages->head = RING_INC_POS(messages->head, left, ring_size);
+			left = 0;
 		}
-		netconsole_target_put(nt);
+		else {
+			/* copy up to the end */
+			memcpy(&messages->buf[messages->head], &msg[pos], end);
+			smp_wmb(); 
+			messages->head = RING_INC_POS(messages->head, end, ring_size);
+			left -= end;
+			pos += end;
+		}
+
 	}
-	spin_unlock_irqrestore(&target_list_lock, flags);
+
+	schedule_work(&netconsole_ctl->tx_work);
 }
 
 static struct console netconsole = {
@@ -746,9 +826,25 @@ static int __init init_netconsole(void)
 {
 	int err;
 	struct netconsole_target *nt, *tmp;
+	struct circ_buf *messages;
 	unsigned long flags;
 	char *target_config;
 	char *input = config;
+	int order = get_order(logsize);
+
+	err = -ENOMEM;
+	netconsole_ctl = kzalloc(sizeof(*netconsole_ctl), GFP_KERNEL);
+	if (netconsole_ctl == NULL)
+		goto nomem;
+
+	netconsole_ctl->buffer_page = alloc_pages(GFP_KERNEL, order);
+	if (netconsole_ctl->buffer_page == NULL)
+		goto nopage;
+
+	netconsole_ctl->ring_size = (PAGE_SIZE << order);
+	messages = &netconsole_ctl->messages;
+	messages->buf = page_address(netconsole_ctl->buffer_page);
+	INIT_WORK(&netconsole_ctl->tx_work, netconsole_process_queue);
 
 	if (strnlen(input, MAX_PARAM_LENGTH)) {
 		while ((target_config = strsep(&input, ";"))) {
@@ -795,6 +891,11 @@ fail:
 		free_param_target(nt);
 	}
 
+	__free_pages(netconsole_ctl->buffer_page, order);
+nopage:
+	kfree(netconsole_ctl);
+
+nomem:
 	return err;
 }
 
@@ -806,6 +907,10 @@ static void __exit cleanup_netconsole(void)
 	dynamic_netconsole_exit();
 	unregister_netdevice_notifier(&netconsole_netdev_notifier);
 
+	flush_work(&netconsole_ctl->tx_work);
+	cancel_work_sync(&netconsole_ctl->tx_work);
+	netconsole_process_queue(NULL);
+
 	/*
 	 * Targets created via configfs pin references on our module
 	 * and would first be rmdir(2)'ed from userspace. We reach
@@ -818,6 +923,11 @@ static void __exit cleanup_netconsole(void)
 		list_del(&nt->list);
 		free_param_target(nt);
 	}
+
+	__free_pages(netconsole_ctl->buffer_page,
+			get_order(netconsole_ctl->ring_size));
+
+	kfree(netconsole_ctl);
 }
 
 module_init(init_netconsole);
-- 
1.7.0.1
