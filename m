From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH net-next 8/12]bnx2x: Enhanced self test
Date: Tue, 27 May 2008 10:17:36 -0400
Message-ID: <1211897857.6967.81.camel@ubuntu804desktop.localdomain>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Eliezer Tamir" <eliezert@broadcom.com>,
	"Yitchak Gertner" <gertner@broadcom.com>
To: netdev <netdev@vger.kernel.org>, jeff@garzik.org,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1084 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756196AbYE0ORw convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 May 2008 10:17:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

bnx2x: Enhanced self test
=EF=BB=BF
=EF=BB=BF=EF=BB=BF=EF=BB=BF=EF=BB=BF=EF=BB=BFSigned-off-by: Yitchak Ger=
tner <gertner@broadcom.com>
Signed-off-by: Eliezer Tamir <eliezert@broadcom.com>
Signed-off-by: Eilong Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_main.c |  508 ++++++++++++++++++++++++++++++++++++++=
+++++++-
 1 files changed, 498 insertions(+), 10 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index b92cef1..5e824a3 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -8124,10 +8124,17 @@ static int bnx2x_set_tso(struct net_device *dev=
, u32 data)
 	return 0;
 }
=20
-static struct {
+static const struct {
 	char string[ETH_GSTRING_LEN];
 } bnx2x_tests_str_arr[BNX2X_NUM_TESTS] =3D {
-	{ "MC Errors  (online)" }
+	{ "register_test (offline)" },
+	{ "memory_test (offline)" },
+	{ "loopback_test (offline)" },
+	{ "nvram_test (online)" },
+	{ "interrupt_test (online)" },
+	{ "link_test (online)" },
+	{ "idle check (online)" },
+	{ "MC errors (online)" }
 };
=20
 static int bnx2x_self_test_count(struct net_device *dev)
@@ -8135,25 +8142,507 @@ static int bnx2x_self_test_count(struct net_de=
vice *dev)
 	return BNX2X_NUM_TESTS;
 }
=20
+static int bnx2x_test_registers(struct bnx2x *bp)
+{
+	int idx, i, rc =3D -ENODEV;
+	u32 wr_val =3D 0;
+	static const struct {
+		u32  offset0;
+		u32  offset1;
+		u32  mask;
+	} reg_tbl[] =3D {
+/* 0 */		{ BRB1_REG_PAUSE_LOW_THRESHOLD_0,      4, 0x000003ff },
+		{ DORQ_REG_DB_ADDR0,                   4, 0xffffffff },
+		{ HC_REG_AGG_INT_0,                    4, 0x000003ff },
+		{ PBF_REG_MAC_IF0_ENABLE,              4, 0x00000001 },
+		{ PBF_REG_P0_INIT_CRD,                 4, 0x000007ff },
+		{ PRS_REG_CID_PORT_0,                  4, 0x00ffffff },
+		{ PXP2_REG_PSWRQ_CDU0_L2P,             4, 0x000fffff },
+		{ PXP2_REG_RQ_CDU0_EFIRST_MEM_ADDR,    8, 0x0003ffff },
+		{ PXP2_REG_PSWRQ_TM0_L2P,              4, 0x000fffff },
+		{ PXP2_REG_RQ_USDM0_EFIRST_MEM_ADDR,   8, 0x0003ffff },
+/* 10 */	{ PXP2_REG_PSWRQ_TSDM0_L2P,            4, 0x000fffff },
+		{ QM_REG_CONNNUM_0,                    4, 0x000fffff },
+		{ TM_REG_LIN0_MAX_ACTIVE_CID,          4, 0x0003ffff },
+		{ SRC_REG_KEYRSS0_0,                  40, 0xffffffff },
+		{ SRC_REG_KEYRSS0_7,                  40, 0xffffffff },
+		{ XCM_REG_WU_DA_SET_TMR_CNT_FLG_CMD00, 4, 0x00000001 },
+		{ XCM_REG_WU_DA_CNT_CMD00,             4, 0x00000003 },
+		{ XCM_REG_GLB_DEL_ACK_MAX_CNT_0,       4, 0x000000ff },
+		{ NIG_REG_EGRESS_MNG0_FIFO,           20, 0xffffffff },
+		{ NIG_REG_LLH0_T_BIT,                  4, 0x00000001 },
+/* 20 */	{ NIG_REG_EMAC0_IN_EN,                 4, 0x00000001 },
+		{ NIG_REG_BMAC0_IN_EN,                 4, 0x00000001 },
+		{ NIG_REG_XCM0_OUT_EN,                 4, 0x00000001 },
+		{ NIG_REG_BRB0_OUT_EN,                 4, 0x00000001 },
+		{ NIG_REG_LLH0_XCM_MASK,               4, 0x00000007 },
+		{ NIG_REG_LLH0_ACPI_PAT_6_LEN,        68, 0x000000ff },
+		{ NIG_REG_LLH0_ACPI_PAT_0_CRC,        68, 0xffffffff },
+		{ NIG_REG_LLH0_DEST_MAC_0_0,         160, 0xffffffff },
+		{ NIG_REG_LLH0_DEST_IP_0_1,          160, 0xffffffff },
+		{ NIG_REG_LLH0_IPV4_IPV6_0,          160, 0x00000001 },
+/* 30 */	{ NIG_REG_LLH0_DEST_UDP_0,           160, 0x0000ffff },
+		{ NIG_REG_LLH0_DEST_TCP_0,           160, 0x0000ffff },
+		{ NIG_REG_LLH0_VLAN_ID_0,            160, 0x00000fff },
+		{ NIG_REG_XGXS_SERDES0_MODE_SEL,       4, 0x00000001 },
+		{ NIG_REG_LED_CONTROL_OVERRIDE_TRAFFIC_P0, 4, 0x00000001 },
+		{ NIG_REG_STATUS_INTERRUPT_PORT0,      4, 0x07ffffff },
+		{ NIG_REG_XGXS0_CTRL_EXTREMOTEMDIOST, 24, 0x00000001 },
+		{ NIG_REG_SERDES0_CTRL_PHY_ADDR,      16, 0x0000001f },
+
+		{ 0xffffffff, 0, 0x00000000 }
+	};
+
+	if (!netif_running(bp->dev))
+		return rc;
+
+	/* Repeat the test twice:
+	   First by writing 0x00000000, second by writing 0xffffffff */
+	for (idx =3D 0; idx < 2; idx++) {
+
+		switch (idx) {
+		case 0:
+			wr_val =3D 0;
+			break;
+		case 1:
+			wr_val =3D 0xffffffff;
+			break;
+		}
+
+		for (i =3D 0; reg_tbl[i].offset0 !=3D 0xffffffff; i++) {
+			u32 offset, mask, save_val, val;
+			int port =3D BP_PORT(bp);
+
+			offset =3D reg_tbl[i].offset0 + port*reg_tbl[i].offset1;
+			mask =3D reg_tbl[i].mask;
+
+			save_val =3D REG_RD(bp, offset);
+
+			REG_WR(bp, offset, wr_val);
+			val =3D REG_RD(bp, offset);
+
+			/* Restore the original register's value */
+			REG_WR(bp, offset, save_val);
+
+			/* verify that value is as expected value */
+			if ((val & mask) !=3D (wr_val & mask))
+				goto test_reg_exit;
+		}
+	}
+
+	rc =3D 0;
+
+test_reg_exit:
+	return rc;
+}
+
+static int bnx2x_test_memory(struct bnx2x *bp)
+{
+	int i, j, rc =3D -ENODEV;
+	u32 val;
+	static const struct {
+		u32 offset;
+		int size;
+	} mem_tbl[] =3D {
+		{ CCM_REG_XX_DESCR_TABLE,   CCM_REG_XX_DESCR_TABLE_SIZE },
+		{ CFC_REG_ACTIVITY_COUNTER, CFC_REG_ACTIVITY_COUNTER_SIZE },
+		{ CFC_REG_LINK_LIST,        CFC_REG_LINK_LIST_SIZE },
+		{ CSEM_REG_INT_TABLE,       CSEM_REG_INT_TABLE_SIZE },
+		{ TCM_REG_XX_DESCR_TABLE,   TCM_REG_XX_DESCR_TABLE_SIZE },
+		{ TSEM_REG_INT_TABLE,       TSEM_REG_INT_TABLE_SIZE },
+		{ UCM_REG_XX_DESCR_TABLE,   UCM_REG_XX_DESCR_TABLE_SIZE },
+		{ USEM_REG_INT_TABLE,       USEM_REG_INT_TABLE_SIZE },
+		{ XCM_REG_XX_DESCR_TABLE,   XCM_REG_XX_DESCR_TABLE_SIZE },
+		{ XSEM_REG_INT_TABLE,       XSEM_REG_INT_TABLE_SIZE },
+
+		{ 0xffffffff, 0 }
+	};
+	static const struct {
+		char *name;
+		u32 offset;
+		u32 mask;
+	} prty_tbl[] =3D {
+		{ "CCM_REG_CCM_PRTY_STS",     CCM_REG_CCM_PRTY_STS,     0 },
+		{ "CFC_REG_CFC_PRTY_STS",     CFC_REG_CFC_PRTY_STS,     0 },
+		{ "CSEM_REG_CSEM_PRTY_STS_0", CSEM_REG_CSEM_PRTY_STS_0, 0 },
+		{ "CSEM_REG_CSEM_PRTY_STS_1", CSEM_REG_CSEM_PRTY_STS_1, 0 },
+		{ "TCM_REG_TCM_PRTY_STS",     TCM_REG_TCM_PRTY_STS,     0 },
+		{ "TSEM_REG_TSEM_PRTY_STS_0", TSEM_REG_TSEM_PRTY_STS_0, 0 },
+		{ "TSEM_REG_TSEM_PRTY_STS_1", TSEM_REG_TSEM_PRTY_STS_1, 0 },
+		{ "UCM_REG_UCM_PRTY_STS",     UCM_REG_UCM_PRTY_STS,     0 },
+		{ "USEM_REG_USEM_PRTY_STS_0", USEM_REG_USEM_PRTY_STS_0,
+							       0xc0000000 },
+		{ "USEM_REG_USEM_PRTY_STS_1", USEM_REG_USEM_PRTY_STS_1, 0 },
+		{ "XCM_REG_XCM_PRTY_STS",     XCM_REG_XCM_PRTY_STS,     0x1 },
+		{ "XSEM_REG_XSEM_PRTY_STS_0", XSEM_REG_XSEM_PRTY_STS_0, 0 },
+		{ "XSEM_REG_XSEM_PRTY_STS_1", XSEM_REG_XSEM_PRTY_STS_1, 0 },
+
+		{ NULL, 0xffffffff, 0 }
+	};
+
+	if (!netif_running(bp->dev))
+		return rc;
+
+	/* Go through all the memories */
+	for (i =3D 0; mem_tbl[i].offset !=3D 0xffffffff; i++)
+		for (j =3D 0; j < mem_tbl[i].size; j++)
+			REG_RD(bp, mem_tbl[i].offset + j*4);
+
+	/* Check the parity status */
+	for (i =3D 0; prty_tbl[i].offset !=3D 0xffffffff; i++) {
+		val =3D REG_RD(bp, prty_tbl[i].offset);
+		if (val & ~(prty_tbl[i].mask)) {
+			DP(NETIF_MSG_HW,
+			   "%s is 0x%x\n", prty_tbl[i].name, val);
+			goto test_mem_exit;
+		}
+	}
+
+	rc =3D 0;
+
+test_mem_exit:
+	return rc;
+}
+
+static void bnx2x_netif_start(struct bnx2x *bp)
+{
+	int i;
+
+	if (atomic_dec_and_test(&bp->intr_sem)) {
+		if (netif_running(bp->dev)) {
+			bnx2x_int_enable(bp);
+			for_each_queue(bp, i)
+				napi_enable(&bnx2x_fp(bp, i, napi));
+			if (bp->state =3D=3D BNX2X_STATE_OPEN)
+				netif_wake_queue(bp->dev);
+		}
+	}
+}
+
+static void bnx2x_netif_stop(struct bnx2x *bp)
+{
+	int i;
+
+	if (netif_running(bp->dev)) {
+		netif_tx_disable(bp->dev);
+		bp->dev->trans_start =3D jiffies;	/* prevent tx timeout */
+		for_each_queue(bp, i)
+			napi_disable(&bnx2x_fp(bp, i, napi));
+	}
+	bnx2x_int_disable_sync(bp);
+}
+
+static void bnx2x_wait_for_link(struct bnx2x *bp, u8 link_up)
+{
+	int cnt =3D 1000;
+
+	if (link_up)
+		while (bnx2x_link_test(bp) && cnt--)
+			msleep(10);
+}
+
+static int bnx2x_run_loopback(struct bnx2x *bp, int loopback_mode, u8 =
link_up)
+{
+	unsigned int pkt_size, num_pkts, i;
+	struct sk_buff *skb;
+	unsigned char *packet;
+	struct bnx2x_fastpath *fp =3D &bp->fp[0];
+	u16 tx_start_idx, tx_idx;
+	u16 rx_start_idx, rx_idx;
+	u16 pkt_prod;
+	struct sw_tx_bd *tx_buf;
+	struct eth_tx_bd *tx_bd;
+	dma_addr_t mapping;
+	union eth_rx_cqe *cqe;
+	u8 cqe_fp_flags;
+	struct sw_rx_bd *rx_buf;
+	u16 len;
+	int rc =3D -ENODEV;
+
+	if (loopback_mode =3D=3D BNX2X_MAC_LOOPBACK) {
+		bp->link_params.loopback_mode =3D LOOPBACK_BMAC;
+		bnx2x_phy_hw_lock(bp);
+		bnx2x_phy_init(&bp->link_params, &bp->link_vars);
+		bnx2x_phy_hw_unlock(bp);
+
+	} else if (loopback_mode =3D=3D BNX2X_PHY_LOOPBACK) {
+		bp->link_params.loopback_mode =3D LOOPBACK_XGXS_10;
+		bnx2x_phy_hw_lock(bp);
+		bnx2x_phy_init(&bp->link_params, &bp->link_vars);
+		bnx2x_phy_hw_unlock(bp);
+		/* wait until link state is restored */
+		bnx2x_wait_for_link(bp, link_up);
+
+	} else
+		return -EINVAL;
+
+	pkt_size =3D 1514;
+	skb =3D netdev_alloc_skb(bp->dev, bp->rx_buf_size);
+	if (!skb) {
+		rc =3D -ENOMEM;
+		goto test_loopback_exit;
+	}
+	packet =3D skb_put(skb, pkt_size);
+	memcpy(packet, bp->dev->dev_addr, ETH_ALEN);
+	memset(packet + ETH_ALEN, 0, (ETH_HLEN - ETH_ALEN));
+	for (i =3D ETH_HLEN; i < pkt_size; i++)
+		packet[i] =3D (unsigned char) (i & 0xff);
+
+	num_pkts =3D 0;
+	tx_start_idx =3D le16_to_cpu(*fp->tx_cons_sb);
+	rx_start_idx =3D le16_to_cpu(*fp->rx_cons_sb);
+
+	pkt_prod =3D fp->tx_pkt_prod++;
+	tx_buf =3D &fp->tx_buf_ring[TX_BD(pkt_prod)];
+	tx_buf->first_bd =3D fp->tx_bd_prod;
+	tx_buf->skb =3D skb;
+
+	tx_bd =3D &fp->tx_desc_ring[TX_BD(fp->tx_bd_prod)];
+	mapping =3D pci_map_single(bp->pdev, skb->data,
+				 skb_headlen(skb), PCI_DMA_TODEVICE);
+	tx_bd->addr_hi =3D cpu_to_le32(U64_HI(mapping));
+	tx_bd->addr_lo =3D cpu_to_le32(U64_LO(mapping));
+	tx_bd->nbd =3D cpu_to_le16(1);
+	tx_bd->nbytes =3D cpu_to_le16(skb_headlen(skb));
+	tx_bd->vlan =3D cpu_to_le16(pkt_prod);
+	tx_bd->bd_flags.as_bitfield =3D (ETH_TX_BD_FLAGS_START_BD |
+				       ETH_TX_BD_FLAGS_END_BD);
+	tx_bd->general_data =3D ((UNICAST_ADDRESS <<
+				ETH_TX_BD_ETH_ADDR_TYPE_SHIFT) | 1);
+
+	fp->hw_tx_prods->bds_prod =3D
+		cpu_to_le16(le16_to_cpu(fp->hw_tx_prods->bds_prod) + 1);
+	mb(); /* FW restriction: must not reorder writing nbd and packets */
+	fp->hw_tx_prods->packets_prod =3D
+		cpu_to_le32(le32_to_cpu(fp->hw_tx_prods->packets_prod) + 1);
+	DOORBELL(bp, FP_IDX(fp), 0);
+
+	mmiowb();
+
+	num_pkts++;
+	fp->tx_bd_prod++;
+	bp->dev->trans_start =3D jiffies;
+
+	udelay(100);
+
+	tx_idx =3D le16_to_cpu(*fp->tx_cons_sb);
+	if (tx_idx !=3D tx_start_idx + num_pkts)
+		goto test_loopback_exit;
+
+	rx_idx =3D le16_to_cpu(*fp->rx_cons_sb);
+	if (rx_idx !=3D rx_start_idx + num_pkts)
+		goto test_loopback_exit;
+
+	cqe =3D &fp->rx_comp_ring[RCQ_BD(fp->rx_comp_cons)];
+	cqe_fp_flags =3D cqe->fast_path_cqe.type_error_flags;
+	if (CQE_TYPE(cqe_fp_flags) || (cqe_fp_flags & ETH_RX_ERROR_FALGS))
+		goto test_loopback_rx_exit;
+
+	len =3D le16_to_cpu(cqe->fast_path_cqe.pkt_len);
+	if (len !=3D pkt_size)
+		goto test_loopback_rx_exit;
+
+	rx_buf =3D &fp->rx_buf_ring[RX_BD(fp->rx_bd_cons)];
+	skb =3D rx_buf->skb;
+	skb_reserve(skb, cqe->fast_path_cqe.placement_offset);
+	for (i =3D ETH_HLEN; i < pkt_size; i++)
+		if (*(skb->data + i) !=3D (unsigned char) (i & 0xff))
+			goto test_loopback_rx_exit;
+
+	rc =3D 0;
+
+test_loopback_rx_exit:
+	bp->dev->last_rx =3D jiffies;
+
+	fp->rx_bd_cons =3D NEXT_RX_IDX(fp->rx_bd_cons);
+	fp->rx_bd_prod =3D NEXT_RX_IDX(fp->rx_bd_prod);
+	fp->rx_comp_cons =3D NEXT_RCQ_IDX(fp->rx_comp_cons);
+	fp->rx_comp_prod =3D NEXT_RCQ_IDX(fp->rx_comp_prod);
+
+	/* Update producers */
+	bnx2x_update_rx_prod(bp, fp, fp->rx_bd_prod, fp->rx_comp_prod,
+			     fp->rx_sge_prod);
+	mmiowb(); /* keep prod updates ordered */
+
+test_loopback_exit:
+	bp->link_params.loopback_mode =3D LOOPBACK_NONE;
+
+	return rc;
+}
+
+static int bnx2x_test_loopback(struct bnx2x *bp, u8 link_up)
+{
+	int rc =3D 0;
+
+	if (!netif_running(bp->dev))
+		return BNX2X_LOOPBACK_FAILED;
+
+	bnx2x_netif_stop(bp);
+
+	if (bnx2x_run_loopback(bp, BNX2X_MAC_LOOPBACK, link_up)) {
+		DP(NETIF_MSG_PROBE, "MAC loopback failed\n");
+		rc |=3D BNX2X_MAC_LOOPBACK_FAILED;
+	}
+
+	if (bnx2x_run_loopback(bp, BNX2X_PHY_LOOPBACK, link_up)) {
+		DP(NETIF_MSG_PROBE, "PHY loopback failed\n");
+		rc |=3D BNX2X_PHY_LOOPBACK_FAILED;
+	}
+
+	bnx2x_netif_start(bp);
+
+	return rc;
+}
+
+#define CRC32_RESIDUAL			0xdebb20e3
+
+static int bnx2x_test_nvram(struct bnx2x *bp)
+{
+	static const struct {
+		int offset;
+		int size;
+	} nvram_tbl[] =3D {
+		{     0,  0x14 }, /* bootstrap */
+		{  0x14,  0xec }, /* dir */
+		{ 0x100, 0x350 }, /* manuf_info */
+		{ 0x450,  0xf0 }, /* feature_info */
+		{ 0x640,  0x64 }, /* upgrade_key_info */
+		{ 0x6a4,  0x64 },
+		{ 0x708,  0x70 }, /* manuf_key_info */
+		{ 0x778,  0x70 },
+		{     0,     0 }
+	};
+	u32 buf[0x350 / 4];
+	u8 *data =3D (u8 *)buf;
+	int i, rc;
+	u32 magic, csum;
+
+	rc =3D bnx2x_nvram_read(bp, 0, data, 4);
+	if (rc) {
+		DP(NETIF_MSG_PROBE, "magic value read (rc -%d)\n", -rc);
+		goto test_nvram_exit;
+	}
+
+	magic =3D be32_to_cpu(buf[0]);
+	if (magic !=3D 0x669955aa) {
+		DP(NETIF_MSG_PROBE, "magic value (0x%08x)\n", magic);
+		rc =3D -ENODEV;
+		goto test_nvram_exit;
+	}
+
+	for (i =3D 0; nvram_tbl[i].size; i++) {
+
+		rc =3D bnx2x_nvram_read(bp, nvram_tbl[i].offset, data,
+				      nvram_tbl[i].size);
+		if (rc) {
+			DP(NETIF_MSG_PROBE,
+			   "nvram_tbl[%d] read data (rc -%d)\n", i, -rc);
+			goto test_nvram_exit;
+		}
+
+		csum =3D ether_crc_le(nvram_tbl[i].size, data);
+		if (csum !=3D CRC32_RESIDUAL) {
+			DP(NETIF_MSG_PROBE,
+			   "nvram_tbl[%d] csum value (0x%08x)\n", i, csum);
+			rc =3D -ENODEV;
+			goto test_nvram_exit;
+		}
+	}
+
+test_nvram_exit:
+	return rc;
+}
+
+static int bnx2x_test_intr(struct bnx2x *bp)
+{
+	struct mac_configuration_cmd *config =3D bnx2x_sp(bp, mac_config);
+	int i, rc;
+
+	if (!netif_running(bp->dev))
+		return -ENODEV;
+
+	config->hdr.length_6b =3D 0;
+	config->hdr.offset =3D 0;
+	config->hdr.client_id =3D BP_CL_ID(bp);
+	config->hdr.reserved1 =3D 0;
+
+	rc =3D bnx2x_sp_post(bp, RAMROD_CMD_ID_ETH_SET_MAC, 0,
+			   U64_HI(bnx2x_sp_mapping(bp, mac_config)),
+			   U64_LO(bnx2x_sp_mapping(bp, mac_config)), 0);
+	if (rc =3D=3D 0) {
+		bp->set_mac_pending++;
+		for (i =3D 0; i < 10; i++) {
+			if (!bp->set_mac_pending)
+				break;
+			msleep_interruptible(10);
+		}
+		if (i =3D=3D 10)
+			rc =3D -ENODEV;
+	}
+
+	return rc;
+}
+
 static void bnx2x_self_test(struct net_device *dev,
 			    struct ethtool_test *etest, u64 *buf)
 {
 	struct bnx2x *bp =3D netdev_priv(dev);
-	int stats_state;
=20
 	memset(buf, 0, sizeof(u64) * BNX2X_NUM_TESTS);
=20
-	if (bp->state !=3D BNX2X_STATE_OPEN) {
-		DP(NETIF_MSG_PROBE, "state is %x, returning\n", bp->state);
+	if (!netif_running(dev))
 		return;
-	}
=20
-	stats_state =3D bp->stats_state;
+	/* offline tests are not suppoerted in MF mode */
+	if (IS_E1HMF(bp))
+		etest->flags &=3D ~ETH_TEST_FL_OFFLINE;
+
+	if (etest->flags & ETH_TEST_FL_OFFLINE) {
+		u8 link_up;
+
+		link_up =3D bp->link_vars.link_up;
+		bnx2x_nic_unload(bp, UNLOAD_NORMAL);
+		bnx2x_nic_load(bp, LOAD_DIAG);
+		/* wait until link state is restored */
+		bnx2x_wait_for_link(bp, link_up);
+
+		if (bnx2x_test_registers(bp) !=3D 0) {
+			buf[0] =3D 1;
+			etest->flags |=3D ETH_TEST_FL_FAILED;
+		}
+		if (bnx2x_test_memory(bp) !=3D 0) {
+			buf[1] =3D 1;
+			etest->flags |=3D ETH_TEST_FL_FAILED;
+		}
+		buf[2] =3D bnx2x_test_loopback(bp, link_up);
+		if (buf[2] !=3D 0)
+			etest->flags |=3D ETH_TEST_FL_FAILED;
=20
-	if (bnx2x_mc_assert(bp) !=3D 0) {
-		buf[0] =3D 1;
+		bnx2x_nic_unload(bp, UNLOAD_NORMAL);
+		bnx2x_nic_load(bp, LOAD_NORMAL);
+		/* wait until link state is restored */
+		bnx2x_wait_for_link(bp, link_up);
+	}
+	if (bnx2x_test_nvram(bp) !=3D 0) {
+		buf[3] =3D 1;
 		etest->flags |=3D ETH_TEST_FL_FAILED;
 	}
+	if (bnx2x_test_intr(bp) !=3D 0) {
+		buf[4] =3D 1;
+		etest->flags |=3D ETH_TEST_FL_FAILED;
+	}
+	if (bp->port.pmf)
+		if (bnx2x_link_test(bp) !=3D 0) {
+			buf[5] =3D 1;
+			etest->flags |=3D ETH_TEST_FL_FAILED;
+		}
+	buf[7] =3D bnx2x_mc_assert(bp);
+	if (buf[7] !=3D 0)
+		etest->flags |=3D ETH_TEST_FL_FAILED;
+
+#ifdef BNX2X_EXTRA_DEBUG
+	bnx2x_panic_dump(bp);
+#endif
 }
=20
 static const struct {
@@ -8664,7 +9153,6 @@ static int bnx2x_start_xmit(struct sk_buff *skb, =
struct net_device *dev)
 #endif
=20
 	fp_index =3D (smp_processor_id() % bp->num_queues);
-
 	fp =3D &bp->fp[fp_index];
=20
 	if (unlikely(bnx2x_tx_avail(bp->fp) <
--=20
1.5.5




