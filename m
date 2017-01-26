From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH net] tcp: don't annotate mark on control socket from tcp_v6_send_response()
Date: Thu, 26 Jan 2017 22:56:21 +0100
Message-ID: <1485467781-1842-1-git-send-email-pablo@netfilter.org>
Cc: netfilter-devel@vger.kernel.org, davem@davemloft.net,
        eric.dumazet@gmail.com
To: netdev@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Unlike ipv4, this control socket is shared by all cpus so we cannot use
it as scratchpad area to annotate the mark that we pass to ip6_xmit().

Add a new parameter to ip6_xmit() to indicate the mark. The SCTP socket
family caches the flowi6 structure in the sctp_transport structure, so
we cannot use to carry the mark unless we later on reset it back, which
I discarded since it looks ugly to me.

Fixes: bf99b4ded5f8 ("tcp: fix mark propagation with fwmark_reflect enabled")
Suggested-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
Tested with nc6, works for me.

Note: DCCP and SCTP don't seem to support fwmark_reflect yet, so leave
      these bits.

Thanks!

 include/net/ipv6.h               | 2 +-
 net/dccp/ipv6.c                  | 4 ++--
 net/ipv6/inet6_connection_sock.c | 2 +-
 net/ipv6/ip6_output.c            | 4 ++--
 net/ipv6/tcp_ipv6.c              | 5 ++---
 net/sctp/ipv6.c                  | 3 ++-
 6 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 487e57391664..7afe991e900e 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -871,7 +871,7 @@ int ip6_rcv_finish(struct net *net, struct sock *sk, struct sk_buff *skb);
  *	upper-layer output functions
  */
 int ip6_xmit(const struct sock *sk, struct sk_buff *skb, struct flowi6 *fl6,
-	     struct ipv6_txoptions *opt, int tclass);
+	     __u32 mark, struct ipv6_txoptions *opt, int tclass);
 
 int ip6_find_1stfragopt(struct sk_buff *skb, u8 **nexthdr);
 
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index adfc790f7193..c4e879c02186 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -227,7 +227,7 @@ static int dccp_v6_send_response(const struct sock *sk, struct request_sock *req
 		opt = ireq->ipv6_opt;
 		if (!opt)
 			opt = rcu_dereference(np->opt);
-		err = ip6_xmit(sk, skb, &fl6, opt, np->tclass);
+		err = ip6_xmit(sk, skb, &fl6, sk->sk_mark, opt, np->tclass);
 		rcu_read_unlock();
 		err = net_xmit_eval(err);
 	}
@@ -281,7 +281,7 @@ static void dccp_v6_ctl_send_reset(const struct sock *sk, struct sk_buff *rxskb)
 	dst = ip6_dst_lookup_flow(ctl_sk, &fl6, NULL);
 	if (!IS_ERR(dst)) {
 		skb_dst_set(skb, dst);
-		ip6_xmit(ctl_sk, skb, &fl6, NULL, 0);
+		ip6_xmit(ctl_sk, skb, &fl6, 0, NULL, 0);
 		DCCP_INC_STATS(DCCP_MIB_OUTSEGS);
 		DCCP_INC_STATS(DCCP_MIB_OUTRSTS);
 		return;
diff --git a/net/ipv6/inet6_connection_sock.c b/net/ipv6/inet6_connection_sock.c
index 7396e75e161b..75c308239243 100644
--- a/net/ipv6/inet6_connection_sock.c
+++ b/net/ipv6/inet6_connection_sock.c
@@ -176,7 +176,7 @@ int inet6_csk_xmit(struct sock *sk, struct sk_buff *skb, struct flowi *fl_unused
 	/* Restore final destination back after routing done */
 	fl6.daddr = sk->sk_v6_daddr;
 
-	res = ip6_xmit(sk, skb, &fl6, rcu_dereference(np->opt),
+	res = ip6_xmit(sk, skb, &fl6, sk->sk_mark, rcu_dereference(np->opt),
 		       np->tclass);
 	rcu_read_unlock();
 	return res;
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 38122d04fadc..2c0df09e9036 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -172,7 +172,7 @@ int ip6_output(struct net *net, struct sock *sk, struct sk_buff *skb)
  * which are using proper atomic operations or spinlocks.
  */
 int ip6_xmit(const struct sock *sk, struct sk_buff *skb, struct flowi6 *fl6,
-	     struct ipv6_txoptions *opt, int tclass)
+	     __u32 mark, struct ipv6_txoptions *opt, int tclass)
 {
 	struct net *net = sock_net(sk);
 	const struct ipv6_pinfo *np = inet6_sk(sk);
@@ -240,7 +240,7 @@ int ip6_xmit(const struct sock *sk, struct sk_buff *skb, struct flowi6 *fl6,
 
 	skb->protocol = htons(ETH_P_IPV6);
 	skb->priority = sk->sk_priority;
-	skb->mark = sk->sk_mark;
+	skb->mark = mark;
 
 	mtu = dst_mtu(dst);
 	if ((skb->len <= mtu) || skb->ignore_df || skb_is_gso(skb)) {
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 2b20622a5824..cb8929681dc7 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -469,7 +469,7 @@ static int tcp_v6_send_synack(const struct sock *sk, struct dst_entry *dst,
 		opt = ireq->ipv6_opt;
 		if (!opt)
 			opt = rcu_dereference(np->opt);
-		err = ip6_xmit(sk, skb, fl6, opt, np->tclass);
+		err = ip6_xmit(sk, skb, fl6, sk->sk_mark, opt, np->tclass);
 		rcu_read_unlock();
 		err = net_xmit_eval(err);
 	}
@@ -840,8 +840,7 @@ static void tcp_v6_send_response(const struct sock *sk, struct sk_buff *skb, u32
 	dst = ip6_dst_lookup_flow(ctl_sk, &fl6, NULL);
 	if (!IS_ERR(dst)) {
 		skb_dst_set(buff, dst);
-		ctl_sk->sk_mark = fl6.flowi6_mark;
-		ip6_xmit(ctl_sk, buff, &fl6, NULL, tclass);
+		ip6_xmit(ctl_sk, buff, &fl6, fl6.flowi6_mark, NULL, tclass);
 		TCP_INC_STATS(net, TCP_MIB_OUTSEGS);
 		if (rst)
 			TCP_INC_STATS(net, TCP_MIB_OUTRSTS);
diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
index 5ed8e79bf102..64dfd35ccdcc 100644
--- a/net/sctp/ipv6.c
+++ b/net/sctp/ipv6.c
@@ -222,7 +222,8 @@ static int sctp_v6_xmit(struct sk_buff *skb, struct sctp_transport *transport)
 	SCTP_INC_STATS(sock_net(sk), SCTP_MIB_OUTSCTPPACKS);
 
 	rcu_read_lock();
-	res = ip6_xmit(sk, skb, fl6, rcu_dereference(np->opt), np->tclass);
+	res = ip6_xmit(sk, skb, fl6, sk->sk_mark, rcu_dereference(np->opt),
+		       np->tclass);
 	rcu_read_unlock();
 	return res;
 }
-- 
2.1.4

