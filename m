From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: scp stalls mysteriously
Date: Wed, 2 Dec 2009 18:05:24 +0200 (EET)
Message-ID: <alpine.DEB.2.00.0912021745200.7024@wel-95.cs.helsinki.fi>
References: <20091128010156.1219012a@houba> <alpine.DEB.2.00.0911281257270.25587@melkinpaasi.cs.helsinki.fi> <20091130195004.38dbc319@houba> <alpine.DEB.2.00.0911302113390.9826@melkinpaasi.cs.helsinki.fi> <20091130213727.2f4047d2@houba>
 <alpine.DEB.2.00.0911302244160.9826@melkinpaasi.cs.helsinki.fi> <20091201211945.505d3c98@houba> <alpine.DEB.2.00.0912012220570.1904@melkinpaasi.cs.helsinki.fi> <20091202085925.472136e2@houba> <alpine.DEB.2.00.0912021438030.20416@melkinpaasi.cs.helsinki.fi>
 <20091202154403.GB30730@sd-11162.dedibox.fr>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="8323329-423961241-1259768797=:7024"
Cc: Netdev <netdev@vger.kernel.org>, Asdo <asdo@shiftmail.org>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Damian Lukowski <damian@tvk.rwth-aachen.de>
To: Frederic Leroy <fredo@starox.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:56311 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754363AbZLBQFT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Dec 2009 11:05:19 -0500
In-Reply-To: <20091202154403.GB30730@sd-11162.dedibox.fr>
Content-ID: <alpine.DEB.2.00.0912021746580.7024@wel-95.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323329-423961241-1259768797=:7024
Content-Type: TEXT/PLAIN; charset=ISO-8859-15
Content-Transfer-Encoding: 8BIT
Content-ID: <alpine.DEB.2.00.0912021746581.7024@wel-95.cs.helsinki.fi>

On Wed, 2 Dec 2009, Frederic Leroy wrote:

> On Wed, Dec 02, 2009 at 02:59:20PM +0200, Ilpo Järvinen wrote:
> > On Wed, 2 Dec 2009, Frederic Leroy wrote:
> > 
> > > Le Tue, 1 Dec 2009 22:27:01 +0200 (EET),
> > > "Ilpo Järvinen" <ilpo.jarvinen@helsinki.fi> a écrit :
> > What is directly inferrable from the logs: Losses happen. RTO is triggered 
> > for the first time (for some reason also fast retransmit is missing and it 
> > most likely it should have preceeded RTO), however, the retransmission 
> > that RTO should make is never captured into the tcpdump. Then when RTO 
> > triggers for the second time, the connection silently dies immediately and 
> > consistently for some reason. ...From that point on resets are sent if the 
> > peer keeps trying.
> 
> If you want, I can add printk when a rto is made, in order to compare 
> with tcpdump. 

It's rather conclusive already that the first one did happen
(icsk_retransmit is increased in very few places and your proc/net/tcp 
shows increase of that to 1 every time). What happened on the second one 
is unknown though (icsk_retransmits==1 at that point of time), I suppose 
it takes some path in the RTO code which leads to death of the connection.

> > > > I wonder if you have had some working (past) kernel version?
> > > I tried a 2.6.31, and it seems to work. If it really work (connection
> > > don't stall everytime at the moment), I'll try to make a "git bisect"
> > > asap.
> 
> I can confirm now that 2.6.31 works well.
> 
> I made a little change during the test : 
> Instead of launching scp on sg, I launched it from houba.
> The scp command return then  to bash with an error, without stalling.
> Which appears to me logical because the connection is killed from houba point of view.
>  
> > In one of the cases, also the sg end dies (the 4th case). I suppose that 
> > was running earlier kernel already?
> 
> This case was the one with tcp_frto=2 and tcp_timestamps=0 on houba.

I suppose we're confused, I was refering to .4. case, did you perhaps mix 
that up with the latest set of tests which yields .8.?

> I only rebooted sg two days ago. It still 2.6.32-rc5. Nothing had been 
> changed on this host during all tests. 
> tcp_frto=2
> tcp_timestamps=1

...Ah so it was running the new kernel all the way along, my bad, I 
somehow was able to misread your kernel version numbers in the earlier 
mail :-).

IIRC your kernels Asdo were older than that, right?

In the recent work, the most suspicious things are the new timeout things, 
I'll read them through once I've some time (but so far I've not found 
anything wrong in them but I of course can miss something subtle).  
...I've added Damian as CC if he has some idea. If you want you can try 
with a trivial revert of that stuff, I've included a patch for that below.


-- 
 i.


--
[PATCH] Revert new RTO backoff stuff

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

--8323329-423961241-1259768797=:7024--
