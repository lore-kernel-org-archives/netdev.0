From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/15] i40e: add VF capabilities to virtual channel interface
Date: Thu, 23 Jul 2015 06:52:37 -0700
Message-ID: <1437659564-48822-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1437659564-48822-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:10490 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752153AbbGWNww (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Jul 2015 09:52:52 -0400
In-Reply-To: <1437659564-48822-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

To prepare for the changes coming up in the X722 device and future
devices, the virtual channel interface has to change slightly. The VF
driver can now report what its capable of supporting, which then informs
the PF driver when it sends the configuration information back to the
VF.

A 1.1 VF driver on a 1.0 PF driver should not send its capabilities.
Likewise, a 1.1 PF driver controlling a 1.0 VF driver should not expect
or depend upon receiving the VF capabilities.

All other aspects of the API are unchanged.

Change-ID: I530cc55f107edd1ee8bdf95830aa90b87854058a
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Acked-by: Shannon Nelson <shannon.nelson@intel.com>
Acked-by: Anjali Singhai <anjali.singhai@intel.com>
Tested-by: Jim Young <james.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl.h   | 16 +++++++++++-----
 drivers/net/ethernet/intel/i40evf/i40e_virtchnl.h | 16 +++++++++++-----
 2 files changed, 22 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl.h b/drivers/net/ethernet/intel/i40e/i40e_virtchnl.h
index 2d20af2..a7ab463 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl.h
@@ -110,7 +110,9 @@ struct i40e_virtchnl_msg {
  * error regardless of version mismatch.
  */
 #define I40E_VIRTCHNL_VERSION_MAJOR		1
-#define I40E_VIRTCHNL_VERSION_MINOR		0
+#define I40E_VIRTCHNL_VERSION_MINOR		1
+#define I40E_VIRTCHNL_VERSION_MINOR_NO_VF_CAPS	0
+
 struct i40e_virtchnl_version_info {
 	u32 major;
 	u32 minor;
@@ -129,7 +131,8 @@ struct i40e_virtchnl_version_info {
  */
 
 /* I40E_VIRTCHNL_OP_GET_VF_RESOURCES
- * VF sends this request to PF with no parameters
+ * Version 1.0 VF sends this request to PF with no parameters
+ * Version 1.1 VF sends this request to PF with u32 bitmap of its capabilities
  * PF responds with an indirect message containing
  * i40e_virtchnl_vf_resource and one or more
  * i40e_virtchnl_vsi_resource structures.
@@ -143,9 +146,12 @@ struct i40e_virtchnl_vsi_resource {
 	u8 default_mac_addr[ETH_ALEN];
 };
 /* VF offload flags */
-#define I40E_VIRTCHNL_VF_OFFLOAD_L2	0x00000001
-#define I40E_VIRTCHNL_VF_OFFLOAD_FCOE	0x00000004
-#define I40E_VIRTCHNL_VF_OFFLOAD_VLAN	0x00010000
+#define I40E_VIRTCHNL_VF_OFFLOAD_L2		0x00000001
+#define I40E_VIRTCHNL_VF_OFFLOAD_IWARP		0x00000002
+#define I40E_VIRTCHNL_VF_OFFLOAD_FCOE		0x00000004
+#define I40E_VIRTCHNL_VF_OFFLOAD_RSS_AQ		0x00000008
+#define I40E_VIRTCHNL_VF_OFFLOAD_RSS_REG	0x00000010
+#define I40E_VIRTCHNL_VF_OFFLOAD_VLAN		0x00010000
 
 struct i40e_virtchnl_vf_resource {
 	u16 num_vsis;
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_virtchnl.h b/drivers/net/ethernet/intel/i40evf/i40e_virtchnl.h
index 59f62f0..1e89dea 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_virtchnl.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_virtchnl.h
@@ -110,7 +110,9 @@ struct i40e_virtchnl_msg {
  * error regardless of version mismatch.
  */
 #define I40E_VIRTCHNL_VERSION_MAJOR		1
-#define I40E_VIRTCHNL_VERSION_MINOR		0
+#define I40E_VIRTCHNL_VERSION_MINOR		1
+#define I40E_VIRTCHNL_VERSION_MINOR_NO_VF_CAPS	0
+
 struct i40e_virtchnl_version_info {
 	u32 major;
 	u32 minor;
@@ -129,7 +131,8 @@ struct i40e_virtchnl_version_info {
  */
 
 /* I40E_VIRTCHNL_OP_GET_VF_RESOURCES
- * VF sends this request to PF with no parameters
+ * Version 1.0 VF sends this request to PF with no parameters
+ * Version 1.1 VF sends this request to PF with u32 bitmap of its capabilities
  * PF responds with an indirect message containing
  * i40e_virtchnl_vf_resource and one or more
  * i40e_virtchnl_vsi_resource structures.
@@ -143,9 +146,12 @@ struct i40e_virtchnl_vsi_resource {
 	u8 default_mac_addr[ETH_ALEN];
 };
 /* VF offload flags */
-#define I40E_VIRTCHNL_VF_OFFLOAD_L2	0x00000001
-#define I40E_VIRTCHNL_VF_OFFLOAD_FCOE	0x00000004
-#define I40E_VIRTCHNL_VF_OFFLOAD_VLAN	0x00010000
+#define I40E_VIRTCHNL_VF_OFFLOAD_L2		0x00000001
+#define I40E_VIRTCHNL_VF_OFFLOAD_IWARP		0x00000002
+#define I40E_VIRTCHNL_VF_OFFLOAD_FCOE		0x00000004
+#define I40E_VIRTCHNL_VF_OFFLOAD_RSS_AQ		0x00000008
+#define I40E_VIRTCHNL_VF_OFFLOAD_RSS_REG	0x00000010
+#define I40E_VIRTCHNL_VF_OFFLOAD_VLAN		0x00010000
 
 struct i40e_virtchnl_vf_resource {
 	u16 num_vsis;
-- 
2.4.3
