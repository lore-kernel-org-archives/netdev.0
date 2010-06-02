From: arno@natisbad.org (Arnaud Ebalard)
Subject: Re: [PATCHv3] Refactor update of IPv6 flowi destination address for srcrt (RH) option
Date: Wed, 02 Jun 2010 09:35:01 +0200
Message-ID: <87sk55q44a.fsf_-_@small.ssi.corp>
References: <87wruid8rx.fsf@small.ssi.corp> <8739x6d0ky.fsf@small.ssi.corp>
	<1275422925.19372.114.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Joe Perches <joe@perches.com>,
	YOSHIFUJI Hideaki / =?utf-8?B?5ZCJ6Jek?=
	 =?utf-8?B?6Iux5piO?= <yoshfuji@linux-ipv6.org>,
	netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from copper.chdir.org ([88.191.97.87]:37895 "EHLO copper.chdir.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751350Ab0FBHfP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Jun 2010 03:35:15 -0400
In-Reply-To: <1275422925.19372.114.camel@Joe-Laptop.home> (Joe Perches's
	message of "Tue, 01 Jun 2010 13:08:45 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Here is a v3 based on the comments I received from Joe. The helper is
now in exthdrs.c (no more inline) and has a proper name.

Applies on net-2.6. Tested on 2.6.34.

Cheers,

a+

>From ec9c9695345f4821060a78bd3243cdfeaa852897 Mon Sep 17 00:00:00 2001
From: Arnaud Ebalard <arno@natisbad.org>
Date: Wed, 2 Jun 2010 09:25:27 +0200
Subject: [PATCH] Refactor update of IPv6 flowi destination address for srcrt (RH) option

There are more than a dozen occurrences of following code in the
IPv6 stack:

    if (opt && opt->srcrt) {
            struct rt0_hdr *rt0 = (struct rt0_hdr *) opt->srcrt;
            ipv6_addr_copy(&final, &fl.fl6_dst);
            ipv6_addr_copy(&fl.fl6_dst, rt0->addr);
            final_p = &final;
    }

Replace those with a helper. Note that the helper overrides final_p
in all cases. This is ok as final_p was previously initialized to
NULL when declared.

Signed-off-by: Arnaud Ebalard <arno@natisbad.org>
---
 include/net/ipv6.h               |    4 ++++
 net/dccp/ipv6.c                  |   30 ++++++------------------------
 net/ipv6/af_inet6.c              |    9 ++-------
 net/ipv6/datagram.c              |   18 ++++--------------
 net/ipv6/exthdrs.c               |   24 ++++++++++++++++++++++++
 net/ipv6/inet6_connection_sock.c |    9 ++-------
 net/ipv6/raw.c                   |   10 ++--------
 net/ipv6/syncookies.c            |    9 ++-------
 net/ipv6/tcp_ipv6.c              |   27 ++++++---------------------
 net/ipv6/udp.c                   |   11 +++--------
 10 files changed, 55 insertions(+), 96 deletions(-)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 2600b69..f5808d5 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -551,6 +551,10 @@ extern int 			ipv6_ext_hdr(u8 nexthdr);
 
 extern int ipv6_find_tlv(struct sk_buff *skb, int offset, int type);
 
+extern struct in6_addr *fl6_update_dst(struct flowi *fl,
+				       const struct ipv6_txoptions *opt,
+				       struct in6_addr *orig);
+
 /*
  *	socket options (ipv6_sockglue.c)
  */
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index 0916988..6e3f325 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -248,7 +248,7 @@ static int dccp_v6_send_response(struct sock *sk, struct request_sock *req,
 	struct ipv6_pinfo *np = inet6_sk(sk);
 	struct sk_buff *skb;
 	struct ipv6_txoptions *opt = NULL;
-	struct in6_addr *final_p = NULL, final;
+	struct in6_addr *final_p, final;
 	struct flowi fl;
 	int err = -1;
 	struct dst_entry *dst;
@@ -265,13 +265,7 @@ static int dccp_v6_send_response(struct sock *sk, struct request_sock *req,
 
 	opt = np->opt;
 
-	if (opt != NULL && opt->srcrt != NULL) {
-		const struct rt0_hdr *rt0 = (struct rt0_hdr *)opt->srcrt;
-
-		ipv6_addr_copy(&final, &fl.fl6_dst);
-		ipv6_addr_copy(&fl.fl6_dst, rt0->addr);
-		final_p = &final;
-	}
+	final_p = fl6_update_dst(&fl, opt, &final);
 
 	err = ip6_dst_lookup(sk, &dst, &fl);
 	if (err)
@@ -545,19 +539,13 @@ static struct sock *dccp_v6_request_recv_sock(struct sock *sk,
 		goto out_overflow;
 
 	if (dst == NULL) {
-		struct in6_addr *final_p = NULL, final;
+		struct in6_addr *final_p, final;
 		struct flowi fl;
 
 		memset(&fl, 0, sizeof(fl));
 		fl.proto = IPPROTO_DCCP;
 		ipv6_addr_copy(&fl.fl6_dst, &ireq6->rmt_addr);
-		if (opt != NULL && opt->srcrt != NULL) {
-			const struct rt0_hdr *rt0 = (struct rt0_hdr *)opt->srcrt;
-
-			ipv6_addr_copy(&final, &fl.fl6_dst);
-			ipv6_addr_copy(&fl.fl6_dst, rt0->addr);
-			final_p = &final;
-		}
+		final_p = fl6_update_dst(&fl, opt, &final);
 		ipv6_addr_copy(&fl.fl6_src, &ireq6->loc_addr);
 		fl.oif = sk->sk_bound_dev_if;
 		fl.fl_ip_dport = inet_rsk(req)->rmt_port;
@@ -885,7 +873,7 @@ static int dccp_v6_connect(struct sock *sk, struct sockaddr *uaddr,
 	struct inet_sock *inet = inet_sk(sk);
 	struct ipv6_pinfo *np = inet6_sk(sk);
 	struct dccp_sock *dp = dccp_sk(sk);
-	struct in6_addr *saddr = NULL, *final_p = NULL, final;
+	struct in6_addr *saddr = NULL, *final_p, final;
 	struct flowi fl;
 	struct dst_entry *dst;
 	int addr_type;
@@ -988,13 +976,7 @@ static int dccp_v6_connect(struct sock *sk, struct sockaddr *uaddr,
 	fl.fl_ip_sport = inet->inet_sport;
 	security_sk_classify_flow(sk, &fl);
 
-	if (np->opt != NULL && np->opt->srcrt != NULL) {
-		const struct rt0_hdr *rt0 = (struct rt0_hdr *)np->opt->srcrt;
-
-		ipv6_addr_copy(&final, &fl.fl6_dst);
-		ipv6_addr_copy(&fl.fl6_dst, rt0->addr);
-		final_p = &final;
-	}
+	final_p = fl6_update_dst(&fl, np->opt, &final);
 
 	err = ip6_dst_lookup(sk, &dst, &fl);
 	if (err)
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index e733942..94b1b9c 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -651,7 +651,7 @@ int inet6_sk_rebuild_header(struct sock *sk)
 
 	if (dst == NULL) {
 		struct inet_sock *inet = inet_sk(sk);
-		struct in6_addr *final_p = NULL, final;
+		struct in6_addr *final_p, final;
 		struct flowi fl;
 
 		memset(&fl, 0, sizeof(fl));
@@ -665,12 +665,7 @@ int inet6_sk_rebuild_header(struct sock *sk)
 		fl.fl_ip_sport = inet->inet_sport;
 		security_sk_classify_flow(sk, &fl);
 
-		if (np->opt && np->opt->srcrt) {
-			struct rt0_hdr *rt0 = (struct rt0_hdr *) np->opt->srcrt;
-			ipv6_addr_copy(&final, &fl.fl6_dst);
-			ipv6_addr_copy(&fl.fl6_dst, rt0->addr);
-			final_p = &final;
-		}
+		final_p = fl6_update_dst(&fl, np->opt, &final);
 
 		err = ip6_dst_lookup(sk, &dst, &fl);
 		if (err) {
diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
index 7126846..7d929a2 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -38,10 +38,11 @@ int ip6_datagram_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 	struct sockaddr_in6	*usin = (struct sockaddr_in6 *) uaddr;
 	struct inet_sock      	*inet = inet_sk(sk);
 	struct ipv6_pinfo      	*np = inet6_sk(sk);
-	struct in6_addr		*daddr, *final_p = NULL, final;
+	struct in6_addr		*daddr, *final_p, final;
 	struct dst_entry	*dst;
 	struct flowi		fl;
 	struct ip6_flowlabel	*flowlabel = NULL;
+	struct ipv6_txoptions   *opt;
 	int			addr_type;
 	int			err;
 
@@ -155,19 +156,8 @@ ipv4_connected:
 
 	security_sk_classify_flow(sk, &fl);
 
-	if (flowlabel) {
-		if (flowlabel->opt && flowlabel->opt->srcrt) {
-			struct rt0_hdr *rt0 = (struct rt0_hdr *) flowlabel->opt->srcrt;
-			ipv6_addr_copy(&final, &fl.fl6_dst);
-			ipv6_addr_copy(&fl.fl6_dst, rt0->addr);
-			final_p = &final;
-		}
-	} else if (np->opt && np->opt->srcrt) {
-		struct rt0_hdr *rt0 = (struct rt0_hdr *)np->opt->srcrt;
-		ipv6_addr_copy(&final, &fl.fl6_dst);
-		ipv6_addr_copy(&fl.fl6_dst, rt0->addr);
-		final_p = &final;
-	}
+	opt = flowlabel ? flowlabel->opt : np->opt;
+	final_p = fl6_update_dst(&fl, opt, &final);
 
 	err = ip6_dst_lookup(sk, &dst, &fl);
 	if (err)
diff --git a/net/ipv6/exthdrs.c b/net/ipv6/exthdrs.c
index 8a659f9..853a633 100644
--- a/net/ipv6/exthdrs.c
+++ b/net/ipv6/exthdrs.c
@@ -874,3 +874,27 @@ struct ipv6_txoptions *ipv6_fixup_options(struct ipv6_txoptions *opt_space,
 	return opt;
 }
 
+/**
+ * fl6_update_dst - update flowi destination address with info given
+ *                  by srcrt option, if any.
+ *
+ * @fl: flowi for which fl6_dst is to be updated
+ * @opt: struct ipv6_txoptions in which to look for srcrt opt
+ * @orig: copy of original fl6_dst address if modified
+ *
+ * Returns NULL if no txoptions or no srcrt, otherwise returns orig
+ * and initial value of fl->fl6_dst set in orig
+ */
+struct in6_addr *fl6_update_dst(struct flowi *fl,
+				const struct ipv6_txoptions *opt,
+				struct in6_addr *orig)
+{
+	if (!opt || !opt->srcrt)
+		return NULL;
+
+	ipv6_addr_copy(orig, &fl->fl6_dst);
+	ipv6_addr_copy(&fl->fl6_dst, ((struct rt0_hdr *)opt->srcrt)->addr);
+	return orig;
+}
+
+EXPORT_SYMBOL_GPL(fl6_update_dst);
diff --git a/net/ipv6/inet6_connection_sock.c b/net/ipv6/inet6_connection_sock.c
index 0c5e3c3..8a16280 100644
--- a/net/ipv6/inet6_connection_sock.c
+++ b/net/ipv6/inet6_connection_sock.c
@@ -185,7 +185,7 @@ int inet6_csk_xmit(struct sk_buff *skb)
 	struct ipv6_pinfo *np = inet6_sk(sk);
 	struct flowi fl;
 	struct dst_entry *dst;
-	struct in6_addr *final_p = NULL, final;
+	struct in6_addr *final_p, final;
 
 	memset(&fl, 0, sizeof(fl));
 	fl.proto = sk->sk_protocol;
@@ -199,12 +199,7 @@ int inet6_csk_xmit(struct sk_buff *skb)
 	fl.fl_ip_dport = inet->inet_dport;
 	security_sk_classify_flow(sk, &fl);
 
-	if (np->opt && np->opt->srcrt) {
-		struct rt0_hdr *rt0 = (struct rt0_hdr *)np->opt->srcrt;
-		ipv6_addr_copy(&final, &fl.fl6_dst);
-		ipv6_addr_copy(&fl.fl6_dst, rt0->addr);
-		final_p = &final;
-	}
+	final_p = fl6_update_dst(&fl, np->opt, &final);
 
 	dst = __inet6_csk_dst_check(sk, np->dst_cookie);
 
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index 4a4dcbe..864eb8e 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -725,7 +725,7 @@ static int rawv6_sendmsg(struct kiocb *iocb, struct sock *sk,
 {
 	struct ipv6_txoptions opt_space;
 	struct sockaddr_in6 * sin6 = (struct sockaddr_in6 *) msg->msg_name;
-	struct in6_addr *daddr, *final_p = NULL, final;
+	struct in6_addr *daddr, *final_p, final;
 	struct inet_sock *inet = inet_sk(sk);
 	struct ipv6_pinfo *np = inet6_sk(sk);
 	struct raw6_sock *rp = raw6_sk(sk);
@@ -847,13 +847,7 @@ static int rawv6_sendmsg(struct kiocb *iocb, struct sock *sk,
 	if (ipv6_addr_any(&fl.fl6_src) && !ipv6_addr_any(&np->saddr))
 		ipv6_addr_copy(&fl.fl6_src, &np->saddr);
 
-	/* merge ip6_build_xmit from ip6_output */
-	if (opt && opt->srcrt) {
-		struct rt0_hdr *rt0 = (struct rt0_hdr *) opt->srcrt;
-		ipv6_addr_copy(&final, &fl.fl6_dst);
-		ipv6_addr_copy(&fl.fl6_dst, rt0->addr);
-		final_p = &final;
-	}
+	final_p = fl6_update_dst(&fl, opt, &final);
 
 	if (!fl.oif && ipv6_addr_is_multicast(&fl.fl6_dst))
 		fl.oif = np->mcast_oif;
diff --git a/net/ipv6/syncookies.c b/net/ipv6/syncookies.c
index 34d1f06..1238370 100644
--- a/net/ipv6/syncookies.c
+++ b/net/ipv6/syncookies.c
@@ -240,17 +240,12 @@ struct sock *cookie_v6_check(struct sock *sk, struct sk_buff *skb)
 	 * me if there is a preferred way.
 	 */
 	{
-		struct in6_addr *final_p = NULL, final;
+		struct in6_addr *final_p, final;
 		struct flowi fl;
 		memset(&fl, 0, sizeof(fl));
 		fl.proto = IPPROTO_TCP;
 		ipv6_addr_copy(&fl.fl6_dst, &ireq6->rmt_addr);
-		if (np->opt && np->opt->srcrt) {
-			struct rt0_hdr *rt0 = (struct rt0_hdr *) np->opt->srcrt;
-			ipv6_addr_copy(&final, &fl.fl6_dst);
-			ipv6_addr_copy(&fl.fl6_dst, rt0->addr);
-			final_p = &final;
-		}
+		final_p = fl6_update_dst(&fl, np->opt, &final);
 		ipv6_addr_copy(&fl.fl6_src, &ireq6->loc_addr);
 		fl.oif = sk->sk_bound_dev_if;
 		fl.mark = sk->sk_mark;
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 2b7c3a1..e487080 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -129,7 +129,7 @@ static int tcp_v6_connect(struct sock *sk, struct sockaddr *uaddr,
 	struct inet_connection_sock *icsk = inet_csk(sk);
 	struct ipv6_pinfo *np = inet6_sk(sk);
 	struct tcp_sock *tp = tcp_sk(sk);
-	struct in6_addr *saddr = NULL, *final_p = NULL, final;
+	struct in6_addr *saddr = NULL, *final_p, final;
 	struct flowi fl;
 	struct dst_entry *dst;
 	int addr_type;
@@ -250,12 +250,7 @@ static int tcp_v6_connect(struct sock *sk, struct sockaddr *uaddr,
 	fl.fl_ip_dport = usin->sin6_port;
 	fl.fl_ip_sport = inet->inet_sport;
 
-	if (np->opt && np->opt->srcrt) {
-		struct rt0_hdr *rt0 = (struct rt0_hdr *)np->opt->srcrt;
-		ipv6_addr_copy(&final, &fl.fl6_dst);
-		ipv6_addr_copy(&fl.fl6_dst, rt0->addr);
-		final_p = &final;
-	}
+	final_p = fl6_update_dst(&fl, np->opt, &final);
 
 	security_sk_classify_flow(sk, &fl);
 
@@ -477,7 +472,7 @@ static int tcp_v6_send_synack(struct sock *sk, struct request_sock *req,
 	struct ipv6_pinfo *np = inet6_sk(sk);
 	struct sk_buff * skb;
 	struct ipv6_txoptions *opt = NULL;
-	struct in6_addr * final_p = NULL, final;
+	struct in6_addr * final_p, final;
 	struct flowi fl;
 	struct dst_entry *dst;
 	int err = -1;
@@ -494,12 +489,7 @@ static int tcp_v6_send_synack(struct sock *sk, struct request_sock *req,
 	security_req_classify_flow(req, &fl);
 
 	opt = np->opt;
-	if (opt && opt->srcrt) {
-		struct rt0_hdr *rt0 = (struct rt0_hdr *) opt->srcrt;
-		ipv6_addr_copy(&final, &fl.fl6_dst);
-		ipv6_addr_copy(&fl.fl6_dst, rt0->addr);
-		final_p = &final;
-	}
+	final_p = fl6_update_dst(&fl, opt, &final);
 
 	err = ip6_dst_lookup(sk, &dst, &fl);
 	if (err)
@@ -1392,18 +1382,13 @@ static struct sock * tcp_v6_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
 		goto out_overflow;
 
 	if (dst == NULL) {
-		struct in6_addr *final_p = NULL, final;
+		struct in6_addr *final_p, final;
 		struct flowi fl;
 
 		memset(&fl, 0, sizeof(fl));
 		fl.proto = IPPROTO_TCP;
 		ipv6_addr_copy(&fl.fl6_dst, &treq->rmt_addr);
-		if (opt && opt->srcrt) {
-			struct rt0_hdr *rt0 = (struct rt0_hdr *) opt->srcrt;
-			ipv6_addr_copy(&final, &fl.fl6_dst);
-			ipv6_addr_copy(&fl.fl6_dst, rt0->addr);
-			final_p = &final;
-		}
+		final_p = fl6_update_dst(&fl, opt, &final);
 		ipv6_addr_copy(&fl.fl6_src, &treq->loc_addr);
 		fl.oif = sk->sk_bound_dev_if;
 		fl.mark = sk->sk_mark;
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 87be586..1dd1aff 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -927,7 +927,7 @@ int udpv6_sendmsg(struct kiocb *iocb, struct sock *sk,
 	struct inet_sock *inet = inet_sk(sk);
 	struct ipv6_pinfo *np = inet6_sk(sk);
 	struct sockaddr_in6 *sin6 = (struct sockaddr_in6 *) msg->msg_name;
-	struct in6_addr *daddr, *final_p = NULL, final;
+	struct in6_addr *daddr, *final_p, final;
 	struct ipv6_txoptions *opt = NULL;
 	struct ip6_flowlabel *flowlabel = NULL;
 	struct flowi fl;
@@ -1097,14 +1097,9 @@ do_udp_sendmsg:
 		ipv6_addr_copy(&fl.fl6_src, &np->saddr);
 	fl.fl_ip_sport = inet->inet_sport;
 
-	/* merge ip6_build_xmit from ip6_output */
-	if (opt && opt->srcrt) {
-		struct rt0_hdr *rt0 = (struct rt0_hdr *) opt->srcrt;
-		ipv6_addr_copy(&final, &fl.fl6_dst);
-		ipv6_addr_copy(&fl.fl6_dst, rt0->addr);
-		final_p = &final;
+	final_p = fl6_update_dst(&fl, opt, &final);
+	if (final_p)
 		connected = 0;
-	}
 
 	if (!fl.oif && ipv6_addr_is_multicast(&fl.fl6_dst)) {
 		fl.oif = np->mcast_oif;
-- 
1.7.1

