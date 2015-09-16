From: Florian Westphal <fw@strlen.de>
Subject: [PATCH net] ipv6: ip6_fragment: fix headroom tests and skb leak
Date: Wed, 16 Sep 2015 17:26:14 +0200
Message-ID: <1442417174-6229-1-git-send-email-fw@strlen.de>
Cc: dwmw2@infradead.org, Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:39072 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751830AbbIPP0r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Sep 2015 11:26:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Woodhouse reports skb_under_panic when we try to push ethernet
header to fragmented ipv6 skbs:

 skbuff: skb_under_panic: text:c1277f1e len:1294 put:14 head:dec98000
 data:dec97ffc tail:0xdec9850a end:0xdec98f40 dev:br-lan
[..]
ip6_finish_output2+0x196/0x4da

David further debugged this:
  [..] offending fragments were arriving here with skb_headroom(skb)==10.
  Which is reasonable, being the Solos ADSL card's header of 8 bytes
  followed by 2 bytes of PPP frame type.

The problem is that if netfilter ipv6 defragmentation is used, skb_cow()
in ip6_forward will only see reassembled skb.

Therefore, headroom is overestimated by 8 bytes (we pulled fragment
header) and we don't check the skbs in the frag_list either.

We can't do these checks in netfilter defrag since outdev isn't known yet.

Furthermore, existing tests in ip6_fragment did not consider the fragment
or ipv6 header size when checking headroom of the fraglist skbs.

While at it, also fix a skb leak on memory allocation -- ip6_fragment
must consume the skb.

I tested this e1000 driver hacked to not allocate additional headroom
(we end up in slowpath, since LL_RESERVED_SPACE is 16).

If 2 bytes of headroom are allocated, fastpath is taken (14 byte
ethernet header was pulled, so 16 byte headroom available in all
fragments).

Reported-by: David Woodhouse <dwmw2@infradead.org>
Diagnosed-by: David Woodhouse <dwmw2@infradead.org>
Signed-off-by: Florian Westphal <fw@strlen.de>
---
 net/ipv6/ip6_output.c | 14 ++++++++------
 1 file changed, 8 insertions(+), 6 deletions(-)

diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 26ea479..92b1aa3 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -586,20 +586,22 @@ int ip6_fragment(struct sock *sk, struct sk_buff *skb,
 	frag_id = ipv6_select_ident(net, &ipv6_hdr(skb)->daddr,
 				    &ipv6_hdr(skb)->saddr);
 
+	hroom = LL_RESERVED_SPACE(rt->dst.dev);
 	if (skb_has_frag_list(skb)) {
 		int first_len = skb_pagelen(skb);
 		struct sk_buff *frag2;
 
 		if (first_len - hlen > mtu ||
 		    ((first_len - hlen) & 7) ||
-		    skb_cloned(skb))
+		    skb_cloned(skb) ||
+		    skb_headroom(skb) < (hroom + sizeof(struct frag_hdr)))
 			goto slow_path;
 
 		skb_walk_frags(skb, frag) {
 			/* Correct geometry. */
 			if (frag->len > mtu ||
 			    ((frag->len & 7) && frag->next) ||
-			    skb_headroom(frag) < hlen)
+			    skb_headroom(frag) < (hlen + hroom + sizeof(struct frag_hdr)))
 				goto slow_path_clean;
 
 			/* Partially cloned skb? */
@@ -616,8 +618,6 @@ int ip6_fragment(struct sock *sk, struct sk_buff *skb,
 
 		err = 0;
 		offset = 0;
-		frag = skb_shinfo(skb)->frag_list;
-		skb_frag_list_init(skb);
 		/* BUILD HEADER */
 
 		*prevhdr = NEXTHDR_FRAGMENT;
@@ -625,8 +625,11 @@ int ip6_fragment(struct sock *sk, struct sk_buff *skb,
 		if (!tmp_hdr) {
 			IP6_INC_STATS(net, ip6_dst_idev(skb_dst(skb)),
 				      IPSTATS_MIB_FRAGFAILS);
-			return -ENOMEM;
+			err = -ENOMEM;
+			goto fail;
 		}
+		frag = skb_shinfo(skb)->frag_list;
+		skb_frag_list_init(skb);
 
 		__skb_pull(skb, hlen);
 		fh = (struct frag_hdr *)__skb_push(skb, sizeof(struct frag_hdr));
@@ -723,7 +726,6 @@ slow_path:
 	 */
 
 	*prevhdr = NEXTHDR_FRAGMENT;
-	hroom = LL_RESERVED_SPACE(rt->dst.dev);
 	troom = rt->dst.dev->needed_tailroom;
 
 	/*
-- 
2.0.5
