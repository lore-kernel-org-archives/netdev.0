From: akpm@osdl.org
Subject: [patch 6/9] e1000: prevent statistics from getting garbled during reset
Date: Thu, 27 Apr 2006 02:30:40 -0700
Message-ID: <200604270932.k3R9W8Uo025324@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@osdl.org, linas@austin.ibm.com,
	jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	john.ronciak@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:19407 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S965027AbWD0JcS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2006 05:32:18 -0400
To: jeff@garzik.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


From: Linas Vepstas <linas@austin.ibm.com>

If a PCI bus error/fault triggers a PCI bus reset, attempts to get the
ethernet packet count statistics from the hardware will fail, returning
garbage data upstream.  This patch skips statistics data collection if the
PCI device is not on the bus.

This patch presumes that an earlier patch,
[PATCH] PCI Error Recovery: e1000 network device driver
has already been applied.

Signed-off-by: Linas Vepstas <linas@austin.ibm.com>
Cc: John Ronciak <john.ronciak@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Cc: Jeff Garzik <jeff@garzik.org>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 drivers/net/e1000/e1000_main.c |    8 +++++++-
 1 files changed, 7 insertions(+), 1 deletion(-)

diff -puN drivers/net/e1000/e1000_main.c~e1000-prevent-statistics-from-getting-garbled-during-reset drivers/net/e1000/e1000_main.c
--- devel/drivers/net/e1000/e1000_main.c~e1000-prevent-statistics-from-getting-garbled-during-reset	2006-04-14 23:41:34.000000000 -0700
+++ devel-akpm/drivers/net/e1000/e1000_main.c	2006-04-14 23:41:34.000000000 -0700
@@ -3082,14 +3082,20 @@ void
 e1000_update_stats(struct e1000_adapter *adapter)
 {
 	struct e1000_hw *hw = &adapter->hw;
+	struct pci_dev *pdev = adapter->pdev;
 	unsigned long flags;
 	uint16_t phy_tmp;
 
 #define PHY_IDLE_ERROR_COUNT_MASK 0x00FF
 
-	/* Prevent stats update while adapter is being reset */
+	/*
+	 * Prevent stats update while adapter is being reset, or if the pci
+	 * connection is down.
+	 */
 	if (adapter->link_speed == 0)
 		return;
+	if (pdev->error_state && pdev->error_state != pci_channel_io_normal)
+		return;
 
 	spin_lock_irqsave(&adapter->stats_lock, flags);
 
_
