From: Jesse Brandeburg <jesse.brandeburg@intel.com>
Subject: [PATCH 2.6.27-rc8 4/6] e1000e: drop stats lock
Date: Thu, 02 Oct 2008 16:33:35 -0700
Message-ID: <20081002233335.12556.10042.stgit@jbrandeb-bw.jf.intel.com>
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
Received: from mga01.intel.com ([192.55.52.88]:57967 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755524AbYJBXdg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Oct 2008 19:33:36 -0400
In-Reply-To: <20081002233314.12556.49143.stgit@jbrandeb-bw.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

the stats lock is left over from e1000, e1000e no longer
has the adjust tbi stats function that required the addition
of the stats lock to begin with.

adding a mutex to acquire_swflag helped catch this one too.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
CC: Thomas Gleixner <tglx@linutronix.de>
---

 drivers/net/e1000e/e1000.h  |    1 -
 drivers/net/e1000e/netdev.c |   18 ------------------
 2 files changed, 0 insertions(+), 19 deletions(-)

diff --git a/drivers/net/e1000e/e1000.h b/drivers/net/e1000e/e1000.h
index 8087bda..5ea6b60 100644
--- a/drivers/net/e1000e/e1000.h
+++ b/drivers/net/e1000e/e1000.h
@@ -257,7 +257,6 @@ struct e1000_adapter {
 	struct net_device *netdev;
 	struct pci_dev *pdev;
 	struct net_device_stats net_stats;
-	spinlock_t stats_lock;      /* prevent concurrent stats updates */
 
 	/* structs defined in e1000_hw.h */
 	struct e1000_hw hw;
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 835b692..01e9558 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -2600,8 +2600,6 @@ static int __devinit e1000_sw_init(struct e1000_adapter *adapter)
 	/* Explicitly disable IRQ since the NIC can be in any state. */
 	e1000_irq_disable(adapter);
 
-	spin_lock_init(&adapter->stats_lock);
-
 	set_bit(__E1000_DOWN, &adapter->state);
 	return 0;
 
@@ -2953,7 +2951,6 @@ void e1000e_update_stats(struct e1000_adapter *adapter)
 {
 	struct e1000_hw *hw = &adapter->hw;
 	struct pci_dev *pdev = adapter->pdev;
-	unsigned long irq_flags;
 
 	/*
 	 * Prevent stats update while adapter is being reset, or if the pci
@@ -2964,14 +2961,6 @@ void e1000e_update_stats(struct e1000_adapter *adapter)
 	if (pci_channel_offline(pdev))
 		return;
 
-	spin_lock_irqsave(&adapter->stats_lock, irq_flags);
-
-	/*
-	 * these counters are modified from e1000_adjust_tbi_stats,
-	 * called from the interrupt context, so they must only
-	 * be written while holding adapter->stats_lock
-	 */
-
 	adapter->stats.crcerrs += er32(CRCERRS);
 	adapter->stats.gprc += er32(GPRC);
 	adapter->stats.gorc += er32(GORCL);
@@ -3046,8 +3035,6 @@ void e1000e_update_stats(struct e1000_adapter *adapter)
 	adapter->stats.mgptc += er32(MGTPTC);
 	adapter->stats.mgprc += er32(MGTPRC);
 	adapter->stats.mgpdc += er32(MGTPDC);
-
-	spin_unlock_irqrestore(&adapter->stats_lock, irq_flags);
 }
 
 /**
@@ -3059,9 +3046,6 @@ static void e1000_phy_read_status(struct e1000_adapter *adapter)
 	struct e1000_hw *hw = &adapter->hw;
 	struct e1000_phy_regs *phy = &adapter->phy_regs;
 	int ret_val;
-	unsigned long irq_flags;
-
-	spin_lock_irqsave(&adapter->stats_lock, irq_flags);
 
 	if ((er32(STATUS) & E1000_STATUS_LU) &&
 	    (adapter->hw.phy.media_type == e1000_media_type_copper)) {
@@ -3092,8 +3076,6 @@ static void e1000_phy_read_status(struct e1000_adapter *adapter)
 		phy->stat1000 = 0;
 		phy->estatus = (ESTATUS_1000_TFULL | ESTATUS_1000_THALF);
 	}
-
-	spin_unlock_irqrestore(&adapter->stats_lock, irq_flags);
 }
 
 static void e1000_print_link_info(struct e1000_adapter *adapter)

