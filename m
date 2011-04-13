From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 1/5] tg3: Provide full regdump on tx timeout
Date: Wed, 13 Apr 2011 14:05:04 -0700
Message-ID: <1302728708-1797-2-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com,
	"Michael Chan" <mchan@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3783 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932296Ab1DMU4e (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Apr 2011 16:56:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The current amount of information provided in the output of a tx timeout
is insufficient to determine a root cause.  This patch replaces the
terse, four-register status output with a more complete body of
information.  For PCIe devices, the full register space is dumped.  For
other devices, select registers are dumped instead.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
Reviewed-by: Benjamin Li <benli@broadcom.com>
---
 drivers/net/tg3.c |  189 ++++++++++++++++++++++++++++++++++-------------------
 drivers/net/tg3.h |    2 +
 2 files changed, 123 insertions(+), 68 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 9d7defc..7274435 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -4459,6 +4459,123 @@ static inline int tg3_irq_sync(struct tg3 *tp)
 	return tp->irq_sync;
 }
 
+static inline void tg3_rd32_loop(struct tg3 *tp, u32 *dst, u32 off, u32 len)
+{
+	int i;
+
+	dst = (u32 *)((u8 *)dst + off);
+	for (i = 0; i < len; i += sizeof(u32))
+		*dst++ = tr32(off + i);
+}
+
+static void tg3_dump_legacy_regs(struct tg3 *tp, u32 *regs)
+{
+	tg3_rd32_loop(tp, regs, TG3PCI_VENDOR, 0xb0);
+	tg3_rd32_loop(tp, regs, MAILBOX_INTERRUPT_0, 0x200);
+	tg3_rd32_loop(tp, regs, MAC_MODE, 0x4f0);
+	tg3_rd32_loop(tp, regs, SNDDATAI_MODE, 0xe0);
+	tg3_rd32_loop(tp, regs, SNDDATAC_MODE, 0x04);
+	tg3_rd32_loop(tp, regs, SNDBDS_MODE, 0x80);
+	tg3_rd32_loop(tp, regs, SNDBDI_MODE, 0x48);
+	tg3_rd32_loop(tp, regs, SNDBDC_MODE, 0x04);
+	tg3_rd32_loop(tp, regs, RCVLPC_MODE, 0x20);
+	tg3_rd32_loop(tp, regs, RCVLPC_SELLST_BASE, 0x15c);
+	tg3_rd32_loop(tp, regs, RCVDBDI_MODE, 0x0c);
+	tg3_rd32_loop(tp, regs, RCVDBDI_JUMBO_BD, 0x3c);
+	tg3_rd32_loop(tp, regs, RCVDBDI_BD_PROD_IDX_0, 0x44);
+	tg3_rd32_loop(tp, regs, RCVDCC_MODE, 0x04);
+	tg3_rd32_loop(tp, regs, RCVBDI_MODE, 0x20);
+	tg3_rd32_loop(tp, regs, RCVCC_MODE, 0x14);
+	tg3_rd32_loop(tp, regs, RCVLSC_MODE, 0x08);
+	tg3_rd32_loop(tp, regs, MBFREE_MODE, 0x08);
+	tg3_rd32_loop(tp, regs, HOSTCC_MODE, 0x100);
+
+	if (tp->tg3_flags & TG3_FLAG_SUPPORT_MSIX)
+		tg3_rd32_loop(tp, regs, HOSTCC_RXCOL_TICKS_VEC1, 0x180);
+
+	tg3_rd32_loop(tp, regs, MEMARB_MODE, 0x10);
+	tg3_rd32_loop(tp, regs, BUFMGR_MODE, 0x58);
+	tg3_rd32_loop(tp, regs, RDMAC_MODE, 0x08);
+	tg3_rd32_loop(tp, regs, WDMAC_MODE, 0x08);
+	tg3_rd32_loop(tp, regs, RX_CPU_MODE, 0x04);
+	tg3_rd32_loop(tp, regs, RX_CPU_STATE, 0x04);
+	tg3_rd32_loop(tp, regs, RX_CPU_PGMCTR, 0x04);
+	tg3_rd32_loop(tp, regs, RX_CPU_HWBKPT, 0x04);
+
+	if (!(tp->tg3_flags2 & TG3_FLG2_5705_PLUS)) {
+		tg3_rd32_loop(tp, regs, TX_CPU_MODE, 0x04);
+		tg3_rd32_loop(tp, regs, TX_CPU_STATE, 0x04);
+		tg3_rd32_loop(tp, regs, TX_CPU_PGMCTR, 0x04);
+	}
+
+	tg3_rd32_loop(tp, regs, GRCMBOX_INTERRUPT_0, 0x110);
+	tg3_rd32_loop(tp, regs, FTQ_RESET, 0x120);
+	tg3_rd32_loop(tp, regs, MSGINT_MODE, 0x0c);
+	tg3_rd32_loop(tp, regs, DMAC_MODE, 0x04);
+	tg3_rd32_loop(tp, regs, GRC_MODE, 0x4c);
+
+	if (tp->tg3_flags & TG3_FLAG_NVRAM)
+		tg3_rd32_loop(tp, regs, NVRAM_CMD, 0x24);
+}
+
+static void tg3_dump_state(struct tg3 *tp)
+{
+	int i;
+	u32 *regs;
+
+	regs = kzalloc(TG3_REG_BLK_SIZE, GFP_ATOMIC);
+	if (!regs) {
+		netdev_err(tp->dev, "Failed allocating register dump buffer\n");
+		return;
+	}
+
+	if (tp->tg3_flags2 & TG3_FLG2_PCI_EXPRESS) {
+		/* Read up to but not including private PCI registers */
+		for (i = 0; i < TG3_PCIE_TLDLPL_PORT; i += sizeof(u32))
+			regs[i / sizeof(u32)] = tr32(i);
+	} else
+		tg3_dump_legacy_regs(tp, regs);
+
+	for (i = 0; i < TG3_REG_BLK_SIZE / sizeof(u32); i += 4) {
+		if (!regs[i + 0] && !regs[i + 1] &&
+		    !regs[i + 2] && !regs[i + 3])
+			continue;
+
+		netdev_err(tp->dev, "0x%08x: 0x%08x, 0x%08x, 0x%08x, 0x%08x\n",
+			   i * 4,
+			   regs[i + 0], regs[i + 1], regs[i + 2], regs[i + 3]);
+	}
+
+	kfree(regs);
+
+	for (i = 0; i < tp->irq_cnt; i++) {
+		struct tg3_napi *tnapi = &tp->napi[i];
+
+		/* SW status block */
+		netdev_err(tp->dev,
+			 "%d: Host status block [%08x:%08x:(%04x:%04x:%04x):(%04x:%04x)]\n",
+			   i,
+			   tnapi->hw_status->status,
+			   tnapi->hw_status->status_tag,
+			   tnapi->hw_status->rx_jumbo_consumer,
+			   tnapi->hw_status->rx_consumer,
+			   tnapi->hw_status->rx_mini_consumer,
+			   tnapi->hw_status->idx[0].rx_producer,
+			   tnapi->hw_status->idx[0].tx_consumer);
+
+		netdev_err(tp->dev,
+		"%d: NAPI info [%08x:%08x:(%04x:%04x:%04x):%04x:(%04x:%04x:%04x:%04x)]\n",
+			   i,
+			   tnapi->last_tag, tnapi->last_irq_tag,
+			   tnapi->tx_prod, tnapi->tx_cons, tnapi->tx_pending,
+			   tnapi->rx_rcb_ptr,
+			   tnapi->prodring.rx_std_prod_idx,
+			   tnapi->prodring.rx_std_cons_idx,
+			   tnapi->prodring.rx_jmb_prod_idx,
+			   tnapi->prodring.rx_jmb_cons_idx);
+	}
+}
+
 /* This is called whenever we suspect that the system chipset is re-
  * ordering the sequence of MMIO to the tx send mailbox. The symptom
  * is bogus tx completions. We try to recover by setting the
@@ -5516,21 +5633,13 @@ out:
 		tg3_phy_start(tp);
 }
 
-static void tg3_dump_short_state(struct tg3 *tp)
-{
-	netdev_err(tp->dev, "DEBUG: MAC_TX_STATUS[%08x] MAC_RX_STATUS[%08x]\n",
-		   tr32(MAC_TX_STATUS), tr32(MAC_RX_STATUS));
-	netdev_err(tp->dev, "DEBUG: RDMAC_STATUS[%08x] WDMAC_STATUS[%08x]\n",
-		   tr32(RDMAC_STATUS), tr32(WDMAC_STATUS));
-}
-
 static void tg3_tx_timeout(struct net_device *dev)
 {
 	struct tg3 *tp = netdev_priv(dev);
 
 	if (netif_msg_tx_err(tp)) {
 		netdev_err(dev, "transmit timed out, resetting\n");
-		tg3_dump_short_state(tp);
+		tg3_dump_state(tp);
 	}
 
 	schedule_work(&tp->reset_task);
@@ -9624,82 +9733,26 @@ static void tg3_set_rx_mode(struct net_device *dev)
 	tg3_full_unlock(tp);
 }
 
-#define TG3_REGDUMP_LEN		(32 * 1024)
-
 static int tg3_get_regs_len(struct net_device *dev)
 {
-	return TG3_REGDUMP_LEN;
+	return TG3_REG_BLK_SIZE;
 }
 
 static void tg3_get_regs(struct net_device *dev,
 		struct ethtool_regs *regs, void *_p)
 {
-	u32 *p = _p;
 	struct tg3 *tp = netdev_priv(dev);
-	u8 *orig_p = _p;
-	int i;
 
 	regs->version = 0;
 
-	memset(p, 0, TG3_REGDUMP_LEN);
+	memset(_p, 0, TG3_REG_BLK_SIZE);
 
 	if (tp->phy_flags & TG3_PHYFLG_IS_LOW_POWER)
 		return;
 
 	tg3_full_lock(tp, 0);
 
-#define __GET_REG32(reg)	(*(p)++ = tr32(reg))
-#define GET_REG32_LOOP(base, len)		\
-do {	p = (u32 *)(orig_p + (base));		\
-	for (i = 0; i < len; i += 4)		\
-		__GET_REG32((base) + i);	\
-} while (0)
-#define GET_REG32_1(reg)			\
-do {	p = (u32 *)(orig_p + (reg));		\
-	__GET_REG32((reg));			\
-} while (0)
-
-	GET_REG32_LOOP(TG3PCI_VENDOR, 0xb0);
-	GET_REG32_LOOP(MAILBOX_INTERRUPT_0, 0x200);
-	GET_REG32_LOOP(MAC_MODE, 0x4f0);
-	GET_REG32_LOOP(SNDDATAI_MODE, 0xe0);
-	GET_REG32_1(SNDDATAC_MODE);
-	GET_REG32_LOOP(SNDBDS_MODE, 0x80);
-	GET_REG32_LOOP(SNDBDI_MODE, 0x48);
-	GET_REG32_1(SNDBDC_MODE);
-	GET_REG32_LOOP(RCVLPC_MODE, 0x20);
-	GET_REG32_LOOP(RCVLPC_SELLST_BASE, 0x15c);
-	GET_REG32_LOOP(RCVDBDI_MODE, 0x0c);
-	GET_REG32_LOOP(RCVDBDI_JUMBO_BD, 0x3c);
-	GET_REG32_LOOP(RCVDBDI_BD_PROD_IDX_0, 0x44);
-	GET_REG32_1(RCVDCC_MODE);
-	GET_REG32_LOOP(RCVBDI_MODE, 0x20);
-	GET_REG32_LOOP(RCVCC_MODE, 0x14);
-	GET_REG32_LOOP(RCVLSC_MODE, 0x08);
-	GET_REG32_1(MBFREE_MODE);
-	GET_REG32_LOOP(HOSTCC_MODE, 0x100);
-	GET_REG32_LOOP(MEMARB_MODE, 0x10);
-	GET_REG32_LOOP(BUFMGR_MODE, 0x58);
-	GET_REG32_LOOP(RDMAC_MODE, 0x08);
-	GET_REG32_LOOP(WDMAC_MODE, 0x08);
-	GET_REG32_1(RX_CPU_MODE);
-	GET_REG32_1(RX_CPU_STATE);
-	GET_REG32_1(RX_CPU_PGMCTR);
-	GET_REG32_1(RX_CPU_HWBKPT);
-	GET_REG32_1(TX_CPU_MODE);
-	GET_REG32_1(TX_CPU_STATE);
-	GET_REG32_1(TX_CPU_PGMCTR);
-	GET_REG32_LOOP(GRCMBOX_INTERRUPT_0, 0x110);
-	GET_REG32_LOOP(FTQ_RESET, 0x120);
-	GET_REG32_LOOP(MSGINT_MODE, 0x0c);
-	GET_REG32_1(DMAC_MODE);
-	GET_REG32_LOOP(GRC_MODE, 0x4c);
-	if (tp->tg3_flags & TG3_FLAG_NVRAM)
-		GET_REG32_LOOP(NVRAM_CMD, 0x24);
-
-#undef __GET_REG32
-#undef GET_REG32_LOOP
-#undef GET_REG32_1
+	tg3_dump_legacy_regs(tp, (u32 *)_p);
 
 	tg3_full_unlock(tp);
 }
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index 829a84a..9912010 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -1954,6 +1954,8 @@
 #define TG3_PCIE_PL_LO_PHYCTL5		 0x00000014
 #define TG3_PCIE_PL_LO_PHYCTL5_DIS_L2CLKREQ	  0x80000000
 
+#define TG3_REG_BLK_SIZE		0x00008000
+
 /* OTP bit definitions */
 #define TG3_OTP_AGCTGT_MASK		0x000000e0
 #define TG3_OTP_AGCTGT_SHIFT		1
-- 
1.7.3.4


