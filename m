From: Luiz Augusto von Dentz <luiz.dentz-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH v7 1/6] bluetooth: Set 6 byte device addresses
Date: Sun, 12 Mar 2017 10:19:33 +0200
Message-ID: <20170312081938.11700-2-luiz.dentz@gmail.com>
References: <20170312081938.11700-1-luiz.dentz@gmail.com>
Cc: patrik.flykt-VuQAYsv1563Yd54FQh9/CA@public.gmane.org, aar-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org,
        jukka.rissanen-VuQAYsv1563Yd54FQh9/CA@public.gmane.org, linux-wpan-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170312081938.11700-1-luiz.dentz-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Patrik Flykt <patrik.flykt-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>

Set BTLE MAC addresses that are 6 bytes long and not 8 bytes
that are used in other places with 6lowpan.

Signed-off-by: Patrik Flykt <patrik.flykt-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Signed-off-by: Luiz Augusto von Dentz <luiz.von.dentz-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Reviewed-by: Stefan Schmidt <stefan-JPH+aEBZ4P+UEJcrhfAQsw@public.gmane.org>
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
