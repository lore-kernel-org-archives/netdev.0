From: =?UTF-8?q?Lothar=20Wa=C3=9Fmann?= <LW@KARO-electronics.de>
Subject: [PATCH 5/8] net: fec: improve access to quirk flags by copying them into fec_enet_private struct
Date: Mon, 17 Nov 2014 10:51:21 +0100
Message-ID: <1416217884-20911-6-git-send-email-LW@KARO-electronics.de>
References: <1416217884-20911-1-git-send-email-LW@KARO-electronics.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Lothar=20Wa=C3=9Fmann?= <LW@KARO-electronics.de>,
	netdev@vger.kernel.org, Frank Li <Frank.Li@freescale.com>,
	Fugang Duan <fugang.duan@freescale.com>,
	Russell King <rmk+kernel@arm.linux.org.uk>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.karo-electronics.de ([81.173.242.67]:53264 "EHLO
	mail.karo-electronics.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751880AbaKQJvl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Nov 2014 04:51:41 -0500
In-Reply-To: <1416217884-20911-1-git-send-email-LW@KARO-electronics.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Lothar Wa=C3=9Fmann <LW@KARO-electronics.de>
---
 drivers/net/ethernet/freescale/fec.h      |    1 +
 drivers/net/ethernet/freescale/fec_main.c |  106 +++++++++++----------=
--------
 2 files changed, 39 insertions(+), 68 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec.h b/drivers/net/etherne=
t/freescale/fec.h
index 1418813..7aa9388 100644
--- a/drivers/net/ethernet/freescale/fec.h
+++ b/drivers/net/ethernet/freescale/fec.h
@@ -504,6 +504,7 @@ struct fec_enet_private {
 	int	irq[FEC_IRQ_NUM];
 	bool	bufdesc_ex;
 	int	pause_flag;
+	u32	quirks;
=20
 	struct	napi_struct napi;
 	int	csum_flags;
diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/et=
hernet/freescale/fec_main.c
index f3a6379..3884dd9 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -361,8 +361,6 @@ fec_enet_txq_submit_frag_skb(struct fec_enet_priv_t=
x_q *txq,
 			     struct net_device *ndev)
 {
 	struct fec_enet_private *fep =3D netdev_priv(ndev);
-	const struct platform_device_id *id_entry =3D
-				platform_get_device_id(fep->pdev);
 	struct bufdesc *bdp =3D txq->cur_tx;
 	struct bufdesc_ex *ebdp;
 	int nr_frags =3D skb_shinfo(skb)->nr_frags;
@@ -398,7 +396,7 @@ fec_enet_txq_submit_frag_skb(struct fec_enet_priv_t=
x_q *txq,
 		}
=20
 		if (fep->bufdesc_ex) {
-			if (id_entry->driver_data & FEC_QUIRK_HAS_AVB)
+			if (fep->quirks & FEC_QUIRK_HAS_AVB)
 				estatus |=3D FEC_TX_BD_FTYPE(queue);
 			if (skb->ip_summed =3D=3D CHECKSUM_PARTIAL)
 				estatus |=3D BD_ENET_TX_PINS | BD_ENET_TX_IINS;
@@ -410,11 +408,11 @@ fec_enet_txq_submit_frag_skb(struct fec_enet_priv=
_tx_q *txq,
=20
 		index =3D fec_enet_get_bd_index(txq->tx_bd_base, bdp, fep);
 		if (((unsigned long) bufaddr) & fep->tx_align ||
-			id_entry->driver_data & FEC_QUIRK_SWAP_FRAME) {
+			fep->quirks & FEC_QUIRK_SWAP_FRAME) {
 			memcpy(txq->tx_bounce[index], bufaddr, frag_len);
 			bufaddr =3D txq->tx_bounce[index];
=20
-			if (id_entry->driver_data & FEC_QUIRK_SWAP_FRAME)
+			if (fep->quirks & FEC_QUIRK_SWAP_FRAME)
 				swap_buffer(bufaddr, frag_len);
 		}
=20
@@ -450,8 +448,6 @@ static int fec_enet_txq_submit_skb(struct fec_enet_=
priv_tx_q *txq,
 				   struct sk_buff *skb, struct net_device *ndev)
 {
 	struct fec_enet_private *fep =3D netdev_priv(ndev);
-	const struct platform_device_id *id_entry =3D
-				platform_get_device_id(fep->pdev);
 	int nr_frags =3D skb_shinfo(skb)->nr_frags;
 	struct bufdesc *bdp, *last_bdp;
 	void *bufaddr;
@@ -490,11 +486,11 @@ static int fec_enet_txq_submit_skb(struct fec_ene=
t_priv_tx_q *txq,
 	queue =3D skb_get_queue_mapping(skb);
 	index =3D fec_enet_get_bd_index(txq->tx_bd_base, bdp, fep);
 	if (((unsigned long) bufaddr) & fep->tx_align ||
-		id_entry->driver_data & FEC_QUIRK_SWAP_FRAME) {
+		fep->quirks & FEC_QUIRK_SWAP_FRAME) {
 		memcpy(txq->tx_bounce[index], skb->data, buflen);
 		bufaddr =3D txq->tx_bounce[index];
=20
-		if (id_entry->driver_data & FEC_QUIRK_SWAP_FRAME)
+		if (fep->quirks & FEC_QUIRK_SWAP_FRAME)
 			swap_buffer(bufaddr, buflen);
 	}
=20
@@ -529,7 +525,7 @@ static int fec_enet_txq_submit_skb(struct fec_enet_=
priv_tx_q *txq,
 			fep->hwts_tx_en))
 			skb_shinfo(skb)->tx_flags |=3D SKBTX_IN_PROGRESS;
=20
-		if (id_entry->driver_data & FEC_QUIRK_HAS_AVB)
+		if (fep->quirks & FEC_QUIRK_HAS_AVB)
 			estatus |=3D FEC_TX_BD_FTYPE(queue);
=20
 		if (skb->ip_summed =3D=3D CHECKSUM_PARTIAL)
@@ -573,8 +569,6 @@ fec_enet_txq_put_data_tso(struct fec_enet_priv_tx_q=
 *txq, struct sk_buff *skb,
 			  int size, bool last_tcp, bool is_last)
 {
 	struct fec_enet_private *fep =3D netdev_priv(ndev);
-	const struct platform_device_id *id_entry =3D
-				platform_get_device_id(fep->pdev);
 	struct bufdesc_ex *ebdp =3D container_of(bdp, struct bufdesc_ex, desc=
);
 	unsigned short queue =3D skb_get_queue_mapping(skb);
 	unsigned short status;
@@ -587,11 +581,11 @@ fec_enet_txq_put_data_tso(struct fec_enet_priv_tx=
_q *txq, struct sk_buff *skb,
 	status |=3D (BD_ENET_TX_TC | BD_ENET_TX_READY);
=20
 	if (((unsigned long) data) & fep->tx_align ||
-		id_entry->driver_data & FEC_QUIRK_SWAP_FRAME) {
+		fep->quirks & FEC_QUIRK_SWAP_FRAME) {
 		memcpy(txq->tx_bounce[index], data, size);
 		data =3D txq->tx_bounce[index];
=20
-		if (id_entry->driver_data & FEC_QUIRK_SWAP_FRAME)
+		if (fep->quirks & FEC_QUIRK_SWAP_FRAME)
 			swap_buffer(data, size);
 	}
=20
@@ -607,7 +601,7 @@ fec_enet_txq_put_data_tso(struct fec_enet_priv_tx_q=
 *txq, struct sk_buff *skb,
 	bdp->cbd_bufaddr =3D addr;
=20
 	if (fep->bufdesc_ex) {
-		if (id_entry->driver_data & FEC_QUIRK_HAS_AVB)
+		if (fep->quirks & FEC_QUIRK_HAS_AVB)
 			estatus |=3D FEC_TX_BD_FTYPE(queue);
 		if (skb->ip_summed =3D=3D CHECKSUM_PARTIAL)
 			estatus |=3D BD_ENET_TX_PINS | BD_ENET_TX_IINS;
@@ -635,8 +629,6 @@ fec_enet_txq_put_hdr_tso(struct fec_enet_priv_tx_q =
*txq,
 			 struct bufdesc *bdp, int index)
 {
 	struct fec_enet_private *fep =3D netdev_priv(ndev);
-	const struct platform_device_id *id_entry =3D
-				platform_get_device_id(fep->pdev);
 	int hdr_len =3D skb_transport_offset(skb) + tcp_hdrlen(skb);
 	struct bufdesc_ex *ebdp =3D container_of(bdp, struct bufdesc_ex, desc=
);
 	unsigned short queue =3D skb_get_queue_mapping(skb);
@@ -652,11 +644,11 @@ fec_enet_txq_put_hdr_tso(struct fec_enet_priv_tx_=
q *txq,
 	bufaddr =3D txq->tso_hdrs + index * TSO_HEADER_SIZE;
 	dmabuf =3D txq->tso_hdrs_dma + index * TSO_HEADER_SIZE;
 	if (((unsigned long)bufaddr) & fep->tx_align ||
-		id_entry->driver_data & FEC_QUIRK_SWAP_FRAME) {
+		fep->quirks & FEC_QUIRK_SWAP_FRAME) {
 		memcpy(txq->tx_bounce[index], skb->data, hdr_len);
 		bufaddr =3D txq->tx_bounce[index];
=20
-		if (id_entry->driver_data & FEC_QUIRK_SWAP_FRAME)
+		if (fep->quirks & FEC_QUIRK_SWAP_FRAME)
 			swap_buffer(bufaddr, hdr_len);
=20
 		dmabuf =3D dma_map_single(&fep->pdev->dev, bufaddr,
@@ -673,7 +665,7 @@ fec_enet_txq_put_hdr_tso(struct fec_enet_priv_tx_q =
*txq,
 	bdp->cbd_datlen =3D hdr_len;
=20
 	if (fep->bufdesc_ex) {
-		if (id_entry->driver_data & FEC_QUIRK_HAS_AVB)
+		if (fep->quirks & FEC_QUIRK_HAS_AVB)
 			estatus |=3D FEC_TX_BD_FTYPE(queue);
 		if (skb->ip_summed =3D=3D CHECKSUM_PARTIAL)
 			estatus |=3D BD_ENET_TX_PINS | BD_ENET_TX_IINS;
@@ -698,8 +690,6 @@ static int fec_enet_txq_submit_tso(struct fec_enet_=
priv_tx_q *txq,
 	struct tso_t tso;
 	unsigned int index =3D 0;
 	int ret;
-	const struct platform_device_id *id_entry =3D
-				platform_get_device_id(fep->pdev);
=20
 	if (tso_count_descs(skb) >=3D fec_enet_get_free_txdesc_num(fep, txq))=
 {
 		dev_kfree_skb_any(skb);
@@ -761,7 +751,7 @@ static int fec_enet_txq_submit_tso(struct fec_enet_=
priv_tx_q *txq,
 	txq->cur_tx =3D bdp;
=20
 	/* Trigger transmission start */
-	if (!(id_entry->driver_data & FEC_QUIRK_ERR007885) ||
+	if (!(fep->quirks & FEC_QUIRK_ERR007885) ||
 	    !readl(fep->hwp + FEC_X_DES_ACTIVE(queue)) ||
 	    !readl(fep->hwp + FEC_X_DES_ACTIVE(queue)) ||
 	    !readl(fep->hwp + FEC_X_DES_ACTIVE(queue)) ||
@@ -924,8 +914,6 @@ static void
 fec_restart(struct net_device *ndev)
 {
 	struct fec_enet_private *fep =3D netdev_priv(ndev);
-	const struct platform_device_id *id_entry =3D
-				platform_get_device_id(fep->pdev);
 	u32 val;
 	u32 temp_mac[2];
 	u32 rcntl =3D OPT_FRAME_SIZE | 0x04;
@@ -935,7 +923,7 @@ fec_restart(struct net_device *ndev)
 	 * For i.MX6SX SOC, enet use AXI bus, we use disable MAC
 	 * instead of reset MAC itself.
 	 */
-	if (id_entry && id_entry->driver_data & FEC_QUIRK_HAS_AVB) {
+	if (fep->quirks & FEC_QUIRK_HAS_AVB) {
 		writel(0, fep->hwp + FEC_ECNTRL);
 	} else {
 		writel(1, fep->hwp + FEC_ECNTRL);
@@ -946,7 +934,7 @@ fec_restart(struct net_device *ndev)
 	 * enet-mac reset will reset mac address registers too,
 	 * so need to reconfigure it.
 	 */
-	if (id_entry->driver_data & FEC_QUIRK_ENET_MAC) {
+	if (fep->quirks & FEC_QUIRK_ENET_MAC) {
 		memcpy(&temp_mac, ndev->dev_addr, ETH_ALEN);
 		writel(cpu_to_be32(temp_mac[0]), fep->hwp + FEC_ADDR_LOW);
 		writel(cpu_to_be32(temp_mac[1]), fep->hwp + FEC_ADDR_HIGH);
@@ -992,7 +980,7 @@ fec_restart(struct net_device *ndev)
 	 * The phy interface and speed need to get configured
 	 * differently on enet-mac.
 	 */
-	if (id_entry->driver_data & FEC_QUIRK_ENET_MAC) {
+	if (fep->quirks & FEC_QUIRK_ENET_MAC) {
 		/* Enable flow control and length check */
 		rcntl |=3D 0x40000000 | 0x00000020;
=20
@@ -1015,7 +1003,7 @@ fec_restart(struct net_device *ndev)
 		}
 	} else {
 #ifdef FEC_MIIGSK_ENR
-		if (id_entry->driver_data & FEC_QUIRK_USE_GASKET) {
+		if (fep->quirks & FEC_QUIRK_USE_GASKET) {
 			u32 cfgr;
 			/* disable the gasket and wait */
 			writel(0, fep->hwp + FEC_MIIGSK_ENR);
@@ -1068,7 +1056,7 @@ fec_restart(struct net_device *ndev)
 	writel(0, fep->hwp + FEC_HASH_TABLE_LOW);
 #endif
=20
-	if (id_entry->driver_data & FEC_QUIRK_ENET_MAC) {
+	if (fep->quirks & FEC_QUIRK_ENET_MAC) {
 		/* enable ENET endian swap */
 		ecntl |=3D (1 << 8);
 		/* enable ENET store and forward mode */
@@ -1102,8 +1090,6 @@ static void
 fec_stop(struct net_device *ndev)
 {
 	struct fec_enet_private *fep =3D netdev_priv(ndev);
-	const struct platform_device_id *id_entry =3D
-				platform_get_device_id(fep->pdev);
 	u32 rmii_mode =3D readl(fep->hwp + FEC_R_CNTRL) & (1 << 8);
=20
 	/* We cannot expect a graceful transmit stop without link !!! */
@@ -1118,7 +1104,7 @@ fec_stop(struct net_device *ndev)
 	 * For i.MX6SX SOC, enet use AXI bus, we use disable MAC
 	 * instead of reset MAC itself.
 	 */
-	if (id_entry && id_entry->driver_data & FEC_QUIRK_HAS_AVB) {
+	if (fep->quirks & FEC_QUIRK_HAS_AVB) {
 		writel(0, fep->hwp + FEC_ECNTRL);
 	} else {
 		writel(1, fep->hwp + FEC_ECNTRL);
@@ -1128,7 +1114,7 @@ fec_stop(struct net_device *ndev)
 	writel(FEC_DEFAULT_IMASK, fep->hwp + FEC_IMASK);
=20
 	/* We have to keep ENET enabled to have MII interrupt stay working */
-	if (id_entry->driver_data & FEC_QUIRK_ENET_MAC) {
+	if (fep->quirks & FEC_QUIRK_ENET_MAC) {
 		writel(2, fep->hwp + FEC_ECNTRL);
 		writel(rmii_mode, fep->hwp + FEC_R_CNTRL);
 	}
@@ -1350,8 +1336,6 @@ static int
 fec_enet_rx_queue(struct net_device *ndev, int budget, u16 queue_id)
 {
 	struct fec_enet_private *fep =3D netdev_priv(ndev);
-	const struct platform_device_id *id_entry =3D
-				platform_get_device_id(fep->pdev);
 	struct fec_enet_priv_rx_q *rxq;
 	struct bufdesc *bdp;
 	unsigned short status;
@@ -1365,7 +1349,7 @@ fec_enet_rx_queue(struct net_device *ndev, int bu=
dget, u16 queue_id)
 	u16	vlan_tag;
 	int	index =3D 0;
 	bool	is_copybreak;
-	bool	need_swap =3D id_entry->driver_data & FEC_QUIRK_SWAP_FRAME;
+	bool	need_swap =3D fep->quirks & FEC_QUIRK_SWAP_FRAME;
=20
 #ifdef CONFIG_M532x
 	flush_cache_all();
@@ -1880,8 +1864,6 @@ failed_clk_ipg:
 static int fec_enet_mii_probe(struct net_device *ndev)
 {
 	struct fec_enet_private *fep =3D netdev_priv(ndev);
-	const struct platform_device_id *id_entry =3D
-				platform_get_device_id(fep->pdev);
 	struct phy_device *phy_dev =3D NULL;
 	char mdio_bus_id[MII_BUS_ID_SIZE];
 	char phy_name[MII_BUS_ID_SIZE + 3];
@@ -1927,7 +1909,7 @@ static int fec_enet_mii_probe(struct net_device *=
ndev)
 	}
=20
 	/* mask with MAC supported features */
-	if (id_entry->driver_data & FEC_QUIRK_HAS_GBIT) {
+	if (fep->quirks & FEC_QUIRK_HAS_GBIT) {
 		phy_dev->supported &=3D PHY_GBIT_FEATURES;
 		phy_dev->supported &=3D ~SUPPORTED_1000baseT_Half;
 #if !defined(CONFIG_M5272)
@@ -1955,8 +1937,6 @@ static int fec_enet_mii_init(struct platform_devi=
ce *pdev)
 	static struct mii_bus *fec0_mii_bus;
 	struct net_device *ndev =3D platform_get_drvdata(pdev);
 	struct fec_enet_private *fep =3D netdev_priv(ndev);
-	const struct platform_device_id *id_entry =3D
-				platform_get_device_id(fep->pdev);
 	struct device_node *node;
 	int err =3D -ENXIO, i;
=20
@@ -1976,7 +1956,7 @@ static int fec_enet_mii_init(struct platform_devi=
ce *pdev)
 	 * mdio interface in board design, and need to be configured by
 	 * fec0 mii_bus.
 	 */
-	if ((id_entry->driver_data & FEC_QUIRK_ENET_MAC) && fep->dev_id > 0) =
{
+	if ((fep->quirks & FEC_QUIRK_ENET_MAC) && fep->dev_id > 0) {
 		/* fec1 uses fec0 mii_bus */
 		if (mii_cnt && fec0_mii_bus) {
 			fep->mii_bus =3D fec0_mii_bus;
@@ -1997,7 +1977,7 @@ static int fec_enet_mii_init(struct platform_devi=
ce *pdev)
 	 * document.
 	 */
 	fep->phy_speed =3D DIV_ROUND_UP(clk_get_rate(fep->clk_ipg), 5000000);
-	if (id_entry->driver_data & FEC_QUIRK_ENET_MAC)
+	if (fep->quirks & FEC_QUIRK_ENET_MAC)
 		fep->phy_speed--;
 	fep->phy_speed <<=3D 1;
 	writel(fep->phy_speed, fep->hwp + FEC_MII_SPEED);
@@ -2039,7 +2019,7 @@ static int fec_enet_mii_init(struct platform_devi=
ce *pdev)
 	mii_cnt++;
=20
 	/* save fec0 mii_bus */
-	if (id_entry->driver_data & FEC_QUIRK_ENET_MAC)
+	if (fep->quirks & FEC_QUIRK_ENET_MAC)
 		fec0_mii_bus =3D fep->mii_bus;
=20
 	return 0;
@@ -2308,11 +2288,9 @@ static int fec_enet_us_to_itr_clock(struct net_d=
evice *ndev, int us)
 static void fec_enet_itr_coal_set(struct net_device *ndev)
 {
 	struct fec_enet_private *fep =3D netdev_priv(ndev);
-	const struct platform_device_id *id_entry =3D
-				platform_get_device_id(fep->pdev);
 	int rx_itr, tx_itr;
=20
-	if (!(id_entry->driver_data & FEC_QUIRK_HAS_AVB))
+	if (!(fep->quirks & FEC_QUIRK_HAS_AVB))
 		return;
=20
 	/* Must be greater than zero to avoid unpredictable behavior */
@@ -2347,10 +2325,8 @@ static int
 fec_enet_get_coalesce(struct net_device *ndev, struct ethtool_coalesce=
 *ec)
 {
 	struct fec_enet_private *fep =3D netdev_priv(ndev);
-	const struct platform_device_id *id_entry =3D
-				platform_get_device_id(fep->pdev);
=20
-	if (!(id_entry->driver_data & FEC_QUIRK_HAS_AVB))
+	if (!(fep->quirks & FEC_QUIRK_HAS_AVB))
 		return -EOPNOTSUPP;
=20
 	ec->rx_coalesce_usecs =3D fep->rx_time_itr;
@@ -2366,12 +2342,9 @@ static int
 fec_enet_set_coalesce(struct net_device *ndev, struct ethtool_coalesce=
 *ec)
 {
 	struct fec_enet_private *fep =3D netdev_priv(ndev);
-	const struct platform_device_id *id_entry =3D
-				platform_get_device_id(fep->pdev);
-
 	unsigned int cycle;
=20
-	if (!(id_entry->driver_data & FEC_QUIRK_HAS_AVB))
+	if (!(fep->quirks & FEC_QUIRK_HAS_AVB))
 		return -EOPNOTSUPP;
=20
 	if (ec->rx_max_coalesced_frames > 255) {
@@ -2951,8 +2924,6 @@ static const struct net_device_ops fec_netdev_ops=
 =3D {
 static int fec_enet_init(struct net_device *ndev)
 {
 	struct fec_enet_private *fep =3D netdev_priv(ndev);
-	const struct platform_device_id *id_entry =3D
-				platform_get_device_id(fep->pdev);
 	struct fec_enet_priv_tx_q *txq;
 	struct fec_enet_priv_rx_q *rxq;
 	struct bufdesc *cbd_base;
@@ -3031,11 +3002,11 @@ static int fec_enet_init(struct net_device *nde=
v)
 	writel(FEC_RX_DISABLED_IMASK, fep->hwp + FEC_IMASK);
 	netif_napi_add(ndev, &fep->napi, fec_enet_rx_napi, NAPI_POLL_WEIGHT);
=20
-	if (id_entry->driver_data & FEC_QUIRK_HAS_VLAN)
+	if (fep->quirks & FEC_QUIRK_HAS_VLAN)
 		/* enable hw VLAN support */
 		ndev->features |=3D NETIF_F_HW_VLAN_CTAG_RX;
=20
-	if (id_entry->driver_data & FEC_QUIRK_HAS_CSUM) {
+	if (fep->quirks & FEC_QUIRK_HAS_CSUM) {
 		ndev->gso_max_segs =3D FEC_MAX_TSO_SEGS;
=20
 		/* enable hw accelerator */
@@ -3044,7 +3015,7 @@ static int fec_enet_init(struct net_device *ndev)
 		fep->csum_flags |=3D FLAG_RX_CSUM_ENABLED;
 	}
=20
-	if (id_entry->driver_data & FEC_QUIRK_HAS_AVB) {
+	if (fep->quirks & FEC_QUIRK_HAS_AVB) {
 		fep->tx_align =3D 0;
 		fep->rx_align =3D 0x3f;
 	}
@@ -3144,10 +3115,6 @@ fec_probe(struct platform_device *pdev)
 	int num_tx_qs;
 	int num_rx_qs;
=20
-	of_id =3D of_match_device(fec_dt_ids, &pdev->dev);
-	if (of_id)
-		pdev->id_entry =3D of_id->data;
-
 	fec_enet_get_queue_num(pdev, &num_tx_qs, &num_rx_qs);
=20
 	/* Init network device */
@@ -3161,13 +3128,17 @@ fec_probe(struct platform_device *pdev)
 	/* setup board info structure */
 	fep =3D netdev_priv(ndev);
=20
+	of_id =3D of_match_device(fec_dt_ids, &pdev->dev);
+	if (of_id)
+		pdev->id_entry =3D of_id->data;
+	fep->quirks =3D pdev->id_entry->driver_data;
+
 	fep->num_rx_queues =3D num_rx_qs;
 	fep->num_tx_queues =3D num_tx_qs;
=20
 #if !defined(CONFIG_M5272)
 	/* default enable pause frame auto negotiation */
-	if (pdev->id_entry &&
-	    (pdev->id_entry->driver_data & FEC_QUIRK_HAS_GBIT))
+	if (fep->quirks & FEC_QUIRK_HAS_GBIT)
 		fep->pause_flag |=3D FEC_PAUSE_FLAG_AUTONEG;
 #endif
=20
@@ -3236,9 +3207,8 @@ fec_probe(struct platform_device *pdev)
 	if (IS_ERR(fep->clk_ref))
 		fep->clk_ref =3D NULL;
=20
+	fep->bufdesc_ex =3D fep->quirks & FEC_QUIRK_HAS_BUFDESC_EX;
 	fep->clk_ptp =3D devm_clk_get(&pdev->dev, "ptp");
-	fep->bufdesc_ex =3D
-		pdev->id_entry->driver_data & FEC_QUIRK_HAS_BUFDESC_EX;
 	if (IS_ERR(fep->clk_ptp)) {
 		fep->clk_ptp =3D NULL;
 		fep->bufdesc_ex =3D false;
--=20
1.7.10.4
