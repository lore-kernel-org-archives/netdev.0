From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net 3/6] openvswitch: Fix MPLS action validation.
Date: Tue, 23 Dec 2014 16:20:20 -0800
Message-ID: <1419380420-1605-1-git-send-email-pshelar@nicira.com>
Cc: netdev@vger.kernel.org, Pravin B Shelar <pshelar@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog125.obsmtp.com ([74.125.149.153]:56632 "HELO
	na3sys009aog125.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751474AbaLXAUW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Dec 2014 19:20:22 -0500
Received: by mail-pa0-f41.google.com with SMTP id rd3so8931116pab.28
        for <netdev@vger.kernel.org>; Tue, 23 Dec 2014 16:20:22 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Linux stack does not implement GSO for packet with multiple
encapsulations.  Therefore there was check in MPLS action
validation to detect such case, But this check introduced
bug which deleted one or more actions from actions list.
Following patch removes this check to fix the validation.

Fixes: 25cd9ba0abc ("openvswitch: Add basic MPLS support to
kernel").

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
Reported-by: Srinivas Neginhal <sneginha@vmware.com>
Acked-by: Jarno Rajahalme <jrajahalme@nicira.com>
---
 net/openvswitch/flow_netlink.c |   13 +------------
 1 files changed, 1 insertions(+), 12 deletions(-)

diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
index 9645a21..d1eecf7 100644
--- a/net/openvswitch/flow_netlink.c
+++ b/net/openvswitch/flow_netlink.c
@@ -1753,7 +1753,6 @@ static int __ovs_nla_copy_actions(const struct nlattr *attr,
 				  __be16 eth_type, __be16 vlan_tci, bool log)
 {
 	const struct nlattr *a;
-	bool out_tnl_port = false;
 	int rem, err;
 
 	if (depth >= SAMPLE_ACTION_DEPTH)
@@ -1796,8 +1795,6 @@ static int __ovs_nla_copy_actions(const struct nlattr *attr,
 		case OVS_ACTION_ATTR_OUTPUT:
 			if (nla_get_u32(a) >= DP_MAX_PORTS)
 				return -EINVAL;
-			out_tnl_port = false;
-
 			break;
 
 		case OVS_ACTION_ATTR_HASH: {
@@ -1832,12 +1829,6 @@ static int __ovs_nla_copy_actions(const struct nlattr *attr,
 		case OVS_ACTION_ATTR_PUSH_MPLS: {
 			const struct ovs_action_push_mpls *mpls = nla_data(a);
 
-			/* Networking stack do not allow simultaneous Tunnel
-			 * and MPLS GSO.
-			 */
-			if (out_tnl_port)
-				return -EINVAL;
-
 			if (!eth_p_mpls(mpls->mpls_ethertype))
 				return -EINVAL;
 			/* Prohibit push MPLS other than to a white list
@@ -1873,11 +1864,9 @@ static int __ovs_nla_copy_actions(const struct nlattr *attr,
 
 		case OVS_ACTION_ATTR_SET:
 			err = validate_set(a, key, sfa,
-					   &out_tnl_port, eth_type, log);
+					   &skip_copy, eth_type, log);
 			if (err)
 				return err;
-
-			skip_copy = out_tnl_port;
 			break;
 
 		case OVS_ACTION_ATTR_SAMPLE:
-- 
1.7.1
