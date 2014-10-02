From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 7/9] igb: remove blocking phy read from inside spinlock
Date: Thu,  2 Oct 2014 03:16:32 -0700
Message-ID: <1412244994-23636-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1412244994-23636-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bernhard Kaindl <bk-linux@use.startmail.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Todd Fujinaka <todd.fujinaka@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:25391 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751523AbaJBKQp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Oct 2014 06:16:45 -0400
In-Reply-To: <1412244994-23636-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bernhard Kaindl <bk-linux@use.startmail.com>

Remove a source of latency spikes (in my case up to 10ms) by not calling
code that uses mdelay() for feeding a phy statistic (rx errors for idle
symbols - not data -> idle_errors) while being called with a spinlock held.

As idle_errors isn't read, this patch only removes unused code and data.

Later, more complicated changes may be applied to address the spinlock and
allow for some PHY diagnostics by harvesting this PHY stats register fully.

This patch is designed to fix the issue and be safe for longterm/stable.

For the Intel e1000e driver, the same change was applied in 2008 with
commit 23033fad5be0 ("e1000e: remove phy read from inside spinlock").

The mdelay is triggered by HW/SW semaphores, thus it depends on the HW.

I've HW that triggers it even when idle. Others may trigger it only e.g.
when Ethernet ports aquire or loose the link or on ifconfig up / down.
We've noticed this first from delays in frame rx/tx due to the mdelay().

Example command for checking if the issue is triggered: cyclictest -Smp1
(Look for occasional "Max:" values > 4000 or use -b 4000 to stop if greater)

It was observed with I350 ports connected to other I350 ports, but not
if driver and EEPROM was modified to run the I350 in EEPROM-less mode.

phy_stats.idle_errors and .receive_errors (isn't touched) occupy 64 not
used bits in the adapter struct: Their allocation may be removed as well.

Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>
Cc: Todd Fujinaka <todd.fujinaka@intel.com>
Fixes: 12dcd86b75d5 ("igb: fix stats handling") (this added the spin_lock)
Signed-off-by: Bernhard Kaindl <bk-linux@use.startmail.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/e1000_hw.h |  5 -----
 drivers/net/ethernet/intel/igb/igb.h      |  1 -
 drivers/net/ethernet/intel/igb/igb_main.c | 12 ------------
 3 files changed, 18 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/e1000_hw.h b/drivers/net/ethernet/intel/igb/e1000_hw.h
index ce55ea5..2003b37 100644
--- a/drivers/net/ethernet/intel/igb/e1000_hw.h
+++ b/drivers/net/ethernet/intel/igb/e1000_hw.h
@@ -265,11 +265,6 @@ struct e1000_hw_stats {
 	u64 b2ogprc;
 };
 
-struct e1000_phy_stats {
-	u32 idle_errors;
-	u32 receive_errors;
-};
-
 struct e1000_host_mng_dhcp_cookie {
 	u32 signature;
 	u8  status;
diff --git a/drivers/net/ethernet/intel/igb/igb.h b/drivers/net/ethernet/intel/igb/igb.h
index 06102d1..82d891e 100644
--- a/drivers/net/ethernet/intel/igb/igb.h
+++ b/drivers/net/ethernet/intel/igb/igb.h
@@ -403,7 +403,6 @@ struct igb_adapter {
 	struct e1000_hw hw;
 	struct e1000_hw_stats stats;
 	struct e1000_phy_info phy_info;
-	struct e1000_phy_stats phy_stats;
 
 	u32 test_icr;
 	struct igb_ring test_tx_ring;
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 6cf0c17..2a4e6f1 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -5206,14 +5206,11 @@ void igb_update_stats(struct igb_adapter *adapter,
 	struct e1000_hw *hw = &adapter->hw;
 	struct pci_dev *pdev = adapter->pdev;
 	u32 reg, mpc;
-	u16 phy_tmp;
 	int i;
 	u64 bytes, packets;
 	unsigned int start;
 	u64 _bytes, _packets;
 
-#define PHY_IDLE_ERROR_COUNT_MASK 0x00FF
-
 	/* Prevent stats update while adapter is being reset, or if the pci
 	 * connection is down.
 	 */
@@ -5374,15 +5371,6 @@ void igb_update_stats(struct igb_adapter *adapter,
 
 	/* Tx Dropped needs to be maintained elsewhere */
 
-	/* Phy Stats */
-	if (hw->phy.media_type == e1000_media_type_copper) {
-		if ((adapter->link_speed == SPEED_1000) &&
-		   (!igb_read_phy_reg(hw, PHY_1000T_STATUS, &phy_tmp))) {
-			phy_tmp &= PHY_IDLE_ERROR_COUNT_MASK;
-			adapter->phy_stats.idle_errors += phy_tmp;
-		}
-	}
-
 	/* Management Stats */
 	adapter->stats.mgptc += rd32(E1000_MGTPTC);
 	adapter->stats.mgprc += rd32(E1000_MGTPRC);
-- 
1.9.3
