From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 1/2] ipv6: Fix IPsec slowpath fragmentation problem
Date: Tue, 11 Oct 2011 13:43:33 +0200
Message-ID: <20111011114333.GI1830@secunet.com>
References: <20111011114251.GH1830@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:53341 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751804Ab1JKLng (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Oct 2011 07:43:36 -0400
Content-Disposition: inline
In-Reply-To: <20111011114251.GH1830@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ip6_append_data() builds packets based on the mtu from dst_mtu(rt->dst.path).
On IPsec the effective mtu is lower because we need to add the protocol
headers and trailers later when we do the IPsec transformations. So after
the IPsec transformations the packet might be too big, which leads to a
slowpath fragmentation then. This patch fixes this by building the packets
based on the lower IPsec mtu from dst_mtu(&rt->dst) and adapts the exthdr
handling to this.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv6/ip6_output.c |   18 ++++++++++++------
 net/ipv6/raw.c        |    3 +--
 2 files changed, 13 insertions(+), 8 deletions(-)

diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 835c04b..1e20b64 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -1193,6 +1193,7 @@ int ip6_append_data(struct sock *sk, int getfrag(void *from, char *to,
 	struct sk_buff *skb;
 	unsigned int maxfraglen, fragheaderlen;
 	int exthdrlen;
+	int dst_exthdrlen;
 	int hh_len;
 	int mtu;
 	int copy;
@@ -1248,7 +1249,7 @@ int ip6_append_data(struct sock *sk, int getfrag(void *from, char *to,
 		np->cork.hop_limit = hlimit;
 		np->cork.tclass = tclass;
 		mtu = np->pmtudisc == IPV6_PMTUDISC_PROBE ?
-		      rt->dst.dev->mtu : dst_mtu(rt->dst.path);
+		      rt->dst.dev->mtu : dst_mtu(&rt->dst);
 		if (np->frag_size < mtu) {
 			if (np->frag_size)
 				mtu = np->frag_size;
@@ -1259,16 +1260,17 @@ int ip6_append_data(struct sock *sk, int getfrag(void *from, char *to,
 		cork->length = 0;
 		sk->sk_sndmsg_page = NULL;
 		sk->sk_sndmsg_off = 0;
-		exthdrlen = rt->dst.header_len + (opt ? opt->opt_flen : 0) -
-			    rt->rt6i_nfheader_len;
+		exthdrlen = (opt ? opt->opt_flen : 0) - rt->rt6i_nfheader_len;
 		length += exthdrlen;
 		transhdrlen += exthdrlen;
+		dst_exthdrlen = rt->dst.header_len;
 	} else {
 		rt = (struct rt6_info *)cork->dst;
 		fl6 = &inet->cork.fl.u.ip6;
 		opt = np->cork.opt;
 		transhdrlen = 0;
 		exthdrlen = 0;
+		dst_exthdrlen = 0;
 		mtu = cork->fragsize;
 	}
 
@@ -1368,6 +1370,8 @@ alloc_new_skb:
 			else
 				alloclen = datalen + fragheaderlen;
 
+			alloclen += dst_exthdrlen;
+
 			/*
 			 * The last fragment gets additional space at tail.
 			 * Note: we overallocate on fragments with MSG_MODE
@@ -1419,9 +1423,9 @@ alloc_new_skb:
 			/*
 			 *	Find where to start putting bytes
 			 */
-			data = skb_put(skb, fraglen);
-			skb_set_network_header(skb, exthdrlen);
-			data += fragheaderlen;
+			data = skb_put(skb, fraglen + dst_exthdrlen);
+			skb_set_network_header(skb, exthdrlen + dst_exthdrlen);
+			data += fragheaderlen + dst_exthdrlen;
 			skb->transport_header = (skb->network_header +
 						 fragheaderlen);
 			if (fraggap) {
@@ -1434,6 +1438,7 @@ alloc_new_skb:
 				pskb_trim_unique(skb_prev, maxfraglen);
 			}
 			copy = datalen - transhdrlen - fraggap;
+
 			if (copy < 0) {
 				err = -EINVAL;
 				kfree_skb(skb);
@@ -1448,6 +1453,7 @@ alloc_new_skb:
 			length -= datalen - fraggap;
 			transhdrlen = 0;
 			exthdrlen = 0;
+			dst_exthdrlen = 0;
 			csummode = CHECKSUM_NONE;
 
 			/*
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index 3486f62..6f7824e 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -542,8 +542,7 @@ static int rawv6_push_pending_frames(struct sock *sk, struct flowi6 *fl6,
 		goto out;
 
 	offset = rp->offset;
-	total_len = inet_sk(sk)->cork.base.length - (skb_network_header(skb) -
-						     skb->data);
+	total_len = inet_sk(sk)->cork.base.length;
 	if (offset >= total_len - 1) {
 		err = -EINVAL;
 		ip6_flush_pending_frames(sk);
-- 
1.7.0.4
