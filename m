From: "=?UTF-8?q?Bendik=20R=C3=B8nning=20Opstad?=" <bro.devel@gmail.com>
Subject: [PATCH v3 net-next 1/2] tcp: Add DPIFL thin stream detection mechanism
Date: Tue,  2 Feb 2016 20:23:14 +0100
Message-ID: <1454440995-18457-2-git-send-email-bro.devel+kernel@gmail.com>
References: <1454440995-18457-1-git-send-email-bro.devel+kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Yuchung Cheng <ycheng@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Neal Cardwell <ncardwell@google.com>,
	Andreas Petlund <apetlund@simula.no>,
	Carsten Griwodz <griff@simula.no>,
	=?UTF-8?q?P=C3=A5l=20Halvorsen?= <paalh@simula.no>,
	Jonas Markussen <jonassm@ifi.uio.no>,
	Kristian Evensen <kristian.evensen@gmail.com>,
	Kenneth Klette Jonassen <kennetkl@ifi.uio.no>,
	=?UTF-8?q?Bendik=20R=C3=B8nning=20Opstad?=
	<bro.devel+kernel@gmail.com>
To: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f196.google.com ([209.85.217.196]:33567 "EHLO
	mail-lb0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754079AbcBBTYI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Feb 2016 14:24:08 -0500
Received: by mail-lb0-f196.google.com with SMTP id bc4so7144112lbc.0
        for <netdev@vger.kernel.org>; Tue, 02 Feb 2016 11:24:07 -0800 (PST)
In-Reply-To: <1454440995-18457-1-git-send-email-bro.devel+kernel@gmail.com>
In-Reply-To: <1445633413-3532-1-git-send-email-bro.devel+kernel@gmail.com>
References: <1445633413-3532-1-git-send-email-bro.devel+kernel@gmail.com>
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
 include/net/tcp.h                      | 21 +++++++++++++++++++++
 net/ipv4/sysctl_net_ipv4.c             |  9 +++++++++
 net/ipv4/tcp.c                         |  2 ++
 4 files changed, 40 insertions(+)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/net=
working/ip-sysctl.txt
index 73b36d7..eb42853 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -708,6 +708,14 @@ tcp_thin_dupack - BOOLEAN
 	Documentation/networking/tcp-thin.txt
 	Default: 0
=20
+tcp_thin_dpifl_itt_lower_bound - INTEGER
+	Controls the lower bound inter-transmission time (ITT) threshold
+	for when a stream is considered thin. The value is specified in
+	microseconds, and may not be lower than 10000 (10 ms). Based on
+	this threshold, a dynamic packets in flight limit (DPIFL) is
+	calculated, which is used to classify whether a stream is thin.
+	Default: 10000
+
 tcp_limit_output_bytes - INTEGER
 	Controls TCP Small Queue limit per tcp socket.
 	TCP bulk sender tends to increase packets in flight until it
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 3dd20fe..2d86bd7 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -215,6 +215,8 @@ void tcp_time_wait(struct sock *sk, int state, int =
timeo);
=20
 /* TCP thin-stream limits */
 #define TCP_THIN_LINEAR_RETRIES 6       /* After 6 linear retries, do =
exp. backoff */
+/* Lowest possible DPIFL lower bound ITT is 10 ms (10000 usec) */
+#define TCP_THIN_DPIFL_ITT_LOWER_BOUND_MIN 10000
=20
 /* TCP initial congestion window as per rfc6928 */
 #define TCP_INIT_CWND		10
@@ -271,6 +273,7 @@ extern int sysctl_tcp_workaround_signed_windows;
 extern int sysctl_tcp_slow_start_after_idle;
 extern int sysctl_tcp_thin_linear_timeouts;
 extern int sysctl_tcp_thin_dupack;
+extern int sysctl_tcp_thin_dpifl_itt_lower_bound;
 extern int sysctl_tcp_early_retrans;
 extern int sysctl_tcp_limit_output_bytes;
 extern int sysctl_tcp_challenge_ack_limit;
@@ -1649,6 +1652,24 @@ static inline bool tcp_stream_is_thin(struct tcp=
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
+	/* Calculate the maximum allowed PIF limit by dividing the RTT by
+	 * the minimum allowed inter-transmission time (ITT).
+	 * Tests if PIF < RTT / ITT-lower-bound
+	 */
+	return (u64) tcp_packets_in_flight(tp) *
+		sysctl_tcp_thin_dpifl_itt_lower_bound < (tp->srtt_us >> 3);
+}
+
 /* /proc */
 enum tcp_seq_states {
 	TCP_SEQ_STATE_LISTENING,
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 4d367b4..6014bc4 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -41,6 +41,7 @@ static int tcp_syn_retries_min =3D 1;
 static int tcp_syn_retries_max =3D MAX_TCP_SYNCNT;
 static int ip_ping_group_range_min[] =3D { 0, 0 };
 static int ip_ping_group_range_max[] =3D { GID_T_MAX, GID_T_MAX };
+static int tcp_thin_dpifl_itt_lower_bound_min =3D TCP_THIN_DPIFL_ITT_L=
OWER_BOUND_MIN;
=20
 /* Update system visible IP port range */
 static void set_local_port_range(struct net *net, int range[2])
@@ -687,6 +688,14 @@ static struct ctl_table ipv4_table[] =3D {
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
index 19746b3..16087fe 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -288,6 +288,8 @@ int sysctl_tcp_min_tso_segs __read_mostly =3D 2;
=20
 int sysctl_tcp_autocorking __read_mostly =3D 1;
=20
+int sysctl_tcp_thin_dpifl_itt_lower_bound __read_mostly =3D TCP_THIN_D=
PIFL_ITT_LOWER_BOUND_MIN;
+
 struct percpu_counter tcp_orphan_count;
 EXPORT_SYMBOL_GPL(tcp_orphan_count);
=20
--=20
1.9.1
