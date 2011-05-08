From: David Miller <davem@davemloft.net>
Subject: [PATCH 12/15] inet: Pass flowi to ->queue_xmit().
Date: Sun, 08 May 2011 15:37:51 -0700 (PDT)
Message-ID: <20110508.153751.28793244.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42662
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755763Ab1EHWiY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 May 2011 18:38:24 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id F357424C087
	for <netdev@vger.kernel.org>; Sun,  8 May 2011 15:37:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This allows us to acquire the exact route keying information from the
protocol, however that might be managed.

It handles all of the possibilities, from the simplest case of storing
the key in inet->cork.fl to the more complex setup SCTP has where
individual transports determine the flow.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/inet6_connection_sock.h |    2 +-
 include/net/inet_connection_sock.h  |    2 +-
 include/net/ip.h                    |    2 +-
 net/dccp/output.c                   |    4 ++--
 net/ipv4/ip_output.c                |    4 ++--
 net/ipv4/tcp_output.c               |    2 +-
 net/ipv6/inet6_connection_sock.c    |    2 +-
 net/l2tp/l2tp_core.c                |   10 ++++++----
 net/l2tp/l2tp_ip.c                  |    2 +-
 net/sctp/protocol.c                 |    2 +-
 10 files changed, 17 insertions(+), 15 deletions(-)

diff --git a/include/net/inet6_connection_sock.h b/include/net/inet6_connection_sock.h
index ff01350..3207e58 100644
--- a/include/net/inet6_connection_sock.h
+++ b/include/net/inet6_connection_sock.h
@@ -41,5 +41,5 @@ extern void inet6_csk_reqsk_queue_hash_add(struct sock *sk,
 
 extern void inet6_csk_addr2sockaddr(struct sock *sk, struct sockaddr *uaddr);
 
-extern int inet6_csk_xmit(struct sk_buff *skb);
+extern int inet6_csk_xmit(struct sk_buff *skb, struct flowi *fl);
 #endif /* _INET6_CONNECTION_SOCK_H */
diff --git a/include/net/inet_connection_sock.h b/include/net/inet_connection_sock.h
index 4367d91..96546ca 100644
--- a/include/net/inet_connection_sock.h
+++ b/include/net/inet_connection_sock.h
@@ -36,7 +36,7 @@ struct tcp_congestion_ops;
  * (i.e. things that depend on the address family)
  */
 struct inet_connection_sock_af_ops {
-	int	    (*queue_xmit)(struct sk_buff *skb);
+	int	    (*queue_xmit)(struct sk_buff *skb, struct flowi *fl);
 	void	    (*send_check)(struct sock *sk, struct sk_buff *skb);
 	int	    (*rebuild_header)(struct sock *sk);
 	int	    (*conn_request)(struct sock *sk, struct sk_buff *skb);
diff --git a/include/net/ip.h b/include/net/ip.h
index 095e392..acf8b78 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -104,7 +104,7 @@ extern int		ip_do_nat(struct sk_buff *skb);
 extern void		ip_send_check(struct iphdr *ip);
 extern int		__ip_local_out(struct sk_buff *skb);
 extern int		ip_local_out(struct sk_buff *skb);
-extern int		ip_queue_xmit(struct sk_buff *skb);
+extern int		ip_queue_xmit(struct sk_buff *skb, struct flowi *fl);
 extern void		ip_init(void);
 extern int		ip_append_data(struct sock *sk,
 				       int getfrag(void *from, char *to, int offset, int len,
diff --git a/net/dccp/output.c b/net/dccp/output.c
index 136d41c..fab108e 100644
--- a/net/dccp/output.c
+++ b/net/dccp/output.c
@@ -43,7 +43,7 @@ static void dccp_skb_entail(struct sock *sk, struct sk_buff *skb)
 static int dccp_transmit_skb(struct sock *sk, struct sk_buff *skb)
 {
 	if (likely(skb != NULL)) {
-		const struct inet_sock *inet = inet_sk(sk);
+		struct inet_sock *inet = inet_sk(sk);
 		const struct inet_connection_sock *icsk = inet_csk(sk);
 		struct dccp_sock *dp = dccp_sk(sk);
 		struct dccp_skb_cb *dcb = DCCP_SKB_CB(skb);
@@ -136,7 +136,7 @@ static int dccp_transmit_skb(struct sock *sk, struct sk_buff *skb)
 
 		DCCP_INC_STATS(DCCP_MIB_OUTSEGS);
 
-		err = icsk->icsk_af_ops->queue_xmit(skb);
+		err = icsk->icsk_af_ops->queue_xmit(skb, &inet->cork.fl);
 		return net_xmit_eval(err);
 	}
 	return -ENOBUFS;
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 4ba26d4..14ee1e4 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -312,7 +312,7 @@ int ip_output(struct sk_buff *skb)
 			    !(IPCB(skb)->flags & IPSKB_REROUTED));
 }
 
-int ip_queue_xmit(struct sk_buff *skb)
+int ip_queue_xmit(struct sk_buff *skb, struct flowi *fl)
 {
 	struct sock *sk = skb->sk;
 	struct inet_sock *inet = inet_sk(sk);
@@ -332,7 +332,7 @@ int ip_queue_xmit(struct sk_buff *skb)
 		goto packet_routed;
 
 	/* Make sure we can route this packet. */
-	fl4 = &inet->cork.fl.u.ip4;
+	fl4 = &fl->u.ip4;
 	rt = (struct rtable *)__sk_dst_check(sk, 0);
 	if (rt == NULL) {
 		__be32 daddr;
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 17388c7..882e0b0 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -899,7 +899,7 @@ static int tcp_transmit_skb(struct sock *sk, struct sk_buff *skb, int clone_it,
 		TCP_ADD_STATS(sock_net(sk), TCP_MIB_OUTSEGS,
 			      tcp_skb_pcount(skb));
 
-	err = icsk->icsk_af_ops->queue_xmit(skb);
+	err = icsk->icsk_af_ops->queue_xmit(skb, &inet->cork.fl);
 	if (likely(err <= 0))
 		return err;
 
diff --git a/net/ipv6/inet6_connection_sock.c b/net/ipv6/inet6_connection_sock.c
index f2c5b0f..8a58e8c 100644
--- a/net/ipv6/inet6_connection_sock.c
+++ b/net/ipv6/inet6_connection_sock.c
@@ -203,7 +203,7 @@ struct dst_entry *__inet6_csk_dst_check(struct sock *sk, u32 cookie)
 	return dst;
 }
 
-int inet6_csk_xmit(struct sk_buff *skb)
+int inet6_csk_xmit(struct sk_buff *skb, struct flowi *fl_unused)
 {
 	struct sock *sk = skb->sk;
 	struct inet_sock *inet = inet_sk(sk);
diff --git a/net/l2tp/l2tp_core.c b/net/l2tp/l2tp_core.c
index 7853029..9be095e 100644
--- a/net/l2tp/l2tp_core.c
+++ b/net/l2tp/l2tp_core.c
@@ -954,7 +954,7 @@ static int l2tp_build_l2tpv3_header(struct l2tp_session *session, void *buf)
 }
 
 static int l2tp_xmit_core(struct l2tp_session *session, struct sk_buff *skb,
-			  size_t data_len)
+			  struct flowi *fl, size_t data_len)
 {
 	struct l2tp_tunnel *tunnel = session->tunnel;
 	unsigned int len = skb->len;
@@ -987,7 +987,7 @@ static int l2tp_xmit_core(struct l2tp_session *session, struct sk_buff *skb,
 
 	/* Queue the packet to IP for output */
 	skb->local_df = 1;
-	error = ip_queue_xmit(skb);
+	error = ip_queue_xmit(skb, fl);
 
 	/* Update stats */
 	if (error >= 0) {
@@ -1028,6 +1028,7 @@ int l2tp_xmit_skb(struct l2tp_session *session, struct sk_buff *skb, int hdr_len
 	int data_len = skb->len;
 	struct l2tp_tunnel *tunnel = session->tunnel;
 	struct sock *sk = tunnel->sock;
+	struct flowi *fl;
 	struct udphdr *uh;
 	struct inet_sock *inet;
 	__wsum csum;
@@ -1070,10 +1071,11 @@ int l2tp_xmit_skb(struct l2tp_session *session, struct sk_buff *skb, int hdr_len
 	skb_dst_drop(skb);
 	skb_dst_set(skb, dst_clone(__sk_dst_get(sk)));
 
+	inet = inet_sk(sk);
+	fl = &inet->cork.fl;
 	switch (tunnel->encap) {
 	case L2TP_ENCAPTYPE_UDP:
 		/* Setup UDP header */
-		inet = inet_sk(sk);
 		__skb_push(skb, sizeof(*uh));
 		skb_reset_transport_header(skb);
 		uh = udp_hdr(skb);
@@ -1111,7 +1113,7 @@ int l2tp_xmit_skb(struct l2tp_session *session, struct sk_buff *skb, int hdr_len
 
 	l2tp_skb_set_owner_w(skb, sk);
 
-	l2tp_xmit_core(session, skb, data_len);
+	l2tp_xmit_core(session, skb, fl, data_len);
 out_unlock:
 	bh_unlock_sock(sk);
 
diff --git a/net/l2tp/l2tp_ip.c b/net/l2tp/l2tp_ip.c
index 1ca7489..f7fb09e 100644
--- a/net/l2tp/l2tp_ip.c
+++ b/net/l2tp/l2tp_ip.c
@@ -508,7 +508,7 @@ static int l2tp_ip_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *m
 	skb_dst_set(skb, dst_clone(&rt->dst));
 
 	/* Queue the packet to IP for output */
-	rc = ip_queue_xmit(skb);
+	rc = ip_queue_xmit(skb, &inet->cork.fl);
 
 error:
 	/* Update stats */
diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index 69fbc55..847193b 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -855,7 +855,7 @@ static inline int sctp_v4_xmit(struct sk_buff *skb,
 			 IP_PMTUDISC_DO : IP_PMTUDISC_DONT;
 
 	SCTP_INC_STATS(SCTP_MIB_OUTSCTPPACKS);
-	return ip_queue_xmit(skb);
+	return ip_queue_xmit(skb, &transport->fl);
 }
 
 static struct sctp_af sctp_af_inet;
-- 
1.7.5.1

