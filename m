From: Benjamin Poirier <bpoirier@suse.com>
Subject: [PATCH 2/2] e1000e: Fix msi-x interrupt automask
Date: Thu, 22 Oct 2015 17:32:28 -0700
Message-ID: <1445560348-29872-3-git-send-email-bpoirier@suse.com>
References: <1445560348-29872-1-git-send-email-bpoirier@suse.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Shannon Nelson <shannon.nelson@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Matthew Vick <matthew.vick@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Mitch Williams <mitch.a.williams@intel.com>,
	intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:59369 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966060AbbJWAdV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Oct 2015 20:33:21 -0400
In-Reply-To: <1445560348-29872-1-git-send-email-bpoirier@suse.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since the introduction of 82574 support in e1000e, the driver has worked on
the assumption that msi-x interrupt generation is automatically disabled
after each irq. As it turns out, this is not the case. Currently, rx
interrupts can fire multiple times before and during napi processing. This
can be a problem for users because frames that arrive in a certain window
(after adapter->clean_rx() but before napi_complete_done() has cleared
NAPI_STATE_SCHED) generate an interrupt which does not lead to
napi_schedule(). These frames sit in the rx queue until another frame
arrives (a tcp retransmit for example).

While the EIAC and CTRL_EXT registers are properly configured for irq
automask, the modification of IAM in e1000_configure_msix() is what
prevents automask from working as intended.

This patch removes that erroneous write and fixes interrupt rearming for tx
and "other" interrupts. Since e1000_msix_other() reads ICR, all interrupts
must be rearmed in that function.

Reported-by: Frank Steiner <steiner-reg@bio.ifi.lmu.de>
Signed-off-by: Benjamin Poirier <bpoirier@suse.com>
---
 drivers/net/ethernet/intel/e1000e/netdev.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index a228167..8881256 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -1921,7 +1921,8 @@ static irqreturn_t e1000_msix_other(int __always_unused irq, void *data)
 
 no_link_interrupt:
 	if (!test_bit(__E1000_DOWN, &adapter->state))
-		ew32(IMS, E1000_IMS_LSC | E1000_IMS_OTHER);
+		ew32(IMS, adapter->eiac_mask | E1000_IMS_OTHER |
+		     E1000_IMS_LSC);
 
 	return IRQ_HANDLED;
 }
@@ -1940,6 +1941,9 @@ static irqreturn_t e1000_intr_msix_tx(int __always_unused irq, void *data)
 		/* Ring was not completely cleaned, so fire another interrupt */
 		ew32(ICS, tx_ring->ims_val);
 
+	if (!test_bit(__E1000_DOWN, &adapter->state))
+		ew32(IMS, E1000_IMS_TXQ0);
+
 	return IRQ_HANDLED;
 }
 
@@ -2027,11 +2031,7 @@ static void e1000_configure_msix(struct e1000_adapter *adapter)
 
 	/* enable MSI-X PBA support */
 	ctrl_ext = er32(CTRL_EXT);
-	ctrl_ext |= E1000_CTRL_EXT_PBA_CLR;
-
-	/* Auto-Mask Other interrupts upon ICR read */
-	ew32(IAM, ~E1000_EIAC_MASK_82574 | E1000_IMS_OTHER);
-	ctrl_ext |= E1000_CTRL_EXT_EIAME;
+	ctrl_ext |= E1000_CTRL_EXT_PBA_CLR | E1000_CTRL_EXT_EIAME;
 	ew32(CTRL_EXT, ctrl_ext);
 	e1e_flush();
 }
-- 
2.5.0
