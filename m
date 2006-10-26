From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 4/8] netpoll setup error handling
Date: Thu, 26 Oct 2006 15:46:52 -0700
Message-ID: <20061026225646.011206921@osdl.org>
References: <20061026225535.443288276@osdl.org>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:15547 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1423694AbWJZXBF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2006 19:01:05 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline; filename=netpoll-setup-errors.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The beast was not always healthy. When it was sick,
it tended to be laconic and not tell anyone the real problem.
A few small changes had it telling the world about its
problems, if they really wanted to hear.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
---
 drivers/net/netconsole.c |    7 +++++--
 net/core/netpoll.c       |   20 +++++++++++++-------
 2 files changed, 18 insertions(+), 9 deletions(-)

--- linux-2.6.orig/drivers/net/netconsole.c
+++ linux-2.6/drivers/net/netconsole.c
@@ -102,6 +102,8 @@ __setup("netconsole=", option_setup);
 
 static int init_netconsole(void)
 {
+	int err;
+
 	if(strlen(config))
 		option_setup(config);
 
@@ -110,8 +112,9 @@ static int init_netconsole(void)
 		return 0;
 	}
 
-	if(netpoll_setup(&np))
-		return -EINVAL;
+	err = netpoll_setup(&np);
+	if (err)
+		return err;
 
 	register_console(&netconsole);
 	printk(KERN_INFO "netconsole: network logging started\n");
--- linux-2.6.orig/net/core/netpoll.c
+++ linux-2.6/net/core/netpoll.c
@@ -602,20 +602,23 @@ int netpoll_setup(struct netpoll *np)
 	struct in_device *in_dev;
 	struct netpoll_info *npinfo;
 	unsigned long flags;
+	int err;
 
 	if (np->dev_name)
 		ndev = dev_get_by_name(np->dev_name);
 	if (!ndev) {
 		printk(KERN_ERR "%s: %s doesn't exist, aborting.\n",
 		       np->name, np->dev_name);
-		return -1;
+		return -ENODEV;
 	}
 
 	np->dev = ndev;
 	if (!ndev->npinfo) {
 		npinfo = kmalloc(sizeof(*npinfo), GFP_KERNEL);
-		if (!npinfo)
+		if (!npinfo) {
+			err = -ENOMEM;
 			goto release;
+		}
 
 		npinfo->rx_flags = 0;
 		npinfo->rx_np = NULL;
@@ -636,6 +639,7 @@ int netpoll_setup(struct netpoll *np)
 	if (!ndev->poll_controller) {
 		printk(KERN_ERR "%s: %s doesn't support polling, aborting.\n",
 		       np->name, np->dev_name);
+		err = -ENOTSUPP;
 		goto release;
 	}
 
@@ -646,13 +650,14 @@ int netpoll_setup(struct netpoll *np)
 		       np->name, np->dev_name);
 
 		rtnl_lock();
-		if (dev_change_flags(ndev, ndev->flags | IFF_UP) < 0) {
+		err = dev_open(ndev);
+		rtnl_unlock();
+
+		if (err) {
 			printk(KERN_ERR "%s: failed to open %s\n",
-			       np->name, np->dev_name);
-			rtnl_unlock();
+			       np->name, ndev->name);
 			goto release;
 		}
-		rtnl_unlock();
 
 		atleast = jiffies + HZ/10;
  		atmost = jiffies + 4*HZ;
@@ -690,6 +695,7 @@ int netpoll_setup(struct netpoll *np)
 			rcu_read_unlock();
 			printk(KERN_ERR "%s: no IP address for %s, aborting\n",
 			       np->name, np->dev_name);
+			err = -EDESTADDRREQ;
 			goto release;
 		}
 
@@ -722,7 +728,7 @@ int netpoll_setup(struct netpoll *np)
 		kfree(npinfo);
 	np->dev = NULL;
 	dev_put(ndev);
-	return -1;
+	return err;
 }
 
 static int __init netpoll_init(void) {

--
Stephen Hemminger <shemminger@osdl.org>

