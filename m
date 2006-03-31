From: linas@austin.ibm.com (Linas Vepstas)
Subject: Re: [PATCH]: e1000: prevent statistics from getting garbled during reset.
Date: Fri, 31 Mar 2006 11:06:20 -0600
Message-ID: <20060331170620.GW2172@austin.ibm.com>
References: <20060330213928.GQ2172@austin.ibm.com> <20060331000208.GS2172@austin.ibm.com> <20060331054654.GA6632@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: john.ronciak@intel.com, jesse.brandeburg@intel.com,
	jeffrey.t.kirsher@intel.com, Jeff Garzik <jgarzik@pobox.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-pci@atrey.karlin.mff.cuni.cz, linuxppc-dev@ozlabs.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751428AbWCaRGY@vger.kernel.org>
To: Greg KH <greg@kroah.com>
Content-Disposition: inline
In-Reply-To: <20060331054654.GA6632@kroah.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 30, 2006 at 09:46:54PM -0800, Greg KH wrote:
> 
> (hint, use a tab...)

glurg.



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
 drivers/net/e1000/e1000_main.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletion(-)

Index: linux-2.6.16-git6/drivers/net/e1000/e1000_main.c
===================================================================
--- linux-2.6.16-git6.orig/drivers/net/e1000/e1000_main.c	2006-03-30 17:51:37.924162779 -0600
+++ linux-2.6.16-git6/drivers/net/e1000/e1000_main.c	2006-03-30 17:54:07.659188391 -0600
@@ -3069,14 +3069,18 @@ void
 e1000_update_stats(struct e1000_adapter *adapter)
 {
 	struct e1000_hw *hw = &adapter->hw;
+	struct pci_dev *pdev = adapter->pdev;
 	unsigned long flags;
 	uint16_t phy_tmp;
 
 #define PHY_IDLE_ERROR_COUNT_MASK 0x00FF
 
-	/* Prevent stats update while adapter is being reset */
+	/* Prevent stats update while adapter is being reset,
+	 * or if the pci connection is down. */
 	if (adapter->link_speed == 0)
 		return;
+	if (pdev->error_state && pdev->error_state != pci_channel_io_normal)
+		return;
 
 	spin_lock_irqsave(&adapter->stats_lock, flags);
 
