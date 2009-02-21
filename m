From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 2/2] ixgbe: fix for 82598 Si errata causing buffer
	overflow
Date: Sat, 21 Feb 2009 14:23:40 -0800
Message-ID: <20090221222339.6451.72721.stgit@lost.foo-projects.org>
References: <20090221222318.6451.16633.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta02.emeryville.ca.mail.comcast.net ([76.96.30.24]:51941 "EHLO
	QMTA02.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754193AbZBUWX7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Feb 2009 17:23:59 -0500
In-Reply-To: <20090221222318.6451.16633.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

The failure happens when an interrupt occurs and the driver is reading
EICR.  This read will cause a clear-by-read which leads to two TLP
being inserted in the PCIe retry buffer leading to an overflow of the
buffer and corruption of TLPs.

The solution is different depending where the reading of EICR takes place.

For ixgbe_msix_lsc() since we are in MSIX mode and know OCD is enabled a
clear-by-write is done instead of the normal clear-by-read.

For ixgbe_intr() 0xffffffff is written to EIMC before the read, masking the
interrupts.

Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |   17 ++++++++++++++++-
 1 files changed, 16 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index a935949..8fbd4c8 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -937,7 +937,16 @@ static irqreturn_t ixgbe_msix_lsc(int irq, void *data)
 	struct net_device *netdev = data;
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 	struct ixgbe_hw *hw = &adapter->hw;
-	u32 eicr = IXGBE_READ_REG(hw, IXGBE_EICR);
+	u32 eicr;
+
+	/*
+	 * Workaround for Silicon errata.  Use clear-by-write instead
+	 * of clear-by-read.  Reading with EICS will return the
+	 * interrupt causes without clearing, which later be done
+	 * with the write to EICR.
+	 */
+	eicr = IXGBE_READ_REG(hw, IXGBE_EICS);
+	IXGBE_WRITE_REG(hw, IXGBE_EICR, eicr);
 
 	if (eicr & IXGBE_EICR_LSC)
 		ixgbe_check_lsc(adapter);
@@ -1356,6 +1365,12 @@ static irqreturn_t ixgbe_intr(int irq, void *data)
 	struct ixgbe_hw *hw = &adapter->hw;
 	u32 eicr;
 
+	/*
+	 * Workaround for silicon errata.  Mask the interrupts
+	 * before the read of EICR.
+	 */
+	IXGBE_WRITE_REG(hw, IXGBE_EIMC, IXGBE_IRQ_CLEAR_MASK);
+
 	/* for NAPI, using EIAM to auto-mask tx/rx interrupt bits on read
 	 * therefore no explict interrupt disable is necessary */
 	eicr = IXGBE_READ_REG(hw, IXGBE_EICR);

