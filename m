From: Casey Leedom <leedom@chelsio.com>
Subject: [PATCH net-26 6/6] cxgb4vf: add call to Firmware to reset VF State.
Date: Thu, 11 Nov 2010 11:06:53 -0800
Message-ID: <1289502413-9895-7-git-send-email-leedom@chelsio.com>
References: <1289502413-9895-1-git-send-email-leedom@chelsio.com>
Cc: davem@davemloft.net, Casey Leedom <leedom@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:19775 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754553Ab0KKTHD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Nov 2010 14:07:03 -0500
In-Reply-To: <1289502413-9895-1-git-send-email-leedom@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add call to Firmware to reset its VF State when we first attach to the VF.

Signed-off-by: Casey Leedom <leedom@chelsio.com>
---
 drivers/net/cxgb4vf/cxgb4vf_main.c |   16 ++++++++++++++++
 drivers/net/cxgb4vf/t4vf_common.h  |    1 +
 drivers/net/cxgb4vf/t4vf_hw.c      |   19 +++++++++++++++++++
 3 files changed, 36 insertions(+), 0 deletions(-)

diff --git a/drivers/net/cxgb4vf/cxgb4vf_main.c b/drivers/net/cxgb4vf/cxgb4vf_main.c
index 8da3bda..c3449bb 100644
--- a/drivers/net/cxgb4vf/cxgb4vf_main.c
+++ b/drivers/net/cxgb4vf/cxgb4vf_main.c
@@ -2065,6 +2065,22 @@ static int adap_init0(struct adapter *adapter)
 	}
 
 	/*
+	 * Some environments do not properly handle PCIE FLRs -- e.g. in Linux
+	 * 2.6.31 and later we can't call pci_reset_function() in order to
+	 * issue an FLR because of a self- deadlock on the device semaphore.
+	 * Meanwhile, the OS infrastructure doesn't issue FLRs in all the
+	 * cases where they're needed -- for instance, some versions of KVM
+	 * fail to reset "Assigned Devices" when the VM reboots.  Therefore we
+	 * use the firmware based reset in order to reset any per function
+	 * state.
+	 */
+	err = t4vf_fw_reset(adapter);
+	if (err < 0) {
+		dev_err(adapter->pdev_dev, "FW reset failed: err=%d\n", err);
+		return err;
+	}
+
+	/*
 	 * Grab basic operational parameters.  These will predominantly have
 	 * been set up by the Physical Function Driver or will be hard coded
 	 * into the adapter.  We just have to live with them ...  Note that
diff --git a/drivers/net/cxgb4vf/t4vf_common.h b/drivers/net/cxgb4vf/t4vf_common.h
index 873cb7d..a65c80a 100644
--- a/drivers/net/cxgb4vf/t4vf_common.h
+++ b/drivers/net/cxgb4vf/t4vf_common.h
@@ -235,6 +235,7 @@ static inline int t4vf_wr_mbox_ns(struct adapter *adapter, const void *cmd,
 int __devinit t4vf_wait_dev_ready(struct adapter *);
 int __devinit t4vf_port_init(struct adapter *, int);
 
+int t4vf_fw_reset(struct adapter *);
 int t4vf_query_params(struct adapter *, unsigned int, const u32 *, u32 *);
 int t4vf_set_params(struct adapter *, unsigned int, const u32 *, const u32 *);
 
diff --git a/drivers/net/cxgb4vf/t4vf_hw.c b/drivers/net/cxgb4vf/t4vf_hw.c
index ea1c123..e306c20 100644
--- a/drivers/net/cxgb4vf/t4vf_hw.c
+++ b/drivers/net/cxgb4vf/t4vf_hw.c
@@ -326,6 +326,25 @@ int __devinit t4vf_port_init(struct adapter *adapter, int pidx)
 }
 
 /**
+ *      t4vf_fw_reset - issue a reset to FW
+ *      @adapter: the adapter
+ *
+ *	Issues a reset command to FW.  For a Physical Function this would
+ *	result in the Firmware reseting all of its state.  For a Virtual
+ *	Function this just resets the state associated with the VF.
+ */
+int t4vf_fw_reset(struct adapter *adapter)
+{
+	struct fw_reset_cmd cmd;
+
+	memset(&cmd, 0, sizeof(cmd));
+	cmd.op_to_write = cpu_to_be32(FW_CMD_OP(FW_RESET_CMD) |
+				      FW_CMD_WRITE);
+	cmd.retval_len16 = cpu_to_be32(FW_LEN16(cmd));
+	return t4vf_wr_mbox(adapter, &cmd, sizeof(cmd), NULL);
+}
+
+/**
  *	t4vf_query_params - query FW or device parameters
  *	@adapter: the adapter
  *	@nparams: the number of parameters
-- 
1.7.0.4

