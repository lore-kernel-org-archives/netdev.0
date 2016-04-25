From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/15] ixgbe: make 'action' field in struct ixgbe_fdir_filter a u64 value
Date: Mon, 25 Apr 2016 05:44:18 -0700
Message-ID: <1461588269-128728-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1461588269-128728-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Sridhar Samudrala <sridhar.samudrala@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:10855 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932382AbcDYMoc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Apr 2016 08:44:32 -0400
In-Reply-To: <1461588269-128728-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sridhar Samudrala <sridhar.samudrala@intel.com>

This field is used to record the RX queue index for a redirect action
passed via ring_cookie field in struct ethtool_rx_flow_spec which is
a u64 value.

For ex: after adding a filter rule to redirect to a VF using ethtool
  # echo 4 > /sys/class/net/p4p1/device/sriov_numvfs
  # ethtool -N p4p1 flow-type ip4 src-ip 192.168.0.1 action 0x100000000

querying for the rule shows the Action as 'Direct to queue 0'

  # ethtool -n p4p1
  4 RX rings available
  Total 1 rules

  Filter: 2045
 	Rule Type: Raw IPv4
	Src IP addr: 192.168.0.1 mask: 0.0.0.0
	Dest IP addr: 0.0.0.0 mask: 255.255.255.255
	TOS: 0x0 mask: 0xff
	Protocol: 0 mask: 0xff
	L4 bytes: 0x0 mask: 0xffffffff
	VLAN EtherType: 0x0 mask: 0xffff
	VLAN: 0x0 mask: 0xffff
	User-defined: 0x0 mask: 0xffffffffffffffff
	Action: Direct to queue 0

With this fix, ethtool will report the right queue index even for VFs.
	Action: Direct to queue 4294967296

Here 4294967296 corresponds to 0x100000000.
We need to update 'ethtool' to report the queue index as a Hex value so
that it is more  user friendly and matches with the 'action' value that
is passed when adding the rule.

Signed-off-by: Sridhar Samudrala <sridhar.samudrala@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index 61d8110..94e39c1 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -825,7 +825,7 @@ struct ixgbe_fdir_filter {
 	struct hlist_node fdir_node;
 	union ixgbe_atr_input filter;
 	u16 sw_idx;
-	u16 action;
+	u64 action;
 };
 
 enum ixgbe_state_t {
-- 
2.5.5
