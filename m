From: "=?UTF-8?q?Bendik=20R=C3=B8nning=20Opstad?=" <bro.devel@gmail.com>
Subject: [PATCH RFC net-next 1/2] tcp: Add DPIFL thin stream detection mechanism
Date: Fri, 23 Oct 2015 22:50:12 +0200
Message-ID: <1445633413-3532-2-git-send-email-bro.devel+kernel@gmail.com>
References: <1445633413-3532-1-git-send-email-bro.devel+kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <edumazet@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Tom Herbert <tom@herbertland.com>,
	Yuchung Cheng <ycheng@google.com>,
	Paolo Abeni <pabeni@redhat.com>, Erik Kline <ek@google.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Al Viro <viro@zeniv.linux.org.uk>,
	Jiri Pirko <jiri@resnulli.us>,
	Alexander Duyck <alexander.h.duyck@redhat.com>,
	Florian Westphal <fw@strlen.de>,
	Daniel Lee <Longinus00@gmail.com>,
	Marcelo Ricardo Leitner <mleitner@redhat.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Willem de Bruijn <willemb@google.com>,
	=?UTF-8?q?Linus=20L=C3=BCssing?= <linus.luessing@c0d3.blue>,
	linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-api@vger.kernel.org,
	Andreas Petlund <apetlund@simula.no>,
	Carsten Griwodz <griff@simula.no>,
	=?UTF-8?q?P=C3=A5l=20Halvorsen?= <paalh@simula.no>,
	Jonas Markussen <j
To: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Jonathan Corbet <corbet@lwn.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f65.google.com ([209.85.215.65]:33078 "EHLO
	mail-lf0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752341AbbJWUzk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2015 16:55:40 -0400
In-Reply-To: <1445633413-3532-1-git-send-email-bro.devel+kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The existing mechanism for detecting thin streams (tcp_stream_is_thin)
is based on a static limit of less than 4 packets in flight. This treat=
s
streams differently depending on the connections RTT, such that a strea=
m
on a high RTT link may never be considered thin, whereas the same
application would produce a stream that would always be thin in a low R=
TT
scenario (e.g. data center).

By calculating a dynamic packets in flight limit (DPIFL), the thin stre=
am
detection will be independent of the RTT and treat streams equally base=
d
on the transmission pattern, i.e. the inter-transmission time (ITT).

Cc: Andreas Petlund <apetlund@simula.no>
Cc: Carsten Griwodz <griff@simula.no>
Cc: P=C3=A5l Halvorsen <paalh@simula.no>
Cc: Jonas Markussen <jonassm@ifi.uio.no>
Cc: Kristian Evensen <kristian.evensen@gmail.com>
Cc: Kenneth Klette Jonassen <kennetkl@ifi.uio.no>
Signed-off-by: Bendik R=C3=B8nning Opstad <bro.devel+kernel@gmail.com>
---
 Documentation/networking/ip-sysctl.txt |  8 ++++++++
 include/linux/tcp.h                    |  6 ++++++
 include/net/tcp.h                      | 20 ++++++++++++++++++++
 net/ipv4/sysctl_net_ipv4.c             |  9 +++++++++
 net/ipv4/tcp.c                         |  3 +++
 5 files changed, 46 insertions(+)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/net=
working/ip-sysctl.txt
index 85752c8..b841a76 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -700,6 +700,14 @@ tcp_thin_dupack - BOOLEAN
 	Documentation/networking/tcp-thin.txt
 	Default: 0
=20
+tcp_thin_dpifl_itt_lower_bound - INTEGER
+	Controls the lower bound for ITT (inter-transmission time) threshold
+	for when a stream is considered thin. The value is specified in
+	microseconds, and may not be lower than 10000 (10 ms). This theshold
+	is used to calculate a dynamic packets in flight limit (DPIFL) which
+	is used to classify whether a stream is thin.
+	Default: 10000
+
 tcp_limit_output_bytes - INTEGER
 	Controls TCP Small Queue limit per tcp socket.
 	TCP bulk sender tends to increase packets in flight until it
diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index c906f45..fc885db 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -269,6 +269,12 @@ struct tcp_sock {
 	struct sk_buff* lost_skb_hint;
 	struct sk_buff *retransmit_skb_hint;
=20
+	/* The limit used to identify when a stream is thin based in a minimu=
m
+	 * allowed inter-transmission time (ITT) in microseconds. This is use=
d
+	 * to dynamically calculate a max packets in flight limit (DPIFL).
+	*/
+	int thin_dpifl_itt_lower_bound;
+
 	/* OOO segments go in this list. Note that socket lock must be held,
 	 * as we do not use sk_buff_head lock.
 	 */
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 4fc457b..6534836 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -215,6 +215,7 @@ void tcp_time_wait(struct sock *sk, int state, int =
timeo);
=20
 /* TCP thin-stream limits */
 #define TCP_THIN_LINEAR_RETRIES 6       /* After 6 linear retries, do =
exp. backoff */
+#define TCP_THIN_DPIFL_ITT_LOWER_BOUND_MIN 10000  /* Minimum lower bou=
nd is 10 ms (10000 usec) */
=20
 /* TCP initial congestion window as per draft-hkchu-tcpm-initcwnd-01 *=
/
 #define TCP_INIT_CWND		10
@@ -274,6 +275,7 @@ extern int sysctl_tcp_workaround_signed_windows;
 extern int sysctl_tcp_slow_start_after_idle;
 extern int sysctl_tcp_thin_linear_timeouts;
 extern int sysctl_tcp_thin_dupack;
+extern int sysctl_tcp_thin_dpifl_itt_lower_bound;
 extern int sysctl_tcp_early_retrans;
 extern int sysctl_tcp_limit_output_bytes;
 extern int sysctl_tcp_challenge_ack_limit;
@@ -1631,6 +1633,24 @@ static inline bool tcp_stream_is_thin(struct tcp=
_sock *tp)
 	return tp->packets_out < 4 && !tcp_in_initial_slowstart(tp);
 }
=20
+/**
+ * tcp_stream_is_thin_dpifl() - Tests if the stream is thin based on d=
ynamic PIF
+ *                              limit
+ * @tp: the tcp_sock struct
+ *
+ * Return: true if current packets in flight (PIF) count is lower than
+ *         the dynamic PIF limit, else false
+ */
+static inline bool tcp_stream_is_thin_dpifl(const struct tcp_sock *tp)
+{
+	u64 dpif_lim =3D tp->srtt_us >> 3;
+	/* Div by is_thin_min_itt_lim, the minimum allowed ITT
+	 * (Inter-transmission time) in usecs.
+	 */
+	do_div(dpif_lim, tp->thin_dpifl_itt_lower_bound);
+	return tcp_packets_in_flight(tp) < dpif_lim;
+}
+
 /* /proc */
 enum tcp_seq_states {
 	TCP_SEQ_STATE_LISTENING,
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 25300c5..917fdde 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -42,6 +42,7 @@ static int tcp_syn_retries_min =3D 1;
 static int tcp_syn_retries_max =3D MAX_TCP_SYNCNT;
 static int ip_ping_group_range_min[] =3D { 0, 0 };
 static int ip_ping_group_range_max[] =3D { GID_T_MAX, GID_T_MAX };
+static int tcp_thin_dpifl_itt_lower_bound_min =3D TCP_THIN_DPIFL_ITT_L=
OWER_BOUND_MIN;
=20
 /* Update system visible IP port range */
 static void set_local_port_range(struct net *net, int range[2])
@@ -709,6 +710,14 @@ static struct ctl_table ipv4_table[] =3D {
 		.proc_handler   =3D proc_dointvec
 	},
 	{
+		.procname	=3D "tcp_thin_dpifl_itt_lower_bound",
+		.data		=3D &sysctl_tcp_thin_dpifl_itt_lower_bound,
+		.maxlen		=3D sizeof(int),
+		.mode		=3D 0644,
+		.proc_handler	=3D &proc_dointvec_minmax,
+		.extra1		=3D &tcp_thin_dpifl_itt_lower_bound_min,
+	},
+	{
 		.procname	=3D "tcp_early_retrans",
 		.data		=3D &sysctl_tcp_early_retrans,
 		.maxlen		=3D sizeof(int),
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 0cfa7c0..f712d7c 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -287,6 +287,8 @@ int sysctl_tcp_min_tso_segs __read_mostly =3D 2;
=20
 int sysctl_tcp_autocorking __read_mostly =3D 1;
=20
+int sysctl_tcp_thin_dpifl_itt_lower_bound __read_mostly =3D TCP_THIN_D=
PIFL_ITT_LOWER_BOUND_MIN;
+
 struct percpu_counter tcp_orphan_count;
 EXPORT_SYMBOL_GPL(tcp_orphan_count);
=20
@@ -406,6 +408,7 @@ void tcp_init_sock(struct sock *sk)
 	u64_stats_init(&tp->syncp);
=20
 	tp->reordering =3D sysctl_tcp_reordering;
+	tp->thin_dpifl_itt_lower_bound =3D sysctl_tcp_thin_dpifl_itt_lower_bo=
und;
 	tcp_enable_early_retrans(tp);
 	tcp_assign_congestion_control(sk);
=20
--=20
1.9.1
