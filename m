From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 12/16] i40evf: handle many MAC filters correctly
Date: Tue, 24 Nov 2015 16:04:42 -0800
Message-ID: <1448409886-90686-13-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1448409886-90686-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:62192 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754990AbbKYAEz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Nov 2015 19:04:55 -0500
In-Reply-To: <1448409886-90686-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

When a lot (many hundreds) of MAC or VLAN filters are added at one time,
we can overflow the Admin Queue buffer size with all the requests.
Unfortunately, the driver would then calculate the message size
incorrectly, causing it to be rejected by the PF. Furthermore, there was
no mechanism to trigger another request to allow for configuring the
rest of the filters that didn't fit into the first request.

To fix this, recalculate the correct buffer size when we detect the
overflow condition instead of just assuming the max buffer size. Also,
don't clear the request bit in adapter->aq_required when we have an
overflow, so that the rest of the filters can be processed later.

Change-ID: Idd7cbbc5af31315e0dcb1b10e6a02ad9817ce65c
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 .../net/ethernet/intel/i40evf/i40evf_virtchnl.c    | 32 ++++++++++++++++------
 1 file changed, 24 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c b/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c
index 091ef6a..46b0516 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c
@@ -391,6 +391,7 @@ void i40evf_add_ether_addrs(struct i40evf_adapter *adapter)
 	struct i40e_virtchnl_ether_addr_list *veal;
 	int len, i = 0, count = 0;
 	struct i40evf_mac_filter *f;
+	bool more = false;
 
 	if (adapter->current_op != I40E_VIRTCHNL_OP_UNKNOWN) {
 		/* bail because we already have a command pending */
@@ -415,7 +416,9 @@ void i40evf_add_ether_addrs(struct i40evf_adapter *adapter)
 		count = (I40EVF_MAX_AQ_BUF_SIZE -
 			 sizeof(struct i40e_virtchnl_ether_addr_list)) /
 			sizeof(struct i40e_virtchnl_ether_addr);
-		len = I40EVF_MAX_AQ_BUF_SIZE;
+		len = sizeof(struct i40e_virtchnl_ether_addr_list) +
+		      (count * sizeof(struct i40e_virtchnl_ether_addr));
+		more = true;
 	}
 
 	veal = kzalloc(len, GFP_ATOMIC);
@@ -431,7 +434,8 @@ void i40evf_add_ether_addrs(struct i40evf_adapter *adapter)
 			f->add = false;
 		}
 	}
-	adapter->aq_required &= ~I40EVF_FLAG_AQ_ADD_MAC_FILTER;
+	if (!more)
+		adapter->aq_required &= ~I40EVF_FLAG_AQ_ADD_MAC_FILTER;
 	i40evf_send_pf_msg(adapter, I40E_VIRTCHNL_OP_ADD_ETHER_ADDRESS,
 			   (u8 *)veal, len);
 	kfree(veal);
@@ -450,6 +454,7 @@ void i40evf_del_ether_addrs(struct i40evf_adapter *adapter)
 	struct i40e_virtchnl_ether_addr_list *veal;
 	struct i40evf_mac_filter *f, *ftmp;
 	int len, i = 0, count = 0;
+	bool more = false;
 
 	if (adapter->current_op != I40E_VIRTCHNL_OP_UNKNOWN) {
 		/* bail because we already have a command pending */
@@ -474,7 +479,9 @@ void i40evf_del_ether_addrs(struct i40evf_adapter *adapter)
 		count = (I40EVF_MAX_AQ_BUF_SIZE -
 			 sizeof(struct i40e_virtchnl_ether_addr_list)) /
 			sizeof(struct i40e_virtchnl_ether_addr);
-		len = I40EVF_MAX_AQ_BUF_SIZE;
+		len = sizeof(struct i40e_virtchnl_ether_addr_list) +
+		      (count * sizeof(struct i40e_virtchnl_ether_addr));
+		more = true;
 	}
 	veal = kzalloc(len, GFP_ATOMIC);
 	if (!veal)
@@ -490,7 +497,8 @@ void i40evf_del_ether_addrs(struct i40evf_adapter *adapter)
 			kfree(f);
 		}
 	}
-	adapter->aq_required &= ~I40EVF_FLAG_AQ_DEL_MAC_FILTER;
+	if (!more)
+		adapter->aq_required &= ~I40EVF_FLAG_AQ_DEL_MAC_FILTER;
 	i40evf_send_pf_msg(adapter, I40E_VIRTCHNL_OP_DEL_ETHER_ADDRESS,
 			   (u8 *)veal, len);
 	kfree(veal);
@@ -509,6 +517,7 @@ void i40evf_add_vlans(struct i40evf_adapter *adapter)
 	struct i40e_virtchnl_vlan_filter_list *vvfl;
 	int len, i = 0, count = 0;
 	struct i40evf_vlan_filter *f;
+	bool more = false;
 
 	if (adapter->current_op != I40E_VIRTCHNL_OP_UNKNOWN) {
 		/* bail because we already have a command pending */
@@ -534,7 +543,9 @@ void i40evf_add_vlans(struct i40evf_adapter *adapter)
 		count = (I40EVF_MAX_AQ_BUF_SIZE -
 			 sizeof(struct i40e_virtchnl_vlan_filter_list)) /
 			sizeof(u16);
-		len = I40EVF_MAX_AQ_BUF_SIZE;
+		len = sizeof(struct i40e_virtchnl_vlan_filter_list) +
+		      (count * sizeof(u16));
+		more = true;
 	}
 	vvfl = kzalloc(len, GFP_ATOMIC);
 	if (!vvfl)
@@ -549,7 +560,8 @@ void i40evf_add_vlans(struct i40evf_adapter *adapter)
 			f->add = false;
 		}
 	}
-	adapter->aq_required &= ~I40EVF_FLAG_AQ_ADD_VLAN_FILTER;
+	if (!more)
+		adapter->aq_required &= ~I40EVF_FLAG_AQ_ADD_VLAN_FILTER;
 	i40evf_send_pf_msg(adapter, I40E_VIRTCHNL_OP_ADD_VLAN, (u8 *)vvfl, len);
 	kfree(vvfl);
 }
@@ -567,6 +579,7 @@ void i40evf_del_vlans(struct i40evf_adapter *adapter)
 	struct i40e_virtchnl_vlan_filter_list *vvfl;
 	struct i40evf_vlan_filter *f, *ftmp;
 	int len, i = 0, count = 0;
+	bool more = false;
 
 	if (adapter->current_op != I40E_VIRTCHNL_OP_UNKNOWN) {
 		/* bail because we already have a command pending */
@@ -592,7 +605,9 @@ void i40evf_del_vlans(struct i40evf_adapter *adapter)
 		count = (I40EVF_MAX_AQ_BUF_SIZE -
 			 sizeof(struct i40e_virtchnl_vlan_filter_list)) /
 			sizeof(u16);
-		len = I40EVF_MAX_AQ_BUF_SIZE;
+		len = sizeof(struct i40e_virtchnl_vlan_filter_list) +
+		      (count * sizeof(u16));
+		more = true;
 	}
 	vvfl = kzalloc(len, GFP_ATOMIC);
 	if (!vvfl)
@@ -608,7 +623,8 @@ void i40evf_del_vlans(struct i40evf_adapter *adapter)
 			kfree(f);
 		}
 	}
-	adapter->aq_required &= ~I40EVF_FLAG_AQ_DEL_VLAN_FILTER;
+	if (!more)
+		adapter->aq_required &= ~I40EVF_FLAG_AQ_DEL_VLAN_FILTER;
 	i40evf_send_pf_msg(adapter, I40E_VIRTCHNL_OP_DEL_VLAN, (u8 *)vvfl, len);
 	kfree(vvfl);
 }
-- 
2.5.0
