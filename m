From: David Miller <davem@davemloft.net>
Subject: [PATCH 1/2] inet: Decrease overhead of on-stack inet_cork.
Date: Fri, 06 May 2011 15:26:21 -0700 (PDT)
Message-ID: <20110506.152621.70194806.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, eric.dumazet@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37684
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753477Ab1EFW0x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 May 2011 18:26:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


When we fast path datagram sends to avoid locking by putting
the inet_cork on the stack we use up lots of space that isn't
necessary.

This is because inet_cork contains a "struct flowi" which isn't
used in these code paths.

Split inet_cork to two parts, "inet_cork" and "inet_cork_full".
Only the latter of which has the "struct flowi" and is what is
stored in inet_sock.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/inet_sock.h |   12 ++++++++----
 include/net/ip.h        |    2 +-
 net/ipv4/ip_output.c    |   22 ++++++++++++----------
 net/ipv6/ip6_output.c   |   34 ++++++++++++++++++----------------
 net/ipv6/raw.c          |    4 ++--
 5 files changed, 41 insertions(+), 33 deletions(-)

diff --git a/include/net/inet_sock.h b/include/net/inet_sock.h
index ed2ba6e..caaff5f 100644
--- a/include/net/inet_sock.h
+++ b/include/net/inet_sock.h
@@ -96,17 +96,21 @@ static inline struct inet_request_sock *inet_rsk(const struct request_sock *sk)
 
 struct inet_cork {
 	unsigned int		flags;
-	unsigned int		fragsize;
+	__be32			addr;
 	struct ip_options	*opt;
+	unsigned int		fragsize;
 	struct dst_entry	*dst;
 	int			length; /* Total length of all frames */
-	__be32			addr;
-	struct flowi		fl;
 	struct page		*page;
 	u32			off;
 	u8			tx_flags;
 };
 
+struct inet_cork_full {
+	struct inet_cork	base;
+	struct flowi		fl;
+};
+
 struct ip_mc_socklist;
 struct ipv6_pinfo;
 struct rtable;
@@ -164,7 +168,7 @@ struct inet_sock {
 	int			mc_index;
 	__be32			mc_addr;
 	struct ip_mc_socklist __rcu	*mc_list;
-	struct inet_cork	cork;
+	struct inet_cork_full	cork;
 };
 
 #define IPCORK_OPT	1	/* ip-options has been held in ipcork.opt */
diff --git a/include/net/ip.h b/include/net/ip.h
index 3a59bf9..095e392 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -132,7 +132,7 @@ extern struct sk_buff  *ip_make_skb(struct sock *sk,
 
 static inline struct sk_buff *ip_finish_skb(struct sock *sk)
 {
-	return __ip_make_skb(sk, &sk->sk_write_queue, &inet_sk(sk)->cork);
+	return __ip_make_skb(sk, &sk->sk_write_queue, &inet_sk(sk)->cork.base);
 }
 
 /* datagram.c */
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index db38c18..eb0647a 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -1096,14 +1096,14 @@ int ip_append_data(struct sock *sk,
 		return 0;
 
 	if (skb_queue_empty(&sk->sk_write_queue)) {
-		err = ip_setup_cork(sk, &inet->cork, ipc, rtp);
+		err = ip_setup_cork(sk, &inet->cork.base, ipc, rtp);
 		if (err)
 			return err;
 	} else {
 		transhdrlen = 0;
 	}
 
-	return __ip_append_data(sk, &sk->sk_write_queue, &inet->cork, getfrag,
+	return __ip_append_data(sk, &sk->sk_write_queue, &inet->cork.base, getfrag,
 				from, length, transhdrlen, flags);
 }
 
@@ -1114,6 +1114,7 @@ ssize_t	ip_append_page(struct sock *sk, struct page *page,
 	struct sk_buff *skb;
 	struct rtable *rt;
 	struct ip_options *opt = NULL;
+	struct inet_cork *cork;
 	int hh_len;
 	int mtu;
 	int len;
@@ -1129,20 +1130,21 @@ ssize_t	ip_append_page(struct sock *sk, struct page *page,
 	if (skb_queue_empty(&sk->sk_write_queue))
 		return -EINVAL;
 
-	rt = (struct rtable *)inet->cork.dst;
-	if (inet->cork.flags & IPCORK_OPT)
-		opt = inet->cork.opt;
+	cork = &inet->cork.base;
+	rt = (struct rtable *)cork->dst;
+	if (cork->flags & IPCORK_OPT)
+		opt = cork->opt;
 
 	if (!(rt->dst.dev->features&NETIF_F_SG))
 		return -EOPNOTSUPP;
 
 	hh_len = LL_RESERVED_SPACE(rt->dst.dev);
-	mtu = inet->cork.fragsize;
+	mtu = cork->fragsize;
 
 	fragheaderlen = sizeof(struct iphdr) + (opt ? opt->optlen : 0);
 	maxfraglen = ((mtu - fragheaderlen) & ~7) + fragheaderlen;
 
-	if (inet->cork.length + size > 0xFFFF - fragheaderlen) {
+	if (cork->length + size > 0xFFFF - fragheaderlen) {
 		ip_local_error(sk, EMSGSIZE, rt->rt_dst, inet->inet_dport, mtu);
 		return -EMSGSIZE;
 	}
@@ -1150,7 +1152,7 @@ ssize_t	ip_append_page(struct sock *sk, struct page *page,
 	if ((skb = skb_peek_tail(&sk->sk_write_queue)) == NULL)
 		return -EINVAL;
 
-	inet->cork.length += size;
+	cork->length += size;
 	if ((size + skb->len > mtu) &&
 	    (sk->sk_protocol == IPPROTO_UDP) &&
 	    (rt->dst.dev->features & NETIF_F_UFO)) {
@@ -1245,7 +1247,7 @@ ssize_t	ip_append_page(struct sock *sk, struct page *page,
 	return 0;
 
 error:
-	inet->cork.length -= size;
+	cork->length -= size;
 	IP_INC_STATS(sock_net(sk), IPSTATS_MIB_OUTDISCARDS);
 	return err;
 }
@@ -1396,7 +1398,7 @@ static void __ip_flush_pending_frames(struct sock *sk,
 
 void ip_flush_pending_frames(struct sock *sk)
 {
-	__ip_flush_pending_frames(sk, &sk->sk_write_queue, &inet_sk(sk)->cork);
+	__ip_flush_pending_frames(sk, &sk->sk_write_queue, &inet_sk(sk)->cork.base);
 }
 
 struct sk_buff *ip_make_skb(struct sock *sk,
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 4cfbb24..9d4b165 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -1150,6 +1150,7 @@ int ip6_append_data(struct sock *sk, int getfrag(void *from, char *to,
 {
 	struct inet_sock *inet = inet_sk(sk);
 	struct ipv6_pinfo *np = inet6_sk(sk);
+	struct inet_cork *cork;
 	struct sk_buff *skb;
 	unsigned int maxfraglen, fragheaderlen;
 	int exthdrlen;
@@ -1163,6 +1164,7 @@ int ip6_append_data(struct sock *sk, int getfrag(void *from, char *to,
 
 	if (flags&MSG_PROBE)
 		return 0;
+	cork = &inet->cork.base;
 	if (skb_queue_empty(&sk->sk_write_queue)) {
 		/*
 		 * setup for corking
@@ -1202,7 +1204,7 @@ int ip6_append_data(struct sock *sk, int getfrag(void *from, char *to,
 			/* need source address above miyazawa*/
 		}
 		dst_hold(&rt->dst);
-		inet->cork.dst = &rt->dst;
+		cork->dst = &rt->dst;
 		inet->cork.fl.u.ip6 = *fl6;
 		np->cork.hop_limit = hlimit;
 		np->cork.tclass = tclass;
@@ -1212,10 +1214,10 @@ int ip6_append_data(struct sock *sk, int getfrag(void *from, char *to,
 			if (np->frag_size)
 				mtu = np->frag_size;
 		}
-		inet->cork.fragsize = mtu;
+		cork->fragsize = mtu;
 		if (dst_allfrag(rt->dst.path))
-			inet->cork.flags |= IPCORK_ALLFRAG;
-		inet->cork.length = 0;
+			cork->flags |= IPCORK_ALLFRAG;
+		cork->length = 0;
 		sk->sk_sndmsg_page = NULL;
 		sk->sk_sndmsg_off = 0;
 		exthdrlen = rt->dst.header_len + (opt ? opt->opt_flen : 0) -
@@ -1223,12 +1225,12 @@ int ip6_append_data(struct sock *sk, int getfrag(void *from, char *to,
 		length += exthdrlen;
 		transhdrlen += exthdrlen;
 	} else {
-		rt = (struct rt6_info *)inet->cork.dst;
+		rt = (struct rt6_info *)cork->dst;
 		fl6 = &inet->cork.fl.u.ip6;
 		opt = np->cork.opt;
 		transhdrlen = 0;
 		exthdrlen = 0;
-		mtu = inet->cork.fragsize;
+		mtu = cork->fragsize;
 	}
 
 	hh_len = LL_RESERVED_SPACE(rt->dst.dev);
@@ -1238,7 +1240,7 @@ int ip6_append_data(struct sock *sk, int getfrag(void *from, char *to,
 	maxfraglen = ((mtu - fragheaderlen) & ~7) + fragheaderlen - sizeof(struct frag_hdr);
 
 	if (mtu <= sizeof(struct ipv6hdr) + IPV6_MAXPLEN) {
-		if (inet->cork.length + length > sizeof(struct ipv6hdr) + IPV6_MAXPLEN - fragheaderlen) {
+		if (cork->length + length > sizeof(struct ipv6hdr) + IPV6_MAXPLEN - fragheaderlen) {
 			ipv6_local_error(sk, EMSGSIZE, fl6, mtu-exthdrlen);
 			return -EMSGSIZE;
 		}
@@ -1267,7 +1269,7 @@ int ip6_append_data(struct sock *sk, int getfrag(void *from, char *to,
 	 * --yoshfuji
 	 */
 
-	inet->cork.length += length;
+	cork->length += length;
 	if (length > mtu) {
 		int proto = sk->sk_protocol;
 		if (dontfrag && (proto == IPPROTO_UDP || proto == IPPROTO_RAW)){
@@ -1292,7 +1294,7 @@ int ip6_append_data(struct sock *sk, int getfrag(void *from, char *to,
 
 	while (length > 0) {
 		/* Check if the remaining data fits into current packet. */
-		copy = (inet->cork.length <= mtu && !(inet->cork.flags & IPCORK_ALLFRAG) ? mtu : maxfraglen) - skb->len;
+		copy = (cork->length <= mtu && !(cork->flags & IPCORK_ALLFRAG) ? mtu : maxfraglen) - skb->len;
 		if (copy < length)
 			copy = maxfraglen - skb->len;
 
@@ -1317,7 +1319,7 @@ alloc_new_skb:
 			 * we know we need more fragment(s).
 			 */
 			datalen = length + fraggap;
-			if (datalen > (inet->cork.length <= mtu && !(inet->cork.flags & IPCORK_ALLFRAG) ? mtu : maxfraglen) - fragheaderlen)
+			if (datalen > (cork->length <= mtu && !(cork->flags & IPCORK_ALLFRAG) ? mtu : maxfraglen) - fragheaderlen)
 				datalen = maxfraglen - fragheaderlen;
 
 			fraglen = datalen + fragheaderlen;
@@ -1481,7 +1483,7 @@ alloc_new_skb:
 	}
 	return 0;
 error:
-	inet->cork.length -= length;
+	cork->length -= length;
 	IP6_INC_STATS(sock_net(sk), rt->rt6i_idev, IPSTATS_MIB_OUTDISCARDS);
 	return err;
 }
@@ -1497,10 +1499,10 @@ static void ip6_cork_release(struct inet_sock *inet, struct ipv6_pinfo *np)
 		np->cork.opt = NULL;
 	}
 
-	if (inet->cork.dst) {
-		dst_release(inet->cork.dst);
-		inet->cork.dst = NULL;
-		inet->cork.flags &= ~IPCORK_ALLFRAG;
+	if (inet->cork.base.dst) {
+		dst_release(inet->cork.base.dst);
+		inet->cork.base.dst = NULL;
+		inet->cork.base.flags &= ~IPCORK_ALLFRAG;
 	}
 	memset(&inet->cork.fl, 0, sizeof(inet->cork.fl));
 }
@@ -1515,7 +1517,7 @@ int ip6_push_pending_frames(struct sock *sk)
 	struct net *net = sock_net(sk);
 	struct ipv6hdr *hdr;
 	struct ipv6_txoptions *opt = np->cork.opt;
-	struct rt6_info *rt = (struct rt6_info *)inet->cork.dst;
+	struct rt6_info *rt = (struct rt6_info *)inet->cork.base.dst;
 	struct flowi6 *fl6 = &inet->cork.fl.u.ip6;
 	unsigned char proto = fl6->flowi6_proto;
 	int err = 0;
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index e5e5425..ae64984 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -542,8 +542,8 @@ static int rawv6_push_pending_frames(struct sock *sk, struct flowi6 *fl6,
 		goto out;
 
 	offset = rp->offset;
-	total_len = inet_sk(sk)->cork.length - (skb_network_header(skb) -
-						skb->data);
+	total_len = inet_sk(sk)->cork.base.length - (skb_network_header(skb) -
+						     skb->data);
 	if (offset >= total_len - 1) {
 		err = -EINVAL;
 		ip6_flush_pending_frames(sk);
-- 
1.7.5.1

