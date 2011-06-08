From: Jerry Chu <hkchu@google.com>
Subject: [PATCH] RFC2988bis + taking RTT sample from 3WHS for the passive open side
Date: Wed, 8 Jun 2011 11:04:22 -0700
Message-ID: <BANLkTimXgK03tM1e3FYe+wausHT15W6H-2eMNCWaj8LLxRvbZw@mail.gmail.com>
References: <1307509203-30973-1-git-send-email-hkchu@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: tsunanet@gmail.com,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Hagen Paul Pfeifer <hagen@jauu.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:45173 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751899Ab1FHSEZ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jun 2011 14:04:25 -0400
Received: from kpbe12.cbf.corp.google.com (kpbe12.cbf.corp.google.com [172.25.105.76])
	by smtp-out.google.com with ESMTP id p58I4Onx032374
	for <netdev@vger.kernel.org>; Wed, 8 Jun 2011 11:04:24 -0700
Received: from yie30 (yie30.prod.google.com [10.243.66.30])
	by kpbe12.cbf.corp.google.com with ESMTP id p58I3gsn032667
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 8 Jun 2011 11:04:22 -0700
Received: by yie30 with SMTP id 30so432758yie.33
        for <netdev@vger.kernel.org>; Wed, 08 Jun 2011 11:04:22 -0700 (PDT)
In-Reply-To: <1307509203-30973-1-git-send-email-hkchu@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[resent to cc netdev]

This patch lowers the default initRTO from 3secs to 1sec per
RFC2988bis. It falls back to 3secs if the SYN or SYN-ACK packet
has been retransmitted, AND the TCP timestamp option is not on.

It also adds support to take RTT sample during 3WHS on the passive
open side, just like its active open counterpart, and uses it, if
valid, to seed the initRTO for the data transmission phase.

The patch also resets ssthresh to its initial default at the
beginning of the data transmission phase, and reduces cwnd to 1 if
there has been MORE THAN ONE retransmission during 3WHS per RFC5681.

Signed-off-by: H.K. Jerry Chu <hkchu@google.com>
---
=A0include/linux/tcp.h =A0 =A0 =A0| =A0 =A01 +
=A0include/net/tcp.h =A0 =A0 =A0 =A0| =A0 11 +++++++++--
=A0net/ipv4/syncookies.c =A0 =A0| =A0 =A01 +
=A0net/ipv4/tcp_input.c =A0 =A0 | =A0 46 +++++++++++++++++++++++++-----=
----------------
=A0net/ipv4/tcp_ipv4.c =A0 =A0 =A0| =A0 11 ++++++++---
=A0net/ipv4/tcp_minisocks.c | =A0 =A06 +++++-
=A0net/ipv6/syncookies.c =A0 =A0| =A0 =A01 +
=A0net/ipv6/tcp_ipv6.c =A0 =A0 =A0| =A0 =A05 +++++
=A08 files changed, 55 insertions(+), 27 deletions(-)

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index e64f4c6..531ede8 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -282,6 +282,7 @@ struct tcp_request_sock {
=A0#endif
=A0 =A0 =A0 =A0u32 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 rcv_isn;
=A0 =A0 =A0 =A0u32 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 snt_isn;
+ =A0 =A0 =A0 u32 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 snt_synack; /* synack sent time */
=A0};

=A0static inline struct tcp_request_sock *tcp_rsk(const struct request_=
sock *req)
diff --git a/include/net/tcp.h b/include/net/tcp.h
index cda30ea..149a415 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -122,7 +122,13 @@ extern void tcp_time_wait(struct sock *sk, int
state, int timeo);
=A0#endif
=A0#define TCP_RTO_MAX =A0 =A0((unsigned)(120*HZ))
=A0#define TCP_RTO_MIN =A0 =A0((unsigned)(HZ/5))
-#define TCP_TIMEOUT_INIT ((unsigned)(3*HZ)) =A0 =A0/* RFC 1122 initial
RTO value =A0 */
+#define TCP_TIMEOUT_INIT ((unsigned)(1*HZ)) =A0 =A0/* RFC2988bis initi=
al
RTO value */
+#define TCP_TIMEOUT_FALLBACK ((unsigned)(3*HZ)) =A0 =A0 =A0 =A0/* RFC =
1122
initial RTO value, now
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0* used as a fallback
RTO for the
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0* initial data
transmission if no
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0* valid RTT sample
has been acquired,
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0* most likely due to
retrans in 3WHS.
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0*/

=A0#define TCP_RESOURCE_PROBE_INTERVAL ((unsigned)(HZ/2U)) /* Maximal
interval between probes
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * for local resources.
@@ -295,7 +301,7 @@ static inline void tcp_synq_overflow(struct sock *s=
k)
=A0static inline int tcp_synq_no_recent_overflow(const struct sock *sk)
=A0{
=A0 =A0 =A0 =A0unsigned long last_overflow =3D tcp_sk(sk)->rx_opt.ts_re=
cent_stamp;
- =A0 =A0 =A0 return time_after(jiffies, last_overflow + TCP_TIMEOUT_IN=
IT);
+ =A0 =A0 =A0 return time_after(jiffies, last_overflow + TCP_TIMEOUT_FA=
LLBACK);
=A0}

=A0extern struct proto tcp_prot;
@@ -508,6 +514,7 @@ extern void tcp_initialize_rcv_mss(struct sock *sk)=
;
=A0extern int tcp_mtu_to_mss(struct sock *sk, int pmtu);
=A0extern int tcp_mss_to_mtu(struct sock *sk, int mss);
=A0extern void tcp_mtup_init(struct sock *sk);
+extern void tcp_valid_rtt_meas(struct sock *sk, u32 seq_rtt);

=A0static inline void tcp_bound_rto(const struct sock *sk)
=A0{
diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
index 2646149..92bb943 100644
--- a/net/ipv4/syncookies.c
+++ b/net/ipv4/syncookies.c
@@ -316,6 +316,7 @@ struct sock *cookie_v4_check(struct sock *sk,
struct sk_buff *skb,
=A0 =A0 =A0 =A0ireq->wscale_ok =A0 =A0 =A0 =A0 =3D tcp_opt.wscale_ok;
=A0 =A0 =A0 =A0ireq->tstamp_ok =A0 =A0 =A0 =A0 =3D tcp_opt.saw_tstamp;
=A0 =A0 =A0 =A0req->ts_recent =A0 =A0 =A0 =A0 =A0=3D tcp_opt.saw_tstamp=
 ? tcp_opt.rcv_tsval : 0;
+ =A0 =A0 =A0 treq->snt_synack =A0 =A0 =A0 =A0=3D tcp_opt.saw_tstamp ? =
tcp_opt.rcv_tsecr : 0;

=A0 =A0 =A0 =A0/* We throwed the options of the initial SYN away, so we=
 hope
=A0 =A0 =A0 =A0 * the ACK carries the same options again (see RFC1122 4=
=2E2.3.8)
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index bef9f04..ea0d218 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -880,6 +880,11 @@ static void tcp_init_metrics(struct sock *sk)
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0tp->snd_ssthresh =3D dst_metric(dst, RTA=
X_SSTHRESH);
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (tp->snd_ssthresh > tp->snd_cwnd_clam=
p)
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0tp->snd_ssthresh =3D tp-=
>snd_cwnd_clamp;
+ =A0 =A0 =A0 } else {
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* ssthresh may have been reduced unneces=
sarily during.
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* 3WHS. Restore it back to its initial=
 default.
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 tp->snd_ssthresh =3D TCP_INFINITE_SSTHRES=
H;
=A0 =A0 =A0 =A0}
=A0 =A0 =A0 =A0if (dst_metric(dst, RTAX_REORDERING) &&
=A0 =A0 =A0 =A0 =A0 =A0tp->reordering !=3D dst_metric(dst, RTAX_REORDER=
ING)) {
@@ -887,10 +892,7 @@ static void tcp_init_metrics(struct sock *sk)
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0tp->reordering =3D dst_metric(dst, RTAX_=
REORDERING);
=A0 =A0 =A0 =A0}

- =A0 =A0 =A0 if (dst_metric(dst, RTAX_RTT) =3D=3D 0)
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto reset;
-
- =A0 =A0 =A0 if (!tp->srtt && dst_metric_rtt(dst, RTAX_RTT) <
(TCP_TIMEOUT_INIT << 3))
+ =A0 =A0 =A0 if (dst_metric(dst, RTAX_RTT) =3D=3D 0 || tp->srtt =3D=3D=
 0)
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto reset;

=A0 =A0 =A0 =A0/* Initial rtt is determined from SYN,SYN-ACK.
@@ -916,19 +918,26 @@ static void tcp_init_metrics(struct sock *sk)
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0tp->mdev_max =3D tp->rttvar =3D max(tp->=
mdev, tcp_rto_min(sk));
=A0 =A0 =A0 =A0}
=A0 =A0 =A0 =A0tcp_set_rto(sk);
- =A0 =A0 =A0 if (inet_csk(sk)->icsk_rto < TCP_TIMEOUT_INIT &&
!tp->rx_opt.saw_tstamp) {
=A0reset:
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Play conservative. If timestamps are n=
ot
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* supported, TCP will fail to recalcul=
ate correct
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* rtt, if initial rto is too small. FO=
RGET ALL AND RESET!
+ =A0 =A0 =A0 if (tp->srtt =3D=3D 0) {
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* RFC2988bis: We've failed to get a vali=
d RTT sample from
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* 3WHS. This is most likely due to ret=
ransmission,
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* including spurious one. Reset the RT=
O back to 3secs
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* from the more aggressive 1sec to avo=
id more spurious
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* retransmission.
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 */
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!tp->rx_opt.saw_tstamp && tp->srtt) {
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 tp->srtt =3D 0;
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 tp->mdev =3D tp->mdev_max=
 =3D tp->rttvar =3D TCP_TIMEOUT_INIT;
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 inet_csk(sk)->icsk_rto =3D=
 TCP_TIMEOUT_INIT;
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 tp->mdev =3D tp->mdev_max =3D tp->rttvar =
=3D TCP_TIMEOUT_FALLBACK;
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 inet_csk(sk)->icsk_rto =3D TCP_TIMEOUT_FA=
LLBACK;
=A0 =A0 =A0 =A0}
- =A0 =A0 =A0 tp->snd_cwnd =3D tcp_init_cwnd(tp, dst);
+ =A0 =A0 =A0 /* Cut cwnd down to 1 per RFC5681 if SYN or SYN-ACK has b=
een
+ =A0 =A0 =A0 =A0* retransmitted. In light of RFC2988bis' more aggressi=
ve 1sec
+ =A0 =A0 =A0 =A0* initRTO, we only reset cwnd when more than 1 SYN/SYN=
-ACK
+ =A0 =A0 =A0 =A0* retransmission has occurred.
+ =A0 =A0 =A0 =A0*/
+ =A0 =A0 =A0 if (tp->total_retrans > 1)
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 tp->snd_cwnd =3D 1;
+ =A0 =A0 =A0 else
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 tp->snd_cwnd =3D tcp_init_cwnd(tp, dst);
=A0 =A0 =A0 =A0tp->snd_cwnd_stamp =3D tcp_time_stamp;
=A0}

@@ -3112,12 +3121,13 @@ static void tcp_fastretrans_alert(struct sock
*sk, int pkts_acked, int flag)
=A0 =A0 =A0 =A0tcp_xmit_retransmit_queue(sk);
=A0}

-static void tcp_valid_rtt_meas(struct sock *sk, u32 seq_rtt)
+void tcp_valid_rtt_meas(struct sock *sk, u32 seq_rtt)
=A0{
=A0 =A0 =A0 =A0tcp_rtt_estimator(sk, seq_rtt);
=A0 =A0 =A0 =A0tcp_set_rto(sk);
=A0 =A0 =A0 =A0inet_csk(sk)->icsk_backoff =3D 0;
=A0}
+EXPORT_SYMBOL(tcp_valid_rtt_meas);

=A0/* Read draft-ietf-tcplw-high-performance before mucking
=A0* with this code. (Supersedes RFC1323)
@@ -5806,12 +5816,6 @@ int tcp_rcv_state_process(struct sock *sk,
struct sk_buff *skb,
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0tp->rx_opt.snd_wscale;
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0tcp_init=
_wl(tp, TCP_SKB_CB(skb)->seq);

- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* tcp_ac=
k considers this ACK as duplicate
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* and =
does not calculate rtt.
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Forc=
e it here.
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 tcp_ack_u=
pdate_rtt(sk, 0, 0);
-
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (tp->=
rx_opt.tstamp_ok)
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0tp->advmss -=3D TCPOLEN_TSTAMP_ALIGNED;

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 3c8d9b6..5fb504b 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -429,8 +429,8 @@ void tcp_v4_err(struct sk_buff *icmp_skb, u32 info)
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;

=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0icsk->icsk_backoff--;
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 inet_csk(sk)->icsk_rto =3D __tcp_set_rto(=
tp) <<
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0icsk->icsk_backoff;
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 inet_csk(sk)->icsk_rto =3D (tp->srtt ? __=
tcp_set_rto(tp) :
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 TCP_TIMEOUT_INIT) << icsk=
->icsk_backoff;
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0tcp_bound_rto(sk);

=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0skb =3D tcp_write_queue_head(sk);
@@ -1384,6 +1384,7 @@ int tcp_v4_conn_request(struct sock *sk, struct
sk_buff *skb)
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0isn =3D tcp_v4_init_sequence(skb);
=A0 =A0 =A0 =A0}
=A0 =A0 =A0 =A0tcp_rsk(req)->snt_isn =3D isn;
+ =A0 =A0 =A0 tcp_rsk(req)->snt_synack =3D tcp_time_stamp;

=A0 =A0 =A0 =A0if (tcp_v4_send_synack(sk, dst, req,
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (struct req=
uest_values *)&tmp_ext) ||
@@ -1458,6 +1459,10 @@ struct sock *tcp_v4_syn_recv_sock(struct sock
*sk, struct sk_buff *skb,
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0newtp->advmss =3D tcp_sk(sk)->rx_opt.use=
r_mss;

=A0 =A0 =A0 =A0tcp_initialize_rcv_mss(newsk);
+ =A0 =A0 =A0 if (tcp_rsk(req)->snt_synack)
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 tcp_valid_rtt_meas(newsk,
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 tcp_time_stamp - tcp_rsk(req)->sn=
t_synack);
+ =A0 =A0 =A0 newtp->total_retrans =3D req->retrans;

=A0#ifdef CONFIG_TCP_MD5SIG
=A0 =A0 =A0 =A0/* Copy over the MD5 key from the original socket */
@@ -1854,7 +1859,7 @@ static int tcp_v4_init_sock(struct sock *sk)
=A0 =A0 =A0 =A0 * algorithms that we must have the following bandaid to=
 talk
=A0 =A0 =A0 =A0 * efficiently to them. =A0-DaveM
=A0 =A0 =A0 =A0 */
- =A0 =A0 =A0 tp->snd_cwnd =3D 2;
+ =A0 =A0 =A0 tp->snd_cwnd =3D TCP_INIT_CWND;

=A0 =A0 =A0 =A0/* See draft-stevens-tcpca-spec-01 for discussion of the
=A0 =A0 =A0 =A0 * initialization of these values.
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 80b1f80..d2fe4e0 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -486,7 +486,7 @@ struct sock *tcp_create_openreq_child(struct sock
*sk, struct request_sock *req,
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * algorithms that we must have the foll=
owing bandaid to talk
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * efficiently to them. =A0-DaveM
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 */
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 newtp->snd_cwnd =3D 2;
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 newtp->snd_cwnd =3D TCP_INIT_CWND;
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0newtp->snd_cwnd_cnt =3D 0;
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0newtp->bytes_acked =3D 0;

@@ -720,6 +720,10 @@ struct sock *tcp_check_req(struct sock *sk,
struct sk_buff *skb,
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0NET_INC_STATS_BH(sock_net(sk), LINUX_MIB=
_TCPDEFERACCEPTDROP);
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return NULL;
=A0 =A0 =A0 =A0}
+ =A0 =A0 =A0 if (tmp_opt.saw_tstamp && tmp_opt.rcv_tsecr)
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 tcp_rsk(req)->snt_synack =3D tmp_opt.rcv_=
tsecr;
+ =A0 =A0 =A0 else if (req->retrans) /* don't take RTT sample if retran=
s && ~TS */
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 tcp_rsk(req)->snt_synack =3D 0;

=A0 =A0 =A0 =A0/* OK, ACK is valid, create big socket and
=A0 =A0 =A0 =A0 * feed this segment to it. It will repeat all
diff --git a/net/ipv6/syncookies.c b/net/ipv6/syncookies.c
index 8b9644a..89d5bf8 100644
--- a/net/ipv6/syncookies.c
+++ b/net/ipv6/syncookies.c
@@ -223,6 +223,7 @@ struct sock *cookie_v6_check(struct sock *sk,
struct sk_buff *skb)
=A0 =A0 =A0 =A0ireq->wscale_ok =A0 =A0 =A0 =A0 =3D tcp_opt.wscale_ok;
=A0 =A0 =A0 =A0ireq->tstamp_ok =A0 =A0 =A0 =A0 =3D tcp_opt.saw_tstamp;
=A0 =A0 =A0 =A0req->ts_recent =A0 =A0 =A0 =A0 =A0=3D tcp_opt.saw_tstamp=
 ? tcp_opt.rcv_tsval : 0;
+ =A0 =A0 =A0 treq->snt_synack =A0 =A0 =A0 =A0=3D tcp_opt.saw_tstamp ? =
tcp_opt.rcv_tsecr : 0;
=A0 =A0 =A0 =A0treq->rcv_isn =3D ntohl(th->seq) - 1;
=A0 =A0 =A0 =A0treq->snt_isn =3D cookie;

diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 8683664..e7d47e4 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1341,6 +1341,7 @@ static int tcp_v6_conn_request(struct sock *sk,
struct sk_buff *skb)
=A0 =A0 =A0 =A0}
=A0have_isn:
=A0 =A0 =A0 =A0tcp_rsk(req)->snt_isn =3D isn;
+ =A0 =A0 =A0 tcp_rsk(req)->snt_synack =3D tcp_time_stamp;

=A0 =A0 =A0 =A0security_inet_conn_request(sk, skb, req);

@@ -1509,6 +1510,10 @@ static struct sock *
tcp_v6_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
=A0 =A0 =A0 =A0tcp_sync_mss(newsk, dst_mtu(dst));
=A0 =A0 =A0 =A0newtp->advmss =3D dst_metric_advmss(dst);
=A0 =A0 =A0 =A0tcp_initialize_rcv_mss(newsk);
+ =A0 =A0 =A0 if (tcp_rsk(req)->snt_synack)
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 tcp_valid_rtt_meas(newsk,
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 tcp_time_stamp - tcp_rsk(req)->sn=
t_synack);
+ =A0 =A0 =A0 newtp->total_retrans =3D req->retrans;

=A0 =A0 =A0 =A0newinet->inet_daddr =3D newinet->inet_saddr =3D LOOPBACK=
4_IPV6;
=A0 =A0 =A0 =A0newinet->inet_rcv_saddr =3D LOOPBACK4_IPV6;
--
1.7.3.1
