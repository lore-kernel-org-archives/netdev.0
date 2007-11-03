From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 07/11] netpoll: get rid of name parameter
Date: Sat, 03 Nov 2007 11:43:21 -0700
Message-ID: <20071103184338.799390572@linux-foundation.org>
References: <20071103184314.216145305@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Satyam Sharma <satyam@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:51908 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758135AbXKCXgk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Nov 2007 19:36:40 -0400
Content-Disposition: inline; filename=netpoll-no-name.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The name was being stored and used only for error messages.
The same effect can be had by just passing it in where needed during
config.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>


--- a/drivers/net/netconsole.c	2007-11-03 10:03:40.000000000 -0700
+++ b/drivers/net/netconsole.c	2007-11-03 10:12:35.000000000 -0700
@@ -170,7 +170,6 @@ static struct netconsole_target *new_tar
 
 	nt = kzalloc(sizeof(*nt), GFP_KERNEL);
 	if (nt) {
-		nt->np.name = "netconsole";
 		strlcpy(nt->dev_name, "eth0", IFNAMSIZ);
 		nt->np.local_port = 6665;
 		nt->np.remote_port = 6666;
@@ -186,8 +185,13 @@ static int start_target(struct netconsol
 	int err;
 
 	dev = dev_get_by_name(&init_net, nt->dev_name);
-	if (!dev)
+	if (!dev) {
+		printk(KERN_ERR "netconsole: device '%s' does not exist.\n",
+		       nt->dev_name);
 		return -ENODEV;
+	}
+
+	netpoll_print_options("netconsole", &nt->np);
 
 	err = netpoll_setup(&nt->np, dev);
 	if (err)
@@ -212,13 +216,16 @@ static struct netconsole_target *alloc_p
 
 	/* Parse parameters and setup netpoll */
 	err = netpoll_parse_options(&nt->np, target_config, nt->dev_name);
-	if (err)
+	if (err) {
+		printk(KERN_ERR "netconsole: parse options '%s' failed %d\n",
+		       target_config, err);
 		goto fail;
-
+	}
 
 	err = start_target(nt);
 	if (err)
 		goto fail;
+
 	return nt;
 
 fail:
@@ -369,12 +376,6 @@ static ssize_t store_enabled(struct netc
 		return enabled;
 
 	if (enabled) {	/* 1 */
-		/*
-		 * Skip netpoll_parse_options() -- all the attributes are
-		 * already configured via configfs. Just print them out.
-		 */
-		netpoll_print_options(&nt->np);
-
 		err = start_target(nt);
 		if (err)
 			return err;
--- a/include/linux/netpoll.h	2007-11-03 10:03:40.000000000 -0700
+++ b/include/linux/netpoll.h	2007-11-03 10:10:00.000000000 -0700
@@ -14,7 +14,6 @@
 
 struct netpoll {
 	struct net_device *dev;
-	const char *name;
 	void (*rx_hook)(struct netpoll *, int, char *, int);
 
 	u32 local_ip, remote_ip;
@@ -33,7 +32,7 @@ struct netpoll_info {
 
 void netpoll_poll(struct netpoll *np);
 void netpoll_send_udp(struct netpoll *np, const char *msg, int len);
-void netpoll_print_options(struct netpoll *np);
+void netpoll_print_options(const char *prefix, struct netpoll *np);
 int netpoll_parse_options(struct netpoll *np, char *opt, char *name);
 int netpoll_setup(struct netpoll *np, struct net_device *dev);
 int netpoll_trap(void);
--- a/net/core/netpoll.c	2007-11-03 10:03:40.000000000 -0700
+++ b/net/core/netpoll.c	2007-11-03 10:22:44.000000000 -0700
@@ -544,21 +544,21 @@ out:
 	return 0;
 }
 
-void netpoll_print_options(struct netpoll *np)
+void netpoll_print_options(const char *name, struct netpoll *np)
 {
 	DECLARE_MAC_BUF(mac);
 	printk(KERN_INFO "%s: local port %d\n",
-			 np->name, np->local_port);
+			 name, np->local_port);
 	printk(KERN_INFO "%s: local IP %d.%d.%d.%d\n",
-			 np->name, HIPQUAD(np->local_ip));
+			 name, HIPQUAD(np->local_ip));
 	printk(KERN_INFO "%s: interface %s\n",
-			 np->name, np->dev->name);
+			 name, np->dev->name);
 	printk(KERN_INFO "%s: remote port %d\n",
-			 np->name, np->remote_port);
+			 name, np->remote_port);
 	printk(KERN_INFO "%s: remote IP %d.%d.%d.%d\n",
-			 np->name, HIPQUAD(np->remote_ip));
+			 name, HIPQUAD(np->remote_ip));
 	printk(KERN_INFO "%s: remote ethernet address %s\n",
-	                 np->name, print_mac(mac, np->remote_mac));
+	                 name, print_mac(mac, np->remote_mac));
 }
 
 int netpoll_parse_options(struct netpoll *np, char *opt, char *dev_name)
@@ -640,13 +640,9 @@ int netpoll_parse_options(struct netpoll
 		np->remote_mac[5] = simple_strtol(cur, NULL, 16);
 	}
 
-	netpoll_print_options(np);
-
 	return 0;
 
  parse_failed:
-	printk(KERN_INFO "%s: couldn't parse config at %s!\n",
-	       np->name, cur);
 	return -1;
 }
 
@@ -679,8 +675,8 @@ int netpoll_setup(struct netpoll *np, st
 	}
 
 	if (!ndev->poll_controller) {
-		printk(KERN_ERR "%s: %s doesn't support polling, aborting.\n",
-		       np->name, ndev->name);
+		printk(KERN_ERR "netpoll: %s doesn't support polling, aborting.\n",
+		       ndev->name);
 		err = -ENOTSUPP;
 		goto release;
 	}
@@ -688,16 +684,16 @@ int netpoll_setup(struct netpoll *np, st
 	if (!netif_running(ndev)) {
 		unsigned long atmost, atleast;
 
-		printk(KERN_INFO "%s: device %s not up yet, forcing it\n",
-		       np->name, ndev->name);
+		printk(KERN_INFO "netpoll: device %s not up yet, forcing it\n",
+		       ndev->name);
 
 		rtnl_lock();
 		err = dev_open(ndev);
 		rtnl_unlock();
 
 		if (err) {
-			printk(KERN_ERR "%s: failed to open %s\n",
-			       np->name, ndev->name);
+			printk(KERN_ERR "netpoll: failed to open %s\n",
+			       ndev->name);
 			goto release;
 		}
 
@@ -705,9 +701,9 @@ int netpoll_setup(struct netpoll *np, st
 		atmost = jiffies + 4*HZ;
 		while (!netif_carrier_ok(ndev)) {
 			if (time_after(jiffies, atmost)) {
-				printk(KERN_NOTICE
-				       "%s: timeout waiting for carrier\n",
-				       np->name);
+				printk(KERN_NOTICE "netpoll:"
+				       "timeout waiting for carrier on '%s'\n",
+				       ndev->name);
 				break;
 			}
 			cond_resched();
@@ -719,9 +715,9 @@ int netpoll_setup(struct netpoll *np, st
 		 */
 
 		if (time_before(jiffies, atleast)) {
-			printk(KERN_NOTICE "%s: carrier detect appears"
-			       " untrustworthy, waiting 4 seconds\n",
-			       np->name);
+			printk(KERN_NOTICE "netpoll: carrier detect appears"
+			       " untrustworthy '%s', waiting 4 seconds\n",
+			       ndev->name);
 			msleep(4000);
 		}
 	}
@@ -732,16 +728,16 @@ int netpoll_setup(struct netpoll *np, st
 
 		if (!in_dev || !in_dev->ifa_list) {
 			rcu_read_unlock();
-			printk(KERN_ERR "%s: no IP address for %s, aborting\n",
-			       np->name, ndev->name);
+			printk(KERN_ERR "netpoll: no IP address for %s, aborting\n",
+			       ndev->name);
 			err = -EDESTADDRREQ;
 			goto release;
 		}
 
 		np->local_ip = ntohl(in_dev->ifa_list->ifa_local);
 		rcu_read_unlock();
-		printk(KERN_INFO "%s: local IP %d.%d.%d.%d\n",
-		       np->name, HIPQUAD(np->local_ip));
+		printk(KERN_INFO "netpoll: local IP %d.%d.%d.%d\n",
+		       HIPQUAD(np->local_ip));
 	}
 
 	if (np->rx_hook) {

-- 
Stephen Hemminger <shemminger@linux-foundation.org>

