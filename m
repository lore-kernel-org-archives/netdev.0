From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: scp stalls mysteriously
Date: Thu, 3 Dec 2009 12:48:02 +0200 (EET)
Message-ID: <alpine.DEB.2.00.0912031235390.7024@wel-95.cs.helsinki.fi>
References: <4B16BD58.3040802@tvk.rwth-aachen.de> <20091203085933.GD30730@sd-11162.dedibox.fr> <alpine.DEB.2.00.0912031121190.7024@wel-95.cs.helsinki.fi> <20091203.023431.215087596.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323329-94020856-1259837282=:7024"
Cc: fredo@starox.org, damian@tvk.rwth-aachen.de,
	Netdev <netdev@vger.kernel.org>, asdo@shiftmail.org,
	eric.dumazet@gmail.com, Herbert Xu <herbert@gondor.apana.org.au>,
	Greg KH <gregkh@suse.de>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:52905 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751053AbZLCKr4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 05:47:56 -0500
In-Reply-To: <20091203.023431.215087596.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323329-94020856-1259837282=:7024
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: 8BIT

On Thu, 3 Dec 2009, David Miller wrote:

> From: "Ilpo Järvinen" <ilpo.jarvinen@helsinki.fi>
> Date: Thu, 3 Dec 2009 12:29:39 +0200 (EET)
> 
> > I've added Greg as CC to make him aware of this issue in early as it now 
> > affects 2.6.32 too (rather important to get dealt quickly in stable once 
> > we have a tested solution since TCP is pretty broken with the silent 
> > deaths this problem seems to cause). ...One possibility would be to just 
> > queue the tested revert to stable and sort this thing out for 2.6.33 in 
> > net-2.6.
> 
> What revert?  Zero context provided here...

...I've CCed this thread to you earlier so I'd have expected such question 
only from Greg (but I know you are busy and read mails in a pseudorandom 
order so I understand :-))... It's the revert for the RTO backoff revert 
thing (its talks about reverting backoff so it's easy to get confused here 
by the terminology :-)). I've included the earlier revert patch in a 
slightly more verbose form below. ...Certainly not in a minimal one form 
with the initial rename patch but I didn't take changes while we did the 
initial testing to find the cause.

-- 
 i.

--
[PATCH] TCP: Revert new RTO backoff stuff

Reverts:

5d7892298a819743b3892df08bb496992fe85951
	RTO connection timeout: sysctl documentation update
5152fc7de3ae31b46692022ea63ce0501280f5b1
	RTO connection timeout: coding style fixes and comments
6fa12c85031485dff38ce550c24f10da23b0adaa
	Revert Backoff [v3]: Calculate TCP's connection close threshold as a time value.
f1ecd5d9e7366609d640ff4040304ea197fbc618
	Revert Backoff [v3]: Revert RTO on ICMP destination unreachable
4d1a2d9ec1c17df077ed09a0d135bccf5637a3b7
	Revert Backoff [v3]: Rename skb to icmp_skb in tcp_v4_err()

---
 Documentation/networking/ip-sysctl.txt |   37 ++++++---------------
 include/net/tcp.h                      |   35 ---------------------
 net/ipv4/tcp_input.c                   |    5 ++-
 net/ipv4/tcp_ipv4.c                    |   53 +++++---------------------------
 net/ipv4/tcp_timer.c                   |   13 +++-----
 5 files changed, 27 insertions(+), 116 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index fbe427a..da07602 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -311,12 +311,9 @@ tcp_no_metrics_save - BOOLEAN
 	connections.
 
 tcp_orphan_retries - INTEGER
-	This value influences the timeout of a locally closed TCP connection,
-	when RTO retransmissions remain unacknowledged.
-	See tcp_retries2 for more details.
-
-	The default value is 7.
-	If your machine is a loaded WEB server,
+	How may times to retry before killing TCP connection, closed
+	by our side. Default value 7 corresponds to ~50sec-16min
+	depending on RTO. If you machine is loaded WEB server,
 	you should think about lowering this value, such sockets
 	may consume significant resources. Cf. tcp_max_orphans.
 
@@ -330,28 +327,16 @@ tcp_retrans_collapse - BOOLEAN
 	certain TCP stacks.
 
 tcp_retries1 - INTEGER
-	This value influences the time, after which TCP decides, that
-	something is wrong due to unacknowledged RTO retransmissions,
-	and reports this suspicion to the network layer.
-	See tcp_retries2 for more details.
-
-	RFC 1122 recommends at least 3 retransmissions, which is the
-	default.
+	How many times to retry before deciding that something is wrong
+	and it is necessary to report this suspicion to network layer.
+	Minimal RFC value is 3, it is default, which corresponds
+	to ~3sec-8min depending on RTO.
 
 tcp_retries2 - INTEGER
-	This value influences the timeout of an alive TCP connection,
-	when RTO retransmissions remain unacknowledged.
-	Given a value of N, a hypothetical TCP connection following
-	exponential backoff with an initial RTO of TCP_RTO_MIN would
-	retransmit N times before killing the connection at the (N+1)th RTO.
-
-	The default value of 15 yields a hypothetical timeout of 924.6
-	seconds and is a lower bound for the effective timeout.
-	TCP will effectively time out at the first RTO which exceeds the
-	hypothetical timeout.
-
-	RFC 1122 recommends at least 100 seconds for the timeout,
-	which corresponds to a value of at least 8.
+	How may times to retry before killing alive TCP connection.
+	RFC1122 says that the limit should be longer than 100 sec.
+	It is too small number.	Default value 15 corresponds to ~13-30min
+	depending on RTO.
 
 tcp_rfc1337 - BOOLEAN
 	If set, the TCP stack behaves conforming to RFC1337. If unset,
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 03a49c7..983367e 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -469,7 +469,6 @@ extern void __tcp_push_pending_frames(struct sock *sk, unsigned int cur_mss,
 				      int nonagle);
 extern int tcp_may_send_now(struct sock *sk);
 extern int tcp_retransmit_skb(struct sock *, struct sk_buff *);
-extern void tcp_retransmit_timer(struct sock *sk);
 extern void tcp_xmit_retransmit_queue(struct sock *);
 extern void tcp_simple_retransmit(struct sock *);
 extern int tcp_trim_head(struct sock *, struct sk_buff *, u32);
@@ -522,17 +521,6 @@ extern int tcp_mtu_to_mss(struct sock *sk, int pmtu);
 extern int tcp_mss_to_mtu(struct sock *sk, int mss);
 extern void tcp_mtup_init(struct sock *sk);
 
-static inline void tcp_bound_rto(const struct sock *sk)
-{
-	if (inet_csk(sk)->icsk_rto > TCP_RTO_MAX)
-		inet_csk(sk)->icsk_rto = TCP_RTO_MAX;
-}
-
-static inline u32 __tcp_set_rto(const struct tcp_sock *tp)
-{
-	return (tp->srtt >> 3) + tp->rttvar;
-}
-
 static inline void __tcp_fast_path_on(struct tcp_sock *tp, u32 snd_wnd)
 {
 	tp->pred_flags = htonl((tp->tcp_header_len << 26) |
@@ -1259,29 +1247,6 @@ static inline struct sk_buff *tcp_write_queue_prev(struct sock *sk, struct sk_bu
 #define tcp_for_write_queue_from_safe(skb, tmp, sk)			\
 	skb_queue_walk_from_safe(&(sk)->sk_write_queue, skb, tmp)
 
-/* This function calculates a "timeout" which is equivalent to the timeout of a
- * TCP connection after "boundary" unsucessful, exponentially backed-off
- * retransmissions with an initial RTO of TCP_RTO_MIN.
- */
-static inline bool retransmits_timed_out(const struct sock *sk,
-					 unsigned int boundary)
-{
-	unsigned int timeout, linear_backoff_thresh;
-
-	if (!inet_csk(sk)->icsk_retransmits)
-		return false;
-
-	linear_backoff_thresh = ilog2(TCP_RTO_MAX/TCP_RTO_MIN);
-
-	if (boundary <= linear_backoff_thresh)
-		timeout = ((2 << boundary) - 1) * TCP_RTO_MIN;
-	else
-		timeout = ((2 << linear_backoff_thresh) - 1) * TCP_RTO_MIN +
-			  (boundary - linear_backoff_thresh) * TCP_RTO_MAX;
-
-	return (tcp_time_stamp - tcp_sk(sk)->retrans_stamp) >= timeout;
-}
-
 static inline struct sk_buff *tcp_send_head(struct sock *sk)
 {
 	return sk->sk_send_head;
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index d86784b..6322e62 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -685,7 +685,7 @@ static inline void tcp_set_rto(struct sock *sk)
 	 *    is invisible. Actually, Linux-2.4 also generates erratic
 	 *    ACKs in some circumstances.
 	 */
-	inet_csk(sk)->icsk_rto = __tcp_set_rto(tp);
+	inet_csk(sk)->icsk_rto = (tp->srtt >> 3) + tp->rttvar;
 
 	/* 2. Fixups made earlier cannot be right.
 	 *    If we do not estimate RTO correctly without them,
@@ -696,7 +696,8 @@ static inline void tcp_set_rto(struct sock *sk)
 	/* NOTE: clamping at TCP_RTO_MIN is not required, current algo
 	 * guarantees that rto is higher.
 	 */
-	tcp_bound_rto(sk);
+	if (inet_csk(sk)->icsk_rto > TCP_RTO_MAX)
+		inet_csk(sk)->icsk_rto = TCP_RTO_MAX;
 }
 
 /* Save metrics learned by this TCP session.
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 7cda24b..702ce88 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -328,29 +328,26 @@ static void do_pmtu_discovery(struct sock *sk, struct iphdr *iph, u32 mtu)
  *
  */
 
-void tcp_v4_err(struct sk_buff *icmp_skb, u32 info)
+void tcp_v4_err(struct sk_buff *skb, u32 info)
 {
-	struct iphdr *iph = (struct iphdr *)icmp_skb->data;
-	struct tcphdr *th = (struct tcphdr *)(icmp_skb->data + (iph->ihl << 2));
-	struct inet_connection_sock *icsk;
+	struct iphdr *iph = (struct iphdr *)skb->data;
+	struct tcphdr *th = (struct tcphdr *)(skb->data + (iph->ihl << 2));
 	struct tcp_sock *tp;
 	struct inet_sock *inet;
-	const int type = icmp_hdr(icmp_skb)->type;
-	const int code = icmp_hdr(icmp_skb)->code;
+	const int type = icmp_hdr(skb)->type;
+	const int code = icmp_hdr(skb)->code;
 	struct sock *sk;
-	struct sk_buff *skb;
 	__u32 seq;
-	__u32 remaining;
 	int err;
-	struct net *net = dev_net(icmp_skb->dev);
+	struct net *net = dev_net(skb->dev);
 
-	if (icmp_skb->len < (iph->ihl << 2) + 8) {
+	if (skb->len < (iph->ihl << 2) + 8) {
 		ICMP_INC_STATS_BH(net, ICMP_MIB_INERRORS);
 		return;
 	}
 
 	sk = inet_lookup(net, &tcp_hashinfo, iph->daddr, th->dest,
-			iph->saddr, th->source, inet_iif(icmp_skb));
+			iph->saddr, th->source, inet_iif(skb));
 	if (!sk) {
 		ICMP_INC_STATS_BH(net, ICMP_MIB_INERRORS);
 		return;
@@ -370,7 +367,6 @@ void tcp_v4_err(struct sk_buff *icmp_skb, u32 info)
 	if (sk->sk_state == TCP_CLOSE)
 		goto out;
 
-	icsk = inet_csk(sk);
 	tp = tcp_sk(sk);
 	seq = ntohl(th->seq);
 	if (sk->sk_state != TCP_LISTEN &&
@@ -397,39 +393,6 @@ void tcp_v4_err(struct sk_buff *icmp_skb, u32 info)
 		}
 
 		err = icmp_err_convert[code].errno;
-		/* check if icmp_skb allows revert of backoff
-		 * (see draft-zimmermann-tcp-lcd) */
-		if (code != ICMP_NET_UNREACH && code != ICMP_HOST_UNREACH)
-			break;
-		if (seq != tp->snd_una  || !icsk->icsk_retransmits ||
-		    !icsk->icsk_backoff)
-			break;
-
-		icsk->icsk_backoff--;
-		inet_csk(sk)->icsk_rto = __tcp_set_rto(tp) <<
-					 icsk->icsk_backoff;
-		tcp_bound_rto(sk);
-
-		skb = tcp_write_queue_head(sk);
-		BUG_ON(!skb);
-
-		remaining = icsk->icsk_rto - min(icsk->icsk_rto,
-				tcp_time_stamp - TCP_SKB_CB(skb)->when);
-
-		if (remaining) {
-			inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS,
-						  remaining, TCP_RTO_MAX);
-		} else if (sock_owned_by_user(sk)) {
-			/* RTO revert clocked out retransmission,
-			 * but socket is locked. Will defer. */
-			inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS,
-						  HZ/20, TCP_RTO_MAX);
-		} else {
-			/* RTO revert clocked out retransmission.
-			 * Will retransmit now */
-			tcp_retransmit_timer(sk);
-		}
-
 		break;
 	case ICMP_TIME_EXCEEDED:
 		err = EHOSTUNREACH;
diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
index cdb2ca7..c520fb6 100644
--- a/net/ipv4/tcp_timer.c
+++ b/net/ipv4/tcp_timer.c
@@ -137,14 +137,13 @@ static int tcp_write_timeout(struct sock *sk)
 {
 	struct inet_connection_sock *icsk = inet_csk(sk);
 	int retry_until;
-	bool do_reset;
 
 	if ((1 << sk->sk_state) & (TCPF_SYN_SENT | TCPF_SYN_RECV)) {
 		if (icsk->icsk_retransmits)
 			dst_negative_advice(&sk->sk_dst_cache);
 		retry_until = icsk->icsk_syn_retries ? : sysctl_tcp_syn_retries;
 	} else {
-		if (retransmits_timed_out(sk, sysctl_tcp_retries1)) {
+		if (icsk->icsk_retransmits >= sysctl_tcp_retries1) {
 			/* Black hole detection */
 			tcp_mtu_probing(icsk, sk);
 
@@ -156,15 +155,13 @@ static int tcp_write_timeout(struct sock *sk)
 			const int alive = (icsk->icsk_rto < TCP_RTO_MAX);
 
 			retry_until = tcp_orphan_retries(sk, alive);
-			do_reset = alive ||
-				   !retransmits_timed_out(sk, retry_until);
 
-			if (tcp_out_of_resources(sk, do_reset))
+			if (tcp_out_of_resources(sk, alive || icsk->icsk_retransmits < retry_until))
 				return 1;
 		}
 	}
 
-	if (retransmits_timed_out(sk, retry_until)) {
+	if (icsk->icsk_retransmits >= retry_until) {
 		/* Has it gone just too far? */
 		tcp_write_err(sk);
 		return 1;
@@ -282,7 +279,7 @@ static void tcp_probe_timer(struct sock *sk)
  *	The TCP retransmit timer.
  */
 
-void tcp_retransmit_timer(struct sock *sk)
+static void tcp_retransmit_timer(struct sock *sk)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct inet_connection_sock *icsk = inet_csk(sk);
@@ -388,7 +385,7 @@ void tcp_retransmit_timer(struct sock *sk)
 out_reset_timer:
 	icsk->icsk_rto = min(icsk->icsk_rto << 1, TCP_RTO_MAX);
 	inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS, icsk->icsk_rto, TCP_RTO_MAX);
-	if (retransmits_timed_out(sk, sysctl_tcp_retries1 + 1))
+	if (icsk->icsk_retransmits > sysctl_tcp_retries1)
 		__sk_dst_reset(sk);
 
 out:;
-- 
1.5.6.3

--8323329-94020856-1259837282=:7024--
