From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 12/15] i40evf: support virtual channel API version 1.1
Date: Thu, 23 Jul 2015 06:52:41 -0700
Message-ID: <1437659564-48822-13-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1437659564-48822-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:10490 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752859AbbGWNw7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Jul 2015 09:52:59 -0400
In-Reply-To: <1437659564-48822-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

Store off the PF's API version, then use it to determine whether or not
to send it our capabilities. Change the version checking to allow for PF
drivers with lower API versions than our current version, so we can
still talk to PF drivers over the 1.0 API.

Change-ID: I8edc55d1229c7decf0ed3f285a63032694007c2e
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Jim young <james.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf_main.c     | 6 ++++++
 drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c | 7 +++++--
 2 files changed, 11 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index 7b90371..f43ac9c 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -2113,6 +2113,12 @@ static void i40evf_init_task(struct work_struct *work)
 		if (err) {
 			if (err == I40E_ERR_ADMIN_QUEUE_NO_WORK)
 				err = i40evf_send_api_ver(adapter);
+			else
+				dev_err(&pdev->dev, "Unsupported PF API version %d.%d, expected %d.%d\n",
+					adapter->pf_version.major,
+					adapter->pf_version.minor,
+					I40E_VIRTCHNL_VERSION_MAJOR,
+					I40E_VIRTCHNL_VERSION_MINOR);
 			goto err;
 		}
 		err = i40evf_send_vf_config_msg(adapter);
diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c b/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c
index a37d56b..52c6959 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c
@@ -125,8 +125,11 @@ int i40evf_verify_api_ver(struct i40evf_adapter *adapter)
 	}
 
 	pf_vvi = (struct i40e_virtchnl_version_info *)event.msg_buf;
-	if ((pf_vvi->major != I40E_VIRTCHNL_VERSION_MAJOR) ||
-	    (pf_vvi->minor != I40E_VIRTCHNL_VERSION_MINOR))
+	adapter->pf_version = *pf_vvi;
+
+	if ((pf_vvi->major > I40E_VIRTCHNL_VERSION_MAJOR) ||
+	    ((pf_vvi->major == I40E_VIRTCHNL_VERSION_MAJOR) &&
+	     (pf_vvi->minor > I40E_VIRTCHNL_VERSION_MINOR)))
 		err = -EIO;
 
 out_alloc:
-- 
2.4.3
