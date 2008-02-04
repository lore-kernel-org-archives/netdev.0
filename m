From: Glenn Griffin <ggriffin.kernel@gmail.com>
Subject: [PATCH] Add IPv6 support to TCP SYN cookies
Date: Mon, 4 Feb 2008 15:01:01 -0800
Message-ID: <47a79d64.16538c0a.5b6a.ffffb0fe@mx.google.com>
Cc: Andi Kleen <andi@firstfloor.org>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0910.google.com ([209.85.198.188]:14379 "EHLO
	rv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757177AbYBDXTF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Feb 2008 18:19:05 -0500
Received: by rv-out-0910.google.com with SMTP id k20so1567185rvb.1
        for <netdev@vger.kernel.org>; Mon, 04 Feb 2008 15:19:01 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add IPv6 support to TCP SYN cookies.  This is written and tested against
2.6.24, and applies cleanly to linus' current HEAD (d2fc0b).  Unfortunately
linus' HEAD breaks my sky2 card at the moment, so I'm unable to test against
that.  I see no reason why it would be affected though.  Comments/suggestions
are welcome.

Signed-off-by: Glenn Griffin <ggriffin.kernel@gmail.com>
---
 include/net/tcp.h     |    4 +
 net/ipv4/syncookies.c |  203 ++++++++++++++++++++++++++++++++++++++++++++++++-
 net/ipv6/tcp_ipv6.c   |   77 +++++++++++++-----
 3 files changed, 260 insertions(+), 24 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index cb5b033..02dc6dd 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -435,6 +435,9 @@ extern struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb,
 				    struct ip_options *opt);
 extern __u32 cookie_v4_init_sequence(struct sock *sk, struct sk_buff *skb, 
 				     __u16 *mss);
+extern struct sock *cookie_v6_check(struct sock *sk, struct sk_buff *skb);
+extern __u32 cookie_v6_init_sequence(struct sock *sk, struct sk_buff *skb,
+				     __u16 *mss);
 
 /* tcp_output.c */
 
@@ -1337,6 +1340,7 @@ extern int tcp_proc_register(struct tcp_seq_afinfo *afinfo);
 extern void tcp_proc_unregister(struct tcp_seq_afinfo *afinfo);
 
 extern struct request_sock_ops tcp_request_sock_ops;
+extern struct request_sock_ops tcp6_request_sock_ops;
 
 extern int tcp_v4_destroy_sock(struct sock *sk);
 
diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
index 2da1be0..b342bae 100644
--- a/net/ipv4/syncookies.c
+++ b/net/ipv4/syncookies.c
@@ -3,6 +3,7 @@
  *
  *  Copyright (C) 1997 Andi Kleen
  *  Based on ideas by D.J.Bernstein and Eric Schenk.
+ *  IPv6 Support Added by Glenn Griffin (2008)
  *
  *	This program is free software; you can redistribute it and/or
  *      modify it under the terms of the GNU General Public License
@@ -10,8 +11,6 @@
  *      2 of the License, or (at your option) any later version.
  *
  *  $Id: syncookies.c,v 1.18 2002/02/01 22:01:04 davem Exp $
- *
- *  Missing: IPv6 support.
  */
 
 #include <linux/tcp.h>
@@ -19,6 +18,7 @@
 #include <linux/random.h>
 #include <linux/cryptohash.h>
 #include <linux/kernel.h>
+#include <net/ipv6.h>
 #include <net/tcp.h>
 
 extern int sysctl_tcp_syncookies;
@@ -281,3 +281,202 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb,
 	ret = get_cookie_sock(sk, skb, req, &rt->u.dst);
 out:	return ret;
 }
+
+/* IPv6 Implementation
+ * Just a reimplementation of the above IPv4 implementation adjusting for
+ * the longer address length.  Could optionally add an additional addrlen
+ * argument to most of the above functions.
+ *
+ * Reference the code comments above to understand what is going on
+ */
+
+static u32 cookie_hash6(__be32 *saddr, __be32 *daddr, __be16 sport,
+			__be16 dport, u32 count, int c)
+{
+	__u32 tmp[16 + 5 + SHA_WORKSPACE_WORDS];
+
+	/*
+	 * we have 320 bits of information to hash, copy in the remaining
+	 * 192 bits required for sha_transform, from the syncookie_secret
+	 * and overwrite the digest with the secret
+	 */
+	memcpy(tmp + 10, syncookie_secret[c], 44);
+	memcpy(tmp, saddr, 16);
+	memcpy(tmp + 4, daddr, 16);
+	tmp[8] = ((__force u32)sport << 16) + (__force u32)dport;
+	tmp[9] = count;
+	sha_transform(tmp + 16, (__u8 *)tmp, tmp + 16 + 5);
+
+	return tmp[17];
+}
+
+static __u32 secure_tcp_syn_cookie6(__be32 *saddr, __be32 *daddr, __be16 sport,
+				    __be16 dport, __u32 sseq, __u32 count,
+				    __u32 data)
+{
+	return (cookie_hash6(saddr, daddr, sport, dport, 0, 0) +
+		sseq + (count << COOKIEBITS) +
+		((cookie_hash6(saddr, daddr, sport, dport, count, 1) + data)
+		& COOKIEMASK));
+}
+
+static __u32 check_tcp_syn_cookie6(__u32 cookie, __be32 *saddr, __be32 *daddr,
+				   __be16 sport, __be16 dport, __u32 sseq,
+				   __u32 count, __u32 maxdiff)
+{
+	__u32 diff;
+
+	cookie -= cookie_hash6(saddr, daddr, sport, dport, 0, 0) + sseq;
+
+	diff = (count - (cookie >> COOKIEBITS)) & ((__u32) -1 >> COOKIEBITS);
+	if (diff >= maxdiff)
+		return (__u32)-1;
+
+	return (cookie -
+		cookie_hash6(saddr, daddr, sport, dport, count - diff, 1))
+		& COOKIEMASK;
+}
+
+__u32 cookie_v6_init_sequence(struct sock *sk, struct sk_buff *skb, __u16 *mssp)
+{
+	struct ipv6hdr *iph = ipv6_hdr(skb);
+	const struct tcphdr *th = tcp_hdr(skb);
+	int mssind;
+	const __u16 mss = *mssp;
+
+	tcp_sk(sk)->last_synq_overflow = jiffies;
+
+	for (mssind = 0; mss > msstab[mssind + 1]; mssind++)
+		;
+	*mssp = msstab[mssind] + 1;
+
+	NET_INC_STATS_BH(LINUX_MIB_SYNCOOKIESSENT);
+
+	return secure_tcp_syn_cookie6(iph->saddr.s6_addr32,
+				      iph->daddr.s6_addr32,
+				      th->source, th->dest, ntohl(th->seq),
+				      jiffies / (HZ * 60), mssind);
+}
+
+static inline int cookie_check6(struct sk_buff *skb, __u32 cookie)
+{
+	struct ipv6hdr *iph = ipv6_hdr(skb);
+	const struct tcphdr *th = tcp_hdr(skb);
+	__u32 seq = ntohl(th->seq) - 1;
+	__u32 mssind = check_tcp_syn_cookie6(cookie, iph->saddr.s6_addr32,
+					     iph->daddr.s6_addr32, th->source,
+					     th->dest, seq, jiffies / (HZ * 60),
+					     COUNTER_TRIES);
+
+	return mssind < NUM_MSS ? msstab[mssind] + 1 : 0;
+}
+
+struct sock *cookie_v6_check(struct sock *sk, struct sk_buff *skb)
+{
+	struct inet_request_sock *ireq;
+	struct inet6_request_sock *ireq6;
+	struct tcp_request_sock *treq;
+	struct ipv6_pinfo *np = inet6_sk(sk);
+	struct tcp_sock *tp = tcp_sk(sk);
+	const struct tcphdr *th = tcp_hdr(skb);
+	__u32 cookie = ntohl(th->ack_seq) - 1;
+	struct sock *ret = sk;
+	struct request_sock *req;
+	int mss;
+	struct dst_entry *dst;
+	__u8 rcv_wscale;
+
+	if (!sysctl_tcp_syncookies || !th->ack)
+		goto out;
+
+	if (time_after(jiffies, tp->last_synq_overflow + TCP_TIMEOUT_INIT) ||
+		(mss = cookie_check6(skb, cookie)) == 0) {
+		NET_INC_STATS_BH(LINUX_MIB_SYNCOOKIESFAILED);
+		goto out;
+	}
+
+	NET_INC_STATS_BH(LINUX_MIB_SYNCOOKIESRECV);
+
+	ret = NULL;
+	req = inet6_reqsk_alloc(&tcp6_request_sock_ops);
+	if (!req)
+		goto out;
+
+	ireq = inet_rsk(req);
+	ireq6 = inet6_rsk(req);
+	treq = tcp_rsk(req);
+	ireq6->pktopts = NULL;
+
+	if (security_inet_conn_request(sk, skb, req)) {
+		reqsk_free(req);
+		goto out;
+	}
+
+	req->mss = mss;
+	ireq->rmt_port = th->source;
+	ipv6_addr_copy(&ireq6->rmt_addr, &ipv6_hdr(skb)->saddr);
+	ipv6_addr_copy(&ireq6->loc_addr, &ipv6_hdr(skb)->daddr);
+	if (ipv6_opt_accepted(sk, skb) ||
+	    np->rxopt.bits.rxinfo || np->rxopt.bits.rxoinfo ||
+	    np->rxopt.bits.rxhlim || np->rxopt.bits.rxohlim) {
+		atomic_inc(&skb->users);
+		ireq6->pktopts = skb;
+	}
+
+	ireq6->iif = sk->sk_bound_dev_if;
+	/* So that link locals have meaning */
+	if (!sk->sk_bound_dev_if &&
+	    ipv6_addr_type(&ireq6->rmt_addr) & IPV6_ADDR_LINKLOCAL)
+		ireq6->iif = inet6_iif(skb);
+
+	req->expires = 0UL;
+	req->retrans = 0;
+	ireq->snd_wscale = ireq->rcv_wscale = ireq->tstamp_ok = 0;
+	ireq->wscale_ok = ireq->sack_ok = 0;
+	treq->rcv_isn = ntohl(th->seq) - 1;
+	treq->snt_isn = cookie;
+
+	/*
+	 * We need to lookup the dst_entry to get the correct window size.
+	 * This is taken from tcp_v6_syn_recv_sock.  Somebody please enlighten
+	 * me if there is a preferred way.
+	 */
+	{
+		struct in6_addr *final_p = NULL, final;
+		struct flowi fl;
+		memset(&fl, 0, sizeof(fl));
+		fl.proto = IPPROTO_TCP;
+		ipv6_addr_copy(&fl.fl6_dst, &ireq6->rmt_addr);
+		if (np->opt && np->opt->srcrt) {
+			struct rt0_hdr *rt0 = (struct rt0_hdr *) np->opt->srcrt;
+			ipv6_addr_copy(&final, &fl.fl6_dst);
+			ipv6_addr_copy(&fl.fl6_dst, rt0->addr);
+			final_p = &final;
+		}
+		ipv6_addr_copy(&fl.fl6_src, &ireq6->loc_addr);
+		fl.oif = sk->sk_bound_dev_if;
+		fl.fl_ip_dport = inet_rsk(req)->rmt_port;
+		fl.fl_ip_sport = inet_sk(sk)->sport;
+		security_req_classify_flow(req, &fl);
+		if (ip6_dst_lookup(sk, &dst, &fl)) {
+			reqsk_free(req);
+			goto out;
+		}
+		if (final_p)
+			ipv6_addr_copy(&fl.fl6_dst, final_p);
+		if ((xfrm_lookup(&dst, &fl, sk, 0)) < 0)
+			goto out;
+	}
+
+	req->window_clamp = dst_metric(dst, RTAX_WINDOW);
+	tcp_select_initial_window(tcp_full_space(sk), req->mss,
+				  &req->rcv_wnd, &req->window_clamp,
+				  0, &rcv_wscale);
+
+	ireq->rcv_wscale = rcv_wscale;
+
+	ret = get_cookie_sock(sk, skb, req, dst);
+
+out:	return ret;
+}
+
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 93980c3..ad39bd1 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -520,6 +520,20 @@ done:
 	return err;
 }
 
+static inline void syn_flood_warning(struct sk_buff *skb)
+{
+#ifdef CONFIG_SYN_COOKIES
+	if (sysctl_tcp_syncookies)
+		printk(KERN_INFO
+		       "TCPv6: Possible SYN flooding on port %d. "
+		       "Sending cookies.\n", ntohs(tcp_hdr(skb)->dest));
+	else
+#endif
+		printk(KERN_INFO
+		       "TCPv6: Possible SYN flooding on port %d. "
+		       "Dropping request.\n", ntohs(tcp_hdr(skb)->dest));
+}
+
 static void tcp_v6_reqsk_destructor(struct request_sock *req)
 {
 	if (inet6_rsk(req)->pktopts)
@@ -923,7 +937,7 @@ done_opts:
 }
 #endif
 
-static struct request_sock_ops tcp6_request_sock_ops __read_mostly = {
+struct request_sock_ops tcp6_request_sock_ops __read_mostly = {
 	.family		=	AF_INET6,
 	.obj_size	=	sizeof(struct tcp6_request_sock),
 	.rtx_syn_ack	=	tcp_v6_send_synack,
@@ -1221,9 +1235,9 @@ static struct sock *tcp_v6_hnd_req(struct sock *sk,struct sk_buff *skb)
 		return NULL;
 	}
 
-#if 0 /*def CONFIG_SYN_COOKIES*/
+#ifdef CONFIG_SYN_COOKIES
 	if (!th->rst && !th->syn && th->ack)
-		sk = cookie_v6_check(sk, skb, &(IPCB(skb)->opt));
+		sk = cookie_v6_check(sk, skb);
 #endif
 	return sk;
 }
@@ -1239,6 +1253,11 @@ static int tcp_v6_conn_request(struct sock *sk, struct sk_buff *skb)
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct request_sock *req = NULL;
 	__u32 isn = TCP_SKB_CB(skb)->when;
+#ifdef CONFIG_SYN_COOKIES
+	int want_cookie = 0;
+#else
+#define want_cookie 0
+#endif
 
 	if (skb->protocol == htons(ETH_P_IP))
 		return tcp_v4_conn_request(sk, skb);
@@ -1246,12 +1265,14 @@ static int tcp_v6_conn_request(struct sock *sk, struct sk_buff *skb)
 	if (!ipv6_unicast_destination(skb))
 		goto drop;
 
-	/*
-	 *	There are no SYN attacks on IPv6, yet...
-	 */
 	if (inet_csk_reqsk_queue_is_full(sk) && !isn) {
 		if (net_ratelimit())
-			printk(KERN_INFO "TCPv6: dropping request, synflood is possible\n");
+			syn_flood_warning(skb);
+#ifdef CONFIG_SYN_COOKIES
+		if (sysctl_tcp_syncookies)
+			want_cookie = 1;
+		else
+#endif
 		goto drop;
 	}
 
@@ -1272,29 +1293,39 @@ static int tcp_v6_conn_request(struct sock *sk, struct sk_buff *skb)
 
 	tcp_parse_options(skb, &tmp_opt, 0);
 
+	if (want_cookie) {
+		tcp_clear_options(&tmp_opt);
+		tmp_opt.saw_tstamp = 0;
+	}
+
 	tmp_opt.tstamp_ok = tmp_opt.saw_tstamp;
 	tcp_openreq_init(req, &tmp_opt, skb);
 
 	treq = inet6_rsk(req);
 	ipv6_addr_copy(&treq->rmt_addr, &ipv6_hdr(skb)->saddr);
 	ipv6_addr_copy(&treq->loc_addr, &ipv6_hdr(skb)->daddr);
-	TCP_ECN_create_request(req, tcp_hdr(skb));
 	treq->pktopts = NULL;
-	if (ipv6_opt_accepted(sk, skb) ||
-	    np->rxopt.bits.rxinfo || np->rxopt.bits.rxoinfo ||
-	    np->rxopt.bits.rxhlim || np->rxopt.bits.rxohlim) {
-		atomic_inc(&skb->users);
-		treq->pktopts = skb;
-	}
-	treq->iif = sk->sk_bound_dev_if;
+	if (!want_cookie)
+		TCP_ECN_create_request(req, tcp_hdr(skb));
+
+	if (want_cookie) {
+		isn = cookie_v6_init_sequence(sk, skb, &req->mss);
+	} else if (!isn) {
+		if (ipv6_opt_accepted(sk, skb) ||
+		    np->rxopt.bits.rxinfo || np->rxopt.bits.rxoinfo ||
+		    np->rxopt.bits.rxhlim || np->rxopt.bits.rxohlim) {
+			atomic_inc(&skb->users);
+			treq->pktopts = skb;
+		}
+		treq->iif = sk->sk_bound_dev_if;
 
-	/* So that link locals have meaning */
-	if (!sk->sk_bound_dev_if &&
-	    ipv6_addr_type(&treq->rmt_addr) & IPV6_ADDR_LINKLOCAL)
-		treq->iif = inet6_iif(skb);
+		/* So that link locals have meaning */
+		if (!sk->sk_bound_dev_if &&
+		    ipv6_addr_type(&treq->rmt_addr) & IPV6_ADDR_LINKLOCAL)
+			treq->iif = inet6_iif(skb);
 
-	if (isn == 0)
 		isn = tcp_v6_init_sequence(skb);
+	}
 
 	tcp_rsk(req)->snt_isn = isn;
 
@@ -1303,8 +1334,10 @@ static int tcp_v6_conn_request(struct sock *sk, struct sk_buff *skb)
 	if (tcp_v6_send_synack(sk, req, NULL))
 		goto drop;
 
-	inet6_csk_reqsk_queue_hash_add(sk, req, TCP_TIMEOUT_INIT);
-	return 0;
+	if (!want_cookie) {
+		inet6_csk_reqsk_queue_hash_add(sk, req, TCP_TIMEOUT_INIT);
+		return 0;
+	}
 
 drop:
 	if (req)
-- 
1.5.3.4

