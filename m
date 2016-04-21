From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH net] openvswitch: use flow protocol when recalculating ipv6 checksums
Date: Thu, 21 Apr 2016 11:49:15 +1000
Message-ID: <1461203355-3088-1-git-send-email-simon.horman@netronome.com>
Cc: Jesse Gross <jesse@kernel.org>, netdev@vger.kernel.org,
	dev@openvswitch.org, Simon Horman <simon.horman@netronome.com>,
	Jarno Rajahalme <jrajahalme@nicira.com>
To: Pravin Shelar <pshelar@ovn.org>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:33815 "EHLO
	mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751608AbcDUBtb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Apr 2016 21:49:31 -0400
Received: by mail-pf0-f175.google.com with SMTP id y69so7637190pfb.1
        for <netdev@vger.kernel.org>; Wed, 20 Apr 2016 18:49:31 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When using masked actions the ipv6_proto field of an action
to set IPv6 fields may be zero rather than the prevailing protocol
which will result in skipping checksum recalculation.

This patch resolves the problem by relying on the protocol
in the flow key rather than that in the set field action.

Fixes: 83d2b9ba1abc ("net: openvswitch: Support masked set actions.")
Cc: Jarno Rajahalme <jrajahalme@nicira.com>
Signed-off-by: Simon Horman <simon.horman@netronome.com>
---
* Found using tcpdump to examine the checksums of packets.
* I believe a similar fix is required for the user-space implementation
  of the datapath. I plan to look into that unless someone else wishes to.
---
 net/openvswitch/actions.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
index e9dd47b2a85b..879185fe183f 100644
--- a/net/openvswitch/actions.c
+++ b/net/openvswitch/actions.c
@@ -461,7 +461,7 @@ static int set_ipv6(struct sk_buff *skb, struct sw_flow_key *flow_key,
 		mask_ipv6_addr(saddr, key->ipv6_src, mask->ipv6_src, masked);
 
 		if (unlikely(memcmp(saddr, masked, sizeof(masked)))) {
-			set_ipv6_addr(skb, key->ipv6_proto, saddr, masked,
+			set_ipv6_addr(skb, flow_key->ip.proto, saddr, masked,
 				      true);
 			memcpy(&flow_key->ipv6.addr.src, masked,
 			       sizeof(flow_key->ipv6.addr.src));
@@ -483,7 +483,7 @@ static int set_ipv6(struct sk_buff *skb, struct sw_flow_key *flow_key,
 							     NULL, &flags)
 					       != NEXTHDR_ROUTING);
 
-			set_ipv6_addr(skb, key->ipv6_proto, daddr, masked,
+			set_ipv6_addr(skb, flow_key->ip.proto, daddr, masked,
 				      recalc_csum);
 			memcpy(&flow_key->ipv6.addr.dst, masked,
 			       sizeof(flow_key->ipv6.addr.dst));
-- 
2.7.0.rc3.207.g0ac5344
