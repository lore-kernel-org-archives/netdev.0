From: Denis Zaitsev <dzaitsev@yandex-team.ru>
Subject: Re: [patch] Added TCP sysctl tunables.
Date: Mon, 27 May 2013 20:42:49 +0400
Message-ID: <51A38D09.4080600@yandex-team.ru>
References: <5197C327.1030806@yandex-team.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Alexey Ivanov <rbtz@yandex-team.ru>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from forward-corp1f.mail.yandex.net ([95.108.130.40]:49790 "EHLO
	forward-corp1f.mail.yandex.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754900Ab3E0Qsx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 May 2013 12:48:53 -0400
In-Reply-To: <5197C327.1030806@yandex-team.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi again.
It seems, you all were too busy and forgot about this email. So I'm
writing again : )


Following the Google's proposal about "TCP parameters for the 21st
century"
(http://www.ietf.org/mail-archive/web/tcpm/current/msg04707.html), we've
added some sysctl variables, which makes some TCP constants tunable:
 TCP_DELACK_MIN -> net.ipv4.tcp_delack_min
 TCP_DELACK_MAX -> net.ipv4.tcp_delack_max
 TCP_ATO_MIN -> net.ipv4.tcp_ato_min
 TCP_RTO_MAX -> net.ipv4.tcp_rto_max
 TCP_RTO_MIN -> net.ipv4.tcp_rto_min
 TCP_TIMEOUT_INIT -> net.ipv4.tcp_timeout_init
 TCP_SYNQ_INTERVAL -> net.ipv4.tcp_synq_interval

Changing TCP constants on-the-fly, without kernel rebuild is extremely
useful both for fully controlled low-latency networks (i.e. your own
datacenter) and for intercontinental "fat long pipes". For example, at
Yandex we changed TCP_RTO_MIN from HZ/5 to HZ/50 for our
in-one-datacenter clusters, which resulted in a speedup of
frontend-backend communications. Other example: we changed
TCP_TIMEOUT_INIT from HZ*1 to HZ/5 in "fat long pipe" with fixed 100 ms
latency, which resulted in a significally speedup of a large data
transfers. And if you are working with high latency connections (dialup,
gprs etc.) it's reasonable to increase TCP_TIMEOUT_INIT to 3s, as in old
linux kernels. Making this values easy tunable is the main goal of this
patch.
By default, all variables values are same as in kernel headers files.

Obviously, this has its downsides. In wrong hands or without full
understanding of network topology these sysctl variables allow to break
any networking and you should be very careful when changing any of these
values. But on the other hand, it allows people to tune their linux
installations for their network topologies more precisely.

What do you think?

Thanks.

From: Denis Zaitsev <dzaitsev@yandex-team.ru>
Signed-off-by: Denis Zaitsev <dzaitsev@yandex-team.ru>
Date: Sat, 18 May 2013 19:22:38 +0400
Subject: [PATCH] YANDEX: tcpm: Added TCP sysctl tunables
 
This patch was originally designed by Alexey Ivanov
<rbtz@yandex-team.ru> for linux 3.2, I've applied it to linux 3.8 and
tested in internal environment.
This patch makes following constants tunable:
TCP_DELACK_MIN -> net.ipv4.tcp_delack_min
TCP_DELACK_MAX -> net.ipv4.tcp_delack_max
TCP_ATO_MIN -> net.ipv4.tcp_ato_min
TCP_RTO_MAX -> net.ipv4.tcp_rto_max
TCP_RTO_MIN -> net.ipv4.tcp_rto_min
TCP_TIMEOUT_INIT -> net.ipv4.tcp_timeout_init
TCP_SYNQ_INTERVAL -> net.ipv4.tcp_synq_interval
 
- delack: Delayed ACK;
- ato: Quick ACK timeout;
- rto: retrasmit timeout;
- timeout_init: SYN/SYN-ACK retransmit timeout;
- synq_interval: multiplier of syn-queue traversal speed.
 

---
include/net/tcp.h | 24 ++++++++++++++--------
net/ipv4/sysctl_net_ipv4.c | 49 ++++++++++++++++++++++++++++++++++++++++++++
net/ipv4/tcp.c | 6 +++---
net/ipv4/tcp_input.c | 22 ++++++++++----------
net/ipv4/tcp_ipv4.c | 6 +++---
net/ipv4/tcp_minisocks.c | 6 +++---
net/ipv4/tcp_output.c | 20 +++++++++---------
net/ipv4/tcp_timer.c | 44 +++++++++++++++++++++++++--------------
net/ipv6/tcp_ipv6.c | 2 +-
9 files changed, 125 insertions(+), 54 deletions(-)
 
diff --git a/include/net/tcp.h b/include/net/tcp.h
index aed42c7..887d0d1 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -292,6 +292,14 @@ extern int sysctl_tcp_thin_dupack;
extern int sysctl_tcp_early_retrans;
extern int sysctl_tcp_limit_output_bytes;
extern int sysctl_tcp_challenge_ack_limit;
+extern int sysctl_tcp_synq_interval;
+extern int sysctl_tcp_rto_min;
+extern int sysctl_tcp_rto_max;
+extern int sysctl_tcp_delack_min;
+extern int sysctl_tcp_delack_max;
+extern int sysctl_tcp_ato_min;
+extern int sysctl_tcp_timeout_init;
+
extern atomic_long_t tcp_memory_allocated;
extern struct percpu_counter tcp_sockets_allocated;
@@ -399,7 +407,7 @@ static inline void tcp_dec_quickack_mode(struct sock
*sk,
if (pkts >= icsk->icsk_ack.quick) {
icsk->icsk_ack.quick = 0;
/* Leaving quickack mode we deflate ATO. */
- icsk->icsk_ack.ato = TCP_ATO_MIN;
+ icsk->icsk_ack.ato = sysctl_tcp_ato_min;
} else
icsk->icsk_ack.quick -= pkts;
}
@@ -603,8 +611,8 @@ extern void tcp_init_buffer_space(struct sock *sk);
static inline void tcp_bound_rto(const struct sock *sk)
{
- if (inet_csk(sk)->icsk_rto > TCP_RTO_MAX)
- inet_csk(sk)->icsk_rto = TCP_RTO_MAX;
+ if (inet_csk(sk)->icsk_rto > sysctl_tcp_rto_max)
+ inet_csk(sk)->icsk_rto = sysctl_tcp_rto_max;
}
static inline u32 __tcp_set_rto(const struct tcp_sock *tp)
@@ -641,7 +649,7 @@ static inline void tcp_fast_path_check(struct sock *sk)
static inline u32 tcp_rto_min(struct sock *sk)
{
const struct dst_entry *dst = __sk_dst_get(sk);
- u32 rto_min = TCP_RTO_MIN;
+ u32 rto_min = sysctl_tcp_rto_min;
if (dst && dst_metric_locked(dst, RTAX_RTO_MIN))
rto_min = dst_metric_rtt(dst, RTAX_RTO_MIN);
@@ -981,7 +989,7 @@ static inline void tcp_check_probe_timer(struct sock
*sk)
if (!tp->packets_out && !icsk->icsk_pending)
inet_csk_reset_xmit_timer(sk, ICSK_TIME_PROBE0,
- icsk->icsk_rto, TCP_RTO_MAX);
+ icsk->icsk_rto, sysctl_tcp_rto_max);
}
static inline void tcp_init_wl(struct tcp_sock *tp, u32 seq)
@@ -1065,7 +1073,7 @@ static inline bool tcp_prequeue(struct sock *sk,
struct sk_buff *skb)
if (!inet_csk_ack_scheduled(sk))
inet_csk_reset_xmit_timer(sk, ICSK_TIME_DACK,
(3 * tcp_rto_min(sk)) / 4,
- TCP_RTO_MAX);
+ sysctl_tcp_rto_max);
}
return true;
}
@@ -1227,8 +1235,8 @@ static inline void tcp_mib_init(struct net *net)
{
/* See RFC 2012 */
TCP_ADD_STATS_USER(net, TCP_MIB_RTOALGORITHM, 1);
- TCP_ADD_STATS_USER(net, TCP_MIB_RTOMIN, TCP_RTO_MIN*1000/HZ);
- TCP_ADD_STATS_USER(net, TCP_MIB_RTOMAX, TCP_RTO_MAX*1000/HZ);
+ TCP_ADD_STATS_USER(net, TCP_MIB_RTOMIN, sysctl_tcp_rto_min*1000/HZ);
+ TCP_ADD_STATS_USER(net, TCP_MIB_RTOMAX, sysctl_tcp_rto_max*1000/HZ);
TCP_ADD_STATS_USER(net, TCP_MIB_MAXCONN, -1);
}
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index d84400b..d9558c0 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -774,6 +774,55 @@ static struct ctl_table ipv4_table[] = {
.extra2 = &two,
},
{
+ .procname = "tcp_rto_min",
+ .data = &sysctl_tcp_rto_min,
+ .maxlen = sizeof(int),
+ .mode = 0644,
+ .proc_handler = proc_dointvec_ms_jiffies,
+ },
+ {
+ .procname = "tcp_rto_max",
+ .data = &sysctl_tcp_rto_max,
+ .maxlen = sizeof(int),
+ .mode = 0644,
+ .proc_handler = proc_dointvec_ms_jiffies,
+ },
+ {
+ .procname = "tcp_delack_min",
+ .data = &sysctl_tcp_delack_min,
+ .maxlen = sizeof(int),
+ .mode = 0644,
+ .proc_handler = proc_dointvec_ms_jiffies,
+ },
+ {
+ .procname = "tcp_delack_max",
+ .data = &sysctl_tcp_delack_max,
+ .maxlen = sizeof(int),
+ .mode = 0644,
+ .proc_handler = proc_dointvec_ms_jiffies,
+ },
+ {
+ .procname = "tcp_ato_min",
+ .data = &sysctl_tcp_ato_min,
+ .maxlen = sizeof(int),
+ .mode = 0644,
+ .proc_handler = proc_dointvec_ms_jiffies,
+ },
+ {
+ .procname = "tcp_timeout_init",
+ .data = &sysctl_tcp_timeout_init,
+ .maxlen = sizeof(int),
+ .mode = 0644,
+ .proc_handler = proc_dointvec_ms_jiffies,
+ },
+ {
+ .procname = "tcp_synq_interval",
+ .data = &sysctl_tcp_synq_interval,
+ .maxlen = sizeof(int),
+ .mode = 0644,
+ .proc_handler = proc_dointvec_ms_jiffies,
+ },
+ {
.procname = "udp_mem",
.data = &sysctl_udp_mem,
.maxlen = sizeof(sysctl_udp_mem),
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 45b63ca..6b493f9 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2656,8 +2656,8 @@ static int do_tcp_setsockopt(struct sock *sk, int
level,
case TCP_DEFER_ACCEPT:
/* Translate value in seconds to number of retransmits */
icsk->icsk_accept_queue.rskq_defer_accept =
- secs_to_retrans(val, TCP_TIMEOUT_INIT / HZ,
- TCP_RTO_MAX / HZ);
+ secs_to_retrans(val, sysctl_tcp_timeout_init / HZ,
+ sysctl_tcp_rto_max / HZ);
break;
case TCP_WINDOW_CLAMP:
@@ -2860,7 +2860,7 @@ static int do_tcp_getsockopt(struct sock *sk, int
level,
break;
case TCP_DEFER_ACCEPT:
val = retrans_to_secs(icsk->icsk_accept_queue.rskq_defer_accept,
- TCP_TIMEOUT_INIT / HZ, TCP_RTO_MAX / HZ);
+ sysctl_tcp_timeout_init / HZ, sysctl_tcp_rto_max / HZ);
break;
case TCP_WINDOW_CLAMP:
val = tp->window_clamp;
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index b4e8b79..8aa0afb 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -192,7 +192,7 @@ static void tcp_enter_quickack_mode(struct sock *sk)
struct inet_connection_sock *icsk = inet_csk(sk);
tcp_incr_quickack(sk);
icsk->icsk_ack.pingpong = 0;
- icsk->icsk_ack.ato = TCP_ATO_MIN;
+ icsk->icsk_ack.ato = sysctl_tcp_ato_min;
}
/* Send ACKs quickly, if "quick" count is not exhausted
@@ -606,13 +606,13 @@ static void tcp_event_data_recv(struct sock *sk,
struct sk_buff *skb)
* delayed ACK engine.
*/
tcp_incr_quickack(sk);
- icsk->icsk_ack.ato = TCP_ATO_MIN;
+ icsk->icsk_ack.ato = sysctl_tcp_ato_min;
} else {
int m = now - icsk->icsk_ack.lrcvtime;
- if (m <= TCP_ATO_MIN / 2) {
+ if (m <= sysctl_tcp_ato_min / 2) {
/* The fastest case is the first. */
- icsk->icsk_ack.ato = (icsk->icsk_ack.ato >> 1) + TCP_ATO_MIN / 2;
+ icsk->icsk_ack.ato = (icsk->icsk_ack.ato >> 1) + sysctl_tcp_ato_min / 2;
} else if (m < icsk->icsk_ack.ato) {
icsk->icsk_ack.ato = (icsk->icsk_ack.ato >> 1) + m;
if (icsk->icsk_ack.ato > icsk->icsk_rto)
@@ -729,7 +729,7 @@ void tcp_set_rto(struct sock *sk)
* with correct one. It is exactly, which we pretend to do.
*/
- /* NOTE: clamping at TCP_RTO_MIN is not required, current algo
+ /* NOTE: clamping at sysctl_tcp_rto_min is not required, current algo
* guarantees that rto is higher.
*/
tcp_bound_rto(sk);
@@ -2113,7 +2113,7 @@ static bool tcp_check_sack_reneging(struct sock
*sk, int flag)
icsk->icsk_retransmits++;
tcp_retransmit_skb(sk, tcp_write_queue_head(sk));
inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS,
- icsk->icsk_rto, TCP_RTO_MAX);
+ icsk->icsk_rto, sysctl_tcp_rto_max);
return true;
}
return false;
@@ -2160,7 +2160,7 @@ static bool tcp_pause_early_retransmit(struct sock
*sk, int flag)
if (!time_after(inet_csk(sk)->icsk_timeout, (jiffies + delay)))
return false;
- inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS, delay, TCP_RTO_MAX);
+ inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS, delay,
sysctl_tcp_rto_max);
tp->early_retrans_delayed = 1;
return true;
}
@@ -3110,7 +3110,7 @@ void tcp_rearm_rto(struct sock *sk)
rto = delta;
}
inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS, rto,
- TCP_RTO_MAX);
+ sysctl_tcp_rto_max);
}
tp->early_retrans_delayed = 0;
}
@@ -3340,8 +3340,8 @@ static void tcp_ack_probe(struct sock *sk)
*/
} else {
inet_csk_reset_xmit_timer(sk, ICSK_TIME_PROBE0,
- min(icsk->icsk_rto << icsk->icsk_backoff, TCP_RTO_MAX),
- TCP_RTO_MAX);
+ min(icsk->icsk_rto << icsk->icsk_backoff, sysctl_tcp_rto_max),
+ sysctl_tcp_rto_max);
}
}
@@ -5821,7 +5821,7 @@ static int tcp_rcv_synsent_state_process(struct
sock *sk, struct sk_buff *skb,
icsk->icsk_ack.lrcvtime = tcp_time_stamp;
tcp_enter_quickack_mode(sk);
inet_csk_reset_xmit_timer(sk, ICSK_TIME_DACK,
- TCP_DELACK_MAX, TCP_RTO_MAX);
+ TCP_DELACK_MAX, sysctl_tcp_rto_max);
discard:
__kfree_skb(skb);
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index d9130a9..0aec555 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -434,7 +434,7 @@ void tcp_v4_err(struct sk_buff *icmp_skb, u32 info)
icsk->icsk_backoff--;
inet_csk(sk)->icsk_rto = (tp->srtt ? __tcp_set_rto(tp) :
- TCP_TIMEOUT_INIT) << icsk->icsk_backoff;
+ sysctl_tcp_timeout_init) << icsk->icsk_backoff;
tcp_bound_rto(sk);
skb = tcp_write_queue_head(sk);
@@ -445,7 +445,7 @@ void tcp_v4_err(struct sk_buff *icmp_skb, u32 info)
if (remaining) {
inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS,
- remaining, TCP_RTO_MAX);
+ remaining, sysctl_tcp_rto_max);
} else {
/* RTO revert clocked out retransmission.
* Will retransmit now */
@@ -1654,7 +1654,7 @@ int tcp_v4_conn_request(struct sock *sk, struct
sk_buff *skb)
tcp_rsk(req)->snt_synack = tcp_time_stamp;
tcp_rsk(req)->listener = NULL;
/* Add the request_sock to the SYN table */
- inet_csk_reqsk_queue_hash_add(sk, req, TCP_TIMEOUT_INIT);
+ inet_csk_reqsk_queue_hash_add(sk, req, sysctl_tcp_timeout_init);
if (fastopen_cookie_present(&foc) && foc.len != 0)
NET_INC_STATS_BH(sock_net(sk),
LINUX_MIB_TCPFASTOPENPASSIVEFAIL);
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index f35f2df..b1397f8 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -429,8 +429,8 @@ struct sock *tcp_create_openreq_child(struct sock
*sk, struct request_sock *req,
tcp_init_wl(newtp, treq->rcv_isn);
newtp->srtt = 0;
- newtp->mdev = TCP_TIMEOUT_INIT;
- newicsk->icsk_rto = TCP_TIMEOUT_INIT;
+ newtp->mdev = sysctl_tcp_timeout_init;
+ newicsk->icsk_rto = sysctl_tcp_timeout_init;
newtp->packets_out = 0;
newtp->retrans_out = 0;
@@ -553,7 +553,7 @@ struct sock *tcp_check_req(struct sock *sk, struct
sk_buff *skb,
* it can be estimated (approximately)
* from another data.
*/
- tmp_opt.ts_recent_stamp = get_seconds() -
((TCP_TIMEOUT_INIT/HZ)<<req->num_timeout);
+ tmp_opt.ts_recent_stamp = get_seconds() -
((sysctl_tcp_timeout_init/HZ)<<req->num_timeout);
paws_reject = tcp_paws_reject(&tmp_opt, th->rst);
}
}
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index a9f50ee..f6375db 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2567,7 +2567,7 @@ begin_fwd:
if (skb == tcp_write_queue_head(sk))
inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS,
inet_csk(sk)->icsk_rto,
- TCP_RTO_MAX);
+ sysctl_tcp_rto_max);
}
}
@@ -2885,7 +2885,7 @@ void tcp_connect_init(struct sock *sk)
tp->rcv_wup = tp->rcv_nxt;
tp->copied_seq = tp->rcv_nxt;
- inet_csk(sk)->icsk_rto = TCP_TIMEOUT_INIT;
+ inet_csk(sk)->icsk_rto = sysctl_tcp_timeout_init;
inet_csk(sk)->icsk_retransmits = 0;
tcp_clear_retrans(tp);
}
@@ -3034,7 +3034,7 @@ int tcp_connect(struct sock *sk)
/* Timer for repeating the SYN until an answer. */
inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS,
- inet_csk(sk)->icsk_rto, TCP_RTO_MAX);
+ inet_csk(sk)->icsk_rto, sysctl_tcp_rto_max);
return 0;
}
EXPORT_SYMBOL(tcp_connect);
@@ -3055,7 +3055,7 @@ void tcp_send_delayed_ack(struct sock *sk)
if (icsk->icsk_ack.pingpong ||
(icsk->icsk_ack.pending & ICSK_ACK_PUSHED))
- max_ato = TCP_DELACK_MAX;
+ max_ato = sysctl_tcp_delack_max;
/* Slow path, intersegment interval is "high". */
@@ -3064,7 +3064,7 @@ void tcp_send_delayed_ack(struct sock *sk)
* directly.
*/
if (tp->srtt) {
- int rtt = max(tp->srtt >> 3, TCP_DELACK_MIN);
+ int rtt = max(tp->srtt >> 3, sysctl_tcp_delack_min);
if (rtt < max_ato)
max_ato = rtt;
@@ -3111,9 +3111,9 @@ void tcp_send_ack(struct sock *sk)
buff = alloc_skb(MAX_TCP_HEADER, sk_gfp_atomic(sk, GFP_ATOMIC));
if (buff == NULL) {
inet_csk_schedule_ack(sk);
- inet_csk(sk)->icsk_ack.ato = TCP_ATO_MIN;
+ inet_csk(sk)->icsk_ack.ato = sysctl_tcp_ato_min;
inet_csk_reset_xmit_timer(sk, ICSK_TIME_DACK,
- TCP_DELACK_MAX, TCP_RTO_MAX);
+ sysctl_tcp_delack_max, sysctl_tcp_rto_max);
return;
}
@@ -3234,8 +3234,8 @@ void tcp_send_probe0(struct sock *sk)
icsk->icsk_backoff++;
icsk->icsk_probes_out++;
inet_csk_reset_xmit_timer(sk, ICSK_TIME_PROBE0,
- min(icsk->icsk_rto << icsk->icsk_backoff, TCP_RTO_MAX),
- TCP_RTO_MAX);
+ min(icsk->icsk_rto << icsk->icsk_backoff, sysctl_tcp_rto_max),
+ sysctl_tcp_rto_max);
} else {
/* If packet was not sent due to local congestion,
* do not backoff and do not remember icsk_probes_out.
@@ -3248,6 +3248,6 @@ void tcp_send_probe0(struct sock *sk)
inet_csk_reset_xmit_timer(sk, ICSK_TIME_PROBE0,
min(icsk->icsk_rto << icsk->icsk_backoff,
TCP_RESOURCE_PROBE_INTERVAL),
- TCP_RTO_MAX);
+ sysctl_tcp_rto_max);
}
}
diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
index b78aac3..c5b35de 100644
--- a/net/ipv4/tcp_timer.c
+++ b/net/ipv4/tcp_timer.c
@@ -31,6 +31,20 @@ int sysctl_tcp_retries1 __read_mostly = TCP_RETR1;
int sysctl_tcp_retries2 __read_mostly = TCP_RETR2;
int sysctl_tcp_orphan_retries __read_mostly;
int sysctl_tcp_thin_linear_timeouts __read_mostly;
+int sysctl_tcp_timeout_init __read_mostly = TCP_TIMEOUT_INIT;
+EXPORT_SYMBOL(sysctl_tcp_timeout_init);
+int sysctl_tcp_rto_min __read_mostly = TCP_RTO_MIN;
+EXPORT_SYMBOL(sysctl_tcp_rto_min);
+int sysctl_tcp_rto_max __read_mostly = TCP_RTO_MAX;
+EXPORT_SYMBOL(sysctl_tcp_rto_max);
+int sysctl_tcp_delack_min __read_mostly = TCP_DELACK_MIN;
+EXPORT_SYMBOL(sysctl_tcp_delack_min);
+int sysctl_tcp_delack_max __read_mostly = TCP_DELACK_MAX;
+EXPORT_SYMBOL(sysctl_tcp_delack_max);
+int sysctl_tcp_ato_min __read_mostly = TCP_ATO_MIN;
+EXPORT_SYMBOL(sysctl_tcp_ato_min);
+int sysctl_tcp_synq_interval __read_mostly = TCP_SYNQ_INTERVAL;
+EXPORT_SYMBOL(sysctl_tcp_synq_interval);
static void tcp_write_err(struct sock *sk)
{
@@ -59,7 +73,7 @@ static int tcp_out_of_resources(struct sock *sk, int
do_reset)
/* If peer does not open window for long time, or did not transmit
* anything for long time, penalize it. */
- if ((s32)(tcp_time_stamp - tp->lsndtime) > 2*TCP_RTO_MAX || !do_reset)
+ if ((s32)(tcp_time_stamp - tp->lsndtime) > 2*sysctl_tcp_rto_max ||
!do_reset)
shift++;
/* If some dubious ICMP arrived, penalize even more. */
@@ -121,7 +135,7 @@ static void tcp_mtu_probing(struct
inet_connection_sock *icsk, struct sock *sk)
/* This function calculates a "timeout" which is equivalent to the
timeout of a
* TCP connection after "boundary" unsuccessful, exponentially backed-off
- * retransmissions with an initial RTO of TCP_RTO_MIN or
TCP_TIMEOUT_INIT if
+ * retransmissions with an initial RTO of sysctl_tcp_rto_min or
sysctl_tcp_timeout_init if
* syn_set flag is set.
*/
static bool retransmits_timed_out(struct sock *sk,
@@ -130,7 +144,7 @@ static bool retransmits_timed_out(struct sock *sk,
bool syn_set)
{
unsigned int linear_backoff_thresh, start_ts;
- unsigned int rto_base = syn_set ? TCP_TIMEOUT_INIT : TCP_RTO_MIN;
+ unsigned int rto_base = syn_set ? sysctl_tcp_timeout_init :
sysctl_tcp_rto_min;
if (!inet_csk(sk)->icsk_retransmits)
return false;
@@ -141,13 +155,13 @@ static bool retransmits_timed_out(struct sock *sk,
start_ts = tcp_sk(sk)->retrans_stamp;
if (likely(timeout == 0)) {
- linear_backoff_thresh = ilog2(TCP_RTO_MAX/rto_base);
+ linear_backoff_thresh = ilog2(sysctl_tcp_rto_max/rto_base);
if (boundary <= linear_backoff_thresh)
timeout = ((2 << boundary) - 1) * rto_base;
else
timeout = ((2 << linear_backoff_thresh) - 1) * rto_base +
- (boundary - linear_backoff_thresh) * TCP_RTO_MAX;
+ (boundary - linear_backoff_thresh) * sysctl_tcp_rto_max;
}
return (tcp_time_stamp - start_ts) >= timeout;
}
@@ -174,7 +188,7 @@ static int tcp_write_timeout(struct sock *sk)
retry_until = sysctl_tcp_retries2;
if (sock_flag(sk, SOCK_DEAD)) {
- const int alive = (icsk->icsk_rto < TCP_RTO_MAX);
+ const int alive = (icsk->icsk_rto < sysctl_tcp_rto_max);
retry_until = tcp_orphan_retries(sk, alive);
do_reset = alive ||
@@ -230,7 +244,7 @@ void tcp_delack_timer_handler(struct sock *sk)
* deflate ATO.
*/
icsk->icsk_ack.pingpong = 0;
- icsk->icsk_ack.ato = TCP_ATO_MIN;
+ icsk->icsk_ack.ato = sysctl_tcp_ato_min;
}
tcp_send_ack(sk);
NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_DELAYEDACKS);
@@ -288,7 +302,7 @@ static void tcp_probe_timer(struct sock *sk)
max_probes = sysctl_tcp_retries2;
if (sock_flag(sk, SOCK_DEAD)) {
- const int alive = ((icsk->icsk_rto << icsk->icsk_backoff) < TCP_RTO_MAX);
+ const int alive = ((icsk->icsk_rto << icsk->icsk_backoff) <
sysctl_tcp_rto_max);
max_probes = tcp_orphan_retries(sk, alive);
@@ -383,7 +397,7 @@ void tcp_retransmit_timer(struct sock *sk)
tp->snd_una, tp->snd_nxt);
}
#endif
- if (tcp_time_stamp - tp->rcv_tstamp > TCP_RTO_MAX) {
+ if (tcp_time_stamp - tp->rcv_tstamp > sysctl_tcp_rto_max) {
tcp_write_err(sk);
goto out;
}
@@ -432,7 +446,7 @@ void tcp_retransmit_timer(struct sock *sk)
icsk->icsk_retransmits = 1;
inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS,
min(icsk->icsk_rto, TCP_RESOURCE_PROBE_INTERVAL),
- TCP_RTO_MAX);
+ sysctl_tcp_rto_max);
goto out;
}
@@ -469,12 +483,12 @@ out_reset_timer:
tcp_stream_is_thin(tp) &&
icsk->icsk_retransmits <= TCP_THIN_LINEAR_RETRIES) {
icsk->icsk_backoff = 0;
- icsk->icsk_rto = min(__tcp_set_rto(tp), TCP_RTO_MAX);
+ icsk->icsk_rto = min(__tcp_set_rto(tp), sysctl_tcp_rto_max);
} else {
/* Use normal (exponential) backoff */
- icsk->icsk_rto = min(icsk->icsk_rto << 1, TCP_RTO_MAX);
+ icsk->icsk_rto = min(icsk->icsk_rto << 1, sysctl_tcp_rto_max);
}
- inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS, icsk->icsk_rto,
TCP_RTO_MAX);
+ inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS, icsk->icsk_rto,
sysctl_tcp_rto_max);
if (retransmits_timed_out(sk, sysctl_tcp_retries1 + 1, 0, 0))
__sk_dst_reset(sk);
@@ -532,8 +546,8 @@ static void tcp_write_timer(unsigned long data)
static void tcp_synack_timer(struct sock *sk)
{
- inet_csk_reqsk_queue_prune(sk, TCP_SYNQ_INTERVAL,
- TCP_TIMEOUT_INIT, TCP_RTO_MAX);
+ inet_csk_reqsk_queue_prune(sk, sysctl_tcp_synq_interval,
+ sysctl_tcp_timeout_init, sysctl_tcp_rto_max);
}
void tcp_syn_ack_timeout(struct sock *sk, struct request_sock *req)
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 89dfedd..ab68733 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1111,7 +1111,7 @@ have_isn:
tcp_rsk(req)->snt_synack = tcp_time_stamp;
tcp_rsk(req)->listener = NULL;
- inet6_csk_reqsk_queue_hash_add(sk, req, TCP_TIMEOUT_INIT);
+ inet6_csk_reqsk_queue_hash_add(sk, req, sysctl_tcp_timeout_init);
return 0;
drop_and_release:
-- 



On 05/18/2013 10:06 PM, Denis Zaitsev wrote:
> Hi.
>
> Following the Google's proposal about "TCP parameters for the 21st
> century"
> (http://www.ietf.org/mail-archive/web/tcpm/current/msg04707.html), we've
> added some sysctl variables, which makes some TCP constants tunable:
>  TCP_DELACK_MIN -> net.ipv4.tcp_delack_min
>  TCP_DELACK_MAX -> net.ipv4.tcp_delack_max
>  TCP_ATO_MIN -> net.ipv4.tcp_ato_min
>  TCP_RTO_MAX -> net.ipv4.tcp_rto_max
>  TCP_RTO_MIN -> net.ipv4.tcp_rto_min
>  TCP_TIMEOUT_INIT -> net.ipv4.tcp_timeout_init
>  TCP_SYNQ_INTERVAL -> net.ipv4.tcp_synq_interval
>
> Changing TCP constants on-the-fly, without kernel rebuild is extremely
> useful both for fully controlled low-latency networks (i.e. your own
> datacenter) and for intercontinental "fat long pipes". For example, at
> Yandex we changed TCP_RTO_MIN from HZ/5 to HZ/50 for our
> in-one-datacenter clusters, which resulted in a speedup of
> frontend-backend communications. Other example: we changed
> TCP_TIMEOUT_INIT from HZ*1 to HZ/5 in "fat long pipe" with fixed 100 ms
> latency, which resulted in a significally speedup of a large data
> transfers. And if you are working with high latency connections (dialup,
> gprs etc.) it's reasonable to increase TCP_TIMEOUT_INIT to 3s, as in old
> linux kernels. Making this values easy tunable is the main goal of this
> patch.
> By default, all variables values are same as in kernel headers files.
>
> Obviously, this has its downsides. In wrong hands or without full
> understanding of network topology these sysctl variables allow to break
> any networking and you should be very careful when changing any of these
> values. But on the other hand, it allows people to tune their linux
> installations for their network topologies more precisely.
>
> What do you think?
>
> Thanks.
>
> From: Denis Zaitsev <dzaitsev@yandex-team.ru> Signed-off-by: Denis
> Zaitsev <dzaitsev@yandex-team.ru> Date: Sat, 18 May 2013 19:22:38 +0400
> Subject: [PATCH] YANDEX: tcpm: Added TCP sysctl tunables
>  
> This patch was originally designed by Alexey Ivanov
> <rbtz@yandex-team.ru> for linux 3.2, I've applied it to linux 3.8 and
> tested in internal environment.
> This patch makes following constants tunable:
> TCP_DELACK_MIN -> net.ipv4.tcp_delack_min
> TCP_DELACK_MAX -> net.ipv4.tcp_delack_max
> TCP_ATO_MIN -> net.ipv4.tcp_ato_min
> TCP_RTO_MAX -> net.ipv4.tcp_rto_max
> TCP_RTO_MIN -> net.ipv4.tcp_rto_min
> TCP_TIMEOUT_INIT -> net.ipv4.tcp_timeout_init
> TCP_SYNQ_INTERVAL -> net.ipv4.tcp_synq_interval
>  
> - delack: Delayed ACK;
> - ato: Quick ACK timeout;
> - rto: retrasmit timeout;
> - timeout_init: SYN/SYN-ACK retransmit timeout;
> - synq_interval: multiplier of syn-queue traversal speed.
>  
>
> ---
> include/net/tcp.h | 24 ++++++++++++++--------
> net/ipv4/sysctl_net_ipv4.c | 49 ++++++++++++++++++++++++++++++++++++++++++++
> net/ipv4/tcp.c | 6 +++---
> net/ipv4/tcp_input.c | 22 ++++++++++----------
> net/ipv4/tcp_ipv4.c | 6 +++---
> net/ipv4/tcp_minisocks.c | 6 +++---
> net/ipv4/tcp_output.c | 20 +++++++++---------
> net/ipv4/tcp_timer.c | 44 +++++++++++++++++++++++++--------------
> net/ipv6/tcp_ipv6.c | 2 +-
> 9 files changed, 125 insertions(+), 54 deletions(-)
>  
> diff --git a/include/net/tcp.h b/include/net/tcp.h
> index aed42c7..887d0d1 100644
> --- a/include/net/tcp.h
> +++ b/include/net/tcp.h
> @@ -292,6 +292,14 @@ extern int sysctl_tcp_thin_dupack;
> extern int sysctl_tcp_early_retrans;
> extern int sysctl_tcp_limit_output_bytes;
> extern int sysctl_tcp_challenge_ack_limit;
> +extern int sysctl_tcp_synq_interval;
> +extern int sysctl_tcp_rto_min;
> +extern int sysctl_tcp_rto_max;
> +extern int sysctl_tcp_delack_min;
> +extern int sysctl_tcp_delack_max;
> +extern int sysctl_tcp_ato_min;
> +extern int sysctl_tcp_timeout_init;
> +
> extern atomic_long_t tcp_memory_allocated;
> extern struct percpu_counter tcp_sockets_allocated;
> @@ -399,7 +407,7 @@ static inline void tcp_dec_quickack_mode(struct sock
> *sk,
> if (pkts >= icsk->icsk_ack.quick) {
> icsk->icsk_ack.quick = 0;
> /* Leaving quickack mode we deflate ATO. */
> - icsk->icsk_ack.ato = TCP_ATO_MIN;
> + icsk->icsk_ack.ato = sysctl_tcp_ato_min;
> } else
> icsk->icsk_ack.quick -= pkts;
> }
> @@ -603,8 +611,8 @@ extern void tcp_init_buffer_space(struct sock *sk);
> static inline void tcp_bound_rto(const struct sock *sk)
> {
> - if (inet_csk(sk)->icsk_rto > TCP_RTO_MAX)
> - inet_csk(sk)->icsk_rto = TCP_RTO_MAX;
> + if (inet_csk(sk)->icsk_rto > sysctl_tcp_rto_max)
> + inet_csk(sk)->icsk_rto = sysctl_tcp_rto_max;
> }
> static inline u32 __tcp_set_rto(const struct tcp_sock *tp)
> @@ -641,7 +649,7 @@ static inline void tcp_fast_path_check(struct sock *sk)
> static inline u32 tcp_rto_min(struct sock *sk)
> {
> const struct dst_entry *dst = __sk_dst_get(sk);
> - u32 rto_min = TCP_RTO_MIN;
> + u32 rto_min = sysctl_tcp_rto_min;
> if (dst && dst_metric_locked(dst, RTAX_RTO_MIN))
> rto_min = dst_metric_rtt(dst, RTAX_RTO_MIN);
> @@ -981,7 +989,7 @@ static inline void tcp_check_probe_timer(struct sock
> *sk)
> if (!tp->packets_out && !icsk->icsk_pending)
> inet_csk_reset_xmit_timer(sk, ICSK_TIME_PROBE0,
> - icsk->icsk_rto, TCP_RTO_MAX);
> + icsk->icsk_rto, sysctl_tcp_rto_max);
> }
> static inline void tcp_init_wl(struct tcp_sock *tp, u32 seq)
> @@ -1065,7 +1073,7 @@ static inline bool tcp_prequeue(struct sock *sk,
> struct sk_buff *skb)
> if (!inet_csk_ack_scheduled(sk))
> inet_csk_reset_xmit_timer(sk, ICSK_TIME_DACK,
> (3 * tcp_rto_min(sk)) / 4,
> - TCP_RTO_MAX);
> + sysctl_tcp_rto_max);
> }
> return true;
> }
> @@ -1227,8 +1235,8 @@ static inline void tcp_mib_init(struct net *net)
> {
> /* See RFC 2012 */
> TCP_ADD_STATS_USER(net, TCP_MIB_RTOALGORITHM, 1);
> - TCP_ADD_STATS_USER(net, TCP_MIB_RTOMIN, TCP_RTO_MIN*1000/HZ);
> - TCP_ADD_STATS_USER(net, TCP_MIB_RTOMAX, TCP_RTO_MAX*1000/HZ);
> + TCP_ADD_STATS_USER(net, TCP_MIB_RTOMIN, sysctl_tcp_rto_min*1000/HZ);
> + TCP_ADD_STATS_USER(net, TCP_MIB_RTOMAX, sysctl_tcp_rto_max*1000/HZ);
> TCP_ADD_STATS_USER(net, TCP_MIB_MAXCONN, -1);
> }
> diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
> index d84400b..d9558c0 100644
> --- a/net/ipv4/sysctl_net_ipv4.c
> +++ b/net/ipv4/sysctl_net_ipv4.c
> @@ -774,6 +774,55 @@ static struct ctl_table ipv4_table[] = {
> .extra2 = &two,
> },
> {
> + .procname = "tcp_rto_min",
> + .data = &sysctl_tcp_rto_min,
> + .maxlen = sizeof(int),
> + .mode = 0644,
> + .proc_handler = proc_dointvec_ms_jiffies,
> + },
> + {
> + .procname = "tcp_rto_max",
> + .data = &sysctl_tcp_rto_max,
> + .maxlen = sizeof(int),
> + .mode = 0644,
> + .proc_handler = proc_dointvec_ms_jiffies,
> + },
> + {
> + .procname = "tcp_delack_min",
> + .data = &sysctl_tcp_delack_min,
> + .maxlen = sizeof(int),
> + .mode = 0644,
> + .proc_handler = proc_dointvec_ms_jiffies,
> + },
> + {
> + .procname = "tcp_delack_max",
> + .data = &sysctl_tcp_delack_max,
> + .maxlen = sizeof(int),
> + .mode = 0644,
> + .proc_handler = proc_dointvec_ms_jiffies,
> + },
> + {
> + .procname = "tcp_ato_min",
> + .data = &sysctl_tcp_ato_min,
> + .maxlen = sizeof(int),
> + .mode = 0644,
> + .proc_handler = proc_dointvec_ms_jiffies,
> + },
> + {
> + .procname = "tcp_timeout_init",
> + .data = &sysctl_tcp_timeout_init,
> + .maxlen = sizeof(int),
> + .mode = 0644,
> + .proc_handler = proc_dointvec_ms_jiffies,
> + },
> + {
> + .procname = "tcp_synq_interval",
> + .data = &sysctl_tcp_synq_interval,
> + .maxlen = sizeof(int),
> + .mode = 0644,
> + .proc_handler = proc_dointvec_ms_jiffies,
> + },
> + {
> .procname = "udp_mem",
> .data = &sysctl_udp_mem,
> .maxlen = sizeof(sysctl_udp_mem),
> diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
> index 45b63ca..6b493f9 100644
> --- a/net/ipv4/tcp.c
> +++ b/net/ipv4/tcp.c
> @@ -2656,8 +2656,8 @@ static int do_tcp_setsockopt(struct sock *sk, int
> level,
> case TCP_DEFER_ACCEPT:
> /* Translate value in seconds to number of retransmits */
> icsk->icsk_accept_queue.rskq_defer_accept =
> - secs_to_retrans(val, TCP_TIMEOUT_INIT / HZ,
> - TCP_RTO_MAX / HZ);
> + secs_to_retrans(val, sysctl_tcp_timeout_init / HZ,
> + sysctl_tcp_rto_max / HZ);
> break;
> case TCP_WINDOW_CLAMP:
> @@ -2860,7 +2860,7 @@ static int do_tcp_getsockopt(struct sock *sk, int
> level,
> break;
> case TCP_DEFER_ACCEPT:
> val = retrans_to_secs(icsk->icsk_accept_queue.rskq_defer_accept,
> - TCP_TIMEOUT_INIT / HZ, TCP_RTO_MAX / HZ);
> + sysctl_tcp_timeout_init / HZ, sysctl_tcp_rto_max / HZ);
> break;
> case TCP_WINDOW_CLAMP:
> val = tp->window_clamp;
> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index b4e8b79..8aa0afb 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -192,7 +192,7 @@ static void tcp_enter_quickack_mode(struct sock *sk)
> struct inet_connection_sock *icsk = inet_csk(sk);
> tcp_incr_quickack(sk);
> icsk->icsk_ack.pingpong = 0;
> - icsk->icsk_ack.ato = TCP_ATO_MIN;
> + icsk->icsk_ack.ato = sysctl_tcp_ato_min;
> }
> /* Send ACKs quickly, if "quick" count is not exhausted
> @@ -606,13 +606,13 @@ static void tcp_event_data_recv(struct sock *sk,
> struct sk_buff *skb)
> * delayed ACK engine.
> */
> tcp_incr_quickack(sk);
> - icsk->icsk_ack.ato = TCP_ATO_MIN;
> + icsk->icsk_ack.ato = sysctl_tcp_ato_min;
> } else {
> int m = now - icsk->icsk_ack.lrcvtime;
> - if (m <= TCP_ATO_MIN / 2) {
> + if (m <= sysctl_tcp_ato_min / 2) {
> /* The fastest case is the first. */
> - icsk->icsk_ack.ato = (icsk->icsk_ack.ato >> 1) + TCP_ATO_MIN / 2;
> + icsk->icsk_ack.ato = (icsk->icsk_ack.ato >> 1) + sysctl_tcp_ato_min / 2;
> } else if (m < icsk->icsk_ack.ato) {
> icsk->icsk_ack.ato = (icsk->icsk_ack.ato >> 1) + m;
> if (icsk->icsk_ack.ato > icsk->icsk_rto)
> @@ -729,7 +729,7 @@ void tcp_set_rto(struct sock *sk)
> * with correct one. It is exactly, which we pretend to do.
> */
> - /* NOTE: clamping at TCP_RTO_MIN is not required, current algo
> + /* NOTE: clamping at sysctl_tcp_rto_min is not required, current algo
> * guarantees that rto is higher.
> */
> tcp_bound_rto(sk);
> @@ -2113,7 +2113,7 @@ static bool tcp_check_sack_reneging(struct sock
> *sk, int flag)
> icsk->icsk_retransmits++;
> tcp_retransmit_skb(sk, tcp_write_queue_head(sk));
> inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS,
> - icsk->icsk_rto, TCP_RTO_MAX);
> + icsk->icsk_rto, sysctl_tcp_rto_max);
> return true;
> }
> return false;
> @@ -2160,7 +2160,7 @@ static bool tcp_pause_early_retransmit(struct sock
> *sk, int flag)
> if (!time_after(inet_csk(sk)->icsk_timeout, (jiffies + delay)))
> return false;
> - inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS, delay, TCP_RTO_MAX);
> + inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS, delay,
> sysctl_tcp_rto_max);
> tp->early_retrans_delayed = 1;
> return true;
> }
> @@ -3110,7 +3110,7 @@ void tcp_rearm_rto(struct sock *sk)
> rto = delta;
> }
> inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS, rto,
> - TCP_RTO_MAX);
> + sysctl_tcp_rto_max);
> }
> tp->early_retrans_delayed = 0;
> }
> @@ -3340,8 +3340,8 @@ static void tcp_ack_probe(struct sock *sk)
> */
> } else {
> inet_csk_reset_xmit_timer(sk, ICSK_TIME_PROBE0,
> - min(icsk->icsk_rto << icsk->icsk_backoff, TCP_RTO_MAX),
> - TCP_RTO_MAX);
> + min(icsk->icsk_rto << icsk->icsk_backoff, sysctl_tcp_rto_max),
> + sysctl_tcp_rto_max);
> }
> }
> @@ -5821,7 +5821,7 @@ static int tcp_rcv_synsent_state_process(struct
> sock *sk, struct sk_buff *skb,
> icsk->icsk_ack.lrcvtime = tcp_time_stamp;
> tcp_enter_quickack_mode(sk);
> inet_csk_reset_xmit_timer(sk, ICSK_TIME_DACK,
> - TCP_DELACK_MAX, TCP_RTO_MAX);
> + TCP_DELACK_MAX, sysctl_tcp_rto_max);
> discard:
> __kfree_skb(skb);
> diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
> index d9130a9..0aec555 100644
> --- a/net/ipv4/tcp_ipv4.c
> +++ b/net/ipv4/tcp_ipv4.c
> @@ -434,7 +434,7 @@ void tcp_v4_err(struct sk_buff *icmp_skb, u32 info)
> icsk->icsk_backoff--;
> inet_csk(sk)->icsk_rto = (tp->srtt ? __tcp_set_rto(tp) :
> - TCP_TIMEOUT_INIT) << icsk->icsk_backoff;
> + sysctl_tcp_timeout_init) << icsk->icsk_backoff;
> tcp_bound_rto(sk);
> skb = tcp_write_queue_head(sk);
> @@ -445,7 +445,7 @@ void tcp_v4_err(struct sk_buff *icmp_skb, u32 info)
> if (remaining) {
> inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS,
> - remaining, TCP_RTO_MAX);
> + remaining, sysctl_tcp_rto_max);
> } else {
> /* RTO revert clocked out retransmission.
> * Will retransmit now */
> @@ -1654,7 +1654,7 @@ int tcp_v4_conn_request(struct sock *sk, struct
> sk_buff *skb)
> tcp_rsk(req)->snt_synack = tcp_time_stamp;
> tcp_rsk(req)->listener = NULL;
> /* Add the request_sock to the SYN table */
> - inet_csk_reqsk_queue_hash_add(sk, req, TCP_TIMEOUT_INIT);
> + inet_csk_reqsk_queue_hash_add(sk, req, sysctl_tcp_timeout_init);
> if (fastopen_cookie_present(&foc) && foc.len != 0)
> NET_INC_STATS_BH(sock_net(sk),
> LINUX_MIB_TCPFASTOPENPASSIVEFAIL);
> diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
> index f35f2df..b1397f8 100644
> --- a/net/ipv4/tcp_minisocks.c
> +++ b/net/ipv4/tcp_minisocks.c
> @@ -429,8 +429,8 @@ struct sock *tcp_create_openreq_child(struct sock
> *sk, struct request_sock *req,
> tcp_init_wl(newtp, treq->rcv_isn);
> newtp->srtt = 0;
> - newtp->mdev = TCP_TIMEOUT_INIT;
> - newicsk->icsk_rto = TCP_TIMEOUT_INIT;
> + newtp->mdev = sysctl_tcp_timeout_init;
> + newicsk->icsk_rto = sysctl_tcp_timeout_init;
> newtp->packets_out = 0;
> newtp->retrans_out = 0;
> @@ -553,7 +553,7 @@ struct sock *tcp_check_req(struct sock *sk, struct
> sk_buff *skb,
> * it can be estimated (approximately)
> * from another data.
> */
> - tmp_opt.ts_recent_stamp = get_seconds() -
> ((TCP_TIMEOUT_INIT/HZ)<<req->num_timeout);
> + tmp_opt.ts_recent_stamp = get_seconds() -
> ((sysctl_tcp_timeout_init/HZ)<<req->num_timeout);
> paws_reject = tcp_paws_reject(&tmp_opt, th->rst);
> }
> }
> diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
> index a9f50ee..f6375db 100644
> --- a/net/ipv4/tcp_output.c
> +++ b/net/ipv4/tcp_output.c
> @@ -2567,7 +2567,7 @@ begin_fwd:
> if (skb == tcp_write_queue_head(sk))
> inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS,
> inet_csk(sk)->icsk_rto,
> - TCP_RTO_MAX);
> + sysctl_tcp_rto_max);
> }
> }
> @@ -2885,7 +2885,7 @@ void tcp_connect_init(struct sock *sk)
> tp->rcv_wup = tp->rcv_nxt;
> tp->copied_seq = tp->rcv_nxt;
> - inet_csk(sk)->icsk_rto = TCP_TIMEOUT_INIT;
> + inet_csk(sk)->icsk_rto = sysctl_tcp_timeout_init;
> inet_csk(sk)->icsk_retransmits = 0;
> tcp_clear_retrans(tp);
> }
> @@ -3034,7 +3034,7 @@ int tcp_connect(struct sock *sk)
> /* Timer for repeating the SYN until an answer. */
> inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS,
> - inet_csk(sk)->icsk_rto, TCP_RTO_MAX);
> + inet_csk(sk)->icsk_rto, sysctl_tcp_rto_max);
> return 0;
> }
> EXPORT_SYMBOL(tcp_connect);
> @@ -3055,7 +3055,7 @@ void tcp_send_delayed_ack(struct sock *sk)
> if (icsk->icsk_ack.pingpong ||
> (icsk->icsk_ack.pending & ICSK_ACK_PUSHED))
> - max_ato = TCP_DELACK_MAX;
> + max_ato = sysctl_tcp_delack_max;
> /* Slow path, intersegment interval is "high". */
> @@ -3064,7 +3064,7 @@ void tcp_send_delayed_ack(struct sock *sk)
> * directly.
> */
> if (tp->srtt) {
> - int rtt = max(tp->srtt >> 3, TCP_DELACK_MIN);
> + int rtt = max(tp->srtt >> 3, sysctl_tcp_delack_min);
> if (rtt < max_ato)
> max_ato = rtt;
> @@ -3111,9 +3111,9 @@ void tcp_send_ack(struct sock *sk)
> buff = alloc_skb(MAX_TCP_HEADER, sk_gfp_atomic(sk, GFP_ATOMIC));
> if (buff == NULL) {
> inet_csk_schedule_ack(sk);
> - inet_csk(sk)->icsk_ack.ato = TCP_ATO_MIN;
> + inet_csk(sk)->icsk_ack.ato = sysctl_tcp_ato_min;
> inet_csk_reset_xmit_timer(sk, ICSK_TIME_DACK,
> - TCP_DELACK_MAX, TCP_RTO_MAX);
> + sysctl_tcp_delack_max, sysctl_tcp_rto_max);
> return;
> }
> @@ -3234,8 +3234,8 @@ void tcp_send_probe0(struct sock *sk)
> icsk->icsk_backoff++;
> icsk->icsk_probes_out++;
> inet_csk_reset_xmit_timer(sk, ICSK_TIME_PROBE0,
> - min(icsk->icsk_rto << icsk->icsk_backoff, TCP_RTO_MAX),
> - TCP_RTO_MAX);
> + min(icsk->icsk_rto << icsk->icsk_backoff, sysctl_tcp_rto_max),
> + sysctl_tcp_rto_max);
> } else {
> /* If packet was not sent due to local congestion,
> * do not backoff and do not remember icsk_probes_out.
> @@ -3248,6 +3248,6 @@ void tcp_send_probe0(struct sock *sk)
> inet_csk_reset_xmit_timer(sk, ICSK_TIME_PROBE0,
> min(icsk->icsk_rto << icsk->icsk_backoff,
> TCP_RESOURCE_PROBE_INTERVAL),
> - TCP_RTO_MAX);
> + sysctl_tcp_rto_max);
> }
> }
> diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
> index b78aac3..c5b35de 100644
> --- a/net/ipv4/tcp_timer.c
> +++ b/net/ipv4/tcp_timer.c
> @@ -31,6 +31,20 @@ int sysctl_tcp_retries1 __read_mostly = TCP_RETR1;
> int sysctl_tcp_retries2 __read_mostly = TCP_RETR2;
> int sysctl_tcp_orphan_retries __read_mostly;
> int sysctl_tcp_thin_linear_timeouts __read_mostly;
> +int sysctl_tcp_timeout_init __read_mostly = TCP_TIMEOUT_INIT;
> +EXPORT_SYMBOL(sysctl_tcp_timeout_init);
> +int sysctl_tcp_rto_min __read_mostly = TCP_RTO_MIN;
> +EXPORT_SYMBOL(sysctl_tcp_rto_min);
> +int sysctl_tcp_rto_max __read_mostly = TCP_RTO_MAX;
> +EXPORT_SYMBOL(sysctl_tcp_rto_max);
> +int sysctl_tcp_delack_min __read_mostly = TCP_DELACK_MIN;
> +EXPORT_SYMBOL(sysctl_tcp_delack_min);
> +int sysctl_tcp_delack_max __read_mostly = TCP_DELACK_MAX;
> +EXPORT_SYMBOL(sysctl_tcp_delack_max);
> +int sysctl_tcp_ato_min __read_mostly = TCP_ATO_MIN;
> +EXPORT_SYMBOL(sysctl_tcp_ato_min);
> +int sysctl_tcp_synq_interval __read_mostly = TCP_SYNQ_INTERVAL;
> +EXPORT_SYMBOL(sysctl_tcp_synq_interval);
> static void tcp_write_err(struct sock *sk)
> {
> @@ -59,7 +73,7 @@ static int tcp_out_of_resources(struct sock *sk, int
> do_reset)
> /* If peer does not open window for long time, or did not transmit
> * anything for long time, penalize it. */
> - if ((s32)(tcp_time_stamp - tp->lsndtime) > 2*TCP_RTO_MAX || !do_reset)
> + if ((s32)(tcp_time_stamp - tp->lsndtime) > 2*sysctl_tcp_rto_max ||
> !do_reset)
> shift++;
> /* If some dubious ICMP arrived, penalize even more. */
> @@ -121,7 +135,7 @@ static void tcp_mtu_probing(struct
> inet_connection_sock *icsk, struct sock *sk)
> /* This function calculates a "timeout" which is equivalent to the
> timeout of a
> * TCP connection after "boundary" unsuccessful, exponentially backed-off
> - * retransmissions with an initial RTO of TCP_RTO_MIN or
> TCP_TIMEOUT_INIT if
> + * retransmissions with an initial RTO of sysctl_tcp_rto_min or
> sysctl_tcp_timeout_init if
> * syn_set flag is set.
> */
> static bool retransmits_timed_out(struct sock *sk,
> @@ -130,7 +144,7 @@ static bool retransmits_timed_out(struct sock *sk,
> bool syn_set)
> {
> unsigned int linear_backoff_thresh, start_ts;
> - unsigned int rto_base = syn_set ? TCP_TIMEOUT_INIT : TCP_RTO_MIN;
> + unsigned int rto_base = syn_set ? sysctl_tcp_timeout_init :
> sysctl_tcp_rto_min;
> if (!inet_csk(sk)->icsk_retransmits)
> return false;
> @@ -141,13 +155,13 @@ static bool retransmits_timed_out(struct sock *sk,
> start_ts = tcp_sk(sk)->retrans_stamp;
> if (likely(timeout == 0)) {
> - linear_backoff_thresh = ilog2(TCP_RTO_MAX/rto_base);
> + linear_backoff_thresh = ilog2(sysctl_tcp_rto_max/rto_base);
> if (boundary <= linear_backoff_thresh)
> timeout = ((2 << boundary) - 1) * rto_base;
> else
> timeout = ((2 << linear_backoff_thresh) - 1) * rto_base +
> - (boundary - linear_backoff_thresh) * TCP_RTO_MAX;
> + (boundary - linear_backoff_thresh) * sysctl_tcp_rto_max;
> }
> return (tcp_time_stamp - start_ts) >= timeout;
> }
> @@ -174,7 +188,7 @@ static int tcp_write_timeout(struct sock *sk)
> retry_until = sysctl_tcp_retries2;
> if (sock_flag(sk, SOCK_DEAD)) {
> - const int alive = (icsk->icsk_rto < TCP_RTO_MAX);
> + const int alive = (icsk->icsk_rto < sysctl_tcp_rto_max);
> retry_until = tcp_orphan_retries(sk, alive);
> do_reset = alive ||
> @@ -230,7 +244,7 @@ void tcp_delack_timer_handler(struct sock *sk)
> * deflate ATO.
> */
> icsk->icsk_ack.pingpong = 0;
> - icsk->icsk_ack.ato = TCP_ATO_MIN;
> + icsk->icsk_ack.ato = sysctl_tcp_ato_min;
> }
> tcp_send_ack(sk);
> NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_DELAYEDACKS);
> @@ -288,7 +302,7 @@ static void tcp_probe_timer(struct sock *sk)
> max_probes = sysctl_tcp_retries2;
> if (sock_flag(sk, SOCK_DEAD)) {
> - const int alive = ((icsk->icsk_rto << icsk->icsk_backoff) < TCP_RTO_MAX);
> + const int alive = ((icsk->icsk_rto << icsk->icsk_backoff) <
> sysctl_tcp_rto_max);
> max_probes = tcp_orphan_retries(sk, alive);
> @@ -383,7 +397,7 @@ void tcp_retransmit_timer(struct sock *sk)
> tp->snd_una, tp->snd_nxt);
> }
> #endif
> - if (tcp_time_stamp - tp->rcv_tstamp > TCP_RTO_MAX) {
> + if (tcp_time_stamp - tp->rcv_tstamp > sysctl_tcp_rto_max) {
> tcp_write_err(sk);
> goto out;
> }
> @@ -432,7 +446,7 @@ void tcp_retransmit_timer(struct sock *sk)
> icsk->icsk_retransmits = 1;
> inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS,
> min(icsk->icsk_rto, TCP_RESOURCE_PROBE_INTERVAL),
> - TCP_RTO_MAX);
> + sysctl_tcp_rto_max);
> goto out;
> }
> @@ -469,12 +483,12 @@ out_reset_timer:
> tcp_stream_is_thin(tp) &&
> icsk->icsk_retransmits <= TCP_THIN_LINEAR_RETRIES) {
> icsk->icsk_backoff = 0;
> - icsk->icsk_rto = min(__tcp_set_rto(tp), TCP_RTO_MAX);
> + icsk->icsk_rto = min(__tcp_set_rto(tp), sysctl_tcp_rto_max);
> } else {
> /* Use normal (exponential) backoff */
> - icsk->icsk_rto = min(icsk->icsk_rto << 1, TCP_RTO_MAX);
> + icsk->icsk_rto = min(icsk->icsk_rto << 1, sysctl_tcp_rto_max);
> }
> - inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS, icsk->icsk_rto,
> TCP_RTO_MAX);
> + inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS, icsk->icsk_rto,
> sysctl_tcp_rto_max);
> if (retransmits_timed_out(sk, sysctl_tcp_retries1 + 1, 0, 0))
> __sk_dst_reset(sk);
> @@ -532,8 +546,8 @@ static void tcp_write_timer(unsigned long data)
> static void tcp_synack_timer(struct sock *sk)
> {
> - inet_csk_reqsk_queue_prune(sk, TCP_SYNQ_INTERVAL,
> - TCP_TIMEOUT_INIT, TCP_RTO_MAX);
> + inet_csk_reqsk_queue_prune(sk, sysctl_tcp_synq_interval,
> + sysctl_tcp_timeout_init, sysctl_tcp_rto_max);
> }
> void tcp_syn_ack_timeout(struct sock *sk, struct request_sock *req)
> diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
> index 89dfedd..ab68733 100644
> --- a/net/ipv6/tcp_ipv6.c
> +++ b/net/ipv6/tcp_ipv6.c
> @@ -1111,7 +1111,7 @@ have_isn:
> tcp_rsk(req)->snt_synack = tcp_time_stamp;
> tcp_rsk(req)->listener = NULL;
> - inet6_csk_reqsk_queue_hash_add(sk, req, TCP_TIMEOUT_INIT);
> + inet6_csk_reqsk_queue_hash_add(sk, req, sysctl_tcp_timeout_init);
> return 0;
> drop_and_release:

-- 
WBR, Denis Zaitsev
SRE, Yandex
