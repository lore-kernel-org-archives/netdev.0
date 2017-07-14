From: Vasily Averin <vvs@virtuozzo.com>
Subject: [PATCH] ipv4: ip_do_fragment: fix headroom tests
Date: Fri, 14 Jul 2017 12:04:16 +0300
Message-ID: <88e7a111-ddcd-5aa9-f15e-045f9b0831a8@virtuozzo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Florian Westphal <fw@strlen.de>,
        David Woodhouse <dwmw2@infradead.org>, devel@openvz.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:32354 "EHLO relay.sw.ru"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753636AbdGNJ1r (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 14 Jul 2017 05:27:47 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some time ago David Woodhouse reported skb_under_panic
when we try to push ethernet header to fragmented ipv6 skbs.
It was fixed for ipv6 by Florian Westphal in
commit 1d325d217c7f ("ipv6: ip6_fragment: fix headroom tests and skb leak")

However similar problem still exist in ipv4.

It does not trigger skb_under_panic due paranoid check
in ip_finish_output2, however according to Alexey Kuznetsov
current state is abnormal and ip_fragment should be fixed too.

Signed-off-by: Vasily Averin <vvs@virtuozzo.com>
---
 net/ipv4/ip_output.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 7eb252d..50c74cd 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -599,6 +599,7 @@ int ip_do_fragment(struct net *net, struct sock *sk, struct sk_buff *skb,
 	hlen = iph->ihl * 4;
 	mtu = mtu - hlen;	/* Size of data space */
 	IPCB(skb)->flags |= IPSKB_FRAG_COMPLETE;
+	ll_rs = LL_RESERVED_SPACE(rt->dst.dev);
 
 	/* When frag_list is given, use it. First, check its validity:
 	 * some transformers could create wrong frag_list or break existing
@@ -614,14 +615,15 @@ int ip_do_fragment(struct net *net, struct sock *sk, struct sk_buff *skb,
 		if (first_len - hlen > mtu ||
 		    ((first_len - hlen) & 7) ||
 		    ip_is_fragment(iph) ||
-		    skb_cloned(skb))
+		    skb_cloned(skb) ||
+		    skb_headroom(skb) < ll_rs)
 			goto slow_path;
 
 		skb_walk_frags(skb, frag) {
 			/* Correct geometry. */
 			if (frag->len > mtu ||
 			    ((frag->len & 7) && frag->next) ||
-			    skb_headroom(frag) < hlen)
+			    skb_headroom(frag) < hlen + ll_rs)
 				goto slow_path_clean;
 
 			/* Partially cloned skb? */
@@ -711,8 +713,6 @@ int ip_do_fragment(struct net *net, struct sock *sk, struct sk_buff *skb,
 	left = skb->len - hlen;		/* Space per frame */
 	ptr = hlen;		/* Where to start from */
 
-	ll_rs = LL_RESERVED_SPACE(rt->dst.dev);
-
 	/*
 	 *	Fragment the datagram.
 	 */
-- 
2.7.4
