From: David Miller <davem@davemloft.net>
Subject: [PATCH 1/2] ipv4: Pass flow keys down into datagram packet
 building engine.
Date: Sun, 08 May 2011 18:07:53 -0700 (PDT)
Message-ID: <20110508.180753.241908549.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54402
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932147Ab1EIBIZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 May 2011 21:08:25 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id B41B124C087
	for <netdev@vger.kernel.org>; Sun,  8 May 2011 18:07:53 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This way ip_output.c no longer needs rt->rt_{src,dst}.

We already have these keys sitting, ready and waiting, on the stack or
in a socket structure.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/ip.h     |    8 +++--
 net/ipv4/icmp.c      |   74 ++++++++++++++++++++++++-------------------------
 net/ipv4/ip_output.c |   39 +++++++++++++-------------
 net/ipv4/raw.c       |   59 +++++++++++++++++++--------------------
 net/ipv4/udp.c       |    4 +-
 5 files changed, 91 insertions(+), 93 deletions(-)

diff --git a/include/net/ip.h b/include/net/ip.h
index acf8b78..a425379 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -117,12 +117,14 @@ extern int		ip_generic_getfrag(void *from, char *to, int offset, int len, int od
 extern ssize_t		ip_append_page(struct sock *sk, struct page *page,
 				int offset, size_t size, int flags);
 extern struct sk_buff  *__ip_make_skb(struct sock *sk,
+				      struct flowi4 *fl4,
 				      struct sk_buff_head *queue,
 				      struct inet_cork *cork);
 extern int		ip_send_skb(struct sk_buff *skb);
-extern int		ip_push_pending_frames(struct sock *sk);
+extern int		ip_push_pending_frames(struct sock *sk, struct flowi4 *fl4);
 extern void		ip_flush_pending_frames(struct sock *sk);
 extern struct sk_buff  *ip_make_skb(struct sock *sk,
+				    struct flowi4 *fl4,
 				    int getfrag(void *from, char *to, int offset, int len,
 						int odd, struct sk_buff *skb),
 				    void *from, int length, int transhdrlen,
@@ -130,9 +132,9 @@ extern struct sk_buff  *ip_make_skb(struct sock *sk,
 				    struct rtable **rtp,
 				    unsigned int flags);
 
-static inline struct sk_buff *ip_finish_skb(struct sock *sk)
+static inline struct sk_buff *ip_finish_skb(struct sock *sk, struct flowi4 *fl4)
 {
-	return __ip_make_skb(sk, &sk->sk_write_queue, &inet_sk(sk)->cork.base);
+	return __ip_make_skb(sk, fl4, &sk->sk_write_queue, &inet_sk(sk)->cork.base);
 }
 
 /* datagram.c */
diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index cfeca3c..b3dc6de 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -290,6 +290,7 @@ static int icmp_glue_bits(void *from, char *to, int offset, int len, int odd,
 }
 
 static void icmp_push_reply(struct icmp_bxm *icmp_param,
+			    struct flowi4 *fl4,
 			    struct ipcm_cookie *ipc, struct rtable **rt)
 {
 	struct sock *sk;
@@ -315,7 +316,7 @@ static void icmp_push_reply(struct icmp_bxm *icmp_param,
 						 icmp_param->head_len, csum);
 		icmph->checksum = csum_fold(csum);
 		skb->ip_summed = CHECKSUM_NONE;
-		ip_push_pending_frames(sk);
+		ip_push_pending_frames(sk, fl4);
 	}
 }
 
@@ -328,6 +329,7 @@ static void icmp_reply(struct icmp_bxm *icmp_param, struct sk_buff *skb)
 	struct ipcm_cookie ipc;
 	struct rtable *rt = skb_rtable(skb);
 	struct net *net = dev_net(rt->dst.dev);
+	struct flowi4 fl4;
 	struct sock *sk;
 	struct inet_sock *inet;
 	__be32 daddr;
@@ -351,57 +353,52 @@ static void icmp_reply(struct icmp_bxm *icmp_param, struct sk_buff *skb)
 		if (ipc.opt->opt.srr)
 			daddr = icmp_param->replyopts.opt.opt.faddr;
 	}
-	{
-		struct flowi4 fl4 = {
-			.daddr = daddr,
-			.saddr = rt->rt_spec_dst,
-			.flowi4_tos = RT_TOS(ip_hdr(skb)->tos),
-			.flowi4_proto = IPPROTO_ICMP,
-		};
-		security_skb_classify_flow(skb, flowi4_to_flowi(&fl4));
-		rt = ip_route_output_key(net, &fl4);
-		if (IS_ERR(rt))
-			goto out_unlock;
-	}
+	memset(&fl4, 0, sizeof(fl4));
+	fl4.daddr = daddr;
+	fl4.saddr = rt->rt_spec_dst;
+	fl4.flowi4_tos = RT_TOS(ip_hdr(skb)->tos);
+	fl4.flowi4_proto = IPPROTO_ICMP;
+	security_skb_classify_flow(skb, flowi4_to_flowi(&fl4));
+	rt = ip_route_output_key(net, &fl4);
+	if (IS_ERR(rt))
+		goto out_unlock;
 	if (icmpv4_xrlim_allow(net, rt, icmp_param->data.icmph.type,
 			       icmp_param->data.icmph.code))
-		icmp_push_reply(icmp_param, &ipc, &rt);
+		icmp_push_reply(icmp_param, &fl4, &ipc, &rt);
 	ip_rt_put(rt);
 out_unlock:
 	icmp_xmit_unlock(sk);
 }
 
-static struct rtable *icmp_route_lookup(struct net *net, struct sk_buff *skb_in,
+static struct rtable *icmp_route_lookup(struct net *net,
+					struct flowi4 *fl4,
+					struct sk_buff *skb_in,
 					const struct iphdr *iph,
 					__be32 saddr, u8 tos,
 					int type, int code,
 					struct icmp_bxm *param)
 {
-	struct flowi4 fl4 = {
-		.daddr = (param->replyopts.opt.opt.srr ?
-			  param->replyopts.opt.opt.faddr : iph->saddr),
-		.saddr = saddr,
-		.flowi4_tos = RT_TOS(tos),
-		.flowi4_proto = IPPROTO_ICMP,
-		.fl4_icmp_type = type,
-		.fl4_icmp_code = code,
-	};
 	struct rtable *rt, *rt2;
 	int err;
 
-	security_skb_classify_flow(skb_in, flowi4_to_flowi(&fl4));
-	rt = __ip_route_output_key(net, &fl4);
+	memset(&fl4, 0, sizeof(fl4));
+	fl4->daddr = (param->replyopts.opt.opt.srr ?
+		      param->replyopts.opt.opt.faddr : iph->saddr);
+	fl4->saddr = saddr;
+	fl4->flowi4_tos = RT_TOS(tos);
+	fl4->flowi4_proto = IPPROTO_ICMP;
+	fl4->fl4_icmp_type = type;
+	fl4->fl4_icmp_code = code;
+	security_skb_classify_flow(skb_in, flowi4_to_flowi(fl4));
+	rt = __ip_route_output_key(net, fl4);
 	if (IS_ERR(rt))
 		return rt;
 
 	/* No need to clone since we're just using its address. */
 	rt2 = rt;
 
-	if (!fl4.saddr)
-		fl4.saddr = rt->rt_src;
-
 	rt = (struct rtable *) xfrm_lookup(net, &rt->dst,
-					   flowi4_to_flowi(&fl4), NULL, 0);
+					   flowi4_to_flowi(fl4), NULL, 0);
 	if (!IS_ERR(rt)) {
 		if (rt != rt2)
 			return rt;
@@ -410,19 +407,19 @@ static struct rtable *icmp_route_lookup(struct net *net, struct sk_buff *skb_in,
 	} else
 		return rt;
 
-	err = xfrm_decode_session_reverse(skb_in, flowi4_to_flowi(&fl4), AF_INET);
+	err = xfrm_decode_session_reverse(skb_in, flowi4_to_flowi(fl4), AF_INET);
 	if (err)
 		goto relookup_failed;
 
-	if (inet_addr_type(net, fl4.saddr) == RTN_LOCAL) {
-		rt2 = __ip_route_output_key(net, &fl4);
+	if (inet_addr_type(net, fl4->saddr) == RTN_LOCAL) {
+		rt2 = __ip_route_output_key(net, fl4);
 		if (IS_ERR(rt2))
 			err = PTR_ERR(rt2);
 	} else {
 		struct flowi4 fl4_2 = {};
 		unsigned long orefdst;
 
-		fl4_2.daddr = fl4.saddr;
+		fl4_2.daddr = fl4->saddr;
 		rt2 = ip_route_output_key(net, &fl4_2);
 		if (IS_ERR(rt2)) {
 			err = PTR_ERR(rt2);
@@ -430,7 +427,7 @@ static struct rtable *icmp_route_lookup(struct net *net, struct sk_buff *skb_in,
 		}
 		/* Ugh! */
 		orefdst = skb_in->_skb_refdst; /* save old refdst */
-		err = ip_route_input(skb_in, fl4.daddr, fl4.saddr,
+		err = ip_route_input(skb_in, fl4->daddr, fl4->saddr,
 				     RT_TOS(tos), rt2->dst.dev);
 
 		dst_release(&rt2->dst);
@@ -442,7 +439,7 @@ static struct rtable *icmp_route_lookup(struct net *net, struct sk_buff *skb_in,
 		goto relookup_failed;
 
 	rt2 = (struct rtable *) xfrm_lookup(net, &rt2->dst,
-					    flowi4_to_flowi(&fl4), NULL,
+					    flowi4_to_flowi(fl4), NULL,
 					    XFRM_LOOKUP_ICMP);
 	if (!IS_ERR(rt2)) {
 		dst_release(&rt->dst);
@@ -481,6 +478,7 @@ void icmp_send(struct sk_buff *skb_in, int type, int code, __be32 info)
 	struct icmp_bxm icmp_param;
 	struct rtable *rt = skb_rtable(skb_in);
 	struct ipcm_cookie ipc;
+	struct flowi4 fl4;
 	__be32 saddr;
 	u8  tos;
 	struct net *net;
@@ -599,7 +597,7 @@ void icmp_send(struct sk_buff *skb_in, int type, int code, __be32 info)
 	ipc.opt = &icmp_param.replyopts.opt;
 	ipc.tx_flags = 0;
 
-	rt = icmp_route_lookup(net, skb_in, iph, saddr, tos,
+	rt = icmp_route_lookup(net, &fl4, skb_in, iph, saddr, tos,
 			       type, code, &icmp_param);
 	if (IS_ERR(rt))
 		goto out_unlock;
@@ -620,7 +618,7 @@ void icmp_send(struct sk_buff *skb_in, int type, int code, __be32 info)
 		icmp_param.data_len = room;
 	icmp_param.head_len = sizeof(struct icmphdr);
 
-	icmp_push_reply(&icmp_param, &ipc, &rt);
+	icmp_push_reply(&icmp_param, &fl4, &ipc, &rt);
 ende:
 	ip_rt_put(rt);
 out_unlock:
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index b88ee5f..dca637b 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -1267,6 +1267,7 @@ static void ip_cork_release(struct inet_cork *cork)
  *	and push them out.
  */
 struct sk_buff *__ip_make_skb(struct sock *sk,
+			      struct flowi4 *fl4,
 			      struct sk_buff_head *queue,
 			      struct inet_cork *cork)
 {
@@ -1333,8 +1334,8 @@ struct sk_buff *__ip_make_skb(struct sock *sk,
 	ip_select_ident(iph, &rt->dst, sk);
 	iph->ttl = ttl;
 	iph->protocol = sk->sk_protocol;
-	iph->saddr = rt->rt_src;
-	iph->daddr = rt->rt_dst;
+	iph->saddr = fl4->saddr;
+	iph->daddr = fl4->daddr;
 
 	skb->priority = sk->sk_priority;
 	skb->mark = sk->sk_mark;
@@ -1370,11 +1371,11 @@ int ip_send_skb(struct sk_buff *skb)
 	return err;
 }
 
-int ip_push_pending_frames(struct sock *sk)
+int ip_push_pending_frames(struct sock *sk, struct flowi4 *fl4)
 {
 	struct sk_buff *skb;
 
-	skb = ip_finish_skb(sk);
+	skb = ip_finish_skb(sk, fl4);
 	if (!skb)
 		return 0;
 
@@ -1403,6 +1404,7 @@ void ip_flush_pending_frames(struct sock *sk)
 }
 
 struct sk_buff *ip_make_skb(struct sock *sk,
+			    struct flowi4 *fl4,
 			    int getfrag(void *from, char *to, int offset,
 					int len, int odd, struct sk_buff *skb),
 			    void *from, int length, int transhdrlen,
@@ -1432,7 +1434,7 @@ struct sk_buff *ip_make_skb(struct sock *sk,
 		return ERR_PTR(err);
 	}
 
-	return __ip_make_skb(sk, &queue, &cork);
+	return __ip_make_skb(sk, fl4, &queue, &cork);
 }
 
 /*
@@ -1461,6 +1463,7 @@ void ip_send_reply(struct sock *sk, struct sk_buff *skb, struct ip_reply_arg *ar
 	struct inet_sock *inet = inet_sk(sk);
 	struct ip_options_data replyopts;
 	struct ipcm_cookie ipc;
+	struct flowi4 fl4;
 	__be32 daddr;
 	struct rtable *rt = skb_rtable(skb);
 
@@ -1478,20 +1481,16 @@ void ip_send_reply(struct sock *sk, struct sk_buff *skb, struct ip_reply_arg *ar
 			daddr = replyopts.opt.opt.faddr;
 	}
 
-	{
-		struct flowi4 fl4;
-
-		flowi4_init_output(&fl4, arg->bound_dev_if, 0,
-				   RT_TOS(ip_hdr(skb)->tos),
-				   RT_SCOPE_UNIVERSE, sk->sk_protocol,
-				   ip_reply_arg_flowi_flags(arg),
-				   daddr, rt->rt_spec_dst,
-				   tcp_hdr(skb)->source, tcp_hdr(skb)->dest);
-		security_skb_classify_flow(skb, flowi4_to_flowi(&fl4));
-		rt = ip_route_output_key(sock_net(sk), &fl4);
-		if (IS_ERR(rt))
-			return;
-	}
+	flowi4_init_output(&fl4, arg->bound_dev_if, 0,
+			   RT_TOS(ip_hdr(skb)->tos),
+			   RT_SCOPE_UNIVERSE, sk->sk_protocol,
+			   ip_reply_arg_flowi_flags(arg),
+			   daddr, rt->rt_spec_dst,
+			   tcp_hdr(skb)->source, tcp_hdr(skb)->dest);
+	security_skb_classify_flow(skb, flowi4_to_flowi(&fl4));
+	rt = ip_route_output_key(sock_net(sk), &fl4);
+	if (IS_ERR(rt))
+		return;
 
 	/* And let IP do all the hard work.
 
@@ -1512,7 +1511,7 @@ void ip_send_reply(struct sock *sk, struct sk_buff *skb, struct ip_reply_arg *ar
 			  arg->csumoffset) = csum_fold(csum_add(skb->csum,
 								arg->csum));
 		skb->ip_summed = CHECKSUM_NONE;
-		ip_push_pending_frames(sk);
+		ip_push_pending_frames(sk, &fl4);
 	}
 
 	bh_unlock_sock(sk);
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index a8659e0..6fee91f 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -314,9 +314,10 @@ int raw_rcv(struct sock *sk, struct sk_buff *skb)
 	return 0;
 }
 
-static int raw_send_hdrinc(struct sock *sk, void *from, size_t length,
-			struct rtable **rtp,
-			unsigned int flags)
+static int raw_send_hdrinc(struct sock *sk, struct flowi4 *fl4,
+			   void *from, size_t length,
+			   struct rtable **rtp,
+			   unsigned int flags)
 {
 	struct inet_sock *inet = inet_sk(sk);
 	struct net *net = sock_net(sk);
@@ -327,7 +328,7 @@ static int raw_send_hdrinc(struct sock *sk, void *from, size_t length,
 	struct rtable *rt = *rtp;
 
 	if (length > rt->dst.dev->mtu) {
-		ip_local_error(sk, EMSGSIZE, rt->rt_dst, inet->inet_dport,
+		ip_local_error(sk, EMSGSIZE, fl4->daddr, inet->inet_dport,
 			       rt->dst.dev->mtu);
 		return -EMSGSIZE;
 	}
@@ -372,7 +373,7 @@ static int raw_send_hdrinc(struct sock *sk, void *from, size_t length,
 
 	if (iphlen >= sizeof(*iph)) {
 		if (!iph->saddr)
-			iph->saddr = rt->rt_src;
+			iph->saddr = fl4->saddr;
 		iph->check   = 0;
 		iph->tot_len = htons(length);
 		if (!iph->id)
@@ -455,6 +456,7 @@ static int raw_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 	struct inet_sock *inet = inet_sk(sk);
 	struct ipcm_cookie ipc;
 	struct rtable *rt = NULL;
+	struct flowi4 fl4;
 	int free = 0;
 	__be32 daddr;
 	__be32 saddr;
@@ -558,27 +560,23 @@ static int raw_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 			saddr = inet->mc_addr;
 	}
 
-	{
-		struct flowi4 fl4;
+	flowi4_init_output(&fl4, ipc.oif, sk->sk_mark, tos,
+			   RT_SCOPE_UNIVERSE,
+			   inet->hdrincl ? IPPROTO_RAW : sk->sk_protocol,
+			   FLOWI_FLAG_CAN_SLEEP, daddr, saddr, 0, 0);
 
-		flowi4_init_output(&fl4, ipc.oif, sk->sk_mark, tos,
-				   RT_SCOPE_UNIVERSE,
-				   inet->hdrincl ? IPPROTO_RAW : sk->sk_protocol,
-				   FLOWI_FLAG_CAN_SLEEP, daddr, saddr, 0, 0);
-
-		if (!inet->hdrincl) {
-			err = raw_probe_proto_opt(&fl4, msg);
-			if (err)
-				goto done;
-		}
-
-		security_sk_classify_flow(sk, flowi4_to_flowi(&fl4));
-		rt = ip_route_output_flow(sock_net(sk), &fl4, sk);
-		if (IS_ERR(rt)) {
-			err = PTR_ERR(rt);
-			rt = NULL;
+	if (!inet->hdrincl) {
+		err = raw_probe_proto_opt(&fl4, msg);
+		if (err)
 			goto done;
-		}
+	}
+
+	security_sk_classify_flow(sk, flowi4_to_flowi(&fl4));
+	rt = ip_route_output_flow(sock_net(sk), &fl4, sk);
+	if (IS_ERR(rt)) {
+		err = PTR_ERR(rt);
+		rt = NULL;
+		goto done;
 	}
 
 	err = -EACCES;
@@ -590,19 +588,20 @@ static int raw_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 back_from_confirm:
 
 	if (inet->hdrincl)
-		err = raw_send_hdrinc(sk, msg->msg_iov, len,
-					&rt, msg->msg_flags);
+		err = raw_send_hdrinc(sk, &fl4, msg->msg_iov, len,
+				      &rt, msg->msg_flags);
 
 	 else {
 		if (!ipc.addr)
-			ipc.addr = rt->rt_dst;
+			ipc.addr = fl4.daddr;
 		lock_sock(sk);
-		err = ip_append_data(sk, ip_generic_getfrag, msg->msg_iov, len, 0,
-					&ipc, &rt, msg->msg_flags);
+		err = ip_append_data(sk, ip_generic_getfrag,
+				     msg->msg_iov, len, 0,
+				     &ipc, &rt, msg->msg_flags);
 		if (err)
 			ip_flush_pending_frames(sk);
 		else if (!(msg->msg_flags & MSG_MORE)) {
-			err = ip_push_pending_frames(sk);
+			err = ip_push_pending_frames(sk, &fl4);
 			if (err == -ENOBUFS && !inet->recverr)
 				err = 0;
 		}
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index ba9f137..006e2cc 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -774,7 +774,7 @@ static int udp_push_pending_frames(struct sock *sk)
 	struct sk_buff *skb;
 	int err = 0;
 
-	skb = ip_finish_skb(sk);
+	skb = ip_finish_skb(sk, fl4);
 	if (!skb)
 		goto out;
 
@@ -958,7 +958,7 @@ back_from_confirm:
 
 	/* Lockless fast path for the non-corking case. */
 	if (!corkreq) {
-		skb = ip_make_skb(sk, getfrag, msg->msg_iov, ulen,
+		skb = ip_make_skb(sk, fl4, getfrag, msg->msg_iov, ulen,
 				  sizeof(struct udphdr), &ipc, &rt,
 				  msg->msg_flags);
 		err = PTR_ERR(skb);
-- 
1.7.5.1

