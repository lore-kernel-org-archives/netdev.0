From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH 3/4] e1000e: fix drv load issues
Date: Mon, 04 Aug 2008 17:21:40 -0700
Message-ID: <20080805002125.24137.2996.stgit@localhost.localdomain>
References: <20080805002030.24137.10360.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	akpm@linux-foundation.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:60280 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755389AbYHEAVl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Aug 2008 20:21:41 -0400
In-Reply-To: <20080805002030.24137.10360.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

a few people seem to have problems maintaining gigabit link
and it was root caused to an interaction between the managability
firmware on the host and the driver, not communicating.

The form of communication they use is the drv_load bit.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/netdev.c |   28 ++++++++++++----------------
 1 files changed, 12 insertions(+), 16 deletions(-)

diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 589e542..18f076c 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -2444,7 +2444,7 @@ void e1000e_reset(struct e1000_adapter *adapter)
 	 * For parts with AMT enabled, let the firmware know
 	 * that the network interface is in control
 	 */
-	if ((adapter->flags & FLAG_HAS_AMT) && e1000e_check_mng_mode(hw))
+	if (adapter->flags & FLAG_HAS_AMT)
 		e1000_get_hw_control(adapter);
 
 	ew32(WUC, 0);
@@ -2634,8 +2634,7 @@ static int e1000_open(struct net_device *netdev)
 	 * If AMT is enabled, let the firmware know that the network
 	 * interface is now open
 	 */
-	if ((adapter->flags & FLAG_HAS_AMT) &&
-	    e1000e_check_mng_mode(&adapter->hw))
+	if (adapter->flags & FLAG_HAS_AMT)
 		e1000_get_hw_control(adapter);
 
 	/*
@@ -2713,8 +2712,7 @@ static int e1000_close(struct net_device *netdev)
 	 * If AMT is enabled, let the firmware know that the network
 	 * interface is now closed
 	 */
-	if ((adapter->flags & FLAG_HAS_AMT) &&
-	    e1000e_check_mng_mode(&adapter->hw))
+	if (adapter->flags & FLAG_HAS_AMT)
 		e1000_release_hw_control(adapter);
 
 	return 0;
@@ -4030,7 +4028,7 @@ static int e1000_resume(struct pci_dev *pdev)
 	 * is up.  For all other cases, let the f/w know that the h/w is now
 	 * under the control of the driver.
 	 */
-	if (!(adapter->flags & FLAG_HAS_AMT) || !e1000e_check_mng_mode(&adapter->hw))
+	if (!(adapter->flags & FLAG_HAS_AMT))
 		e1000_get_hw_control(adapter);
 
 	return 0;
@@ -4149,8 +4147,7 @@ static void e1000_io_resume(struct pci_dev *pdev)
 	 * is up.  For all other cases, let the f/w know that the h/w is now
 	 * under the control of the driver.
 	 */
-	if (!(adapter->flags & FLAG_HAS_AMT) ||
-	    !e1000e_check_mng_mode(&adapter->hw))
+	if (!(adapter->flags & FLAG_HAS_AMT))
 		e1000_get_hw_control(adapter);
 
 }
@@ -4505,8 +4502,7 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 	 * is up.  For all other cases, let the f/w know that the h/w is now
 	 * under the control of the driver.
 	 */
-	if (!(adapter->flags & FLAG_HAS_AMT) ||
-	    !e1000e_check_mng_mode(&adapter->hw))
+	if (!(adapter->flags & FLAG_HAS_AMT))
 		e1000_get_hw_control(adapter);
 
 	/* tell the stack to leave us alone until e1000_open() is called */
@@ -4523,19 +4519,19 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 	return 0;
 
 err_register:
-err_hw_init:
-	e1000_release_hw_control(adapter);
+	if (!(adapter->flags & FLAG_HAS_AMT))
+		e1000_release_hw_control(adapter);
 err_eeprom:
 	if (!e1000_check_reset_block(&adapter->hw))
 		e1000_phy_hw_reset(&adapter->hw);
+err_hw_init:
 
-	if (adapter->hw.flash_address)
-		iounmap(adapter->hw.flash_address);
-
-err_flashmap:
 	kfree(adapter->tx_ring);
 	kfree(adapter->rx_ring);
 err_sw_init:
+	if (adapter->hw.flash_address)
+		iounmap(adapter->hw.flash_address);
+err_flashmap:
 	iounmap(adapter->hw.hw_addr);
 err_ioremap:
 	free_netdev(netdev);

