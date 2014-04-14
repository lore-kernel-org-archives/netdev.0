From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [BUG] A panic caused by null pointer dereference aftering
 updating to
Date: Mon, 14 Apr 2014 12:06:36 -0700
Message-ID: <1397502396.4222.45.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1397498082.4222.29.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140414.140253.788885546068554928.davem@davemloft.net>
	 <1397499566.4222.36.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140414.144843.488522666550066271.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: nasa4836@gmail.com, jchapman@katalix.com, edumazet@google.com,
	joe@perches.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140414.144843.488522666550066271.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2014-04-14 at 14:48 -0400, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Mon, 14 Apr 2014 11:19:26 -0700
> 
> > ip_local_out() doesn't use skb->sk
> 
> It does Eric.
> 

Hmmm, right...

> We had just such a report with this in the backtrace, when AF_PACKET
> sends over vxlan devices.
> 
> The problem is ip_mc_output().

So this means that : User socket wanted sk_mc_loop(sk), but because
vxlan changed skb->sk to internal socket, we were doing something else
anyway.

There are a lot of undocumented features here... like

 	skb->priority = sk->sk_priority;
 	skb->mark = sk->sk_mark;

which socket do we want here (in ip_queue_xmit()) ?

Its interesting to see ip6_xmit() already has a 'struct sock *sk'
parameter...

This was the preliminary patch I tested :

 include/net/inet6_connection_sock.h |    2 +-
 include/net/inet_connection_sock.h  |    2 +-
 include/net/ip.h                    |    2 +-
 net/dccp/output.c                   |    2 +-
 net/ipv4/ip_output.c                |    5 +++--
 net/ipv4/tcp_output.c               |    2 +-
 net/ipv6/inet6_connection_sock.c    |    3 +--
 net/l2tp/l2tp_core.c                |    4 ++--
 net/l2tp/l2tp_ip.c                  |    2 +-
 net/sctp/protocol.c                 |    2 +-
 10 files changed, 13 insertions(+), 13 deletions(-)
diff --git a/include/net/inet6_connection_sock.h b/include/net/inet6_connection_sock.h
index f981ba7adeed..74af137304be 100644
--- a/include/net/inet6_connection_sock.h
+++ b/include/net/inet6_connection_sock.h
@@ -40,7 +40,7 @@ void inet6_csk_reqsk_queue_hash_add(struct sock *sk, struct request_sock *req,
 
 void inet6_csk_addr2sockaddr(struct sock *sk, struct sockaddr *uaddr);
 
-int inet6_csk_xmit(struct sk_buff *skb, struct flowi *fl);
+int inet6_csk_xmit(struct sock *sk, struct sk_buff *skb, struct flowi *fl);
 
 struct dst_entry *inet6_csk_update_pmtu(struct sock *sk, u32 mtu);
 #endif /* _INET6_CONNECTION_SOCK_H */
diff --git a/include/net/inet_connection_sock.h b/include/net/inet_connection_sock.h
index c55aeed41ace..7a4313887568 100644
--- a/include/net/inet_connection_sock.h
+++ b/include/net/inet_connection_sock.h
@@ -36,7 +36,7 @@ struct tcp_congestion_ops;
  * (i.e. things that depend on the address family)
  */
 struct inet_connection_sock_af_ops {
-	int	    (*queue_xmit)(struct sk_buff *skb, struct flowi *fl);
+	int	    (*queue_xmit)(struct sock *sk, struct sk_buff *skb, struct flowi *fl);
 	void	    (*send_check)(struct sock *sk, struct sk_buff *skb);
 	int	    (*rebuild_header)(struct sock *sk);
 	void	    (*sk_rx_dst_set)(struct sock *sk, const struct sk_buff *skb);
diff --git a/include/net/ip.h b/include/net/ip.h
index 25064c28e059..77e73d293e09 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -111,7 +111,7 @@ int ip_do_nat(struct sk_buff *skb);
 void ip_send_check(struct iphdr *ip);
 int __ip_local_out(struct sk_buff *skb);
 int ip_local_out(struct sk_buff *skb);
-int ip_queue_xmit(struct sk_buff *skb, struct flowi *fl);
+int ip_queue_xmit(struct sock *sk, struct sk_buff *skb, struct flowi *fl);
 void ip_init(void);
 int ip_append_data(struct sock *sk, struct flowi4 *fl4,
 		   int getfrag(void *from, char *to, int offset, int len,
diff --git a/net/dccp/output.c b/net/dccp/output.c
index 8876078859da..0248e8a3460c 100644
--- a/net/dccp/output.c
+++ b/net/dccp/output.c
@@ -138,7 +138,7 @@ static int dccp_transmit_skb(struct sock *sk, struct sk_buff *skb)
 
 		DCCP_INC_STATS(DCCP_MIB_OUTSEGS);
 
-		err = icsk->icsk_af_ops->queue_xmit(skb, &inet->cork.fl);
+		err = icsk->icsk_af_ops->queue_xmit(sk, skb, &inet->cork.fl);
 		return net_xmit_eval(err);
 	}
 	return -ENOBUFS;
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 1a0755fea491..7ad68b860935 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -315,9 +315,9 @@ static void ip_copy_addrs(struct iphdr *iph, const struct flowi4 *fl4)
 	       sizeof(fl4->saddr) + sizeof(fl4->daddr));
 }
 
-int ip_queue_xmit(struct sk_buff *skb, struct flowi *fl)
+/* Note: skb->sk can be different from sk, in case of tunnels */
+int ip_queue_xmit(struct sock *sk, struct sk_buff *skb, struct flowi *fl)
 {
-	struct sock *sk = skb->sk;
 	struct inet_sock *inet = inet_sk(sk);
 	struct ip_options_rcu *inet_opt;
 	struct flowi4 *fl4;
@@ -389,6 +389,7 @@ packet_routed:
 	ip_select_ident_more(skb, &rt->dst, sk,
 			     (skb_shinfo(skb)->gso_segs ?: 1) - 1);
 
+	/* TODO : should we use skb->sk here instead of sk ? */
 	skb->priority = sk->sk_priority;
 	skb->mark = sk->sk_mark;
 
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 699fb102e971..025e25093984 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -981,7 +981,7 @@ static int tcp_transmit_skb(struct sock *sk, struct sk_buff *skb, int clone_it,
 		TCP_ADD_STATS(sock_net(sk), TCP_MIB_OUTSEGS,
 			      tcp_skb_pcount(skb));
 
-	err = icsk->icsk_af_ops->queue_xmit(skb, &inet->cork.fl);
+	err = icsk->icsk_af_ops->queue_xmit(sk, skb, &inet->cork.fl);
 	if (likely(err <= 0))
 		return err;
 
diff --git a/net/ipv6/inet6_connection_sock.c b/net/ipv6/inet6_connection_sock.c
index c9138189415a..d4ade34ab375 100644
--- a/net/ipv6/inet6_connection_sock.c
+++ b/net/ipv6/inet6_connection_sock.c
@@ -224,9 +224,8 @@ static struct dst_entry *inet6_csk_route_socket(struct sock *sk,
 	return dst;
 }
 
-int inet6_csk_xmit(struct sk_buff *skb, struct flowi *fl_unused)
+int inet6_csk_xmit(struct sock *sk, struct sk_buff *skb, struct flowi *fl_unused)
 {
-	struct sock *sk = skb->sk;
 	struct ipv6_pinfo *np = inet6_sk(sk);
 	struct flowi6 fl6;
 	struct dst_entry *dst;
diff --git a/net/l2tp/l2tp_core.c b/net/l2tp/l2tp_core.c
index 47f7a5490555..a4e37d7158dc 100644
--- a/net/l2tp/l2tp_core.c
+++ b/net/l2tp/l2tp_core.c
@@ -1131,10 +1131,10 @@ static int l2tp_xmit_core(struct l2tp_session *session, struct sk_buff *skb,
 	skb->local_df = 1;
 #if IS_ENABLED(CONFIG_IPV6)
 	if (tunnel->sock->sk_family == PF_INET6 && !tunnel->v4mapped)
-		error = inet6_csk_xmit(skb, NULL);
+		error = inet6_csk_xmit(tunnel->sock, skb, NULL);
 	else
 #endif
-		error = ip_queue_xmit(skb, fl);
+		error = ip_queue_xmit(tunnel->sock, skb, fl);
 
 	/* Update stats */
 	if (error >= 0) {
diff --git a/net/l2tp/l2tp_ip.c b/net/l2tp/l2tp_ip.c
index 0b44d855269c..3397fe6897c0 100644
--- a/net/l2tp/l2tp_ip.c
+++ b/net/l2tp/l2tp_ip.c
@@ -487,7 +487,7 @@ static int l2tp_ip_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *m
 
 xmit:
 	/* Queue the packet to IP for output */
-	rc = ip_queue_xmit(skb, &inet->cork.fl);
+	rc = ip_queue_xmit(sk, skb, &inet->cork.fl);
 	rcu_read_unlock();
 
 error:
diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index 4e1d0fcb028e..c09757fbf803 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -957,7 +957,7 @@ static inline int sctp_v4_xmit(struct sk_buff *skb,
 
 	SCTP_INC_STATS(sock_net(&inet->sk), SCTP_MIB_OUTSCTPPACKS);
 
-	return ip_queue_xmit(skb, &transport->fl);
+	return ip_queue_xmit(&inet->sk, skb, &transport->fl);
 }
 
 static struct sctp_af sctp_af_inet;
