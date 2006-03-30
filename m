From: linas@austin.ibm.com (Linas Vepstas)
Subject: [PATCH]: e1000: prevent statistics from getting garbled during reset.
Date: Thu, 30 Mar 2006 15:39:28 -0600
Message-ID: <20060330213928.GQ2172@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-pci@atrey.karlin.mff.cuni.cz,
	linuxppc-dev@ozlabs.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750987AbWC3Vju@vger.kernel.org>
To: john.ronciak@intel.com, jesse.brandeburg@intel.com,
	jeffrey.t.kirsher@intel.com
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Please review, sign-off/ack, and forward upstream.
--linas

[PATCH]: e1000: prevent statistics from getting garbled during reset.

If a PCI bus error/fault triggers a PCI bus reset, attempts to get the
ethernet packet count statistics from the hardware will fail, returning
garbage data upstream.  This patch skips statistics data collection
if the PCI device is not on the bus. 

This patch presumes that an earlier patch,
[PATCH] PCI Error Recovery: e1000 network device driver
has already been applied.

Signed-off-by: Linas Vepstas <linas@austin.ibm.com>

----
 drivers/net/e1000/e1000_main.c |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

Index: linux-2.6.16-git6/drivers/net/e1000/e1000_main.c
===================================================================
--- linux-2.6.16-git6.orig/drivers/net/e1000/e1000_main.c	2006-03-30 14:42:33.000000000 -0600
+++ linux-2.6.16-git6/drivers/net/e1000/e1000_main.c	2006-03-30 14:44:52.000000000 -0600
@@ -3069,13 +3069,17 @@ void
 e1000_update_stats(struct e1000_adapter *adapter)
 {
 	struct e1000_hw *hw = &adapter->hw;
+	struct pci_dev *pdev = adapter->pdev;
 	unsigned long flags;
 	uint16_t phy_tmp;
 
 #define PHY_IDLE_ERROR_COUNT_MASK 0x00FF
 
-	/* Prevent stats update while adapter is being reset */
-	if (adapter->link_speed == 0)
+	/* Prevent stats update while adapter is being reset, or if
+	 * the pci connection is down. */
+	if ((adapter->link_speed == 0) ||
+       ((pdev->error_state != 0) &&
+	    (pdev->error_state != pci_channel_io_normal)))
 		return;
 
 	spin_lock_irqsave(&adapter->stats_lock, flags);
