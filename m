From: Benjamin Poirier <bpoirier@suse.com>
Subject: [PATCH v3 4/4] e1000e: Fix msi-x interrupt automask
Date: Mon,  9 Nov 2015 15:50:21 -0800
Message-ID: <1447113021-1611-5-git-send-email-bpoirier@suse.com>
References: <1447113021-1611-1-git-send-email-bpoirier@suse.com>
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
	Frank Steiner <steiner-reg@bio.ifi.lmu.de>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Shannon Nelson <shannon.nelson@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Matthew Vick <matthew.vick@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Mitch Williams <mitch.a.williams@intel.com>,
	intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1447113021-1611-1-git-send-email-bpoirier@suse.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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
---
 drivers/net/ethernet/intel/e1000e/netdev.c | 11 +++++------
 1 file changed, 5 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index ed7cc8e..2a22ed7 100644
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
 
@@ -2018,12 +2021,8 @@ static void e1000_configure_msix(struct e1000_adapter *adapter)
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
2.6.2
