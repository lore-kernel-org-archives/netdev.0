From: Jim Baxter <jim_baxter@mentor.com>
Subject: [PATCH net-next v2 1/1] net: fec: Add VLAN receive HW support.
Date: Fri, 28 Jun 2013 15:08:23 +0100
Message-ID: <1372428503-13744-1-git-send-email-jim_baxter@mentor.com>
References: <Jim Baxter <jim_baxter@mentor.com>
Cc: Frank Li <Frank.Li@freescale.com>,
	Fugang Duan <B38611@freescale.com>,
	Fabio Estevam <fabio.estevam@freescale.com>,
	Lucas Stach <l.stach@pengutronix.de>,
	Shawn Guo <shawn.guo@linaro.org>, netdev@vger.kernel.org,
	Ben Hutchings <bhutchings@solarflare.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay1.mentorg.com ([192.94.38.131]:33949 "EHLO
	relay1.mentorg.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752128Ab3F1OIf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Jun 2013 10:08:35 -0400
In-Reply-To: <Jim Baxter <jim_baxter@mentor.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This enables the driver to take advantage of the FEC VLAN
indicator to improve performance.

Signed-off-by: Jim Baxter <jim_baxter@mentor.com>
---
Change from v1 to v2
Changed Max recieve Buffer Size Register from 1540 to 1536 so it is
divisible by 64.

 drivers/net/ethernet/freescale/fec.h      |    3 ++
 drivers/net/ethernet/freescale/fec_main.c |   64 +++++++++++++++++++++++------
 2 files changed, 55 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec.h b/drivers/net/ethernet/freescale/fec.h
index 8362a03..2b0a0ea 100644
--- a/drivers/net/ethernet/freescale/fec.h
+++ b/drivers/net/ethernet/freescale/fec.h
@@ -203,6 +203,9 @@ struct bufdesc_ex {
 #define BD_ENET_RX_CL           ((ushort)0x0001)
 #define BD_ENET_RX_STATS        ((ushort)0x013f)        /* All status bits */
 
+/* Enhanced buffer descriptor control/status used by Ethernet receive */
+#define BD_ENET_RX_VLAN         0x00000004
+
 /* Buffer descriptor control/status used by Ethernet transmit.
 */
 #define BD_ENET_TX_READY        ((ushort)0x8000)
diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index ed6180e..b94dde2 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -54,6 +54,7 @@
 #include <linux/of_gpio.h>
 #include <linux/of_net.h>
 #include <linux/regulator/consumer.h>
+#include <linux/if_vlan.h>
 
 #include <asm/cacheflush.h>
 
@@ -88,6 +89,8 @@
 #define FEC_QUIRK_HAS_BUFDESC_EX	(1 << 4)
 /* Controller has hardware checksum support */
 #define FEC_QUIRK_HAS_CSUM		(1 << 5)
+/* Controller has hardware vlan support */
+#define FEC_QUIRK_HAS_VLAN		(1 << 6)
 
 static struct platform_device_id fec_devtype[] = {
 	{
@@ -106,7 +109,8 @@ static struct platform_device_id fec_devtype[] = {
 	}, {
 		.name = "imx6q-fec",
 		.driver_data = FEC_QUIRK_ENET_MAC | FEC_QUIRK_HAS_GBIT |
-				FEC_QUIRK_HAS_BUFDESC_EX | FEC_QUIRK_HAS_CSUM,
+				FEC_QUIRK_HAS_BUFDESC_EX | FEC_QUIRK_HAS_CSUM |
+				FEC_QUIRK_HAS_VLAN,
 	}, {
 		.name = "mvf600-fec",
 		.driver_data = FEC_QUIRK_ENET_MAC,
@@ -177,11 +181,11 @@ MODULE_PARM_DESC(macaddr, "FEC Ethernet MAC address");
 #define FEC_DEFAULT_IMASK (FEC_ENET_TXF | FEC_ENET_RXF | FEC_ENET_MII)
 #define FEC_RX_DISABLED_IMASK (FEC_DEFAULT_IMASK & (~FEC_ENET_RXF))
 
-/* The FEC stores dest/src/type, data, and checksum for receive packets.
+/* The FEC stores dest/src/type/vlan, data, and checksum for receive packets.
  */
-#define PKT_MAXBUF_SIZE		1518
+#define PKT_MAXBUF_SIZE		1522
 #define PKT_MINBUF_SIZE		64
-#define PKT_MAXBLR_SIZE		1520
+#define PKT_MAXBLR_SIZE		1536
 
 /* FEC receive acceleration */
 #define FEC_RACC_IPDIS		(1 << 1)
@@ -803,6 +807,9 @@ fec_enet_rx(struct net_device *ndev, int budget)
 	ushort	pkt_len;
 	__u8 *data;
 	int	pkt_received = 0;
+	struct	bufdesc_ex *ebdp = NULL;
+	bool	vlan_packet_rcvd = false;
+	u16	vlan_tag;
 
 #ifdef CONFIG_M532x
 	flush_cache_all();
@@ -866,6 +873,24 @@ fec_enet_rx(struct net_device *ndev, int budget)
 		if (id_entry->driver_data & FEC_QUIRK_SWAP_FRAME)
 			swap_buffer(data, pkt_len);
 
+		/* Extract the enhanced buffer descriptor */
+		ebdp = NULL;
+		if (fep->bufdesc_ex)
+			ebdp = (struct bufdesc_ex *)bdp;
+
+		/* If this is a VLAN packet remove the VLAN Tag */
+		vlan_packet_rcvd = false;
+		if ((ndev->features & NETIF_F_HW_VLAN_CTAG_RX) &&
+				ebdp && (ebdp->cbd_esc & BD_ENET_RX_VLAN)) {
+			/* Push and remove the vlan tag */
+			struct vlan_hdr *vlan_header =
+					(struct vlan_hdr *) (data + ETH_HLEN);
+			vlan_tag = ntohs(vlan_header->h_vlan_TCI);
+			pkt_len -= VLAN_HLEN;
+
+			vlan_packet_rcvd = true;
+		}
+
 		/* This does 16 byte alignment, exactly what we need.
 		 * The packet length includes FCS, but we don't want to
 		 * include that when passing upstream as it messes up
@@ -876,18 +901,25 @@ fec_enet_rx(struct net_device *ndev, int budget)
 		if (unlikely(!skb)) {
 			ndev->stats.rx_dropped++;
 		} else {
+			int payload_offset = (2 * ETH_ALEN);
 			skb_reserve(skb, NET_IP_ALIGN);
 			skb_put(skb, pkt_len - 4);	/* Make room */
-			skb_copy_to_linear_data(skb, data, pkt_len - 4);
+
+			/* Extract the frame data without the VLAN header. */
+			skb_copy_to_linear_data(skb, data, (2 * ETH_ALEN));
+			if (vlan_packet_rcvd)
+				payload_offset = (2 * ETH_ALEN) + VLAN_HLEN;
+			skb_copy_to_linear_data_offset(skb, (2 * ETH_ALEN),
+					data + payload_offset,
+					pkt_len - 4 - (2 * ETH_ALEN));
+
 			skb->protocol = eth_type_trans(skb, ndev);
 
 			/* Get receive timestamp from the skb */
-			if (fep->hwts_rx_en && fep->bufdesc_ex) {
+			if (fep->hwts_rx_en && ebdp) {
 				struct skb_shared_hwtstamps *shhwtstamps =
 							    skb_hwtstamps(skb);
 				unsigned long flags;
-				struct bufdesc_ex *ebdp =
-					(struct bufdesc_ex *)bdp;
 
 				memset(shhwtstamps, 0, sizeof(*shhwtstamps));
 
@@ -897,10 +929,7 @@ fec_enet_rx(struct net_device *ndev, int budget)
 				spin_unlock_irqrestore(&fep->tmreg_lock, flags);
 			}
 
-			if (fep->bufdesc_ex &&
-				(fep->csum_flags & FLAG_RX_CSUM_ENABLED)) {
-				struct bufdesc_ex *ebdp =
-					(struct bufdesc_ex *)bdp;
+			if (ebdp && (fep->csum_flags & FLAG_RX_CSUM_ENABLED)) {
 				if (!(ebdp->cbd_esc & FLAG_RX_CSUM_ERROR)) {
 					/* don't check it */
 					skb->ip_summed = CHECKSUM_UNNECESSARY;
@@ -909,6 +938,11 @@ fec_enet_rx(struct net_device *ndev, int budget)
 				}
 			}
 
+			/* Handle received VLAN packets */
+			if (vlan_packet_rcvd)
+				__vlan_hwaccel_put_tag(skb,
+						htons(ETH_P_8021Q), vlan_tag);
+
 			if (!skb_defer_rx_timestamp(skb))
 				napi_gro_receive(&fep->napi, skb);
 		}
@@ -1916,6 +1950,12 @@ static int fec_enet_init(struct net_device *ndev)
 	writel(FEC_RX_DISABLED_IMASK, fep->hwp + FEC_IMASK);
 	netif_napi_add(ndev, &fep->napi, fec_enet_rx_napi, FEC_NAPI_WEIGHT);
 
+	if (id_entry->driver_data & FEC_QUIRK_HAS_VLAN) {
+		/* enable hw VLAN support */
+		ndev->features |= NETIF_F_HW_VLAN_CTAG_RX;
+		ndev->hw_features |= NETIF_F_HW_VLAN_CTAG_RX;
+	}
+
 	if (id_entry->driver_data & FEC_QUIRK_HAS_CSUM) {
 		/* enable hw accelerator */
 		ndev->features |= (NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM
-- 
1.7.10.4
