From: Joe Stringer <joestringer@nicira.com>
Subject: [PATCHv3 net 3/3] openvswitch: Fix skb leak using IPv6 defrag
Date: Sun, 25 Oct 2015 20:21:50 -0700
Message-ID: <1445829710-11292-3-git-send-email-joestringer@nicira.com>
References: <1445829710-11292-1-git-send-email-joestringer@nicira.com>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	Andy Zhou <azhou@nicira.com>
To: netdev@vger.kernel.org, Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:35264 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752677AbbJZDV7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Oct 2015 23:21:59 -0400
Received: by pasz6 with SMTP id z6so173634214pas.2
        for <netdev@vger.kernel.org>; Sun, 25 Oct 2015 20:21:56 -0700 (PDT)
In-Reply-To: <1445829710-11292-1-git-send-email-joestringer@nicira.com>
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
v2-v3: No change.
---
 net/openvswitch/conntrack.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/net/openvswitch/conntrack.c b/net/openvswitch/conntrack.c
index b5dcc0abde66..50095820edb7 100644
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
