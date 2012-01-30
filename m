From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 1/2] netpoll: Convert printks to np_<level> and add pr_fmt
Date: Sun, 29 Jan 2012 17:50:43 -0800
Message-ID: <8a61df72a4eb6caaeaa8b5be644be227da61512b.1327888082.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use a more current message logging style.
Add pr_fmt to prefix dmesg output with "netpoll: "
Add macros to print np->name.

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/core/netpoll.c |   63 +++++++++++++++++++++++----------------------------
 1 files changed, 28 insertions(+), 35 deletions(-)

diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index 556b082..b523274 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -9,6 +9,8 @@
  * Copyright (C) 2002  Red Hat, Inc.
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/moduleparam.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
@@ -55,6 +57,13 @@ static void arp_reply(struct sk_buff *skb);
 static unsigned int carrier_timeout = 4;
 module_param(carrier_timeout, uint, 0644);
 
+#define np_info(np, fmt, ...)				\
+	pr_info("%s: " fmt, np->name, ##__VA_ARGS__)
+#define np_err(np, fmt, ...)				\
+	pr_err("%s: " fmt, np->name, ##__VA_ARGS__)
+#define np_notice(np, fmt, ...)				\
+	pr_notice("%s: " fmt, np->name, ##__VA_ARGS__)
+
 static void queue_process(struct work_struct *work)
 {
 	struct netpoll_info *npinfo =
@@ -627,18 +636,12 @@ out:
 
 void netpoll_print_options(struct netpoll *np)
 {
-	printk(KERN_INFO "%s: local port %d\n",
-			 np->name, np->local_port);
-	printk(KERN_INFO "%s: local IP %pI4\n",
-			 np->name, &np->local_ip);
-	printk(KERN_INFO "%s: interface '%s'\n",
-			 np->name, np->dev_name);
-	printk(KERN_INFO "%s: remote port %d\n",
-			 np->name, np->remote_port);
-	printk(KERN_INFO "%s: remote IP %pI4\n",
-			 np->name, &np->remote_ip);
-	printk(KERN_INFO "%s: remote ethernet address %pM\n",
-	                 np->name, np->remote_mac);
+	np_info(np, "local port %d\n", np->local_port);
+	np_info(np, "local IP %pI4\n", &np->local_ip);
+	np_info(np, "interface '%s'\n", np->dev_name);
+	np_info(np, "remote port %d\n", np->remote_port);
+	np_info(np, "remote IP %pI4\n", &np->remote_ip);
+	np_info(np, "remote ethernet address %pM\n", np->remote_mac);
 }
 EXPORT_SYMBOL(netpoll_print_options);
 
@@ -680,8 +683,7 @@ int netpoll_parse_options(struct netpoll *np, char *opt)
 			goto parse_failed;
 		*delim = 0;
 		if (*cur == ' ' || *cur == '\t')
-			printk(KERN_INFO "%s: warning: whitespace"
-					"is not allowed\n", np->name);
+			np_info(np, "warning: whitespace is not allowed\n");
 		np->remote_port = simple_strtol(cur, NULL, 10);
 		cur = delim;
 	}
@@ -705,8 +707,7 @@ int netpoll_parse_options(struct netpoll *np, char *opt)
 	return 0;
 
  parse_failed:
-	printk(KERN_INFO "%s: couldn't parse config at '%s'!\n",
-	       np->name, cur);
+	np_info(np, "couldn't parse config at '%s'!\n", cur);
 	return -1;
 }
 EXPORT_SYMBOL(netpoll_parse_options);
@@ -721,8 +722,8 @@ int __netpoll_setup(struct netpoll *np)
 
 	if ((ndev->priv_flags & IFF_DISABLE_NETPOLL) ||
 	    !ndev->netdev_ops->ndo_poll_controller) {
-		printk(KERN_ERR "%s: %s doesn't support polling, aborting.\n",
-		       np->name, np->dev_name);
+		np_err(np, "%s doesn't support polling, aborting\n",
+		       np->dev_name);
 		err = -ENOTSUPP;
 		goto out;
 	}
@@ -785,14 +786,12 @@ int netpoll_setup(struct netpoll *np)
 	if (np->dev_name)
 		ndev = dev_get_by_name(&init_net, np->dev_name);
 	if (!ndev) {
-		printk(KERN_ERR "%s: %s doesn't exist, aborting.\n",
-		       np->name, np->dev_name);
+		np_err(np, "%s doesn't exist, aborting\n", np->dev_name);
 		return -ENODEV;
 	}
 
 	if (ndev->master) {
-		printk(KERN_ERR "%s: %s is a slave device, aborting.\n",
-		       np->name, np->dev_name);
+		np_err(np, "%s is a slave device, aborting\n", np->dev_name);
 		err = -EBUSY;
 		goto put;
 	}
@@ -800,16 +799,14 @@ int netpoll_setup(struct netpoll *np)
 	if (!netif_running(ndev)) {
 		unsigned long atmost, atleast;
 
-		printk(KERN_INFO "%s: device %s not up yet, forcing it\n",
-		       np->name, np->dev_name);
+		np_info(np, "device %s not up yet, forcing it\n", np->dev_name);
 
 		rtnl_lock();
 		err = dev_open(ndev);
 		rtnl_unlock();
 
 		if (err) {
-			printk(KERN_ERR "%s: failed to open %s\n",
-			       np->name, ndev->name);
+			np_err(np, "failed to open %s\n", ndev->name);
 			goto put;
 		}
 
@@ -817,9 +814,7 @@ int netpoll_setup(struct netpoll *np)
 		atmost = jiffies + carrier_timeout * HZ;
 		while (!netif_carrier_ok(ndev)) {
 			if (time_after(jiffies, atmost)) {
-				printk(KERN_NOTICE
-				       "%s: timeout waiting for carrier\n",
-				       np->name);
+				np_notice(np, "timeout waiting for carrier\n");
 				break;
 			}
 			msleep(1);
@@ -831,9 +826,7 @@ int netpoll_setup(struct netpoll *np)
 		 */
 
 		if (time_before(jiffies, atleast)) {
-			printk(KERN_NOTICE "%s: carrier detect appears"
-			       " untrustworthy, waiting 4 seconds\n",
-			       np->name);
+			np_notice(np, "carrier detect appears untrustworthy, waiting 4 seconds\n");
 			msleep(4000);
 		}
 	}
@@ -844,15 +837,15 @@ int netpoll_setup(struct netpoll *np)
 
 		if (!in_dev || !in_dev->ifa_list) {
 			rcu_read_unlock();
-			printk(KERN_ERR "%s: no IP address for %s, aborting\n",
-			       np->name, np->dev_name);
+			np_err(np, "no IP address for %s, aborting\n",
+			       np->dev_name);
 			err = -EDESTADDRREQ;
 			goto put;
 		}
 
 		np->local_ip = in_dev->ifa_list->ifa_local;
 		rcu_read_unlock();
-		printk(KERN_INFO "%s: local IP %pI4\n", np->name, &np->local_ip);
+		np_info(np, "local IP %pI4\n", &np->local_ip);
 	}
 
 	np->dev = ndev;
-- 
1.7.8.111.gad25c.dirty
