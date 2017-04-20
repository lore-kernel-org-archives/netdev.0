From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 14/14] i40e: use i40e_stop_rings_no_wait to implement PORT_SUSPENDED state
Date: Wed, 19 Apr 2017 18:57:50 -0700
Message-ID: <20170420015750.6828-15-jeffrey.t.kirsher@intel.com>
References: <20170420015750.6828-1-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga07.intel.com ([134.134.136.100]:20804 "EHLO mga07.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S939106AbdDTB6D (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 19 Apr 2017 21:58:03 -0400
In-Reply-To: <20170420015750.6828-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

This state bit was added as a way for DCB to avoid having to wait for
the queues to disable when handling LLDP events. The logic for this was
burried deep within stop Tx and stop Rx queue code. First, let's rename
it so that it does not appear to only affect Tx when infact it modifies
both Tx and Rx flow. Second we can move it up into the i40e_stop_rings()
function, and we can simply re-use the i40e_stop_rings_no_wait() so that
we don't have to bury the implementation as deep into the call stack.

An alternative might be to remove the state bit and instead attempt to
shut down everything directly in DCP flow. This, however, is not ideal
because it creates yet another separate shutdown routine that we'd have
to maintain. In the current implementation any changes will be made to
both flows.

Change-ID: I68e1ccb901af320862bca395e9c9746f08e8b17c
Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h      |  2 +-
 drivers/net/ethernet/intel/i40e/i40e_main.c | 16 ++++++----------
 2 files changed, 7 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index dfab7b030b67..70f9458f7a01 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -145,7 +145,7 @@ enum i40e_state_t {
 	__I40E_DOWN_REQUESTED,
 	__I40E_FD_FLUSH_REQUESTED,
 	__I40E_RESET_FAILED,
-	__I40E_PORT_TX_SUSPENDED,
+	__I40E_PORT_SUSPENDED,
 	__I40E_VF_DISABLE,
 };
 
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 2fe1fbdaafae..c001562f19b2 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -4008,10 +4008,6 @@ static int i40e_vsi_control_tx(struct i40e_vsi *vsi, bool enable)
 	for (i = 0; i < vsi->num_queue_pairs; i++, pf_q++) {
 		i40e_control_tx_q(pf, pf_q, enable);
 
-		/* Don't wait to disable when port Tx is suspended */
-		if (!enable && test_bit(__I40E_PORT_TX_SUSPENDED, &pf->state))
-			continue;
-
 		/* wait for the change to finish */
 		ret = i40e_pf_txq_wait(pf, pf_q, enable);
 		if (ret) {
@@ -4105,10 +4101,6 @@ static int i40e_vsi_control_rx(struct i40e_vsi *vsi, bool enable)
 	for (i = 0; i < vsi->num_queue_pairs; i++, pf_q++) {
 		i40e_control_rx_q(pf, pf_q, enable);
 
-		/* Don't wait to disable when port Tx is suspended */
-		if (!enable && test_bit(__I40E_PORT_TX_SUSPENDED, &pf->state))
-			continue;
-
 		/* wait for the change to finish */
 		ret = i40e_pf_rxq_wait(pf, pf_q, enable);
 		if (ret) {
@@ -4151,6 +4143,10 @@ int i40e_vsi_start_rings(struct i40e_vsi *vsi)
  **/
 void i40e_vsi_stop_rings(struct i40e_vsi *vsi)
 {
+	/* When port TX is suspended, don't wait */
+	if (test_bit(__I40E_PORT_SUSPENDED, &vsi->back->state))
+		return i40e_vsi_stop_rings_no_wait(vsi);
+
 	/* do rx first for enable and last for disable
 	 * Ignore return value, we need to shutdown whatever we can
 	 */
@@ -5948,7 +5944,7 @@ static int i40e_handle_lldp_event(struct i40e_pf *pf,
 	else
 		pf->flags &= ~I40E_FLAG_DCB_ENABLED;
 
-	set_bit(__I40E_PORT_TX_SUSPENDED, &pf->state);
+	set_bit(__I40E_PORT_SUSPENDED, &pf->state);
 	/* Reconfiguration needed quiesce all VSIs */
 	i40e_pf_quiesce_all_vsi(pf);
 
@@ -5957,7 +5953,7 @@ static int i40e_handle_lldp_event(struct i40e_pf *pf,
 
 	ret = i40e_resume_port_tx(pf);
 
-	clear_bit(__I40E_PORT_TX_SUSPENDED, &pf->state);
+	clear_bit(__I40E_PORT_SUSPENDED, &pf->state);
 	/* In case of error no point in resuming VSIs */
 	if (ret)
 		goto exit;
-- 
2.12.2
