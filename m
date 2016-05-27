From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH net] openvswitch: update checksum in {push,pop}_mpls
Date: Fri, 27 May 2016 15:58:58 +0900
Message-ID: <1464332338-12382-1-git-send-email-simon.horman@netronome.com>
Cc: netdev@vger.kernel.org, Simon Horman <simon.horman@netronome.com>
To: Pravin Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:32857 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754505AbcE0G7I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 May 2016 02:59:08 -0400
Received: by mail-pa0-f54.google.com with SMTP id xk12so37338013pac.0
        for <netdev@vger.kernel.org>; Thu, 26 May 2016 23:59:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the case of CHECKSUM_COMPLETE the skb checksum should be updated in
{push,pop}_mpls() as they the type in the ethernet header.

As suggested by Pravin Shelar.

Cc: Pravin Shelar <pshelar@nicira.com>
Fixes: 25cd9ba0abc0 ("openvswitch: Add basic MPLS support to kernel")
Signed-off-by: Simon Horman <simon.horman@netronome.com>
---
 net/openvswitch/actions.c | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
index 879185fe183f..d6010b44d423 100644
--- a/net/openvswitch/actions.c
+++ b/net/openvswitch/actions.c
@@ -161,6 +161,12 @@ static int push_mpls(struct sk_buff *skb, struct sw_flow_key *key,
 	skb_postpush_rcsum(skb, new_mpls_lse, MPLS_HLEN);
 
 	hdr = eth_hdr(skb);
+	if (skb->ip_summed == CHECKSUM_COMPLETE) {
+		__be16 diff[] = { ~(hdr->h_proto), mpls->mpls_ethertype };
+
+		skb->csum = ~csum_partial((char *)diff, sizeof(diff),
+					~skb->csum);
+	}
 	hdr->h_proto = mpls->mpls_ethertype;
 
 	if (!skb->inner_protocol)
@@ -193,6 +199,12 @@ static int pop_mpls(struct sk_buff *skb, struct sw_flow_key *key,
 	 * field correctly in the presence of VLAN tags.
 	 */
 	hdr = (struct ethhdr *)(skb_mpls_header(skb) - ETH_HLEN);
+	if (skb->ip_summed == CHECKSUM_COMPLETE) {
+		__be16 diff[] = { ~(hdr->h_proto), ethertype };
+
+		skb->csum = ~csum_partial((char *)diff, sizeof(diff),
+					~skb->csum);
+	}
 	hdr->h_proto = ethertype;
 	if (eth_p_mpls(skb->protocol))
 		skb->protocol = ethertype;
-- 
2.1.4
