From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 1/9] ixgb: fix smp polling race condition
Date: Fri, 26 May 2006 09:51:56 -0700
Message-ID: <20060526165156.30514.36444.stgit@gitlost.site>
References: <20060526165124.30514.78477.stgit@gitlost.site>
Cc: netdev@vger.kernel.org, "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
        "Kok, Auke" <auke-jan.h.kok@intel.com>,
        "Kok, Auke" <auke@foo-projects.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:27910 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S1751124AbWEZQqw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 May 2006 12:46:52 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20060526165124.30514.78477.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Moved interrupt masking to before requesting the interrupt from the OS.
Moved interrupt enable to after netif_poll_enable.  This fixes a racy
BUG() where polling would be running on another CPU at the same time
that netif_poll_enable would run.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
Signed-off-by: John Ronciak <john.ronciak@intel.com>
---

 drivers/net/ixgb/ixgb_main.c |    9 +++++----
 1 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index 0a0c876..954894b 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -247,6 +247,9 @@ ixgb_up(struct ixgb_adapter *adapter)
 	ixgb_configure_rx(adapter);
 	ixgb_alloc_rx_buffers(adapter);
 
+	/* disable interrupts and get the hardware into a known state */
+	IXGB_WRITE_REG(&adapter->hw, IMC, 0xffffffff);
+
 #ifdef CONFIG_PCI_MSI
 	{
 	boolean_t pcix = (IXGB_READ_REG(&adapter->hw, STATUS) & 
@@ -272,9 +275,6 @@ ixgb_up(struct ixgb_adapter *adapter)
 		return err;
 	}
 
-	/* disable interrupts and get the hardware into a known state */
-	IXGB_WRITE_REG(&adapter->hw, IMC, 0xffffffff);
-
 	if((hw->max_frame_size != max_frame) ||
 		(hw->max_frame_size !=
 		(IXGB_READ_REG(hw, MFS) >> IXGB_MFS_SHIFT))) {
@@ -295,11 +295,12 @@ ixgb_up(struct ixgb_adapter *adapter)
 	}
 
 	mod_timer(&adapter->watchdog_timer, jiffies);
-	ixgb_irq_enable(adapter);
 
 #ifdef CONFIG_IXGB_NAPI
 	netif_poll_enable(netdev);
 #endif
+	ixgb_irq_enable(adapter);
+
 	return 0;
 }
 



--
Auke Kok <auke-jan.h.kok@intel.com>
