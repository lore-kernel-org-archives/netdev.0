From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-NEXT PATCH 03/25] ixgb: fix bug in descriptor ring due to
	prefetch corruption
Date: Tue, 08 Jul 2008 15:51:17 -0700
Message-ID: <20080708225117.6925.15563.stgit@localhost.localdomain>
References: <20080708224858.6925.29725.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:46399 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753344AbYGHWvS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Jul 2008 18:51:18 -0400
In-Reply-To: <20080708224858.6925.29725.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

there was one more bug hidden in the prefetch routines in ixgb hardware
that force us to remove it completely.  Writebacks were being done on
descriptors with stale data due to internal hardware fifo corruption.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgb/ixgb_main.c |   27 ++++++---------------------
 1 files changed, 6 insertions(+), 21 deletions(-)

diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index 652c0ea..ecd5252 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -146,14 +146,6 @@ static int debug = DEFAULT_DEBUG_LEVEL_SHIFT;
 module_param(debug, int, 0);
 MODULE_PARM_DESC(debug, "Debug level (0=none,...,16=all)");
 
-/* some defines for controlling descriptor fetches in h/w */
-#define RXDCTL_WTHRESH_DEFAULT 15  /* chip writes back at this many or RXT0 */
-#define RXDCTL_PTHRESH_DEFAULT 0   /* chip considers prefech below
-                                    * this */
-#define RXDCTL_HTHRESH_DEFAULT 0   /* chip will only prefetch if tail
-                                    * is pushed this many descriptors
-                                    * from head */
-
 /**
  * ixgb_init_module - Driver Registration Routine
  *
@@ -839,7 +831,6 @@ ixgb_configure_rx(struct ixgb_adapter *adapter)
 	struct ixgb_hw *hw = &adapter->hw;
 	u32 rctl;
 	u32 rxcsum;
-	u32 rxdctl;
 
 	/* make sure receives are disabled while setting up the descriptors */
 
@@ -861,18 +852,12 @@ ixgb_configure_rx(struct ixgb_adapter *adapter)
 	IXGB_WRITE_REG(hw, RDH, 0);
 	IXGB_WRITE_REG(hw, RDT, 0);
 
-	/* set up pre-fetching of receive buffers so we get some before we
-	 * run out (default hardware behavior is to run out before fetching
-	 * more).  This sets up to fetch if HTHRESH rx descriptors are avail
-	 * and the descriptors in hw cache are below PTHRESH.  This avoids
-	 * the hardware behavior of fetching <=512 descriptors in a single
-	 * burst that pre-empts all other activity, usually causing fifo
-	 * overflows. */
-	/* use WTHRESH to burst write 16 descriptors or burst when RXT0 */
-	rxdctl = RXDCTL_WTHRESH_DEFAULT << IXGB_RXDCTL_WTHRESH_SHIFT |
-	         RXDCTL_HTHRESH_DEFAULT << IXGB_RXDCTL_HTHRESH_SHIFT |
-	         RXDCTL_PTHRESH_DEFAULT << IXGB_RXDCTL_PTHRESH_SHIFT;
-	IXGB_WRITE_REG(hw, RXDCTL, rxdctl);
+	/* due to the hardware errata with RXDCTL, we are unable to use any of
+	 * the performance enhancing features of it without causing other
+	 * subtle bugs, some of the bugs could include receive length
+	 * corruption at high data rates (WTHRESH > 0) and/or receive
+	 * descriptor ring irregularites (particularly in hardware cache) */
+	IXGB_WRITE_REG(hw, RXDCTL, 0);
 
 	/* Enable Receive Checksum Offload for TCP and UDP */
 	if (adapter->rx_csum) {

