From: Lance Richardson <lrichard@redhat.com>
Subject: [PATCHi next] veth: advertise peer link relationship for both devices
Date: Fri, 10 Jun 2016 12:32:19 -0400
Message-ID: <1465576339-17641-1-git-send-email-lrichard@redhat.com>
Cc: nicolas.dichtel@6wind.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43665 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753041AbcFJQcY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Jun 2016 12:32:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, when creating a veth pair, notfications to user
space only include link peer for one end of the veth pair:
   # ip monitor link &
   # ip link add dev vm1 type veth peer name vm2
   30: vm2@NONE: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN
       link/ether be:e3:b7:0e:14:52 brd ff:ff:ff:ff:ff:ff
   31: vm1@vm2: <BROADCAST,MULTICAST,M-DOWN> mtu 1500 qdisc noop state DOWN
       link/ether da:e6:a6:c5:42:54 brd ff:ff:ff:ff:ff:ff

With this change, netlink notifications are sent with complete
information for both interfaces of the veth pair:

   # 3: vm2@NONE: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN
       link/ether e2:94:54:8a:ac:f5 brd ff:ff:ff:ff:ff:ff
   4: vm1@vm2: <BROADCAST,MULTICAST,M-DOWN> mtu 1500 qdisc noop state DOWN
       link/ether b2:05:70:e0:fc:35 brd ff:ff:ff:ff:ff:ff
   3: vm2@vm1: <BROADCAST,MULTICAST,M-DOWN> mtu 1500 qdisc noop state DOWN
       link/ether e2:94:54:8a:ac:f5 brd ff:ff:ff:ff:ff:ff

Signed-off-by: Lance Richardson <lrichard@redhat.com>
---
 drivers/net/veth.c   | 10 +++++++++-
 net/core/rtnetlink.c | 10 ++++++++--
 2 files changed, 17 insertions(+), 3 deletions(-)

diff --git a/drivers/net/veth.c b/drivers/net/veth.c
index f37a6e6..9151686 100644
--- a/drivers/net/veth.c
+++ b/drivers/net/veth.c
@@ -458,7 +458,7 @@ static int veth_newlink(struct net *src_net, struct net_device *dev,
 	netif_carrier_off(dev);
 
 	/*
-	 * tie the deviced together
+	 * tie the devices together
 	 */
 
 	priv = netdev_priv(dev);
@@ -466,8 +466,16 @@ static int veth_newlink(struct net *src_net, struct net_device *dev,
 
 	priv = netdev_priv(peer);
 	rcu_assign_pointer(priv->peer, dev);
+
+	err = rtnl_configure_link(dev, NULL);
+	if (err < 0)
+		goto err_configure_dev;
+
+	rtmsg_ifinfo(RTM_NEWLINK, peer, 0, GFP_KERNEL);
 	return 0;
 
+err_configure_dev:
+	/* nothing to do */
 err_register_dev:
 	/* nothing to do */
 err_configure_peer:
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index d69c464..e0956bb 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -2165,6 +2165,7 @@ static int rtnl_dellink(struct sk_buff *skb, struct nlmsghdr *nlh)
 int rtnl_configure_link(struct net_device *dev, const struct ifinfomsg *ifm)
 {
 	unsigned int old_flags;
+	unsigned int gchanges;
 	int err;
 
 	old_flags = dev->flags;
@@ -2174,9 +2175,14 @@ int rtnl_configure_link(struct net_device *dev, const struct ifinfomsg *ifm)
 			return err;
 	}
 
-	dev->rtnl_link_state = RTNL_LINK_INITIALIZED;
+	if (dev->rtnl_link_state == RTNL_LINK_INITIALIZING) {
+		dev->rtnl_link_state = RTNL_LINK_INITIALIZED;
+		gchanges = ~0U;
+	} else {
+		gchanges = dev->flags ^ old_flags;
+	}
 
-	__dev_notify_flags(dev, old_flags, ~0U);
+	__dev_notify_flags(dev, old_flags, gchanges);
 	return 0;
 }
 EXPORT_SYMBOL(rtnl_configure_link);
-- 
2.5.5
