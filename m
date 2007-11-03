From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 06/11] netpoll: remove dev_name for npinfo
Date: Sat, 03 Nov 2007 11:43:20 -0700
Message-ID: <20071103184338.747306412@linux-foundation.org>
References: <20071103184314.216145305@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Satyam Sharma <satyam@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:40529 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758042AbXKCXgj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Nov 2007 19:36:39 -0400
Content-Disposition: inline; filename=netpoll-noname.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The device name was only in npinfo for netconsole target
configuration, so move it to netconsole.  Netconsole only
needs the value during config, so no need to do all
the device name tracking etc.. 

Make functions for common code for instantiation and 
start up.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>


--- a/drivers/net/netconsole.c	2007-11-03 09:26:27.000000000 -0700
+++ b/drivers/net/netconsole.c	2007-11-03 10:02:18.000000000 -0700
@@ -96,6 +96,7 @@ struct netconsole_target {
 	struct config_item	item;
 #endif
 	int			enabled;
+	char 			dev_name[IFNAMSIZ];
 	struct netpoll		np;
 };
 
@@ -157,39 +158,67 @@ static void netconsole_target_put(struct
 
 #endif	/* CONFIG_NETCONSOLE_DYNAMIC */
 
+
+
+/*
+ * Allocate and initialize with defaults.
+ * Note that these targets get their config_item fields zeroed-out.
+ */
+static struct netconsole_target *new_target(void)
+{
+	struct netconsole_target *nt;
+
+	nt = kzalloc(sizeof(*nt), GFP_KERNEL);
+	if (nt) {
+		nt->np.name = "netconsole";
+		strlcpy(nt->dev_name, "eth0", IFNAMSIZ);
+		nt->np.local_port = 6665;
+		nt->np.remote_port = 6666;
+		memset(nt->np.remote_mac, 0xff, ETH_ALEN);
+	}
+
+	return nt;
+}
+
+static int start_target(struct netconsole_target *nt)
+{
+	struct net_device *dev;
+	int err;
+
+	dev = dev_get_by_name(&init_net, nt->dev_name);
+	if (!dev)
+		return -ENODEV;
+
+	err = netpoll_setup(&nt->np, dev);
+	if (err)
+		dev_put(dev);
+	else
+		nt->enabled = 1;
+	return err;
+}
+
+
 /* Allocate new target (from boot/module param) and setup netpoll for it */
 static struct netconsole_target *alloc_param_target(char *target_config)
 {
 	int err = -ENOMEM;
 	struct netconsole_target *nt;
 
-	/*
-	 * Allocate and initialize with defaults.
-	 * Note that these targets get their config_item fields zeroed-out.
-	 */
-	nt = kzalloc(sizeof(*nt), GFP_KERNEL);
+	nt = new_target();
 	if (!nt) {
 		printk(KERN_ERR "netconsole: failed to allocate memory\n");
 		goto fail;
 	}
 
-	nt->np.name = "netconsole";
-	strlcpy(nt->np.dev_name, "eth0", IFNAMSIZ);
-	nt->np.local_port = 6665;
-	nt->np.remote_port = 6666;
-	memset(nt->np.remote_mac, 0xff, ETH_ALEN);
-
 	/* Parse parameters and setup netpoll */
-	err = netpoll_parse_options(&nt->np, target_config);
+	err = netpoll_parse_options(&nt->np, target_config, nt->dev_name);
 	if (err)
 		goto fail;
 
-	err = netpoll_setup(&nt->np);
+
+	err = start_target(nt);
 	if (err)
 		goto fail;
-
-	nt->enabled = 1;
-
 	return nt;
 
 fail:
@@ -279,7 +308,8 @@ static ssize_t show_enabled(struct netco
 
 static ssize_t show_dev_name(struct netconsole_target *nt, char *buf)
 {
-	return snprintf(buf, PAGE_SIZE, "%s\n", nt->np.dev_name);
+	return snprintf(buf, PAGE_SIZE, "%s\n",
+			nt->enabled ? nt->np.dev->name : nt->dev_name);
 }
 
 static ssize_t show_local_port(struct netconsole_target *nt, char *buf)
@@ -339,14 +369,13 @@ static ssize_t store_enabled(struct netc
 		return enabled;
 
 	if (enabled) {	/* 1 */
-
 		/*
 		 * Skip netpoll_parse_options() -- all the attributes are
 		 * already configured via configfs. Just print them out.
 		 */
 		netpoll_print_options(&nt->np);
 
-		err = netpoll_setup(&nt->np);
+		err = start_target(nt);
 		if (err)
 			return err;
 
@@ -365,7 +394,7 @@ static ssize_t store_dev_name(struct net
 			      const char *buf,
 			      size_t count)
 {
-	size_t len;
+	char *cp;
 
 	if (nt->enabled) {
 		printk(KERN_ERR "netconsole: target (%s) is enabled, "
@@ -374,12 +403,12 @@ static ssize_t store_dev_name(struct net
 		return -EINVAL;
 	}
 
-	strlcpy(nt->np.dev_name, buf, IFNAMSIZ);
+	strlcpy(nt->dev_name, buf, IFNAMSIZ);
 
 	/* Get rid of possible trailing newline from echo(1) */
-	len = strnlen(nt->np.dev_name, IFNAMSIZ);
-	if (nt->np.dev_name[len - 1] == '\n')
-		nt->np.dev_name[len - 1] = '\0';
+	cp = strnchr(nt->dev_name, '\n', IFNAMSIZ);
+	if (cp)
+		*cp = '\0';
 
 	return strnlen(buf, count);
 }
@@ -591,21 +620,7 @@ static struct config_item *make_netconso
 	unsigned long flags;
 	struct netconsole_target *nt;
 
-	/*
-	 * Allocate and initialize with defaults.
-	 * Target is disabled at creation (enabled == 0).
-	 */
-	nt = kzalloc(sizeof(*nt), GFP_KERNEL);
-	if (!nt) {
-		printk(KERN_ERR "netconsole: failed to allocate memory\n");
-		return NULL;
-	}
-
-	nt->np.name = "netconsole";
-	strlcpy(nt->np.dev_name, "eth0", IFNAMSIZ);
-	nt->np.local_port = 6665;
-	nt->np.remote_port = 6666;
-	memset(nt->np.remote_mac, 0xff, ETH_ALEN);
+	nt = new_target();
 
 	/* Initialize the config_item member */
 	config_item_init_type_name(&nt->item, name, &netconsole_target_type);
@@ -660,40 +675,6 @@ static struct configfs_subsystem netcons
 
 #endif	/* CONFIG_NETCONSOLE_DYNAMIC */
 
-/* Handle network interface device notifications */
-static int netconsole_netdev_event(struct notifier_block *this,
-				   unsigned long event,
-				   void *ptr)
-{
-	unsigned long flags;
-	struct netconsole_target *nt;
-	struct net_device *dev = ptr;
-
-	if (!(event == NETDEV_CHANGENAME))
-		goto done;
-
-	spin_lock_irqsave(&target_list_lock, flags);
-	list_for_each_entry(nt, &target_list, list) {
-		netconsole_target_get(nt);
-		if (nt->np.dev == dev) {
-			switch (event) {
-			case NETDEV_CHANGENAME:
-				strlcpy(nt->np.dev_name, dev->name, IFNAMSIZ);
-				break;
-			}
-		}
-		netconsole_target_put(nt);
-	}
-	spin_unlock_irqrestore(&target_list_lock, flags);
-
-done:
-	return NOTIFY_DONE;
-}
-
-static struct notifier_block netconsole_netdev_notifier = {
-	.notifier_call  = netconsole_netdev_event,
-};
-
 static void write_msg(struct console *con, const char *msg, unsigned int len)
 {
 	int frag, left;
@@ -755,22 +736,15 @@ static int __init init_netconsole(void)
 		}
 	}
 
-	err = register_netdevice_notifier(&netconsole_netdev_notifier);
-	if (err)
-		goto fail;
-
 	err = dynamic_netconsole_init();
 	if (err)
-		goto undonotifier;
+		goto fail;
 
 	register_console(&netconsole);
 	printk(KERN_INFO "netconsole: network logging started\n");
 
 	return err;
 
-undonotifier:
-	unregister_netdevice_notifier(&netconsole_netdev_notifier);
-
 fail:
 	printk(KERN_ERR "netconsole: cleaning up\n");
 
@@ -793,7 +767,6 @@ static void __exit cleanup_netconsole(vo
 
 	unregister_console(&netconsole);
 	dynamic_netconsole_exit();
-	unregister_netdevice_notifier(&netconsole_netdev_notifier);
 
 	/*
 	 * Targets created via configfs pin references on our module
--- a/include/linux/netpoll.h	2007-11-03 09:35:45.000000000 -0700
+++ b/include/linux/netpoll.h	2007-11-03 09:41:57.000000000 -0700
@@ -14,7 +14,6 @@
 
 struct netpoll {
 	struct net_device *dev;
-	char dev_name[IFNAMSIZ];
 	const char *name;
 	void (*rx_hook)(struct netpoll *, int, char *, int);
 
@@ -35,8 +34,8 @@ struct netpoll_info {
 void netpoll_poll(struct netpoll *np);
 void netpoll_send_udp(struct netpoll *np, const char *msg, int len);
 void netpoll_print_options(struct netpoll *np);
-int netpoll_parse_options(struct netpoll *np, char *opt);
-int netpoll_setup(struct netpoll *np);
+int netpoll_parse_options(struct netpoll *np, char *opt, char *name);
+int netpoll_setup(struct netpoll *np, struct net_device *dev);
 int netpoll_trap(void);
 void netpoll_set_trap(int trap);
 void netpoll_cleanup(struct netpoll *np);
--- a/net/core/netpoll.c	2007-11-03 09:35:45.000000000 -0700
+++ b/net/core/netpoll.c	2007-11-03 09:42:43.000000000 -0700
@@ -552,7 +552,7 @@ void netpoll_print_options(struct netpol
 	printk(KERN_INFO "%s: local IP %d.%d.%d.%d\n",
 			 np->name, HIPQUAD(np->local_ip));
 	printk(KERN_INFO "%s: interface %s\n",
-			 np->name, np->dev_name);
+			 np->name, np->dev->name);
 	printk(KERN_INFO "%s: remote port %d\n",
 			 np->name, np->remote_port);
 	printk(KERN_INFO "%s: remote IP %d.%d.%d.%d\n",
@@ -561,7 +561,7 @@ void netpoll_print_options(struct netpol
 	                 np->name, print_mac(mac, np->remote_mac));
 }
 
-int netpoll_parse_options(struct netpoll *np, char *opt)
+int netpoll_parse_options(struct netpoll *np, char *opt, char *dev_name)
 {
 	char *cur=opt, *delim;
 
@@ -588,7 +588,7 @@ int netpoll_parse_options(struct netpoll
 		if ((delim = strchr(cur, ',')) == NULL)
 			goto parse_failed;
 		*delim = 0;
-		strlcpy(np->dev_name, cur, sizeof(np->dev_name));
+		strlcpy(dev_name, cur, IFNAMSIZ);
 		cur = delim;
 	}
 	cur++;
@@ -650,22 +650,13 @@ int netpoll_parse_options(struct netpoll
 	return -1;
 }
 
-int netpoll_setup(struct netpoll *np)
+int netpoll_setup(struct netpoll *np, struct net_device *ndev)
 {
-	struct net_device *ndev = NULL;
 	struct in_device *in_dev;
 	struct netpoll_info *npinfo;
 	unsigned long flags;
 	int err;
 
-	if (np->dev_name)
-		ndev = dev_get_by_name(&init_net, np->dev_name);
-	if (!ndev) {
-		printk(KERN_ERR "%s: %s doesn't exist, aborting.\n",
-		       np->name, np->dev_name);
-		return -ENODEV;
-	}
-
 	np->dev = ndev;
 	if (!ndev->npinfo) {
 		npinfo = kmalloc(sizeof(*npinfo), GFP_KERNEL);
@@ -689,7 +680,7 @@ int netpoll_setup(struct netpoll *np)
 
 	if (!ndev->poll_controller) {
 		printk(KERN_ERR "%s: %s doesn't support polling, aborting.\n",
-		       np->name, np->dev_name);
+		       np->name, ndev->name);
 		err = -ENOTSUPP;
 		goto release;
 	}
@@ -698,7 +689,7 @@ int netpoll_setup(struct netpoll *np)
 		unsigned long atmost, atleast;
 
 		printk(KERN_INFO "%s: device %s not up yet, forcing it\n",
-		       np->name, np->dev_name);
+		       np->name, ndev->name);
 
 		rtnl_lock();
 		err = dev_open(ndev);
@@ -742,7 +733,7 @@ int netpoll_setup(struct netpoll *np)
 		if (!in_dev || !in_dev->ifa_list) {
 			rcu_read_unlock();
 			printk(KERN_ERR "%s: no IP address for %s, aborting\n",
-			       np->name, np->dev_name);
+			       np->name, ndev->name);
 			err = -EDESTADDRREQ;
 			goto release;
 		}
@@ -774,7 +765,6 @@ int netpoll_setup(struct netpoll *np)
 	if (!ndev->npinfo)
 		kfree(npinfo);
 	np->dev = NULL;
-	dev_put(ndev);
 	return err;
 }
 

-- 
Stephen Hemminger <shemminger@linux-foundation.org>

