From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 12/12] i40e: Set XPS bit mask to zero in DCB mode
Date: Fri, 14 Nov 2014 22:08:35 -0800
Message-ID: <1416031715-32498-13-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1416031715-32498-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Neerav Parikh <neerav.parikh@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:35240 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754504AbaKOGIp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 15 Nov 2014 01:08:45 -0500
In-Reply-To: <1416031715-32498-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neerav Parikh <neerav.parikh@intel.com>

Due to DCBX configuration change if the VSI needs to use more than 1 TC;
it needs to disable the XPS maps that were set when operating in 1 TC mode.
Without disabling XPS the netdev layer will select queues based on those
settings and not use the TC queue mapping to make the queue selection.

This patch allows the driver to enable/disable the XPS based on the number
of TCs being enabled for the given VSI.

Change-ID: Idc4dec47a672d2a509f6d7fe11ed1ee65b4f0e08
Signed-off-by: Neerav Parikh <neerav.parikh@intel.com>
Tested-By: Jack Morgan <jack.morgan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 38 +++++++++++++++++++++++------
 1 file changed, 31 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 7651925..9c68236 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -2382,6 +2382,35 @@ static void i40e_vsi_free_rx_resources(struct i40e_vsi *vsi)
 }
 
 /**
+ * i40e_config_xps_tx_ring - Configure XPS for a Tx ring
+ * @ring: The Tx ring to configure
+ *
+ * This enables/disables XPS for a given Tx descriptor ring
+ * based on the TCs enabled for the VSI that ring belongs to.
+ **/
+static void i40e_config_xps_tx_ring(struct i40e_ring *ring)
+{
+	struct i40e_vsi *vsi = ring->vsi;
+	cpumask_var_t mask;
+
+	if (ring->q_vector && ring->netdev) {
+		/* Single TC mode enable XPS */
+		if (vsi->tc_config.numtc <= 1 &&
+		    !test_and_set_bit(__I40E_TX_XPS_INIT_DONE, &ring->state)) {
+			netif_set_xps_queue(ring->netdev,
+					    &ring->q_vector->affinity_mask,
+					    ring->queue_index);
+		} else if (alloc_cpumask_var(&mask, GFP_KERNEL)) {
+			/* Disable XPS to allow selection based on TC */
+			bitmap_zero(cpumask_bits(mask), nr_cpumask_bits);
+			netif_set_xps_queue(ring->netdev, mask,
+					    ring->queue_index);
+			free_cpumask_var(mask);
+		}
+	}
+}
+
+/**
  * i40e_configure_tx_ring - Configure a transmit ring context and rest
  * @ring: The Tx ring to configure
  *
@@ -2404,13 +2433,8 @@ static int i40e_configure_tx_ring(struct i40e_ring *ring)
 		ring->atr_sample_rate = 0;
 	}
 
-	/* initialize XPS */
-	if (ring->q_vector && ring->netdev &&
-	    vsi->tc_config.numtc <= 1 &&
-	    !test_and_set_bit(__I40E_TX_XPS_INIT_DONE, &ring->state))
-		netif_set_xps_queue(ring->netdev,
-				    &ring->q_vector->affinity_mask,
-				    ring->queue_index);
+	/* configure XPS */
+	i40e_config_xps_tx_ring(ring);
 
 	/* clear the context structure first */
 	memset(&tx_ctx, 0, sizeof(tx_ctx));
-- 
1.9.3
