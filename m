From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH/RFC] openvswitch: loosen restriction of output of MPLS to tunnel vports
Date: Fri, 12 Feb 2016 20:25:33 +0100
Message-ID: <1455305133-23285-1-git-send-email-simon.horman@netronome.com>
Cc: dev@openvswitch.org, Pravin Shelar <pshelar@nicira.com>,
	Simon Horman <simon.horman@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f54.google.com ([209.85.215.54]:34280 "EHLO
	mail-lf0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750707AbcBLT0B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Feb 2016 14:26:01 -0500
Received: by mail-lf0-f54.google.com with SMTP id j78so57803620lfb.1
        for <netdev@vger.kernel.org>; Fri, 12 Feb 2016 11:26:00 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If an skb was not MPLS initially then it may be GSO and in that case if it
became MPLS then GSO can't be performed because both MPLS and tunnels make
use of the inner_protocol field of struct skbuff in order to allow GSO to
be performed in the inner packet.

On the other hand if an skb was MPLS initially then it will not be GSO,
as there is no support for GRO for MPLS. Thus in this case it is safe
to allow output of MPLS on tunnel vports.

Signed-off-by: Simon Horman <simon.horman@netronome.com>
---
 net/openvswitch/flow_netlink.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
index d1bd4a45ca2d..a574796f35d2 100644
--- a/net/openvswitch/flow_netlink.c
+++ b/net/openvswitch/flow_netlink.c
@@ -2038,7 +2038,13 @@ static int validate_set(const struct nlattr *a,
 		break;
 
 	case OVS_KEY_ATTR_TUNNEL:
-		if (eth_p_mpls(eth_type))
+		/* If an skb was not MPLS initially then it may be GSO
+		 * and in that case if it became MPLS then GSO can't be
+		 * performed because both MPLS and tunnels make use
+		 * of the inner_protocol field of struct skbuff in order
+		 * to allow GSO to be performed in the inner packet.
+		 */
+		if (!eth_p_mpls(flow_key->eth.type) && eth_p_mpls(eth_type))
 			return -EINVAL;
 
 		if (masked)
-- 
2.7.0.rc3.207.g0ac5344
