From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 06/16] Handle TCP SYN+ACK/ACK/RST transparency
Date: Wed, 01 Oct 2008 07:42:50 -0700 (PDT)
Message-ID: <20081001.074250.261632354.davem@davemloft.net>
References: <20081001142431.4893.48078.stgit@este>
	<20081001142431.4893.64737.stgit@este>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: hidden@sch.bme.hu
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20081001142431.4893.64737.stgit@este>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: KOVACS Krisztian <hidden@sch.bme.hu>
Date: Wed, 01 Oct 2008 16:24:31 +0200

> The TCP stack sends out SYN+ACK/ACK/RST reply packets in response to
> incoming packets. The non-local source address check on output bites
> us again, as replies for transparently redirected traffic won't have a
> chance to leave the node.
> 
> This patch selectively sets the FLOWI_FLAG_ANYSRC flag when doing
> the route lookup for those replies. Transparent replies are enabled if
> the listening socket has the transparent socket flag set.
> 
> Signed-off-by: KOVACS Krisztian <hidden@sch.bme.hu>

I had to make some modifications to make this build.

I took two include/net/ip.h modifications from patch 7:

1) Adding flags to ip_reply_arg struct
2) definition of IP_REPLY_ARG_NOSRCCHECK

and the result is included below and added to net-next-2.6

tcp: Handle TCP SYN+ACK/ACK/RST transparency

The TCP stack sends out SYN+ACK/ACK/RST reply packets in response to
incoming packets. The non-local source address check on output bites
us again, as replies for transparently redirected traffic won't have a
chance to leave the node.

This patch selectively sets the FLOWI_FLAG_ANYSRC flag when doing the
route lookup for those replies. Transparent replies are enabled if the
listening socket has the transparent socket flag set.

Signed-off-by: KOVACS Krisztian <hidden@sch.bme.hu>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/inet_sock.h |    8 +++++++-
 include/net/ip.h        |    3 +++
 net/ipv4/tcp_ipv4.c     |   12 +++++++++---
 3 files changed, 19 insertions(+), 4 deletions(-)

diff --git a/include/net/inet_sock.h b/include/net/inet_sock.h
index 139b78b..dced3f6 100644
--- a/include/net/inet_sock.h
+++ b/include/net/inet_sock.h
@@ -72,7 +72,8 @@ struct inet_request_sock {
 				sack_ok	   : 1,
 				wscale_ok  : 1,
 				ecn_ok	   : 1,
-				acked	   : 1;
+				acked	   : 1,
+				no_srccheck: 1;
 	struct ip_options	*opt;
 };
 
@@ -204,4 +205,9 @@ static inline struct request_sock *inet_reqsk_alloc(struct request_sock_ops *ops
 	return req;
 }
 
+static inline __u8 inet_sk_flowi_flags(const struct sock *sk)
+{
+	return inet_sk(sk)->transparent ? FLOWI_FLAG_ANYSRC : 0;
+}
+
 #endif	/* _INET_SOCK_H */
diff --git a/include/net/ip.h b/include/net/ip.h
index 250e6ef..90b27f6 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -140,12 +140,15 @@ static inline void ip_tr_mc_map(__be32 addr, char *buf)
 
 struct ip_reply_arg {
 	struct kvec iov[1];   
+	int	    flags;
 	__wsum 	    csum;
 	int	    csumoffset; /* u16 offset of csum in iov[0].iov_base */
 				/* -1 if not needed */ 
 	int	    bound_dev_if;
 }; 
 
+#define IP_REPLY_ARG_NOSRCCHECK 1
+
 void ip_send_reply(struct sock *sk, struct sk_buff *skb, struct ip_reply_arg *arg,
 		   unsigned int len); 
 
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index d13688e..8b24bd8 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -591,6 +591,7 @@ static void tcp_v4_send_reset(struct sock *sk, struct sk_buff *skb)
 				      ip_hdr(skb)->saddr, /* XXX */
 				      sizeof(struct tcphdr), IPPROTO_TCP, 0);
 	arg.csumoffset = offsetof(struct tcphdr, check) / 2;
+	arg.flags = (sk && inet_sk(sk)->transparent) ? IP_REPLY_ARG_NOSRCCHECK : 0;
 
 	net = dev_net(skb->dst->dev);
 	ip_send_reply(net->ipv4.tcp_sock, skb,
@@ -606,7 +607,8 @@ static void tcp_v4_send_reset(struct sock *sk, struct sk_buff *skb)
 
 static void tcp_v4_send_ack(struct sk_buff *skb, u32 seq, u32 ack,
 			    u32 win, u32 ts, int oif,
-			    struct tcp_md5sig_key *key)
+			    struct tcp_md5sig_key *key,
+			    int reply_flags)
 {
 	struct tcphdr *th = tcp_hdr(skb);
 	struct {
@@ -659,6 +661,7 @@ static void tcp_v4_send_ack(struct sk_buff *skb, u32 seq, u32 ack,
 				    ip_hdr(skb)->daddr, &rep.th);
 	}
 #endif
+	arg.flags = reply_flags;
 	arg.csum = csum_tcpudp_nofold(ip_hdr(skb)->daddr,
 				      ip_hdr(skb)->saddr, /* XXX */
 				      arg.iov[0].iov_len, IPPROTO_TCP, 0);
@@ -681,7 +684,8 @@ static void tcp_v4_timewait_ack(struct sock *sk, struct sk_buff *skb)
 			tcptw->tw_rcv_wnd >> tw->tw_rcv_wscale,
 			tcptw->tw_ts_recent,
 			tw->tw_bound_dev_if,
-			tcp_twsk_md5_key(tcptw)
+			tcp_twsk_md5_key(tcptw),
+			tw->tw_transparent ? IP_REPLY_ARG_NOSRCCHECK : 0
 			);
 
 	inet_twsk_put(tw);
@@ -694,7 +698,8 @@ static void tcp_v4_reqsk_send_ack(struct sock *sk, struct sk_buff *skb,
 			tcp_rsk(req)->rcv_isn + 1, req->rcv_wnd,
 			req->ts_recent,
 			0,
-			tcp_v4_md5_do_lookup(sk, ip_hdr(skb)->daddr));
+			tcp_v4_md5_do_lookup(sk, ip_hdr(skb)->daddr),
+			inet_rsk(req)->no_srccheck ? IP_REPLY_ARG_NOSRCCHECK : 0);
 }
 
 /*
@@ -1244,6 +1249,7 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 	ireq = inet_rsk(req);
 	ireq->loc_addr = daddr;
 	ireq->rmt_addr = saddr;
+	ireq->no_srccheck = inet_sk(sk)->transparent;
 	ireq->opt = tcp_v4_save_options(sk, skb);
 	if (!want_cookie)
 		TCP_ECN_create_request(req, tcp_hdr(skb));
-- 
1.5.6.5

