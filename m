From: Jim Baxter <jim_baxter@mentor.com>
Subject: [PATCH net-next v3 1/1] net: fec: Enable imx6 enet checksum acceleration.
Date: Wed, 17 Apr 2013 21:07:58 +0100
Message-ID: <1366229278-7528-1-git-send-email-jim_baxter@mentor.com>
References: <Jim Baxter <jim_baxter@mentor.com>
Cc: Frank Li <Frank.Li@freescale.com>,
	Fugang Duan <B38611@freescale.com>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay1.mentorg.com ([192.94.38.131]:40782 "EHLO
	relay1.mentorg.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965295Ab3DQUIO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Apr 2013 16:08:14 -0400
In-Reply-To: <Jim Baxter <jim_baxter@mentor.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Enables hardware generation of IP header and
protocol specific checksums for transmitted
packets.

Enabled hardware discarding of received packets with
invalid IP header or protocol specific checksums.

The feature is enabled by default but can be
enabled/disabled by ethtool.

Signed-off-by: Fugang Duan <B38611@freescale.com>
Signed-off-by: Jim Baxter <jim_baxter@mentor.com>
---
Changed NETIF_F_GRO feature to NETIF_F_RX_CSUM
Changed NETIF_F_HW_CSUM feature to NETIF_F_IP_CSUM
Removed error stats for receive checksum error and made code more readable.
Removed incorrect check for NETIF_F_HW_CSUM feature in checksum code.
Spelling corrections.


 drivers/net/ethernet/freescale/fec.h      |   10 ++-
 drivers/net/ethernet/freescale/fec_main.c |  133 ++++++++++++++++++++++++++++-
 2 files changed, 140 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec.h b/drivers/net/ethernet/freescale/fec.h
index eb43729..d44f65b 100644
--- a/drivers/net/ethernet/freescale/fec.h
+++ b/drivers/net/ethernet/freescale/fec.h
@@ -52,6 +52,7 @@
 #define FEC_R_FIFO_RSEM		0x194 /* Receive FIFO section empty threshold */
 #define FEC_R_FIFO_RAEM		0x198 /* Receive FIFO almost empty threshold */
 #define FEC_R_FIFO_RAFL		0x19c /* Receive FIFO almost full threshold */
+#define FEC_RACC		0x1C4 /* Receive Accelerator function */
 #define FEC_MIIGSK_CFGR		0x300 /* MIIGSK Configuration reg */
 #define FEC_MIIGSK_ENR		0x308 /* MIIGSK Enable reg */
 
@@ -164,9 +165,11 @@ struct bufdesc_ex {
 #define BD_ENET_TX_CSL          ((ushort)0x0001)
 #define BD_ENET_TX_STATS        ((ushort)0x03ff)        /* All status bits */
 
-/*enhanced buffer desciptor control/status used by Ethernet transmit*/
+/*enhanced buffer descriptor control/status used by Ethernet transmit*/
 #define BD_ENET_TX_INT          0x40000000
 #define BD_ENET_TX_TS           0x20000000
+#define BD_ENET_TX_PINS         0x10000000
+#define BD_ENET_TX_IINS         0x08000000
 
 
 /* This device has up to three irqs on some platforms */
@@ -190,6 +193,10 @@ struct bufdesc_ex {
 
 #define BD_ENET_RX_INT          0x00800000
 #define BD_ENET_RX_PTP          ((ushort)0x0400)
+#define BD_ENET_RX_ICE		0x00000020
+#define BD_ENET_RX_PCR		0x00000010
+#define FLAG_RX_CSUM_ENABLED	(BD_ENET_RX_ICE | BD_ENET_RX_PCR)
+#define FLAG_RX_CSUM_ERROR	(BD_ENET_RX_ICE | BD_ENET_RX_PCR)
 
 /* The FEC buffer descriptors track the ring buffers.  The rx_bd_base and
  * tx_bd_base always point to the base of the buffer descriptors.  The
@@ -247,6 +254,7 @@ struct fec_enet_private {
 	int	pause_flag;
 
 	struct	napi_struct napi;
+	int	csum_flags;
 
 	struct ptp_clock *ptp_clock;
 	struct ptp_clock_info ptp_caps;
diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index d7657a4..b626608 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -34,6 +34,12 @@
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/skbuff.h>
+#include <linux/in.h>
+#include <linux/ip.h>
+#include <net/ip.h>
+#include <linux/tcp.h>
+#include <linux/udp.h>
+#include <linux/icmp.h>
 #include <linux/spinlock.h>
 #include <linux/workqueue.h>
 #include <linux/bitops.h>
@@ -181,6 +187,10 @@ MODULE_PARM_DESC(macaddr, "FEC Ethernet MAC address");
 #define PKT_MINBUF_SIZE		64
 #define PKT_MAXBLR_SIZE		1520
 
+/* FEC receive acceleration */
+#define FEC_RACC_IPDIS		(1 << 1)
+#define FEC_RACC_PRODIS		(1 << 2)
+
 /*
  * The 5270/5271/5280/5282/532x RX control register also contains maximum frame
  * size bits. Other FEC hardware does not, so we need to take that into
@@ -241,6 +251,58 @@ static void *swap_buffer(void *bufaddr, int len)
 	return bufaddr;
 }
 
+static void
+fec_enet_clear_csum(struct sk_buff *skb, struct net_device *ndev)
+{
+	int hdr_len = 0;
+
+	/* Only run for packets requiring a checksum. */
+	if (skb->ip_summed != CHECKSUM_PARTIAL)
+		return;
+	if (skb->len < (ETH_HLEN + sizeof(struct iphdr)))
+		return;
+
+	if (skb->protocol == htons(ETH_P_IP)) {
+		ip_hdr(skb)->check = 0;
+
+		switch (ip_hdr(skb)->protocol) {
+		case IPPROTO_UDP:
+			hdr_len = (ETH_HLEN +
+					(ip_hdr(skb)->ihl << 2) +
+					sizeof(struct udphdr));
+			if (skb->len < hdr_len)
+				return;
+			skb_cow_head(skb, hdr_len);
+			skb_set_transport_header(skb,
+					ETH_HLEN + ip_hdrlen(skb));
+			udp_hdr(skb)->check = 0;
+			break;
+		case IPPROTO_TCP:
+			hdr_len = (ETH_HLEN +
+					(ip_hdr(skb)->ihl << 2) +
+					sizeof(struct tcphdr));
+			if (skb->len < hdr_len)
+				return;
+			skb_cow_head(skb, hdr_len);
+			if (tcp_hdr(skb))
+				tcp_hdr(skb)->check = 0;
+			break;
+		case IPPROTO_ICMP:
+			hdr_len = (ETH_HLEN +
+					(ip_hdr(skb)->ihl << 2) +
+					sizeof(struct icmphdr));
+			if (skb->len < hdr_len)
+				return;
+			skb_cow_head(skb, hdr_len);
+			if (icmp_hdr(skb))
+				icmp_hdr(skb)->checksum = 0;
+			break;
+		default:
+			break;
+		}
+	}
+}
+
 static netdev_tx_t
 fec_enet_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 {
@@ -277,6 +339,9 @@ fec_enet_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 	bufaddr = skb->data;
 	bdp->cbd_datlen = skb->len;
 
+	/* HW acceleration for ICMP TCP UDP checksum */
+	fec_enet_clear_csum(skb, ndev);
+
 	/*
 	 * On some FEC implementations data must be aligned on
 	 * 4-byte boundaries. Use bounce buffers to copy data
@@ -326,8 +391,10 @@ fec_enet_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 			ebdp->cbd_esc = (BD_ENET_TX_TS | BD_ENET_TX_INT);
 			skb_shinfo(skb)->tx_flags |= SKBTX_IN_PROGRESS;
 		} else {
-
 			ebdp->cbd_esc = BD_ENET_TX_INT;
+			if (skb->ip_summed == CHECKSUM_PARTIAL)
+				ebdp->cbd_esc |= BD_ENET_TX_PINS
+						| BD_ENET_TX_IINS;
 		}
 	}
 	/* If this was the last BD in the ring, start at the beginning again. */
@@ -407,6 +474,7 @@ fec_restart(struct net_device *ndev, int duplex)
 	const struct platform_device_id *id_entry =
 				platform_get_device_id(fep->pdev);
 	int i;
+	u32 val;
 	u32 temp_mac[2];
 	u32 rcntl = OPT_FRAME_SIZE | 0x04;
 	u32 ecntl = 0x2; /* ETHEREN */
@@ -473,6 +541,14 @@ fec_restart(struct net_device *ndev, int duplex)
 	/* Set MII speed */
 	writel(fep->phy_speed, fep->hwp + FEC_MII_SPEED);
 
+	/* set RX checksum */
+	val = readl(fep->hwp + FEC_RACC);
+	if (fep->csum_flags & FLAG_RX_CSUM_ENABLED)
+		val |= (FEC_RACC_IPDIS | FEC_RACC_PRODIS);
+	else
+		val &= ~(FEC_RACC_IPDIS | FEC_RACC_PRODIS);
+	writel(val, fep->hwp + FEC_RACC);
+
 	/*
 	 * The phy interface and speed need to get configured
 	 * differently on enet-mac.
@@ -530,7 +606,7 @@ fec_restart(struct net_device *ndev, int duplex)
 	     fep->phy_dev && fep->phy_dev->pause)) {
 		rcntl |= FEC_ENET_FCE;
 
-		/* set FIFO thresh hold parameter to reduce overrun */
+		/* set FIFO threshold parameter to reduce overrun */
 		writel(FEC_ENET_RSEM_V, fep->hwp + FEC_R_FIFO_RSEM);
 		writel(FEC_ENET_RSFL_V, fep->hwp + FEC_R_FIFO_RSFL);
 		writel(FEC_ENET_RAEM_V, fep->hwp + FEC_R_FIFO_RAEM);
@@ -818,6 +894,18 @@ fec_enet_rx(struct net_device *ndev, int budget)
 				spin_unlock_irqrestore(&fep->tmreg_lock, flags);
 			}
 
+			if (fep->bufdesc_ex &&
+				(fep->csum_flags & FLAG_RX_CSUM_ENABLED)) {
+				struct bufdesc_ex *ebdp =
+					(struct bufdesc_ex *)bdp;
+				if (!(ebdp->cbd_esc & FLAG_RX_CSUM_ERROR)) {
+					/* don't check it */
+					skb->ip_summed = CHECKSUM_UNNECESSARY;
+				} else {
+					skb_checksum_none_assert(skb);
+				}
+			}
+
 			if (!skb_defer_rx_timestamp(skb))
 				napi_gro_receive(&fep->napi, skb);
 		}
@@ -1439,6 +1527,9 @@ static int fec_enet_alloc_buffers(struct net_device *ndev)
 		if (fep->bufdesc_ex) {
 			struct bufdesc_ex *ebdp = (struct bufdesc_ex *)bdp;
 			ebdp->cbd_esc = BD_ENET_TX_INT;
+			if (ndev->features & NETIF_F_HW_CSUM)
+				ebdp->cbd_esc |= BD_ENET_TX_PINS
+						| BD_ENET_TX_IINS;
 		}
 
 		bdp = fec_enet_get_nextdesc(bdp, fep->bufdesc_ex);
@@ -1618,6 +1709,38 @@ static void fec_poll_controller(struct net_device *dev)
 }
 #endif
 
+static int fec_set_features(struct net_device *netdev,
+	netdev_features_t features)
+{
+	struct fec_enet_private *fep = netdev_priv(netdev);
+	netdev_features_t changed = features ^ netdev->features;
+	bool restart_required = false;
+
+	netdev->features = features;
+
+	/* Receive checksum has been changed */
+	if (changed & NETIF_F_RXCSUM) {
+		restart_required = true;
+		if (features & NETIF_F_RXCSUM)
+			fep->csum_flags |= FLAG_RX_CSUM_ENABLED;
+		else
+			fep->csum_flags &= ~FLAG_RX_CSUM_ENABLED;
+	}
+
+	/* Restart the network interface */
+	if (true == restart_required) {
+		if (netif_running(netdev)) {
+			fec_stop(netdev);
+			fec_restart(netdev, fep->phy_dev->duplex);
+			netif_wake_queue(netdev);
+		} else {
+			fec_restart(netdev, fep->phy_dev->duplex);
+		}
+	}
+
+	return 0;
+}
+
 static const struct net_device_ops fec_netdev_ops = {
 	.ndo_open		= fec_enet_open,
 	.ndo_stop		= fec_enet_close,
@@ -1631,6 +1754,7 @@ static const struct net_device_ops fec_netdev_ops = {
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= fec_poll_controller,
 #endif
+	.ndo_set_features	= fec_set_features,
 };
 
  /*
@@ -1672,6 +1796,11 @@ static int fec_enet_init(struct net_device *ndev)
 	writel(FEC_RX_DISABLED_IMASK, fep->hwp + FEC_IMASK);
 	netif_napi_add(ndev, &fep->napi, fec_enet_rx_napi, FEC_NAPI_WEIGHT);
 
+	/* enable hw accelerator */
+	ndev->features |= (NETIF_F_IP_CSUM | NETIF_F_RXCSUM);
+	ndev->hw_features |= (NETIF_F_IP_CSUM | NETIF_F_RXCSUM);
+	fep->csum_flags |= FLAG_RX_CSUM_ENABLED;
+
 	fec_restart(ndev, 0);
 
 	return 0;
-- 
1.7.10.4
