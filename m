From: Satyam Sharma <ssatyam@cse.iitk.ac.in>
Subject: [PATCH v2 -mm 8/9] netconsole: Support multiple logging targets
Date: Tue, 10 Jul 2007 14:50:01 +0530
Message-ID: <20070710092001.23907.39876.sendpatchset@cselinux1.cse.iitk.ac.in>
References: <20070710091920.23907.96483.sendpatchset@cselinux1.cse.iitk.ac.in>
Cc: Matt Mackall <mpm@selenic.com>,
	Keiichi Kii <k-keiichi@bx.jp.nec.com>,
	Satyam Sharma <ssatyam@cse.iitk.ac.in>,
	Netdev <netdev@vger.kernel.org>,
	Joel Becker <joel.becker@oracle.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail4.iitk.ac.in ([203.197.196.4]:56135 "EHLO mail4.iitk.ac.in"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762436AbXGJI5r (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jul 2007 04:57:47 -0400
In-Reply-To: <20070710091920.23907.96483.sendpatchset@cselinux1.cse.iitk.ac.in>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Satyam Sharma <ssatyam@cse.iitk.ac.in>

[8/9] netconsole: Support multiple logging targets

This patch introduces support for multiple targets:

Let's keep this out of CONFIG_NETCONSOLE_DYNAMIC as well -- this is useful
even in the default case and (including the infrastructure introduced in
previous patches) doesn't really add too many bytes to module text. All the
complexity (and size) comes with the dynamic reconfigurability / userspace
interface patch, and so it's plausible users may want to keep this enabled
but that disabled (say to avoid a dep on CONFIG_CONFIGFS_FS too).

Also update documentation to mention the use of ";" separator to specify
multiple logging targets in the boot/module option string.

Brief overview:

We maintain a target_list (and corresponding lock). Get rid of the static
"default_target" and introduce allocation and release functions for our
netconsole_target objects (but keeping sure to preserve previous behaviour
such as default values). During init_netconsole(), ";" is used as the
separator to identify multiple target specifications in the boot/module
option string. The target specifications are parsed and netpolls setup.
During exit, the target_list is torn down and all items released.

Signed-off-by: Satyam Sharma <ssatyam@cse.iitk.ac.in>
Cc: Keiichi Kii <k-keiichi@bx.jp.nec.com>

---

 Documentation/networking/netconsole.txt |    6 +
 drivers/net/netconsole.c                |  173 ++++++++++++++++++++++++--------
 2 files changed, 139 insertions(+), 40 deletions(-)

---

diff -ruNp a/Documentation/networking/netconsole.txt b/Documentation/networking/netconsole.txt
--- a/Documentation/networking/netconsole.txt	2007-07-10 07:35:17.000000000 +0530
+++ b/Documentation/networking/netconsole.txt	2007-07-10 08:25:17.000000000 +0530
@@ -34,6 +34,12 @@ Examples:
 
  insmod netconsole netconsole=@/,@10.0.0.2/
 
+It also supports logging to multiple remote agents by specifying
+parameters for the multiple agents separated by semicolons and the
+complete string enclosed in "quotes", thusly:
+
+ modprobe netconsole netconsole="@/,@10.0.0.2/;@/eth1,6892@10.0.0.3/"
+
 Built-in netconsole starts immediately after the TCP stack is
 initialized and attempts to bring up the supplied dev at the supplied
 address.
diff -ruNp a/drivers/net/netconsole.c b/drivers/net/netconsole.c
--- a/drivers/net/netconsole.c	2007-07-10 07:52:44.000000000 +0530
+++ b/drivers/net/netconsole.c	2007-07-10 08:34:26.000000000 +0530
@@ -62,44 +62,93 @@ static int __init option_setup(char *opt
 __setup("netconsole=", option_setup);
 #endif	/* MODULE */
 
+/* Linked list of all configured targets */
+static LIST_HEAD(target_list);
+
+/* This needs to be a spinlock because write_msg() cannot sleep */
+static DEFINE_SPINLOCK(target_list_lock);
+
 /**
  * struct netconsole_target - Represents a configured netconsole target.
+ * @list:	Links this target into the target_list.
  * @np:		The netpoll structure for this target.
  */
 struct netconsole_target {
+	struct list_head	list;
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
+/* Allocate new target and setup netpoll for it */
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
+	return nt;
+
+fail:
+	kfree(nt);
+	return ERR_PTR(err);
+}
+
+/* Cleanup netpoll for given target and free it */
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
 
-	if (nt->np.dev == dev) {
-		switch (event) {
-		case NETDEV_CHANGEADDR:
-			memcpy(nt->np.local_mac, dev->dev_addr, ETH_ALEN);
-			break;
-
-		case NETDEV_CHANGENAME:
-			strlcpy(nt->np.dev_name, dev->name, IFNAMSIZ);
-			break;
+	if (!(event == NETDEV_CHANGEADDR || event == NETDEV_CHANGENAME))
+		goto done;
+
+	spin_lock_irqsave(&target_list_lock, flags);
+	list_for_each_entry(nt, &target_list, list) {
+		if (nt->np.dev == dev) {
+			switch (event) {
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
 
+done:
 	return NOTIFY_DONE;
 }
 
@@ -111,18 +160,32 @@ static void write_msg(struct console *co
 {
 	int frag, left;
 	unsigned long flags;
-	struct netconsole_target *nt = &default_target;
+	struct netconsole_target *nt;
+	const char *tmp;
 
-	if (netif_running(nt->np.dev)) {
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
+		if (netif_running(nt->np.dev)) {
+			/*
+			 * We nest this inside the for-each-target loop above
+			 * so that we're able to get as much logging out to
+			 * at least one target if we die inside here, instead
+			 * of unnecessarily keeping all targets in lock-step.
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
@@ -134,39 +197,69 @@ static struct console netconsole = {
 static int __init init_netconsole(void)
 {
 	int err = 0;
-	struct netconsole_target *nt = &default_target;
+	struct netconsole_target *nt, *tmp;
+	unsigned long flags;
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
+	while ((target_config = strsep(&input, ";"))) {
+		nt = alloc_target(target_config);
+		if (IS_ERR(nt)) {
+			err = PTR_ERR(nt);
+			goto fail;
+		}
+		spin_lock_irqsave(&target_list_lock, flags);
+		list_add(&nt->list, &target_list);
+		spin_unlock_irqrestore(&target_list_lock, flags);
+	}
 
 	err = register_netdevice_notifier(&netconsole_netdev_notifier);
 	if (err)
-		goto out;
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
