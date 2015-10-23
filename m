From: Joe Stringer <joestringer@nicira.com>
Subject: [PATCH net 3/3] openvswitch: Fix skb leak using IPv6 defrag
Date: Fri, 23 Oct 2015 16:01:51 -0700
Message-ID: <1445641311-63081-3-git-send-email-joestringer@nicira.com>
References: <1445641311-63081-1-git-send-email-joestringer@nicira.com>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	Andy Zhou <azhou@nicira.com>
To: netdev@vger.kernel.org, Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:33742 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751301AbbJWXCC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2015 19:02:02 -0400
Received: by pabrc13 with SMTP id rc13so129498913pab.0
        for <netdev@vger.kernel.org>; Fri, 23 Oct 2015 16:02:01 -0700 (PDT)
In-Reply-To: <1445641311-63081-1-git-send-email-joestringer@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

nf_ct_frag6_gather() makes a clone of each skb passed to it, and if the
reassembly is successful, expects the caller to free all of the original
skbs using nf_ct_frag6_consume_orig(). This call was previously missing,
meaning that the original fragments were never freed (with the exception
of the last fragment to arrive).

Fix this by ensuring that all original fragments except for the last
fragment are freed via nf_ct_frag6_consume_orig(). The last fragment
will be morphed into the head, so it must not be freed yet. Furthermore,
retain the ->next pointer for the head after skb_morph().

Fixes: 7f8a436eaa2c ("openvswitch: Add conntrack action")
Reported-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Joe Stringer <joestringer@nicira.com>
---
 net/openvswitch/conntrack.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/net/openvswitch/conntrack.c b/net/openvswitch/conntrack.c
index 6d907f913c8b..d982e82c0794 100644
--- a/net/openvswitch/conntrack.c
+++ b/net/openvswitch/conntrack.c
@@ -328,8 +328,15 @@ static int handle_fragments(struct net *net, struct sw_flow_key *key,
 			return -EINVAL;
 		}
 
+		/* Don't free 'skb' even though it is one of the original
+		 * fragments, as we're going to morph it into the head.
+		 */
+		skb_get(skb);
+		nf_ct_frag6_consume_orig(reasm);
+
 		key->ip.proto = ipv6_hdr(reasm)->nexthdr;
 		skb_morph(skb, reasm);
+		skb->next = reasm->next;
 		consume_skb(reasm);
 		ovs_cb.mru = IP6CB(skb)->frag_max_size;
 #endif
-- 
2.1.4
