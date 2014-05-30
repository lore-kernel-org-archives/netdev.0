From: Fugang Duan <b38611@freescale.com>
Subject: [PATCH v1 6/6] net: fec: Add software TSO support
Date: Fri, 30 May 2014 10:05:52 +0800
Message-ID: <1401415552-2263-7-git-send-email-b38611@freescale.com>
References: <1401415552-2263-1-git-send-email-b38611@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <ezequiel.garcia@free-electrons.com>, <netdev@vger.kernel.org>,
	<shawn.guo@linaro.org>, <bhutchings@solarflare.com>,
	<b38611@freescale.com>, <stephen@networkplumber.org>
To: <b20596@freescale.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2lp0203.outbound.protection.outlook.com ([207.46.163.203]:59714
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754509AbaE3D1y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 May 2014 23:27:54 -0400
In-Reply-To: <1401415552-2263-1-git-send-email-b38611@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add software TSO support for FEC.i
This feature allows to improve outbound throughput performance.
Tested on imx6dl sabresd board, running iperf tcp tests shows:
- 16.2% improvement comparing with FEC SG patch
- 82% improvement comparing with NO SG & TSO patch

$ ethtool -K eth0 tso on
[  3] local 10.192.242.108 port 35388 connected with 10.192.242.167 port 5001
[ ID] Interval       Transfer     Bandwidth
[  3]  0.0- 3.0 sec   181 MBytes   506 Mbits/sec

Signed-off-by: Fugang Duan <B38611@freescale.com>
---
 drivers/net/ethernet/freescale/fec.h      |    4 +
 drivers/net/ethernet/freescale/fec_main.c |  185 ++++++++++++++++++++++++++++-
 2 files changed, 187 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec.h b/drivers/net/ethernet/freescale/fec.h
index 57f3ecf..caba87d 100644
--- a/drivers/net/ethernet/freescale/fec.h
+++ b/drivers/net/ethernet/freescale/fec.h
@@ -299,6 +299,10 @@ struct fec_enet_private {
 	unsigned short tx_ring_size;
 	unsigned short rx_ring_size;
 
+	/* Software TSO */
+	char *tso_hdrs;
+	dma_addr_t tso_hdrs_dma;
+
 	struct	platform_device *pdev;
 
 	int	opened;
diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index a96ed3a..cd20344 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -36,6 +36,7 @@
 #include <linux/in.h>
 #include <linux/ip.h>
 #include <net/ip.h>
+#include <net/tso.h>
 #include <linux/tcp.h>
 #include <linux/udp.h>
 #include <linux/icmp.h>
@@ -227,6 +228,8 @@ MODULE_PARM_DESC(macaddr, "FEC Ethernet MAC address");
 #define FEC_PAUSE_FLAG_AUTONEG	0x1
 #define FEC_PAUSE_FLAG_ENABLE	0x2
 
+#define TSO_HEADER_SIZE		128
+
 static int mii_cnt;
 
 static inline
@@ -554,6 +557,174 @@ static int fec_enet_txq_submit_skb(struct sk_buff *skb, struct net_device *ndev)
 	return 0;
 }
 
+static int
+fec_enet_txq_put_data_tso(struct sk_buff *skb, struct net_device *ndev,
+			struct bufdesc *bdp, int index, char *data,
+			int size, bool last_tcp, bool is_last)
+{
+	struct fec_enet_private *fep = netdev_priv(ndev);
+	const struct platform_device_id *id_entry =
+				platform_get_device_id(fep->pdev);
+	struct bufdesc_ex *ebdp = (struct bufdesc_ex *)bdp;
+	unsigned short status;
+	unsigned int estatus = 0;
+
+	status = bdp->cbd_sc;
+	status &= ~BD_ENET_TX_STATS;
+
+	status |= (BD_ENET_TX_TC | BD_ENET_TX_READY);
+	bdp->cbd_datlen = size;
+
+	if (((unsigned long) data) & FEC_ALIGNMENT) {
+		memcpy(fep->tx_bounce[index], data, size);
+		data = fep->tx_bounce[index];
+	}
+	if (id_entry->driver_data & FEC_QUIRK_SWAP_FRAME)
+		swap_buffer(data, size);
+
+	bdp->cbd_bufaddr = dma_map_single(&fep->pdev->dev, data,
+					size, DMA_TO_DEVICE);
+	if (dma_mapping_error(&fep->pdev->dev, bdp->cbd_bufaddr)) {
+		dev_kfree_skb_any(skb);
+		if (net_ratelimit())
+			netdev_err(ndev, "Tx DMA memory map failed\n");
+		return NETDEV_TX_BUSY;
+	}
+
+	if (fep->bufdesc_ex) {
+		if (skb->ip_summed == CHECKSUM_PARTIAL)
+			estatus |= BD_ENET_TX_PINS | BD_ENET_TX_IINS;
+		ebdp->cbd_bdu = 0;
+		ebdp->cbd_esc = estatus;
+	}
+
+	/* Handle the last BD specially */
+	if (last_tcp)
+		status |= (BD_ENET_TX_LAST | BD_ENET_TX_TC);
+	if (is_last) {
+		status |= BD_ENET_TX_INTR;
+		if (fep->bufdesc_ex)
+			ebdp->cbd_esc |= BD_ENET_TX_INT;
+	}
+
+	bdp->cbd_sc = status;
+
+	return 0;
+}
+
+static void
+fec_enet_txq_put_hdr_tso(struct sk_buff *skb, struct net_device *ndev,
+			struct bufdesc *bdp, int index)
+{
+	struct fec_enet_private *fep = netdev_priv(ndev);
+	const struct platform_device_id *id_entry =
+				platform_get_device_id(fep->pdev);
+	int hdr_len = skb_transport_offset(skb) + tcp_hdrlen(skb);
+	struct bufdesc_ex *ebdp = (struct bufdesc_ex *)bdp;
+	void *bufaddr;
+	unsigned short status;
+	unsigned int estatus = 0;
+
+	status = bdp->cbd_sc;
+	status &= ~BD_ENET_TX_STATS;
+	status |= (BD_ENET_TX_TC | BD_ENET_TX_READY);
+
+	bufaddr = fep->tso_hdrs + index * TSO_HEADER_SIZE;
+	if (((unsigned long) bufaddr) & FEC_ALIGNMENT) {
+		memcpy(fep->tx_bounce[index], skb->data, hdr_len);
+		bufaddr = fep->tx_bounce[index];
+	}
+	if (id_entry->driver_data & FEC_QUIRK_SWAP_FRAME)
+		swap_buffer(bufaddr, hdr_len);
+
+	bdp->cbd_bufaddr = fep->tso_hdrs_dma + index * TSO_HEADER_SIZE;
+	bdp->cbd_datlen = hdr_len;
+
+	if (fep->bufdesc_ex) {
+		if (skb->ip_summed == CHECKSUM_PARTIAL)
+			estatus |= BD_ENET_TX_PINS | BD_ENET_TX_IINS;
+		ebdp->cbd_bdu = 0;
+		ebdp->cbd_esc = estatus;
+	}
+
+	bdp->cbd_sc = status;
+}
+
+static int fec_enet_txq_submit_tso(struct sk_buff *skb, struct net_device *ndev)
+{
+	struct fec_enet_private *fep = netdev_priv(ndev);
+	int hdr_len = skb_transport_offset(skb) + tcp_hdrlen(skb);
+	int total_len, data_left;
+	struct bufdesc *bdp = fep->cur_tx;
+	struct tso_t tso;
+	unsigned int index = 0;
+	int ret;
+
+	if (tso_count_descs(skb) >= fec_enet_txdesc_entry_free(fep)) {
+		if (net_ratelimit())
+			netdev_err(ndev, "tx queue full!\n");
+		return NETDEV_TX_BUSY;
+	}
+
+	/* Protocol checksum off-load for TCP and UDP. */
+	if (fec_enet_clear_csum(skb, ndev)) {
+		dev_kfree_skb_any(skb);
+		return NETDEV_TX_OK;
+	}
+
+	/* Initialize the TSO handler, and prepare the first payload */
+	tso_start(skb, &tso);
+
+	total_len = skb->len - hdr_len;
+	while (total_len > 0) {
+		char *hdr;
+
+		index = fec_enet_get_bd_index(bdp, fep);
+		data_left = min_t(int, skb_shinfo(skb)->gso_size, total_len);
+		total_len -= data_left;
+
+		/* prepare packet headers: MAC + IP + TCP */
+		hdr = fep->tso_hdrs + index * TSO_HEADER_SIZE;
+		tso_build_hdr(skb, hdr, &tso, data_left, total_len == 0);
+		fec_enet_txq_put_hdr_tso(skb, ndev, bdp, index);
+
+		while (data_left > 0) {
+			int size;
+
+			size = min_t(int, tso.size, data_left);
+			bdp = fec_enet_get_nextdesc(bdp, fep);
+			index = fec_enet_get_bd_index(bdp, fep);
+			ret = fec_enet_txq_put_data_tso(skb, ndev, bdp, index, tso.data,
+							size, size == data_left,
+							total_len == 0);
+			if (ret)
+				goto err_release;
+
+			data_left -= size;
+			tso_build_data(skb, &tso, size);
+		}
+
+		bdp = fec_enet_get_nextdesc(bdp, fep);
+	}
+
+	/* Save skb pointer */
+	fep->tx_skbuff[index] = skb;
+
+	fec_enet_submit_work(bdp, fep);
+
+	skb_tx_timestamp(skb);
+	fep->cur_tx = bdp;
+
+	/* Trigger transmission start */
+	writel(0, fep->hwp + FEC_X_DES_ACTIVE);
+
+	return 0;
+
+err_release:
+	/* TODO: Release all used data descriptors for TSO */
+	return ret;
+}
+
 static netdev_tx_t
 fec_enet_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 {
@@ -577,7 +748,10 @@ fec_enet_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 		return NETDEV_TX_BUSY;
 	}
 
-	ret = fec_enet_txq_submit_skb(skb, ndev);
+	if (skb_is_gso(skb))
+		ret = fec_enet_txq_submit_tso(skb, ndev);
+	else
+		ret = fec_enet_txq_submit_skb(skb, ndev);
 	if (ret)
 		return ret;
 
@@ -2198,6 +2372,13 @@ static int fec_enet_init(struct net_device *ndev)
 	if (!cbd_base)
 		return -ENOMEM;
 
+	fep->tso_hdrs = dma_alloc_coherent(NULL, fep->tx_ring_size * TSO_HEADER_SIZE,
+						&fep->tso_hdrs_dma, GFP_KERNEL);
+	if (!fep->tso_hdrs) {
+		dma_free_coherent(NULL, bd_size, cbd_base, fep->bd_dma);
+		return -ENOMEM;
+	}
+
 	memset(cbd_base, 0, PAGE_SIZE);
 
 	fep->netdev = ndev;
@@ -2230,7 +2411,7 @@ static int fec_enet_init(struct net_device *ndev)
 	if (id_entry->driver_data & FEC_QUIRK_HAS_CSUM) {
 		/* enable hw accelerator */
 		ndev->features |= (NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM
-				| NETIF_F_RXCSUM | NETIF_F_SG);
+				| NETIF_F_RXCSUM | NETIF_F_SG | NETIF_F_TSO);
 		fep->csum_flags |= FLAG_RX_CSUM_ENABLED;
 	}
 
-- 
1.7.8
