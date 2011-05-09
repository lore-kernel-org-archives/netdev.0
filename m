From: David Miller <davem@davemloft.net>
Subject: [PATCH 2/2] ipv4: Pass flow key down into ip_append_*().
Date: Sun, 08 May 2011 18:07:55 -0700 (PDT)
Message-ID: <20110508.180755.98868574.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54405
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932150Ab1EIBI1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 May 2011 21:08:27 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 689D724C087
	for <netdev@vger.kernel.org>; Sun,  8 May 2011 18:07:55 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This way rt->rt_dst accesses are unnecessary.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/ip.h     |    4 ++--
 net/ipv4/icmp.c      |    2 +-
 net/ipv4/ip_output.c |   18 ++++++++++--------
 net/ipv4/raw.c       |    2 +-
 net/ipv4/udp.c       |   12 +++++++-----
 5 files changed, 21 insertions(+), 17 deletions(-)

diff --git a/include/net/ip.h b/include/net/ip.h
index a425379..0b30d3a 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -106,7 +106,7 @@ extern int		__ip_local_out(struct sk_buff *skb);
 extern int		ip_local_out(struct sk_buff *skb);
 extern int		ip_queue_xmit(struct sk_buff *skb, struct flowi *fl);
 extern void		ip_init(void);
-extern int		ip_append_data(struct sock *sk,
+extern int		ip_append_data(struct sock *sk, struct flowi4 *fl4,
 				       int getfrag(void *from, char *to, int offset, int len,
 						   int odd, struct sk_buff *skb),
 				void *from, int len, int protolen,
@@ -114,7 +114,7 @@ extern int		ip_append_data(struct sock *sk,
 				struct rtable **rt,
 				unsigned int flags);
 extern int		ip_generic_getfrag(void *from, char *to, int offset, int len, int odd, struct sk_buff *skb);
-extern ssize_t		ip_append_page(struct sock *sk, struct page *page,
+extern ssize_t		ip_append_page(struct sock *sk, struct flowi4 *fl4, struct page *page,
 				int offset, size_t size, int flags);
 extern struct sk_buff  *__ip_make_skb(struct sock *sk,
 				      struct flowi4 *fl4,
diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index b3dc6de..67ad66a 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -297,7 +297,7 @@ static void icmp_push_reply(struct icmp_bxm *icmp_param,
 	struct sk_buff *skb;
 
 	sk = icmp_sk(dev_net((*rt)->dst.dev));
-	if (ip_append_data(sk, icmp_glue_bits, icmp_param,
+	if (ip_append_data(sk, fl4, icmp_glue_bits, icmp_param,
 			   icmp_param->data_len+icmp_param->head_len,
 			   icmp_param->head_len,
 			   ipc, rt, MSG_DONTWAIT) < 0) {
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index dca637b..cd89d22 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -776,7 +776,9 @@ static inline int ip_ufo_append_data(struct sock *sk,
 				       (length - transhdrlen));
 }
 
-static int __ip_append_data(struct sock *sk, struct sk_buff_head *queue,
+static int __ip_append_data(struct sock *sk,
+			    struct flowi4 *fl4,
+			    struct sk_buff_head *queue,
 			    struct inet_cork *cork,
 			    int getfrag(void *from, char *to, int offset,
 					int len, int odd, struct sk_buff *skb),
@@ -808,7 +810,7 @@ static int __ip_append_data(struct sock *sk, struct sk_buff_head *queue,
 	maxfraglen = ((mtu - fragheaderlen) & ~7) + fragheaderlen;
 
 	if (cork->length + length > 0xFFFF - fragheaderlen) {
-		ip_local_error(sk, EMSGSIZE, rt->rt_dst, inet->inet_dport,
+		ip_local_error(sk, EMSGSIZE, fl4->daddr, inet->inet_dport,
 			       mtu-exthdrlen);
 		return -EMSGSIZE;
 	}
@@ -1083,7 +1085,7 @@ static int ip_setup_cork(struct sock *sk, struct inet_cork *cork,
  *
  *	LATER: length must be adjusted by pad at tail, when it is required.
  */
-int ip_append_data(struct sock *sk,
+int ip_append_data(struct sock *sk, struct flowi4 *fl4,
 		   int getfrag(void *from, char *to, int offset, int len,
 			       int odd, struct sk_buff *skb),
 		   void *from, int length, int transhdrlen,
@@ -1104,11 +1106,11 @@ int ip_append_data(struct sock *sk,
 		transhdrlen = 0;
 	}
 
-	return __ip_append_data(sk, &sk->sk_write_queue, &inet->cork.base, getfrag,
+	return __ip_append_data(sk, fl4, &sk->sk_write_queue, &inet->cork.base, getfrag,
 				from, length, transhdrlen, flags);
 }
 
-ssize_t	ip_append_page(struct sock *sk, struct page *page,
+ssize_t	ip_append_page(struct sock *sk, struct flowi4 *fl4, struct page *page,
 		       int offset, size_t size, int flags)
 {
 	struct inet_sock *inet = inet_sk(sk);
@@ -1146,7 +1148,7 @@ ssize_t	ip_append_page(struct sock *sk, struct page *page,
 	maxfraglen = ((mtu - fragheaderlen) & ~7) + fragheaderlen;
 
 	if (cork->length + size > 0xFFFF - fragheaderlen) {
-		ip_local_error(sk, EMSGSIZE, rt->rt_dst, inet->inet_dport, mtu);
+		ip_local_error(sk, EMSGSIZE, fl4->daddr, inet->inet_dport, mtu);
 		return -EMSGSIZE;
 	}
 
@@ -1427,7 +1429,7 @@ struct sk_buff *ip_make_skb(struct sock *sk,
 	if (err)
 		return ERR_PTR(err);
 
-	err = __ip_append_data(sk, &queue, &cork, getfrag,
+	err = __ip_append_data(sk, fl4, &queue, &cork, getfrag,
 			       from, length, transhdrlen, flags);
 	if (err) {
 		__ip_flush_pending_frames(sk, &queue, &cork);
@@ -1503,7 +1505,7 @@ void ip_send_reply(struct sock *sk, struct sk_buff *skb, struct ip_reply_arg *ar
 	sk->sk_priority = skb->priority;
 	sk->sk_protocol = ip_hdr(skb)->protocol;
 	sk->sk_bound_dev_if = arg->bound_dev_if;
-	ip_append_data(sk, ip_reply_glue_bits, arg->iov->iov_base, len, 0,
+	ip_append_data(sk, &fl4, ip_reply_glue_bits, arg->iov->iov_base, len, 0,
 		       &ipc, &rt, MSG_DONTWAIT);
 	if ((skb = skb_peek(&sk->sk_write_queue)) != NULL) {
 		if (arg->csumoffset >= 0)
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index 6fee91f..11e17804 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -595,7 +595,7 @@ back_from_confirm:
 		if (!ipc.addr)
 			ipc.addr = fl4.daddr;
 		lock_sock(sk);
-		err = ip_append_data(sk, ip_generic_getfrag,
+		err = ip_append_data(sk, &fl4, ip_generic_getfrag,
 				     msg->msg_iov, len, 0,
 				     &ipc, &rt, msg->msg_flags);
 		if (err)
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 006e2cc..66341a3 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -822,6 +822,7 @@ int udp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 
 	getfrag = is_udplite ? udplite_getfrag : ip_generic_getfrag;
 
+	fl4 = &inet->cork.fl.u.ip4;
 	if (up->pending) {
 		/*
 		 * There are pending frames.
@@ -920,7 +921,6 @@ int udp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 	if (connected)
 		rt = (struct rtable *)sk_dst_check(sk, 0);
 
-	fl4 = &inet->cork.fl.u.ip4;
 	if (rt == NULL) {
 		struct net *net = sock_net(sk);
 
@@ -989,9 +989,9 @@ back_from_confirm:
 
 do_append_data:
 	up->len += ulen;
-	err = ip_append_data(sk, getfrag, msg->msg_iov, ulen,
-			sizeof(struct udphdr), &ipc, &rt,
-			corkreq ? msg->msg_flags|MSG_MORE : msg->msg_flags);
+	err = ip_append_data(sk, fl4, getfrag, msg->msg_iov, ulen,
+			     sizeof(struct udphdr), &ipc, &rt,
+			     corkreq ? msg->msg_flags|MSG_MORE : msg->msg_flags);
 	if (err)
 		udp_flush_pending_frames(sk);
 	else if (!corkreq)
@@ -1031,6 +1031,7 @@ EXPORT_SYMBOL(udp_sendmsg);
 int udp_sendpage(struct sock *sk, struct page *page, int offset,
 		 size_t size, int flags)
 {
+	struct inet_sock *inet = inet_sk(sk);
 	struct udp_sock *up = udp_sk(sk);
 	int ret;
 
@@ -1055,7 +1056,8 @@ int udp_sendpage(struct sock *sk, struct page *page, int offset,
 		return -EINVAL;
 	}
 
-	ret = ip_append_page(sk, page, offset, size, flags);
+	ret = ip_append_page(sk, &inet->cork.fl.u.ip4,
+			     page, offset, size, flags);
 	if (ret == -EOPNOTSUPP) {
 		release_sock(sk);
 		return sock_no_sendpage(sk->sk_socket, page, offset,
-- 
1.7.5.1

