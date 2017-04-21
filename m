From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/11] ixgbevf: Fix errors in retrieving RETA and RSS from PF
Date: Thu, 20 Apr 2017 18:50:28 -0700
Message-ID: <20170421015029.18994-11-jeffrey.t.kirsher@intel.com>
References: <20170421015029.18994-1-jeffrey.t.kirsher@intel.com>
Cc: Tony Nguyen <anthony.l.nguyen@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:63872 "EHLO mga04.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1034440AbdDUBvE (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 20 Apr 2017 21:51:04 -0400
In-Reply-To: <20170421015029.18994-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tony Nguyen <anthony.l.nguyen@intel.com>

Mailbox support for getting RETA and RSS is available for only 82599 and
x540; a previous patch reversed the logic and these adapters were
returning not supported.

Also, the NACK check in ixgbevf_get_rss_key_locked() was checking for the
command IXGBE_VF_GET_RETA instead of IXGBE_VF_GET_RSS_KEY.

This patch corrects both issues by correcting the logic and checking for
the right command.

Signed-off-by: Tony Nguyen <anthony.l.nguyen@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/vf.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/vf.c b/drivers/net/ethernet/intel/ixgbevf/vf.c
index 8a5db9d7219d..b6d0c01eab10 100644
--- a/drivers/net/ethernet/intel/ixgbevf/vf.c
+++ b/drivers/net/ethernet/intel/ixgbevf/vf.c
@@ -333,7 +333,7 @@ int ixgbevf_get_reta_locked(struct ixgbe_hw *hw, u32 *reta, int num_rx_queues)
 	switch (hw->api_version) {
 	case ixgbe_mbox_api_13:
 	case ixgbe_mbox_api_12:
-		if (hw->mac.type >= ixgbe_mac_X550_vf)
+		if (hw->mac.type < ixgbe_mac_X550_vf)
 			break;
 	default:
 		return -EOPNOTSUPP;
@@ -399,7 +399,7 @@ int ixgbevf_get_rss_key_locked(struct ixgbe_hw *hw, u8 *rss_key)
 	switch (hw->api_version) {
 	case ixgbe_mbox_api_13:
 	case ixgbe_mbox_api_12:
-		if (hw->mac.type >= ixgbe_mac_X550_vf)
+		if (hw->mac.type < ixgbe_mac_X550_vf)
 			break;
 	default:
 		return -EOPNOTSUPP;
@@ -419,7 +419,7 @@ int ixgbevf_get_rss_key_locked(struct ixgbe_hw *hw, u8 *rss_key)
 	msgbuf[0] &= ~IXGBE_VT_MSGTYPE_CTS;
 
 	/* If the operation has been refused by a PF return -EPERM */
-	if (msgbuf[0] == (IXGBE_VF_GET_RETA | IXGBE_VT_MSGTYPE_NACK))
+	if (msgbuf[0] == (IXGBE_VF_GET_RSS_KEY | IXGBE_VT_MSGTYPE_NACK))
 		return -EPERM;
 
 	/* If we didn't get an ACK there must have been
-- 
2.12.2
