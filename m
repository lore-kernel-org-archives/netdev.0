From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 08/12] bnxt_en: Add ethtool mac loopback self test.
Date: Tue,  4 Apr 2017 18:14:13 -0400
Message-ID: <1491344057-12663-9-git-send-email-michael.chan@broadcom.com>
References: <1491344057-12663-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f170.google.com ([209.85.128.170]:36786 "EHLO
        mail-wr0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755173AbdDDWOv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 4 Apr 2017 18:14:51 -0400
Received: by mail-wr0-f170.google.com with SMTP id w11so222692823wrc.3
        for <netdev@vger.kernel.org>; Tue, 04 Apr 2017 15:14:50 -0700 (PDT)
In-Reply-To: <1491344057-12663-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The mac loopback self test operates in polling mode.  To support that,
we need to add functions to open and close the NIC half way.  The half
open mode allows the rings to operate without IRQ and NAPI.  We
use the XDP transmit function to send the loopback packet.

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c         |  37 +++++
 drivers/net/ethernet/broadcom/bnxt/bnxt.h         |   2 +
 drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c | 165 ++++++++++++++++++++--
 drivers/net/ethernet/broadcom/bnxt/bnxt_xdp.c     |   4 +-
 drivers/net/ethernet/broadcom/bnxt/bnxt_xdp.h     |   2 +
 5 files changed, 199 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 7b72ba9..9d71c19 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -6097,6 +6097,43 @@ int bnxt_open_nic(struct bnxt *bp, bool irq_re_init, bool link_re_init)
 	return rc;
 }
 
+/* rtnl_lock held, open the NIC half way by allocating all resources, but
+ * NAPI, IRQ, and TX are not enabled.  This is mainly used for offline
+ * self tests.
+ */
+int bnxt_half_open_nic(struct bnxt *bp)
+{
+	int rc = 0;
+
+	rc = bnxt_alloc_mem(bp, false);
+	if (rc) {
+		netdev_err(bp->dev, "bnxt_alloc_mem err: %x\n", rc);
+		goto half_open_err;
+	}
+	rc = bnxt_init_nic(bp, false);
+	if (rc) {
+		netdev_err(bp->dev, "bnxt_init_nic err: %x\n", rc);
+		goto half_open_err;
+	}
+	return 0;
+
+half_open_err:
+	bnxt_free_skbs(bp);
+	bnxt_free_mem(bp, false);
+	dev_close(bp->dev);
+	return rc;
+}
+
+/* rtnl_lock held, this call can only be made after a previous successful
+ * call to bnxt_half_open_nic().
+ */
+void bnxt_half_close_nic(struct bnxt *bp)
+{
+	bnxt_hwrm_resource_free(bp, false, false);
+	bnxt_free_skbs(bp);
+	bnxt_free_mem(bp, false);
+}
+
 static int bnxt_open(struct net_device *dev)
 {
 	struct bnxt *bp = netdev_priv(dev);
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.h b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
index 4affaac..c9a1688 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
@@ -1255,6 +1255,8 @@ int bnxt_hwrm_func_rgtr_async_events(struct bnxt *bp, unsigned long *bmap,
 int bnxt_hwrm_free_wol_fltr(struct bnxt *bp);
 int bnxt_hwrm_fw_set_time(struct bnxt *);
 int bnxt_open_nic(struct bnxt *, bool, bool);
+int bnxt_half_open_nic(struct bnxt *bp);
+void bnxt_half_close_nic(struct bnxt *bp);
 int bnxt_close_nic(struct bnxt *, bool, bool);
 int bnxt_reserve_rings(struct bnxt *bp, int tx, int rx, int tcs, int tx_xdp);
 int bnxt_setup_mq_tc(struct net_device *dev, u8 tc);
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
index 711d7fd..ecb4417 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
@@ -18,6 +18,7 @@
 #include <linux/firmware.h>
 #include "bnxt_hsi.h"
 #include "bnxt.h"
+#include "bnxt_xdp.h"
 #include "bnxt_ethtool.h"
 #include "bnxt_nvm_defs.h"	/* NVRAM content constant and structure defs */
 #include "bnxt_fw_hdr.h"	/* Firmware hdr constant and structure defs */
@@ -2177,6 +2178,130 @@ static int bnxt_set_phys_id(struct net_device *dev,
 	return rc;
 }
 
+static int bnxt_hwrm_mac_loopback(struct bnxt *bp, bool enable)
+{
+	struct hwrm_port_mac_cfg_input req = {0};
+
+	bnxt_hwrm_cmd_hdr_init(bp, &req, HWRM_PORT_MAC_CFG, -1, -1);
+
+	req.enables = cpu_to_le32(PORT_MAC_CFG_REQ_ENABLES_LPBK);
+	if (enable)
+		req.lpbk = PORT_MAC_CFG_REQ_LPBK_LOCAL;
+	else
+		req.lpbk = PORT_MAC_CFG_REQ_LPBK_NONE;
+	return hwrm_send_message(bp, &req, sizeof(req), HWRM_CMD_TIMEOUT);
+}
+
+static int bnxt_rx_loopback(struct bnxt *bp, struct bnxt_napi *bnapi,
+			    u32 raw_cons, int pkt_size)
+{
+	struct bnxt_cp_ring_info *cpr = &bnapi->cp_ring;
+	struct bnxt_rx_ring_info *rxr = bnapi->rx_ring;
+	struct bnxt_sw_rx_bd *rx_buf;
+	struct rx_cmp *rxcmp;
+	u16 cp_cons, cons;
+	u8 *data;
+	u32 len;
+	int i;
+
+	cp_cons = RING_CMP(raw_cons);
+	rxcmp = (struct rx_cmp *)
+		&cpr->cp_desc_ring[CP_RING(cp_cons)][CP_IDX(cp_cons)];
+	cons = rxcmp->rx_cmp_opaque;
+	rx_buf = &rxr->rx_buf_ring[cons];
+	data = rx_buf->data_ptr;
+	len = le32_to_cpu(rxcmp->rx_cmp_len_flags_type) >> RX_CMP_LEN_SHIFT;
+	if (len != pkt_size)
+		return -EIO;
+	i = ETH_ALEN;
+	if (!ether_addr_equal(data + i, bnapi->bp->dev->dev_addr))
+		return -EIO;
+	i += ETH_ALEN;
+	for (  ; i < pkt_size; i++) {
+		if (data[i] != (u8)(i & 0xff))
+			return -EIO;
+	}
+	return 0;
+}
+
+static int bnxt_poll_loopback(struct bnxt *bp, int pkt_size)
+{
+	struct bnxt_napi *bnapi = bp->bnapi[0];
+	struct bnxt_cp_ring_info *cpr;
+	struct tx_cmp *txcmp;
+	int rc = -EIO;
+	u32 raw_cons;
+	u32 cons;
+	int i;
+
+	cpr = &bnapi->cp_ring;
+	raw_cons = cpr->cp_raw_cons;
+	for (i = 0; i < 200; i++) {
+		cons = RING_CMP(raw_cons);
+		txcmp = &cpr->cp_desc_ring[CP_RING(cons)][CP_IDX(cons)];
+
+		if (!TX_CMP_VALID(txcmp, raw_cons)) {
+			udelay(5);
+			continue;
+		}
+
+		/* The valid test of the entry must be done first before
+		 * reading any further.
+		 */
+		dma_rmb();
+		if (TX_CMP_TYPE(txcmp) == CMP_TYPE_RX_L2_CMP) {
+			rc = bnxt_rx_loopback(bp, bnapi, raw_cons, pkt_size);
+			raw_cons = NEXT_RAW_CMP(raw_cons);
+			raw_cons = NEXT_RAW_CMP(raw_cons);
+			break;
+		}
+		raw_cons = NEXT_RAW_CMP(raw_cons);
+	}
+	cpr->cp_raw_cons = raw_cons;
+	return rc;
+}
+
+static int bnxt_run_loopback(struct bnxt *bp)
+{
+	struct bnxt_tx_ring_info *txr = &bp->tx_ring[0];
+	int pkt_size, i = 0;
+	struct sk_buff *skb;
+	dma_addr_t map;
+	u8 *data;
+	int rc;
+
+	pkt_size = min(bp->dev->mtu + ETH_HLEN, bp->rx_copy_thresh);
+	skb = netdev_alloc_skb(bp->dev, pkt_size);
+	if (!skb)
+		return -ENOMEM;
+	data = skb_put(skb, pkt_size);
+	eth_broadcast_addr(data);
+	i += ETH_ALEN;
+	ether_addr_copy(&data[i], bp->dev->dev_addr);
+	i += ETH_ALEN;
+	for ( ; i < pkt_size; i++)
+		data[i] = (u8)(i & 0xff);
+
+	map = dma_map_single(&bp->pdev->dev, skb->data, pkt_size,
+			     PCI_DMA_TODEVICE);
+	if (dma_mapping_error(&bp->pdev->dev, map)) {
+		dev_kfree_skb(skb);
+		return -EIO;
+	}
+	bnxt_xmit_xdp(bp, txr, map, pkt_size, 0);
+
+	/* Sync BD data before updating doorbell */
+	wmb();
+
+	writel(DB_KEY_TX | txr->tx_prod, txr->tx_doorbell);
+	writel(DB_KEY_TX | txr->tx_prod, txr->tx_doorbell);
+	rc = bnxt_poll_loopback(bp, pkt_size);
+
+	dma_unmap_single(&bp->pdev->dev, map, pkt_size, PCI_DMA_TODEVICE);
+	dev_kfree_skb(skb);
+	return rc;
+}
+
 static int bnxt_run_fw_tests(struct bnxt *bp, u8 test_mask, u8 *test_results)
 {
 	struct hwrm_selftest_exec_output *resp = bp->hwrm_cmd_resp_addr;
@@ -2193,7 +2318,8 @@ static int bnxt_run_fw_tests(struct bnxt *bp, u8 test_mask, u8 *test_results)
 	return rc;
 }
 
-#define BNXT_DRV_TESTS			0
+#define BNXT_DRV_TESTS			1
+#define BNXT_MACLPBK_TEST_IDX		(bp->num_tests - BNXT_DRV_TESTS)
 
 static void bnxt_self_test(struct net_device *dev, struct ethtool_test *etest,
 			   u64 *buf)
@@ -2236,6 +2362,23 @@ static void bnxt_self_test(struct net_device *dev, struct ethtool_test *etest,
 		if (rc)
 			return;
 		bnxt_run_fw_tests(bp, test_mask, &test_results);
+
+		buf[BNXT_MACLPBK_TEST_IDX] = 1;
+		bnxt_hwrm_mac_loopback(bp, true);
+		msleep(250);
+		rc = bnxt_half_open_nic(bp);
+		if (rc) {
+			bnxt_hwrm_mac_loopback(bp, false);
+			etest->flags |= ETH_TEST_FL_FAILED;
+			return;
+		}
+		if (bnxt_run_loopback(bp))
+			etest->flags |= ETH_TEST_FL_FAILED;
+		else
+			buf[BNXT_MACLPBK_TEST_IDX] = 0;
+
+		bnxt_half_close_nic(bp);
+		bnxt_hwrm_mac_loopback(bp, false);
 		bnxt_open_nic(bp, false, true);
 	}
 	for (i = 0; i < bp->num_tests - BNXT_DRV_TESTS; i++) {
@@ -2281,14 +2424,18 @@ void bnxt_ethtool_init(struct bnxt *bp)
 		char *str = test_info->string[i];
 		char *fw_str = resp->test0_name + i * 32;
 
-		strlcpy(str, fw_str, ETH_GSTRING_LEN);
-		strncat(str, " test", ETH_GSTRING_LEN - strlen(str));
-		if (test_info->offline_mask & (1 << i))
-			strncat(str, " (offline)",
-				ETH_GSTRING_LEN - strlen(str));
-		else
-			strncat(str, " (online)",
-				ETH_GSTRING_LEN - strlen(str));
+		if (i == BNXT_MACLPBK_TEST_IDX) {
+			strcpy(str, "Mac loopback test (offline)");
+		} else {
+			strlcpy(str, fw_str, ETH_GSTRING_LEN);
+			strncat(str, " test", ETH_GSTRING_LEN - strlen(str));
+			if (test_info->offline_mask & (1 << i))
+				strncat(str, " (offline)",
+					ETH_GSTRING_LEN - strlen(str));
+			else
+				strncat(str, " (online)",
+					ETH_GSTRING_LEN - strlen(str));
+		}
 	}
 
 ethtool_init_exit:
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_xdp.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_xdp.c
index 899c30f..8b27137 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_xdp.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_xdp.c
@@ -19,8 +19,8 @@
 #include "bnxt.h"
 #include "bnxt_xdp.h"
 
-static void bnxt_xmit_xdp(struct bnxt *bp, struct bnxt_tx_ring_info *txr,
-			  dma_addr_t mapping, u32 len, u16 rx_prod)
+void bnxt_xmit_xdp(struct bnxt *bp, struct bnxt_tx_ring_info *txr,
+		   dma_addr_t mapping, u32 len, u16 rx_prod)
 {
 	struct bnxt_sw_tx_bd *tx_buf;
 	struct tx_bd_ext *txbd1;
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_xdp.h b/drivers/net/ethernet/broadcom/bnxt/bnxt_xdp.h
index b529f2c..12a5ad6 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_xdp.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_xdp.h
@@ -10,6 +10,8 @@
 #ifndef BNXT_XDP_H
 #define BNXT_XDP_H
 
+void bnxt_xmit_xdp(struct bnxt *bp, struct bnxt_tx_ring_info *txr,
+		   dma_addr_t mapping, u32 len, u16 rx_prod);
 void bnxt_tx_int_xdp(struct bnxt *bp, struct bnxt_napi *bnapi, int nr_pkts);
 bool bnxt_rx_xdp(struct bnxt *bp, struct bnxt_rx_ring_info *rxr, u16 cons,
 		 struct page *page, u8 **data_ptr, unsigned int *len,
-- 
1.8.3.1
