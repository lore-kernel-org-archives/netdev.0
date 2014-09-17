From: David L Stevens <david.stevens@oracle.com>
Subject: [PATCHv5 net-next 2/3] sunvnet: allow admin to set sunvnet MTU
Date: Wed, 17 Sep 2014 16:50:04 -0400
Message-ID: <5419F3FC.80407@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:41833 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756245AbaIQUuJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Sep 2014 16:50:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch allows an admin to set the MTU on a sunvnet device to arbitrary
values between the minimum (68) and maximum (65535) IPv4 packet sizes.

Signed-off-by: David L Stevens <david.stevens@oracle.com>
---
 arch/sparc/kernel/ldc.c            |    2 +-
 drivers/net/ethernet/sun/sunvnet.c |    7 +++++--
 drivers/net/ethernet/sun/sunvnet.h |    6 ++++--
 3 files changed, 10 insertions(+), 5 deletions(-)

diff --git a/arch/sparc/kernel/ldc.c b/arch/sparc/kernel/ldc.c
index 66dacd5..0af28b9 100644
--- a/arch/sparc/kernel/ldc.c
+++ b/arch/sparc/kernel/ldc.c
@@ -2159,7 +2159,7 @@ int ldc_map_single(struct ldc_channel *lp,
 	state.pte_idx = (base - iommu->page_table);
 	state.nc = 0;
 	fill_cookies(&state, (pa & PAGE_MASK), (pa & ~PAGE_MASK), len);
-	BUG_ON(state.nc != 1);
+	BUG_ON(state.nc > ncookies);
 
 	return state.nc;
 }
diff --git a/drivers/net/ethernet/sun/sunvnet.c b/drivers/net/ethernet/sun/sunvnet.c
index a9638c1..5e64e60 100644
--- a/drivers/net/ethernet/sun/sunvnet.c
+++ b/drivers/net/ethernet/sun/sunvnet.c
@@ -791,6 +791,9 @@ static int vnet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (unlikely(!port))
 		goto out_dropped;
 
+	if (skb->len > port->rmtu)
+		goto out_dropped;
+
 	spin_lock_irqsave(&port->vio.lock, flags);
 
 	dr = &port->vio.drings[VIO_DRIVER_TX_RING];
@@ -1038,7 +1041,7 @@ static void vnet_set_rx_mode(struct net_device *dev)
 
 static int vnet_change_mtu(struct net_device *dev, int new_mtu)
 {
-	if (new_mtu != ETH_DATA_LEN)
+	if (new_mtu < 68 || new_mtu > 65535)
 		return -EINVAL;
 
 	dev->mtu = new_mtu;
@@ -1131,7 +1134,7 @@ static int vnet_port_alloc_tx_bufs(struct vnet_port *port)
 		}
 
 		err = ldc_map_single(port->vio.lp, buf, map_len,
-				     port->tx_bufs[i].cookies, 2,
+				     port->tx_bufs[i].cookies, VNET_MAXCOOKIES,
 				     (LDC_MAP_SHADOW |
 				      LDC_MAP_DIRECT |
 				      LDC_MAP_RW));
diff --git a/drivers/net/ethernet/sun/sunvnet.h b/drivers/net/ethernet/sun/sunvnet.h
index 986e04b..a39a801 100644
--- a/drivers/net/ethernet/sun/sunvnet.h
+++ b/drivers/net/ethernet/sun/sunvnet.h
@@ -11,7 +11,7 @@
  */
 #define VNET_TX_TIMEOUT			(5 * HZ)
 
-#define VNET_MAXPACKET			1518ULL /* ETH_FRAMELEN + VLAN_HDR */
+#define VNET_MAXPACKET			(65535ULL + ETH_HLEN + VLAN_HLEN)
 #define VNET_TX_RING_SIZE		512
 #define VNET_TX_WAKEUP_THRESH(dr)	((dr)->pending / 4)
 
@@ -21,10 +21,12 @@
  */
 #define VNET_PACKET_SKIP		6
 
+#define VNET_MAXCOOKIES			(VNET_MAXPACKET/PAGE_SIZE + 1)
+
 struct vnet_tx_entry {
 	void			*buf;
 	unsigned int		ncookies;
-	struct ldc_trans_cookie	cookies[2];
+	struct ldc_trans_cookie	cookies[VNET_MAXCOOKIES];
 };
 
 struct vnet;
-- 
1.7.1
