From: arno@natisbad.org (Arnaud Ebalard)
Subject: [PATCH] Refactor update of IPv6 flow destination address for srcrt (RH) option
Date: Tue, 01 Jun 2010 18:20:34 +0200
Message-ID: <87wruid8rx.fsf@small.ssi.corp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: YOSHIFUJI Hideaki / =?utf-8?B?5ZCJ6Jek6Iux5piO?=
	<yoshfuji@linux-ipv6.org>, <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from copper.chdir.org ([88.191.97.87]:60572 "EHLO copper.chdir.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756012Ab0FAQUt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Jun 2010 12:20:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

While playing with associated code, I noticed there are more than a
dozen occurrences of the following in the IPv6 stack:

    if (opt && opt->srcrt) {
            struct rt0_hdr *rt0 = (struct rt0_hdr *) opt->srcrt;
            ipv6_addr_copy(&final, &fl.fl6_dst);
            ipv6_addr_copy(&fl.fl6_dst, rt0->addr);
            final_p = &final;
    }

Maybe this can be replaced with a helper (not sure about the name
though).


Signed-off-by: Arnaud Ebalard <arno@natisbad.org>
---
 include/net/ipv6.h               |   13 +++++++++++++
 net/dccp/ipv6.c                  |   24 +++---------------------
 net/ipv6/af_inet6.c              |    7 +------
 net/ipv6/datagram.c              |   16 +++-------------
 net/ipv6/inet6_connection_sock.c |    7 +------
 net/ipv6/raw.c                   |    8 +-------
 net/ipv6/syncookies.c            |    7 +------
 net/ipv6/tcp_ipv6.c              |   21 +++------------------
 net/ipv6/udp.c                   |    9 ++-------
 9 files changed, 28 insertions(+), 84 deletions(-)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 2600b69..9edfa1c 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -290,6 +290,19 @@ static inline void ipv6_addr_copy(struct in6_addr *a1, const struct in6_addr *a2
 	memcpy(a1, a2, sizeof(struct in6_addr));
 }
 
+static inline struct in6_addr *srcrt_dst_flow_update(struct in6_addr *final,
+						     struct in6_addr *fl6dst,
+						     const struct ipv6_txoptions *opt)
+{
+	if (opt && opt->srcrt) {
+		const struct rt0_hdr *rt0 = (struct rt0_hdr *)opt->srcrt;
+		ipv6_addr_copy(final, fl6dst);
+		ipv6_addr_copy(fl6dst, rt0->addr);
+		return final;
+	}
+	return NULL;
+}
+
 static inline void ipv6_addr_prefix(struct in6_addr *pfx, 
 				    const struct in6_addr *addr,
 				    int plen)
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index 0916988..fc435ba 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -265,13 +265,7 @@ static int dccp_v6_send_response(struct sock *sk, struct request_sock *req,
 
 	opt = np->opt;
 
-	if (opt != NULL && opt->srcrt != NULL) {
-		const struct rt0_hdr *rt0 = (struct rt0_hdr *)opt->srcrt;
-
-		ipv6_addr_copy(&final, &fl.fl6_dst);
-		ipv6_addr_copy(&fl.fl6_dst, rt0->addr);
-		final_p = &final;
-	}
+	final_p = srcrt_dst_flow_update(&final, &fl.fl6_dst, opt);
 
 	err = ip6_dst_lookup(sk, &dst, &fl);
 	if (err)
@@ -551,13 +545,7 @@ static struct sock *dccp_v6_request_recv_sock(struct sock *sk,
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
+		final_p = srcrt_dst_flow_update(&final, &fl.fl6_dst, opt);
 		ipv6_addr_copy(&fl.fl6_src, &ireq6->loc_addr);
 		fl.oif = sk->sk_bound_dev_if;
 		fl.fl_ip_dport = inet_rsk(req)->rmt_port;
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
+	final_p = srcrt_dst_flow_update(&final, &fl.fl6_dst, np->opt);
 
 	err = ip6_dst_lookup(sk, &dst, &fl);
 	if (err)
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index e733942..d6e6491 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -665,12 +665,7 @@ int inet6_sk_rebuild_header(struct sock *sk)
 		fl.fl_ip_sport = inet->inet_sport;
 		security_sk_classify_flow(sk, &fl);
 
-		if (np->opt && np->opt->srcrt) {
-			struct rt0_hdr *rt0 = (struct rt0_hdr *) np->opt->srcrt;
-			ipv6_addr_copy(&final, &fl.fl6_dst);
-			ipv6_addr_copy(&fl.fl6_dst, rt0->addr);
-			final_p = &final;
-		}
+		final_p = srcrt_dst_flow_update(&final, &fl.fl6_dst, np->opt);
 
 		err = ip6_dst_lookup(sk, &dst, &fl);
 		if (err) {
diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
index 7126846..2fcba06 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -42,6 +42,7 @@ int ip6_datagram_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
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
+	final_p = srcrt_dst_flow_update(&final, &fl.fl6_dst, opt);
 
 	err = ip6_dst_lookup(sk, &dst, &fl);
 	if (err)
diff --git a/net/ipv6/inet6_connection_sock.c b/net/ipv6/inet6_connection_sock.c
index 0c5e3c3..505c8de 100644
--- a/net/ipv6/inet6_connection_sock.c
+++ b/net/ipv6/inet6_connection_sock.c
@@ -199,12 +199,7 @@ int inet6_csk_xmit(struct sk_buff *skb)
 	fl.fl_ip_dport = inet->inet_dport;
 	security_sk_classify_flow(sk, &fl);
 
-	if (np->opt && np->opt->srcrt) {
-		struct rt0_hdr *rt0 = (struct rt0_hdr *)np->opt->srcrt;
-		ipv6_addr_copy(&final, &fl.fl6_dst);
-		ipv6_addr_copy(&fl.fl6_dst, rt0->addr);
-		final_p = &final;
-	}
+	final_p = srcrt_dst_flow_update(&final, &fl.fl6_dst, np->opt);
 
 	dst = __inet6_csk_dst_check(sk, np->dst_cookie);
 
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index 4a4dcbe..91211bd 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
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
+	final_p = srcrt_dst_flow_update(&final, &fl.fl6_dst, opt);
 
 	if (!fl.oif && ipv6_addr_is_multicast(&fl.fl6_dst))
 		fl.oif = np->mcast_oif;
diff --git a/net/ipv6/syncookies.c b/net/ipv6/syncookies.c
index 34d1f06..7d27bc7 100644
--- a/net/ipv6/syncookies.c
+++ b/net/ipv6/syncookies.c
@@ -245,12 +245,7 @@ struct sock *cookie_v6_check(struct sock *sk, struct sk_buff *skb)
 		memset(&fl, 0, sizeof(fl));
 		fl.proto = IPPROTO_TCP;
 		ipv6_addr_copy(&fl.fl6_dst, &ireq6->rmt_addr);
-		if (np->opt && np->opt->srcrt) {
-			struct rt0_hdr *rt0 = (struct rt0_hdr *) np->opt->srcrt;
-			ipv6_addr_copy(&final, &fl.fl6_dst);
-			ipv6_addr_copy(&fl.fl6_dst, rt0->addr);
-			final_p = &final;
-		}
+		final_p = srcrt_dst_flow_update(&final, &fl.fl6_dst, np->opt);
 		ipv6_addr_copy(&fl.fl6_src, &ireq6->loc_addr);
 		fl.oif = sk->sk_bound_dev_if;
 		fl.mark = sk->sk_mark;
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 2b7c3a1..2dcb536 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -250,12 +250,7 @@ static int tcp_v6_connect(struct sock *sk, struct sockaddr *uaddr,
 	fl.fl_ip_dport = usin->sin6_port;
 	fl.fl_ip_sport = inet->inet_sport;
 
-	if (np->opt && np->opt->srcrt) {
-		struct rt0_hdr *rt0 = (struct rt0_hdr *)np->opt->srcrt;
-		ipv6_addr_copy(&final, &fl.fl6_dst);
-		ipv6_addr_copy(&fl.fl6_dst, rt0->addr);
-		final_p = &final;
-	}
+	final_p = srcrt_dst_flow_update(&final, &fl.fl6_dst, np->opt);
 
 	security_sk_classify_flow(sk, &fl);
 
@@ -494,12 +489,7 @@ static int tcp_v6_send_synack(struct sock *sk, struct request_sock *req,
 	security_req_classify_flow(req, &fl);
 
 	opt = np->opt;
-	if (opt && opt->srcrt) {
-		struct rt0_hdr *rt0 = (struct rt0_hdr *) opt->srcrt;
-		ipv6_addr_copy(&final, &fl.fl6_dst);
-		ipv6_addr_copy(&fl.fl6_dst, rt0->addr);
-		final_p = &final;
-	}
+	final_p = srcrt_dst_flow_update(&final, &fl.fl6_dst, opt);
 
 	err = ip6_dst_lookup(sk, &dst, &fl);
 	if (err)
@@ -1398,12 +1388,7 @@ static struct sock * tcp_v6_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
 		memset(&fl, 0, sizeof(fl));
 		fl.proto = IPPROTO_TCP;
 		ipv6_addr_copy(&fl.fl6_dst, &treq->rmt_addr);
-		if (opt && opt->srcrt) {
-			struct rt0_hdr *rt0 = (struct rt0_hdr *) opt->srcrt;
-			ipv6_addr_copy(&final, &fl.fl6_dst);
-			ipv6_addr_copy(&fl.fl6_dst, rt0->addr);
-			final_p = &final;
-		}
+		final_p = srcrt_dst_flow_update(&final, &fl.fl6_dst, opt);
 		ipv6_addr_copy(&fl.fl6_src, &treq->loc_addr);
 		fl.oif = sk->sk_bound_dev_if;
 		fl.mark = sk->sk_mark;
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 87be586..a46ad07 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -1097,14 +1097,9 @@ do_udp_sendmsg:
 		ipv6_addr_copy(&fl.fl6_src, &np->saddr);
 	fl.fl_ip_sport = inet->inet_sport;
 
-	/* merge ip6_build_xmit from ip6_output */
-	if (opt && opt->srcrt) {
-		struct rt0_hdr *rt0 = (struct rt0_hdr *) opt->srcrt;
-		ipv6_addr_copy(&final, &fl.fl6_dst);
-		ipv6_addr_copy(&fl.fl6_dst, rt0->addr);
-		final_p = &final;
+	final_p = srcrt_dst_flow_update(&final, &fl.fl6_dst, opt);
+	if (final_p)
 		connected = 0;
-	}
 
 	if (!fl.oif && ipv6_addr_is_multicast(&fl.fl6_dst)) {
 		fl.oif = np->mcast_oif;
-- 
1.7.1


