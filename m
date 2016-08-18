From: Florian Westphal <fw@strlen.de>
Subject: [RFC 1/3] tcp: randomize tcp timestamp offsets for each connection
Date: Thu, 18 Aug 2016 14:48:45 +0200
Message-ID: <1471524527-10029-2-git-send-email-fw@strlen.de>
References: <1471524527-10029-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:51582 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754024AbcHRNAJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Aug 2016 09:00:09 -0400
In-Reply-To: <1471524527-10029-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit ceaa1fef65a7c2e ("tcp: adding a per-socket timestamp offset")
added the main infrastructure that is needed for per-connection
randomization, in particular writing/reading the on-wire tcp header
format takes the offset into account so rest of stack can use normal
tcp_time_stamp (jiffies).

So only two items are left:
 - add a tsoffset for request sockets
 - extend the tcp isn generator to also return another 32bit number
 in addition to the ISN.

Re-use of ISN generator also means timestamps are still monotonically
increasing for same connection quadruple.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 include/linux/tcp.h      |  1 +
 include/net/secure_seq.h | 13 +++++++++----
 include/net/tcp.h        |  2 +-
 net/core/secure_seq.c    | 19 +++++++++++++------
 net/ipv4/syncookies.c    |  1 +
 net/ipv4/tcp_input.c     |  7 ++++++-
 net/ipv4/tcp_ipv4.c      | 30 ++++++++++++++++++++----------
 net/ipv4/tcp_minisocks.c |  4 +++-
 net/ipv4/tcp_output.c    |  2 +-
 net/ipv6/syncookies.c    |  1 +
 net/ipv6/tcp_ipv6.c      | 28 ++++++++++++++++++----------
 11 files changed, 74 insertions(+), 34 deletions(-)

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index 7be9b12..edad1a1 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -122,6 +122,7 @@ struct tcp_request_sock {
 	u32				txhash;
 	u32				rcv_isn;
 	u32				snt_isn;
+	u32				ts_off;
 	u32				last_oow_ack_time; /* last SYNACK */
 	u32				rcv_nxt; /* the ack # by SYNACK. For
 						  * FastOpen it's the seq#
diff --git a/include/net/secure_seq.h b/include/net/secure_seq.h
index 3f36d45..3d576f7 100644
--- a/include/net/secure_seq.h
+++ b/include/net/secure_seq.h
@@ -3,13 +3,18 @@
 
 #include <linux/types.h>
 
+struct secure_tcp_seq {
+	u32 seq;
+	u32 tsoff;
+};
+
 u32 secure_ipv4_port_ephemeral(__be32 saddr, __be32 daddr, __be16 dport);
 u32 secure_ipv6_port_ephemeral(const __be32 *saddr, const __be32 *daddr,
 			       __be16 dport);
-__u32 secure_tcp_sequence_number(__be32 saddr, __be32 daddr,
-				 __be16 sport, __be16 dport);
-__u32 secure_tcpv6_sequence_number(const __be32 *saddr, const __be32 *daddr,
-				   __be16 sport, __be16 dport);
+struct secure_tcp_seq secure_tcp_sequence_number(__be32 saddr, __be32 daddr,
+						 __be16 sport, __be16 dport);
+struct secure_tcp_seq secure_tcpv6_sequence_number(const __be32 *saddr, const __be32 *daddr,
+						    __be16 sport, __be16 dport);
 u64 secure_dccp_sequence_number(__be32 saddr, __be32 daddr,
 				__be16 sport, __be16 dport);
 u64 secure_dccpv6_sequence_number(__be32 *saddr, __be32 *daddr,
diff --git a/include/net/tcp.h b/include/net/tcp.h
index c00e7d5..5707361 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1749,7 +1749,7 @@ struct tcp_request_sock_ops {
 	struct dst_entry *(*route_req)(const struct sock *sk, struct flowi *fl,
 				       const struct request_sock *req,
 				       bool *strict);
-	__u32 (*init_seq)(const struct sk_buff *skb);
+	__u32 (*init_seq)(const struct sk_buff *skb, u32 *tsoff);
 	int (*send_synack)(const struct sock *sk, struct dst_entry *dst,
 			   struct flowi *fl, struct request_sock *req,
 			   struct tcp_fastopen_cookie *foc,
diff --git a/net/core/secure_seq.c b/net/core/secure_seq.c
index fd3ce46..613f2fd 100644
--- a/net/core/secure_seq.c
+++ b/net/core/secure_seq.c
@@ -40,11 +40,13 @@ static u32 seq_scale(u32 seq)
 #endif
 
 #if IS_ENABLED(CONFIG_IPV6)
-__u32 secure_tcpv6_sequence_number(const __be32 *saddr, const __be32 *daddr,
-				   __be16 sport, __be16 dport)
+struct secure_tcp_seq
+secure_tcpv6_sequence_number(const __be32 *saddr, const __be32 *daddr,
+			     __be16 sport, __be16 dport)
 {
 	u32 secret[MD5_MESSAGE_BYTES / 4];
 	u32 hash[MD5_DIGEST_WORDS];
+	struct secure_tcp_seq seq;
 	u32 i;
 
 	net_secret_init();
@@ -58,7 +60,9 @@ __u32 secure_tcpv6_sequence_number(const __be32 *saddr, const __be32 *daddr,
 
 	md5_transform(hash, secret);
 
-	return seq_scale(hash[0]);
+	seq.seq = seq_scale(hash[0]);
+	seq.tsoff = hash[1];
+	return seq;
 }
 EXPORT_SYMBOL(secure_tcpv6_sequence_number);
 
@@ -86,10 +90,11 @@ EXPORT_SYMBOL(secure_ipv6_port_ephemeral);
 
 #ifdef CONFIG_INET
 
-__u32 secure_tcp_sequence_number(__be32 saddr, __be32 daddr,
-				 __be16 sport, __be16 dport)
+struct secure_tcp_seq secure_tcp_sequence_number(__be32 saddr, __be32 daddr,
+						 __be16 sport, __be16 dport)
 {
 	u32 hash[MD5_DIGEST_WORDS];
+	struct secure_tcp_seq seq;
 
 	net_secret_init();
 	hash[0] = (__force u32)saddr;
@@ -99,7 +104,9 @@ __u32 secure_tcp_sequence_number(__be32 saddr, __be32 daddr,
 
 	md5_transform(hash, net_secret);
 
-	return seq_scale(hash[0]);
+	seq.seq = seq_scale(hash[0]);
+	seq.tsoff = hash[1];
+	return seq;
 }
 
 u32 secure_ipv4_port_ephemeral(__be32 saddr, __be32 daddr, __be16 dport)
diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
index e3c4043..5db13f7 100644
--- a/net/ipv4/syncookies.c
+++ b/net/ipv4/syncookies.c
@@ -334,6 +334,7 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb)
 	treq = tcp_rsk(req);
 	treq->rcv_isn		= ntohl(th->seq) - 1;
 	treq->snt_isn		= cookie;
+	treq->ts_off		= 0;
 	req->mss		= mss;
 	ireq->ir_num		= ntohs(th->dest);
 	ireq->ir_rmt_port	= th->source;
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 3ebf45b..092f2dd 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -6249,6 +6249,7 @@ int tcp_conn_request(struct request_sock_ops *rsk_ops,
 		goto drop;
 
 	tcp_rsk(req)->af_specific = af_ops;
+	tcp_rsk(req)->ts_off = 0;
 
 	tcp_clear_options(&tmp_opt);
 	tmp_opt.mss_clamp = af_ops->mss_clamp;
@@ -6269,6 +6270,9 @@ int tcp_conn_request(struct request_sock_ops *rsk_ops,
 	if (security_inet_conn_request(sk, skb, req))
 		goto drop_and_free;
 
+	if (isn && tmp_opt.tstamp_ok) /* retrans? recompute tsoff */
+		af_ops->init_seq(skb, &tcp_rsk(req)->ts_off);
+
 	if (!want_cookie && !isn) {
 		/* VJ's idea. We save last timestamp seen
 		 * from the destination in peer table, when entering
@@ -6309,7 +6313,7 @@ int tcp_conn_request(struct request_sock_ops *rsk_ops,
 			goto drop_and_release;
 		}
 
-		isn = af_ops->init_seq(skb);
+		isn = af_ops->init_seq(skb, &tcp_rsk(req)->ts_off);
 	}
 	if (!dst) {
 		dst = af_ops->route_req(sk, &fl, req, NULL);
@@ -6321,6 +6325,7 @@ int tcp_conn_request(struct request_sock_ops *rsk_ops,
 
 	if (want_cookie) {
 		isn = cookie_init_sequence(af_ops, sk, skb, &req->mss);
+		tcp_rsk(req)->ts_off = 0;
 		req->cookie_ts = tmp_opt.tstamp_ok;
 		if (!tmp_opt.tstamp_ok)
 			inet_rsk(req)->ecn_ok = 0;
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 32b048e..47683c7 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -66,6 +66,7 @@
 #include <net/net_namespace.h>
 #include <net/icmp.h>
 #include <net/inet_hashtables.h>
+#include <net/secure_seq.h>
 #include <net/tcp.h>
 #include <net/transp_v6.h>
 #include <net/ipv6.h>
@@ -96,12 +97,16 @@ static int tcp_v4_md5_hash_hdr(char *md5_hash, const struct tcp_md5sig_key *key,
 struct inet_hashinfo tcp_hashinfo;
 EXPORT_SYMBOL(tcp_hashinfo);
 
-static  __u32 tcp_v4_init_sequence(const struct sk_buff *skb)
+static u32 tcp_v4_init_sequence(const struct sk_buff *skb, u32 *tsoff)
 {
-	return secure_tcp_sequence_number(ip_hdr(skb)->daddr,
-					  ip_hdr(skb)->saddr,
-					  tcp_hdr(skb)->dest,
-					  tcp_hdr(skb)->source);
+	struct secure_tcp_seq s;
+
+	s = secure_tcp_sequence_number(ip_hdr(skb)->daddr,
+				       ip_hdr(skb)->saddr,
+				       tcp_hdr(skb)->dest,
+				       tcp_hdr(skb)->source);
+	*tsoff = s.tsoff;
+	return s.seq;
 }
 
 int tcp_twsk_unique(struct sock *sk, struct sock *sktw, void *twp)
@@ -234,11 +239,16 @@ int tcp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 	sk->sk_gso_type = SKB_GSO_TCPV4;
 	sk_setup_caps(sk, &rt->dst);
 
-	if (!tp->write_seq && likely(!tp->repair))
-		tp->write_seq = secure_tcp_sequence_number(inet->inet_saddr,
-							   inet->inet_daddr,
-							   inet->inet_sport,
-							   usin->sin_port);
+	if (!tp->write_seq && likely(!tp->repair)) {
+		struct secure_tcp_seq seq;
+
+		seq = secure_tcp_sequence_number(inet->inet_saddr,
+						 inet->inet_daddr,
+						 inet->inet_sport,
+						 usin->sin_port);
+		tp->write_seq = seq.seq;
+		tp->tsoffset = seq.tsoff;
+	}
 
 	inet->inet_id = tp->write_seq ^ jiffies;
 
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 4b95ec4..b43ca7e 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -530,7 +530,7 @@ struct sock *tcp_create_openreq_child(const struct sock *sk,
 			newtp->rx_opt.ts_recent_stamp = 0;
 			newtp->tcp_header_len = sizeof(struct tcphdr);
 		}
-		newtp->tsoffset = 0;
+		newtp->tsoffset = treq->ts_off;
 #ifdef CONFIG_TCP_MD5SIG
 		newtp->md5sig_info = NULL;	/*XXX*/
 		if (newtp->af_specific->md5_lookup(sk, newsk))
@@ -579,6 +579,8 @@ struct sock *tcp_check_req(struct sock *sk, struct sk_buff *skb,
 
 		if (tmp_opt.saw_tstamp) {
 			tmp_opt.ts_recent = req->ts_recent;
+			if (tmp_opt.rcv_tsecr)
+				tmp_opt.rcv_tsecr -= tcp_rsk(req)->ts_off;
 			/* We do not store true stamp, but it is not required,
 			 * it can be estimated (approximately)
 			 * from another data.
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index bdaef7f..e0e478e 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -640,7 +640,7 @@ static unsigned int tcp_synack_options(struct request_sock *req,
 	}
 	if (likely(ireq->tstamp_ok)) {
 		opts->options |= OPTION_TS;
-		opts->tsval = tcp_skb_timestamp(skb);
+		opts->tsval = tcp_skb_timestamp(skb) + tcp_rsk(req)->ts_off;
 		opts->tsecr = req->ts_recent;
 		remaining -= TCPOLEN_TSTAMP_ALIGNED;
 	}
diff --git a/net/ipv6/syncookies.c b/net/ipv6/syncookies.c
index 59c4839..241d40e 100644
--- a/net/ipv6/syncookies.c
+++ b/net/ipv6/syncookies.c
@@ -209,6 +209,7 @@ struct sock *cookie_v6_check(struct sock *sk, struct sk_buff *skb)
 	treq->snt_synack.v64	= 0;
 	treq->rcv_isn = ntohl(th->seq) - 1;
 	treq->snt_isn = cookie;
+	treq->ts_off = 0;
 
 	/*
 	 * We need to lookup the dst_entry to get the correct window size.
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 33df8b8..5cf7aa9 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -101,12 +101,16 @@ static void inet6_sk_rx_dst_set(struct sock *sk, const struct sk_buff *skb)
 	}
 }
 
-static __u32 tcp_v6_init_sequence(const struct sk_buff *skb)
+static u32 tcp_v6_init_sequence(const struct sk_buff *skb, u32 *tsoff)
 {
-	return secure_tcpv6_sequence_number(ipv6_hdr(skb)->daddr.s6_addr32,
-					    ipv6_hdr(skb)->saddr.s6_addr32,
-					    tcp_hdr(skb)->dest,
-					    tcp_hdr(skb)->source);
+	struct secure_tcp_seq s;
+
+	s = secure_tcpv6_sequence_number(ipv6_hdr(skb)->daddr.s6_addr32,
+					 ipv6_hdr(skb)->saddr.s6_addr32,
+					 tcp_hdr(skb)->dest,
+					 tcp_hdr(skb)->source);
+	*tsoff = s.tsoff;
+	return s.seq;
 }
 
 static int tcp_v6_connect(struct sock *sk, struct sockaddr *uaddr,
@@ -278,12 +282,16 @@ static int tcp_v6_connect(struct sock *sk, struct sockaddr *uaddr,
 
 	sk_set_txhash(sk);
 
-	if (!tp->write_seq && likely(!tp->repair))
-		tp->write_seq = secure_tcpv6_sequence_number(np->saddr.s6_addr32,
-							     sk->sk_v6_daddr.s6_addr32,
-							     inet->inet_sport,
-							     inet->inet_dport);
+	if (!tp->write_seq && likely(!tp->repair)) {
+		struct secure_tcp_seq seq;
 
+		seq = secure_tcpv6_sequence_number(np->saddr.s6_addr32,
+						   sk->sk_v6_daddr.s6_addr32,
+						   inet->inet_sport,
+						   inet->inet_dport);
+		tp->write_seq = seq.seq;
+		tp->tsoffset = seq.tsoff;
+	}
 	err = tcp_connect(sk);
 	if (err)
 		goto late_failure;
-- 
2.7.3
