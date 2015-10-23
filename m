From: Joe Stringer <joestringer@nicira.com>
Subject: [PATCHv2 net 3/3] openvswitch: Fix skb leak using IPv6 defrag
Date: Fri, 23 Oct 2015 16:32:15 -0700
Message-ID: <1445643135-65034-3-git-send-email-joestringer@nicira.com>
References: <1445643135-65034-1-git-send-email-joestringer@nicira.com>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	Andy Zhou <azhou@nicira.com>
To: netdev@vger.kernel.org, Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:36670 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751850AbbJWXcY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2015 19:32:24 -0400
Received: by pacfv9 with SMTP id fv9so136168819pac.3
        for <netdev@vger.kernel.org>; Fri, 23 Oct 2015 16:32:24 -0700 (PDT)
In-Reply-To: <1445643135-65034-1-git-send-email-joestringer@nicira.com>
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
v2: No change.
---
 net/openvswitch/conntrack.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/net/openvswitch/conntrack.c b/net/openvswitch/conntrack.c
index 3713275a1345..3deb89636257 100644
--- a/net/openvswitch/conntrack.c
+++ b/net/openvswitch/conntrack.c
@@ -326,8 +326,15 @@ static int handle_fragments(struct net *net, struct sw_flow_key *key,
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
