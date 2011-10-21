From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] ipv4: tcp: fix TOS value in ACK messages sent from
 TIME_WAIT
Date: Fri, 21 Oct 2011 12:29:25 +0200
Message-ID: <1319192965.2338.25.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <20111010145206.6f7e9ee2@nehalam.linuxnetplumber.net>
	 <1318382887-31824-1-git-send-email-muralira@google.com>
	 <1318387734.3686.2.camel@edumazet-laptop>
	 <CAP3iWTQXHwzw-qUYVfT--uNv4pNZnu0ROJnF7B1VLeZBbrfdqw@mail.gmail.com>
	 <1318393869.3686.26.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, MuraliRaja Muniraju <muralira@google.com>,
	Andi Kleen <ak@linux.intel.com>,
	KOVACS Krisztian <hidden@balabit.hu>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:39879 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753664Ab1JUK33 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Oct 2011 06:29:29 -0400
Received: by wyg36 with SMTP id 36so3808271wyg.19
        for <netdev@vger.kernel.org>; Fri, 21 Oct 2011 03:29:28 -0700 (PDT)
In-Reply-To: <1318393869.3686.26.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is a long standing bug in linux tcp stack, about ACK messages sent
on behalf of TIME_WAIT sockets.

In the IP header of the ACK message, we choose to reflect TOS field of
incoming message, and this might break some setups.

Example of things that were broken :
  - Routing using TOS as a selector
  - Firewalls
  - Trafic classification / shaping

We now remember in timewait structure the inet tos field and use it in
ACK generation, and route lookup.

Notes :
 - We still reflect incoming TOS in RST messages.
 - We could extend MuraliRaja Muniraju patch to report TOS value in
netlink messages for TIME_WAIT sockets.
 - A patch is needed for IPv6

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: MuraliRaja Muniraju <muralira@google.com>
CC: Andi Kleen <ak@linux.intel.com>
CC: KOVACS Krisztian <hidden@balabit.hu>
---
 include/net/inet_timewait_sock.h |    3 ++-
 include/net/ip.h                 |    3 ++-
 net/ipv4/inet_timewait_sock.c    |    1 +
 net/ipv4/ip_output.c             |    6 +++---
 net/ipv4/tcp_ipv4.c              |   11 +++++++----
 5 files changed, 15 insertions(+), 9 deletions(-)

diff --git a/include/net/inet_timewait_sock.h b/include/net/inet_timewait_sock.h
index f1a7709..180231c 100644
--- a/include/net/inet_timewait_sock.h
+++ b/include/net/inet_timewait_sock.h
@@ -126,7 +126,8 @@ struct inet_timewait_sock {
 	/* And these are ours. */
 	unsigned int		tw_ipv6only     : 1,
 				tw_transparent  : 1,
-				tw_pad		: 14,	/* 14 bits hole */
+				tw_pad		: 6,	/* 6 bits hole */
+				tw_tos		: 8,
 				tw_ipv6_offset  : 16;
 	kmemcheck_bitfield_end(flags);
 	unsigned long		tw_ttd;
diff --git a/include/net/ip.h b/include/net/ip.h
index c7e066a..eca0ef7 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -165,6 +165,7 @@ struct ip_reply_arg {
 	int	    csumoffset; /* u16 offset of csum in iov[0].iov_base */
 				/* -1 if not needed */ 
 	int	    bound_dev_if;
+	u8  	    tos;
 }; 
 
 #define IP_REPLY_ARG_NOSRCCHECK 1
@@ -175,7 +176,7 @@ static inline __u8 ip_reply_arg_flowi_flags(const struct ip_reply_arg *arg)
 }
 
 void ip_send_reply(struct sock *sk, struct sk_buff *skb, __be32 daddr,
-		   struct ip_reply_arg *arg, unsigned int len);
+		   const struct ip_reply_arg *arg, unsigned int len);
 
 struct ipv4_config {
 	int	log_martians;
diff --git a/net/ipv4/inet_timewait_sock.c b/net/ipv4/inet_timewait_sock.c
index 3c8dfa1..44d65d5 100644
--- a/net/ipv4/inet_timewait_sock.c
+++ b/net/ipv4/inet_timewait_sock.c
@@ -183,6 +183,7 @@ struct inet_timewait_sock *inet_twsk_alloc(const struct sock *sk, const int stat
 		tw->tw_daddr	    = inet->inet_daddr;
 		tw->tw_rcv_saddr    = inet->inet_rcv_saddr;
 		tw->tw_bound_dev_if = sk->sk_bound_dev_if;
+		tw->tw_tos	    = inet->tos;
 		tw->tw_num	    = inet->inet_num;
 		tw->tw_state	    = TCP_TIME_WAIT;
 		tw->tw_substate	    = state;
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index e1374ab..0bc95f3 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -1466,7 +1466,7 @@ static int ip_reply_glue_bits(void *dptr, char *to, int offset,
  *     	structure to pass arguments.
  */
 void ip_send_reply(struct sock *sk, struct sk_buff *skb, __be32 daddr,
-		   struct ip_reply_arg *arg, unsigned int len)
+		   const struct ip_reply_arg *arg, unsigned int len)
 {
 	struct inet_sock *inet = inet_sk(sk);
 	struct ip_options_data replyopts;
@@ -1489,7 +1489,7 @@ void ip_send_reply(struct sock *sk, struct sk_buff *skb, __be32 daddr,
 	}
 
 	flowi4_init_output(&fl4, arg->bound_dev_if, 0,
-			   RT_TOS(ip_hdr(skb)->tos),
+			   RT_TOS(arg->tos),
 			   RT_SCOPE_UNIVERSE, sk->sk_protocol,
 			   ip_reply_arg_flowi_flags(arg),
 			   daddr, rt->rt_spec_dst,
@@ -1506,7 +1506,7 @@ void ip_send_reply(struct sock *sk, struct sk_buff *skb, __be32 daddr,
 	   with locally disabled BH and that sk cannot be already spinlocked.
 	 */
 	bh_lock_sock(sk);
-	inet->tos = ip_hdr(skb)->tos;
+	inet->tos = arg->tos;
 	sk->sk_priority = skb->priority;
 	sk->sk_protocol = ip_hdr(skb)->protocol;
 	sk->sk_bound_dev_if = arg->bound_dev_if;
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 955c925..16687b3 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -652,6 +652,7 @@ static void tcp_v4_send_reset(struct sock *sk, struct sk_buff *skb)
 	arg.flags = (sk && inet_sk(sk)->transparent) ? IP_REPLY_ARG_NOSRCCHECK : 0;
 
 	net = dev_net(skb_dst(skb)->dev);
+	arg.tos = ip_hdr(skb)->tos;
 	ip_send_reply(net->ipv4.tcp_sock, skb, ip_hdr(skb)->saddr,
 		      &arg, arg.iov[0].iov_len);
 
@@ -666,7 +667,7 @@ static void tcp_v4_send_reset(struct sock *sk, struct sk_buff *skb)
 static void tcp_v4_send_ack(struct sk_buff *skb, u32 seq, u32 ack,
 			    u32 win, u32 ts, int oif,
 			    struct tcp_md5sig_key *key,
-			    int reply_flags)
+			    int reply_flags, u8 tos)
 {
 	const struct tcphdr *th = tcp_hdr(skb);
 	struct {
@@ -726,7 +727,7 @@ static void tcp_v4_send_ack(struct sk_buff *skb, u32 seq, u32 ack,
 	arg.csumoffset = offsetof(struct tcphdr, check) / 2;
 	if (oif)
 		arg.bound_dev_if = oif;
-
+	arg.tos = tos;
 	ip_send_reply(net->ipv4.tcp_sock, skb, ip_hdr(skb)->saddr,
 		      &arg, arg.iov[0].iov_len);
 
@@ -743,7 +744,8 @@ static void tcp_v4_timewait_ack(struct sock *sk, struct sk_buff *skb)
 			tcptw->tw_ts_recent,
 			tw->tw_bound_dev_if,
 			tcp_twsk_md5_key(tcptw),
-			tw->tw_transparent ? IP_REPLY_ARG_NOSRCCHECK : 0
+			tw->tw_transparent ? IP_REPLY_ARG_NOSRCCHECK : 0,
+			tw->tw_tos
 			);
 
 	inet_twsk_put(tw);
@@ -757,7 +759,8 @@ static void tcp_v4_reqsk_send_ack(struct sock *sk, struct sk_buff *skb,
 			req->ts_recent,
 			0,
 			tcp_v4_md5_do_lookup(sk, ip_hdr(skb)->daddr),
-			inet_rsk(req)->no_srccheck ? IP_REPLY_ARG_NOSRCCHECK : 0);
+			inet_rsk(req)->no_srccheck ? IP_REPLY_ARG_NOSRCCHECK : 0,
+			ip_hdr(skb)->tos);
 }
 
 /*
