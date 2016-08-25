From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC 1/3] tcp: randomize tcp timestamp offsets for each
 connection
Date: Thu, 25 Aug 2016 15:06:11 -0700
Message-ID: <1472162771.14381.167.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1471524527-10029-1-git-send-email-fw@strlen.de>
         <1471524527-10029-2-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:35883 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751521AbcHYWGp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 25 Aug 2016 18:06:45 -0400
Received: by mail-pf0-f196.google.com with SMTP id y134so3831663pfg.3
        for <netdev@vger.kernel.org>; Thu, 25 Aug 2016 15:06:35 -0700 (PDT)
In-Reply-To: <1471524527-10029-2-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-08-18 at 14:48 +0200, Florian Westphal wrote:
> commit ceaa1fef65a7c2e ("tcp: adding a per-socket timestamp offset")
> added the main infrastructure that is needed for per-connection
> randomization, in particular writing/reading the on-wire tcp header
> format takes the offset into account so rest of stack can use normal
> tcp_time_stamp (jiffies).

...

> +struct secure_tcp_seq {
> +	u32 seq;
> +	u32 tsoff;
> +};
> +

...

>  #if IS_ENABLED(CONFIG_IPV6)
> -__u32 secure_tcpv6_sequence_number(const __be32 *saddr, const __be32 *daddr,
> -				   __be16 sport, __be16 dport)
> +struct secure_tcp_seq
> +secure_tcpv6_sequence_number(const __be32 *saddr, const __be32 *daddr,
> +			     __be16 sport, __be16 dport)
>  {
>  	u32 secret[MD5_MESSAGE_BYTES / 4];
>  	u32 hash[MD5_DIGEST_WORDS];
> +	struct secure_tcp_seq seq;
>  	u32 i;
>  
>  	net_secret_init();
> @@ -58,7 +60,9 @@ __u32 secure_tcpv6_sequence_number(const __be32 *saddr, const __be32 *daddr,
>  
>  	md5_transform(hash, secret);
>  
> -	return seq_scale(hash[0]);
> +	seq.seq = seq_scale(hash[0]);
> +	seq.tsoff = hash[1];
> +	return seq;
>  }


I am not a super fan of this "struct secure_tcp_seq" being returned by
functions. This adds unnecessary overhead.

I would instead add a "u32 *ts_off" parameter, as you already did for
tcp_v4_init_sequence()

Patch on top of yours :

 include/net/secure_seq.h |   13 ++++---------
 net/core/secure_seq.c    |   21 ++++++++-------------
 net/ipv4/tcp_ipv4.c      |   30 +++++++++++-------------------
 net/ipv6/tcp_ipv6.c      |   31 ++++++++++++-------------------
 4 files changed, 35 insertions(+), 60 deletions(-)

diff --git a/include/net/secure_seq.h b/include/net/secure_seq.h
index 3d576f74169c..5f1cd2cb7d5d 100644
--- a/include/net/secure_seq.h
+++ b/include/net/secure_seq.h
@@ -3,18 +3,13 @@
 
 #include <linux/types.h>
 
-struct secure_tcp_seq {
-	u32 seq;
-	u32 tsoff;
-};
-
 u32 secure_ipv4_port_ephemeral(__be32 saddr, __be32 daddr, __be16 dport);
 u32 secure_ipv6_port_ephemeral(const __be32 *saddr, const __be32 *daddr,
 			       __be16 dport);
-struct secure_tcp_seq secure_tcp_sequence_number(__be32 saddr, __be32 daddr,
-						 __be16 sport, __be16 dport);
-struct secure_tcp_seq secure_tcpv6_sequence_number(const __be32 *saddr, const __be32 *daddr,
-						    __be16 sport, __be16 dport);
+u32 secure_tcp_sequence_number(__be32 saddr, __be32 daddr,
+			       __be16 sport, __be16 dport, u32 *tsoff);
+u32 secure_tcpv6_sequence_number(const __be32 *saddr, const __be32 *daddr,
+			         __be16 sport, __be16 dport, u32 *tsoff);
 u64 secure_dccp_sequence_number(__be32 saddr, __be32 daddr,
 				__be16 sport, __be16 dport);
 u64 secure_dccpv6_sequence_number(__be32 *saddr, __be32 *daddr,
diff --git a/net/core/secure_seq.c b/net/core/secure_seq.c
index 613f2fd406d4..a8d6062cbb4a 100644
--- a/net/core/secure_seq.c
+++ b/net/core/secure_seq.c
@@ -40,13 +40,11 @@ static u32 seq_scale(u32 seq)
 #endif
 
 #if IS_ENABLED(CONFIG_IPV6)
-struct secure_tcp_seq
-secure_tcpv6_sequence_number(const __be32 *saddr, const __be32 *daddr,
-			     __be16 sport, __be16 dport)
+u32 secure_tcpv6_sequence_number(const __be32 *saddr, const __be32 *daddr,
+				 __be16 sport, __be16 dport, u32 *tsoff)
 {
 	u32 secret[MD5_MESSAGE_BYTES / 4];
 	u32 hash[MD5_DIGEST_WORDS];
-	struct secure_tcp_seq seq;
 	u32 i;
 
 	net_secret_init();
@@ -60,9 +58,8 @@ secure_tcpv6_sequence_number(const __be32 *saddr, const __be32 *daddr,
 
 	md5_transform(hash, secret);
 
-	seq.seq = seq_scale(hash[0]);
-	seq.tsoff = hash[1];
-	return seq;
+	*tsoff = hash[1];
+	return seq_scale(hash[0]);
 }
 EXPORT_SYMBOL(secure_tcpv6_sequence_number);
 
@@ -90,11 +87,10 @@ EXPORT_SYMBOL(secure_ipv6_port_ephemeral);
 
 #ifdef CONFIG_INET
 
-struct secure_tcp_seq secure_tcp_sequence_number(__be32 saddr, __be32 daddr,
-						 __be16 sport, __be16 dport)
+u32 secure_tcp_sequence_number(__be32 saddr, __be32 daddr,
+			       __be16 sport, __be16 dport, u32 *tsoff)
 {
 	u32 hash[MD5_DIGEST_WORDS];
-	struct secure_tcp_seq seq;
 
 	net_secret_init();
 	hash[0] = (__force u32)saddr;
@@ -104,9 +100,8 @@ struct secure_tcp_seq secure_tcp_sequence_number(__be32 saddr, __be32 daddr,
 
 	md5_transform(hash, net_secret);
 
-	seq.seq = seq_scale(hash[0]);
-	seq.tsoff = hash[1];
-	return seq;
+	*tsoff = hash[1];
+	return seq_scale(hash[0]);
 }
 
 u32 secure_ipv4_port_ephemeral(__be32 saddr, __be32 daddr, __be16 dport)
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 47683c798f57..ebfdbb0e1698 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -99,14 +99,10 @@ EXPORT_SYMBOL(tcp_hashinfo);
 
 static u32 tcp_v4_init_sequence(const struct sk_buff *skb, u32 *tsoff)
 {
-	struct secure_tcp_seq s;
-
-	s = secure_tcp_sequence_number(ip_hdr(skb)->daddr,
-				       ip_hdr(skb)->saddr,
-				       tcp_hdr(skb)->dest,
-				       tcp_hdr(skb)->source);
-	*tsoff = s.tsoff;
-	return s.seq;
+	return secure_tcp_sequence_number(ip_hdr(skb)->daddr,
+					  ip_hdr(skb)->saddr,
+					  tcp_hdr(skb)->dest,
+					  tcp_hdr(skb)->source, tsoff);
 }
 
 int tcp_twsk_unique(struct sock *sk, struct sock *sktw, void *twp)
@@ -239,16 +235,12 @@ int tcp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 	sk->sk_gso_type = SKB_GSO_TCPV4;
 	sk_setup_caps(sk, &rt->dst);
 
-	if (!tp->write_seq && likely(!tp->repair)) {
-		struct secure_tcp_seq seq;
-
-		seq = secure_tcp_sequence_number(inet->inet_saddr,
-						 inet->inet_daddr,
-						 inet->inet_sport,
-						 usin->sin_port);
-		tp->write_seq = seq.seq;
-		tp->tsoffset = seq.tsoff;
-	}
+	if (!tp->write_seq && likely(!tp->repair))
+		tp->write_seq = secure_tcp_sequence_number(inet->inet_saddr,
+					inet->inet_daddr,
+					inet->inet_sport,
+					usin->sin_port,
+					&tp->tsoffset);
 
 	inet->inet_id = tp->write_seq ^ jiffies;
 
@@ -826,7 +818,7 @@ static void tcp_v4_reqsk_send_ack(const struct sock *sk, struct sk_buff *skb,
 
 	tcp_v4_send_ack(sock_net(sk), skb, seq,
 			tcp_rsk(req)->rcv_nxt, req->rsk_rcv_wnd,
-			tcp_time_stamp,
+			tcp_time_stamp + tcp_rsk(req)->ts_off,
 			req->ts_recent,
 			0,
 			tcp_md5_do_lookup(sk, (union tcp_md5_addr *)&ip_hdr(skb)->daddr,
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index ce029c090f94..3b4033ad87a0 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -103,14 +103,10 @@ static void inet6_sk_rx_dst_set(struct sock *sk, const struct sk_buff *skb)
 
 static u32 tcp_v6_init_sequence(const struct sk_buff *skb, u32 *tsoff)
 {
-	struct secure_tcp_seq s;
-
-	s = secure_tcpv6_sequence_number(ipv6_hdr(skb)->daddr.s6_addr32,
-					 ipv6_hdr(skb)->saddr.s6_addr32,
-					 tcp_hdr(skb)->dest,
-					 tcp_hdr(skb)->source);
-	*tsoff = s.tsoff;
-	return s.seq;
+	return secure_tcpv6_sequence_number(ipv6_hdr(skb)->daddr.s6_addr32,
+					    ipv6_hdr(skb)->saddr.s6_addr32,
+					    tcp_hdr(skb)->dest,
+					    tcp_hdr(skb)->source, tsoff);
 }
 
 static int tcp_v6_connect(struct sock *sk, struct sockaddr *uaddr,
@@ -282,16 +278,12 @@ static int tcp_v6_connect(struct sock *sk, struct sockaddr *uaddr,
 
 	sk_set_txhash(sk);
 
-	if (!tp->write_seq && likely(!tp->repair)) {
-		struct secure_tcp_seq seq;
-
-		seq = secure_tcpv6_sequence_number(np->saddr.s6_addr32,
-						   sk->sk_v6_daddr.s6_addr32,
-						   inet->inet_sport,
-						   inet->inet_dport);
-		tp->write_seq = seq.seq;
-		tp->tsoffset = seq.tsoff;
-	}
+	if (!tp->write_seq && likely(!tp->repair))
+		tp->write_seq = secure_tcpv6_sequence_number(np->saddr.s6_addr32,
+							    sk->sk_v6_daddr.s6_addr32,
+							    inet->inet_sport,
+							    inet->inet_dport,
+							    &tp->tsoffset);
 	err = tcp_connect(sk);
 	if (err)
 		goto late_failure;
@@ -955,7 +947,8 @@ static void tcp_v6_reqsk_send_ack(const struct sock *sk, struct sk_buff *skb,
 	tcp_v6_send_ack(sk, skb, (sk->sk_state == TCP_LISTEN) ?
 			tcp_rsk(req)->snt_isn + 1 : tcp_sk(sk)->snd_nxt,
 			tcp_rsk(req)->rcv_nxt, req->rsk_rcv_wnd,
-			tcp_time_stamp, req->ts_recent, sk->sk_bound_dev_if,
+			tcp_time_stamp + tcp_rsk(req)->ts_off,
+			req->ts_recent, sk->sk_bound_dev_if,
 			tcp_v6_md5_do_lookup(sk, &ipv6_hdr(skb)->daddr),
 			0, 0);
 }
