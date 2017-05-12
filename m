From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCH] vmxnet3: ensure that adapter is in proper state during force_close
Date: Fri, 12 May 2017 12:00:01 -0400
Message-ID: <20170512160001.24425-1-nhorman@tuxdriver.com>
Cc: Neil Horman <nhorman@tuxdriver.com>,
        Shrikrishna Khare <skhare@vmware.com>,
        "VMware, Inc." <pv-drivers@vmware.com>,
        "David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:33317 "EHLO
        smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756671AbdELQAp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 12 May 2017 12:00:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are several paths in vmxnet3, where settings changes cause the
adapter to be brought down and back up (vmxnet3_set_ringparam among
them).  Should part of the reset operation fail, these paths call
vmxnet3_force_close, which enables all napi instances prior to calling
dev_close (with the expectation that vmxnet3_close will then properly
disable them again).  However, vmxnet3_force_close neglects to clear
VMXNET3_STATE_BIT_QUIESCED prior to calling dev_close.  As a result
vmxnet3_quiesce_dev (called from vmxnet3_close), returns early, and
leaves all the napi instances in a enabled state while the device itself
is closed.  If a device in this state is activated again, napi_enable
will be called on already enabled napi_instances, leading to a BUG halt.

The fix is to simply enausre that the QUIESCED bit is cleared in
vmxnet3_force_close to allow quesence to be completed properly on close.

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
CC: Shrikrishna Khare <skhare@vmware.com>
CC: "VMware, Inc." <pv-drivers@vmware.com>
CC: "David S. Miller" <davem@davemloft.net>
---
 drivers/net/vmxnet3/vmxnet3_drv.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vmxnet3_drv.c
index 25bc764..d1c7029 100644
--- a/drivers/net/vmxnet3/vmxnet3_drv.c
+++ b/drivers/net/vmxnet3/vmxnet3_drv.c
@@ -2962,6 +2962,11 @@ vmxnet3_force_close(struct vmxnet3_adapter *adapter)
 	/* we need to enable NAPI, otherwise dev_close will deadlock */
 	for (i = 0; i < adapter->num_rx_queues; i++)
 		napi_enable(&adapter->rx_queue[i].napi);
+	/*
+	 * Need to clear the quiesce bit to ensure that vmxnet3_close
+	 * can quiesce the device properly
+	 */
+	clear_bit(VMXNET3_STATE_BIT_QUIESCED, &adapter->state);
 	dev_close(adapter->netdev);
 }
 
-- 
2.9.3
