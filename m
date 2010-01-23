From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 6/7] ixgbevf: Fix panics in the VF driver
Date: Sat, 23 Jan 2010 00:47:18 -0800
Message-ID: <20100123084717.9865.5467.stgit@localhost.localdomain>
References: <20100123084457.9865.51853.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Greg Rose <gregory.v.rose@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta03.emeryville.ca.mail.comcast.net ([76.96.30.32]:51618 "EHLO
	qmta03.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752636Ab0AWIrf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Jan 2010 03:47:35 -0500
In-Reply-To: <20100123084457.9865.51853.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

Fix panics in the VF driver that occur when you bring it down after
having already brought the PF down.

Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbevf/ixgbevf_main.c |   24 ++++++++++++++++++++----
 1 files changed, 20 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ixgbevf/ixgbevf_main.c b/drivers/net/ixgbevf/ixgbevf_main.c
index bd2fd46..0a27fa1 100644
--- a/drivers/net/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ixgbevf/ixgbevf_main.c
@@ -1693,8 +1693,10 @@ static void ixgbevf_clean_rx_ring(struct ixgbevf_adapter *adapter,
 	unsigned long size;
 	unsigned int i;
 
-	/* Free all the Rx ring sk_buffs */
+	if (!rx_ring->rx_buffer_info)
+		return;
 
+	/* Free all the Rx ring sk_buffs */
 	for (i = 0; i < rx_ring->count; i++) {
 		struct ixgbevf_rx_buffer *rx_buffer_info;
 
@@ -1751,6 +1753,9 @@ static void ixgbevf_clean_tx_ring(struct ixgbevf_adapter *adapter,
 	unsigned long size;
 	unsigned int i;
 
+	if (!tx_ring->tx_buffer_info)
+		return;
+
 	/* Free all the Tx ring sk_buffs */
 
 	for (i = 0; i < tx_ring->count; i++) {
@@ -1843,12 +1848,24 @@ void ixgbevf_down(struct ixgbevf_adapter *adapter)
 
 void ixgbevf_reinit_locked(struct ixgbevf_adapter *adapter)
 {
+	struct ixgbe_hw *hw = &adapter->hw;
+
 	WARN_ON(in_interrupt());
+
 	while (test_and_set_bit(__IXGBEVF_RESETTING, &adapter->state))
 		msleep(1);
 
-	ixgbevf_down(adapter);
-	ixgbevf_up(adapter);
+	/*
+	 * Check if PF is up before re-init.  If not then skip until
+	 * later when the PF is up and ready to service requests from
+	 * the VF via mailbox.  If the VF is up and running then the
+	 * watchdog task will continue to schedule reset tasks until
+	 * the PF is up and running.
+	 */
+	if (!hw->mac.ops.reset_hw(hw)) {
+		ixgbevf_down(adapter);
+		ixgbevf_up(adapter);
+	}
 
 	clear_bit(__IXGBEVF_RESETTING, &adapter->state);
 }
@@ -2423,7 +2440,6 @@ void ixgbevf_free_tx_resources(struct ixgbevf_adapter *adapter,
 {
 	struct pci_dev *pdev = adapter->pdev;
 
-
 	ixgbevf_clean_tx_ring(adapter, tx_ring);
 
 	vfree(tx_ring->tx_buffer_info);

