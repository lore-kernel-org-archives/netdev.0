From: David L Stevens <david.stevens@oracle.com>
Subject: [PATCHv8 net-next 3/4] sunvnet: allow admin to set sunvnet MTU
Date: Mon, 29 Sep 2014 15:54:22 -0400
Message-ID: <5429B8EE.5060102@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Sowmini Varadhan <sowmini.varadhan@oracle.com>,
	Raghuram Kothahota <raghuram.kothakota@oracle.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:46655 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755073AbaI2Txu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2014 15:53:50 -0400
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
index 7faa0ca..e1f954c 100644
--- a/drivers/net/ethernet/sun/sunvnet.c
+++ b/drivers/net/ethernet/sun/sunvnet.c
@@ -887,6 +887,9 @@ static int vnet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (unlikely(!skb))
 		goto out_dropped;
 
+	if (skb->len > port->rmtu)
+		goto out_dropped;
+
 	spin_lock_irqsave(&port->vio.lock, flags);
 
 	dr = &port->vio.drings[VIO_DRIVER_TX_RING];
@@ -917,7 +920,7 @@ static int vnet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	port->tx_bufs[txi].skb = skb;
 
 	err = ldc_map_single(port->vio.lp, start, nlen,
-			     port->tx_bufs[txi].cookies, 2,
+			     port->tx_bufs[txi].cookies, VNET_MAXCOOKIES,
 			     (LDC_MAP_SHADOW | LDC_MAP_DIRECT | LDC_MAP_RW));
 	if (err < 0) {
 		netdev_info(dev, "tx buffer map error %d\n", err);
@@ -1146,7 +1149,7 @@ static void vnet_set_rx_mode(struct net_device *dev)
 
 static int vnet_change_mtu(struct net_device *dev, int new_mtu)
 {
-	if (new_mtu != ETH_DATA_LEN)
+	if (new_mtu < 68 || new_mtu > 65535)
 		return -EINVAL;
 
 	dev->mtu = new_mtu;
diff --git a/drivers/net/ethernet/sun/sunvnet.h b/drivers/net/ethernet/sun/sunvnet.h
index f18409b..ead9001 100644
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
 	struct sk_buff		*skb;
 	unsigned int		ncookies;
-	struct ldc_trans_cookie	cookies[2];
+	struct ldc_trans_cookie	cookies[VNET_MAXCOOKIES];
 };
 
 struct vnet;
-- 
1.7.1
