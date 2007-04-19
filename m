From: Jeff Garzik <jeff@garzik.org>
Subject: [git patches] net driver fixes
Date: Thu, 19 Apr 2007 15:31:56 -0400
Message-ID: <20070419193156.GA6734@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:43089 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1766957AbXDSTcA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Apr 2007 15:32:00 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Please pull from 'upstream-linus' branch of
master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git upstream-linus

to receive the following updates:

 drivers/net/Kconfig               |    1 +
 drivers/net/cxgb3/cxgb3_defs.h    |    5 +-
 drivers/net/cxgb3/cxgb3_offload.c |   69 +++++++++++----
 drivers/net/cxgb3/t3_hw.c         |   18 +++--
 drivers/net/sky2.c                |  176 +++++++++++++++++++++++--------------
 drivers/net/sky2.h                |   11 +++
 drivers/net/spider_net.c          |    2 +-
 7 files changed, 190 insertions(+), 92 deletions(-)

Dave Jiang (1):
      gianfar needs crc32 lib dependency

Divy Le Ray (2):
      cxgb3 - Fix low memory conditions
      cxgb3 - PHY interrupts and GPIO pins.

Linas Vepstas (1):
      spidernet: Fix problem sending IP fragments

Stephen Hemminger (6):
      sky2: disable support for 88E8056
      sky2: handle descriptor errors
      sky2: disable ASF on all chip types
      sky2: EC-U performance and jumbo support
      sky2: no jumbo on Yukon FE
      sky2: version 1.14

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index c3f9f59..a3d46ea 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -2263,6 +2263,7 @@ config GIANFAR
 	tristate "Gianfar Ethernet"
 	depends on 85xx || 83xx || PPC_86xx
 	select PHYLIB
+	select CRC32
 	help
 	  This driver supports the Gigabit TSEC on the MPC83xx, MPC85xx,
 	  and MPC86xx family of chips, and the FEC on the 8540.
diff --git a/drivers/net/cxgb3/cxgb3_defs.h b/drivers/net/cxgb3/cxgb3_defs.h
index e14862b..483a594 100644
--- a/drivers/net/cxgb3/cxgb3_defs.h
+++ b/drivers/net/cxgb3/cxgb3_defs.h
@@ -67,7 +67,10 @@ static inline union listen_entry *stid2entry(const struct tid_info *t,
 static inline struct t3c_tid_entry *lookup_tid(const struct tid_info *t,
 					       unsigned int tid)
 {
-	return tid < t->ntids ? &(t->tid_tab[tid]) : NULL;
+	struct t3c_tid_entry *t3c_tid = tid < t->ntids ?
+	    &(t->tid_tab[tid]) : NULL;
+
+	return (t3c_tid && t3c_tid->client) ? t3c_tid : NULL;
 }
 
 /*
diff --git a/drivers/net/cxgb3/cxgb3_offload.c b/drivers/net/cxgb3/cxgb3_offload.c
index 4864924..199e506 100644
--- a/drivers/net/cxgb3/cxgb3_offload.c
+++ b/drivers/net/cxgb3/cxgb3_offload.c
@@ -508,6 +508,7 @@ void cxgb3_queue_tid_release(struct t3cdev *tdev, unsigned int tid)
 
 	spin_lock_bh(&td->tid_release_lock);
 	p->ctx = (void *)td->tid_release_list;
+	p->client = NULL;
 	td->tid_release_list = p;
 	if (!p->ctx)
 		schedule_work(&td->tid_release_task);
@@ -623,7 +624,8 @@ static int do_act_open_rpl(struct t3cdev *dev, struct sk_buff *skb)
 	struct t3c_tid_entry *t3c_tid;
 
 	t3c_tid = lookup_atid(&(T3C_DATA(dev))->tid_maps, atid);
-	if (t3c_tid->ctx && t3c_tid->client && t3c_tid->client->handlers &&
+	if (t3c_tid && t3c_tid->ctx && t3c_tid->client &&
+	    t3c_tid->client->handlers &&
 	    t3c_tid->client->handlers[CPL_ACT_OPEN_RPL]) {
 		return t3c_tid->client->handlers[CPL_ACT_OPEN_RPL] (dev, skb,
 								    t3c_tid->
@@ -642,7 +644,7 @@ static int do_stid_rpl(struct t3cdev *dev, struct sk_buff *skb)
 	struct t3c_tid_entry *t3c_tid;
 
 	t3c_tid = lookup_stid(&(T3C_DATA(dev))->tid_maps, stid);
-	if (t3c_tid->ctx && t3c_tid->client->handlers &&
+	if (t3c_tid && t3c_tid->ctx && t3c_tid->client->handlers &&
 	    t3c_tid->client->handlers[p->opcode]) {
 		return t3c_tid->client->handlers[p->opcode] (dev, skb,
 							     t3c_tid->ctx);
@@ -660,7 +662,7 @@ static int do_hwtid_rpl(struct t3cdev *dev, struct sk_buff *skb)
 	struct t3c_tid_entry *t3c_tid;
 
 	t3c_tid = lookup_tid(&(T3C_DATA(dev))->tid_maps, hwtid);
-	if (t3c_tid->ctx && t3c_tid->client->handlers &&
+	if (t3c_tid && t3c_tid->ctx && t3c_tid->client->handlers &&
 	    t3c_tid->client->handlers[p->opcode]) {
 		return t3c_tid->client->handlers[p->opcode]
 		    (dev, skb, t3c_tid->ctx);
@@ -689,6 +691,28 @@ static int do_cr(struct t3cdev *dev, struct sk_buff *skb)
 	}
 }
 
+/*
+ * Returns an sk_buff for a reply CPL message of size len.  If the input
+ * sk_buff has no other users it is trimmed and reused, otherwise a new buffer
+ * is allocated.  The input skb must be of size at least len.  Note that this
+ * operation does not destroy the original skb data even if it decides to reuse
+ * the buffer.
+ */
+static struct sk_buff *cxgb3_get_cpl_reply_skb(struct sk_buff *skb, size_t len,
+					       int gfp)
+{
+	if (likely(!skb_cloned(skb))) {
+		BUG_ON(skb->len < len);
+		__skb_trim(skb, len);
+		skb_get(skb);
+	} else {
+		skb = alloc_skb(len, gfp);
+		if (skb)
+			__skb_put(skb, len);
+	}
+	return skb;
+}
+
 static int do_abort_req_rss(struct t3cdev *dev, struct sk_buff *skb)
 {
 	union opcode_tid *p = cplhdr(skb);
@@ -696,30 +720,39 @@ static int do_abort_req_rss(struct t3cdev *dev, struct sk_buff *skb)
 	struct t3c_tid_entry *t3c_tid;
 
 	t3c_tid = lookup_tid(&(T3C_DATA(dev))->tid_maps, hwtid);
-	if (t3c_tid->ctx && t3c_tid->client->handlers &&
+	if (t3c_tid && t3c_tid->ctx && t3c_tid->client->handlers &&
 	    t3c_tid->client->handlers[p->opcode]) {
 		return t3c_tid->client->handlers[p->opcode]
 		    (dev, skb, t3c_tid->ctx);
 	} else {
 		struct cpl_abort_req_rss *req = cplhdr(skb);
 		struct cpl_abort_rpl *rpl;
+		struct sk_buff *reply_skb;
+		unsigned int tid = GET_TID(req);
+		u8 cmd = req->status;
+
+		if (req->status == CPL_ERR_RTX_NEG_ADVICE ||
+		    req->status == CPL_ERR_PERSIST_NEG_ADVICE)
+			goto out;
 
-		struct sk_buff *skb =
-		    alloc_skb(sizeof(struct cpl_abort_rpl), GFP_ATOMIC);
-		if (!skb) {
+		reply_skb = cxgb3_get_cpl_reply_skb(skb,
+						    sizeof(struct
+							   cpl_abort_rpl),
+						    GFP_ATOMIC);
+
+		if (!reply_skb) {
 			printk("do_abort_req_rss: couldn't get skb!\n");
 			goto out;
 		}
-		skb->priority = CPL_PRIORITY_DATA;
-		__skb_put(skb, sizeof(struct cpl_abort_rpl));
-		rpl = cplhdr(skb);
+		reply_skb->priority = CPL_PRIORITY_DATA;
+		__skb_put(reply_skb, sizeof(struct cpl_abort_rpl));
+		rpl = cplhdr(reply_skb);
 		rpl->wr.wr_hi =
 		    htonl(V_WR_OP(FW_WROPCODE_OFLD_HOST_ABORT_CON_RPL));
-		rpl->wr.wr_lo = htonl(V_WR_TID(GET_TID(req)));
-		OPCODE_TID(rpl) =
-		    htonl(MK_OPCODE_TID(CPL_ABORT_RPL, GET_TID(req)));
-		rpl->cmd = req->status;
-		cxgb3_ofld_send(dev, skb);
+		rpl->wr.wr_lo = htonl(V_WR_TID(tid));
+		OPCODE_TID(rpl) = htonl(MK_OPCODE_TID(CPL_ABORT_RPL, tid));
+		rpl->cmd = cmd;
+		cxgb3_ofld_send(dev, reply_skb);
 out:
 		return CPL_RET_BUF_DONE;
 	}
@@ -732,7 +765,7 @@ static int do_act_establish(struct t3cdev *dev, struct sk_buff *skb)
 	struct t3c_tid_entry *t3c_tid;
 
 	t3c_tid = lookup_atid(&(T3C_DATA(dev))->tid_maps, atid);
-	if (t3c_tid->ctx && t3c_tid->client->handlers &&
+	if (t3c_tid && t3c_tid->ctx && t3c_tid->client->handlers &&
 	    t3c_tid->client->handlers[CPL_ACT_ESTABLISH]) {
 		return t3c_tid->client->handlers[CPL_ACT_ESTABLISH]
 		    (dev, skb, t3c_tid->ctx);
@@ -762,7 +795,7 @@ static int do_term(struct t3cdev *dev, struct sk_buff *skb)
 	struct t3c_tid_entry *t3c_tid;
 
 	t3c_tid = lookup_tid(&(T3C_DATA(dev))->tid_maps, hwtid);
-	if (t3c_tid->ctx && t3c_tid->client->handlers &&
+	if (t3c_tid && t3c_tid->ctx && t3c_tid->client->handlers &&
 	    t3c_tid->client->handlers[opcode]) {
 		return t3c_tid->client->handlers[opcode] (dev, skb,
 							  t3c_tid->ctx);
@@ -961,7 +994,7 @@ void cxgb_redirect(struct dst_entry *old, struct dst_entry *new)
 	for (tid = 0; tid < ti->ntids; tid++) {
 		te = lookup_tid(ti, tid);
 		BUG_ON(!te);
-		if (te->ctx && te->client && te->client->redirect) {
+		if (te && te->ctx && te->client && te->client->redirect) {
 			update_tcb = te->client->redirect(te->ctx, old, new, e);
 			if (update_tcb) {
 				l2t_hold(L2DATA(tdev), e);
diff --git a/drivers/net/cxgb3/t3_hw.c b/drivers/net/cxgb3/t3_hw.c
index d83f075..fb485d0 100644
--- a/drivers/net/cxgb3/t3_hw.c
+++ b/drivers/net/cxgb3/t3_hw.c
@@ -1523,19 +1523,25 @@ static int mac_intr_handler(struct adapter *adap, unsigned int idx)
  */
 int t3_phy_intr_handler(struct adapter *adapter)
 {
-	static const int intr_gpio_bits[] = { 8, 0x20 };
-
+	u32 mask, gpi = adapter_info(adapter)->gpio_intr;
 	u32 i, cause = t3_read_reg(adapter, A_T3DBG_INT_CAUSE);
 
 	for_each_port(adapter, i) {
-		if (cause & intr_gpio_bits[i]) {
-			struct cphy *phy = &adap2pinfo(adapter, i)->phy;
-			int phy_cause = phy->ops->intr_handler(phy);
+		struct port_info *p = adap2pinfo(adapter, i);
+
+		mask = gpi - (gpi & (gpi - 1));
+		gpi -= mask;
+
+		if (!(p->port_type->caps & SUPPORTED_IRQ))
+			continue;
+
+		if (cause & mask) {
+			int phy_cause = p->phy.ops->intr_handler(&p->phy);
 
 			if (phy_cause & cphy_cause_link_change)
 				t3_link_changed(adapter, i);
 			if (phy_cause & cphy_cause_fifo_error)
-				phy->fifo_errors++;
+				p->phy.fifo_errors++;
 		}
 	}
 
diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index 4a009b7..ac36152 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -49,7 +49,7 @@
 #include "sky2.h"
 
 #define DRV_NAME		"sky2"
-#define DRV_VERSION		"1.13"
+#define DRV_VERSION		"1.14"
 #define PFX			DRV_NAME " "
 
 /*
@@ -123,7 +123,10 @@ static const struct pci_device_id sky2_id_table[] = {
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4361) }, /* 88E8050 */
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4362) }, /* 88E8053 */
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4363) }, /* 88E8055 */
+#ifdef broken
+	/* This device causes data corruption problems that are not resolved */
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4364) }, /* 88E8056 */
+#endif
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4366) }, /* 88EC036 */
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4367) }, /* 88EC032 */
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4368) }, /* 88EC034 */
@@ -740,12 +743,17 @@ static void sky2_mac_init(struct sky2_hw *hw, unsigned port)
 	if (hw->chip_id == CHIP_ID_YUKON_EC_U || hw->chip_id == CHIP_ID_YUKON_EX) {
 		sky2_write8(hw, SK_REG(port, RX_GMF_LP_THR), 768/8);
 		sky2_write8(hw, SK_REG(port, RX_GMF_UP_THR), 1024/8);
-		if (hw->dev[port]->mtu > ETH_DATA_LEN) {
-			/* set Tx GMAC FIFO Almost Empty Threshold */
-			sky2_write32(hw, SK_REG(port, TX_GMF_AE_THR), 0x180);
-			/* Disable Store & Forward mode for TX */
-			sky2_write32(hw, SK_REG(port, TX_GMF_CTRL_T), TX_STFW_DIS);
-		}
+
+		/* set Tx GMAC FIFO Almost Empty Threshold */
+		sky2_write32(hw, SK_REG(port, TX_GMF_AE_THR),
+			     (ECU_JUMBO_WM << 16) | ECU_AE_THR);
+
+		if (hw->dev[port]->mtu > ETH_DATA_LEN)
+			sky2_write32(hw, SK_REG(port, TX_GMF_CTRL_T),
+				     TX_JUMBO_ENA | TX_STFW_DIS);
+		else
+			sky2_write32(hw, SK_REG(port, TX_GMF_CTRL_T),
+				     TX_JUMBO_DIS | TX_STFW_ENA);
 	}
 
 }
@@ -1278,7 +1286,7 @@ static int sky2_up(struct net_device *dev)
 	/* Set almost empty threshold */
 	if (hw->chip_id == CHIP_ID_YUKON_EC_U
 	    && hw->chip_rev == CHIP_REV_YU_EC_U_A0)
-		sky2_write16(hw, Q_ADDR(txqaddr[port], Q_AL), 0x1a0);
+		sky2_write16(hw, Q_ADDR(txqaddr[port], Q_AL), ECU_TXFF_LEV);
 
 	sky2_prefetch_init(hw, txqaddr[port], sky2->tx_le_map,
 			   TX_RING_SIZE - 1);
@@ -1584,13 +1592,6 @@ static int sky2_down(struct net_device *dev)
 	sky2_write32(hw, RB_ADDR(txqaddr[port], RB_CTRL),
 		     RB_RST_SET | RB_DIS_OP_MD);
 
-	/* WA for dev. #4.209 */
-	if (hw->chip_id == CHIP_ID_YUKON_EC_U
-	    && (hw->chip_rev == CHIP_REV_YU_EC_U_A1 || hw->chip_rev == CHIP_REV_YU_EC_U_B0))
-		sky2_write32(hw, SK_REG(port, TX_GMF_CTRL_T),
-			     sky2->speed != SPEED_1000 ?
-			     TX_STFW_ENA : TX_STFW_DIS);
-
 	ctrl = gma_read16(hw, port, GM_GP_CTRL);
 	ctrl &= ~(GM_GPCR_TX_ENA | GM_GPCR_RX_ENA);
 	gma_write16(hw, port, GM_GP_CTRL, ctrl);
@@ -1890,6 +1891,7 @@ static int sky2_change_mtu(struct net_device *dev, int new_mtu)
 {
 	struct sky2_port *sky2 = netdev_priv(dev);
 	struct sky2_hw *hw = sky2->hw;
+	unsigned port = sky2->port;
 	int err;
 	u16 ctl, mode;
 	u32 imask;
@@ -1897,9 +1899,8 @@ static int sky2_change_mtu(struct net_device *dev, int new_mtu)
 	if (new_mtu < ETH_ZLEN || new_mtu > ETH_JUMBO_MTU)
 		return -EINVAL;
 
-	/* TSO on Yukon Ultra and MTU > 1500 not supported */
-	if (hw->chip_id == CHIP_ID_YUKON_EC_U && new_mtu > ETH_DATA_LEN)
-		dev->features &= ~NETIF_F_TSO;
+	if (new_mtu > ETH_DATA_LEN && hw->chip_id == CHIP_ID_YUKON_FE)
+		return -EINVAL;
 
 	if (!netif_running(dev)) {
 		dev->mtu = new_mtu;
@@ -1915,8 +1916,18 @@ static int sky2_change_mtu(struct net_device *dev, int new_mtu)
 
 	synchronize_irq(hw->pdev->irq);
 
-	ctl = gma_read16(hw, sky2->port, GM_GP_CTRL);
-	gma_write16(hw, sky2->port, GM_GP_CTRL, ctl & ~GM_GPCR_RX_ENA);
+	if (hw->chip_id == CHIP_ID_YUKON_EC_U || hw->chip_id == CHIP_ID_YUKON_EX) {
+		if (new_mtu > ETH_DATA_LEN) {
+			sky2_write32(hw, SK_REG(port, TX_GMF_CTRL_T),
+				     TX_JUMBO_ENA | TX_STFW_DIS);
+			dev->features &= NETIF_F_TSO | NETIF_F_SG | NETIF_F_IP_CSUM;
+		} else
+			sky2_write32(hw, SK_REG(port, TX_GMF_CTRL_T),
+				     TX_JUMBO_DIS | TX_STFW_ENA);
+	}
+
+	ctl = gma_read16(hw, port, GM_GP_CTRL);
+	gma_write16(hw, port, GM_GP_CTRL, ctl & ~GM_GPCR_RX_ENA);
 	sky2_rx_stop(sky2);
 	sky2_rx_clean(sky2);
 
@@ -1928,9 +1939,9 @@ static int sky2_change_mtu(struct net_device *dev, int new_mtu)
 	if (dev->mtu > ETH_DATA_LEN)
 		mode |= GM_SMOD_JUMBO_ENA;
 
-	gma_write16(hw, sky2->port, GM_SERIAL_MODE, mode);
+	gma_write16(hw, port, GM_SERIAL_MODE, mode);
 
-	sky2_write8(hw, RB_ADDR(rxqaddr[sky2->port], RB_CTRL), RB_ENA_OP_MD);
+	sky2_write8(hw, RB_ADDR(rxqaddr[port], RB_CTRL), RB_ENA_OP_MD);
 
 	err = sky2_rx_start(sky2);
 	sky2_write32(hw, B0_IMSK, imask);
@@ -1938,7 +1949,7 @@ static int sky2_change_mtu(struct net_device *dev, int new_mtu)
 	if (err)
 		dev_close(dev);
 	else {
-		gma_write16(hw, sky2->port, GM_GP_CTRL, ctl);
+		gma_write16(hw, port, GM_GP_CTRL, ctl);
 
 		netif_poll_enable(hw->dev[0]);
 		netif_wake_queue(dev);
@@ -2340,26 +2351,22 @@ static void sky2_mac_intr(struct sky2_hw *hw, unsigned port)
 	}
 }
 
-/* This should never happen it is a fatal situation */
-static void sky2_descriptor_error(struct sky2_hw *hw, unsigned port,
-				  const char *rxtx, u32 mask)
+/* This should never happen it is a bug. */
+static void sky2_le_error(struct sky2_hw *hw, unsigned port,
+			  u16 q, unsigned ring_size)
 {
 	struct net_device *dev = hw->dev[port];
 	struct sky2_port *sky2 = netdev_priv(dev);
-	u32 imask;
-
-	printk(KERN_ERR PFX "%s: %s descriptor error (hardware problem)\n",
-	       dev ? dev->name : "<not registered>", rxtx);
+	unsigned idx;
+	const u64 *le = (q == Q_R1 || q == Q_R2)
+		? (u64 *) sky2->rx_le : (u64 *) sky2->tx_le;
 
-	imask = sky2_read32(hw, B0_IMSK);
-	imask &= ~mask;
-	sky2_write32(hw, B0_IMSK, imask);
+	idx = sky2_read16(hw, Y2_QADDR(q, PREF_UNIT_GET_IDX));
+	printk(KERN_ERR PFX "%s: descriptor error q=%#x get=%u [%llx] put=%u\n",
+	       dev->name, (unsigned) q, idx, (unsigned long long) le[idx],
+	       (unsigned) sky2_read16(hw, Y2_QADDR(q, PREF_UNIT_PUT_IDX)));
 
-	if (dev) {
-		spin_lock(&sky2->phy_lock);
-		sky2_link_down(sky2);
-		spin_unlock(&sky2->phy_lock);
-	}
+	sky2_write32(hw, Q_ADDR(q, Q_CSR), BMU_CLR_IRQ_CHK);
 }
 
 /* If idle then force a fake soft NAPI poll once a second
@@ -2383,23 +2390,15 @@ static void sky2_idle(unsigned long arg)
 	mod_timer(&hw->idle_timer, jiffies + msecs_to_jiffies(idle_timeout));
 }
 
-
-static int sky2_poll(struct net_device *dev0, int *budget)
+/* Hardware/software error handling */
+static void sky2_err_intr(struct sky2_hw *hw, u32 status)
 {
-	struct sky2_hw *hw = ((struct sky2_port *) netdev_priv(dev0))->hw;
-	int work_limit = min(dev0->quota, *budget);
-	int work_done = 0;
-	u32 status = sky2_read32(hw, B0_Y2_SP_EISR);
+	if (net_ratelimit())
+		dev_warn(&hw->pdev->dev, "error interrupt status=%#x\n", status);
 
 	if (status & Y2_IS_HW_ERR)
 		sky2_hw_intr(hw);
 
-	if (status & Y2_IS_IRQ_PHY1)
-		sky2_phy_intr(hw, 0);
-
-	if (status & Y2_IS_IRQ_PHY2)
-		sky2_phy_intr(hw, 1);
-
 	if (status & Y2_IS_IRQ_MAC1)
 		sky2_mac_intr(hw, 0);
 
@@ -2407,16 +2406,33 @@ static int sky2_poll(struct net_device *dev0, int *budget)
 		sky2_mac_intr(hw, 1);
 
 	if (status & Y2_IS_CHK_RX1)
-		sky2_descriptor_error(hw, 0, "receive", Y2_IS_CHK_RX1);
+		sky2_le_error(hw, 0, Q_R1, RX_LE_SIZE);
 
 	if (status & Y2_IS_CHK_RX2)
-		sky2_descriptor_error(hw, 1, "receive", Y2_IS_CHK_RX2);
+		sky2_le_error(hw, 1, Q_R2, RX_LE_SIZE);
 
 	if (status & Y2_IS_CHK_TXA1)
-		sky2_descriptor_error(hw, 0, "transmit", Y2_IS_CHK_TXA1);
+		sky2_le_error(hw, 0, Q_XA1, TX_RING_SIZE);
 
 	if (status & Y2_IS_CHK_TXA2)
-		sky2_descriptor_error(hw, 1, "transmit", Y2_IS_CHK_TXA2);
+		sky2_le_error(hw, 1, Q_XA2, TX_RING_SIZE);
+}
+
+static int sky2_poll(struct net_device *dev0, int *budget)
+{
+	struct sky2_hw *hw = ((struct sky2_port *) netdev_priv(dev0))->hw;
+	int work_limit = min(dev0->quota, *budget);
+	int work_done = 0;
+	u32 status = sky2_read32(hw, B0_Y2_SP_EISR);
+
+	if (unlikely(status & Y2_IS_ERROR))
+		sky2_err_intr(hw, status);
+
+	if (status & Y2_IS_IRQ_PHY1)
+		sky2_phy_intr(hw, 0);
+
+	if (status & Y2_IS_IRQ_PHY2)
+		sky2_phy_intr(hw, 1);
 
 	work_done = sky2_status_intr(hw, work_limit);
 	if (work_done < work_limit) {
@@ -2534,16 +2550,14 @@ static void sky2_reset(struct sky2_hw *hw)
 	int i;
 
 	/* disable ASF */
-	if (hw->chip_id <= CHIP_ID_YUKON_EC) {
-		if (hw->chip_id == CHIP_ID_YUKON_EX) {
-			status = sky2_read16(hw, HCU_CCSR);
-			status &= ~(HCU_CCSR_AHB_RST | HCU_CCSR_CPU_RST_MODE |
-				    HCU_CCSR_UC_STATE_MSK);
-			sky2_write16(hw, HCU_CCSR, status);
-		} else
-			sky2_write8(hw, B28_Y2_ASF_STAT_CMD, Y2_ASF_RESET);
-		sky2_write16(hw, B0_CTST, Y2_ASF_DISABLE);
-	}
+	if (hw->chip_id == CHIP_ID_YUKON_EX) {
+		status = sky2_read16(hw, HCU_CCSR);
+		status &= ~(HCU_CCSR_AHB_RST | HCU_CCSR_CPU_RST_MODE |
+			    HCU_CCSR_UC_STATE_MSK);
+		sky2_write16(hw, HCU_CCSR, status);
+	} else
+		sky2_write8(hw, B28_Y2_ASF_STAT_CMD, Y2_ASF_RESET);
+	sky2_write16(hw, B0_CTST, Y2_ASF_DISABLE);
 
 	/* do a SW reset */
 	sky2_write8(hw, B0_CTST, CS_RST_SET);
@@ -3328,6 +3342,36 @@ static void sky2_get_regs(struct net_device *dev, struct ethtool_regs *regs,
 		      regs->len - B3_RI_WTO_R1);
 }
 
+/* In order to do Jumbo packets on these chips, need to turn off the
+ * transmit store/forward. Therefore checksum offload won't work.
+ */
+static int no_tx_offload(struct net_device *dev)
+{
+	const struct sky2_port *sky2 = netdev_priv(dev);
+	const struct sky2_hw *hw = sky2->hw;
+
+	return dev->mtu > ETH_DATA_LEN &&
+		(hw->chip_id == CHIP_ID_YUKON_EX
+		 || hw->chip_id == CHIP_ID_YUKON_EC_U);
+}
+
+static int sky2_set_tx_csum(struct net_device *dev, u32 data)
+{
+	if (data && no_tx_offload(dev))
+		return -EINVAL;
+
+	return ethtool_op_set_tx_csum(dev, data);
+}
+
+
+static int sky2_set_tso(struct net_device *dev, u32 data)
+{
+	if (data && no_tx_offload(dev))
+		return -EINVAL;
+
+	return ethtool_op_set_tso(dev, data);
+}
+
 static const struct ethtool_ops sky2_ethtool_ops = {
 	.get_settings = sky2_get_settings,
 	.set_settings = sky2_set_settings,
@@ -3343,9 +3387,9 @@ static const struct ethtool_ops sky2_ethtool_ops = {
 	.get_sg = ethtool_op_get_sg,
 	.set_sg = ethtool_op_set_sg,
 	.get_tx_csum = ethtool_op_get_tx_csum,
-	.set_tx_csum = ethtool_op_set_tx_csum,
+	.set_tx_csum = sky2_set_tx_csum,
 	.get_tso = ethtool_op_get_tso,
-	.set_tso = ethtool_op_set_tso,
+	.set_tso = sky2_set_tso,
 	.get_rx_csum = sky2_get_rx_csum,
 	.set_rx_csum = sky2_set_rx_csum,
 	.get_strings = sky2_get_strings,
diff --git a/drivers/net/sky2.h b/drivers/net/sky2.h
index ac24bdc..5efb5af 100644
--- a/drivers/net/sky2.h
+++ b/drivers/net/sky2.h
@@ -288,6 +288,9 @@ enum {
 		          | Y2_IS_CHK_TXA1 | Y2_IS_CHK_RX1,
 	Y2_IS_PORT_2	= Y2_IS_IRQ_PHY2 | Y2_IS_IRQ_MAC2
 			  | Y2_IS_CHK_TXA2 | Y2_IS_CHK_RX2,
+	Y2_IS_ERROR     = Y2_IS_HW_ERR |
+			  Y2_IS_IRQ_MAC1 | Y2_IS_CHK_TXA1 | Y2_IS_CHK_RX1 |
+			  Y2_IS_IRQ_MAC2 | Y2_IS_CHK_TXA2 | Y2_IS_CHK_RX2,
 };
 
 /*	B2_IRQM_HWE_MSK	32 bit	IRQ Moderation HW Error Mask */
@@ -738,6 +741,11 @@ enum {
 	TX_GMF_RP	= 0x0d70,/* 32 bit 	Tx GMAC FIFO Read Pointer */
 	TX_GMF_RSTP	= 0x0d74,/* 32 bit 	Tx GMAC FIFO Restart Pointer */
 	TX_GMF_RLEV	= 0x0d78,/* 32 bit 	Tx GMAC FIFO Read Level */
+
+	/* Threshold values for Yukon-EC Ultra and Extreme */
+	ECU_AE_THR	= 0x0070, /* Almost Empty Threshold */
+	ECU_TXFF_LEV	= 0x01a0, /* Tx BMU FIFO Level */
+	ECU_JUMBO_WM	= 0x0080, /* Jumbo Mode Watermark */
 };
 
 /* Descriptor Poll Timer Registers */
@@ -1631,6 +1639,9 @@ enum {
 	TX_VLAN_TAG_ON	= 1<<25,/* enable  VLAN tagging */
 	TX_VLAN_TAG_OFF	= 1<<24,/* disable VLAN tagging */
 
+	TX_JUMBO_ENA	= 1<<23,/* PCI Jumbo Mode enable (Yukon-EC Ultra) */
+	TX_JUMBO_DIS	= 1<<22,/* PCI Jumbo Mode enable (Yukon-EC Ultra) */
+
 	GMF_WSP_TST_ON	= 1<<18,/* Write Shadow Pointer Test On */
 	GMF_WSP_TST_OFF	= 1<<17,/* Write Shadow Pointer Test Off */
 	GMF_WSP_STEP	= 1<<16,/* Write Shadow Pointer Step/Increment */
diff --git a/drivers/net/spider_net.c b/drivers/net/spider_net.c
index 3b91af8..e3019d5 100644
--- a/drivers/net/spider_net.c
+++ b/drivers/net/spider_net.c
@@ -719,7 +719,7 @@ spider_net_prepare_tx_descr(struct spider_net_card *card,
 			SPIDER_NET_DESCR_CARDOWNED | SPIDER_NET_DMAC_NOCS;
 	spin_unlock_irqrestore(&chain->lock, flags);
 
-	if (skb->protocol == htons(ETH_P_IP))
+	if (skb->protocol == htons(ETH_P_IP) && skb->ip_summed == CHECKSUM_PARTIAL)
 		switch (skb->nh.iph->protocol) {
 		case IPPROTO_TCP:
 			hwdescr->dmac_cmd_status |= SPIDER_NET_DMAC_TCP;
