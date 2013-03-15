From: Jesse Gross <jesse@nicira.com>
Subject: [PATCH net-next 1/5] openvswitch: Use eth_mac_addr() instead of duplicating it
Date: Fri, 15 Mar 2013 10:38:47 -0700
Message-ID: <1363369131-16830-2-git-send-email-jesse@nicira.com>
References: <1363369131-16830-1-git-send-email-jesse@nicira.com>
Cc: netdev@vger.kernel.org, dev@openvswitch.org,
	Thomas Graf <tgraf@redhat.com>, Jesse Gross <jesse@nicira.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog108.obsmtp.com ([74.125.149.199]:47688 "HELO
	na3sys009aog108.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751901Ab3CORjA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Mar 2013 13:39:00 -0400
Received: by mail-oa0-f72.google.com with SMTP id j6so18925441oag.11
        for <netdev@vger.kernel.org>; Fri, 15 Mar 2013 10:39:00 -0700 (PDT)
In-Reply-To: <1363369131-16830-1-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@redhat.com>

bonus: if we ever are to use IFF_LIVE_ADDR_CHANGE for
anything further than to check availability in eth_mac_addr(),
Open vSwitch will be ready for that.

Signed-off-by: Thomas Graf <tgraf@redhat.com>
Signed-off-by: Jesse Gross <jesse@nicira.com>
---
 net/openvswitch/vport-internal_dev.c |   14 ++------------
 1 file changed, 2 insertions(+), 12 deletions(-)

diff --git a/net/openvswitch/vport-internal_dev.c b/net/openvswitch/vport-internal_dev.c
index 5d460c3..90816c7 100644
--- a/net/openvswitch/vport-internal_dev.c
+++ b/net/openvswitch/vport-internal_dev.c
@@ -63,17 +63,6 @@ static struct rtnl_link_stats64 *internal_dev_get_stats(struct net_device *netde
 	return stats;
 }
 
-static int internal_dev_mac_addr(struct net_device *dev, void *p)
-{
-	struct sockaddr *addr = p;
-
-	if (!is_valid_ether_addr(addr->sa_data))
-		return -EADDRNOTAVAIL;
-	dev->addr_assign_type &= ~NET_ADDR_RANDOM;
-	memcpy(dev->dev_addr, addr->sa_data, dev->addr_len);
-	return 0;
-}
-
 /* Called with rcu_read_lock_bh. */
 static int internal_dev_xmit(struct sk_buff *skb, struct net_device *netdev)
 {
@@ -127,7 +116,7 @@ static const struct net_device_ops internal_dev_netdev_ops = {
 	.ndo_open = internal_dev_open,
 	.ndo_stop = internal_dev_stop,
 	.ndo_start_xmit = internal_dev_xmit,
-	.ndo_set_mac_address = internal_dev_mac_addr,
+	.ndo_set_mac_address = eth_mac_addr,
 	.ndo_change_mtu = internal_dev_change_mtu,
 	.ndo_get_stats64 = internal_dev_get_stats,
 };
@@ -139,6 +128,7 @@ static void do_setup(struct net_device *netdev)
 	netdev->netdev_ops = &internal_dev_netdev_ops;
 
 	netdev->priv_flags &= ~IFF_TX_SKB_SHARING;
+	netdev->priv_flags |= IFF_LIVE_ADDR_CHANGE;
 	netdev->destructor = internal_dev_destructor;
 	SET_ETHTOOL_OPS(netdev, &internal_dev_ethtool_ops);
 	netdev->tx_queue_len = 0;
-- 
1.7.10.4
