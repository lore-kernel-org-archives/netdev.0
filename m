From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 9/9] e1000e: Fix msi-x interrupt automask
Date: Mon, 14 Dec 2015 21:38:44 -0800
Message-ID: <1450157924-58901-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1450157924-58901-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Benjamin Poirier <bpoirier@suse.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:59689 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751588AbbLOFiu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Dec 2015 00:38:50 -0500
In-Reply-To: <1450157924-58901-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Benjamin Poirier <bpoirier@suse.com>

Since the introduction of 82574 support in e1000e, the driver has worked
on the assumption that msi-x interrupt generation is automatically
disabled after each irq. As it turns out, this is not the case.
Currently, rx interrupts can fire multiple times before and during napi
processing. This can be a problem for users because frames that arrive
in a certain window (after adapter->clean_rx() but before
napi_complete_done() has cleared NAPI_STATE_SCHED) generate an interrupt
which does not lead to napi_schedule(). These frames sit in the rx queue
until another frame arrives (a tcp retransmit for example).

While the EIAC and CTRL_EXT registers are properly configured for irq
automask, the modification of IAM in e1000_configure_msix() is what
prevents automask from working as intended.

This patch removes that erroneous write and fixes interrupt rearming for
tx interrupts. It also clears IAME from CTRL_EXT. This is not strictly
necessary for operation of the driver but it is to avoid disruption from
potential programs that access the registers directly, like `ethregs -c`.

Reported-by: Frank Steiner <steiner-reg@bio.ifi.lmu.de>
Signed-off-by: Benjamin Poirier <bpoirier@suse.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/netdev.c | 11 +++++------
 1 file changed, 5 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index d59c0bc..c71ba1b 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -1931,6 +1931,9 @@ static irqreturn_t e1000_intr_msix_tx(int __always_unused irq, void *data)
 		/* Ring was not completely cleaned, so fire another interrupt */
 		ew32(ICS, tx_ring->ims_val);
 
+	if (!test_bit(__E1000_DOWN, &adapter->state))
+		ew32(IMS, adapter->tx_ring->ims_val);
+
 	return IRQ_HANDLED;
 }
 
@@ -2020,12 +2023,8 @@ static void e1000_configure_msix(struct e1000_adapter *adapter)
 	ew32(IVAR, ivar);
 
 	/* enable MSI-X PBA support */
-	ctrl_ext = er32(CTRL_EXT);
-	ctrl_ext |= E1000_CTRL_EXT_PBA_CLR;
-
-	/* Auto-Mask Other interrupts upon ICR read */
-	ew32(IAM, ~E1000_EIAC_MASK_82574 | E1000_IMS_OTHER);
-	ctrl_ext |= E1000_CTRL_EXT_EIAME;
+	ctrl_ext = er32(CTRL_EXT) & ~E1000_CTRL_EXT_IAME;
+	ctrl_ext |= E1000_CTRL_EXT_PBA_CLR | E1000_CTRL_EXT_EIAME;
 	ew32(CTRL_EXT, ctrl_ext);
 	e1e_flush();
 }
-- 
2.5.0
