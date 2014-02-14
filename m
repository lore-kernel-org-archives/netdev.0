From: Aaron Brown <aaron.f.brown@intel.com>
Subject: [net-next 01/14] i40evf: request reset on tx hang
Date: Fri, 14 Feb 2014 14:57:55 -0800
Message-ID: <1392418688-23895-2-git-send-email-aaron.f.brown@intel.com>
References: <1392418688-23895-1-git-send-email-aaron.f.brown@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Aaron Brown <aaron.f.brown@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:61878 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753125AbaBNXBT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Feb 2014 18:01:19 -0500
In-Reply-To: <1392418688-23895-1-git-send-email-aaron.f.brown@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

If the kernel watchdog bites us, ask the PF to reset us and attempt to
reinit the driver.

Change-ID: Ic97665aeeed71ce712b9c4f057e78ff8372522b9
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Aaron Brown <aaron.f.brown@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf.h          |  1 +
 drivers/net/ethernet/intel/i40evf/i40evf_main.c     | 10 +++++++---
 drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c | 12 ++++++++++++
 3 files changed, 20 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf.h b/drivers/net/ethernet/intel/i40evf/i40evf.h
index a30c4a9..ec54ebb 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf.h
+++ b/drivers/net/ethernet/intel/i40evf/i40evf.h
@@ -289,6 +289,7 @@ void i40evf_add_vlans(struct i40evf_adapter *adapter);
 void i40evf_del_vlans(struct i40evf_adapter *adapter);
 void i40evf_set_promiscuous(struct i40evf_adapter *adapter, int flags);
 void i40evf_request_stats(struct i40evf_adapter *adapter);
+void i40evf_request_reset(struct i40evf_adapter *adapter);
 void i40evf_virtchnl_completion(struct i40evf_adapter *adapter,
 				enum i40e_virtchnl_ops v_opcode,
 				i40e_status v_retval, u8 *msg, u16 msglen);
diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index fe2271e..1629b73 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -167,9 +167,13 @@ static void i40evf_tx_timeout(struct net_device *netdev)
 	struct i40evf_adapter *adapter = netdev_priv(netdev);
 
 	adapter->tx_timeout_count++;
-
-	/* Do the reset outside of interrupt context */
-	schedule_work(&adapter->reset_task);
+	dev_info(&adapter->pdev->dev, "TX timeout detected.\n");
+	if (!(adapter->flags & I40EVF_FLAG_RESET_PENDING)) {
+		dev_info(&adapter->pdev->dev, "Requesting reset from PF\n");
+		i40evf_request_reset(adapter);
+		adapter->flags |= I40EVF_FLAG_RESET_PENDING;
+		schedule_work(&adapter->reset_task);
+	}
 }
 
 /**
diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c b/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c
index 93891a1..e294f01 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c
@@ -654,6 +654,18 @@ void i40evf_request_stats(struct i40evf_adapter *adapter)
 		/* if the request failed, don't lock out others */
 		adapter->current_op = I40E_VIRTCHNL_OP_UNKNOWN;
 }
+/**
+ * i40evf_request_reset
+ * @adapter: adapter structure
+ *
+ * Request that the PF reset this VF. No response is expected.
+ **/
+void i40evf_request_reset(struct i40evf_adapter *adapter)
+{
+	/* Don't check CURRENT_OP - this is always higher priority */
+	i40evf_send_pf_msg(adapter, I40E_VIRTCHNL_OP_RESET_VF, NULL, 0);
+	adapter->current_op = I40E_VIRTCHNL_OP_UNKNOWN;
+}
 
 /**
  * i40evf_virtchnl_completion
-- 
1.8.5.GIT
