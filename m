From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH 2/4] e1000e: reduce scope of some variables, remove unnecessary ones
Date: Sat, 22 Jan 2011 03:56:14 -0800
Message-ID: <1295697376-2984-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1295697376-2984-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:32805 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752733Ab1AVL4b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 22 Jan 2011 06:56:31 -0500
To: David Miller <davem@davemloft.net>
In-Reply-To: <1295697376-2984-1-git-send-email-jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Static analysis of the driver code found some variables for which the scope
can be reduced, or remove the variable altogether.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/e1000e/ethtool.c |    4 +--
 drivers/net/e1000e/ich8lan.c |    3 +-
 drivers/net/e1000e/lib.c     |    4 +-
 drivers/net/e1000e/netdev.c  |   45 ++++++++++++++++++++---------------------
 drivers/net/e1000e/phy.c     |    8 +++---
 5 files changed, 31 insertions(+), 33 deletions(-)

diff --git a/drivers/net/e1000e/ethtool.c b/drivers/net/e1000e/ethtool.c
index dfa44de..323fd12 100644
--- a/drivers/net/e1000e/ethtool.c
+++ b/drivers/net/e1000e/ethtool.c
@@ -1255,7 +1255,6 @@ static int e1000_integrated_phy_loopback(struct e1000_adapter *adapter)
 {
 	struct e1000_hw *hw = &adapter->hw;
 	u32 ctrl_reg = 0;
-	u32 stat_reg = 0;
 	u16 phy_reg = 0;
 	s32 ret_val = 0;
 
@@ -1363,8 +1362,7 @@ static int e1000_integrated_phy_loopback(struct e1000_adapter *adapter)
 		 * Set the ILOS bit on the fiber Nic if half duplex link is
 		 * detected.
 		 */
-		stat_reg = er32(STATUS);
-		if ((stat_reg & E1000_STATUS_FD) == 0)
+		if ((er32(STATUS) & E1000_STATUS_FD) == 0)
 			ctrl_reg |= (E1000_CTRL_ILOS | E1000_CTRL_SLU);
 	}
 
diff --git a/drivers/net/e1000e/ich8lan.c b/drivers/net/e1000e/ich8lan.c
index fb46974..232b42b 100644
--- a/drivers/net/e1000e/ich8lan.c
+++ b/drivers/net/e1000e/ich8lan.c
@@ -2104,7 +2104,6 @@ static s32 e1000_flash_cycle_init_ich8lan(struct e1000_hw *hw)
 {
 	union ich8_hws_flash_status hsfsts;
 	s32 ret_val = -E1000_ERR_NVM;
-	s32 i = 0;
 
 	hsfsts.regval = er16flash(ICH_FLASH_HSFSTS);
 
@@ -2140,6 +2139,8 @@ static s32 e1000_flash_cycle_init_ich8lan(struct e1000_hw *hw)
 		ew16flash(ICH_FLASH_HSFSTS, hsfsts.regval);
 		ret_val = 0;
 	} else {
+		s32 i = 0;
+
 		/*
 		 * Otherwise poll for sometime so the current
 		 * cycle has a chance to end before giving up.
diff --git a/drivers/net/e1000e/lib.c b/drivers/net/e1000e/lib.c
index 68aa174..96921de 100644
--- a/drivers/net/e1000e/lib.c
+++ b/drivers/net/e1000e/lib.c
@@ -1978,15 +1978,15 @@ static s32 e1000_ready_nvm_eeprom(struct e1000_hw *hw)
 {
 	struct e1000_nvm_info *nvm = &hw->nvm;
 	u32 eecd = er32(EECD);
-	u16 timeout = 0;
 	u8 spi_stat_reg;
 
 	if (nvm->type == e1000_nvm_eeprom_spi) {
+		u16 timeout = NVM_MAX_RETRY_SPI;
+
 		/* Clear SK and CS */
 		eecd &= ~(E1000_EECD_CS | E1000_EECD_SK);
 		ew32(EECD, eecd);
 		udelay(1);
-		timeout = NVM_MAX_RETRY_SPI;
 
 		/*
 		 * Read "Status Register" repeatedly until the LSB is cleared.
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 1c2f33d..5b916b0 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -2720,7 +2720,6 @@ static void e1000_setup_rctl(struct e1000_adapter *adapter)
 {
 	struct e1000_hw *hw = &adapter->hw;
 	u32 rctl, rfctl;
-	u32 psrctl = 0;
 	u32 pages = 0;
 
 	/* Workaround Si errata on 82579 - configure jumbo frame flow */
@@ -2819,6 +2818,8 @@ static void e1000_setup_rctl(struct e1000_adapter *adapter)
 		adapter->rx_ps_pages = 0;
 
 	if (adapter->rx_ps_pages) {
+		u32 psrctl = 0;
+
 		/* Configure extra packet-split registers */
 		rfctl = er32(RFCTL);
 		rfctl |= E1000_RFCTL_EXTEN;
@@ -3020,7 +3021,6 @@ static void e1000_set_multi(struct net_device *netdev)
 	struct netdev_hw_addr *ha;
 	u8  *mta_list;
 	u32 rctl;
-	int i;
 
 	/* Check for Promiscuous and All Multicast modes */
 
@@ -3043,12 +3043,13 @@ static void e1000_set_multi(struct net_device *netdev)
 	ew32(RCTL, rctl);
 
 	if (!netdev_mc_empty(netdev)) {
+		int i = 0;
+
 		mta_list = kmalloc(netdev_mc_count(netdev) * 6, GFP_ATOMIC);
 		if (!mta_list)
 			return;
 
 		/* prepare a packed array of only addresses. */
-		i = 0;
 		netdev_for_each_mc_addr(ha, netdev)
 			memcpy(mta_list + (i++ * ETH_ALEN), ha->addr, ETH_ALEN);
 
@@ -3999,10 +4000,11 @@ static void e1000_phy_read_status(struct e1000_adapter *adapter)
 {
 	struct e1000_hw *hw = &adapter->hw;
 	struct e1000_phy_regs *phy = &adapter->phy_regs;
-	int ret_val;
 
 	if ((er32(STATUS) & E1000_STATUS_LU) &&
 	    (adapter->hw.phy.media_type == e1000_media_type_copper)) {
+		int ret_val;
+
 		ret_val  = e1e_rphy(hw, PHY_CONTROL, &phy->bmcr);
 		ret_val |= e1e_rphy(hw, PHY_STATUS, &phy->bmsr);
 		ret_val |= e1e_rphy(hw, PHY_AUTONEG_ADV, &phy->advertise);
@@ -4148,7 +4150,6 @@ static void e1000_watchdog_task(struct work_struct *work)
 	struct e1000_ring *tx_ring = adapter->tx_ring;
 	struct e1000_hw *hw = &adapter->hw;
 	u32 link, tctl;
-	int tx_pending = 0;
 
 	link = e1000e_has_link(adapter);
 	if ((netif_carrier_ok(netdev)) && link) {
@@ -4302,21 +4303,18 @@ link_up:
 
 	e1000e_update_adaptive(&adapter->hw);
 
-	if (!netif_carrier_ok(netdev)) {
-		tx_pending = (e1000_desc_unused(tx_ring) + 1 <
-			       tx_ring->count);
-		if (tx_pending) {
-			/*
-			 * We've lost link, so the controller stops DMA,
-			 * but we've got queued Tx work that's never going
-			 * to get done, so reset controller to flush Tx.
-			 * (Do the reset outside of interrupt context).
-			 */
-			adapter->tx_timeout_count++;
-			schedule_work(&adapter->reset_task);
-			/* return immediately since reset is imminent */
-			return;
-		}
+	if (!netif_carrier_ok(netdev) &&
+	    (e1000_desc_unused(tx_ring) + 1 < tx_ring->count)) {
+		/*
+		 * We've lost link, so the controller stops DMA,
+		 * but we've got queued Tx work that's never going
+		 * to get done, so reset controller to flush Tx.
+		 * (Do the reset outside of interrupt context).
+		 */
+		adapter->tx_timeout_count++;
+		schedule_work(&adapter->reset_task);
+		/* return immediately since reset is imminent */
+		return;
 	}
 
 	/* Simple mode for Interrupt Throttle Rate (ITR) */
@@ -4387,13 +4385,13 @@ static int e1000_tso(struct e1000_adapter *adapter,
 	u32 cmd_length = 0;
 	u16 ipcse = 0, tucse, mss;
 	u8 ipcss, ipcso, tucss, tucso, hdr_len;
-	int err;
 
 	if (!skb_is_gso(skb))
 		return 0;
 
 	if (skb_header_cloned(skb)) {
-		err = pskb_expand_head(skb, 0, 0, GFP_ATOMIC);
+		int err = pskb_expand_head(skb, 0, 0, GFP_ATOMIC);
+
 		if (err)
 			return err;
 	}
@@ -5518,9 +5516,10 @@ static irqreturn_t e1000_intr_msix(int irq, void *data)
 {
 	struct net_device *netdev = data;
 	struct e1000_adapter *adapter = netdev_priv(netdev);
-	int vector, msix_irq;
 
 	if (adapter->msix_entries) {
+		int vector, msix_irq;
+
 		vector = 0;
 		msix_irq = adapter->msix_entries[vector].vector;
 		disable_irq(msix_irq);
diff --git a/drivers/net/e1000e/phy.c b/drivers/net/e1000e/phy.c
index 6bea051..6ae31fc 100644
--- a/drivers/net/e1000e/phy.c
+++ b/drivers/net/e1000e/phy.c
@@ -2409,9 +2409,7 @@ static u32 e1000_get_phy_addr_for_bm_page(u32 page, u32 reg)
 s32 e1000e_write_phy_reg_bm(struct e1000_hw *hw, u32 offset, u16 data)
 {
 	s32 ret_val;
-	u32 page_select = 0;
 	u32 page = offset >> IGP_PAGE_SHIFT;
-	u32 page_shift = 0;
 
 	ret_val = hw->phy.ops.acquire(hw);
 	if (ret_val)
@@ -2427,6 +2425,8 @@ s32 e1000e_write_phy_reg_bm(struct e1000_hw *hw, u32 offset, u16 data)
 	hw->phy.addr = e1000_get_phy_addr_for_bm_page(page, offset);
 
 	if (offset > MAX_PHY_MULTI_PAGE_REG) {
+		u32 page_shift, page_select;
+
 		/*
 		 * Page select is register 31 for phy address 1 and 22 for
 		 * phy address 2 and 3. Page select is shifted only for
@@ -2468,9 +2468,7 @@ out:
 s32 e1000e_read_phy_reg_bm(struct e1000_hw *hw, u32 offset, u16 *data)
 {
 	s32 ret_val;
-	u32 page_select = 0;
 	u32 page = offset >> IGP_PAGE_SHIFT;
-	u32 page_shift = 0;
 
 	ret_val = hw->phy.ops.acquire(hw);
 	if (ret_val)
@@ -2486,6 +2484,8 @@ s32 e1000e_read_phy_reg_bm(struct e1000_hw *hw, u32 offset, u16 *data)
 	hw->phy.addr = e1000_get_phy_addr_for_bm_page(page, offset);
 
 	if (offset > MAX_PHY_MULTI_PAGE_REG) {
+		u32 page_shift, page_select;
+
 		/*
 		 * Page select is register 31 for phy address 1 and 22 for
 		 * phy address 2 and 3. Page select is shifted only for
-- 
1.7.3.4

