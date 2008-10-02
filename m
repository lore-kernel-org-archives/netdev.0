From: Jesse Brandeburg <jesse.brandeburg@intel.com>
Subject: [PATCH 2.6.27-rc8 3/6] e1000e: remove phy read from inside spinlock
Date: Thu, 02 Oct 2008 16:33:30 -0700
Message-ID: <20081002233330.12556.79763.stgit@jbrandeb-bw.jf.intel.com>
References: <20081002233314.12556.49143.stgit@jbrandeb-bw.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	tglx@linutronix.de, arjan@linux.intel.com, airlied@gmail.com,
	davem@davemloft.net, jeff@garzik.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Thomas Gleixner <tglx@linutronix.de>
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:65208 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755687AbYJBXdk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Oct 2008 19:33:40 -0400
In-Reply-To: <20081002233314.12556.49143.stgit@jbrandeb-bw.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

thanks to tglx, we're finding some interesting reentrancy issues.
this patch removes the phy read from inside a spinlock, paving
the way for removing the spinlock completely.  The phy read was
only feeding a statistic that wasn't used.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
CC: Thomas Gleixner <tglx@linutronix.de>
---

 drivers/net/e1000e/ethtool.c |    6 +++++-
 drivers/net/e1000e/netdev.c  |   13 -------------
 2 files changed, 5 insertions(+), 14 deletions(-)

diff --git a/drivers/net/e1000e/ethtool.c b/drivers/net/e1000e/ethtool.c
index 5ed8e13..33a3ff1 100644
--- a/drivers/net/e1000e/ethtool.c
+++ b/drivers/net/e1000e/ethtool.c
@@ -432,6 +432,10 @@ static void e1000_get_regs(struct net_device *netdev,
 	regs_buff[11] = er32(TIDV);
 
 	regs_buff[12] = adapter->hw.phy.type;  /* PHY type (IGP=1, M88=0) */
+
+	/* ethtool doesn't use anything past this point, so all this
+	 * code is likely legacy junk for apps that may or may not
+	 * exist */
 	if (hw->phy.type == e1000_phy_m88) {
 		e1e_rphy(hw, M88E1000_PHY_SPEC_STATUS, &phy_data);
 		regs_buff[13] = (u32)phy_data; /* cable length */
@@ -447,7 +451,7 @@ static void e1000_get_regs(struct net_device *netdev,
 		regs_buff[22] = adapter->phy_stats.receive_errors;
 		regs_buff[23] = regs_buff[13]; /* mdix mode */
 	}
-	regs_buff[21] = adapter->phy_stats.idle_errors;  /* phy idle errors */
+	regs_buff[21] = 0; /* was idle_errors */
 	e1e_rphy(hw, PHY_1000T_STATUS, &phy_data);
 	regs_buff[24] = (u32)phy_data;  /* phy local receiver status */
 	regs_buff[25] = regs_buff[24];  /* phy remote receiver status */
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 803545b..835b692 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -2954,9 +2954,6 @@ void e1000e_update_stats(struct e1000_adapter *adapter)
 	struct e1000_hw *hw = &adapter->hw;
 	struct pci_dev *pdev = adapter->pdev;
 	unsigned long irq_flags;
-	u16 phy_tmp;
-
-#define PHY_IDLE_ERROR_COUNT_MASK 0x00FF
 
 	/*
 	 * Prevent stats update while adapter is being reset, or if the pci
@@ -3045,15 +3042,6 @@ void e1000e_update_stats(struct e1000_adapter *adapter)
 
 	/* Tx Dropped needs to be maintained elsewhere */
 
-	/* Phy Stats */
-	if (hw->phy.media_type == e1000_media_type_copper) {
-		if ((adapter->link_speed == SPEED_1000) &&
-		   (!e1e_rphy(hw, PHY_1000T_STATUS, &phy_tmp))) {
-			phy_tmp &= PHY_IDLE_ERROR_COUNT_MASK;
-			adapter->phy_stats.idle_errors += phy_tmp;
-		}
-	}
-
 	/* Management Stats */
 	adapter->stats.mgptc += er32(MGTPTC);
 	adapter->stats.mgprc += er32(MGTPRC);
@@ -3073,7 +3061,6 @@ static void e1000_phy_read_status(struct e1000_adapter *adapter)
 	int ret_val;
 	unsigned long irq_flags;
 
-
 	spin_lock_irqsave(&adapter->stats_lock, irq_flags);
 
 	if ((er32(STATUS) & E1000_STATUS_LU) &&

