From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 05/18] fm10k: only prevent removal of default VID rules
Date: Tue, 15 Sep 2015 17:36:30 -0700
Message-ID: <1442363803-47237-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1442363803-47237-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:17223 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753203AbbIPAgs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Sep 2015 20:36:48 -0400
In-Reply-To: <1442363803-47237-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

This allows us to correctly add a VLAN even if it matches our default
VID. However, we don't want to remove the VID rules once that VLAN is
deleted. Correctly remove the stack layers information of the VLAN, but
then return to forwarding that VID as untagged frames. If we deleted the
VID rules here, we would begin dropping traffic due to VLAN membership
violations.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Krishneil Singh <krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_netdev.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
index 99228bf..818bc8b 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
@@ -775,8 +775,8 @@ static int fm10k_update_vid(struct net_device *netdev, u16 vid, bool set)
 	if (!set)
 		clear_bit(vid, interface->active_vlans);
 
-	/* if default VLAN is already present do nothing */
-	if (vid == hw->mac.default_vid)
+	/* Do not remove default VID related entries from VLAN and MAC tables */
+	if (!set && vid == hw->mac.default_vid)
 		return 0;
 
 	fm10k_mbx_lock(interface);
-- 
2.4.3
