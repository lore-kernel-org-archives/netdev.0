From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net v2 3/4] ipv6: no CHECKSUM_PARTIAL on MSG_MORE corked sockets
Date: Tue, 27 Oct 2015 16:02:14 +0100
Message-ID: <1445958135-19805-4-git-send-email-hannes@stressinduktion.org>
References: <1445958135-19805-1-git-send-email-hannes@stressinduktion.org>
Cc: edumazet@google.com, vyasevich@gmail.com, bcodding@redhat.com,
	tom@herbertland.com,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:43851 "EHLO
	out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932435AbbJ0PC0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Oct 2015 11:02:26 -0400
Received: from compute4.internal (compute4.nyi.internal [10.202.2.44])
	by mailout.nyi.internal (Postfix) with ESMTP id 4B257215D4
	for <netdev@vger.kernel.org>; Tue, 27 Oct 2015 11:02:26 -0400 (EDT)
In-Reply-To: <1445958135-19805-1-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We cannot reliable calculate packet size on MSG_MORE corked sockets
and thus cannot decide if they are going to be fragmented later on,
so better not use CHECKSUM_PARTIAL in the first place.

The IPv6 code also intended to protect and not use CHECKSUM_PARTIAL in
the existence of IPv6 extension headers, but the condition was wrong. Fix
it up, too. Also the condition to check whether the packet fits into
one fragment was wrong and has been corrected.

Fixes: commit 32dce968dd987 ("ipv6: Allow for partial checksums on non-ufo packets")
See-also: commit 72e843bb09d45 ("ipv6: ip6_fragment() should check CHECKSUM_PARTIAL")
Cc: Eric Dumazet <edumazet@google.com>
Cc: Vlad Yasevich <vyasevich@gmail.com>
Cc: Benjamin Coddington <bcodding@redhat.com>
Cc: Tom Herbert <tom@herbertland.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/ipv6/ip6_output.c | 70 ++++++++++++++++++++++++---------------------------
 1 file changed, 33 insertions(+), 37 deletions(-)

diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index c265068..9828a71 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -1272,6 +1272,7 @@ static int __ip6_append_data(struct sock *sk,
 	struct rt6_info *rt = (struct rt6_info *)cork->dst;
 	struct ipv6_txoptions *opt = v6_cork->opt;
 	int csummode = CHECKSUM_NONE;
+	unsigned int maxnonfragsize, headersize;
 
 	skb = skb_peek_tail(queue);
 	if (!skb) {
@@ -1289,38 +1290,43 @@ static int __ip6_append_data(struct sock *sk,
 	maxfraglen = ((mtu - fragheaderlen) & ~7) + fragheaderlen -
 		     sizeof(struct frag_hdr);
 
-	if (mtu <= sizeof(struct ipv6hdr) + IPV6_MAXPLEN) {
-		unsigned int maxnonfragsize, headersize;
-
-		headersize = sizeof(struct ipv6hdr) +
-			     (opt ? opt->opt_flen + opt->opt_nflen : 0) +
-			     (dst_allfrag(&rt->dst) ?
-			      sizeof(struct frag_hdr) : 0) +
-			     rt->rt6i_nfheader_len;
-
-		if (ip6_sk_ignore_df(sk))
-			maxnonfragsize = sizeof(struct ipv6hdr) + IPV6_MAXPLEN;
-		else
-			maxnonfragsize = mtu;
+	headersize = sizeof(struct ipv6hdr) +
+		     (opt ? opt->opt_flen + opt->opt_nflen : 0) +
+		     (dst_allfrag(&rt->dst) ?
+		      sizeof(struct frag_hdr) : 0) +
+		     rt->rt6i_nfheader_len;
+
+	if (cork->length + length > mtu - headersize && dontfrag &&
+	    (sk->sk_protocol == IPPROTO_UDP ||
+	     sk->sk_protocol == IPPROTO_RAW)) {
+		ipv6_local_rxpmtu(sk, fl6, mtu - headersize +
+				sizeof(struct ipv6hdr));
+		goto emsgsize;
+	}
 
-		/* dontfrag active */
-		if ((cork->length + length > mtu - headersize) && dontfrag &&
-		    (sk->sk_protocol == IPPROTO_UDP ||
-		     sk->sk_protocol == IPPROTO_RAW)) {
-			ipv6_local_rxpmtu(sk, fl6, mtu - headersize +
-						   sizeof(struct ipv6hdr));
-			goto emsgsize;
-		}
+	if (ip6_sk_ignore_df(sk))
+		maxnonfragsize = sizeof(struct ipv6hdr) + IPV6_MAXPLEN;
+	else
+		maxnonfragsize = mtu;
 
-		if (cork->length + length > maxnonfragsize - headersize) {
+	if (cork->length + length > maxnonfragsize - headersize) {
 emsgsize:
-			ipv6_local_error(sk, EMSGSIZE, fl6,
-					 mtu - headersize +
-					 sizeof(struct ipv6hdr));
-			return -EMSGSIZE;
-		}
+		ipv6_local_error(sk, EMSGSIZE, fl6,
+				 mtu - headersize +
+				 sizeof(struct ipv6hdr));
+		return -EMSGSIZE;
 	}
 
+	/* CHECKSUM_PARTIAL only with no extension headers and when
+	 * we are not going to fragment
+	 */
+	if (transhdrlen && sk->sk_protocol == IPPROTO_UDP &&
+	    headersize == sizeof(struct ipv6hdr) &&
+	    length < mtu - headersize &&
+	    !(flags & MSG_MORE) &&
+	    rt->dst.dev->features & NETIF_F_V6_CSUM)
+		csummode = CHECKSUM_PARTIAL;
+
 	if (sk->sk_type == SOCK_DGRAM || sk->sk_type == SOCK_RAW) {
 		sock_tx_timestamp(sk, &tx_flags);
 		if (tx_flags & SKBTX_ANY_SW_TSTAMP &&
@@ -1328,16 +1334,6 @@ emsgsize:
 			tskey = sk->sk_tskey++;
 	}
 
-	/* If this is the first and only packet and device
-	 * supports checksum offloading, let's use it.
-	 * Use transhdrlen, same as IPv4, because partial
-	 * sums only work when transhdrlen is set.
-	 */
-	if (transhdrlen && sk->sk_protocol == IPPROTO_UDP &&
-	    length + fragheaderlen < mtu &&
-	    rt->dst.dev->features & NETIF_F_V6_CSUM &&
-	    !exthdrlen)
-		csummode = CHECKSUM_PARTIAL;
 	/*
 	 * Let's try using as much space as possible.
 	 * Use MTU if total length of the message fits into the MTU.
-- 
2.5.0
