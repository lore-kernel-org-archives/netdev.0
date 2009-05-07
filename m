From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 4/5] ixgbe: fix failing to log fan failures
Date: Thu, 07 May 2009 13:39:54 -0700
Message-ID: <20090507203954.19886.71138.stgit@localhost.localdomain>
References: <20090507203854.19886.54737.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta11.westchester.pa.mail.comcast.net ([76.96.59.211]:53170
	"EHLO QMTA11.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1762821AbZEGUkO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 May 2009 16:40:14 -0400
In-Reply-To: <20090507203854.19886.54737.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

We weren't logging the 82598AT fan failure if it occurred before (ixgbe_open)
as we hadn't sent up to catch the interrupt that event caused.

This patch checks for this failure in:
ixgbe_probe - So we can log the failure asap. We check right after we
set up the adapter->flags, which is when we know that we have a fan.
ixgbe_up_complete - To catch failures that may have happened between probe
and when we set up the interrupt that would normally detect the fan failure.

To enable all of this we need to initialize the adapter flag with
IXGBE_FLAG_FAN_FAIL_CAPABLE when the NIC contained a fan.

Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |   28 ++++++++++++++++++++++++++--
 1 files changed, 26 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 01d8b6b..4a316e9 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -2458,6 +2458,17 @@ static int ixgbe_up_complete(struct ixgbe_adapter *adapter)
 	ixgbe_irq_enable(adapter);
 
 	/*
+	 * If this adapter has a fan, check to see if we had a failure
+	 * before we enabled the interrupt.
+	 */
+	if (adapter->flags & IXGBE_FLAG_FAN_FAIL_CAPABLE) {
+		u32 esdp = IXGBE_READ_REG(hw, IXGBE_ESDP);
+		if (esdp & IXGBE_ESDP_SDP1)
+			DPRINTK(DRV, CRIT,
+				"Fan has stopped, replace the adapter\n");
+	}
+
+	/*
 	 * For hot-pluggable SFP+ devices, a new SFP+ module may have
 	 * arrived before interrupts were enabled.  We need to kick off
 	 * the SFP+ module setup first, then try to bring up link.
@@ -3382,9 +3393,11 @@ static int __devinit ixgbe_sw_init(struct ixgbe_adapter *adapter)
 	adapter->ring_feature[RING_F_RSS].indices = rss;
 	adapter->flags |= IXGBE_FLAG_RSS_ENABLED;
 	adapter->ring_feature[RING_F_DCB].indices = IXGBE_MAX_DCB_INDICES;
-	if (hw->mac.type == ixgbe_mac_82598EB)
+	if (hw->mac.type == ixgbe_mac_82598EB) {
+		if (hw->device_id == IXGBE_DEV_ID_82598AT)
+			adapter->flags |= IXGBE_FLAG_FAN_FAIL_CAPABLE;
 		adapter->max_msix_q_vectors = MAX_MSIX_Q_VECTORS_82598;
-	else if (hw->mac.type == ixgbe_mac_82599EB) {
+	} else if (hw->mac.type == ixgbe_mac_82599EB) {
 		adapter->max_msix_q_vectors = MAX_MSIX_Q_VECTORS_82599;
 		adapter->flags |= IXGBE_FLAG_RSC_CAPABLE;
 		adapter->flags |= IXGBE_FLAG_RSC_ENABLED;
@@ -4915,6 +4928,17 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 	if (err)
 		goto err_sw_init;
 
+	/*
+	 * If there is a fan on this device and it has failed log the
+	 * failure.
+	 */
+	if (adapter->flags & IXGBE_FLAG_FAN_FAIL_CAPABLE) {
+		u32 esdp = IXGBE_READ_REG(hw, IXGBE_ESDP);
+		if (esdp & IXGBE_ESDP_SDP1)
+			DPRINTK(PROBE, CRIT,
+				"Fan has stopped, replace the adapter\n");
+	}
+
 	/* reset_hw fills in the perm_addr as well */
 	err = hw->mac.ops.reset_hw(hw);
 	if (err == IXGBE_ERR_SFP_NOT_SUPPORTED) {

