From: Luiz Augusto von Dentz <luiz.dentz@gmail.com>
Subject: [PATCH v6 1/6] bluetooth: Set 6 byte device addresses
Date: Thu,  2 Mar 2017 15:23:30 +0200
Message-ID: <20170302132335.21192-2-luiz.dentz@gmail.com>
References: <20170302132335.21192-1-luiz.dentz@gmail.com>
Cc: patrik.flykt@linux.intel.com, aar@pengutronix.de,
        jukka.rissanen@linux.intel.com, linux-wpan@vger.kernel.org,
        netdev@vger.kernel.org
To: linux-bluetooth@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f66.google.com ([209.85.215.66]:36595 "EHLO
        mail-lf0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753024AbdCBNcZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Mar 2017 08:32:25 -0500
In-Reply-To: <20170302132335.21192-1-luiz.dentz@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrik Flykt <patrik.flykt@linux.intel.com>

Set BTLE MAC addresses that are 6 bytes long and not 8 bytes
that are used in other places with 6lowpan.

Signed-off-by: Patrik Flykt <patrik.flykt@linux.intel.com>
Signed-off-by: Luiz Augusto von Dentz <luiz.von.dentz@intel.com>
Reviewed-by: Stefan Schmidt <stefan@osg.samsung.com>
---
 net/bluetooth/6lowpan.c | 19 ++++++++-----------
 1 file changed, 8 insertions(+), 11 deletions(-)

diff --git a/net/bluetooth/6lowpan.c b/net/bluetooth/6lowpan.c
index 1904a93..1456b01 100644
--- a/net/bluetooth/6lowpan.c
+++ b/net/bluetooth/6lowpan.c
@@ -80,6 +80,8 @@ struct lowpan_btle_dev {
 	struct delayed_work notify_peers;
 };
 
+static void set_addr(u8 *eui, u8 *addr, u8 addr_type);
+
 static inline struct lowpan_btle_dev *
 lowpan_btle_dev(const struct net_device *netdev)
 {
@@ -272,9 +274,10 @@ static int give_skb_to_upper(struct sk_buff *skb, struct net_device *dev)
 static int iphc_decompress(struct sk_buff *skb, struct net_device *netdev,
 			   struct l2cap_chan *chan)
 {
-	const u8 *saddr, *daddr;
+	const u8 *saddr;
 	struct lowpan_btle_dev *dev;
 	struct lowpan_peer *peer;
+	unsigned char eui64_daddr[EUI64_ADDR_LEN];
 
 	dev = lowpan_btle_dev(netdev);
 
@@ -285,9 +288,9 @@ static int iphc_decompress(struct sk_buff *skb, struct net_device *netdev,
 		return -EINVAL;
 
 	saddr = peer->eui64_addr;
-	daddr = dev->netdev->dev_addr;
+	set_addr(&eui64_daddr[0], chan->src.b, chan->src_type);
 
-	return lowpan_header_decompress(skb, netdev, daddr, saddr);
+	return lowpan_header_decompress(skb, netdev, &eui64_daddr, saddr);
 }
 
 static int recv_pkt(struct sk_buff *skb, struct net_device *dev,
@@ -681,13 +684,6 @@ static void set_addr(u8 *eui, u8 *addr, u8 addr_type)
 	BT_DBG("type %d addr %*phC", addr_type, 8, eui);
 }
 
-static void set_dev_addr(struct net_device *netdev, bdaddr_t *addr,
-		         u8 addr_type)
-{
-	netdev->addr_assign_type = NET_ADDR_PERM;
-	set_addr(netdev->dev_addr, addr->b, addr_type);
-}
-
 static void ifup(struct net_device *netdev)
 {
 	int err;
@@ -803,7 +799,8 @@ static int setup_netdev(struct l2cap_chan *chan, struct lowpan_btle_dev **dev)
 	if (!netdev)
 		return -ENOMEM;
 
-	set_dev_addr(netdev, &chan->src, chan->src_type);
+	netdev->addr_assign_type = NET_ADDR_PERM;
+	baswap((void *)netdev->dev_addr, &chan->src);
 
 	netdev->netdev_ops = &netdev_ops;
 	SET_NETDEV_DEV(netdev, &chan->conn->hcon->hdev->dev);
-- 
2.9.3
