From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH] ipv6: fix incorrect ipsec transport mode fragment
Date: Mon, 14 May 2012 11:21:00 +0800
Message-ID: <1336965660-14201-1-git-send-email-gaofeng@cn.fujitsu.com>
References: <20120215104021.GC31660@secunet.com>
Cc: steffen.klassert@secunet.com, davem@davemloft.net,
	lw@cn.fujitsu.com, Gao feng <gaofeng@cn.fujitsu.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:19820 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753179Ab2ENDUc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 May 2012 23:20:32 -0400
In-Reply-To: <20120215104021.GC31660@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since commit 299b0767(ipv6: Fix IPsec slowpath fragmentation problem)
the fragment of ipsec transport mode packets is incorrect.
because tunnel mode needs IPsec headers and trailer for all fragments,
while on transport mode it is sufficient to add the headers to the
first fragment and the trailer to the last.

so modify mtu and maxfraglen base on ipsec mode and if fragment is first
or last.

with my test,it work well and does not trigger slow fragment path.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
---
 net/ipv6/ip6_output.c |   80 +++++++++++++++++++++++++++++++++++++-----------
 1 files changed, 61 insertions(+), 19 deletions(-)

diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index b7ca461..9416887 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -1191,19 +1191,23 @@ int ip6_append_data(struct sock *sk, int getfrag(void *from, char *to,
 	struct ipv6_pinfo *np = inet6_sk(sk);
 	struct inet_cork *cork;
 	struct sk_buff *skb;
-	unsigned int maxfraglen, fragheaderlen;
+	unsigned int maxfraglen, maxfraglen_prev, fragheaderlen;
 	int exthdrlen;
 	int dst_exthdrlen;
 	int hh_len;
-	int mtu;
+	int mtu, mtu_prev;
 	int copy;
 	int err;
 	int offset = 0;
 	int csummode = CHECKSUM_NONE;
 	__u8 tx_flags = 0;
-
+	bool transport_mode = false;
+	struct xfrm_state *x = rt->dst.xfrm;
 	if (flags&MSG_PROBE)
 		return 0;
+	if (x && x->props.mode == XFRM_MODE_TRANSPORT)
+		transport_mode = true;
+
 	cork = &inet->cork.base;
 	if (skb_queue_empty(&sk->sk_write_queue)) {
 		/*
@@ -1248,13 +1252,17 @@ int ip6_append_data(struct sock *sk, int getfrag(void *from, char *to,
 		inet->cork.fl.u.ip6 = *fl6;
 		np->cork.hop_limit = hlimit;
 		np->cork.tclass = tclass;
-		mtu = np->pmtudisc == IPV6_PMTUDISC_PROBE ?
-		      rt->dst.dev->mtu : dst_mtu(&rt->dst);
+		if (transport_mode)
+			mtu = np->pmtudisc == IPV6_PMTUDISC_PROBE ?
+			      rt->dst.dev->mtu : dst_mtu(rt->dst.path);
+		else
+			mtu = np->pmtudisc == IPV6_PMTUDISC_PROBE ?
+			      rt->dst.dev->mtu : dst_mtu(&rt->dst);
 		if (np->frag_size < mtu) {
 			if (np->frag_size)
 				mtu = np->frag_size;
 		}
-		cork->fragsize = mtu;
+		mtu_prev = cork->fragsize = mtu;
 		if (dst_allfrag(rt->dst.path))
 			cork->flags |= IPCORK_ALLFRAG;
 		cork->length = 0;
@@ -1271,14 +1279,15 @@ int ip6_append_data(struct sock *sk, int getfrag(void *from, char *to,
 		transhdrlen = 0;
 		exthdrlen = 0;
 		dst_exthdrlen = 0;
-		mtu = cork->fragsize;
+		mtu_prev = mtu = cork->fragsize;
 	}
 
 	hh_len = LL_RESERVED_SPACE(rt->dst.dev);
 
 	fragheaderlen = sizeof(struct ipv6hdr) + rt->rt6i_nfheader_len +
 			(opt ? opt->opt_nflen : 0);
-	maxfraglen = ((mtu - fragheaderlen) & ~7) + fragheaderlen - sizeof(struct frag_hdr);
+	maxfraglen_prev = maxfraglen = ((mtu - fragheaderlen) & ~7)
+				       + fragheaderlen - sizeof(struct frag_hdr);
 
 	if (mtu <= sizeof(struct ipv6hdr) + IPV6_MAXPLEN) {
 		if (cork->length + length > sizeof(struct ipv6hdr) + IPV6_MAXPLEN - fragheaderlen) {
@@ -1329,15 +1338,27 @@ int ip6_append_data(struct sock *sk, int getfrag(void *from, char *to,
 			return 0;
 		}
 	}
-
-	if ((skb = skb_peek_tail(&sk->sk_write_queue)) == NULL)
+	skb = skb_peek_tail(&sk->sk_write_queue);
+	if (skb == NULL) {
+		if (transport_mode) {
+			/*
+			 * transport mode the first ipsec fragment should contain
+			 * ipsec header, so decrease dst_exthdrlen from mtu.
+			 */
+			mtu -= dst_exthdrlen;
+			mtu_prev = mtu;
+			maxfraglen = ((mtu - fragheaderlen) & ~7)
+				     + fragheaderlen - sizeof(struct frag_hdr);
+			maxfraglen_prev = maxfraglen;
+		}
 		goto alloc_new_skb;
+	}
 
 	while (length > 0) {
 		/* Check if the remaining data fits into current packet. */
-		copy = (cork->length <= mtu && !(cork->flags & IPCORK_ALLFRAG) ? mtu : maxfraglen) - skb->len;
+		copy = (cork->length <= mtu_prev && !(cork->flags & IPCORK_ALLFRAG) ? mtu_prev : maxfraglen_prev) - skb->len;
 		if (copy < length)
-			copy = maxfraglen - skb->len;
+			copy = maxfraglen_prev - skb->len;
 
 		if (copy <= 0) {
 			char *data;
@@ -1351,7 +1372,7 @@ alloc_new_skb:
 
 			/* There's no room in the current skb */
 			if (skb_prev)
-				fraggap = skb_prev->len - maxfraglen;
+				fraggap = skb_prev->len - maxfraglen_prev;
 			else
 				fraggap = 0;
 
@@ -1360,10 +1381,14 @@ alloc_new_skb:
 			 * we know we need more fragment(s).
 			 */
 			datalen = length + fraggap;
-			if (datalen > (cork->length <= mtu && !(cork->flags & IPCORK_ALLFRAG) ? mtu : maxfraglen) - fragheaderlen)
-				datalen = maxfraglen - fragheaderlen;
+			if (datalen > (cork->length <= mtu && !(cork->flags & IPCORK_ALLFRAG) ? mtu : maxfraglen) - fragheaderlen) {
+				/*
+				 * decrease ipsec trailer here,
+				 * if it's not the last fragment, add trailer latter
+				 */
+				datalen = maxfraglen - fragheaderlen - rt->dst.trailer_len;
+			}
 
-			fraglen = datalen + fragheaderlen;
 			if ((flags & MSG_MORE) &&
 			    !(rt->dst.dev->features&NETIF_F_SG))
 				alloclen = mtu;
@@ -1377,9 +1402,15 @@ alloc_new_skb:
 			 * Note: we overallocate on fragments with MSG_MODE
 			 * because we have no idea if we're the last one.
 			 */
-			if (datalen == length + fraggap)
-				alloclen += rt->dst.trailer_len;
-
+			alloclen += rt->dst.trailer_len;
+			if (datalen != length + fraggap) {
+				/*
+				 * this fragment is not the last fragment,
+				 * add trailer to datalen
+				 */
+				datalen += rt->dst.trailer_len;
+			}
+			fraglen = datalen + fragheaderlen;
 			/*
 			 * We just reserve space for fragment header.
 			 * Note: this may be overallocation if the message
@@ -1452,6 +1483,17 @@ alloc_new_skb:
 
 			offset += copy;
 			length -= datalen - fraggap;
+
+			mtu_prev = mtu;
+			maxfraglen_prev = maxfraglen;
+			if (skb_prev == NULL && transport_mode) {
+				/*
+				 * transport mode the middle skb should not have
+				 * ipsec header and trailer, so update the mtu.
+				 */
+				mtu = dst_mtu(rt->dst.path);
+				maxfraglen = ((mtu - fragheaderlen) & ~7) + fragheaderlen - sizeof(struct frag_hdr);
+			}
 			transhdrlen = 0;
 			exthdrlen = 0;
 			dst_exthdrlen = 0;
-- 
1.7.7.6
