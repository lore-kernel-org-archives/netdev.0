From: Jeff Garzik <jeff@garzik.org>
Subject: [git patches] net driver updates
Date: Tue, 9 Oct 2007 21:03:26 -0400
Message-ID: <20071010010325.GA16769@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:33959 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751632AbXJJBD1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Oct 2007 21:03:27 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Please pull from the 'upstream-davem' branch of
master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git upstream-davem

to receive these changes:

Auke Kok (2):
      e1000e: Simple optimizations in e1000_xmit_frame
      e1000e: restore flow control settings properly

Jan-Bernd Themann (1):
      ehea: use kernel event queue

Krishna Kumar (1):
      e1000: Simple optimizations in e1000_xmit_frame

Mark Brown (1):
      natsemi: Use NATSEMI_TIMER_FREQ consistently

Roland Dreier (4):
      IPoIB: Fix unused variable warning
      ibm_emac: Convert to use napi_struct independent of struct net_device
      ibm_new_emac: Nuke SET_MODULE_OWNER() use
      ibm_emac: Convert to use napi_struct independent of struct net_device

Stephen Hemminger (4):
      s2io: sparse warnings fix (rev2)
      network drivers: sparse warning fixes
      chelsio: sparse warning fixes (old cxgb2)
      cxgb3 sparse warning fixes

 drivers/infiniband/ulp/ipoib/ipoib_main.c |    1 
 drivers/net/acenic.c                      |   37 +--
 drivers/net/atl1/atl1_main.c              |    5 
 drivers/net/chelsio/Makefile              |    2 
 drivers/net/chelsio/common.h              |    1 
 drivers/net/chelsio/mac.c                 |  368 ------------------------------
 drivers/net/chelsio/subr.c                |    2 
 drivers/net/cxgb3/cxgb3_main.c            |    4 
 drivers/net/cxgb3/cxgb3_offload.c         |   44 +--
 drivers/net/cxgb3/sge.c                   |    6 
 drivers/net/cxgb3/t3_hw.c                 |    8 
 drivers/net/cxgb3/xgmac.c                 |    2 
 drivers/net/dl2k.c                        |    8 
 drivers/net/e100.c                        |    2 
 drivers/net/e1000/e1000_main.c            |    9 
 drivers/net/e1000e/ethtool.c              |    1 
 drivers/net/e1000e/lib.c                  |   12 
 drivers/net/e1000e/netdev.c               |   10 
 drivers/net/ehea/ehea.h                   |    3 
 drivers/net/ehea/ehea_main.c              |   28 --
 drivers/net/ehea/ehea_qmr.c               |    3 
 drivers/net/hamachi.c                     |    3 
 drivers/net/ibm_emac/ibm_emac_mal.c       |   48 +--
 drivers/net/ibm_emac/ibm_emac_mal.h       |    2 
 drivers/net/ibm_newemac/core.c            |    1 
 drivers/net/ibm_newemac/mal.c             |   55 +---
 drivers/net/ibm_newemac/mal.h             |    2 
 drivers/net/natsemi.c                     |   10 
 drivers/net/s2io.c                        |   97 ++++---
 drivers/net/tehuti.c                      |    4 
 include/linux/netdevice.h                 |   10 
 31 files changed, 195 insertions(+), 593 deletions(-)

diff --git a/drivers/infiniband/ulp/ipoib/ipoib_main.c b/drivers/infiniband/ulp/ipoib/ipoib_main.c
index 6b1b4b2..855c9de 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_main.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_main.c
@@ -854,7 +854,6 @@ struct ipoib_neigh *ipoib_neigh_alloc(struct neighbour *neighbour)
 
 void ipoib_neigh_free(struct net_device *dev, struct ipoib_neigh *neigh)
 {
-	struct ipoib_dev_priv *priv = netdev_priv(dev);
 	struct sk_buff *skb;
 	*to_ipoib_neigh(neigh->neighbour) = NULL;
 	while ((skb = __skb_dequeue(&neigh->queue))) {
diff --git a/drivers/net/acenic.c b/drivers/net/acenic.c
index 2c2ed6d..6c19265 100644
--- a/drivers/net/acenic.c
+++ b/drivers/net/acenic.c
@@ -406,7 +406,7 @@ MODULE_DEVICE_TABLE(pci, acenic_pci_tbl);
 #define DEF_STAT		(2 * TICKS_PER_SEC)
 
 
-static int link[ACE_MAX_MOD_PARMS];
+static int link_state[ACE_MAX_MOD_PARMS];
 static int trace[ACE_MAX_MOD_PARMS];
 static int tx_coal_tick[ACE_MAX_MOD_PARMS];
 static int rx_coal_tick[ACE_MAX_MOD_PARMS];
@@ -419,7 +419,7 @@ MODULE_AUTHOR("Jes Sorensen <jes@trained-monkey.org>");
 MODULE_LICENSE("GPL");
 MODULE_DESCRIPTION("AceNIC/3C985/GA620 Gigabit Ethernet driver");
 
-module_param_array(link, int, NULL, 0);
+module_param_array_named(link, link_state, int, NULL, 0);
 module_param_array(trace, int, NULL, 0);
 module_param_array(tx_coal_tick, int, NULL, 0);
 module_param_array(max_tx_desc, int, NULL, 0);
@@ -987,27 +987,27 @@ static int __devinit ace_init(struct net_device *dev)
 
 	mac1 = 0;
 	for(i = 0; i < 4; i++) {
-		int tmp;
+		int t;
 
 		mac1 = mac1 << 8;
-		tmp = read_eeprom_byte(dev, 0x8c+i);
-		if (tmp < 0) {
+		t = read_eeprom_byte(dev, 0x8c+i);
+		if (t < 0) {
 			ecode = -EIO;
 			goto init_error;
 		} else
-			mac1 |= (tmp & 0xff);
+			mac1 |= (t & 0xff);
 	}
 	mac2 = 0;
 	for(i = 4; i < 8; i++) {
-		int tmp;
+		int t;
 
 		mac2 = mac2 << 8;
-		tmp = read_eeprom_byte(dev, 0x8c+i);
-		if (tmp < 0) {
+		t = read_eeprom_byte(dev, 0x8c+i);
+		if (t < 0) {
 			ecode = -EIO;
 			goto init_error;
 		} else
-			mac2 |= (tmp & 0xff);
+			mac2 |= (t & 0xff);
 	}
 
 	writel(mac1, &regs->MacAddrHi);
@@ -1305,10 +1305,10 @@ static int __devinit ace_init(struct net_device *dev)
 	writel(TX_RING_BASE, &regs->WinBase);
 
 	if (ACE_IS_TIGON_I(ap)) {
-		ap->tx_ring = (struct tx_desc *) regs->Window;
+		ap->tx_ring = (__force struct tx_desc *) regs->Window;
 		for (i = 0; i < (TIGON_I_TX_RING_ENTRIES
 				 * sizeof(struct tx_desc)) / sizeof(u32); i++)
-			writel(0, (void __iomem *)ap->tx_ring  + i * 4);
+			writel(0, (__force void __iomem *)ap->tx_ring  + i * 4);
 
 		set_aceaddr(&info->tx_ctrl.rngptr, TX_RING_BASE);
 	} else {
@@ -1394,8 +1394,8 @@ static int __devinit ace_init(struct net_device *dev)
 	/*
 	 * Override link default parameters
 	 */
-	if ((board_idx >= 0) && link[board_idx]) {
-		int option = link[board_idx];
+	if ((board_idx >= 0) && link_state[board_idx]) {
+		int option = link_state[board_idx];
 
 		tmp = LNK_ENABLE;
 
@@ -2383,8 +2383,9 @@ static int ace_close(struct net_device *dev)
 
 		if (mapping) {
 			if (ACE_IS_TIGON_I(ap)) {
-				struct tx_desc __iomem *tx
-					= (struct tx_desc __iomem *) &ap->tx_ring[i];
+				/* NB: TIGON_1 is special, tx_ring is in io space */
+				struct tx_desc __iomem *tx;
+				tx = (__force struct tx_desc __iomem *) &ap->tx_ring[i];
 				writel(0, &tx->addr.addrhi);
 				writel(0, &tx->addr.addrlo);
 				writel(0, &tx->flagsize);
@@ -2444,7 +2445,7 @@ ace_load_tx_bd(struct ace_private *ap, struct tx_desc *desc, u64 addr,
 #endif
 
 	if (ACE_IS_TIGON_I(ap)) {
-		struct tx_desc __iomem *io = (struct tx_desc __iomem *) desc;
+		struct tx_desc __iomem *io = (__force struct tx_desc __iomem *) desc;
 		writel(addr >> 32, &io->addr.addrhi);
 		writel(addr & 0xffffffff, &io->addr.addrlo);
 		writel(flagsize, &io->flagsize);
@@ -2936,7 +2937,7 @@ static void __devinit ace_clear(struct ace_regs __iomem *regs, u32 dest, int siz
  * This operation requires the NIC to be halted and is performed with
  * interrupts disabled and with the spinlock hold.
  */
-int __devinit ace_load_firmware(struct net_device *dev)
+static int __devinit ace_load_firmware(struct net_device *dev)
 {
 	struct ace_private *ap = netdev_priv(dev);
 	struct ace_regs __iomem *regs = ap->regs;
diff --git a/drivers/net/atl1/atl1_main.c b/drivers/net/atl1/atl1_main.c
index 4c728f1..35b0a7d 100644
--- a/drivers/net/atl1/atl1_main.c
+++ b/drivers/net/atl1/atl1_main.c
@@ -1367,7 +1367,6 @@ rrd_ok:
 	if (count) {
 		u32 tpd_next_to_use;
 		u32 rfd_next_to_use;
-		u32 rrd_next_to_clean;
 
 		spin_lock(&adapter->mb_lock);
 
@@ -1512,7 +1511,7 @@ static void atl1_tx_map(struct atl1_adapter *adapter, struct sk_buff *skb,
 	unsigned int f;
 	u16 tpd_next_to_use;
 	u16 proto_hdr_len;
-	u16 i, m, len12;
+	u16 len12;
 
 	first_buf_len -= skb->data_len;
 	nr_frags = skb_shinfo(skb)->nr_frags;
@@ -1536,6 +1535,8 @@ static void atl1_tx_map(struct atl1_adapter *adapter, struct sk_buff *skb,
 			tpd_next_to_use = 0;
 
 		if (first_buf_len > proto_hdr_len) {
+			int i, m;
+
 			len12 = first_buf_len - proto_hdr_len;
 			m = (len12 + ATL1_MAX_TX_BUF_LEN - 1) /
 				ATL1_MAX_TX_BUF_LEN;
diff --git a/drivers/net/chelsio/Makefile b/drivers/net/chelsio/Makefile
index 743ad8b..57a4b26 100644
--- a/drivers/net/chelsio/Makefile
+++ b/drivers/net/chelsio/Makefile
@@ -4,6 +4,6 @@
 
 obj-$(CONFIG_CHELSIO_T1) += cxgb.o
 
-cxgb-$(CONFIG_CHELSIO_T1_1G) += mac.o mv88e1xxx.o vsc7326.o
+cxgb-$(CONFIG_CHELSIO_T1_1G) += mv88e1xxx.o vsc7326.o
 cxgb-objs := cxgb2.o espi.o tp.o pm3393.o sge.o subr.o \
 	     mv88x201x.o my3126.o $(cxgb-y)
diff --git a/drivers/net/chelsio/common.h b/drivers/net/chelsio/common.h
index b5de445..846ca53 100644
--- a/drivers/net/chelsio/common.h
+++ b/drivers/net/chelsio/common.h
@@ -372,6 +372,7 @@ extern void t1_interrupts_enable(adapter_t *adapter);
 extern void t1_interrupts_disable(adapter_t *adapter);
 extern void t1_interrupts_clear(adapter_t *adapter);
 extern int t1_elmer0_ext_intr_handler(adapter_t *adapter);
+extern void t1_elmer0_ext_intr(adapter_t *adapter);
 extern int t1_slow_intr_handler(adapter_t *adapter);
 
 extern int t1_link_start(struct cphy *phy, struct cmac *mac, struct link_config *lc);
diff --git a/drivers/net/chelsio/mac.c b/drivers/net/chelsio/mac.c
deleted file mode 100644
index 1d97282..0000000
--- a/drivers/net/chelsio/mac.c
+++ /dev/null
@@ -1,368 +0,0 @@
-/* $Date: 2005/10/22 00:42:59 $ $RCSfile: mac.c,v $ $Revision: 1.32 $ */
-#include "gmac.h"
-#include "regs.h"
-#include "fpga_defs.h"
-
-#define MAC_CSR_INTERFACE_GMII      0x0
-#define MAC_CSR_INTERFACE_TBI       0x1
-#define MAC_CSR_INTERFACE_MII       0x2
-#define MAC_CSR_INTERFACE_RMII      0x3
-
-/* Chelsio's MAC statistics. */
-struct mac_statistics {
-
-	/* Transmit */
-	u32 TxFramesTransmittedOK;
-	u32 TxReserved1;
-	u32 TxReserved2;
-	u32 TxOctetsTransmittedOK;
-	u32 TxFramesWithDeferredXmissions;
-	u32 TxLateCollisions;
-	u32 TxFramesAbortedDueToXSCollisions;
-	u32 TxFramesLostDueToIntMACXmitError;
-	u32 TxReserved3;
-	u32 TxMulticastFrameXmittedOK;
-	u32 TxBroadcastFramesXmittedOK;
-	u32 TxFramesWithExcessiveDeferral;
-	u32 TxPAUSEMACCtrlFramesTransmitted;
-
-	/* Receive */
-	u32 RxFramesReceivedOK;
-	u32 RxFrameCheckSequenceErrors;
-	u32 RxAlignmentErrors;
-	u32 RxOctetsReceivedOK;
-	u32 RxFramesLostDueToIntMACRcvError;
-	u32 RxMulticastFramesReceivedOK;
-	u32 RxBroadcastFramesReceivedOK;
-	u32 RxInRangeLengthErrors;
-	u32 RxTxOutOfRangeLengthField;
-	u32 RxFrameTooLongErrors;
-	u32 RxPAUSEMACCtrlFramesReceived;
-};
-
-static int static_aPorts[] = {
-	FPGA_GMAC_INTERRUPT_PORT0,
-	FPGA_GMAC_INTERRUPT_PORT1,
-	FPGA_GMAC_INTERRUPT_PORT2,
-	FPGA_GMAC_INTERRUPT_PORT3
-};
-
-struct _cmac_instance {
-	u32 index;
-};
-
-static int mac_intr_enable(struct cmac *mac)
-{
-	u32 mac_intr;
-
-	if (t1_is_asic(mac->adapter)) {
-		/* ASIC */
-
-		/* We don't use the on chip MAC for ASIC products. */
-	} else {
-		/* FPGA */
-
-		/* Set parent gmac interrupt. */
-		mac_intr = readl(mac->adapter->regs + A_PL_ENABLE);
-		mac_intr |= FPGA_PCIX_INTERRUPT_GMAC;
-		writel(mac_intr, mac->adapter->regs + A_PL_ENABLE);
-
-		mac_intr = readl(mac->adapter->regs + FPGA_GMAC_ADDR_INTERRUPT_ENABLE);
-		mac_intr |= static_aPorts[mac->instance->index];
-		writel(mac_intr,
-		       mac->adapter->regs + FPGA_GMAC_ADDR_INTERRUPT_ENABLE);
-	}
-
-	return 0;
-}
-
-static int mac_intr_disable(struct cmac *mac)
-{
-	u32 mac_intr;
-
-	if (t1_is_asic(mac->adapter)) {
-		/* ASIC */
-
-		/* We don't use the on chip MAC for ASIC products. */
-	} else {
-		/* FPGA */
-
-		/* Set parent gmac interrupt. */
-		mac_intr = readl(mac->adapter->regs + A_PL_ENABLE);
-		mac_intr &= ~FPGA_PCIX_INTERRUPT_GMAC;
-		writel(mac_intr, mac->adapter->regs + A_PL_ENABLE);
-
-		mac_intr = readl(mac->adapter->regs + FPGA_GMAC_ADDR_INTERRUPT_ENABLE);
-		mac_intr &= ~(static_aPorts[mac->instance->index]);
-		writel(mac_intr,
-		       mac->adapter->regs + FPGA_GMAC_ADDR_INTERRUPT_ENABLE);
-	}
-
-	return 0;
-}
-
-static int mac_intr_clear(struct cmac *mac)
-{
-	u32 mac_intr;
-
-	if (t1_is_asic(mac->adapter)) {
-		/* ASIC */
-
-		/* We don't use the on chip MAC for ASIC products. */
-	} else {
-		/* FPGA */
-
-		/* Set parent gmac interrupt. */
-		writel(FPGA_PCIX_INTERRUPT_GMAC,
-		       mac->adapter->regs +  A_PL_CAUSE);
-		mac_intr = readl(mac->adapter->regs + FPGA_GMAC_ADDR_INTERRUPT_CAUSE);
-		mac_intr |= (static_aPorts[mac->instance->index]);
-		writel(mac_intr,
-		       mac->adapter->regs + FPGA_GMAC_ADDR_INTERRUPT_CAUSE);
-	}
-
-	return 0;
-}
-
-static int mac_get_address(struct cmac *mac, u8 addr[6])
-{
-	u32 data32_lo, data32_hi;
-
-	data32_lo = readl(mac->adapter->regs
-			  + MAC_REG_IDLO(mac->instance->index));
-	data32_hi = readl(mac->adapter->regs
-			  + MAC_REG_IDHI(mac->instance->index));
-
-	addr[0] = (u8) ((data32_hi >> 8) & 0xFF);
-	addr[1] = (u8) ((data32_hi) & 0xFF);
-	addr[2] = (u8) ((data32_lo >> 24) & 0xFF);
-	addr[3] = (u8) ((data32_lo >> 16) & 0xFF);
-	addr[4] = (u8) ((data32_lo >> 8) & 0xFF);
-	addr[5] = (u8) ((data32_lo) & 0xFF);
-	return 0;
-}
-
-static int mac_reset(struct cmac *mac)
-{
-	u32 data32;
-	int mac_in_reset, time_out = 100;
-	int idx = mac->instance->index;
-
-	data32 = readl(mac->adapter->regs + MAC_REG_CSR(idx));
-	writel(data32 | F_MAC_RESET,
-	       mac->adapter->regs + MAC_REG_CSR(idx));
-
-	do {
-		data32 = readl(mac->adapter->regs + MAC_REG_CSR(idx));
-
-		mac_in_reset = data32 & F_MAC_RESET;
-		if (mac_in_reset)
-			udelay(1);
-	} while (mac_in_reset && --time_out);
-
-	if (mac_in_reset) {
-		CH_ERR("%s: MAC %d reset timed out\n",
-		       mac->adapter->name, idx);
-		return 2;
-	}
-
-	return 0;
-}
-
-static int mac_set_rx_mode(struct cmac *mac, struct t1_rx_mode *rm)
-{
-	u32 val;
-
-	val = readl(mac->adapter->regs
-			    + MAC_REG_CSR(mac->instance->index));
-	val &= ~(F_MAC_PROMISC | F_MAC_MC_ENABLE);
-	val |= V_MAC_PROMISC(t1_rx_mode_promisc(rm) != 0);
-	val |= V_MAC_MC_ENABLE(t1_rx_mode_allmulti(rm) != 0);
-	writel(val,
-	       mac->adapter->regs + MAC_REG_CSR(mac->instance->index));
-
-	return 0;
-}
-
-static int mac_set_speed_duplex_fc(struct cmac *mac, int speed, int duplex,
-				   int fc)
-{
-	u32 data32;
-
-	data32 = readl(mac->adapter->regs
-			       + MAC_REG_CSR(mac->instance->index));
-	data32 &= ~(F_MAC_HALF_DUPLEX | V_MAC_SPEED(M_MAC_SPEED) |
-		V_INTERFACE(M_INTERFACE) | F_MAC_TX_PAUSE_ENABLE |
-		F_MAC_RX_PAUSE_ENABLE);
-
-	switch (speed) {
-	case SPEED_10:
-	case SPEED_100:
-		data32 |= V_INTERFACE(MAC_CSR_INTERFACE_MII);
-		data32 |= V_MAC_SPEED(speed == SPEED_10 ? 0 : 1);
-		break;
-	case SPEED_1000:
-		data32 |= V_INTERFACE(MAC_CSR_INTERFACE_GMII);
-		data32 |= V_MAC_SPEED(2);
-		break;
-	}
-
-	if (duplex >= 0)
-		data32 |= V_MAC_HALF_DUPLEX(duplex == DUPLEX_HALF);
-
-	if (fc >= 0) {
-		data32 |= V_MAC_RX_PAUSE_ENABLE((fc & PAUSE_RX) != 0);
-		data32 |= V_MAC_TX_PAUSE_ENABLE((fc & PAUSE_TX) != 0);
-	}
-
-	writel(data32,
-	       mac->adapter->regs + MAC_REG_CSR(mac->instance->index));
-	return 0;
-}
-
-static int mac_enable(struct cmac *mac, int which)
-{
-	u32 val;
-
-	val = readl(mac->adapter->regs
-			    + MAC_REG_CSR(mac->instance->index));
-	if (which & MAC_DIRECTION_RX)
-		val |= F_MAC_RX_ENABLE;
-	if (which & MAC_DIRECTION_TX)
-		val |= F_MAC_TX_ENABLE;
-	writel(val,
-	       mac->adapter->regs + MAC_REG_CSR(mac->instance->index));
-	return 0;
-}
-
-static int mac_disable(struct cmac *mac, int which)
-{
-	u32 val;
-
-	val = readl(mac->adapter->regs
-			    + MAC_REG_CSR(mac->instance->index));
-	if (which & MAC_DIRECTION_RX)
-		val &= ~F_MAC_RX_ENABLE;
-	if (which & MAC_DIRECTION_TX)
-		val &= ~F_MAC_TX_ENABLE;
-	writel(val,
-	       mac->adapter->regs + MAC_REG_CSR(mac->instance->index));
-	return 0;
-}
-
-#if 0
-static int mac_set_ifs(struct cmac *mac, u32 mode)
-{
-	t1_write_reg_4(mac->adapter,
-		       MAC_REG_IFS(mac->instance->index),
-		       mode);
-	return 0;
-}
-
-static int mac_enable_isl(struct cmac *mac)
-{
-	u32 data32 = readl(mac->adapter->regs
-				   + MAC_REG_CSR(mac->instance->index));
-	data32 |= F_MAC_RX_ENABLE | F_MAC_TX_ENABLE;
-	t1_write_reg_4(mac->adapter,
-		       MAC_REG_CSR(mac->instance->index),
-		       data32);
-	return 0;
-}
-#endif
-
-static int mac_set_mtu(struct cmac *mac, int mtu)
-{
-	if (mtu > 9600)
-		return -EINVAL;
-	writel(mtu + ETH_HLEN + VLAN_HLEN,
-	       mac->adapter->regs + MAC_REG_LARGEFRAMELENGTH(mac->instance->index));
-
-	return 0;
-}
-
-static const struct cmac_statistics *mac_update_statistics(struct cmac *mac,
-							   int flag)
-{
-	struct mac_statistics st;
-	u32 *p = (u32 *) & st, i;
-
-	writel(0,
-	       mac->adapter->regs + MAC_REG_RMCNT(mac->instance->index));
-
-	for (i = 0; i < sizeof(st) / sizeof(u32); i++)
-		*p++ = readl(mac->adapter->regs
-			     + MAC_REG_RMDATA(mac->instance->index));
-
-	/* XXX convert stats */
-	return &mac->stats;
-}
-
-static void mac_destroy(struct cmac *mac)
-{
-	kfree(mac);
-}
-
-static struct cmac_ops chelsio_mac_ops = {
-	.destroy                 = mac_destroy,
-	.reset                   = mac_reset,
-	.interrupt_enable        = mac_intr_enable,
-	.interrupt_disable       = mac_intr_disable,
-	.interrupt_clear         = mac_intr_clear,
-	.enable                  = mac_enable,
-	.disable                 = mac_disable,
-	.set_mtu                 = mac_set_mtu,
-	.set_rx_mode             = mac_set_rx_mode,
-	.set_speed_duplex_fc     = mac_set_speed_duplex_fc,
-	.macaddress_get          = mac_get_address,
-	.statistics_update       = mac_update_statistics,
-};
-
-static struct cmac *mac_create(adapter_t *adapter, int index)
-{
-	struct cmac *mac;
-	u32 data32;
-
-	if (index >= 4)
-		return NULL;
-
-	mac = kzalloc(sizeof(*mac) + sizeof(cmac_instance), GFP_KERNEL);
-	if (!mac)
-		return NULL;
-
-	mac->ops = &chelsio_mac_ops;
-	mac->instance = (cmac_instance *) (mac + 1);
-
-	mac->instance->index = index;
-	mac->adapter = adapter;
-
-	data32 = readl(adapter->regs + MAC_REG_CSR(mac->instance->index));
-	data32 &= ~(F_MAC_RESET | F_MAC_PROMISC | F_MAC_PROMISC |
-		    F_MAC_LB_ENABLE | F_MAC_RX_ENABLE | F_MAC_TX_ENABLE);
-	data32 |= F_MAC_JUMBO_ENABLE;
-	writel(data32, adapter->regs + MAC_REG_CSR(mac->instance->index));
-
-	/* Initialize the random backoff seed. */
-	data32 = 0x55aa + (3 * index);
-	writel(data32,
-	       adapter->regs + MAC_REG_GMRANDBACKOFFSEED(mac->instance->index));
-
-	/* Check to see if the mac address needs to be set manually. */
-	data32 = readl(adapter->regs + MAC_REG_IDLO(mac->instance->index));
-	if (data32 == 0 || data32 == 0xffffffff) {
-		/*
-		 * Add a default MAC address if we can't read one.
-		 */
-		writel(0x43FFFFFF - index,
-		       adapter->regs + MAC_REG_IDLO(mac->instance->index));
-		writel(0x0007,
-		       adapter->regs + MAC_REG_IDHI(mac->instance->index));
-	}
-
-	(void) mac_set_mtu(mac, 1500);
-	return mac;
-}
-
-const struct gmac t1_chelsio_mac_ops = {
-	.create = mac_create
-};
diff --git a/drivers/net/chelsio/subr.c b/drivers/net/chelsio/subr.c
index 7de9a61..dc50151 100644
--- a/drivers/net/chelsio/subr.c
+++ b/drivers/net/chelsio/subr.c
@@ -884,7 +884,7 @@ static int asic_slow_intr(adapter_t *adapter)
 	if (cause & F_PL_INTR_PCIX)
 		t1_pci_intr_handler(adapter);
 	if (cause & F_PL_INTR_EXT)
-		t1_elmer0_ext_intr_handler(adapter);
+		t1_elmer0_ext_intr(adapter);
 
 	/* Clear the interrupts just processed. */
 	writel(cause, adapter->regs + A_PL_CAUSE);
diff --git a/drivers/net/cxgb3/cxgb3_main.c b/drivers/net/cxgb3/cxgb3_main.c
index e22d065..61ffc92 100644
--- a/drivers/net/cxgb3/cxgb3_main.c
+++ b/drivers/net/cxgb3/cxgb3_main.c
@@ -740,7 +740,7 @@ static inline char t3rev2char(struct adapter *adapter)
 	return rev;
 }
 
-int update_tpsram(struct adapter *adap)
+static int update_tpsram(struct adapter *adap)
 {
 	const struct firmware *tpsram;
 	char buf[64];
@@ -1769,7 +1769,6 @@ static int cxgb_extension_ioctl(struct net_device *dev, void __user *useraddr)
 	}
 	case CHELSIO_SET_QSET_NUM:{
 		struct ch_reg edata;
-		struct port_info *pi = netdev_priv(dev);
 		unsigned int i, first_qset = 0, other_qsets = 0;
 
 		if (!capable(CAP_NET_ADMIN))
@@ -1801,7 +1800,6 @@ static int cxgb_extension_ioctl(struct net_device *dev, void __user *useraddr)
 	}
 	case CHELSIO_GET_QSET_NUM:{
 		struct ch_reg edata;
-		struct port_info *pi = netdev_priv(dev);
 
 		edata.cmd = CHELSIO_GET_QSET_NUM;
 		edata.val = pi->nqsets;
diff --git a/drivers/net/cxgb3/cxgb3_offload.c b/drivers/net/cxgb3/cxgb3_offload.c
index 1c8eec3..bd25421 100644
--- a/drivers/net/cxgb3/cxgb3_offload.c
+++ b/drivers/net/cxgb3/cxgb3_offload.c
@@ -222,32 +222,32 @@ static int cxgb_rdma_ctl(struct adapter *adapter, unsigned int req, void *data)
 	int ret = 0;
 
 	switch (req) {
-	case RDMA_GET_PARAMS:{
-		struct rdma_info *req = data;
+	case RDMA_GET_PARAMS: {
+		struct rdma_info *rdma = data;
 		struct pci_dev *pdev = adapter->pdev;
 
-		req->udbell_physbase = pci_resource_start(pdev, 2);
-		req->udbell_len = pci_resource_len(pdev, 2);
-		req->tpt_base =
+		rdma->udbell_physbase = pci_resource_start(pdev, 2);
+		rdma->udbell_len = pci_resource_len(pdev, 2);
+		rdma->tpt_base =
 			t3_read_reg(adapter, A_ULPTX_TPT_LLIMIT);
-		req->tpt_top = t3_read_reg(adapter, A_ULPTX_TPT_ULIMIT);
-		req->pbl_base =
+		rdma->tpt_top = t3_read_reg(adapter, A_ULPTX_TPT_ULIMIT);
+		rdma->pbl_base =
 			t3_read_reg(adapter, A_ULPTX_PBL_LLIMIT);
-		req->pbl_top = t3_read_reg(adapter, A_ULPTX_PBL_ULIMIT);
-		req->rqt_base = t3_read_reg(adapter, A_ULPRX_RQ_LLIMIT);
-		req->rqt_top = t3_read_reg(adapter, A_ULPRX_RQ_ULIMIT);
-		req->kdb_addr = adapter->regs + A_SG_KDOORBELL;
-		req->pdev = pdev;
+		rdma->pbl_top = t3_read_reg(adapter, A_ULPTX_PBL_ULIMIT);
+		rdma->rqt_base = t3_read_reg(adapter, A_ULPRX_RQ_LLIMIT);
+		rdma->rqt_top = t3_read_reg(adapter, A_ULPRX_RQ_ULIMIT);
+		rdma->kdb_addr = adapter->regs + A_SG_KDOORBELL;
+		rdma->pdev = pdev;
 		break;
 	}
 	case RDMA_CQ_OP:{
 		unsigned long flags;
-		struct rdma_cq_op *req = data;
+		struct rdma_cq_op *rdma = data;
 
 		/* may be called in any context */
 		spin_lock_irqsave(&adapter->sge.reg_lock, flags);
-		ret = t3_sge_cqcntxt_op(adapter, req->id, req->op,
-					req->credits);
+		ret = t3_sge_cqcntxt_op(adapter, rdma->id, rdma->op,
+					rdma->credits);
 		spin_unlock_irqrestore(&adapter->sge.reg_lock, flags);
 		break;
 	}
@@ -274,15 +274,15 @@ static int cxgb_rdma_ctl(struct adapter *adapter, unsigned int req, void *data)
 		break;
 	}
 	case RDMA_CQ_SETUP:{
-		struct rdma_cq_setup *req = data;
+		struct rdma_cq_setup *rdma = data;
 
 		spin_lock_irq(&adapter->sge.reg_lock);
 		ret =
-			t3_sge_init_cqcntxt(adapter, req->id,
-					req->base_addr, req->size,
+			t3_sge_init_cqcntxt(adapter, rdma->id,
+					rdma->base_addr, rdma->size,
 					ASYNC_NOTIF_RSPQ,
-					req->ovfl_mode, req->credits,
-					req->credit_thres);
+					rdma->ovfl_mode, rdma->credits,
+					rdma->credit_thres);
 		spin_unlock_irq(&adapter->sge.reg_lock);
 		break;
 	}
@@ -292,13 +292,13 @@ static int cxgb_rdma_ctl(struct adapter *adapter, unsigned int req, void *data)
 		spin_unlock_irq(&adapter->sge.reg_lock);
 		break;
 	case RDMA_CTRL_QP_SETUP:{
-		struct rdma_ctrlqp_setup *req = data;
+		struct rdma_ctrlqp_setup *rdma = data;
 
 		spin_lock_irq(&adapter->sge.reg_lock);
 		ret = t3_sge_init_ecntxt(adapter, FW_RI_SGEEC_START, 0,
 						SGE_CNTXT_RDMA,
 						ASYNC_NOTIF_RSPQ,
-						req->base_addr, req->size,
+						rdma->base_addr, rdma->size,
 						FW_RI_TID_START, 1, 0);
 		spin_unlock_irq(&adapter->sge.reg_lock);
 		break;
diff --git a/drivers/net/cxgb3/sge.c b/drivers/net/cxgb3/sge.c
index 77f3ec5..994b5d6 100644
--- a/drivers/net/cxgb3/sge.c
+++ b/drivers/net/cxgb3/sge.c
@@ -544,7 +544,7 @@ static void *alloc_ring(struct pci_dev *pdev, size_t nelem, size_t elem_size,
  *	as HW contexts, packet buffers, and descriptor rings.  Traffic to the
  *	queue set must be quiesced prior to calling this.
  */
-void t3_free_qset(struct adapter *adapter, struct sge_qset *q)
+static void t3_free_qset(struct adapter *adapter, struct sge_qset *q)
 {
 	int i;
 	struct pci_dev *pdev = adapter->pdev;
@@ -2215,7 +2215,7 @@ irqreturn_t t3_sge_intr_msix(int irq, void *cookie)
  * The MSI-X interrupt handler for an SGE response queue for the NAPI case
  * (i.e., response queue serviced by NAPI polling).
  */
-irqreturn_t t3_sge_intr_msix_napi(int irq, void *cookie)
+static irqreturn_t t3_sge_intr_msix_napi(int irq, void *cookie)
 {
 	struct sge_qset *qs = cookie;
 	struct sge_rspq *q = &qs->rspq;
@@ -2284,7 +2284,7 @@ static int rspq_check_napi(struct sge_qset *qs)
  * one SGE response queue per port in this mode and protect all response
  * queues with queue 0's lock.
  */
-irqreturn_t t3_intr_msi_napi(int irq, void *cookie)
+static irqreturn_t t3_intr_msi_napi(int irq, void *cookie)
 {
 	int new_packets;
 	struct adapter *adap = cookie;
diff --git a/drivers/net/cxgb3/t3_hw.c b/drivers/net/cxgb3/t3_hw.c
index 0583293..d4ee00d 100644
--- a/drivers/net/cxgb3/t3_hw.c
+++ b/drivers/net/cxgb3/t3_hw.c
@@ -119,9 +119,9 @@ void t3_set_reg_field(struct adapter *adapter, unsigned int addr, u32 mask,
  *	Reads registers that are accessed indirectly through an address/data
  *	register pair.
  */
-void t3_read_indirect(struct adapter *adap, unsigned int addr_reg,
-		      unsigned int data_reg, u32 *vals, unsigned int nregs,
-		      unsigned int start_idx)
+static void t3_read_indirect(struct adapter *adap, unsigned int addr_reg,
+			     unsigned int data_reg, u32 *vals,
+			     unsigned int nregs, unsigned int start_idx)
 {
 	while (nregs--) {
 		t3_write_reg(adap, addr_reg, start_idx);
@@ -3407,7 +3407,7 @@ void early_hw_init(struct adapter *adapter, const struct adapter_info *ai)
  * Older PCIe cards lose their config space during reset, PCI-X
  * ones don't.
  */
-int t3_reset_adapter(struct adapter *adapter)
+static int t3_reset_adapter(struct adapter *adapter)
 {
 	int i, save_and_restore_pcie = 
 	    adapter->params.rev < T3_REV_B2 && is_pcie(adapter);
diff --git a/drivers/net/cxgb3/xgmac.c b/drivers/net/cxgb3/xgmac.c
index bcb5bc4..eeb766a 100644
--- a/drivers/net/cxgb3/xgmac.c
+++ b/drivers/net/cxgb3/xgmac.c
@@ -142,7 +142,7 @@ int t3_mac_reset(struct cmac *mac)
 	return 0;
 }
 
-int t3b2_mac_reset(struct cmac *mac)
+static int t3b2_mac_reset(struct cmac *mac)
 {
 	struct adapter *adap = mac->adapter;
 	unsigned int oft = mac->offset;
diff --git a/drivers/net/dl2k.c b/drivers/net/dl2k.c
index e91b709..5066beb 100644
--- a/drivers/net/dl2k.c
+++ b/drivers/net/dl2k.c
@@ -290,7 +290,7 @@ rio_probe1 (struct pci_dev *pdev, const struct pci_device_id *ent)
 	return err;
 }
 
-int
+static int
 find_miiphy (struct net_device *dev)
 {
 	int i, phy_found = 0;
@@ -314,7 +314,7 @@ find_miiphy (struct net_device *dev)
 	return 0;
 }
 
-int
+static int
 parse_eeprom (struct net_device *dev)
 {
 	int i, j;
@@ -1096,7 +1096,7 @@ clear_stats (struct net_device *dev)
 }
 
 
-int
+static int
 change_mtu (struct net_device *dev, int new_mtu)
 {
 	struct netdev_private *np = netdev_priv(dev);
@@ -1331,7 +1331,7 @@ rio_ioctl (struct net_device *dev, struct ifreq *rq, int cmd)
 #define EEP_BUSY 0x8000
 /* Read the EEPROM word */
 /* We use I/O instruction to read/write eeprom to avoid fail on some machines */
-int
+static int
 read_eeprom (long ioaddr, int eep_addr)
 {
 	int i = 1000;
diff --git a/drivers/net/e100.c b/drivers/net/e100.c
index 7bd9604..64f35e2 100644
--- a/drivers/net/e100.c
+++ b/drivers/net/e100.c
@@ -1990,7 +1990,7 @@ static int e100_poll(struct napi_struct *napi, int budget)
 {
 	struct nic *nic = container_of(napi, struct nic, napi);
 	struct net_device *netdev = nic->netdev;
-	int work_done = 0;
+	unsigned int work_done = 0;
 	int tx_cleaned;
 
 	e100_rx_clean(nic, &work_done, budget);
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 10505de..0472638 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -3261,14 +3261,13 @@ e1000_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	unsigned int first, max_per_txd = E1000_MAX_DATA_PER_TXD;
 	unsigned int max_txd_pwr = E1000_MAX_TXD_PWR;
 	unsigned int tx_flags = 0;
-	unsigned int len = skb->len;
+	unsigned int len = skb->len - skb->data_len;
 	unsigned long flags;
-	unsigned int nr_frags = 0;
-	unsigned int mss = 0;
+	unsigned int nr_frags;
+	unsigned int mss;
 	int count = 0;
 	int tso;
 	unsigned int f;
-	len -= skb->data_len;
 
 	/* This goes back to the question of how to logically map a tx queue
 	 * to a flow.  Right now, performance is impacted slightly negatively
@@ -3302,7 +3301,7 @@ e1000_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 		* points to just header, pull a few bytes of payload from
 		* frags into skb->data */
 		hdr_len = skb_transport_offset(skb) + tcp_hdrlen(skb);
-		if (skb->data_len && (hdr_len == (skb->len - skb->data_len))) {
+		if (skb->data_len && hdr_len == len) {
 			switch (adapter->hw.mac_type) {
 				unsigned int pull_size;
 			case e1000_82544:
diff --git a/drivers/net/e1000e/ethtool.c b/drivers/net/e1000e/ethtool.c
index 2e8218f..b7a7e2a 100644
--- a/drivers/net/e1000e/ethtool.c
+++ b/drivers/net/e1000e/ethtool.c
@@ -301,6 +301,7 @@ static int e1000_set_pauseparam(struct net_device *netdev,
 	hw->mac.original_fc = hw->mac.fc;
 
 	if (adapter->fc_autoneg == AUTONEG_ENABLE) {
+		hw->mac.fc = e1000_fc_default;
 		if (netif_running(adapter->netdev)) {
 			e1000e_down(adapter);
 			e1000e_up(adapter);
diff --git a/drivers/net/e1000e/lib.c b/drivers/net/e1000e/lib.c
index 3bbfe60..0bdeca3 100644
--- a/drivers/net/e1000e/lib.c
+++ b/drivers/net/e1000e/lib.c
@@ -639,9 +639,15 @@ s32 e1000e_setup_link(struct e1000_hw *hw)
 	if (e1000_check_reset_block(hw))
 		return 0;
 
-	ret_val = e1000_set_default_fc_generic(hw);
-	if (ret_val)
-		return ret_val;
+	/*
+	 * If flow control is set to default, set flow control based on
+	 * the EEPROM flow control settings.
+	 */
+	if (mac->fc == e1000_fc_default) {
+		ret_val = e1000_set_default_fc_generic(hw);
+		if (ret_val)
+			return ret_val;
+	}
 
 	/* We want to save off the original Flow Control configuration just
 	 * in case we get disconnected and then reconnected into a different
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 3a0bb2a..033e124 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -3424,14 +3424,13 @@ static int e1000_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	unsigned int max_per_txd = E1000_MAX_PER_TXD;
 	unsigned int max_txd_pwr = E1000_MAX_TXD_PWR;
 	unsigned int tx_flags = 0;
-	unsigned int len = skb->len;
+	unsigned int len = skb->len - skb->data_len;
 	unsigned long irq_flags;
-	unsigned int nr_frags = 0;
-	unsigned int mss = 0;
+	unsigned int nr_frags;
+	unsigned int mss;
 	int count = 0;
 	int tso;
 	unsigned int f;
-	len -= skb->data_len;
 
 	if (test_bit(__E1000_DOWN, &adapter->state)) {
 		dev_kfree_skb_any(skb);
@@ -3459,7 +3458,7 @@ static int e1000_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 		* points to just header, pull a few bytes of payload from
 		* frags into skb->data */
 		hdr_len = skb_transport_offset(skb) + tcp_hdrlen(skb);
-		if (skb->data_len && (hdr_len == (skb->len - skb->data_len))) {
+		if (skb->data_len && (hdr_len == len)) {
 			unsigned int pull_size;
 
 			pull_size = min((unsigned int)4, skb->data_len);
@@ -4196,6 +4195,7 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 
 	/* Initialize link parameters. User can change them with ethtool */
 	adapter->hw.mac.autoneg = 1;
+	adapter->fc_autoneg = 1;
 	adapter->hw.mac.original_fc = e1000_fc_default;
 	adapter->hw.mac.fc = e1000_fc_default;
 	adapter->hw.phy.autoneg_advertised = 0x2f;
diff --git a/drivers/net/ehea/ehea.h b/drivers/net/ehea/ehea.h
index 3022089..ac21526 100644
--- a/drivers/net/ehea/ehea.h
+++ b/drivers/net/ehea/ehea.h
@@ -40,7 +40,7 @@
 #include <asm/io.h>
 
 #define DRV_NAME	"ehea"
-#define DRV_VERSION	"EHEA_0077"
+#define DRV_VERSION	"EHEA_0078"
 
 /* eHEA capability flags */
 #define DLPAR_PORT_ADD_REM 1
@@ -391,7 +391,6 @@ struct ehea_adapter {
 	struct ibmebus_dev *ebus_dev;
 	struct ehea_port *port[EHEA_MAX_PORTS];
 	struct ehea_eq *neq;       /* notification event queue */
-	struct workqueue_struct *ehea_wq;
 	struct tasklet_struct neq_tasklet;
 	struct ehea_mr mr;
 	u32 pd;                    /* protection domain */
diff --git a/drivers/net/ehea/ehea_main.c b/drivers/net/ehea/ehea_main.c
index 5bc0a15..2ba57e6 100644
--- a/drivers/net/ehea/ehea_main.c
+++ b/drivers/net/ehea/ehea_main.c
@@ -94,7 +94,6 @@ MODULE_PARM_DESC(use_lro, " Large Receive Offload, 1: enable, 0: disable, "
 static int port_name_cnt = 0;
 static LIST_HEAD(adapter_list);
 u64 ehea_driver_flags = 0;
-struct workqueue_struct *ehea_driver_wq;
 struct work_struct ehea_rereg_mr_task;
 
 struct semaphore dlpar_mem_lock;
@@ -421,7 +420,7 @@ static int ehea_treat_poll_error(struct ehea_port_res *pr, int rq,
 
 	if (cqe->status & EHEA_CQE_STAT_FAT_ERR_MASK) {
 		ehea_error("Critical receive error. Resetting port.");
-		queue_work(pr->port->adapter->ehea_wq, &pr->port->reset_task);
+		schedule_work(&pr->port->reset_task);
 		return 1;
 	}
 
@@ -596,8 +595,7 @@ static struct ehea_cqe *ehea_proc_cqes(struct ehea_port_res *pr, int my_quota)
 			ehea_error("Send Completion Error: Resetting port");
 			if (netif_msg_tx_err(pr->port))
 				ehea_dump(cqe, sizeof(*cqe), "Send CQE");
-			queue_work(pr->port->adapter->ehea_wq,
-				   &pr->port->reset_task);
+			schedule_work(&pr->port->reset_task);
 			break;
 		}
 
@@ -716,7 +714,7 @@ static irqreturn_t ehea_qp_aff_irq_handler(int irq, void *param)
 		eqe = ehea_poll_eq(port->qp_eq);
 	}
 
-	queue_work(port->adapter->ehea_wq, &port->reset_task);
+	schedule_work(&port->reset_task);
 
 	return IRQ_HANDLED;
 }
@@ -2395,7 +2393,7 @@ static int ehea_stop(struct net_device *dev)
 	if (netif_msg_ifdown(port))
 		ehea_info("disabling port %s", dev->name);
 
-	flush_workqueue(port->adapter->ehea_wq);
+	flush_scheduled_work();
 	down(&port->port_lock);
 	netif_stop_queue(dev);
 	ret = ehea_down(dev);
@@ -2710,7 +2708,7 @@ static void ehea_tx_watchdog(struct net_device *dev)
 
 	if (netif_carrier_ok(dev) &&
 	    !test_bit(__EHEA_STOP_XFER, &ehea_driver_flags))
-		queue_work(port->adapter->ehea_wq, &port->reset_task);
+		schedule_work(&port->reset_task);
 }
 
 int ehea_sense_adapter_attr(struct ehea_adapter *adapter)
@@ -3243,15 +3241,9 @@ static int __devinit ehea_probe_adapter(struct ibmebus_dev *dev,
 		goto out_kill_eq;
 	}
 
-	adapter->ehea_wq = create_workqueue("ehea_wq");
-	if (!adapter->ehea_wq) {
-		ret = -EIO;
-		goto out_free_irq;
-	}
-
 	ret = ehea_create_device_sysfs(dev);
 	if (ret)
-		goto out_kill_wq;
+		goto out_free_irq;
 
 	ret = ehea_setup_ports(adapter);
 	if (ret) {
@@ -3265,9 +3257,6 @@ static int __devinit ehea_probe_adapter(struct ibmebus_dev *dev,
 out_rem_dev_sysfs:
 	ehea_remove_device_sysfs(dev);
 
-out_kill_wq:
-	destroy_workqueue(adapter->ehea_wq);
-
 out_free_irq:
 	ibmebus_free_irq(NULL, adapter->neq->attr.ist1, adapter);
 
@@ -3293,7 +3282,7 @@ static int __devexit ehea_remove(struct ibmebus_dev *dev)
 
 	ehea_remove_device_sysfs(dev);
 
-	destroy_workqueue(adapter->ehea_wq);
+	flush_scheduled_work();
 
 	ibmebus_free_irq(NULL, adapter->neq->attr.ist1, adapter);
 	tasklet_kill(&adapter->neq_tasklet);
@@ -3351,7 +3340,6 @@ int __init ehea_module_init(void)
 	printk(KERN_INFO "IBM eHEA ethernet device driver (Release %s)\n",
 	       DRV_VERSION);
 
-	ehea_driver_wq = create_workqueue("ehea_driver_wq");
 
 	INIT_WORK(&ehea_rereg_mr_task, ehea_rereg_mrs);
 	sema_init(&dlpar_mem_lock, 1);
@@ -3385,7 +3373,7 @@ out:
 
 static void __exit ehea_module_exit(void)
 {
-	destroy_workqueue(ehea_driver_wq);
+	flush_scheduled_work();
 	driver_remove_file(&ehea_driver.driver, &driver_attr_capabilities);
 	ibmebus_unregister_driver(&ehea_driver);
 	ehea_destroy_busmap();
diff --git a/drivers/net/ehea/ehea_qmr.c b/drivers/net/ehea/ehea_qmr.c
index 329a252..83b7643 100644
--- a/drivers/net/ehea/ehea_qmr.c
+++ b/drivers/net/ehea/ehea_qmr.c
@@ -34,7 +34,6 @@
 
 struct ehea_busmap ehea_bmap = { 0, 0, NULL };
 extern u64 ehea_driver_flags;
-extern struct workqueue_struct *ehea_driver_wq;
 extern struct work_struct ehea_rereg_mr_task;
 
 
@@ -618,7 +617,7 @@ u64 ehea_map_vaddr(void *caddr)
 
 	if (unlikely(mapped_addr == -1))
 		if (!test_and_set_bit(__EHEA_STOP_XFER, &ehea_driver_flags))
-			queue_work(ehea_driver_wq, &ehea_rereg_mr_task);
+			schedule_work(&ehea_rereg_mr_task);
 
 	return mapped_addr;
 }
diff --git a/drivers/net/hamachi.c b/drivers/net/hamachi.c
index 015ed3a..ed407c8 100644
--- a/drivers/net/hamachi.c
+++ b/drivers/net/hamachi.c
@@ -1017,7 +1017,7 @@ static inline int hamachi_tx(struct net_device *dev)
 			break;
 		/* Free the original skb. */
 		skb = hmp->tx_skbuff[entry];
-		if (skb != 0) {
+		if (skb) {
 			pci_unmap_single(hmp->pci_dev,
 				hmp->tx_ring[entry].addr, skb->len,
 				PCI_DMA_TODEVICE);
@@ -1069,7 +1069,6 @@ static void hamachi_tx_timeout(struct net_device *dev)
 		   " resetting...\n", dev->name, (int)readw(ioaddr + TxStatus));
 
 	{
-		int i;
 		printk(KERN_DEBUG "  Rx ring %p: ", hmp->rx_ring);
 		for (i = 0; i < RX_RING_SIZE; i++)
 			printk(" %8.8x", (unsigned int)hmp->rx_ring[i].status_n_length);
diff --git a/drivers/net/ibm_emac/ibm_emac_mal.c b/drivers/net/ibm_emac/ibm_emac_mal.c
index cabd984..4e49e8c 100644
--- a/drivers/net/ibm_emac/ibm_emac_mal.c
+++ b/drivers/net/ibm_emac/ibm_emac_mal.c
@@ -207,10 +207,10 @@ static irqreturn_t mal_serr(int irq, void *dev_instance)
 
 static inline void mal_schedule_poll(struct ibm_ocp_mal *mal)
 {
-	if (likely(netif_rx_schedule_prep(&mal->poll_dev))) {
+	if (likely(napi_schedule_prep(&mal->napi))) {
 		MAL_DBG2("%d: schedule_poll" NL, mal->def->index);
 		mal_disable_eob_irq(mal);
-		__netif_rx_schedule(&mal->poll_dev);
+		__napi_schedule(&mal->napi);
 	} else
 		MAL_DBG2("%d: already in poll" NL, mal->def->index);
 }
@@ -273,11 +273,11 @@ static irqreturn_t mal_rxde(int irq, void *dev_instance)
 	return IRQ_HANDLED;
 }
 
-static int mal_poll(struct net_device *ndev, int *budget)
+static int mal_poll(struct napi_struct *napi, int budget)
 {
-	struct ibm_ocp_mal *mal = ndev->priv;
+	struct ibm_ocp_mal *mal = container_of(napi, struct ibm_ocp_mal, napi);
 	struct list_head *l;
-	int rx_work_limit = min(ndev->quota, *budget), received = 0, done;
+	int received = 0;
 
 	MAL_DBG2("%d: poll(%d) %d ->" NL, mal->def->index, *budget,
 		 rx_work_limit);
@@ -295,38 +295,34 @@ static int mal_poll(struct net_device *ndev, int *budget)
 	list_for_each(l, &mal->poll_list) {
 		struct mal_commac *mc =
 		    list_entry(l, struct mal_commac, poll_list);
-		int n = mc->ops->poll_rx(mc->dev, rx_work_limit);
+		int n = mc->ops->poll_rx(mc->dev, budget);
 		if (n) {
 			received += n;
-			rx_work_limit -= n;
-			if (rx_work_limit <= 0) {
-				done = 0;
+			budget -= n;
+			if (budget <= 0)
 				goto more_work;	// XXX What if this is the last one ?
-			}
 		}
 	}
 
 	/* We need to disable IRQs to protect from RXDE IRQ here */
 	local_irq_disable();
-	__netif_rx_complete(ndev);
+	__napi_complete(napi);
 	mal_enable_eob_irq(mal);
 	local_irq_enable();
 
-	done = 1;
-
 	/* Check for "rotting" packet(s) */
 	list_for_each(l, &mal->poll_list) {
 		struct mal_commac *mc =
 		    list_entry(l, struct mal_commac, poll_list);
 		if (unlikely(mc->ops->peek_rx(mc->dev) || mc->rx_stopped)) {
 			MAL_DBG2("%d: rotting packet" NL, mal->def->index);
-			if (netif_rx_reschedule(ndev, received))
+			if (napi_reschedule(napi))
 				mal_disable_eob_irq(mal);
 			else
 				MAL_DBG2("%d: already in poll list" NL,
 					 mal->def->index);
 
-			if (rx_work_limit > 0)
+			if (budget > 0)
 				goto again;
 			else
 				goto more_work;
@@ -335,12 +331,8 @@ static int mal_poll(struct net_device *ndev, int *budget)
 	}
 
       more_work:
-	ndev->quota -= received;
-	*budget -= received;
-
-	MAL_DBG2("%d: poll() %d <- %d" NL, mal->def->index, *budget,
-		 done ? 0 : 1);
-	return done ? 0 : 1;
+	MAL_DBG2("%d: poll() %d <- %d" NL, mal->def->index, budget, received);
+	return received;
 }
 
 static void mal_reset(struct ibm_ocp_mal *mal)
@@ -425,11 +417,8 @@ static int __init mal_probe(struct ocp_device *ocpdev)
 	mal->def = ocpdev->def;
 
 	INIT_LIST_HEAD(&mal->poll_list);
-	set_bit(__LINK_STATE_START, &mal->poll_dev.state);
-	mal->poll_dev.weight = CONFIG_IBM_EMAC_POLL_WEIGHT;
-	mal->poll_dev.poll = mal_poll;
-	mal->poll_dev.priv = mal;
-	atomic_set(&mal->poll_dev.refcnt, 1);
+	mal->napi.weight = CONFIG_IBM_EMAC_POLL_WEIGHT;
+	mal->napi.poll = mal_poll;
 
 	INIT_LIST_HEAD(&mal->list);
 
@@ -520,11 +509,8 @@ static void __exit mal_remove(struct ocp_device *ocpdev)
 
 	MAL_DBG("%d: remove" NL, mal->def->index);
 
-	/* Syncronize with scheduled polling, 
-	   stolen from net/core/dev.c:dev_close() 
-	 */
-	clear_bit(__LINK_STATE_START, &mal->poll_dev.state);
-	netif_poll_disable(&mal->poll_dev);
+	/* Synchronize with scheduled polling */
+	napi_disable(&mal->napi);
 
 	if (!list_empty(&mal->list)) {
 		/* This is *very* bad */
diff --git a/drivers/net/ibm_emac/ibm_emac_mal.h b/drivers/net/ibm_emac/ibm_emac_mal.h
index 64bc338..8f54d62 100644
--- a/drivers/net/ibm_emac/ibm_emac_mal.h
+++ b/drivers/net/ibm_emac/ibm_emac_mal.h
@@ -195,7 +195,7 @@ struct ibm_ocp_mal {
 	dcr_host_t		dcrhost;
 
 	struct list_head	poll_list;
-	struct net_device	poll_dev;
+	struct napi_struct	napi;
 
 	struct list_head	list;
 	u32			tx_chan_mask;
diff --git a/drivers/net/ibm_newemac/core.c b/drivers/net/ibm_newemac/core.c
index ce127b9..8ea5009 100644
--- a/drivers/net/ibm_newemac/core.c
+++ b/drivers/net/ibm_newemac/core.c
@@ -2549,7 +2549,6 @@ static int __devinit emac_probe(struct of_device *ofdev,
 	dev->ndev = ndev;
 	dev->ofdev = ofdev;
 	dev->blist = blist;
-	SET_MODULE_OWNER(ndev);
 	SET_NETDEV_DEV(ndev, &ofdev->dev);
 
 	/* Initialize some embedded data structures */
diff --git a/drivers/net/ibm_newemac/mal.c b/drivers/net/ibm_newemac/mal.c
index c4335b7..5885411 100644
--- a/drivers/net/ibm_newemac/mal.c
+++ b/drivers/net/ibm_newemac/mal.c
@@ -235,10 +235,10 @@ static irqreturn_t mal_serr(int irq, void *dev_instance)
 
 static inline void mal_schedule_poll(struct mal_instance *mal)
 {
-	if (likely(netif_rx_schedule_prep(&mal->poll_dev))) {
+	if (likely(napi_schedule_prep(&mal->napi))) {
 		MAL_DBG2(mal, "schedule_poll" NL);
 		mal_disable_eob_irq(mal);
-		__netif_rx_schedule(&mal->poll_dev);
+		__napi_schedule(&mal->napi);
 	} else
 		MAL_DBG2(mal, "already in poll" NL);
 }
@@ -318,8 +318,7 @@ void mal_poll_disable(struct mal_instance *mal, struct mal_commac *commac)
 		msleep(1);
 
 	/* Synchronize with the MAL NAPI poller. */
-	while (test_bit(__LINK_STATE_RX_SCHED, &mal->poll_dev.state))
-		msleep(1);
+	napi_disable(&mal->napi);
 }
 
 void mal_poll_enable(struct mal_instance *mal, struct mal_commac *commac)
@@ -330,11 +329,11 @@ void mal_poll_enable(struct mal_instance *mal, struct mal_commac *commac)
 	// XXX might want to kick a poll now...
 }
 
-static int mal_poll(struct net_device *ndev, int *budget)
+static int mal_poll(struct napi_struct *napi, int budget)
 {
-	struct mal_instance *mal = netdev_priv(ndev);
+	struct mal_instance *mal = container_of(napi, struct mal_instance, napi);
 	struct list_head *l;
-	int rx_work_limit = min(ndev->quota, *budget), received = 0, done;
+	int received = 0;
 	unsigned long flags;
 
 	MAL_DBG2(mal, "poll(%d) %d ->" NL, *budget,
@@ -358,26 +357,21 @@ static int mal_poll(struct net_device *ndev, int *budget)
 		int n;
 		if (unlikely(test_bit(MAL_COMMAC_POLL_DISABLED, &mc->flags)))
 			continue;
-		n = mc->ops->poll_rx(mc->dev, rx_work_limit);
+		n = mc->ops->poll_rx(mc->dev, budget);
 		if (n) {
 			received += n;
-			rx_work_limit -= n;
-			if (rx_work_limit <= 0) {
-				done = 0;
-				// XXX What if this is the last one ?
-				goto more_work;
-			}
+			budget -= n;
+			if (budget <= 0)
+				goto more_work; // XXX What if this is the last one ?
 		}
 	}
 
 	/* We need to disable IRQs to protect from RXDE IRQ here */
 	spin_lock_irqsave(&mal->lock, flags);
-	__netif_rx_complete(ndev);
+	__napi_complete(napi);
 	mal_enable_eob_irq(mal);
 	spin_unlock_irqrestore(&mal->lock, flags);
 
-	done = 1;
-
 	/* Check for "rotting" packet(s) */
 	list_for_each(l, &mal->poll_list) {
 		struct mal_commac *mc =
@@ -387,12 +381,12 @@ static int mal_poll(struct net_device *ndev, int *budget)
 		if (unlikely(mc->ops->peek_rx(mc->dev) ||
 			     test_bit(MAL_COMMAC_RX_STOPPED, &mc->flags))) {
 			MAL_DBG2(mal, "rotting packet" NL);
-			if (netif_rx_reschedule(ndev, received))
+			if (napi_reschedule(napi))
 				mal_disable_eob_irq(mal);
 			else
 				MAL_DBG2(mal, "already in poll list" NL);
 
-			if (rx_work_limit > 0)
+			if (budget > 0)
 				goto again;
 			else
 				goto more_work;
@@ -401,13 +395,8 @@ static int mal_poll(struct net_device *ndev, int *budget)
 	}
 
  more_work:
-	ndev->quota -= received;
-	*budget -= received;
-
-	MAL_DBG2(mal, "poll() %d <- %d" NL, *budget,
-		 done ? 0 : 1);
-
-	return done ? 0 : 1;
+	MAL_DBG2(mal, "poll() %d <- %d" NL, budget, received);
+	return received;
 }
 
 static void mal_reset(struct mal_instance *mal)
@@ -538,11 +527,8 @@ static int __devinit mal_probe(struct of_device *ofdev,
 	}
 
 	INIT_LIST_HEAD(&mal->poll_list);
-	set_bit(__LINK_STATE_START, &mal->poll_dev.state);
-	mal->poll_dev.weight = CONFIG_IBM_NEW_EMAC_POLL_WEIGHT;
-	mal->poll_dev.poll = mal_poll;
-	mal->poll_dev.priv = mal;
-	atomic_set(&mal->poll_dev.refcnt, 1);
+	mal->napi.weight = CONFIG_IBM_NEW_EMAC_POLL_WEIGHT;
+	mal->napi.poll = mal_poll;
 	INIT_LIST_HEAD(&mal->list);
 	spin_lock_init(&mal->lock);
 
@@ -653,11 +639,8 @@ static int __devexit mal_remove(struct of_device *ofdev)
 
 	MAL_DBG(mal, "remove" NL);
 
-	/* Syncronize with scheduled polling,
-	   stolen from net/core/dev.c:dev_close()
-	 */
-	clear_bit(__LINK_STATE_START, &mal->poll_dev.state);
-	netif_poll_disable(&mal->poll_dev);
+	/* Synchronize with scheduled polling */
+	napi_disable(&mal->napi);
 
 	if (!list_empty(&mal->list)) {
 		/* This is *very* bad */
diff --git a/drivers/net/ibm_newemac/mal.h b/drivers/net/ibm_newemac/mal.h
index 57b69dc..cb1a16d 100644
--- a/drivers/net/ibm_newemac/mal.h
+++ b/drivers/net/ibm_newemac/mal.h
@@ -197,7 +197,7 @@ struct mal_instance {
 	int			serr_irq;	/* MAL System Error IRQ    */
 
 	struct list_head	poll_list;
-	struct net_device	poll_dev;
+	struct napi_struct	napi;
 
 	struct list_head	list;
 	u32			tx_chan_mask;
diff --git a/drivers/net/natsemi.c b/drivers/net/natsemi.c
index ea38da6..527f9dc 100644
--- a/drivers/net/natsemi.c
+++ b/drivers/net/natsemi.c
@@ -108,7 +108,7 @@ static int full_duplex[MAX_UNITS];
 #define TX_TIMEOUT  (2*HZ)
 
 #define NATSEMI_HW_TIMEOUT	400
-#define NATSEMI_TIMER_FREQ	3*HZ
+#define NATSEMI_TIMER_FREQ	5*HZ
 #define NATSEMI_PG0_NREGS	64
 #define NATSEMI_RFDR_NREGS	8
 #define NATSEMI_PG1_NREGS	4
@@ -1615,7 +1615,7 @@ static void do_cable_magic(struct net_device *dev)
 		 * (these values all come from National)
 		 */
 		if (!(data & 0x80) || ((data >= 0xd8) && (data <= 0xff))) {
-			struct netdev_private *np = netdev_priv(dev);
+			np = netdev_priv(dev);
 
 			/* the bug has been triggered - fix the coefficient */
 			writew(TSTDAT_FIXED, ioaddr + TSTDAT);
@@ -1798,7 +1798,7 @@ static void netdev_timer(unsigned long data)
 	struct net_device *dev = (struct net_device *)data;
 	struct netdev_private *np = netdev_priv(dev);
 	void __iomem * ioaddr = ns_ioaddr(dev);
-	int next_tick = 5*HZ;
+	int next_tick = NATSEMI_TIMER_FREQ;
 
 	if (netif_msg_timer(np)) {
 		/* DO NOT read the IntrStatus register,
@@ -2502,8 +2502,8 @@ static void __set_rx_mode(struct net_device *dev)
 		memset(mc_filter, 0, sizeof(mc_filter));
 		for (i = 0, mclist = dev->mc_list; mclist && i < dev->mc_count;
 			 i++, mclist = mclist->next) {
-			int i = (ether_crc(ETH_ALEN, mclist->dmi_addr) >> 23) & 0x1ff;
-			mc_filter[i/8] |= (1 << (i & 0x07));
+			int b = (ether_crc(ETH_ALEN, mclist->dmi_addr) >> 23) & 0x1ff;
+			mc_filter[b/8] |= (1 << (b & 0x07));
 		}
 		rx_mode = RxFilterEnable | AcceptBroadcast
 			| AcceptMulticast | AcceptMyPhys;
diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index 203cc1e..22e4054 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -38,7 +38,7 @@
  * Tx descriptors that can be associated with each corresponding FIFO.
  * intr_type: This defines the type of interrupt. The values can be 0(INTA),
  *     2(MSI_X). Default value is '2(MSI_X)'
- * lro: Specifies whether to enable Large Receive Offload (LRO) or not.
+ * lro_enable: Specifies whether to enable Large Receive Offload (LRO) or not.
  *     Possible values '1' for enable '0' for disable. Default is '0'
  * lro_max_pkts: This parameter defines maximum number of packets can be
  *     aggregated as a single large packet
@@ -276,46 +276,46 @@ static char ethtool_driver_stats_keys[][ETH_GSTRING_LEN] = {
 	{"ring_5_full_cnt"},
 	{"ring_6_full_cnt"},
 	{"ring_7_full_cnt"},
-	("alarm_transceiver_temp_high"),
-	("alarm_transceiver_temp_low"),
-	("alarm_laser_bias_current_high"),
-	("alarm_laser_bias_current_low"),
-	("alarm_laser_output_power_high"),
-	("alarm_laser_output_power_low"),
-	("warn_transceiver_temp_high"),
-	("warn_transceiver_temp_low"),
-	("warn_laser_bias_current_high"),
-	("warn_laser_bias_current_low"),
-	("warn_laser_output_power_high"),
-	("warn_laser_output_power_low"),
-	("lro_aggregated_pkts"),
-	("lro_flush_both_count"),
-	("lro_out_of_sequence_pkts"),
-	("lro_flush_due_to_max_pkts"),
-	("lro_avg_aggr_pkts"),
-	("mem_alloc_fail_cnt"),
-	("pci_map_fail_cnt"),
-	("watchdog_timer_cnt"),
-	("mem_allocated"),
-	("mem_freed"),
-	("link_up_cnt"),
-	("link_down_cnt"),
-	("link_up_time"),
-	("link_down_time"),
-	("tx_tcode_buf_abort_cnt"),
-	("tx_tcode_desc_abort_cnt"),
-	("tx_tcode_parity_err_cnt"),
-	("tx_tcode_link_loss_cnt"),
-	("tx_tcode_list_proc_err_cnt"),
-	("rx_tcode_parity_err_cnt"),
-	("rx_tcode_abort_cnt"),
-	("rx_tcode_parity_abort_cnt"),
-	("rx_tcode_rda_fail_cnt"),
-	("rx_tcode_unkn_prot_cnt"),
-	("rx_tcode_fcs_err_cnt"),
-	("rx_tcode_buf_size_err_cnt"),
-	("rx_tcode_rxd_corrupt_cnt"),
-	("rx_tcode_unkn_err_cnt"),
+	{"alarm_transceiver_temp_high"},
+	{"alarm_transceiver_temp_low"},
+	{"alarm_laser_bias_current_high"},
+	{"alarm_laser_bias_current_low"},
+	{"alarm_laser_output_power_high"},
+	{"alarm_laser_output_power_low"},
+	{"warn_transceiver_temp_high"},
+	{"warn_transceiver_temp_low"},
+	{"warn_laser_bias_current_high"},
+	{"warn_laser_bias_current_low"},
+	{"warn_laser_output_power_high"},
+	{"warn_laser_output_power_low"},
+	{"lro_aggregated_pkts"},
+	{"lro_flush_both_count"},
+	{"lro_out_of_sequence_pkts"},
+	{"lro_flush_due_to_max_pkts"},
+	{"lro_avg_aggr_pkts"},
+	{"mem_alloc_fail_cnt"},
+	{"pci_map_fail_cnt"},
+	{"watchdog_timer_cnt"},
+	{"mem_allocated"},
+	{"mem_freed"},
+	{"link_up_cnt"},
+	{"link_down_cnt"},
+	{"link_up_time"},
+	{"link_down_time"},
+	{"tx_tcode_buf_abort_cnt"},
+	{"tx_tcode_desc_abort_cnt"},
+	{"tx_tcode_parity_err_cnt"},
+	{"tx_tcode_link_loss_cnt"},
+	{"tx_tcode_list_proc_err_cnt"},
+	{"rx_tcode_parity_err_cnt"},
+	{"rx_tcode_abort_cnt"},
+	{"rx_tcode_parity_abort_cnt"},
+	{"rx_tcode_rda_fail_cnt"},
+	{"rx_tcode_unkn_prot_cnt"},
+	{"rx_tcode_fcs_err_cnt"},
+	{"rx_tcode_buf_size_err_cnt"},
+	{"rx_tcode_rxd_corrupt_cnt"},
+	{"rx_tcode_unkn_err_cnt"},
 	{"tda_err_cnt"},
 	{"pfc_err_cnt"},
 	{"pcc_err_cnt"},
@@ -468,7 +468,9 @@ S2IO_PARM_INT(rxsync_frequency, 3);
 /* Interrupt type. Values can be 0(INTA), 2(MSI_X) */
 S2IO_PARM_INT(intr_type, 2);
 /* Large receive offload feature */
-S2IO_PARM_INT(lro, 0);
+static unsigned int lro_enable;
+module_param_named(lro, lro_enable, uint, 0);
+
 /* Max pkts to be aggregated by LRO at one time. If not specified,
  * aggregation happens until we hit max IP pkt size(64K)
  */
@@ -1759,7 +1761,7 @@ static void do_s2io_write_bits(u64 value, int flag, void __iomem *addr)
 	writeq(temp64, addr);
 }
 
-void en_dis_err_alarms(struct s2io_nic *nic, u16 mask, int flag)
+static void en_dis_err_alarms(struct s2io_nic *nic, u16 mask, int flag)
 {
 	struct XENA_dev_config __iomem *bar0 = nic->bar0;
 	register u64 gen_int_mask = 0;
@@ -4228,7 +4230,7 @@ static void s2io_txpic_intr_handle(struct s2io_nic *sp)
  *  1 - if alarm bit set
  *  0 - if alarm bit is not set
  */
-int do_s2io_chk_alarm_bit(u64 value, void __iomem * addr,
+static int do_s2io_chk_alarm_bit(u64 value, void __iomem * addr,
 			  unsigned long long *cnt)
 {
 	u64 val64;
@@ -7135,7 +7137,8 @@ static int rx_osm_handler(struct ring_info *ring_data, struct RxD_t * rxdp)
 				int ret = 0;
 
 				ret = s2io_club_tcp_session(skb->data, &tcp,
-						&tcp_len, &lro, rxdp, sp);
+							    &tcp_len, &lro,
+							    rxdp, sp);
 				switch (ret) {
 					case 3: /* Begin anew */
 						lro->parent = skb;
@@ -7451,7 +7454,7 @@ s2io_init_nic(struct pci_dev *pdev, const struct pci_device_id *pre)
 	else
 		sp->device_type = XFRAME_I_DEVICE;
 
-	sp->lro = lro;
+	sp->lro = lro_enable;
 
 	/* Initialize some PCI/PCI-X fields of the NIC. */
 	s2io_init_pci(sp);
@@ -7798,7 +7801,7 @@ static void __devexit s2io_rem_nic(struct pci_dev *pdev)
  * the module loadable parameters and initializes PCI configuration space.
  */
 
-int __init s2io_starter(void)
+static int __init s2io_starter(void)
 {
 	return pci_register_driver(&s2io_driver);
 }
diff --git a/drivers/net/tehuti.c b/drivers/net/tehuti.c
index 2483431..8d04654 100644
--- a/drivers/net/tehuti.c
+++ b/drivers/net/tehuti.c
@@ -750,7 +750,6 @@ bdx_vlan_rx_register(struct net_device *ndev, struct vlan_group *grp)
  */
 static int bdx_change_mtu(struct net_device *ndev, int new_mtu)
 {
-	BDX_ASSERT(ndev == 0);
 	ENTER;
 
 	if (new_mtu == ndev->mtu)
@@ -1002,7 +1001,7 @@ static inline void bdx_rxdb_free_elem(struct rxdb *db, int n)
 static int bdx_rx_init(struct bdx_priv *priv)
 {
 	ENTER;
-	BDX_ASSERT(priv == 0);
+
 	if (bdx_fifo_init(priv, &priv->rxd_fifo0.m, priv->rxd_size,
 			  regRXD_CFG0_0, regRXD_CFG1_0,
 			  regRXD_RPTR_0, regRXD_WPTR_0))
@@ -1747,7 +1746,6 @@ static void bdx_tx_cleanup(struct bdx_priv *priv)
 		tx_level -= db->rptr->len;	/* '-' koz len is negative */
 
 		/* now should come skb pointer - free it */
-		BDX_ASSERT(db->rptr->addr.skb == 0);
 		dev_kfree_skb_irq(db->rptr->addr.skb);
 		bdx_tx_db_inc_rptr(db);
 	}
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 91cd3f3..4848c7a 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -349,6 +349,16 @@ static inline void napi_schedule(struct napi_struct *n)
 		__napi_schedule(n);
 }
 
+/* Try to reschedule poll. Called by dev->poll() after napi_complete().  */
+static inline int napi_reschedule(struct napi_struct *napi)
+{
+	if (napi_schedule_prep(napi)) {
+		__napi_schedule(napi);
+		return 1;
+	}
+	return 0;
+}
+
 /**
  *	napi_complete - NAPI processing complete
  *	@n: napi context
