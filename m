From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: Re: [patch 4/8] e1000: prevent statistics from getting garbled during
 reset
Date: Fri, 09 Jun 2006 11:28:07 -0700
Message-ID: <4489BDB7.8000606@intel.com>
References: <200606090519.k595JiOL032023@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020605080108060107010109"
Cc: akpm@osdl.org, netdev@vger.kernel.org, linas@austin.ibm.com,
	jesse.brandeburg@intel.com, john.ronciak@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:52243 "EHLO
	azsmga101-1.ch.intel.com") by vger.kernel.org with ESMTP
	id S1030486AbWFIUPS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Jun 2006 16:15:18 -0400
To: jeff@garzik.org
In-Reply-To: <200606090519.k595JiOL032023@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------020605080108060107010109
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit


Ack,

Jeff, please pull this patch from:

    git://lost.foo-projects.org/~ahkok/git/netdev-2.6 upstream

which is against netdev-2.6#upstream cac925a4aab1b7233d3beb591f53498816058a08

Cheers,

Auke


---

Signed-off-by: Linas Vepstas <linas@austin.ibm.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Andrew Morton <akpm@osdl.org>
Acked-by: Auke Kok <auke-jan.h.kok@intel.com>

---
  e1000_main.c |    8 +++++++-
  1 files changed, 7 insertions(+), 1 deletion(-)


akpm@osdl.org wrote:
> From: Linas Vepstas <linas@austin.ibm.com>
> 
> If a PCI bus error/fault triggers a PCI bus reset, attempts to get the
> ethernet packet count statistics from the hardware will fail, returning
> garbage data upstream.  This patch skips statistics data collection if the
> PCI device is not on the bus.
[snip]


--------------020605080108060107010109
Content-Type: text/x-patch;
 name="e1000_prevent_garbled_stats_during_reset_linas.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename*0="e1000_prevent_garbled_stats_during_reset_linas.patch"

e1000: prevent statistics from garbling during bus resets

If a PCI bus error/fault triggers a PCI bus reset, attempts to get
the ethernet packet count statistics from the hardware will fail,
returning garbage data upstream.  This patch skips statistics data
collection if the PCI device is not on the bus.

Signed-off-by: Linas Vepstas <linas@austin.ibm.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Andrew Morton <akpm@osdl.org>
Acked-by: Auke Kok <auke-jan.h.kok@intel.com>

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 56c7492..a373ccb 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -3045,14 +3045,20 @@ void
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
 

--------------020605080108060107010109--
