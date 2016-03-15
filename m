From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH net-next repost] openvswitch: allow output of MPLS packets on tunnel vports
Date: Tue, 15 Mar 2016 12:00:35 +0900
Message-ID: <1458010835-18555-1-git-send-email-simon.horman@netronome.com>
Cc: Jesse Gross <jesse@kernel.org>, netdev@vger.kernel.org,
	dev@openvswitch.org, Simon Horman <simon.horman@netronome.com>
To: Pravin Shelar <pshelar@ovn.org>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:35816 "EHLO
	mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933484AbcCODA4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2016 23:00:56 -0400
Received: by mail-pf0-f175.google.com with SMTP id n5so7758887pfn.2
        for <netdev@vger.kernel.org>; Mon, 14 Mar 2016 20:00:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently output of MPLS packets on tunnel vports is not allowed by Open
vSwitch. This is because historically encapsulation was done in such a way
that the inner_protocol field of the skb needed to hold the inner protocol
for both MPLS and tunnel encapsulation in order for GSO segmentation to be
performed correctly.

Since b2acd1dc3949 ("openvswitch: Use regular GRE net_device instead of
vport") Open vSwitch makes use of lwt to output to tunnel netdevs which
perform encapsulation. As no drivers expose support for MPLS offloads this
means that GSO packets are segmented in software by validate_xmit_skb(),
which is called from __dev_queue_xmit(), before tunnel encapsulation occurs.
This means that the inner protocol of MPLS is no longer needed by the time
encapsulation occurs and the contention on the inner_protocol field of the
skb no longer occurs.

Thus it is now safe to output MPLS to tunnel vports.

Signed-off-by: Simon Horman <simon.horman@netronome.com>

---
* Lightly tested with Geneve, GRE and VXLAN
* Reposted with my desired email for this work
---
 net/openvswitch/flow_netlink.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
index 58b8efc23668..689c17264221 100644
--- a/net/openvswitch/flow_netlink.c
+++ b/net/openvswitch/flow_netlink.c
@@ -2044,9 +2044,6 @@ static int validate_set(const struct nlattr *a,
 		break;
 
 	case OVS_KEY_ATTR_TUNNEL:
-		if (eth_p_mpls(eth_type))
-			return -EINVAL;
-
 		if (masked)
 			return -EINVAL; /* Masked tunnel set not supported. */
 
-- 
2.1.4
