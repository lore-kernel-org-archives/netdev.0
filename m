From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/12] ixgbe: Exit on error case in VF message processing
Date: Wed,  9 May 2012 23:46:43 -0700
Message-ID: <1336632413-19135-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1336632413-19135-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:22833 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755893Ab2EJGq6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 May 2012 02:46:58 -0400
In-Reply-To: <1336632413-19135-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

Previously we would get a mailbox error and still process the message.
Instead we should exit on error.

In addition we should also be flushing the ACK of the message so that we
can guarantee that the other end is aware we have received the message
while we are processing it.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
index 3985637..b64f1fc 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
@@ -544,13 +544,18 @@ static int ixgbe_rcv_msg_from_vf(struct ixgbe_adapter *adapter, u32 vf)
 
 	retval = ixgbe_read_mbx(hw, msgbuf, mbx_size, vf);
 
-	if (retval)
+	if (retval) {
 		pr_err("Error receiving message from VF\n");
+		return retval;
+	}
 
 	/* this is a message we already processed, do nothing */
 	if (msgbuf[0] & (IXGBE_VT_MSGTYPE_ACK | IXGBE_VT_MSGTYPE_NACK))
 		return retval;
 
+	/* flush the ack before we write any messages back */
+	IXGBE_WRITE_FLUSH(hw);
+
 	/*
 	 * until the vf completes a virtual function reset it should not be
 	 * allowed to start any configuration.
-- 
1.7.7.6
