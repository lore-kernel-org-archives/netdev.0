From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/14] i40evf: track outstanding client request
Date: Sat, 11 Feb 2017 21:30:16 -0800
Message-ID: <20170212053028.98581-3-jeffrey.t.kirsher@intel.com>
References: <20170212053028.98581-1-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.43]:15779 "EHLO mga05.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750768AbdBLFab (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 12 Feb 2017 00:30:31 -0500
In-Reply-To: <20170212053028.98581-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

The iWarp client cannot continue until this operation has been completed
by the PF driver. Sleep (with timeout) until the reply from the PF
driver has been received.

Change-ID: I5dc41b857bba32d0218b7ce167b5da122dadf349
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40e_virtchnl.h   | 1 +
 drivers/net/ethernet/intel/i40evf/i40evf.h          | 1 +
 drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c | 4 ++++
 3 files changed, 6 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40evf/i40e_virtchnl.h b/drivers/net/ethernet/intel/i40evf/i40e_virtchnl.h
index fc374f8..d38a2b2 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_virtchnl.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_virtchnl.h
@@ -81,6 +81,7 @@ enum i40e_virtchnl_ops {
 	I40E_VIRTCHNL_OP_GET_STATS = 15,
 	I40E_VIRTCHNL_OP_FCOE = 16,
 	I40E_VIRTCHNL_OP_EVENT = 17, /* must ALWAYS be 17 */
+	I40E_VIRTCHNL_OP_CONFIG_IWARP_IRQ_MAP = 21,
 	I40E_VIRTCHNL_OP_CONFIG_RSS_KEY = 23,
 	I40E_VIRTCHNL_OP_CONFIG_RSS_LUT = 24,
 	I40E_VIRTCHNL_OP_GET_RSS_HENA_CAPS = 25,
diff --git a/drivers/net/ethernet/intel/i40evf/i40evf.h b/drivers/net/ethernet/intel/i40evf/i40evf.h
index fffe4cf..00c42d8 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf.h
+++ b/drivers/net/ethernet/intel/i40evf/i40evf.h
@@ -195,6 +195,7 @@ struct i40evf_adapter {
 	u64 hw_csum_rx_error;
 	u32 rx_desc_count;
 	int num_msix_vectors;
+	u32 client_pending;
 	struct msix_entry *msix_entries;
 
 	u32 flags;
diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c b/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c
index 2059a8e..bee58af 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c
@@ -999,6 +999,10 @@ void i40evf_virtchnl_completion(struct i40evf_adapter *adapter,
 		if (v_opcode != adapter->current_op)
 			return;
 		break;
+	case I40E_VIRTCHNL_OP_CONFIG_IWARP_IRQ_MAP:
+		adapter->client_pending &=
+				~(BIT(I40E_VIRTCHNL_OP_CONFIG_IWARP_IRQ_MAP));
+		break;
 	case I40E_VIRTCHNL_OP_GET_RSS_HENA_CAPS: {
 		struct i40e_virtchnl_rss_hena *vrh =
 			(struct i40e_virtchnl_rss_hena *)msg;
-- 
2.10.2
