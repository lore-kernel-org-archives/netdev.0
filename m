From: Satyam Sharma <ssatyam@cse.iitk.ac.in>
Subject: [PATCH -mm 7/9] netconsole: Support multiple logging targets
Date: Wed, 04 Jul 2007 16:38:14 +0530
Message-ID: <20070704110814.28520.94417.sendpatchset@cselinux1.cse.iitk.ac.in>
References: <20070704110739.28520.5036.sendpatchset@cselinux1.cse.iitk.ac.in>
Cc: Keiichi Kii <k-keiichi@bx.jp.nec.com>,
	Satyam Sharma <ssatyam@cse.iitk.ac.in>,
	Netdev <netdev@vger.kernel.org>,
	Joel Becker <joel.becker@oracle.com>,
	Matt Mackall <mpm@selenic.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail4.iitk.ac.in ([203.197.196.4]:57176 "EHLO mail4.iitk.ac.in"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761301AbXGDLII (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Jul 2007 07:08:08 -0400
In-Reply-To: <20070704110739.28520.5036.sendpatchset@cselinux1.cse.iitk.ac.in>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Satyam Sharma <ssatyam@cse.iitk.ac.in>

[7/9] netconsole: Support multiple logging targets

This patch introduces support for multiple targets:

Let's keep this out of CONFIG_NETCONSOLE_DYNAMIC as well -- this is useful
even in the default case and (including the infrastructure introduced in
previous patches) doesn't really add too many bytes to module text. All the
complexity (and size) comes with the dynamic reconfigurability / userspace
interface patch, and so it's plausible users may want to keep this enabled
but that disabled (say to avoid a dep on CONFIG_CONFIGFS_FS).

Brief overview:

We maintain a target_list (and corresponding lock). Get rid of the static
"default_target" and introduce allocation and release functions for our
netconsole_target objects (but keeping sure to preserve previous behaviour
such as default values). During init_netconsole(), ";" is used as the
separator to identify multiple target specifications in the input boot/module
option string, and sent off to netpoll_parse_options(), and then finally
netpoll's are setup. During exit, the target_list is torn down and all items
released.

Signed-off-by: Satyam Sharma <ssatyam@cse.iitk.ac.in>
Cc: Keiichi Kii <k-keiichi@bx.jp.nec.com>
Cc: Takayoshi Kochi <t-kochi@bq.jp.nec.com>

---

 drivers/net/netconsole.c |  193 +++++++++++++++++++++++++++++++++++------------
 1 file changed, 145 insertions(+), 48 deletions(-)

---

diff -ruNp a/drivers/net/netconsole.c b/drivers/net/netconsole.c
--- a/drivers/net/netconsole.c	2007-07-04 03:05:32.000000000 +0530
+++ b/drivers/net/netconsole.c	2007-07-04 12:03:01.000000000 +0530
@@ -63,6 +63,12 @@ static int __init option_setup(char *opt
 __setup("netconsole=", option_setup);
 #endif
 
+/* Linked list of all configured targets */
+static LIST_HEAD(target_list);
+
+/* This needs to be a spinlock because write_msg() cannot sleep */
+static DEFINE_SPINLOCK(target_list_lock);
+
 /*
  * Why no net_dev_is_up() in netdevice.h? The kernel could lose a lot of
  * weight if only netdevice.h had the good sense to export such a function.
@@ -75,52 +81,99 @@ static inline int net_dev_is_up(struct n
 
 /**
  * struct netconsole_target - Represents a configured netconsole target.
+ * @list:	Links this target into the target_list.
  * @dev_status:	Tracks whether the underlying interface is up or down.
  * @np:		The netpoll structure for this target.
  */
 struct netconsole_target {
+	struct list_head	list;
 	int			dev_status;
 	struct netpoll		np;
 };
 
-static struct netconsole_target default_target = {
-	.np		= {
-		.name		= "netconsole",
-		.dev_name	= "eth0",
-		.local_port	= 6665,
-		.remote_port	= 6666,
-		.remote_mac	= {0xff, 0xff, 0xff, 0xff, 0xff, 0xff},
-	},
-};
+/*
+ * Allocate new target and setup netpoll for it.
+ * Caller must then add this to target_list itself.
+ */
+static struct netconsole_target *alloc_target(char *target_config)
+{
+	int err = -ENOMEM;
+	struct netconsole_target *nt;
+
+	/* Allocate and initialize with defaults */
+	nt = kzalloc(sizeof(*nt), GFP_KERNEL);
+	if (!nt) {
+		printk(KERN_ERR "netconsole: failed to allocate memory\n");
+		goto fail;
+	}
+
+	nt->np.name = "netconsole";
+	strlcpy(nt->np.dev_name, "eth0", IFNAMSIZ);
+	nt->np.local_port = 6665;
+	nt->np.remote_port = 6666;
+	memset(nt->np.remote_mac, 0xff, ETH_ALEN);
+
+	/* Parse parameters and setup netpoll */
+	err = netpoll_parse_options(&nt->np, target_config);
+	if (err)
+		goto fail;
+
+	err = netpoll_setup(&nt->np);
+	if (err)
+		goto fail;
+
+	nt->dev_status = net_dev_is_up(nt->np.dev);
+
+	return nt;
+
+fail:
+	kfree(nt);
+	return ERR_PTR(err);
+}
+
+/*
+ * Cleanup netpoll for given target and free it.
+ * Caller must have removed this from target_list already.
+ */
+static void free_target(struct netconsole_target *nt)
+{
+	netpoll_cleanup(&nt->np);
+	kfree(nt);
+}
 
 /* Handle network interface device notifications */
 static int netconsole_netdev_event(struct notifier_block *this,
 				   unsigned long event,
 				   void *ptr)
 {
+	unsigned long flags;
+	struct netconsole_target *nt;
 	struct net_device *dev = ptr;
-	struct netconsole_target *nt = &default_target;
 
 	if (!(event == NETDEV_UP || event == NETDEV_DOWN ||
 	      event == NETDEV_CHANGEADDR || event == NETDEV_CHANGENAME))
-	      	goto done;
+		goto done;
 
-	if (nt->np.dev == dev) {
-		switch (event) {
-		case NETDEV_UP:
-		case NETDEV_DOWN:
-			nt->dev_status = net_dev_is_up(nt->np.dev);
-			break;
-
-		case NETDEV_CHANGEADDR:
-			memcpy(nt->np.local_mac, dev->dev_addr, ETH_ALEN);
-			break;
-
-		case NETDEV_CHANGENAME:
-			strlcpy(nt->np.dev_name, dev->name, IFNAMSIZ);
-			break;
+	spin_lock_irqsave(&target_list_lock, flags);
+	list_for_each_entry(nt, &target_list, list) {
+		if (nt->np.dev == dev) {
+			switch (event) {
+			case NETDEV_UP:
+			case NETDEV_DOWN:
+				nt->dev_status = net_dev_is_up(nt->np.dev);
+				break;
+
+			case NETDEV_CHANGEADDR:
+				memcpy(nt->np.local_mac, dev->dev_addr, ETH_ALEN);
+				break;
+
+			case NETDEV_CHANGENAME:
+				strlcpy(nt->np.dev_name, dev->name, IFNAMSIZ);
+				break;
+			}
 		}
 	}
+	spin_unlock_irqrestore(&target_list_lock, flags);
 
 done:
 	return NOTIFY_DONE;
@@ -134,18 +187,33 @@ static void write_msg(struct console *co
 {
 	int frag, left;
 	unsigned long flags;
-	struct netconsole_target *nt = &default_target;
+	struct netconsole_target *nt;
+	const char *tmp;
 
-	if (nt->dev_status) {
-		local_irq_save(flags);
-		for (left = len; left;) {
-			frag = min(left, MAX_PRINT_CHUNK);
-			netpoll_send_udp(&nt->np, msg, frag);
-			msg += frag;
-			left -= frag;
+	/* Avoid taking lock and disabling interrupts unnecessarily */
+	if (unlikely(list_empty(&target_list)))
+		return;
+
+	spin_lock_irqsave(&target_list_lock, flags);
+	list_for_each_entry(nt, &target_list, list) {
+		if (nt->dev_status) {
+			/*
+			 * Note the double-loop nesting (for-in-buffer inside
+			 * for-all-targets) and use of temporary buf pointer.
+			 * This could be useful in getting as much logging out
+			 * to at least one target if we die inside here,
+			 * rather than unnecessarily keeping all in lock-step.
+			 */
+			tmp = msg;
+			for (left = len; left;) {
+				frag = min(left, MAX_PRINT_CHUNK);
+				netpoll_send_udp(&nt->np, tmp, frag);
+				tmp += frag;
+				left -= frag;
+			}
 		}
-		local_irq_restore(flags);
 	}
+	spin_unlock_irqrestore(&target_list_lock, flags);
 }
 
 static struct console netconsole = {
@@ -157,41 +225,70 @@ static struct console netconsole = {
 static int __init init_netconsole(void)
 {
 	int err = 0;
-	struct netconsole_target *nt = &default_target;
+	struct netconsole_target *nt, *tmp;
+	char *target_config;
+	char *input = config;
 
-	if (!strnlen(config, MAX_PARAM_LENGTH)) {
+	if (!strnlen(input, MAX_PARAM_LENGTH)) {
 		printk(KERN_INFO "netconsole: not configured, aborting\n");
 		goto out;
 	}
 
-	err = netpoll_parse_options(&nt->np, config);
-	if (err)
-		goto out;
-
-	err = netpoll_setup(&nt->np);
-	if (err)
-		goto out;
-
-	nt->dev_status = net_dev_is_up(nt->np.dev);
+	/*
+	 * Neither the netdev notifier, nor the console have been
+	 * registered so far. Nobody's racing us, so skip the lock.
+	 */
+	while ((target_config = strsep(&input, ";"))) {
+		nt = alloc_target(target_config);
+		if (IS_ERR(nt)) {
+			err = PTR_ERR(nt);
+			goto fail;
+		}
+		list_add(&nt->list, &target_list);
+	}
 
 	err = register_netdevice_notifier(&netconsole_netdev_notifier);
 	if (err)
-		return err;
+		goto fail;
 
 	register_console(&netconsole);
 	printk(KERN_INFO "netconsole: network logging started\n");
 
 out:
 	return err;
+
+fail:
+	printk(KERN_ERR "netconsole: cleaning up\n");
+
+	/*
+	 * Remove all targets and destroy them.
+	 * The notifier is off, so nobody's racing us. So let's skip
+	 * the lock, netpoll_cleanup() wants to sleep anyway.
+	 */
+	list_for_each_entry_safe(nt, tmp, &target_list, list) {
+		list_del(&nt->list);
+		free_target(nt);
+	}
+
+	return err;
 }
 
 static void __exit cleanup_netconsole(void)
 {
-	struct netconsole_target *nt = &default_target;
+	struct netconsole_target *nt, *tmp;
 
 	unregister_console(&netconsole);
 	unregister_netdevice_notifier(&netconsole_netdev_notifier);
-	netpoll_cleanup(&nt->np);
+
+	/*
+	 * Remove all targets and destroy them.
+	 * Nobody's racing us, and netpoll_cleanup() wants to
+	 * sleep -- so skip the lock.
+	 */
+	list_for_each_entry_safe(nt, tmp, &target_list, list) {
+		list_del(&nt->list);
+		free_target(nt);
+	}
 }
 
 module_init(init_netconsole);
