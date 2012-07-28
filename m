From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [GIT] Networking
Date: Sat, 28 Jul 2012 10:41:10 +0200
Message-ID: <1343464870.2626.13156.camel@edumazet-glaptop>
References: <20120728.005241.2226926028836664098.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:51052 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751625Ab2G1IlO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Jul 2012 04:41:14 -0400
Received: by wgbdr13 with SMTP id dr13so3419964wgb.1
        for <netdev@vger.kernel.org>; Sat, 28 Jul 2012 01:41:13 -0700 (PDT)
In-Reply-To: <20120728.005241.2226926028836664098.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2012-07-28 at 00:52 -0700, David Miller wrote:
> Several bug fixes, some to new features appearing in this merge window,
> some that have been around for a while.
> 
> I have a short list of known problems that need to be sorted out, but
> all of them can be solved easily during the run up to 3.6-final.
> 
> I'll be offline until Sunday afternoon, but nothing need hold up
> 3.6-rc1 and the close of the merge window, networking wise, at this
> point.
> 
> 1) Fix interface check in ipv4 TCP early demux, from Eric Dumazet.

trimming CC

I have some other TCP early demux issues, about RCU correctness

As we skb_dst_set_noref(skb, dst); in tcp_v{4|6}_early_demux,
we need to make sure we dont dst_release(sk->sk_rx_dst) if some in
flight skbs are still around.

So we probably need to respect an RCU grace period in dst_release()
before destroy.
 
Or we should set sk_rx_dst = dst only if dst hasnt DST_NOCACHE set ?

Also we need to remove rcu_read_lock() around ->early_demux() calls, 
since we MUST already be in an rcu_read_lock() section.

RFC only patch, before running out for the week end ;)

 include/net/inet_sock.h  |   11 +++++++++++
 net/ipv4/ip_input.c      |    2 --
 net/ipv4/tcp_input.c     |    3 +--
 net/ipv4/tcp_ipv4.c      |   12 ++++++------
 net/ipv4/tcp_minisocks.c |    3 +--
 net/ipv6/ip6_input.c     |    2 --
 6 files changed, 19 insertions(+), 14 deletions(-)

diff --git a/include/net/inet_sock.h b/include/net/inet_sock.h
index 613cfa4..47b24d7 100644
--- a/include/net/inet_sock.h
+++ b/include/net/inet_sock.h
@@ -249,4 +249,15 @@ static inline __u8 inet_sk_flowi_flags(const struct sock *sk)
 	return flags;
 }
 
+static inline void inet_sk_rx_dst_set(struct sock *sk, const struct sk_buff *skb)
+{
+	struct dst_entry *dst = skb_dst(skb);
+
+	/* Can cache dst if rcu grace period is respected at dst destroy time */
+	if (!(dst->flags & DST_NOCACHE)) {
+		sk->sk_rx_dst = dst_clone(dst);
+		inet_sk(sk)->rx_dst_ifindex = skb->skb_iif;
+	}
+}
+
 #endif	/* _INET_SOCK_H */
diff --git a/net/ipv4/ip_input.c b/net/ipv4/ip_input.c
index 981ff1e..f1395a6 100644
--- a/net/ipv4/ip_input.c
+++ b/net/ipv4/ip_input.c
@@ -325,14 +325,12 @@ static int ip_rcv_finish(struct sk_buff *skb)
 		const struct net_protocol *ipprot;
 		int protocol = iph->protocol;
 
-		rcu_read_lock();
 		ipprot = rcu_dereference(inet_protos[protocol]);
 		if (ipprot && ipprot->early_demux) {
 			ipprot->early_demux(skb);
 			/* must reload iph, skb->head might have changed */
 			iph = ip_hdr(skb);
 		}
-		rcu_read_unlock();
 	}
 
 	/*
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index a356e1f..9be30b0 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -5604,8 +5604,7 @@ void tcp_finish_connect(struct sock *sk, struct sk_buff *skb)
 	tcp_set_state(sk, TCP_ESTABLISHED);
 
 	if (skb != NULL) {
-		sk->sk_rx_dst = dst_clone(skb_dst(skb));
-		inet_sk(sk)->rx_dst_ifindex = skb->skb_iif;
+		inet_sk_rx_dst_set(sk, skb);
 		security_inet_conn_established(sk, skb);
 	}
 
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 2fbd992..7f91e5a 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1617,19 +1617,19 @@ int tcp_v4_do_rcv(struct sock *sk, struct sk_buff *skb)
 #endif
 
 	if (sk->sk_state == TCP_ESTABLISHED) { /* Fast path */
+		struct dst_entry *dst = sk->sk_rx_dst;
+
 		sock_rps_save_rxhash(sk, skb);
-		if (sk->sk_rx_dst) {
-			struct dst_entry *dst = sk->sk_rx_dst;
+		if (dst) {
 			if (inet_sk(sk)->rx_dst_ifindex != skb->skb_iif ||
 			    dst->ops->check(dst, 0) == NULL) {
 				dst_release(dst);
 				sk->sk_rx_dst = NULL;
 			}
 		}
-		if (unlikely(sk->sk_rx_dst == NULL)) {
-			sk->sk_rx_dst = dst_clone(skb_dst(skb));
-			inet_sk(sk)->rx_dst_ifindex = skb->skb_iif;
-		}
+		if (unlikely(!sk->sk_rx_dst))
+			inet_sk_rx_dst_set(sk, skb);
+
 		if (tcp_rcv_established(sk, skb, tcp_hdr(skb), skb->len)) {
 			rsk = sk;
 			goto reset;
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 3f1cc20..232a90c 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -387,8 +387,7 @@ struct sock *tcp_create_openreq_child(struct sock *sk, struct request_sock *req,
 		struct tcp_sock *oldtp = tcp_sk(sk);
 		struct tcp_cookie_values *oldcvp = oldtp->cookie_values;
 
-		newsk->sk_rx_dst = dst_clone(skb_dst(skb));
-		inet_sk(newsk)->rx_dst_ifindex = skb->skb_iif;
+		inet_sk_rx_dst_set(newsk, skb);
 
 		/* TCP Cookie Transactions require space for the cookie pair,
 		 * as it differs for each connection.  There is no need to
diff --git a/net/ipv6/ip6_input.c b/net/ipv6/ip6_input.c
index 47975e3..a52d864 100644
--- a/net/ipv6/ip6_input.c
+++ b/net/ipv6/ip6_input.c
@@ -52,11 +52,9 @@ int ip6_rcv_finish(struct sk_buff *skb)
 	if (sysctl_ip_early_demux && !skb_dst(skb)) {
 		const struct inet6_protocol *ipprot;
 
-		rcu_read_lock();
 		ipprot = rcu_dereference(inet6_protos[ipv6_hdr(skb)->nexthdr]);
 		if (ipprot && ipprot->early_demux)
 			ipprot->early_demux(skb);
-		rcu_read_unlock();
 	}
 	if (!skb_dst(skb))
 		ip6_route_input(skb);
