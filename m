From: Vladislav Yasevich <vyasevich@gmail.com>
Subject: [PATCH] ixgbe: Correctly disable vlan filter in promiscuous mode
Date: Tue, 18 Nov 2014 14:28:17 -0500
Message-ID: <1416338897-13007-1-git-send-email-vyasevic@redhat.com>
Cc: Vladislav Yasevich <vyasevic@redhat.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jacob Keller <jacob.e.keller@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f53.google.com ([209.85.192.53]:38037 "EHLO
	mail-qg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753903AbaKRT22 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Nov 2014 14:28:28 -0500
Received: by mail-qg0-f53.google.com with SMTP id z107so17414907qgd.26
        for <netdev@vger.kernel.org>; Tue, 18 Nov 2014 11:28:27 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IXGBE adapater seems to require that vlan filtering be enabled if
VMDQ
or SRIOV are enabled.  When those functions are disabled,
vlan filtering may be disabled in promiscuous mode.

Prior to commit a9b8943ee129e11045862d6d6e25c5b63c95403c
    ixgbe: remove vlan_filter_disable and enable functions

the logic was correct.  However, after the commit the logic
got reversed and vlan filtered in now turned on when VMDQ/SRIOV
is disabled.

This patch changes the condition to enable hw vlan filtered
when VMDQ or SRIOV is enabled.

Fixes: a9b8943ee129e11045862d6d6e25c5b63c95403c (ixgbe: remove
vlan_filter_disable and enable functions)
CC: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
CC: Jacob Keller <jacob.e.keller@intel.com>
Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index d2df4e3..3f81c7a 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -3936,8 +3936,8 @@ void ixgbe_set_rx_mode(struct net_device *netdev)
 		 * if SR-IOV and VMDQ are disabled - otherwise ensure
 		 * that hardware VLAN filters remain enabled.
 		 */
-		if (!(adapter->flags & (IXGBE_FLAG_VMDQ_ENABLED |
-					IXGBE_FLAG_SRIOV_ENABLED)))
+		if (adapter->flags & (IXGBE_FLAG_VMDQ_ENABLED |
+				      IXGBE_FLAG_SRIOV_ENABLED))
 			vlnctrl |= (IXGBE_VLNCTRL_VFE | IXGBE_VLNCTRL_CFIEN);
 	} else {
 		if (netdev->flags & IFF_ALLMULTI) {
-- 
1.9.3
