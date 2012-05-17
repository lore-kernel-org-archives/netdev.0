From: Samuel Thibault <samuel.thibault@ens-lyon.org>
Subject: [PATCH] e1000: Reset rx ring index on receive overrun
Date: Fri, 18 May 2012 01:01:40 +0200
Message-ID: <20120517230140.GZ683@type.famille.thibault.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Greg Rose <gregory.v.rose@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Alex Duyck <alexander.h.duyck@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jiri Pirko <jpirko@redhat.com>,
	Dean Nelson <dnelson@redhat.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

At high traffic rate, the rx ring may get completely filled before we
manage to consume it.  After it is filled, the kernel and device indexes
are not synchronized any more, so we have to reset them, otherwise the
kernel will be stuck waiting for the wrong slot to be filled.

Signed-off-by: Samuel Thibault <samuel.thibault@ens-lyon.org>

---
This is just a patch suggestion, I'm not an expert in network drivers, I
leave to actual driver authors to bake a better version.

diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/net/ethernet/intel/e1000/e1000_main.c
index 37caa88..77c8dbc 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_main.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
@@ -3759,6 +3759,21 @@ static irqreturn_t e1000_intr(int irq, void *data)
 	if (unlikely(test_bit(__E1000_DOWN, &adapter->flags)))
 		return IRQ_HANDLED;
 
+	if (unlikely(icr & E1000_ICR_RXO)) {
+		/* Receive Overrun */
+		u32 rctl;
+		int i;
+		rctl = er32(RCTL);
+		ew32(RCTL, rctl & ~E1000_RCTL_EN);
+		for (i = 0; i < adapter->num_rx_queues; i++) {
+			memset(adapter->rx_ring[i].desc, 0, adapter->rx_ring[i].size);
+			adapter->rx_ring[i].next_to_clean = 0;
+		}
+		ew32(RDH, 0);
+		ew32(RCTL, rctl);
+		adapter->netdev->stats.rx_fifo_errors++;
+	}
+
 	if (unlikely(icr & (E1000_ICR_RXSEQ | E1000_ICR_LSC))) {
 		hw->get_link_status = 1;
 		/* guard against interrupt when we're going down */
