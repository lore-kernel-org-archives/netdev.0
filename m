From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH net-next 10/12]bnx2x: Enhanced self test
Date: Tue, 17 Jun 2008 11:33:42 +0300
Message-ID: <1213691622.5817.69.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Michael Chan" <mchan@broadcom.com>,
	"Yitchak Gertner" <yitchak.gertner@broadcom.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2732 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754887AbYFQIdx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Jun 2008 04:33:53 -0400
Received: from mail-irva-8.broadcom.com (mail-irva-8 [10.11.18.52]) by
 mail-irva-10.broadcom.com (Postfix) with ESMTP id 4D7202B0 for
 <netdev@vger.kernel.org>; Tue, 17 Jun 2008 01:33:45 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Added registers, memories, loopback, nvram, interrupt and link tests to
the self-test

Signed-off-by: Yitchak Gertner <gertner@broadcom.com>
Signed-off-by: Eliezer Tamir <eliezert@broadcom.com>
Signed-off-by: Eilong Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_main.c |  522 ++++++++++++++++++++++++++++++++++++++++++++--
 1 files changed, 505 insertions(+), 17 deletions(-)
 mode change 100644 => 100755 drivers/net/bnx2x_main.c

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
old mode 100644
new mode 100755
index b92cef1..deb57e2
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -8124,10 +8124,17 @@ static int bnx2x_set_tso(struct net_device *dev, u32 data)
 	return 0;
 }
 
-static struct {
+static const struct {
 	char string[ETH_GSTRING_LEN];
 } bnx2x_tests_str_arr[BNX2X_NUM_TESTS] = {
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
 
 static int bnx2x_self_test_count(struct net_device *dev)
@@ -8135,25 +8142,507 @@ static int bnx2x_self_test_count(struct net_device *dev)
 	return BNX2X_NUM_TESTS;
 }
 
+static int bnx2x_test_registers(struct bnx2x *bp)
+{
+	int idx, i, rc = -ENODEV;
+	u32 wr_val = 0;
+	static const struct {
+		u32  offset0;
+		u32  offset1;
+		u32  mask;
+	} reg_tbl[] = {
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
+	for (idx = 0; idx < 2; idx++) {
+
+		switch (idx) {
+		case 0:
+			wr_val = 0;
+			break;
+		case 1:
+			wr_val = 0xffffffff;
+			break;
+		}
+
+		for (i = 0; reg_tbl[i].offset0 != 0xffffffff; i++) {
+			u32 offset, mask, save_val, val;
+			int port = BP_PORT(bp);
+
+			offset = reg_tbl[i].offset0 + port*reg_tbl[i].offset1;
+			mask = reg_tbl[i].mask;
+
+			save_val = REG_RD(bp, offset);
+
+			REG_WR(bp, offset, wr_val);
+			val = REG_RD(bp, offset);
+
+			/* Restore the original register's value */
+			REG_WR(bp, offset, save_val);
+
+			/* verify that value is as expected value */
+			if ((val & mask) != (wr_val & mask))
+				goto test_reg_exit;
+		}
+	}
+
+	rc = 0;
+
+test_reg_exit:
+	return rc;
+}
+
+static int bnx2x_test_memory(struct bnx2x *bp)
+{
+	int i, j, rc = -ENODEV;
+	u32 val;
+	static const struct {
+		u32 offset;
+		int size;
+	} mem_tbl[] = {
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
+	} prty_tbl[] = {
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
+	for (i = 0; mem_tbl[i].offset != 0xffffffff; i++)
+		for (j = 0; j < mem_tbl[i].size; j++)
+			REG_RD(bp, mem_tbl[i].offset + j*4);
+
+	/* Check the parity status */
+	for (i = 0; prty_tbl[i].offset != 0xffffffff; i++) {
+		val = REG_RD(bp, prty_tbl[i].offset);
+		if (val & ~(prty_tbl[i].mask)) {
+			DP(NETIF_MSG_HW,
+			   "%s is 0x%x\n", prty_tbl[i].name, val);
+			goto test_mem_exit;
+		}
+	}
+
+	rc = 0;
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
+			if (bp->state == BNX2X_STATE_OPEN)
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
+		bp->dev->trans_start = jiffies;	/* prevent tx timeout */
+		for_each_queue(bp, i)
+			napi_disable(&bnx2x_fp(bp, i, napi));
+	}
+	bnx2x_int_disable_sync(bp);
+}
+
+static void bnx2x_wait_for_link(struct bnx2x *bp, u8 link_up)
+{
+	int cnt = 1000;
+
+	if (link_up)
+		while (bnx2x_link_test(bp) && cnt--)
+			msleep(10);
+}
+
+static int bnx2x_run_loopback(struct bnx2x *bp, int loopback_mode, u8 link_up)
+{
+	unsigned int pkt_size, num_pkts, i;
+	struct sk_buff *skb;
+	unsigned char *packet;
+	struct bnx2x_fastpath *fp = &bp->fp[0];
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
+	int rc = -ENODEV;
+
+	if (loopback_mode == BNX2X_MAC_LOOPBACK) {
+		bp->link_params.loopback_mode = LOOPBACK_BMAC;
+		bnx2x_phy_hw_lock(bp);
+		bnx2x_phy_init(&bp->link_params, &bp->link_vars);
+		bnx2x_phy_hw_unlock(bp);
+
+	} else if (loopback_mode == BNX2X_PHY_LOOPBACK) {
+		bp->link_params.loopback_mode = LOOPBACK_XGXS_10;
+		bnx2x_phy_hw_lock(bp);
+		bnx2x_phy_init(&bp->link_params, &bp->link_vars);
+		bnx2x_phy_hw_unlock(bp);
+		/* wait until link state is restored */
+		bnx2x_wait_for_link(bp, link_up);
+
+	} else
+		return -EINVAL;
+
+	pkt_size = 1514;
+	skb = netdev_alloc_skb(bp->dev, bp->rx_buf_size);
+	if (!skb) {
+		rc = -ENOMEM;
+		goto test_loopback_exit;
+	}
+	packet = skb_put(skb, pkt_size);
+	memcpy(packet, bp->dev->dev_addr, ETH_ALEN);
+	memset(packet + ETH_ALEN, 0, (ETH_HLEN - ETH_ALEN));
+	for (i = ETH_HLEN; i < pkt_size; i++)
+		packet[i] = (unsigned char) (i & 0xff);
+
+	num_pkts = 0;
+	tx_start_idx = le16_to_cpu(*fp->tx_cons_sb);
+	rx_start_idx = le16_to_cpu(*fp->rx_cons_sb);
+
+	pkt_prod = fp->tx_pkt_prod++;
+	tx_buf = &fp->tx_buf_ring[TX_BD(pkt_prod)];
+	tx_buf->first_bd = fp->tx_bd_prod;
+	tx_buf->skb = skb;
+
+	tx_bd = &fp->tx_desc_ring[TX_BD(fp->tx_bd_prod)];
+	mapping = pci_map_single(bp->pdev, skb->data,
+				 skb_headlen(skb), PCI_DMA_TODEVICE);
+	tx_bd->addr_hi = cpu_to_le32(U64_HI(mapping));
+	tx_bd->addr_lo = cpu_to_le32(U64_LO(mapping));
+	tx_bd->nbd = cpu_to_le16(1);
+	tx_bd->nbytes = cpu_to_le16(skb_headlen(skb));
+	tx_bd->vlan = cpu_to_le16(pkt_prod);
+	tx_bd->bd_flags.as_bitfield = (ETH_TX_BD_FLAGS_START_BD |
+				       ETH_TX_BD_FLAGS_END_BD);
+	tx_bd->general_data = ((UNICAST_ADDRESS <<
+				ETH_TX_BD_ETH_ADDR_TYPE_SHIFT) | 1);
+
+	fp->hw_tx_prods->bds_prod =
+		cpu_to_le16(le16_to_cpu(fp->hw_tx_prods->bds_prod) + 1);
+	mb(); /* FW restriction: must not reorder writing nbd and packets */
+	fp->hw_tx_prods->packets_prod =
+		cpu_to_le32(le32_to_cpu(fp->hw_tx_prods->packets_prod) + 1);
+	DOORBELL(bp, FP_IDX(fp), 0);
+
+	mmiowb();
+
+	num_pkts++;
+	fp->tx_bd_prod++;
+	bp->dev->trans_start = jiffies;
+
+	udelay(100);
+
+	tx_idx = le16_to_cpu(*fp->tx_cons_sb);
+	if (tx_idx != tx_start_idx + num_pkts)
+		goto test_loopback_exit;
+
+	rx_idx = le16_to_cpu(*fp->rx_cons_sb);
+	if (rx_idx != rx_start_idx + num_pkts)
+		goto test_loopback_exit;
+
+	cqe = &fp->rx_comp_ring[RCQ_BD(fp->rx_comp_cons)];
+	cqe_fp_flags = cqe->fast_path_cqe.type_error_flags;
+	if (CQE_TYPE(cqe_fp_flags) || (cqe_fp_flags & ETH_RX_ERROR_FALGS))
+		goto test_loopback_rx_exit;
+
+	len = le16_to_cpu(cqe->fast_path_cqe.pkt_len);
+	if (len != pkt_size)
+		goto test_loopback_rx_exit;
+
+	rx_buf = &fp->rx_buf_ring[RX_BD(fp->rx_bd_cons)];
+	skb = rx_buf->skb;
+	skb_reserve(skb, cqe->fast_path_cqe.placement_offset);
+	for (i = ETH_HLEN; i < pkt_size; i++)
+		if (*(skb->data + i) != (unsigned char) (i & 0xff))
+			goto test_loopback_rx_exit;
+
+	rc = 0;
+
+test_loopback_rx_exit:
+	bp->dev->last_rx = jiffies;
+
+	fp->rx_bd_cons = NEXT_RX_IDX(fp->rx_bd_cons);
+	fp->rx_bd_prod = NEXT_RX_IDX(fp->rx_bd_prod);
+	fp->rx_comp_cons = NEXT_RCQ_IDX(fp->rx_comp_cons);
+	fp->rx_comp_prod = NEXT_RCQ_IDX(fp->rx_comp_prod);
+
+	/* Update producers */
+	bnx2x_update_rx_prod(bp, fp, fp->rx_bd_prod, fp->rx_comp_prod,
+			     fp->rx_sge_prod);
+	mmiowb(); /* keep prod updates ordered */
+
+test_loopback_exit:
+	bp->link_params.loopback_mode = LOOPBACK_NONE;
+
+	return rc;
+}
+
+static int bnx2x_test_loopback(struct bnx2x *bp, u8 link_up)
+{
+	int rc = 0;
+
+	if (!netif_running(bp->dev))
+		return BNX2X_LOOPBACK_FAILED;
+
+	bnx2x_netif_stop(bp);
+
+	if (bnx2x_run_loopback(bp, BNX2X_MAC_LOOPBACK, link_up)) {
+		DP(NETIF_MSG_PROBE, "MAC loopback failed\n");
+		rc |= BNX2X_MAC_LOOPBACK_FAILED;
+	}
+
+	if (bnx2x_run_loopback(bp, BNX2X_PHY_LOOPBACK, link_up)) {
+		DP(NETIF_MSG_PROBE, "PHY loopback failed\n");
+		rc |= BNX2X_PHY_LOOPBACK_FAILED;
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
+	} nvram_tbl[] = {
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
+	u8 *data = (u8 *)buf;
+	int i, rc;
+	u32 magic, csum;
+
+	rc = bnx2x_nvram_read(bp, 0, data, 4);
+	if (rc) {
+		DP(NETIF_MSG_PROBE, "magic value read (rc -%d)\n", -rc);
+		goto test_nvram_exit;
+	}
+
+	magic = be32_to_cpu(buf[0]);
+	if (magic != 0x669955aa) {
+		DP(NETIF_MSG_PROBE, "magic value (0x%08x)\n", magic);
+		rc = -ENODEV;
+		goto test_nvram_exit;
+	}
+
+	for (i = 0; nvram_tbl[i].size; i++) {
+
+		rc = bnx2x_nvram_read(bp, nvram_tbl[i].offset, data,
+				      nvram_tbl[i].size);
+		if (rc) {
+			DP(NETIF_MSG_PROBE,
+			   "nvram_tbl[%d] read data (rc -%d)\n", i, -rc);
+			goto test_nvram_exit;
+		}
+
+		csum = ether_crc_le(nvram_tbl[i].size, data);
+		if (csum != CRC32_RESIDUAL) {
+			DP(NETIF_MSG_PROBE,
+			   "nvram_tbl[%d] csum value (0x%08x)\n", i, csum);
+			rc = -ENODEV;
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
+	struct mac_configuration_cmd *config = bnx2x_sp(bp, mac_config);
+	int i, rc;
+
+	if (!netif_running(bp->dev))
+		return -ENODEV;
+
+	config->hdr.length_6b = 0;
+	config->hdr.offset = 0;
+	config->hdr.client_id = BP_CL_ID(bp);
+	config->hdr.reserved1 = 0;
+
+	rc = bnx2x_sp_post(bp, RAMROD_CMD_ID_ETH_SET_MAC, 0,
+			   U64_HI(bnx2x_sp_mapping(bp, mac_config)),
+			   U64_LO(bnx2x_sp_mapping(bp, mac_config)), 0);
+	if (rc == 0) {
+		bp->set_mac_pending++;
+		for (i = 0; i < 10; i++) {
+			if (!bp->set_mac_pending)
+				break;
+			msleep_interruptible(10);
+		}
+		if (i == 10)
+			rc = -ENODEV;
+	}
+
+	return rc;
+}
+
 static void bnx2x_self_test(struct net_device *dev,
 			    struct ethtool_test *etest, u64 *buf)
 {
 	struct bnx2x *bp = netdev_priv(dev);
-	int stats_state;
 
 	memset(buf, 0, sizeof(u64) * BNX2X_NUM_TESTS);
 
-	if (bp->state != BNX2X_STATE_OPEN) {
-		DP(NETIF_MSG_PROBE, "state is %x, returning\n", bp->state);
+	if (!netif_running(dev))
 		return;
-	}
 
-	stats_state = bp->stats_state;
+	/* offline tests are not suppoerted in MF mode */
+	if (IS_E1HMF(bp))
+		etest->flags &= ~ETH_TEST_FL_OFFLINE;
+
+	if (etest->flags & ETH_TEST_FL_OFFLINE) {
+		u8 link_up;
+
+		link_up = bp->link_vars.link_up;
+		bnx2x_nic_unload(bp, UNLOAD_NORMAL);
+		bnx2x_nic_load(bp, LOAD_DIAG);
+		/* wait until link state is restored */
+		bnx2x_wait_for_link(bp, link_up);
+
+		if (bnx2x_test_registers(bp) != 0) {
+			buf[0] = 1;
+			etest->flags |= ETH_TEST_FL_FAILED;
+		}
+		if (bnx2x_test_memory(bp) != 0) {
+			buf[1] = 1;
+			etest->flags |= ETH_TEST_FL_FAILED;
+		}
+		buf[2] = bnx2x_test_loopback(bp, link_up);
+		if (buf[2] != 0)
+			etest->flags |= ETH_TEST_FL_FAILED;
 
-	if (bnx2x_mc_assert(bp) != 0) {
-		buf[0] = 1;
+		bnx2x_nic_unload(bp, UNLOAD_NORMAL);
+		bnx2x_nic_load(bp, LOAD_NORMAL);
+		/* wait until link state is restored */
+		bnx2x_wait_for_link(bp, link_up);
+	}
+	if (bnx2x_test_nvram(bp) != 0) {
+		buf[3] = 1;
+		etest->flags |= ETH_TEST_FL_FAILED;
+	}
+	if (bnx2x_test_intr(bp) != 0) {
+		buf[4] = 1;
 		etest->flags |= ETH_TEST_FL_FAILED;
 	}
+	if (bp->port.pmf)
+		if (bnx2x_link_test(bp) != 0) {
+			buf[5] = 1;
+			etest->flags |= ETH_TEST_FL_FAILED;
+		}
+	buf[7] = bnx2x_mc_assert(bp);
+	if (buf[7] != 0)
+		etest->flags |= ETH_TEST_FL_FAILED;
+
+#ifdef BNX2X_EXTRA_DEBUG
+	bnx2x_panic_dump(bp);
+#endif
 }
 
 static const struct {
@@ -8664,7 +9153,6 @@ static int bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 #endif
 
 	fp_index = (smp_processor_id() % bp->num_queues);
-
 	fp = &bp->fp[fp_index];
 
 	if (unlikely(bnx2x_tx_avail(bp->fp) <
@@ -8901,26 +9389,26 @@ static int bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	return NETDEV_TX_OK;
 }
 
-/* Called with rtnl_lock */
+/* called with rtnl_lock */
 static int bnx2x_open(struct net_device *dev)
 {
 	struct bnx2x *bp = netdev_priv(dev);
 
 	bnx2x_set_power_state(bp, PCI_D0);
 
-	return bnx2x_nic_load(bp, 1);
+	return bnx2x_nic_load(bp, LOAD_OPEN);
 }
 
-/* Called with rtnl_lock */
+/* called with rtnl_lock */
 static int bnx2x_close(struct net_device *dev)
 {
 	struct bnx2x *bp = netdev_priv(dev);
 
 	/* Unload the driver, release IRQs */
-	bnx2x_nic_unload(bp, 1);
-
-	if (!CHIP_REV_IS_SLOW(bp))
-		bnx2x_set_power_state(bp, PCI_D3hot);
+	bnx2x_nic_unload(bp, UNLOAD_CLOSE);
+	if (atomic_read(&bp->pdev->enable_cnt) == 1)
+		if (!CHIP_REV_IS_SLOW(bp))
+			bnx2x_set_power_state(bp, PCI_D3hot);
 
 	return 0;
 }
-- 
1.5.5




