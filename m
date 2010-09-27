From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6 10/17] ixgbe: Use
 netif_set_real_num_{rx,tx}_queues()
Date: Mon, 27 Sep 2010 19:28:56 +0100
Message-ID: <1285612136.2263.306.camel@achroite.uk.solarflarecom.com>
References: <1285611791.2263.287.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com,
	PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	e1000-devel <e1000-devel@lists.sourceforge.net>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Alex Duyck <alexander.h.duyck@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:51832 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757189Ab0I0S3A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Sep 2010 14:29:00 -0400
In-Reply-To: <1285611791.2263.287.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ixgbe/ixgbe_main.c |   16 +++++++++++-----
 1 files changed, 11 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 4e0ce91..c35185c 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -4088,7 +4088,7 @@ static inline bool ixgbe_set_sriov_queues(struct ixgbe_adapter *adapter)
  * fallthrough conditions.
  *
  **/
-static void ixgbe_set_num_queues(struct ixgbe_adapter *adapter)
+static int ixgbe_set_num_queues(struct ixgbe_adapter *adapter)
 {
 	/* Start with base case */
 	adapter->num_rx_queues = 1;
@@ -4097,7 +4097,7 @@ static void ixgbe_set_num_queues(struct ixgbe_adapter *adapter)
 	adapter->num_rx_queues_per_pool = 1;
 
 	if (ixgbe_set_sriov_queues(adapter))
-		return;
+		goto done;
 
 #ifdef IXGBE_FCOE
 	if (ixgbe_set_fcoe_queues(adapter))
@@ -4120,8 +4120,10 @@ static void ixgbe_set_num_queues(struct ixgbe_adapter *adapter)
 	adapter->num_tx_queues = 1;
 
 done:
-	/* Notify the stack of the (possibly) reduced Tx Queue count. */
+	/* Notify the stack of the (possibly) reduced queue counts. */
 	netif_set_real_num_tx_queues(adapter->netdev, adapter->num_tx_queues);
+	return netif_set_real_num_rx_queues(adapter->netdev,
+					    adapter->num_rx_queues);
 }
 
 static void ixgbe_acquire_msix_vectors(struct ixgbe_adapter *adapter,
@@ -4550,7 +4552,9 @@ static int ixgbe_set_interrupt_capability(struct ixgbe_adapter *adapter)
 	if (adapter->flags & IXGBE_FLAG_SRIOV_ENABLED)
 		ixgbe_disable_sriov(adapter);
 
-	ixgbe_set_num_queues(adapter);
+	err = ixgbe_set_num_queues(adapter);
+	if (err)
+		return err;
 
 	err = pci_enable_msi(adapter->pdev);
 	if (!err) {
@@ -4675,7 +4679,9 @@ int ixgbe_init_interrupt_scheme(struct ixgbe_adapter *adapter)
 	int err;
 
 	/* Number of supported queues */
-	ixgbe_set_num_queues(adapter);
+	err = ixgbe_set_num_queues(adapter);
+	if (err)
+		return err;
 
 	err = ixgbe_set_interrupt_capability(adapter);
 	if (err) {
-- 
1.7.2.1



-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

