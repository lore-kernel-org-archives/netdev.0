From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] ipv4: use IS_ENABLED() macro to cleanup code
Date: Tue, 25 Oct 2011 09:12:32 +0200
Message-ID: <1319526752.3834.12.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:58979 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752214Ab1JYHMh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Oct 2011 03:12:37 -0400
Received: by wyg36 with SMTP id 36so168312wyg.19
        for <netdev@vger.kernel.org>; Tue, 25 Oct 2011 00:12:36 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove some ugly #ifdef, using IS_ENABLED(CONFIG_xxx) macro

IS_ENABLED(CONFIG_xxx) evaluates to 1 if CONFIG_xxx is set to 'y' or 'm'

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv4/inet_diag.c     |   65 +++++++++++++++----------------------
 net/ipv4/ip_gre.c        |   21 ++++-------
 net/ipv4/ip_sockglue.c   |   12 ++----
 net/ipv4/tcp_input.c     |    6 +--
 net/ipv4/tcp_minisocks.c |   49 ++++++++++++++-------------
 net/ipv4/tcp_timer.c     |    6 +--
 net/ipv4/tunnel4.c       |   11 ++----
 net/ipv4/xfrm4_tunnel.c  |   12 +++---
 8 files changed, 80 insertions(+), 102 deletions(-)

diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index f5e2bda..7f42cc3 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -125,8 +125,8 @@ static int inet_csk_diag_fill(struct sock *sk,
 	r->id.idiag_src[0] = inet->inet_rcv_saddr;
 	r->id.idiag_dst[0] = inet->inet_daddr;
 
-#if defined(CONFIG_IPV6) || defined (CONFIG_IPV6_MODULE)
-	if (r->idiag_family == AF_INET6) {
+	if (IS_ENABLED(CONFIG_IPV6) &&
+	    r->idiag_family == AF_INET6) {
 		const struct ipv6_pinfo *np = inet6_sk(sk);
 
 		ipv6_addr_copy((struct in6_addr *)r->id.idiag_src,
@@ -136,7 +136,6 @@ static int inet_csk_diag_fill(struct sock *sk,
 		if (ext & (1 << (INET_DIAG_TOS - 1)))
 			RTA_PUT_U8(skb, INET_DIAG_TOS, np->tclass);
 	}
-#endif
 
 #define EXPIRES_IN_MS(tmo)  DIV_ROUND_UP((tmo - jiffies) * 1000, HZ)
 
@@ -219,8 +218,9 @@ static int inet_twsk_diag_fill(struct inet_timewait_sock *tw,
 	r->idiag_wqueue	      = 0;
 	r->idiag_uid	      = 0;
 	r->idiag_inode	      = 0;
-#if defined(CONFIG_IPV6) || defined (CONFIG_IPV6_MODULE)
-	if (tw->tw_family == AF_INET6) {
+
+	if (IS_ENABLED(CONFIG_IPV6) &&
+	    tw->tw_family == AF_INET6) {
 		const struct inet6_timewait_sock *tw6 =
 						inet6_twsk((struct sock *)tw);
 
@@ -229,7 +229,6 @@ static int inet_twsk_diag_fill(struct inet_timewait_sock *tw,
 		ipv6_addr_copy((struct in6_addr *)r->id.idiag_dst,
 			       &tw6->tw_v6_daddr);
 	}
-#endif
 	nlh->nlmsg_len = skb_tail_pointer(skb) - previous_tail;
 	return skb->len;
 nlmsg_failure:
@@ -271,18 +270,15 @@ static int inet_diag_get_exact(struct sk_buff *in_skb,
 		sk = inet_lookup(&init_net, hashinfo, req->id.idiag_dst[0],
 				 req->id.idiag_dport, req->id.idiag_src[0],
 				 req->id.idiag_sport, req->id.idiag_if);
-	}
-#if defined(CONFIG_IPV6) || defined (CONFIG_IPV6_MODULE)
-	else if (req->idiag_family == AF_INET6) {
+	} else if (IS_ENABLED(CONFIG_IPV6) &&
+		 req->idiag_family == AF_INET6) {
 		sk = inet6_lookup(&init_net, hashinfo,
 				  (struct in6_addr *)req->id.idiag_dst,
 				  req->id.idiag_dport,
 				  (struct in6_addr *)req->id.idiag_src,
 				  req->id.idiag_sport,
 				  req->id.idiag_if);
-	}
-#endif
-	else {
+	} else {
 		goto unlock;
 	}
 
@@ -501,15 +497,14 @@ static int inet_csk_diag_dump(struct sock *sk,
 		struct inet_sock *inet = inet_sk(sk);
 
 		entry.family = sk->sk_family;
-#if defined(CONFIG_IPV6) || defined (CONFIG_IPV6_MODULE)
-		if (entry.family == AF_INET6) {
+
+		if (IS_ENABLED(CONFIG_IPV6) &&
+		    entry.family == AF_INET6) {
 			struct ipv6_pinfo *np = inet6_sk(sk);
 
 			entry.saddr = np->rcv_saddr.s6_addr32;
 			entry.daddr = np->daddr.s6_addr32;
-		} else
-#endif
-		{
+		} else {
 			entry.saddr = &inet->inet_rcv_saddr;
 			entry.daddr = &inet->inet_daddr;
 		}
@@ -539,15 +534,13 @@ static int inet_twsk_diag_dump(struct inet_timewait_sock *tw,
 							  INET_DIAG_REQ_BYTECODE);
 
 		entry.family = tw->tw_family;
-#if defined(CONFIG_IPV6) || defined (CONFIG_IPV6_MODULE)
-		if (tw->tw_family == AF_INET6) {
+		if (IS_ENABLED(CONFIG_IPV6) &&
+		    tw->tw_family == AF_INET6) {
 			struct inet6_timewait_sock *tw6 =
 						inet6_twsk((struct sock *)tw);
 			entry.saddr = tw6->tw_v6_rcv_saddr.s6_addr32;
 			entry.daddr = tw6->tw_v6_daddr.s6_addr32;
-		} else
-#endif
-		{
+		} else {
 			entry.saddr = &tw->tw_rcv_saddr;
 			entry.daddr = &tw->tw_daddr;
 		}
@@ -601,14 +594,14 @@ static int inet_diag_fill_req(struct sk_buff *skb, struct sock *sk,
 	r->idiag_wqueue = 0;
 	r->idiag_uid = sock_i_uid(sk);
 	r->idiag_inode = 0;
-#if defined(CONFIG_IPV6) || defined (CONFIG_IPV6_MODULE)
-	if (r->idiag_family == AF_INET6) {
+
+	if (IS_ENABLED(CONFIG_IPV6) &&
+	    r->idiag_family == AF_INET6) {
 		ipv6_addr_copy((struct in6_addr *)r->id.idiag_src,
 			       &inet6_rsk(req)->loc_addr);
 		ipv6_addr_copy((struct in6_addr *)r->id.idiag_dst,
 			       &inet6_rsk(req)->rmt_addr);
 	}
-#endif
 	nlh->nlmsg_len = skb_tail_pointer(skb) - b;
 
 	return skb->len;
@@ -626,7 +619,7 @@ static int inet_diag_dump_reqs(struct sk_buff *skb, struct sock *sk,
 	struct inet_connection_sock *icsk = inet_csk(sk);
 	struct listen_sock *lopt;
 	const struct nlattr *bc = NULL;
-	struct inet_sock *inet = inet_sk(sk);
+	const struct inet_sock *inet = inet_sk(sk);
 	int j, s_j;
 	int reqnum, s_reqnum;
 	int err = 0;
@@ -666,18 +659,14 @@ static int inet_diag_dump_reqs(struct sk_buff *skb, struct sock *sk,
 				continue;
 
 			if (bc) {
-				entry.saddr =
-#if defined(CONFIG_IPV6) || defined (CONFIG_IPV6_MODULE)
-					(entry.family == AF_INET6) ?
-					inet6_rsk(req)->loc_addr.s6_addr32 :
-#endif
-					&ireq->loc_addr;
-				entry.daddr =
-#if defined(CONFIG_IPV6) || defined (CONFIG_IPV6_MODULE)
-					(entry.family == AF_INET6) ?
-					inet6_rsk(req)->rmt_addr.s6_addr32 :
-#endif
-					&ireq->rmt_addr;
+				if (IS_ENABLED(CONFIG_IPV6) &&
+				    entry.family == AF_INET6) {
+					entry.saddr = inet6_rsk(req)->loc_addr.s6_addr32;
+					entry.daddr = inet6_rsk(req)->rmt_addr.s6_addr32;
+				} else {
+					entry.saddr = &ireq->loc_addr;
+					entry.daddr = &ireq->rmt_addr;
+				}
 				entry.dport = ntohs(ireq->rmt_port);
 
 				if (!inet_diag_bc_run(nla_data(bc),
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index d55110e..06bf1b7 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -728,9 +728,8 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev
 			rt = skb_rtable(skb);
 			if ((dst = rt->rt_gateway) == 0)
 				goto tx_error_icmp;
-		}
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
-		else if (skb->protocol == htons(ETH_P_IPV6)) {
+		} else if (IS_ENABLED(CONFIG_IPV6) &&
+			   skb->protocol == htons(ETH_P_IPV6)) {
 			struct neighbour *neigh = dst_get_neighbour(skb_dst(skb));
 			const struct in6_addr *addr6;
 			int addr_type;
@@ -750,10 +749,9 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev
 				goto tx_error_icmp;
 
 			dst = addr6->s6_addr32[3];
-		}
-#endif
-		else
+		} else {
 			goto tx_error;
+		}
 	}
 
 	tos = tiph->tos;
@@ -798,9 +796,8 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev
 			ip_rt_put(rt);
 			goto tx_error;
 		}
-	}
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
-	else if (skb->protocol == htons(ETH_P_IPV6)) {
+	} else if (IS_ENABLED(CONFIG_IPV6) &&
+		   skb->protocol == htons(ETH_P_IPV6)) {
 		struct rt6_info *rt6 = (struct rt6_info *)skb_dst(skb);
 
 		if (rt6 && mtu < dst_mtu(skb_dst(skb)) && mtu >= IPV6_MIN_MTU) {
@@ -818,7 +815,6 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev
 			goto tx_error;
 		}
 	}
-#endif
 
 	if (tunnel->err_count > 0) {
 		if (time_before(jiffies,
@@ -873,10 +869,9 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev
 	if ((iph->ttl = tiph->ttl) == 0) {
 		if (skb->protocol == htons(ETH_P_IP))
 			iph->ttl = old_iph->ttl;
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
-		else if (skb->protocol == htons(ETH_P_IPV6))
+		else if (IS_ENABLED(CONFIG_IPV6) &&
+			 skb->protocol == htons(ETH_P_IPV6))
 			iph->ttl = ((const struct ipv6hdr *)old_iph)->hop_limit;
-#endif
 		else
 			iph->ttl = ip4_dst_hoplimit(&rt->dst);
 	}
diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index 09ff51b..03f614e 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -515,20 +515,18 @@ static int do_ip_setsockopt(struct sock *sk, int level,
 						sock_owned_by_user(sk));
 		if (inet->is_icsk) {
 			struct inet_connection_sock *icsk = inet_csk(sk);
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
-			if (sk->sk_family == PF_INET ||
-			    (!((1 << sk->sk_state) &
+
+			if (IS_ENABLED(CONFIG_IPV6) &&
+			    (sk->sk_family == PF_INET ||
+			     (!((1 << sk->sk_state) &
 			       (TCPF_LISTEN | TCPF_CLOSE)) &&
-			     inet->inet_daddr != LOOPBACK4_IPV6)) {
-#endif
+			     inet->inet_daddr != LOOPBACK4_IPV6))) {
 				if (old)
 					icsk->icsk_ext_hdr_len -= old->opt.optlen;
 				if (opt)
 					icsk->icsk_ext_hdr_len += opt->opt.optlen;
 				icsk->icsk_sync_mss(sk, icsk->icsk_pmtu_cookie);
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 			}
-#endif
 		}
 		rcu_assign_pointer(inet->inet_opt, opt);
 		if (old)
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 52b5c2d..0635f27 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2662,9 +2662,8 @@ static void DBGUNDO(struct sock *sk, const char *msg)
 		       tp->snd_cwnd, tcp_left_out(tp),
 		       tp->snd_ssthresh, tp->prior_ssthresh,
 		       tp->packets_out);
-	}
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
-	else if (sk->sk_family == AF_INET6) {
+	} else if (IS_ENABLED(CONFIG_IPV6) &&
+		   sk->sk_family == AF_INET6) {
 		struct ipv6_pinfo *np = inet6_sk(sk);
 		printk(KERN_DEBUG "Undo %s %pI6/%u c%u l%u ss%u/%u p%u\n",
 		       msg,
@@ -2673,7 +2672,6 @@ static void DBGUNDO(struct sock *sk, const char *msg)
 		       tp->snd_ssthresh, tp->prior_ssthresh,
 		       tp->packets_out);
 	}
-#endif
 }
 #else
 #define DBGUNDO(x...) do { } while (0)
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 85a2fbe..ca07a0e 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -336,8 +336,8 @@ void tcp_time_wait(struct sock *sk, int state, int timeo)
 		tcptw->tw_ts_recent	= tp->rx_opt.ts_recent;
 		tcptw->tw_ts_recent_stamp = tp->rx_opt.ts_recent_stamp;
 
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
-		if (tw->tw_family == PF_INET6) {
+		if (IS_ENABLED(CONFIG_IPV6) &&
+		    tw->tw_family == PF_INET6) {
 			struct ipv6_pinfo *np = inet6_sk(sk);
 			struct inet6_timewait_sock *tw6;
 
@@ -347,17 +347,16 @@ void tcp_time_wait(struct sock *sk, int state, int timeo)
 			ipv6_addr_copy(&tw6->tw_v6_rcv_saddr, &np->rcv_saddr);
 			tw->tw_ipv6only = np->ipv6only;
 		}
-#endif
 
-#ifdef CONFIG_TCP_MD5SIG
-		/*
-		 * The timewait bucket does not have the key DB from the
-		 * sock structure. We just make a quick copy of the
-		 * md5 key being used (if indeed we are using one)
-		 * so the timewait ack generating code has the key.
-		 */
-		do {
+		if (IS_ENABLED(CONFIG_TCP_MD5SIG)) {
+			/*
+			 * The timewait bucket does not have the key DB from the
+			 * sock structure. We just make a quick copy of the
+			 * md5 key being used (if indeed we are using one)
+			 * so the timewait ack generating code has the key.
+			 */
 			struct tcp_md5sig_key *key;
+
 			memset(tcptw->tw_md5_key, 0, sizeof(tcptw->tw_md5_key));
 			tcptw->tw_md5_keylen = 0;
 			key = tp->af_specific->md5_lookup(sk, sk);
@@ -367,8 +366,7 @@ void tcp_time_wait(struct sock *sk, int state, int timeo)
 				if (tcp_alloc_md5sig_pool(sk) == NULL)
 					BUG();
 			}
-		} while (0);
-#endif
+		}
 
 		/* Linkage updates. */
 		__inet_twsk_hashdance(tw, sk, &tcp_hashinfo);
@@ -402,16 +400,17 @@ void tcp_time_wait(struct sock *sk, int state, int timeo)
 
 void tcp_twsk_destructor(struct sock *sk)
 {
-#ifdef CONFIG_TCP_MD5SIG
-	struct tcp_timewait_sock *twsk = tcp_twsk(sk);
-	if (twsk->tw_md5_keylen)
-		tcp_free_md5sig_pool();
-#endif
+	if (IS_ENABLED(CONFIG_TCP_MD5SIG)) {
+		const struct tcp_timewait_sock *twsk = tcp_twsk(sk);
+
+		if (twsk->tw_md5_keylen)
+			tcp_free_md5sig_pool();
+	}
 }
 EXPORT_SYMBOL_GPL(tcp_twsk_destructor);
 
 static inline void TCP_ECN_openreq_child(struct tcp_sock *tp,
-					 struct request_sock *req)
+					 const struct request_sock *req)
 {
 	tp->ecn_flags = inet_rsk(req)->ecn_ok ? TCP_ECN_OK : 0;
 }
@@ -541,11 +540,13 @@ struct sock *tcp_create_openreq_child(struct sock *sk, struct request_sock *req,
 			newtp->rx_opt.ts_recent_stamp = 0;
 			newtp->tcp_header_len = sizeof(struct tcphdr);
 		}
-#ifdef CONFIG_TCP_MD5SIG
-		newtp->md5sig_info = NULL;	/*XXX*/
-		if (newtp->af_specific->md5_lookup(sk, newsk))
-			newtp->tcp_header_len += TCPOLEN_MD5SIG_ALIGNED;
-#endif
+
+		if (IS_ENABLED(CONFIG_TCP_MD5SIG)) {
+			newtp->md5sig_info = NULL;	/*XXX*/
+			if (newtp->af_specific->md5_lookup(sk, newsk))
+				newtp->tcp_header_len += TCPOLEN_MD5SIG_ALIGNED;
+		}
+
 		if (skb->len >= TCP_MSS_DEFAULT + newtp->tcp_header_len)
 			newicsk->icsk_ack.last_seg_size = skb->len - newtp->tcp_header_len;
 		newtp->rx_opt.mss_clamp = req->mss;
diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
index 2e0f0af..9d8705c 100644
--- a/net/ipv4/tcp_timer.c
+++ b/net/ipv4/tcp_timer.c
@@ -339,15 +339,13 @@ void tcp_retransmit_timer(struct sock *sk)
 			LIMIT_NETDEBUG(KERN_DEBUG "TCP: Peer %pI4:%u/%u unexpectedly shrunk window %u:%u (repaired)\n",
 			       &inet->inet_daddr, ntohs(inet->inet_dport),
 			       inet->inet_num, tp->snd_una, tp->snd_nxt);
-		}
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
-		else if (sk->sk_family == AF_INET6) {
+		} else if (IS_ENABLED(CONFIG_IPV6) &&
+			   sk->sk_family == AF_INET6) {
 			struct ipv6_pinfo *np = inet6_sk(sk);
 			LIMIT_NETDEBUG(KERN_DEBUG "TCP: Peer %pI6:%u/%u unexpectedly shrunk window %u:%u (repaired)\n",
 			       &np->daddr, ntohs(inet->inet_dport),
 			       inet->inet_num, tp->snd_una, tp->snd_nxt);
 		}
-#endif
 		if (tcp_time_stamp - tp->rcv_tstamp > TCP_RTO_MAX) {
 			tcp_write_err(sk);
 			goto out;
diff --git a/net/ipv4/tunnel4.c b/net/ipv4/tunnel4.c
index ac3b3ee..e860b17 100644
--- a/net/ipv4/tunnel4.c
+++ b/net/ipv4/tunnel4.c
@@ -167,22 +167,21 @@ static int __init tunnel4_init(void)
 		printk(KERN_ERR "tunnel4 init: can't add protocol\n");
 		return -EAGAIN;
 	}
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
-	if (inet_add_protocol(&tunnel64_protocol, IPPROTO_IPV6)) {
+	if (IS_ENABLED(CONFIG_IPV6) &&
+	    inet_add_protocol(&tunnel64_protocol, IPPROTO_IPV6)) {
 		printk(KERN_ERR "tunnel64 init: can't add protocol\n");
 		inet_del_protocol(&tunnel4_protocol, IPPROTO_IPIP);
 		return -EAGAIN;
 	}
-#endif
 	return 0;
 }
 
 static void __exit tunnel4_fini(void)
 {
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
-	if (inet_del_protocol(&tunnel64_protocol, IPPROTO_IPV6))
+	if (IS_ENABLED(CONFIG_IPV6) &&
+	    inet_del_protocol(&tunnel64_protocol, IPPROTO_IPV6))
 		printk(KERN_ERR "tunnel64 close: can't remove protocol\n");
-#endif
+
 	if (inet_del_protocol(&tunnel4_protocol, IPPROTO_IPIP))
 		printk(KERN_ERR "tunnel4 close: can't remove protocol\n");
 }
diff --git a/net/ipv4/xfrm4_tunnel.c b/net/ipv4/xfrm4_tunnel.c
index 8280645..b6de688 100644
--- a/net/ipv4/xfrm4_tunnel.c
+++ b/net/ipv4/xfrm4_tunnel.c
@@ -84,25 +84,25 @@ static int __init ipip_init(void)
 		xfrm_unregister_type(&ipip_type, AF_INET);
 		return -EAGAIN;
 	}
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
-	if (xfrm4_tunnel_register(&xfrm64_tunnel_handler, AF_INET6)) {
+	if (IS_ENABLED(CONFIG_IPV6) &&
+	    xfrm4_tunnel_register(&xfrm64_tunnel_handler, AF_INET6)) {
 		printk(KERN_INFO "ipip init: can't add xfrm handler for AF_INET6\n");
 		xfrm4_tunnel_deregister(&xfrm_tunnel_handler, AF_INET);
 		xfrm_unregister_type(&ipip_type, AF_INET);
 		return -EAGAIN;
 	}
-#endif
 	return 0;
 }
 
 static void __exit ipip_fini(void)
 {
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
-	if (xfrm4_tunnel_deregister(&xfrm64_tunnel_handler, AF_INET6))
+	if (IS_ENABLED(CONFIG_IPV6) &&
+	    xfrm4_tunnel_deregister(&xfrm64_tunnel_handler, AF_INET6))
 		printk(KERN_INFO "ipip close: can't remove xfrm handler for AF_INET6\n");
-#endif
+
 	if (xfrm4_tunnel_deregister(&xfrm_tunnel_handler, AF_INET))
 		printk(KERN_INFO "ipip close: can't remove xfrm handler for AF_INET\n");
+
 	if (xfrm_unregister_type(&ipip_type, AF_INET) < 0)
 		printk(KERN_INFO "ipip close: can't remove xfrm type\n");
 }
