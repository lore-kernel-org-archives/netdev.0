From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 1/2] netpoll: move np->dev and np->dev_name init into __netpoll_setup()
Date: Tue, 17 Jul 2012 17:22:35 +0200
Message-ID: <1342538556-22601-2-git-send-email-jiri@resnulli.us>
References: <1342538556-22601-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:63165 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754163Ab2GQPWo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2012 11:22:44 -0400
Received: by wgbdr13 with SMTP id dr13so502683wgb.1
        for <netdev@vger.kernel.org>; Tue, 17 Jul 2012 08:22:43 -0700 (PDT)
In-Reply-To: <1342538556-22601-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 drivers/net/bonding/bond_main.c |    4 +---
 include/linux/netpoll.h         |    2 +-
 net/8021q/vlan_dev.c            |    5 +----
 net/bridge/br_device.c          |    5 +----
 net/core/netpoll.c              |   10 +++++-----
 5 files changed, 9 insertions(+), 17 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 4ddcc3e..1eb3979 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1240,9 +1240,7 @@ static inline int slave_enable_netpoll(struct slave *slave)
 	if (!np)
 		goto out;
 
-	np->dev = slave->dev;
-	strlcpy(np->dev_name, slave->dev->name, IFNAMSIZ);
-	err = __netpoll_setup(np);
+	err = __netpoll_setup(np, slave->dev);
 	if (err) {
 		kfree(np);
 		goto out;
diff --git a/include/linux/netpoll.h b/include/linux/netpoll.h
index 5dfa091..28f5389 100644
--- a/include/linux/netpoll.h
+++ b/include/linux/netpoll.h
@@ -43,7 +43,7 @@ struct netpoll_info {
 void netpoll_send_udp(struct netpoll *np, const char *msg, int len);
 void netpoll_print_options(struct netpoll *np);
 int netpoll_parse_options(struct netpoll *np, char *opt);
-int __netpoll_setup(struct netpoll *np);
+int __netpoll_setup(struct netpoll *np, struct net_device *ndev);
 int netpoll_setup(struct netpoll *np);
 int netpoll_trap(void);
 void netpoll_set_trap(int trap);
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index da1bc9c..73a2a83 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -681,10 +681,7 @@ static int vlan_dev_netpoll_setup(struct net_device *dev, struct netpoll_info *n
 	if (!netpoll)
 		goto out;
 
-	netpoll->dev = real_dev;
-	strlcpy(netpoll->dev_name, real_dev->name, IFNAMSIZ);
-
-	err = __netpoll_setup(netpoll);
+	err = __netpoll_setup(netpoll, real_dev);
 	if (err) {
 		kfree(netpoll);
 		goto out;
diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index 929e48aed..f4be1bb 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -246,10 +246,7 @@ int br_netpoll_enable(struct net_bridge_port *p)
 	if (!np)
 		goto out;
 
-	np->dev = p->dev;
-	strlcpy(np->dev_name, p->dev->name, IFNAMSIZ);
-
-	err = __netpoll_setup(np);
+	err = __netpoll_setup(np, p->dev);
 	if (err) {
 		kfree(np);
 		goto out;
diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index f9f40b9..b4c90e4 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -715,14 +715,16 @@ int netpoll_parse_options(struct netpoll *np, char *opt)
 }
 EXPORT_SYMBOL(netpoll_parse_options);
 
-int __netpoll_setup(struct netpoll *np)
+int __netpoll_setup(struct netpoll *np, struct net_device *ndev)
 {
-	struct net_device *ndev = np->dev;
 	struct netpoll_info *npinfo;
 	const struct net_device_ops *ops;
 	unsigned long flags;
 	int err;
 
+	np->dev = ndev;
+	strlcpy(np->dev_name, ndev->name, IFNAMSIZ);
+
 	if ((ndev->priv_flags & IFF_DISABLE_NETPOLL) ||
 	    !ndev->netdev_ops->ndo_poll_controller) {
 		np_err(np, "%s doesn't support polling, aborting\n",
@@ -851,13 +853,11 @@ int netpoll_setup(struct netpoll *np)
 		np_info(np, "local IP %pI4\n", &np->local_ip);
 	}
 
-	np->dev = ndev;
-
 	/* fill up the skb queue */
 	refill_skbs();
 
 	rtnl_lock();
-	err = __netpoll_setup(np);
+	err = __netpoll_setup(np, ndev);
 	rtnl_unlock();
 
 	if (err)
-- 
1.7.10.4
