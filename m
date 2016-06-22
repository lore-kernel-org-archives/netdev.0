From: "=?UTF-8?q?Bendik=20R=C3=B8nning=20Opstad?=" <bro.devel@gmail.com>
Subject: [PATCH v7 net-next 1/2] tcp: Add DPIFL thin stream detection mechanism
Date: Wed, 22 Jun 2016 16:56:09 +0200
Message-ID: <1466607370-24514-2-git-send-email-bro.devel+kernel@gmail.com>
References: <1466607370-24514-1-git-send-email-bro.devel+kernel@gmail.com>
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
	Kenneth Klette Jonassen <kennetkl@ifi.uio.no>
To: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f65.google.com ([209.85.215.65]:35473 "EHLO
	mail-lf0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752102AbcFVO4S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jun 2016 10:56:18 -0400
Received: by mail-lf0-f65.google.com with SMTP id w130so14233825lfd.2
        for <netdev@vger.kernel.org>; Wed, 22 Jun 2016 07:56:17 -0700 (PDT)
In-Reply-To: <1466607370-24514-1-git-send-email-bro.devel+kernel@gmail.com>
In-Reply-To: <1445633413-3532-1-git-send-email-bro.devel+kernel@gmail.com>
References: <1445633413-3532-1-git-send-email-bro.devel+kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The existing mechanism for detecting thin streams,
tcp_stream_is_thin(), is based on a static limit of less than 4
packets in flight. This treats streams differently depending on the
connection's RTT, such that a stream on a high RTT link may never be
considered thin, whereas the same application would produce a stream
that would always be thin in a low RTT scenario (e.g. data center).

By calculating a dynamic packets in flight limit (DPIFL), the thin
stream detection will be independent of the RTT and treat streams
equally based on the transmission pattern, i.e. the inter-transmission
time (ITT).

Cc: Andreas Petlund <apetlund@simula.no>
Cc: Carsten Griwodz <griff@simula.no>
Cc: P=C3=A5l Halvorsen <paalh@simula.no>
Cc: Jonas Markussen <jonassm@ifi.uio.no>
Cc: Kristian Evensen <kristian.evensen@gmail.com>
Cc: Kenneth Klette Jonassen <kennetkl@ifi.uio.no>
Signed-off-by: Bendik R=C3=B8nning Opstad <bro.devel+kernel@gmail.com>
---
 Documentation/networking/ip-sysctl.txt |  8 ++++++++
 include/net/netns/ipv4.h               |  1 +
 include/net/tcp.h                      | 21 +++++++++++++++++++++
 net/ipv4/sysctl_net_ipv4.c             |  9 +++++++++
 net/ipv4/tcp_ipv4.c                    |  1 +
 5 files changed, 40 insertions(+)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/net=
working/ip-sysctl.txt
index 9ae9293..d856b98 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -718,6 +718,14 @@ tcp_thin_dupack - BOOLEAN
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
diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
index d061ffe..71be4ac 100644
--- a/include/net/netns/ipv4.h
+++ b/include/net/netns/ipv4.h
@@ -111,6 +111,7 @@ struct netns_ipv4 {
 	int sysctl_tcp_orphan_retries;
 	int sysctl_tcp_fin_timeout;
 	unsigned int sysctl_tcp_notsent_lowat;
+	int sysctl_tcp_thin_dpifl_itt_lower_bound;
=20
 	int sysctl_igmp_max_memberships;
 	int sysctl_igmp_max_msf;
diff --git a/include/net/tcp.h b/include/net/tcp.h
index a79894b..9956af9 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -214,6 +214,8 @@ void tcp_time_wait(struct sock *sk, int state, int =
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
@@ -1652,6 +1654,25 @@ static inline bool tcp_stream_is_thin(struct tcp=
_sock *tp)
 	return tp->packets_out < 4 && !tcp_in_initial_slowstart(tp);
 }
=20
+/**
+ * tcp_stream_is_thin_dpifl() - Test if the stream is thin based on
+ *                              dynamic PIF limit (DPIFL)
+ * @sk: socket
+ *
+ * Return: true if current packets in flight (PIF) count is lower than
+ *         the dynamic PIF limit, else false
+ */
+static inline bool tcp_stream_is_thin_dpifl(const struct sock *sk)
+{
+	/* Calculate the maximum allowed PIF limit by dividing the RTT by
+	 * the minimum allowed inter-transmission time (ITT).
+	 * Tests if PIF < RTT / ITT-lower-bound
+	 */
+	return (u64) tcp_packets_in_flight(tcp_sk(sk)) *
+		sock_net(sk)->ipv4.sysctl_tcp_thin_dpifl_itt_lower_bound <
+		(tcp_sk(sk)->srtt_us >> 3);
+}
+
 /* /proc */
 enum tcp_seq_states {
 	TCP_SEQ_STATE_LISTENING,
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 1cb67de..150969d 100644
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
@@ -960,6 +961,14 @@ static struct ctl_table ipv4_net_table[] =3D {
 		.mode		=3D 0644,
 		.proc_handler	=3D proc_dointvec,
 	},
+	{
+		.procname	=3D "tcp_thin_dpifl_itt_lower_bound",
+		.data		=3D &init_net.ipv4.sysctl_tcp_thin_dpifl_itt_lower_bound,
+		.maxlen		=3D sizeof(init_net.ipv4.sysctl_tcp_thin_dpifl_itt_lower_bo=
und),
+		.mode		=3D 0644,
+		.proc_handler	=3D proc_dointvec_minmax,
+		.extra1		=3D &tcp_thin_dpifl_itt_lower_bound_min,
+	},
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
 	{
 		.procname	=3D "fib_multipath_use_neigh",
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 3708de2..4e5e8e6 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -2412,6 +2412,7 @@ static int __net_init tcp_sk_init(struct net *net=
)
 	net->ipv4.sysctl_tcp_orphan_retries =3D 0;
 	net->ipv4.sysctl_tcp_fin_timeout =3D TCP_FIN_TIMEOUT;
 	net->ipv4.sysctl_tcp_notsent_lowat =3D UINT_MAX;
+	net->ipv4.sysctl_tcp_thin_dpifl_itt_lower_bound =3D TCP_THIN_DPIFL_IT=
T_LOWER_BOUND_MIN;
=20
 	return 0;
 fail:
--=20
2.1.4
