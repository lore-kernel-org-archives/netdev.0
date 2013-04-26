From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 4/8] ixgbe: fix EICR write in ixgbe_msix_other
Date: Thu, 25 Apr 2013 21:57:07 -0700
Message-ID: <1366952231-16727-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1366952231-16727-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	stable <stable@vger.kernel.org>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1366952231-16727-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jacob Keller <jacob.e.keller@intel.com>

Previously, the ixgbe_msix_other was writing the full 32bits of the set
interrupts, instead of only the ones which the ixgbe_msix_other is
handling. This resulted in a loss of performance when the X540's PPS feature is
enabled due to sometimes clearing queue interrupts which resulted in the driver
not getting the interrupt for cleaning the q_vector rings often enough. The fix
is to simply mask the lower 16bits off so that this handler does not write them
in the EICR, which causes them to remain high and be properly handled by the
clean_rings interrupt routine as normal.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Cc: stable <stable@vger.kernel.org>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 88f6737..d30fbdd 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -2454,6 +2454,16 @@ static irqreturn_t ixgbe_msix_other(int irq, void *data)
 	 * with the write to EICR.
 	 */
 	eicr = IXGBE_READ_REG(hw, IXGBE_EICS);
+
+	/* The lower 16bits of the EICR register are for the queue interrupts
+	 * which should be masked here in order to not accidently clear them if
+	 * the bits are high when ixgbe_msix_other is called. There is a race
+	 * condition otherwise which results in possible performance loss
+	 * especially if the ixgbe_msix_other interrupt is triggering
+	 * consistently (as it would when PPS is turned on for the X540 device)
+	 */
+	eicr &= 0xFFFF0000;
+
 	IXGBE_WRITE_REG(hw, IXGBE_EICR, eicr);
 
 	if (eicr & IXGBE_EICR_LSC)
-- 
1.7.11.7
