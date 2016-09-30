From: Lawrence Brakmo <brakmo@fb.com>
Subject: Re: [PATCH v4 net-next 16/16] tcp_bbr: add BBR congestion control
Date: Fri, 30 Sep 2016 15:42:32 +0000
Message-ID: <D413D39F.1F57C%brakmo@fb.com>
References: <1474342763-16715-1-git-send-email-ncardwell@google.com>
 <1474342763-16715-17-git-send-email-ncardwell@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Van Jacobson <vanj@google.com>,
        Yuchung Cheng <ycheng@google.com>,
        Nandita Dukkipati <nanditad@google.com>,
        Eric Dumazet <edumazet@google.com>,
        "Soheil Hassas Yeganeh" <soheil@google.com>
To: Neal Cardwell <ncardwell@google.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:48613 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S932839AbcI3Pmk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 30 Sep 2016 11:42:40 -0400
In-Reply-To: <1474342763-16715-17-git-send-email-ncardwell@google.com>
Content-Language: en-US
Content-ID: <7F588461FDD917408852C67933C10F4D@namprd15.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I ran some BBR tests under different scenarios and I am concerned that
under some conditions BBR can become very aggressive. It seems BBR flows
can decide that losses are un-correlated to congestion, and when in this
mode, they will maintain large cwnds regardless of the losses. In cases
when BBR is wrong, it will starve non-BBR flows sharing the bottleneck. Im
some of my tests even some BBR flows were starved when some flows got into
this mode and others didn=B9t.

I posted the report here:
https://drive.google.com/open?id=3D0B4YZ_0yTgbJEa21CbUVLWFdrX2c

- Lawrence

On 9/19/16, 8:39 PM, "netdev-owner@vger.kernel.org on behalf of Neal
Cardwell" <netdev-owner@vger.kernel.org on behalf of ncardwell@google.com>
wrote:

>This commit implements a new TCP congestion control algorithm: BBR
>(Bottleneck Bandwidth and RTT). A detailed description of BBR will be
>published in ACM Queue, Vol. 14 No. 5, September-October 2016, as
>"BBR: Congestion-Based Congestion Control".
>
>BBR has significantly increased throughput and reduced latency for
>connections on Google's internal backbone networks and google.com and
>YouTube Web servers.
>
>BBR requires only changes on the sender side, not in the network or
>the receiver side. Thus it can be incrementally deployed on today's
>Internet, or in datacenters.
>
>The Internet has predominantly used loss-based congestion control
>(largely Reno or CUBIC) since the 1980s, relying on packet loss as the
>signal to slow down. While this worked well for many years, loss-based
>congestion control is unfortunately out-dated in today's networks. On
>today's Internet, loss-based congestion control causes the infamous
>bufferbloat problem, often causing seconds of needless queuing delay,
>since it fills the bloated buffers in many last-mile links. On today's
>high-speed long-haul links using commodity switches with shallow
>buffers, loss-based congestion control has abysmal throughput because
>it over-reacts to losses caused by transient traffic bursts.
>
>In 1981 Kleinrock and Gale showed that the optimal operating point for
>a network maximizes delivered bandwidth while minimizing delay and
>loss, not only for single connections but for the network as a
>whole. Finding that optimal operating point has been elusive, since
>any single network measurement is ambiguous: network measurements are
>the result of both bandwidth and propagation delay, and those two
>cannot be measured simultaneously.
>
>While it is impossible to disambiguate any single bandwidth or RTT
>measurement, a connection's behavior over time tells a clearer
>story. BBR uses a measurement strategy designed to resolve this
>ambiguity. It combines these measurements with a robust servo loop
>using recent control systems advances to implement a distributed
>congestion control algorithm that reacts to actual congestion, not
>packet loss or transient queue delay, and is designed to converge with
>high probability to a point near the optimal operating point.
>
>In a nutshell, BBR creates an explicit model of the network pipe by
>sequentially probing the bottleneck bandwidth and RTT. On the arrival
>of each ACK, BBR derives the current delivery rate of the last round
>trip, and feeds it through a windowed max-filter to estimate the
>bottleneck bandwidth. Conversely it uses a windowed min-filter to
>estimate the round trip propagation delay. The max-filtered bandwidth
>and min-filtered RTT estimates form BBR's model of the network pipe.
>
>Using its model, BBR sets control parameters to govern sending
>behavior. The primary control is the pacing rate: BBR applies a gain
>multiplier to transmit faster or slower than the observed bottleneck
>bandwidth. The conventional congestion window (cwnd) is now the
>secondary control; the cwnd is set to a small multiple of the
>estimated BDP (bandwidth-delay product) in order to allow full
>utilization and bandwidth probing while bounding the potential amount
>of queue at the bottleneck.
>
>When a BBR connection starts, it enters STARTUP mode and applies a
>high gain to perform an exponential search to quickly probe the
>bottleneck bandwidth (doubling its sending rate each round trip, like
>slow start). However, instead of continuing until it fills up the
>buffer (i.e. a loss), or until delay or ACK spacing reaches some
>threshold (like Hystart), it uses its model of the pipe to estimate
>when that pipe is full: it estimates the pipe is full when it notices
>the estimated bandwidth has stopped growing. At that point it exits
>STARTUP and enters DRAIN mode, where it reduces its pacing rate to
>drain the queue it estimates it has created.
>
>Then BBR enters steady state. In steady state, PROBE_BW mode cycles
>between first pacing faster to probe for more bandwidth, then pacing
>slower to drain any queue that created if no more bandwidth was
>available, and then cruising at the estimated bandwidth to utilize the
>pipe without creating excess queue. Occasionally, on an as-needed
>basis, it sends significantly slower to probe for RTT (PROBE_RTT
>mode).
>
>BBR has been fully deployed on Google's wide-area backbone networks
>and we're experimenting with BBR on Google.com and YouTube on a global
>scale.  Replacing CUBIC with BBR has resulted in significant
>improvements in network latency and application (RPC, browser, and
>video) metrics. For more details please refer to our upcoming ACM
>Queue publication.
>
>Example performance results, to illustrate the difference between BBR
>and CUBIC:
>
>Resilience to random loss (e.g. from shallow buffers):
>  Consider a netperf TCP_STREAM test lasting 30 secs on an emulated
>  path with a 10Gbps bottleneck, 100ms RTT, and 1% packet loss
>  rate. CUBIC gets 3.27 Mbps, and BBR gets 9150 Mbps (2798x higher).
>
>Low latency with the bloated buffers common in today's last-mile links:
>  Consider a netperf TCP_STREAM test lasting 120 secs on an emulated
>  path with a 10Mbps bottleneck, 40ms RTT, and 1000-packet bottleneck
>  buffer. Both fully utilize the bottleneck bandwidth, but BBR
>  achieves this with a median RTT 25x lower (43 ms instead of 1.09
>  secs).
>
>Our long-term goal is to improve the congestion control algorithms
>used on the Internet. We are hopeful that BBR can help advance the
>efforts toward this goal, and motivate the community to do further
>research.
>
>Test results, performance evaluations, feedback, and BBR-related
>discussions are very welcome in the public e-mail list for BBR:
>
> =20
>https://urldefense.proofpoint.com/v2/url?u=3Dhttps-3A__groups.google.com_f=
or
>um_-23-21forum_bbr-2Ddev&d=3DDQIBAg&c=3D5VD0RTtNlTh3ycd41b3MUw&r=3Dpq_Mqvz=
fy-C8l
>tkgyx1u_g&m=3DxV8BAzDZSWNmi4irvSU7Cnf_stojC7Qv3TSqkxYzMK0&s=3DmWB9nxnt76UW=
KkpT
>0cioXxwy06b0evTHGgwlI3STNCI&e=3D
>
>NOTE: BBR *must* be used with the fq qdisc ("man tc-fq") with pacing
>enabled, since pacing is integral to the BBR design and
>implementation. BBR without pacing would not function properly, and
>may incur unnecessary high packet loss rates.
>
>Signed-off-by: Van Jacobson <vanj@google.com>
>Signed-off-by: Neal Cardwell <ncardwell@google.com>
>Signed-off-by: Yuchung Cheng <ycheng@google.com>
>Signed-off-by: Nandita Dukkipati <nanditad@google.com>
>Signed-off-by: Eric Dumazet <edumazet@google.com>
>Signed-off-by: Soheil Hassas Yeganeh <soheil@google.com>
>---
> include/uapi/linux/inet_diag.h |  13 +
> net/ipv4/Kconfig               |  18 +
> net/ipv4/Makefile              |   1 +
> net/ipv4/tcp_bbr.c             | 896
>+++++++++++++++++++++++++++++++++++++++++
> 4 files changed, 928 insertions(+)
> create mode 100644 net/ipv4/tcp_bbr.c
>
>diff --git a/include/uapi/linux/inet_diag.h
>b/include/uapi/linux/inet_diag.h
>index b5c366f..509cd96 100644
>--- a/include/uapi/linux/inet_diag.h
>+++ b/include/uapi/linux/inet_diag.h
>@@ -124,6 +124,7 @@ enum {
> 	INET_DIAG_PEERS,
> 	INET_DIAG_PAD,
> 	INET_DIAG_MARK,
>+	INET_DIAG_BBRINFO,
> 	__INET_DIAG_MAX,
> };
>=20
>@@ -157,8 +158,20 @@ struct tcp_dctcp_info {
> 	__u32	dctcp_ab_tot;
> };
>=20
>+/* INET_DIAG_BBRINFO */
>+
>+struct tcp_bbr_info {
>+	/* u64 bw: max-filtered BW (app throughput) estimate in Byte per sec: */
>+	__u32	bbr_bw_lo;		/* lower 32 bits of bw */
>+	__u32	bbr_bw_hi;		/* upper 32 bits of bw */
>+	__u32	bbr_min_rtt;		/* min-filtered RTT in uSec */
>+	__u32	bbr_pacing_gain;	/* pacing gain shifted left 8 bits */
>+	__u32	bbr_cwnd_gain;		/* cwnd gain shifted left 8 bits */
>+};
>+
> union tcp_cc_info {
> 	struct tcpvegas_info	vegas;
> 	struct tcp_dctcp_info	dctcp;
>+	struct tcp_bbr_info	bbr;
> };
> #endif /* _UAPI_INET_DIAG_H_ */
>diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
>index 50d6a9b..300b068 100644
>--- a/net/ipv4/Kconfig
>+++ b/net/ipv4/Kconfig
>@@ -640,6 +640,21 @@ config TCP_CONG_CDG
> 	  D.A. Hayes and G. Armitage. "Revisiting TCP congestion control using
> 	  delay gradients." In Networking 2011. Preprint:
>https://urldefense.proofpoint.com/v2/url?u=3Dhttp-3A__goo.gl_No3vdg&d=3DDQ=
IBAg
>&c=3D5VD0RTtNlTh3ycd41b3MUw&r=3Dpq_Mqvzfy-C8ltkgyx1u_g&m=3DxV8BAzDZSWNmi4i=
rvSU7C
>nf_stojC7Qv3TSqkxYzMK0&s=3DcVqj8M0_43G6FqE2LfEGLAe5pfUieb8_YYe2TquWgSA&e=
=3D
>=20
>+config TCP_CONG_BBR
>+	tristate "BBR TCP"
>+	default n
>+	---help---
>+
>+	BBR (Bottleneck Bandwidth and RTT) TCP congestion control aims to
>+	maximize network utilization and minimize queues. It builds an explicit
>+	model of the the bottleneck delivery rate and path round-trip
>+	propagation delay. It tolerates packet loss and delay unrelated to
>+	congestion. It can operate over LAN, WAN, cellular, wifi, or cable
>+	modem links. It can coexist with flows that use loss-based congestion
>+	control, and can operate with shallow buffers, deep buffers,
>+	bufferbloat, policers, or AQM schemes that do not provide a delay
>+	signal. It requires the fq ("Fair Queue") pacing packet scheduler.
>+
> choice
> 	prompt "Default TCP congestion control"
> 	default DEFAULT_CUBIC
>@@ -674,6 +689,9 @@ choice
> 	config DEFAULT_CDG
> 		bool "CDG" if TCP_CONG_CDG=3Dy
>=20
>+	config DEFAULT_BBR
>+		bool "BBR" if TCP_CONG_BBR=3Dy
>+
> 	config DEFAULT_RENO
> 		bool "Reno"
> endchoice
>diff --git a/net/ipv4/Makefile b/net/ipv4/Makefile
>index 9cfff1a..bc6a6c8 100644
>--- a/net/ipv4/Makefile
>+++ b/net/ipv4/Makefile
>@@ -41,6 +41,7 @@ obj-$(CONFIG_INET_DIAG) +=3D inet_diag.o
> obj-$(CONFIG_INET_TCP_DIAG) +=3D tcp_diag.o
> obj-$(CONFIG_INET_UDP_DIAG) +=3D udp_diag.o
> obj-$(CONFIG_NET_TCPPROBE) +=3D tcp_probe.o
>+obj-$(CONFIG_TCP_CONG_BBR) +=3D tcp_bbr.o
> obj-$(CONFIG_TCP_CONG_BIC) +=3D tcp_bic.o
> obj-$(CONFIG_TCP_CONG_CDG) +=3D tcp_cdg.o
> obj-$(CONFIG_TCP_CONG_CUBIC) +=3D tcp_cubic.o
>diff --git a/net/ipv4/tcp_bbr.c b/net/ipv4/tcp_bbr.c
>new file mode 100644
>index 0000000..0ea66c2
>--- /dev/null
>+++ b/net/ipv4/tcp_bbr.c
>@@ -0,0 +1,896 @@
>+/* Bottleneck Bandwidth and RTT (BBR) congestion control
>+ *
>+ * BBR congestion control computes the sending rate based on the delivery
>+ * rate (throughput) estimated from ACKs. In a nutshell:
>+ *
>+ *   On each ACK, update our model of the network path:
>+ *      bottleneck_bandwidth =3D windowed_max(delivered / elapsed, 10
>round trips)
>+ *      min_rtt =3D windowed_min(rtt, 10 seconds)
>+ *   pacing_rate =3D pacing_gain * bottleneck_bandwidth
>+ *   cwnd =3D max(cwnd_gain * bottleneck_bandwidth * min_rtt, 4)
>+ *
>+ * The core algorithm does not react directly to packet losses or delays,
>+ * although BBR may adjust the size of next send per ACK when loss is
>+ * observed, or adjust the sending rate if it estimates there is a
>+ * traffic policer, in order to keep the drop rate reasonable.
>+ *
>+ * BBR is described in detail in:
>+ *   "BBR: Congestion-Based Congestion Control",
>+ *   Neal Cardwell, Yuchung Cheng, C. Stephen Gunn, Soheil Hassas
>Yeganeh,
>+ *   Van Jacobson. ACM Queue, Vol. 14 No. 5, September-October 2016.
>+ *
>+ * There is a public e-mail list for discussing BBR development and
>testing:
>+ *  =20
>https://urldefense.proofpoint.com/v2/url?u=3Dhttps-3A__groups.google.com_f=
or
>um_-23-21forum_bbr-2Ddev&d=3DDQIBAg&c=3D5VD0RTtNlTh3ycd41b3MUw&r=3Dpq_Mqvz=
fy-C8l
>tkgyx1u_g&m=3DxV8BAzDZSWNmi4irvSU7Cnf_stojC7Qv3TSqkxYzMK0&s=3DmWB9nxnt76UW=
KkpT
>0cioXxwy06b0evTHGgwlI3STNCI&e=3D
>+ *
>+ * NOTE: BBR *must* be used with the fq qdisc ("man tc-fq") with pacing
>enabled,
>+ * since pacing is integral to the BBR design and implementation.
>+ * BBR without pacing would not function properly, and may incur
>unnecessary
>+ * high packet loss rates.
>+ */
>+#include <linux/module.h>
>+#include <net/tcp.h>
>+#include <linux/inet_diag.h>
>+#include <linux/inet.h>
>+#include <linux/random.h>
>+#include <linux/win_minmax.h>
>+
>+/* Scale factor for rate in pkt/uSec unit to avoid truncation in
>bandwidth
>+ * estimation. The rate unit ~=3D (1500 bytes / 1 usec / 2^24) ~=3D 715 b=
ps.
>+ * This handles bandwidths from 0.06pps (715bps) to 256Mpps (3Tbps) in a
>u32.
>+ * Since the minimum window is >=3D4 packets, the lower bound isn't
>+ * an issue. The upper bound isn't an issue with existing technologies.
>+ */
>+#define BW_SCALE 24
>+#define BW_UNIT (1 << BW_SCALE)
>+
>+#define BBR_SCALE 8	/* scaling factor for fractions in BBR (e.g. gains)
>*/
>+#define BBR_UNIT (1 << BBR_SCALE)
>+
>+/* BBR has the following modes for deciding how fast to send: */
>+enum bbr_mode {
>+	BBR_STARTUP,	/* ramp up sending rate rapidly to fill pipe */
>+	BBR_DRAIN,	/* drain any queue created during startup */
>+	BBR_PROBE_BW,	/* discover, share bw: pace around estimated bw */
>+	BBR_PROBE_RTT,	/* cut cwnd to min to probe min_rtt */
>+};
>+
>+/* BBR congestion control block */
>+struct bbr {
>+	u32	min_rtt_us;	        /* min RTT in min_rtt_win_sec window */
>+	u32	min_rtt_stamp;	        /* timestamp of min_rtt_us */
>+	u32	probe_rtt_done_stamp;   /* end time for BBR_PROBE_RTT mode */
>+	struct minmax bw;	/* Max recent delivery rate in pkts/uS << 24 */
>+	u32	rtt_cnt;	    /* count of packet-timed rounds elapsed */
>+	u32     next_rtt_delivered; /* scb->tx.delivered at end of round */
>+	struct skb_mstamp cycle_mstamp;  /* time of this cycle phase start */
>+	u32     mode:3,		     /* current bbr_mode in state machine */
>+		prev_ca_state:3,     /* CA state on previous ACK */
>+		packet_conservation:1,  /* use packet conservation? */
>+		restore_cwnd:1,	     /* decided to revert cwnd to old value */
>+		round_start:1,	     /* start of packet-timed tx->ack round? */
>+		tso_segs_goal:7,     /* segments we want in each skb we send */
>+		idle_restart:1,	     /* restarting after idle? */
>+		probe_rtt_round_done:1,  /* a BBR_PROBE_RTT round at 4 pkts? */
>+		unused:5,
>+		lt_is_sampling:1,    /* taking long-term ("LT") samples now? */
>+		lt_rtt_cnt:7,	     /* round trips in long-term interval */
>+		lt_use_bw:1;	     /* use lt_bw as our bw estimate? */
>+	u32	lt_bw;		     /* LT est delivery rate in pkts/uS << 24 */
>+	u32	lt_last_delivered;   /* LT intvl start: tp->delivered */
>+	u32	lt_last_stamp;	     /* LT intvl start: tp->delivered_mstamp */
>+	u32	lt_last_lost;	     /* LT intvl start: tp->lost */
>+	u32	pacing_gain:10,	/* current gain for setting pacing rate */
>+		cwnd_gain:10,	/* current gain for setting cwnd */
>+		full_bw_cnt:3,	/* number of rounds without large bw gains */
>+		cycle_idx:3,	/* current index in pacing_gain cycle array */
>+		unused_b:6;
>+	u32	prior_cwnd;	/* prior cwnd upon entering loss recovery */
>+	u32	full_bw;	/* recent bw, to estimate if pipe is full */
>+};
>+
>+#define CYCLE_LEN	8	/* number of phases in a pacing gain cycle */
>+
>+/* Window length of bw filter (in rounds): */
>+static const int bbr_bw_rtts =3D CYCLE_LEN + 2;
>+/* Window length of min_rtt filter (in sec): */
>+static const u32 bbr_min_rtt_win_sec =3D 10;
>+/* Minimum time (in ms) spent at bbr_cwnd_min_target in BBR_PROBE_RTT
>mode: */
>+static const u32 bbr_probe_rtt_mode_ms =3D 200;
>+/* Skip TSO below the following bandwidth (bits/sec): */
>+static const int bbr_min_tso_rate =3D 1200000;
>+
>+/* We use a high_gain value of 2/ln(2) because it's the smallest pacing
>gain
>+ * that will allow a smoothly increasing pacing rate that will double
>each RTT
>+ * and send the same number of packets per RTT that an un-paced,
>slow-starting
>+ * Reno or CUBIC flow would:
>+ */
>+static const int bbr_high_gain  =3D BBR_UNIT * 2885 / 1000 + 1;
>+/* The pacing gain of 1/high_gain in BBR_DRAIN is calculated to
>typically drain
>+ * the queue created in BBR_STARTUP in a single round:
>+ */
>+static const int bbr_drain_gain =3D BBR_UNIT * 1000 / 2885;
>+/* The gain for deriving steady-state cwnd tolerates delayed/stretched
>ACKs: */
>+static const int bbr_cwnd_gain  =3D BBR_UNIT * 2;
>+/* The pacing_gain values for the PROBE_BW gain cycle, to discover/share
>bw: */
>+static const int bbr_pacing_gain[] =3D {
>+	BBR_UNIT * 5 / 4,	/* probe for more available bw */
>+	BBR_UNIT * 3 / 4,	/* drain queue and/or yield bw to other flows */
>+	BBR_UNIT, BBR_UNIT, BBR_UNIT,	/* cruise at 1.0*bw to utilize pipe, */
>+	BBR_UNIT, BBR_UNIT, BBR_UNIT	/* without creating excess queue... */
>+};
>+/* Randomize the starting gain cycling phase over N phases: */
>+static const u32 bbr_cycle_rand =3D 7;
>+
>+/* Try to keep at least this many packets in flight, if things go
>smoothly. For
>+ * smooth functioning, a sliding window protocol ACKing every other
>packet
>+ * needs at least 4 packets in flight:
>+ */
>+static const u32 bbr_cwnd_min_target =3D 4;
>+
>+/* To estimate if BBR_STARTUP mode (i.e. high_gain) has filled pipe... */
>+/* If bw has increased significantly (1.25x), there may be more bw
>available: */
>+static const u32 bbr_full_bw_thresh =3D BBR_UNIT * 5 / 4;
>+/* But after 3 rounds w/o significant bw growth, estimate pipe is full:
>*/
>+static const u32 bbr_full_bw_cnt =3D 3;
>+
>+/* "long-term" ("LT") bandwidth estimator parameters... */
>+/* The minimum number of rounds in an LT bw sampling interval: */
>+static const u32 bbr_lt_intvl_min_rtts =3D 4;
>+/* If lost/delivered ratio > 20%, interval is "lossy" and we may be
>policed: */
>+static const u32 bbr_lt_loss_thresh =3D 50;
>+/* If 2 intervals have a bw ratio <=3D 1/8, their bw is "consistent": */
>+static const u32 bbr_lt_bw_ratio =3D BBR_UNIT / 8;
>+/* If 2 intervals have a bw diff <=3D 4 Kbit/sec their bw is "consistent"=
:
>*/
>+static const u32 bbr_lt_bw_diff =3D 4000 / 8;
>+/* If we estimate we're policed, use lt_bw for this many round trips: */
>+static const u32 bbr_lt_bw_max_rtts =3D 48;
>+
>+/* Do we estimate that STARTUP filled the pipe? */
>+static bool bbr_full_bw_reached(const struct sock *sk)
>+{
>+	const struct bbr *bbr =3D inet_csk_ca(sk);
>+
>+	return bbr->full_bw_cnt >=3D bbr_full_bw_cnt;
>+}
>+
>+/* Return the windowed max recent bandwidth sample, in pkts/uS <<
>BW_SCALE. */
>+static u32 bbr_max_bw(const struct sock *sk)
>+{
>+	struct bbr *bbr =3D inet_csk_ca(sk);
>+
>+	return minmax_get(&bbr->bw);
>+}
>+
>+/* Return the estimated bandwidth of the path, in pkts/uS << BW_SCALE. */
>+static u32 bbr_bw(const struct sock *sk)
>+{
>+	struct bbr *bbr =3D inet_csk_ca(sk);
>+
>+	return bbr->lt_use_bw ? bbr->lt_bw : bbr_max_bw(sk);
>+}
>+
>+/* Return rate in bytes per second, optionally with a gain.
>+ * The order here is chosen carefully to avoid overflow of u64. This
>should
>+ * work for input rates of up to 2.9Tbit/sec and gain of 2.89x.
>+ */
>+static u64 bbr_rate_bytes_per_sec(struct sock *sk, u64 rate, int gain)
>+{
>+	rate *=3D tcp_mss_to_mtu(sk, tcp_sk(sk)->mss_cache);
>+	rate *=3D gain;
>+	rate >>=3D BBR_SCALE;
>+	rate *=3D USEC_PER_SEC;
>+	return rate >> BW_SCALE;
>+}
>+
>+/* Pace using current bw estimate and a gain factor. In order to help
>drive the
>+ * network toward lower queues while maintaining high utilization and low
>+ * latency, the average pacing rate aims to be slightly (~1%) lower than
>the
>+ * estimated bandwidth. This is an important aspect of the design. In
>this
>+ * implementation this slightly lower pacing rate is achieved implicitly
>by not
>+ * including link-layer headers in the packet size used for the pacing
>rate.
>+ */
>+static void bbr_set_pacing_rate(struct sock *sk, u32 bw, int gain)
>+{
>+	struct bbr *bbr =3D inet_csk_ca(sk);
>+	u64 rate =3D bw;
>+
>+	rate =3D bbr_rate_bytes_per_sec(sk, rate, gain);
>+	rate =3D min_t(u64, rate, sk->sk_max_pacing_rate);
>+	if (bbr->mode !=3D BBR_STARTUP || rate > sk->sk_pacing_rate)
>+		sk->sk_pacing_rate =3D rate;
>+}
>+
>+/* Return count of segments we want in the skbs we send, or 0 for
>default. */
>+static u32 bbr_tso_segs_goal(struct sock *sk)
>+{
>+	struct bbr *bbr =3D inet_csk_ca(sk);
>+
>+	return bbr->tso_segs_goal;
>+}
>+
>+static void bbr_set_tso_segs_goal(struct sock *sk)
>+{
>+	struct tcp_sock *tp =3D tcp_sk(sk);
>+	struct bbr *bbr =3D inet_csk_ca(sk);
>+	u32 min_segs;
>+
>+	min_segs =3D sk->sk_pacing_rate < (bbr_min_tso_rate >> 3) ? 1 : 2;
>+	bbr->tso_segs_goal =3D min(tcp_tso_autosize(sk, tp->mss_cache, min_segs)=
,
>+				 0x7FU);
>+}
>+
>+/* Save "last known good" cwnd so we can restore it after losses or
>PROBE_RTT */
>+static void bbr_save_cwnd(struct sock *sk)
>+{
>+	struct tcp_sock *tp =3D tcp_sk(sk);
>+	struct bbr *bbr =3D inet_csk_ca(sk);
>+
>+	if (bbr->prev_ca_state < TCP_CA_Recovery && bbr->mode !=3D BBR_PROBE_RTT=
)
>+		bbr->prior_cwnd =3D tp->snd_cwnd;  /* this cwnd is good enough */
>+	else  /* loss recovery or BBR_PROBE_RTT have temporarily cut cwnd */
>+		bbr->prior_cwnd =3D max(bbr->prior_cwnd, tp->snd_cwnd);
>+}
>+
>+static void bbr_cwnd_event(struct sock *sk, enum tcp_ca_event event)
>+{
>+	struct tcp_sock *tp =3D tcp_sk(sk);
>+	struct bbr *bbr =3D inet_csk_ca(sk);
>+
>+	if (event =3D=3D CA_EVENT_TX_START && tp->app_limited) {
>+		bbr->idle_restart =3D 1;
>+		/* Avoid pointless buffer overflows: pace at est. bw if we don't
>+		 * need more speed (we're restarting from idle and app-limited).
>+		 */
>+		if (bbr->mode =3D=3D BBR_PROBE_BW)
>+			bbr_set_pacing_rate(sk, bbr_bw(sk), BBR_UNIT);
>+	}
>+}
>+
>+/* Find target cwnd. Right-size the cwnd based on min RTT and the
>+ * estimated bottleneck bandwidth:
>+ *
>+ * cwnd =3D bw * min_rtt * gain =3D BDP * gain
>+ *
>+ * The key factor, gain, controls the amount of queue. While a small gain
>+ * builds a smaller queue, it becomes more vulnerable to noise in RTT
>+ * measurements (e.g., delayed ACKs or other ACK compression effects).
>This
>+ * noise may cause BBR to under-estimate the rate.
>+ *
>+ * To achieve full performance in high-speed paths, we budget enough
>cwnd to
>+ * fit full-sized skbs in-flight on both end hosts to fully utilize the
>path:
>+ *   - one skb in sending host Qdisc,
>+ *   - one skb in sending host TSO/GSO engine
>+ *   - one skb being received by receiver host LRO/GRO/delayed-ACK engine
>+ * Don't worry, at low rates (bbr_min_tso_rate) this won't bloat cwnd
>because
>+ * in such cases tso_segs_goal is 1. The minimum cwnd is 4 packets,
>+ * which allows 2 outstanding 2-packet sequences, to try to keep pipe
>+ * full even with ACK-every-other-packet delayed ACKs.
>+ */
>+static u32 bbr_target_cwnd(struct sock *sk, u32 bw, int gain)
>+{
>+	struct bbr *bbr =3D inet_csk_ca(sk);
>+	u32 cwnd;
>+	u64 w;
>+
>+	/* If we've never had a valid RTT sample, cap cwnd at the initial
>+	 * default. This should only happen when the connection is not using TCP
>+	 * timestamps and has retransmitted all of the SYN/SYNACK/data packets
>+	 * ACKed so far. In this case, an RTO can cut cwnd to 1, in which
>+	 * case we need to slow-start up toward something safe: TCP_INIT_CWND.
>+	 */
>+	if (unlikely(bbr->min_rtt_us =3D=3D ~0U))	 /* no valid RTT samples yet? =
*/
>+		return TCP_INIT_CWND;  /* be safe: cap at default initial cwnd*/
>+
>+	w =3D (u64)bw * bbr->min_rtt_us;
>+
>+	/* Apply a gain to the given value, then remove the BW_SCALE shift. */
>+	cwnd =3D (((w * gain) >> BBR_SCALE) + BW_UNIT - 1) / BW_UNIT;
>+
>+	/* Allow enough full-sized skbs in flight to utilize end systems. */
>+	cwnd +=3D 3 * bbr->tso_segs_goal;
>+
>+	/* Reduce delayed ACKs by rounding up cwnd to the next even number. */
>+	cwnd =3D (cwnd + 1) & ~1U;
>+
>+	return cwnd;
>+}
>+
>+/* An optimization in BBR to reduce losses: On the first round of
>recovery, we
>+ * follow the packet conservation principle: send P packets per P
>packets acked.
>+ * After that, we slow-start and send at most 2*P packets per P packets
>acked.
>+ * After recovery finishes, or upon undo, we restore the cwnd we had when
>+ * recovery started (capped by the target cwnd based on estimated BDP).
>+ *
>+ * TODO(ycheng/ncardwell): implement a rate-based approach.
>+ */
>+static bool bbr_set_cwnd_to_recover_or_restore(
>+	struct sock *sk, const struct rate_sample *rs, u32 acked, u32 *new_cwnd)
>+{
>+	struct tcp_sock *tp =3D tcp_sk(sk);
>+	struct bbr *bbr =3D inet_csk_ca(sk);
>+	u8 prev_state =3D bbr->prev_ca_state, state =3D inet_csk(sk)->icsk_ca_st=
ate;
>+	u32 cwnd =3D tp->snd_cwnd;
>+
>+	/* An ACK for P pkts should release at most 2*P packets. We do this
>+	 * in two steps. First, here we deduct the number of lost packets.
>+	 * Then, in bbr_set_cwnd() we slow start up toward the target cwnd.
>+	 */
>+	if (rs->losses > 0)
>+		cwnd =3D max_t(s32, cwnd - rs->losses, 1);
>+
>+	if (state =3D=3D TCP_CA_Recovery && prev_state !=3D TCP_CA_Recovery) {
>+		/* Starting 1st round of Recovery, so do packet conservation. */
>+		bbr->packet_conservation =3D 1;
>+		bbr->next_rtt_delivered =3D tp->delivered;  /* start round now */
>+		/* Cut unused cwnd from app behavior, TSQ, or TSO deferral: */
>+		cwnd =3D tcp_packets_in_flight(tp) + acked;
>+	} else if (prev_state >=3D TCP_CA_Recovery && state < TCP_CA_Recovery) {
>+		/* Exiting loss recovery; restore cwnd saved before recovery. */
>+		bbr->restore_cwnd =3D 1;
>+		bbr->packet_conservation =3D 0;
>+	}
>+	bbr->prev_ca_state =3D state;
>+
>+	if (bbr->restore_cwnd) {
>+		/* Restore cwnd after exiting loss recovery or PROBE_RTT. */
>+		cwnd =3D max(cwnd, bbr->prior_cwnd);
>+		bbr->restore_cwnd =3D 0;
>+	}
>+
>+	if (bbr->packet_conservation) {
>+		*new_cwnd =3D max(cwnd, tcp_packets_in_flight(tp) + acked);
>+		return true;	/* yes, using packet conservation */
>+	}
>+	*new_cwnd =3D cwnd;
>+	return false;
>+}
>+
>+/* Slow-start up toward target cwnd (if bw estimate is growing, or
>packet loss
>+ * has drawn us down below target), or snap down to target if we're
>above it.
>+ */
>+static void bbr_set_cwnd(struct sock *sk, const struct rate_sample *rs,
>+			 u32 acked, u32 bw, int gain)
>+{
>+	struct tcp_sock *tp =3D tcp_sk(sk);
>+	struct bbr *bbr =3D inet_csk_ca(sk);
>+	u32 cwnd =3D 0, target_cwnd =3D 0;
>+
>+	if (!acked)
>+		return;
>+
>+	if (bbr_set_cwnd_to_recover_or_restore(sk, rs, acked, &cwnd))
>+		goto done;
>+
>+	/* If we're below target cwnd, slow start cwnd toward target cwnd. */
>+	target_cwnd =3D bbr_target_cwnd(sk, bw, gain);
>+	if (bbr_full_bw_reached(sk))  /* only cut cwnd if we filled the pipe */
>+		cwnd =3D min(cwnd + acked, target_cwnd);
>+	else if (cwnd < target_cwnd || tp->delivered < TCP_INIT_CWND)
>+		cwnd =3D cwnd + acked;
>+	cwnd =3D max(cwnd, bbr_cwnd_min_target);
>+
>+done:
>+	tp->snd_cwnd =3D min(cwnd, tp->snd_cwnd_clamp);	/* apply global cap */
>+	if (bbr->mode =3D=3D BBR_PROBE_RTT)  /* drain queue, refresh min_rtt */
>+		tp->snd_cwnd =3D min(tp->snd_cwnd, bbr_cwnd_min_target);
>+}
>+
>+/* End cycle phase if it's time and/or we hit the phase's in-flight
>target. */
>+static bool bbr_is_next_cycle_phase(struct sock *sk,
>+				    const struct rate_sample *rs)
>+{
>+	struct tcp_sock *tp =3D tcp_sk(sk);
>+	struct bbr *bbr =3D inet_csk_ca(sk);
>+	bool is_full_length =3D
>+		skb_mstamp_us_delta(&tp->delivered_mstamp, &bbr->cycle_mstamp) >
>+		bbr->min_rtt_us;
>+	u32 inflight, bw;
>+
>+	/* The pacing_gain of 1.0 paces at the estimated bw to try to fully
>+	 * use the pipe without increasing the queue.
>+	 */
>+	if (bbr->pacing_gain =3D=3D BBR_UNIT)
>+		return is_full_length;		/* just use wall clock time */
>+
>+	inflight =3D rs->prior_in_flight;  /* what was in-flight before ACK? */
>+	bw =3D bbr_max_bw(sk);
>+
>+	/* A pacing_gain > 1.0 probes for bw by trying to raise inflight to at
>+	 * least pacing_gain*BDP; this may take more than min_rtt if min_rtt is
>+	 * small (e.g. on a LAN). We do not persist if packets are lost, since
>+	 * a path with small buffers may not hold that much.
>+	 */
>+	if (bbr->pacing_gain > BBR_UNIT)
>+		return is_full_length &&
>+			(rs->losses ||  /* perhaps pacing_gain*BDP won't fit */
>+			 inflight >=3D bbr_target_cwnd(sk, bw, bbr->pacing_gain));
>+
>+	/* A pacing_gain < 1.0 tries to drain extra queue we added if bw
>+	 * probing didn't find more bw. If inflight falls to match BDP then we
>+	 * estimate queue is drained; persisting would underutilize the pipe.
>+	 */
>+	return is_full_length ||
>+		inflight <=3D bbr_target_cwnd(sk, bw, BBR_UNIT);
>+}
>+
>+static void bbr_advance_cycle_phase(struct sock *sk)
>+{
>+	struct tcp_sock *tp =3D tcp_sk(sk);
>+	struct bbr *bbr =3D inet_csk_ca(sk);
>+
>+	bbr->cycle_idx =3D (bbr->cycle_idx + 1) & (CYCLE_LEN - 1);
>+	bbr->cycle_mstamp =3D tp->delivered_mstamp;
>+	bbr->pacing_gain =3D bbr_pacing_gain[bbr->cycle_idx];
>+}
>+
>+/* Gain cycling: cycle pacing gain to converge to fair share of
>available bw. */
>+static void bbr_update_cycle_phase(struct sock *sk,
>+				   const struct rate_sample *rs)
>+{
>+	struct bbr *bbr =3D inet_csk_ca(sk);
>+
>+	if ((bbr->mode =3D=3D BBR_PROBE_BW) && !bbr->lt_use_bw &&
>+	    bbr_is_next_cycle_phase(sk, rs))
>+		bbr_advance_cycle_phase(sk);
>+}
>+
>+static void bbr_reset_startup_mode(struct sock *sk)
>+{
>+	struct bbr *bbr =3D inet_csk_ca(sk);
>+
>+	bbr->mode =3D BBR_STARTUP;
>+	bbr->pacing_gain =3D bbr_high_gain;
>+	bbr->cwnd_gain	 =3D bbr_high_gain;
>+}
>+
>+static void bbr_reset_probe_bw_mode(struct sock *sk)
>+{
>+	struct bbr *bbr =3D inet_csk_ca(sk);
>+
>+	bbr->mode =3D BBR_PROBE_BW;
>+	bbr->pacing_gain =3D BBR_UNIT;
>+	bbr->cwnd_gain =3D bbr_cwnd_gain;
>+	bbr->cycle_idx =3D CYCLE_LEN - 1 - prandom_u32_max(bbr_cycle_rand);
>+	bbr_advance_cycle_phase(sk);	/* flip to next phase of gain cycle */
>+}
>+
>+static void bbr_reset_mode(struct sock *sk)
>+{
>+	if (!bbr_full_bw_reached(sk))
>+		bbr_reset_startup_mode(sk);
>+	else
>+		bbr_reset_probe_bw_mode(sk);
>+}
>+
>+/* Start a new long-term sampling interval. */
>+static void bbr_reset_lt_bw_sampling_interval(struct sock *sk)
>+{
>+	struct tcp_sock *tp =3D tcp_sk(sk);
>+	struct bbr *bbr =3D inet_csk_ca(sk);
>+
>+	bbr->lt_last_stamp =3D tp->delivered_mstamp.stamp_jiffies;
>+	bbr->lt_last_delivered =3D tp->delivered;
>+	bbr->lt_last_lost =3D tp->lost;
>+	bbr->lt_rtt_cnt =3D 0;
>+}
>+
>+/* Completely reset long-term bandwidth sampling. */
>+static void bbr_reset_lt_bw_sampling(struct sock *sk)
>+{
>+	struct bbr *bbr =3D inet_csk_ca(sk);
>+
>+	bbr->lt_bw =3D 0;
>+	bbr->lt_use_bw =3D 0;
>+	bbr->lt_is_sampling =3D false;
>+	bbr_reset_lt_bw_sampling_interval(sk);
>+}
>+
>+/* Long-term bw sampling interval is done. Estimate whether we're
>policed. */
>+static void bbr_lt_bw_interval_done(struct sock *sk, u32 bw)
>+{
>+	struct bbr *bbr =3D inet_csk_ca(sk);
>+	u32 diff;
>+
>+	if (bbr->lt_bw) {  /* do we have bw from a previous interval? */
>+		/* Is new bw close to the lt_bw from the previous interval? */
>+		diff =3D abs(bw - bbr->lt_bw);
>+		if ((diff * BBR_UNIT <=3D bbr_lt_bw_ratio * bbr->lt_bw) ||
>+		    (bbr_rate_bytes_per_sec(sk, diff, BBR_UNIT) <=3D
>+		     bbr_lt_bw_diff)) {
>+			/* All criteria are met; estimate we're policed. */
>+			bbr->lt_bw =3D (bw + bbr->lt_bw) >> 1;  /* avg 2 intvls */
>+			bbr->lt_use_bw =3D 1;
>+			bbr->pacing_gain =3D BBR_UNIT;  /* try to avoid drops */
>+			bbr->lt_rtt_cnt =3D 0;
>+			return;
>+		}
>+	}
>+	bbr->lt_bw =3D bw;
>+	bbr_reset_lt_bw_sampling_interval(sk);
>+}
>+
>+/* Token-bucket traffic policers are common (see "An Internet-Wide
>Analysis of
>+ * Traffic Policing", SIGCOMM 2016). BBR detects token-bucket policers
>and
>+ * explicitly models their policed rate, to reduce unnecessary losses. We
>+ * estimate that we're policed if we see 2 consecutive sampling
>intervals with
>+ * consistent throughput and high packet loss. If we think we're being
>policed,
>+ * set lt_bw to the "long-term" average delivery rate from those 2
>intervals.
>+ */
>+static void bbr_lt_bw_sampling(struct sock *sk, const struct rate_sample
>*rs)
>+{
>+	struct tcp_sock *tp =3D tcp_sk(sk);
>+	struct bbr *bbr =3D inet_csk_ca(sk);
>+	u32 lost, delivered;
>+	u64 bw;
>+	s32 t;
>+
>+	if (bbr->lt_use_bw) {	/* already using long-term rate, lt_bw? */
>+		if (bbr->mode =3D=3D BBR_PROBE_BW && bbr->round_start &&
>+		    ++bbr->lt_rtt_cnt >=3D bbr_lt_bw_max_rtts) {
>+			bbr_reset_lt_bw_sampling(sk);    /* stop using lt_bw */
>+			bbr_reset_probe_bw_mode(sk);  /* restart gain cycling */
>+		}
>+		return;
>+	}
>+
>+	/* Wait for the first loss before sampling, to let the policer exhaust
>+	 * its tokens and estimate the steady-state rate allowed by the policer.
>+	 * Starting samples earlier includes bursts that over-estimate the bw.
>+	 */
>+	if (!bbr->lt_is_sampling) {
>+		if (!rs->losses)
>+			return;
>+		bbr_reset_lt_bw_sampling_interval(sk);
>+		bbr->lt_is_sampling =3D true;
>+	}
>+
>+	/* To avoid underestimates, reset sampling if we run out of data. */
>+	if (rs->is_app_limited) {
>+		bbr_reset_lt_bw_sampling(sk);
>+		return;
>+	}
>+
>+	if (bbr->round_start)
>+		bbr->lt_rtt_cnt++;	/* count round trips in this interval */
>+	if (bbr->lt_rtt_cnt < bbr_lt_intvl_min_rtts)
>+		return;		/* sampling interval needs to be longer */
>+	if (bbr->lt_rtt_cnt > 4 * bbr_lt_intvl_min_rtts) {
>+		bbr_reset_lt_bw_sampling(sk);  /* interval is too long */
>+		return;
>+	}
>+
>+	/* End sampling interval when a packet is lost, so we estimate the
>+	 * policer tokens were exhausted. Stopping the sampling before the
>+	 * tokens are exhausted under-estimates the policed rate.
>+	 */
>+	if (!rs->losses)
>+		return;
>+
>+	/* Calculate packets lost and delivered in sampling interval. */
>+	lost =3D tp->lost - bbr->lt_last_lost;
>+	delivered =3D tp->delivered - bbr->lt_last_delivered;
>+	/* Is loss rate (lost/delivered) >=3D lt_loss_thresh? If not, wait. */
>+	if (!delivered || (lost << BBR_SCALE) < bbr_lt_loss_thresh * delivered)
>+		return;
>+
>+	/* Find average delivery rate in this sampling interval. */
>+	t =3D (s32)(tp->delivered_mstamp.stamp_jiffies - bbr->lt_last_stamp);
>+	if (t < 1)
>+		return;		/* interval is less than one jiffy, so wait */
>+	t =3D jiffies_to_usecs(t);
>+	/* Interval long enough for jiffies_to_usecs() to return a bogus 0? */
>+	if (t < 1) {
>+		bbr_reset_lt_bw_sampling(sk);  /* interval too long; reset */
>+		return;
>+	}
>+	bw =3D (u64)delivered * BW_UNIT;
>+	do_div(bw, t);
>+	bbr_lt_bw_interval_done(sk, bw);
>+}
>+
>+/* Estimate the bandwidth based on how fast packets are delivered */
>+static void bbr_update_bw(struct sock *sk, const struct rate_sample *rs)
>+{
>+	struct tcp_sock *tp =3D tcp_sk(sk);
>+	struct bbr *bbr =3D inet_csk_ca(sk);
>+	u64 bw;
>+
>+	bbr->round_start =3D 0;
>+	if (rs->delivered < 0 || rs->interval_us <=3D 0)
>+		return; /* Not a valid observation */
>+
>+	/* See if we've reached the next RTT */
>+	if (!before(rs->prior_delivered, bbr->next_rtt_delivered)) {
>+		bbr->next_rtt_delivered =3D tp->delivered;
>+		bbr->rtt_cnt++;
>+		bbr->round_start =3D 1;
>+		bbr->packet_conservation =3D 0;
>+	}
>+
>+	bbr_lt_bw_sampling(sk, rs);
>+
>+	/* Divide delivered by the interval to find a (lower bound) bottleneck
>+	 * bandwidth sample. Delivered is in packets and interval_us in uS and
>+	 * ratio will be <<1 for most connections. So delivered is first scaled.
>+	 */
>+	bw =3D (u64)rs->delivered * BW_UNIT;
>+	do_div(bw, rs->interval_us);
>+
>+	/* If this sample is application-limited, it is likely to have a very
>+	 * low delivered count that represents application behavior rather than
>+	 * the available network rate. Such a sample could drag down estimated
>+	 * bw, causing needless slow-down. Thus, to continue to send at the
>+	 * last measured network rate, we filter out app-limited samples unless
>+	 * they describe the path bw at least as well as our bw model.
>+	 *
>+	 * So the goal during app-limited phase is to proceed with the best
>+	 * network rate no matter how long. We automatically leave this
>+	 * phase when app writes faster than the network can deliver :)
>+	 */
>+	if (!rs->is_app_limited || bw >=3D bbr_max_bw(sk)) {
>+		/* Incorporate new sample into our max bw filter. */
>+		minmax_running_max(&bbr->bw, bbr_bw_rtts, bbr->rtt_cnt, bw);
>+	}
>+}
>+
>+/* Estimate when the pipe is full, using the change in delivery rate: BBR
>+ * estimates that STARTUP filled the pipe if the estimated bw hasn't=20
>changed by
>+ * at least bbr_full_bw_thresh (25%) after bbr_full_bw_cnt (3)=20
>non-app-limited
>+ * rounds. Why 3 rounds: 1: rwin autotuning grows the rwin, 2: we fill=20
>the
>+ * higher rwin, 3: we get higher delivery rate samples. Or transient
>+ * cross-traffic or radio noise can go away. CUBIC Hystart shares a=20
>similar
>+ * design goal, but uses delay and inter-ACK spacing instead of=20
>bandwidth.
>+ */
>+static void bbr_check_full_bw_reached(struct sock *sk,
>+				      const struct rate_sample *rs)
>+{
>+	struct bbr *bbr =3D inet_csk_ca(sk);
>+	u32 bw_thresh;
>+
>+	if (bbr_full_bw_reached(sk) || !bbr->round_start || rs->is_app_limited)
>+		return;
>+
>+	bw_thresh =3D (u64)bbr->full_bw * bbr_full_bw_thresh >> BBR_SCALE;
>+	if (bbr_max_bw(sk) >=3D bw_thresh) {
>+		bbr->full_bw =3D bbr_max_bw(sk);
>+		bbr->full_bw_cnt =3D 0;
>+		return;
>+	}
>+	++bbr->full_bw_cnt;
>+}
>+
>+/* If pipe is probably full, drain the queue and then enter=20
>steady-state. */
>+static void bbr_check_drain(struct sock *sk, const struct rate_sample=20
>*rs)
>+{
>+	struct bbr *bbr =3D inet_csk_ca(sk);
>+
>+	if (bbr->mode =3D=3D BBR_STARTUP && bbr_full_bw_reached(sk)) {
>+		bbr->mode =3D BBR_DRAIN;	/* drain queue we created */
>+		bbr->pacing_gain =3D bbr_drain_gain;	/* pace slow to drain */
>+		bbr->cwnd_gain =3D bbr_high_gain;	/* maintain cwnd */
>+	}	/* fall through to check if in-flight is already small: */
>+	if (bbr->mode =3D=3D BBR_DRAIN &&
>+	    tcp_packets_in_flight(tcp_sk(sk)) <=3D
>+	    bbr_target_cwnd(sk, bbr_max_bw(sk), BBR_UNIT))
>+		bbr_reset_probe_bw_mode(sk);  /* we estimate queue is drained */
>+}
>+
>+/* The goal of PROBE_RTT mode is to have BBR flows cooperatively and
>+ * periodically drain the bottleneck queue, to converge to measure the=20
>true
>+ * min_rtt (unloaded propagation delay). This allows the flows to keep=20
>queues
>+ * small (reducing queuing delay and packet loss) and achieve fairness=20
>among
>+ * BBR flows.
>+ *
>+ * The min_rtt filter window is 10 seconds. When the min_rtt estimate=20
>expires,
>+ * we enter PROBE_RTT mode and cap the cwnd at bbr_cwnd_min_target=3D4=20
>packets.
>+ * After at least bbr_probe_rtt_mode_ms=3D200ms and at least one=20
>packet-timed
>+ * round trip elapsed with that flight size <=3D 4, we leave PROBE_RTT=20
>mode and
>+ * re-enter the previous mode. BBR uses 200ms to approximately bound the
>+ * performance penalty of PROBE_RTT's cwnd capping to roughly 2%=20
>(200ms/10s).
>+ *
>+ * Note that flows need only pay 2% if they are busy sending over the=20
>last 10
>+ * seconds. Interactive applications (e.g., Web, RPCs, video chunks)=20
>often have
>+ * natural silences or low-rate periods within 10 seconds where the rate=
=20
>is low
>+ * enough for long enough to drain its queue in the bottleneck. We pick=20
>up
>+ * these min RTT measurements opportunistically with our min_rtt filter.=
=20
>:-)
>+ */
>+static void bbr_update_min_rtt(struct sock *sk, const struct rate_sample=
=20
>*rs)
>+{
>+	struct tcp_sock *tp =3D tcp_sk(sk);
>+	struct bbr *bbr =3D inet_csk_ca(sk);
>+	bool filter_expired;
>+
>+	/* Track min RTT seen in the min_rtt_win_sec filter window: */
>+	filter_expired =3D after(tcp_time_stamp,
>+			       bbr->min_rtt_stamp + bbr_min_rtt_win_sec * HZ);
>+	if (rs->rtt_us >=3D 0 &&
>+	    (rs->rtt_us <=3D bbr->min_rtt_us || filter_expired)) {
>+		bbr->min_rtt_us =3D rs->rtt_us;
>+		bbr->min_rtt_stamp =3D tcp_time_stamp;
>+	}
>+
>+	if (bbr_probe_rtt_mode_ms > 0 && filter_expired &&
>+	    !bbr->idle_restart && bbr->mode !=3D BBR_PROBE_RTT) {
>+		bbr->mode =3D BBR_PROBE_RTT;  /* dip, drain queue */
>+		bbr->pacing_gain =3D BBR_UNIT;
>+		bbr->cwnd_gain =3D BBR_UNIT;
>+		bbr_save_cwnd(sk);  /* note cwnd so we can restore it */
>+		bbr->probe_rtt_done_stamp =3D 0;
>+	}
>+
>+	if (bbr->mode =3D=3D BBR_PROBE_RTT) {
>+		/* Ignore low rate samples during this mode. */
>+		tp->app_limited =3D
>+			(tp->delivered + tcp_packets_in_flight(tp)) ? : 1;
>+		/* Maintain min packets in flight for max(200 ms, 1 round). */
>+		if (!bbr->probe_rtt_done_stamp &&
>+		    tcp_packets_in_flight(tp) <=3D bbr_cwnd_min_target) {
>+			bbr->probe_rtt_done_stamp =3D tcp_time_stamp +
>+				msecs_to_jiffies(bbr_probe_rtt_mode_ms);
>+			bbr->probe_rtt_round_done =3D 0;
>+			bbr->next_rtt_delivered =3D tp->delivered;
>+		} else if (bbr->probe_rtt_done_stamp) {
>+			if (bbr->round_start)
>+				bbr->probe_rtt_round_done =3D 1;
>+			if (bbr->probe_rtt_round_done &&
>+			    after(tcp_time_stamp, bbr->probe_rtt_done_stamp)) {
>+				bbr->min_rtt_stamp =3D tcp_time_stamp;
>+				bbr->restore_cwnd =3D 1;  /* snap to prior_cwnd */
>+				bbr_reset_mode(sk);
>+			}
>+		}
>+	}
>+	bbr->idle_restart =3D 0;
>+}
>+
>+static void bbr_update_model(struct sock *sk, const struct rate_sample=20
>*rs)
>+{
>+	bbr_update_bw(sk, rs);
>+	bbr_update_cycle_phase(sk, rs);
>+	bbr_check_full_bw_reached(sk, rs);
>+	bbr_check_drain(sk, rs);
>+	bbr_update_min_rtt(sk, rs);
>+}
>+
>+static void bbr_main(struct sock *sk, const struct rate_sample *rs)
>+{
>+	struct bbr *bbr =3D inet_csk_ca(sk);
>+	u32 bw;
>+
>+	bbr_update_model(sk, rs);
>+
>+	bw =3D bbr_bw(sk);
>+	bbr_set_pacing_rate(sk, bw, bbr->pacing_gain);
>+	bbr_set_tso_segs_goal(sk);
>+	bbr_set_cwnd(sk, rs, rs->acked_sacked, bw, bbr->cwnd_gain);
>+}
>+
>+static void bbr_init(struct sock *sk)
>+{
>+	struct tcp_sock *tp =3D tcp_sk(sk);
>+	struct bbr *bbr =3D inet_csk_ca(sk);
>+	u64 bw;
>+
>+	bbr->prior_cwnd =3D 0;
>+	bbr->tso_segs_goal =3D 0;	 /* default segs per skb until first ACK */
>+	bbr->rtt_cnt =3D 0;
>+	bbr->next_rtt_delivered =3D 0;
>+	bbr->prev_ca_state =3D TCP_CA_Open;
>+	bbr->packet_conservation =3D 0;
>+
>+	bbr->probe_rtt_done_stamp =3D 0;
>+	bbr->probe_rtt_round_done =3D 0;
>+	bbr->min_rtt_us =3D tcp_min_rtt(tp);
>+	bbr->min_rtt_stamp =3D tcp_time_stamp;
>+
>+	minmax_reset(&bbr->bw, bbr->rtt_cnt, 0);  /* init max bw to 0 */
>+
>+	/* Initialize pacing rate to: high_gain * init_cwnd / RTT. */
>+	bw =3D (u64)tp->snd_cwnd * BW_UNIT;
>+	do_div(bw, (tp->srtt_us >> 3) ? : USEC_PER_MSEC);
>+	sk->sk_pacing_rate =3D 0;		/* force an update of sk_pacing_rate */
>+	bbr_set_pacing_rate(sk, bw, bbr_high_gain);
>+
>+	bbr->restore_cwnd =3D 0;
>+	bbr->round_start =3D 0;
>+	bbr->idle_restart =3D 0;
>+	bbr->full_bw =3D 0;
>+	bbr->full_bw_cnt =3D 0;
>+	bbr->cycle_mstamp.v64 =3D 0;
>+	bbr->cycle_idx =3D 0;
>+	bbr_reset_lt_bw_sampling(sk);
>+	bbr_reset_startup_mode(sk);
>+}
>+
>+static u32 bbr_sndbuf_expand(struct sock *sk)
>+{
>+	/* Provision 3 * cwnd since BBR may slow-start even during recovery. */
>+	return 3;
>+}
>+
>+/* In theory BBR does not need to undo the cwnd since it does not
>+ * always reduce cwnd on losses (see bbr_main()). Keep it for now.
>+ */
>+static u32 bbr_undo_cwnd(struct sock *sk)
>+{
>+	return tcp_sk(sk)->snd_cwnd;
>+}
>+
>+/* Entering loss recovery, so save cwnd for when we exit or undo=20
>recovery. */
>+static u32 bbr_ssthresh(struct sock *sk)
>+{
>+	bbr_save_cwnd(sk);
>+	return TCP_INFINITE_SSTHRESH;	 /* BBR does not use ssthresh */
>+}
>+
>+static size_t bbr_get_info(struct sock *sk, u32 ext, int *attr,
>+			   union tcp_cc_info *info)
>+{
>+	if (ext & (1 << (INET_DIAG_BBRINFO - 1)) ||
>+	    ext & (1 << (INET_DIAG_VEGASINFO - 1))) {
>+		struct tcp_sock *tp =3D tcp_sk(sk);
>+		struct bbr *bbr =3D inet_csk_ca(sk);
>+		u64 bw =3D bbr_bw(sk);
>+
>+		bw =3D bw * tp->mss_cache * USEC_PER_SEC >> BW_SCALE;
>+		memset(&info->bbr, 0, sizeof(info->bbr));
>+		info->bbr.bbr_bw_lo		=3D (u32)bw;
>+		info->bbr.bbr_bw_hi		=3D (u32)(bw >> 32);
>+		info->bbr.bbr_min_rtt		=3D bbr->min_rtt_us;
>+		info->bbr.bbr_pacing_gain	=3D bbr->pacing_gain;
>+		info->bbr.bbr_cwnd_gain		=3D bbr->cwnd_gain;
>+		*attr =3D INET_DIAG_BBRINFO;
>+		return sizeof(info->bbr);
>+	}
>+	return 0;
>+}
>+
>+static void bbr_set_state(struct sock *sk, u8 new_state)
>+{
>+	struct bbr *bbr =3D inet_csk_ca(sk);
>+
>+	if (new_state =3D=3D TCP_CA_Loss) {
>+		struct rate_sample rs =3D { .losses =3D 1 };
>+
>+		bbr->prev_ca_state =3D TCP_CA_Loss;
>+		bbr->full_bw =3D 0;
>+		bbr->round_start =3D 1;	/* treat RTO like end of a round */
>+		bbr_lt_bw_sampling(sk, &rs);
>+	}
>+}
>+
>+static struct tcp_congestion_ops tcp_bbr_cong_ops __read_mostly =3D {
>+	.flags		=3D TCP_CONG_NON_RESTRICTED,
>+	.name		=3D "bbr",
>+	.owner		=3D THIS_MODULE,
>+	.init		=3D bbr_init,
>+	.cong_control	=3D bbr_main,
>+	.sndbuf_expand	=3D bbr_sndbuf_expand,
>+	.undo_cwnd	=3D bbr_undo_cwnd,
>+	.cwnd_event	=3D bbr_cwnd_event,
>+	.ssthresh	=3D bbr_ssthresh,
>+	.tso_segs_goal	=3D bbr_tso_segs_goal,
>+	.get_info	=3D bbr_get_info,
>+	.set_state	=3D bbr_set_state,
>+};
>+
>+static int __init bbr_register(void)
>+{
>+	BUILD_BUG_ON(sizeof(struct bbr) > ICSK_CA_PRIV_SIZE);
>+	return tcp_register_congestion_control(&tcp_bbr_cong_ops);
>+}
>+
>+static void __exit bbr_unregister(void)
>+{
>+	tcp_unregister_congestion_control(&tcp_bbr_cong_ops);
>+}
>+
>+module_init(bbr_register);
>+module_exit(bbr_unregister);
>+
>+MODULE_AUTHOR("Van Jacobson <vanj@google.com>");
>+MODULE_AUTHOR("Neal Cardwell <ncardwell@google.com>");
>+MODULE_AUTHOR("Yuchung Cheng <ycheng@google.com>");
>+MODULE_AUTHOR("Soheil Hassas Yeganeh <soheil@google.com>");
>+MODULE_LICENSE("Dual BSD/GPL");
>+MODULE_DESCRIPTION("TCP BBR (Bottleneck Bandwidth and RTT)");
>--=20
>2.8.0.rc3.226.g39d4020
>
