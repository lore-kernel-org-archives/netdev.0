From: "=?UTF-8?q?Bendik=20R=C3=B8nning=20Opstad?=" <bro.devel@gmail.com>
Subject: [PATCH v7 net-next 2/2] tcp: Add Redundant Data Bundling (RDB)
Date: Wed, 22 Jun 2016 16:56:10 +0200
Message-ID: <1466607370-24514-3-git-send-email-bro.devel+kernel@gmail.com>
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
Received: from mail-lf0-f65.google.com ([209.85.215.65]:35954 "EHLO
	mail-lf0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752556AbcFVO43 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jun 2016 10:56:29 -0400
Received: by mail-lf0-f65.google.com with SMTP id a2so14205343lfe.3
        for <netdev@vger.kernel.org>; Wed, 22 Jun 2016 07:56:28 -0700 (PDT)
In-Reply-To: <1466607370-24514-1-git-send-email-bro.devel+kernel@gmail.com>
In-Reply-To: <1445633413-3532-1-git-send-email-bro.devel+kernel@gmail.com>
References: <1445633413-3532-1-git-send-email-bro.devel+kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Redundant Data Bundling (RDB) is a mechanism for TCP aimed at reducing
the latency for applications sending time-dependent data.

Latency-sensitive applications or services, such as online games,
remote control systems, and VoIP, produce traffic with thin-stream
characteristics, characterized by small packets and relatively high
inter-transmission times (ITT). When experiencing packet loss, such
latency-sensitive applications are heavily penalized by the need to
retransmit lost packets, which increases the latency by a minimum of
one RTT for the lost packet. Packets coming after a lost packet are
held back due to head-of-line blocking, causing increased delays for
all data segments until the lost packet has been retransmitted.

RDB enables a TCP sender to bundle redundant (already sent) data with
TCP packets containing small segments of new data. By resending
un-ACKed data from the output queue in packets with new data, RDB
reduces the need to retransmit data segments on connections
experiencing sporadic packet loss. By avoiding a retransmit, RDB
evades the latency increase of at least one RTT for the lost packet,
as well as alleviating head-of-line blocking for the packets following
the lost packet. This makes the TCP connection more resistant to
latency fluctuations, and reduces the application layer latency
significantly in lossy environments.

Main functionality added:

  o When a packet is scheduled for transmission, RDB builds and
    transmits a new SKB containing both the unsent data as well as
    data of previously sent packets from the TCP output queue.

  o RDB will only be used for streams classified as thin by the
    function tcp_stream_is_thin_dpifl(). This enforces a lower bound
    on the ITT for streams that may benefit from RDB, controlled by
    the sysctl variable net.ipv4.tcp_thin_dpifl_itt_lower_bound.

  o Loss detection of hidden loss events: When bundling redundant data
    with each packet, packet loss can be hidden from the TCP engine due
    to lack of dupACKs. This is because the loss is "repaired" by the
    redundant data in the packet coming after the lost packet. Based on
    incoming ACKs, such hidden loss events are detected, and CWR state
    is entered.

RDB can be enabled on a connection with the socket option TCP_RDB or
on all new connections by setting the sysctl variable
net.ipv4.tcp_rdb=3D2

Cc: Andreas Petlund <apetlund@simula.no>
Cc: Carsten Griwodz <griff@simula.no>
Cc: P=C3=A5l Halvorsen <paalh@simula.no>
Cc: Jonas Markussen <jonassm@ifi.uio.no>
Cc: Kristian Evensen <kristian.evensen@gmail.com>
Cc: Kenneth Klette Jonassen <kennetkl@ifi.uio.no>
Signed-off-by: Bendik R=C3=B8nning Opstad <bro.devel+kernel@gmail.com>
---
 Documentation/networking/ip-sysctl.txt |  35 +++++
 Documentation/networking/tcp-thin.txt  | 188 ++++++++++++++++++++-----=
-
 include/linux/skbuff.h                 |   1 +
 include/linux/tcp.h                    |  11 +-
 include/net/netns/ipv4.h               |   5 +
 include/net/tcp.h                      |  12 ++
 include/uapi/linux/snmp.h              |   1 +
 include/uapi/linux/tcp.h               |  10 ++
 net/core/skbuff.c                      |   2 +-
 net/ipv4/Makefile                      |   3 +-
 net/ipv4/proc.c                        |   1 +
 net/ipv4/sysctl_net_ipv4.c             |  34 +++++
 net/ipv4/tcp.c                         |  42 +++++-
 net/ipv4/tcp_input.c                   |   3 +
 net/ipv4/tcp_ipv4.c                    |   5 +
 net/ipv4/tcp_output.c                  |  49 ++++---
 net/ipv4/tcp_rdb.c                     | 240 +++++++++++++++++++++++++=
++++++++
 17 files changed, 579 insertions(+), 63 deletions(-)
 create mode 100644 net/ipv4/tcp_rdb.c

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/net=
working/ip-sysctl.txt
index d856b98..d26d12b 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -726,6 +726,41 @@ tcp_thin_dpifl_itt_lower_bound - INTEGER
 	calculated, which is used to classify whether a stream is thin.
 	Default: 10000
=20
+tcp_rdb - BOOLEAN
+	Controls the use of the Redundant Data Bundling (RDB) mechanism
+	for TCP connections.
+
+	RDB is a TCP mechanism aimed at reducing the latency for
+	applications transmitting time-dependent data. By bundling already
+	sent data in packets with new data, RDB alleviates head-of-line
+	blocking on the receiver side by reducing the need to retransmit
+	data segments when packets are lost. See tcp-thin.txt for further
+	details.
+	Possible values:
+	0 - Disable RDB system wide, i.e. disallow enabling RDB on TCP
+	    sockets with the socket option TCP_RDB.
+	1 - Allow enabling/disabling RDB with socket option TCP_RDB.
+	2 - Set RDB to be enabled by default for all new TCP connections
+	    and allow modifying socket with socket option TCP_RDB.
+	Default: 1
+
+tcp_rdb_await_congestion - BOOLEAN
+	Controls whether an RDB-enabled connection, by default, should
+	postpone bundling until congestion has been detected.
+
+tcp_rdb_max_bytes - INTEGER
+	Enable restriction on how many bytes an RDB packet can contain.
+	This is the total amount of payload including the new unsent data.
+	A value of 0 will disable bytes based limitation.
+	Default: 0
+
+tcp_rdb_max_packets - INTEGER
+	Enable restriction on how many previous packets in the output queue
+	RDB may include data from. A value of 1 will restrict bundling to
+	only the data from the last packet that was sent.
+	A value of 0 will disable packet based limitation.
+	Default: 1
+
 tcp_limit_output_bytes - INTEGER
 	Controls TCP Small Queue limit per tcp socket.
 	TCP bulk sender tends to increase packets in flight until it
diff --git a/Documentation/networking/tcp-thin.txt b/Documentation/netw=
orking/tcp-thin.txt
index 151e229..e3752e7 100644
--- a/Documentation/networking/tcp-thin.txt
+++ b/Documentation/networking/tcp-thin.txt
@@ -1,47 +1,159 @@
 Thin-streams and TCP
-=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
+-----------------------
+
 A wide range of Internet-based services that use reliable transport
-protocols display what we call thin-stream properties. This means
-that the application sends data with such a low rate that the
-retransmission mechanisms of the transport protocol are not fully
-effective. In time-dependent scenarios (like online games, control
-systems, stock trading etc.) where the user experience depends
-on the data delivery latency, packet loss can be devastating for
-the service quality. Extreme latencies are caused by TCP's
-dependency on the arrival of new data from the application to trigger
-retransmissions effectively through fast retransmit instead of
-waiting for long timeouts.
+protocols display what we call thin-stream properties. Traffic with
+thin-stream characteristics, characterized by small packets and a
+relatively high inter-transmission time (ITT), is often produced by
+latency-sensitive applications or services that rely on minimal
+latencies.
+
+In time-dependent scenarios (like online games, remote desktop,
+control systems, stock trading etc.) where the user experience depends
+on the data delivery latency, packet loss can be devastating for the
+service quality.
+
+Applications with a low write frequency, i.e. that write to the socket
+with with a low rate resulting in few packets in flight (PIF), render
+the retransmission mechanisms of the transport protocol ineffective.
+Thin streams experience increased latencies due to TCP's dependency on
+the arrival of dupACKs to trigger retransmissions effectively through
+fast retransmit instead of waiting for long timeouts.
=20
 After analysing a large number of time-dependent interactive
-applications, we have seen that they often produce thin streams
-and also stay with this traffic pattern throughout its entire
-lifespan. The combination of time-dependency and the fact that the
-streams provoke high latencies when using TCP is unfortunate.
+applications, we have seen that they often produce thin streams and
+also stay with this traffic pattern throughout its entire lifespan.
+The combination of time-dependency and the fact that the streams
+provoke high latencies when using TCP is unfortunate.
+
+In order to reduce application-layer latency when packets are lost, a
+set of mechanisms have been made, which address these latency issues
+for thin streams.
+
+Two reactive mechanisms will reduce the time it takes to trigger
+retransmits when a stream has less than four PIFs:
+
+* TCP_THIN_DUPACK: Do Fast Retransmit on the first dupACK.
+
+* TCP_THIN_LINEAR_TIMEOUTS: Instead of exponential backoff after RTOs,
+  perform up to 6 (TCP_THIN_LINEAR_RETRIES) linear timeouts before
+  initiating exponential backoff.
+
+The threshold of 4 PIFs is used because when there are less than 4
+PIFs, the three dupACKs usually required to trigger a fast retransmit
+may not be produced, rendering the stream prone to experience high
+retransmission latencies.
=20
-In order to reduce application-layer latency when packets are lost,
-a set of mechanisms has been made, which address these latency issues
-for thin streams. In short, if the kernel detects a thin stream,
-the retransmission mechanisms are modified in the following manner:
+Redundant Data Bundling
+***********************
=20
-1) If the stream is thin, fast retransmit on the first dupACK.
-2) If the stream is thin, do not apply exponential backoff.
+Redundant Data Bundling (RDB) is a mechanism aimed at reducing the
+latency for applications sending time-dependent data by proactively
+retransmitting un-ACKed segments. By bundling (retransmitting) already
+sent data with packets containing new data, the connection will be
+more resistant to sporadic packet loss which reduces the application
+layer latency significantly in congested scenarios.
=20
-These enhancements are applied only if the stream is detected as
-thin. This is accomplished by defining a threshold for the number
-of packets in flight. If there are less than 4 packets in flight,
-fast retransmissions can not be triggered, and the stream is prone
-to experience high retransmission latencies.
+Retransmitting data segments before they are known to be lost is a
+proactive approach at preventing increased latencies when packets are
+lost. By bundling redundant data before the retransmission mechanisms
+are triggered, RDB is very effective at alleviating head-of-line
+blocking on the receiving side, simply by reducing the need to perform
+regular retransmissions.
+
+With RDB enabled, an application that writes less frequently than the
+limit defined by the sysctl tcp_thin_dpifl_itt_lower_bound will be
+allowed to bundle.
+
+Using the thin-stream mechanisms
+********************************
=20
 Since these mechanisms are targeted at time-dependent applications,
-they must be specifically activated by the application using the
-TCP_THIN_LINEAR_TIMEOUTS and TCP_THIN_DUPACK IOCTLS or the
-tcp_thin_linear_timeouts and tcp_thin_dupack sysctls. Both
-modifications are turned off by default.
-
-References
-=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
-More information on the modifications, as well as a wide range of
-experimental data can be found here:
-"Improving latency for interactive, thin-stream applications over
-reliable transport"
-http://simula.no/research/nd/publications/Simula.nd.477/simula_pdf_fil=
e
+they are by default off.
+
+The socket options TCP_THIN_DUPACK and TCP_THIN_LINEAR_TIMEOUTS can be
+used to enable the mechanisms on a socket. Alternatively, they can be
+enabled system-wide by setting the sysctl variables
+net.ipv4.tcp_thin_dupack and net.ipv4.tcp_thin_linear_timeouts to 1.
+
+Using RDB
+=3D=3D=3D=3D=3D=3D=3D=3D=3D
+
+By default, applications are allowed to enable RDB on a socket with
+the socket option TCP_RDB. By setting the sysctl net.ipv4.tcp_rdb=3D0,
+application are not allowed to enable RDB on a socket. For testing
+purposes, it is possible to enable RDB system-wide for all new TCP
+connections by setting net.ipv4.tcp_rdb=3D2.
+
+For RDB to be fully efficient, Nagle must be disabled with the socket
+option TCP_NODELAY.
+
+
+Limitations on how much is bundled
+=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
+
+Applying limitations on how much RDB may bundle can help control how
+RDB affects the bandwidth usage and effects on competing traffic. With
+few active RDB enabled streams, the total increase of bandwidth usage
+and negative effect on competing traffic will be minimal, unless the
+total bandwidth capacity is very limited.
+
+In scenarios with many RDB enabled streams, the total effect may
+become significant, which may justify imposing limitations on RDB.
+
+The two sysctls tcp_rdb_max_bytes and tcp_rdb_max_packets contain the
+default values used to limit how much can be bundled with each packet.
+
+tcp_rdb_max_bytes limits the payload size of an RDB packet which is
+the size including both the new (unsent) data as well as the already
+sent data. tcp_rdb_max_packets specifies the number of packets that
+may be bundled with each RDB packet. This is the most important knob
+as it directly controls how many lost packets each RDB packet may
+recover.
+
+If more fine grained control is required, tcp_rdb_max_bytes is useful
+to control how much impact RDB can have on the increased bandwidth
+requirements of the flows. If an application writes 700 bytes per
+write call, the bandwidth increase can be quite significant (even with
+a 1 packet bundling limit) if we consider a scenario with thousands of
+RDB streams.
+
+By limiting the total payload size of RDB packets to e.g. 100 bytes,
+only the smallest segments will benefit from RDB, while the segments
+that would increase the bandwidth requirements the most, will not.
+
+tcp_rdb_max_packets defaults to 1 as that allows RDB to recover from
+sporadic packet loss while still affecting competing traffic to a
+small degree[2].
+
+The sysctl tcp_rdb_await_congestion specifies whether a connection
+should bundle only after congestion has been detected.
+
+The default bundling limitations defined by the sysctl variables may
+be overridden with the socket options TCP_RDB_MAX_BYTES and
+TCP_RDB_MAX_PACKETS. To ensure bundling is performed immediately
+instead of waiting until after packet loss, pass the following flags
+to TCP_RDB socket option: (TCP_RDB_ENABLE | TCP_RDB_BUNDLE_IMMEDIATE).
+
+
+Further reading
+***********************
+
+[1] provides information on the modifications thin_dupack and
+thin_linear_timeouts, as well as a wide range of experimental data
+
+[2] presents RDB and the motivation behind the mechanism. [3] provides
+a detailed overview of the RDB mechanism and the experiments performed
+to test the effects of RDB.
+
+[1] "Improving latency for interactive, thin-stream applications over
+     reliable transport"
+    http://urn.nb.no/URN:NBN:no-24274
+
+[2] "Latency and fairness trade-off for thin streams using redundant
+     data bundling in TCP."
+    http://dx.doi.org/10.1109/LCN.2015.7366322
+
+[3] "Taming Redundant Data Bundling: Balancing fairness and latency
+     for redundant bundling in TCP"
+    http://urn.nb.no/URN:NBN:no-48283
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index dc0fca7..20c74c3 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2973,6 +2973,7 @@ static inline void skb_free_datagram_locked(struc=
t sock *sk,
 	__skb_free_datagram_locked(sk, skb, 0);
 }
 int skb_kill_datagram(struct sock *sk, struct sk_buff *skb, unsigned i=
nt flags);
+void copy_skb_header(struct sk_buff *new, const struct sk_buff *old);
 int skb_copy_bits(const struct sk_buff *skb, int offset, void *to, int=
 len);
 int skb_store_bits(struct sk_buff *skb, int offset, const void *from, =
int len);
 __wsum skb_copy_and_csum_bits(const struct sk_buff *skb, int offset, u=
8 *to,
diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index 7be9b12..7a53644 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -213,11 +213,12 @@ struct tcp_sock {
 	} rack;
 	u16	advmss;		/* Advertised MSS			*/
 	u8	unused;
-	u8	nonagle     : 4,/* Disable Nagle algorithm?             */
+	u8	nonagle     : 3,/* Disable Nagle algorithm?             */
 		thin_lto    : 1,/* Use linear timeouts for thin streams */
 		thin_dupack : 1,/* Fast retransmit on first dupack      */
 		repair      : 1,
-		frto        : 1;/* F-RTO (RFC5682) activated in CA_Loss */
+		frto        : 1,/* F-RTO (RFC5682) activated in CA_Loss */
+		is_cwnd_limited:1;/* forward progress limited by snd_cwnd? */
 	u8	repair_queue;
 	u8	do_early_retrans:1,/* Enable RFC5827 early-retransmit  */
 		syn_data:1,	/* SYN includes data */
@@ -225,7 +226,11 @@ struct tcp_sock {
 		syn_fastopen_exp:1,/* SYN includes Fast Open exp. option */
 		syn_data_acked:1,/* data in SYN is acked by SYN-ACK */
 		save_syn:1,	/* Save headers of SYN packet */
-		is_cwnd_limited:1;/* forward progress limited by snd_cwnd? */
+		rdb:1,                  /* Redundant Data Bundling enabled     */
+		rdb_await_congestion:1; /* RDB wait to bundle until next loss  */
+
+	u16 rdb_max_bytes;      /* Max payload bytes in an RDB packet       *=
/
+	u16 rdb_max_packets;    /* Max packets allowed to be bundled by RDB *=
/
 	u32	tlp_high_seq;	/* snd_nxt at the time of TLP retransmit. */
=20
 /* RTT measurement */
diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
index 71be4ac..eb45f73 100644
--- a/include/net/netns/ipv4.h
+++ b/include/net/netns/ipv4.h
@@ -113,6 +113,11 @@ struct netns_ipv4 {
 	unsigned int sysctl_tcp_notsent_lowat;
 	int sysctl_tcp_thin_dpifl_itt_lower_bound;
=20
+	int sysctl_tcp_rdb;
+	int sysctl_tcp_rdb_await_congestion;
+	int sysctl_tcp_rdb_max_bytes;
+	int sysctl_tcp_rdb_max_packets;
+
 	int sysctl_igmp_max_memberships;
 	int sysctl_igmp_max_msf;
 	int sysctl_igmp_llm_reports;
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 9956af9..013d08a 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -541,6 +541,8 @@ void __tcp_push_pending_frames(struct sock *sk, uns=
igned int cur_mss,
 bool tcp_may_send_now(struct sock *sk);
 int __tcp_retransmit_skb(struct sock *sk, struct sk_buff *skb, int seg=
s);
 int tcp_retransmit_skb(struct sock *sk, struct sk_buff *skb, int segs)=
;
+int tcp_transmit_skb(struct sock *sk, struct sk_buff *skb, int clone_i=
t,
+		     gfp_t gfp_mask);
 void tcp_retransmit_timer(struct sock *sk);
 void tcp_xmit_retransmit_queue(struct sock *);
 void tcp_simple_retransmit(struct sock *);
@@ -560,6 +562,7 @@ void tcp_send_loss_probe(struct sock *sk);
 bool tcp_schedule_loss_probe(struct sock *sk);
 void tcp_skb_collapse_tstamp(struct sk_buff *skb,
 			     const struct sk_buff *next_skb);
+void tcp_skb_append_data(struct sk_buff *from_skb, struct sk_buff *to_=
skb);
=20
 /* tcp_input.c */
 void tcp_resume_early_retransmit(struct sock *sk);
@@ -569,6 +572,11 @@ void tcp_reset(struct sock *sk);
 void tcp_skb_mark_lost_uncond_verify(struct tcp_sock *tp, struct sk_bu=
ff *skb);
 void tcp_fin(struct sock *sk);
=20
+/* tcp_rdb.c */
+void tcp_rdb_ack_event(struct sock *sk);
+int tcp_transmit_rdb_skb(struct sock *sk, struct sk_buff *xmit_skb,
+			 unsigned int mss_now, gfp_t gfp_mask);
+
 /* tcp_timer.c */
 void tcp_init_xmit_timers(struct sock *);
 static inline void tcp_clear_xmit_timers(struct sock *sk)
@@ -770,6 +778,7 @@ struct tcp_skb_cb {
 		struct {
 			/* There is space for up to 20 bytes */
 			__u32 in_flight;/* Bytes in flight when packet sent */
+			__u32 rdb_start_seq; /* Start seq of RDB data */
 		} tx;   /* only used for outgoing skbs */
 		union {
 			struct inet_skb_parm	h4;
@@ -1503,6 +1512,9 @@ static inline struct sk_buff *tcp_write_queue_pre=
v(const struct sock *sk,
 #define tcp_for_write_queue_from_safe(skb, tmp, sk)			\
 	skb_queue_walk_from_safe(&(sk)->sk_write_queue, skb, tmp)
=20
+#define tcp_for_write_queue_reverse_from_safe(skb, tmp, sk)		\
+	skb_queue_reverse_walk_from_safe(&(sk)->sk_write_queue, skb, tmp)
+
 static inline struct sk_buff *tcp_send_head(const struct sock *sk)
 {
 	return sk->sk_send_head;
diff --git a/include/uapi/linux/snmp.h b/include/uapi/linux/snmp.h
index 25a9ad8..0bdeb06 100644
--- a/include/uapi/linux/snmp.h
+++ b/include/uapi/linux/snmp.h
@@ -280,6 +280,7 @@ enum
 	LINUX_MIB_TCPKEEPALIVE,			/* TCPKeepAlive */
 	LINUX_MIB_TCPMTUPFAIL,			/* TCPMTUPFail */
 	LINUX_MIB_TCPMTUPSUCCESS,		/* TCPMTUPSuccess */
+	LINUX_MIB_TCPRDBLOSSREPAIRS,		/* TCPRDBLossRepairs */
 	__LINUX_MIB_MAX
 };
=20
diff --git a/include/uapi/linux/tcp.h b/include/uapi/linux/tcp.h
index 53e8e3f..33ece78 100644
--- a/include/uapi/linux/tcp.h
+++ b/include/uapi/linux/tcp.h
@@ -115,6 +115,9 @@ enum {
 #define TCP_CC_INFO		26	/* Get Congestion Control (optional) info */
 #define TCP_SAVE_SYN		27	/* Record SYN headers for new connections */
 #define TCP_SAVED_SYN		28	/* Get SYN headers recorded for connection *=
/
+#define TCP_RDB			29	/* Enable Redundant Data Bundling mechanism */
+#define TCP_RDB_MAX_BYTES	30	/* Max payload bytes in an RDB packet */
+#define TCP_RDB_MAX_PACKETS	31	/* Max packets allowed to be bundled by=
 RDB */
=20
 struct tcp_repair_opt {
 	__u32	opt_code;
@@ -214,4 +217,11 @@ struct tcp_md5sig {
 	__u8	tcpm_key[TCP_MD5SIG_MAXKEYLEN];		/* key (binary) */
 };
=20
+/*
+ * TCP_RDB socket option flags
+ */
+#define TCP_RDB_DISABLE          0 /* Disble RDB */
+#define TCP_RDB_ENABLE           1 /* Enable RDB */
+#define TCP_RDB_BUNDLE_IMMEDIATE 2 /* Force immediate bundling (Do not=
 wait for congestion) */
+
 #endif /* _UAPI_LINUX_TCP_H */
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index e7ec6d3..77edf5a 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -1056,7 +1056,7 @@ static void skb_headers_offset_update(struct sk_b=
uff *skb, int off)
 	skb->inner_mac_header +=3D off;
 }
=20
-static void copy_skb_header(struct sk_buff *new, const struct sk_buff =
*old)
+void copy_skb_header(struct sk_buff *new, const struct sk_buff *old)
 {
 	__copy_skb_header(new, old);
=20
diff --git a/net/ipv4/Makefile b/net/ipv4/Makefile
index 24629b6..fac88b5 100644
--- a/net/ipv4/Makefile
+++ b/net/ipv4/Makefile
@@ -12,7 +12,8 @@ obj-y     :=3D route.o inetpeer.o protocol.o \
 	     tcp_offload.o datagram.o raw.o udp.o udplite.o \
 	     udp_offload.o arp.o icmp.o devinet.o af_inet.o igmp.o \
 	     fib_frontend.o fib_semantics.o fib_trie.o \
-	     inet_fragment.o ping.o ip_tunnel_core.o gre_offload.o
+	     inet_fragment.o ping.o ip_tunnel_core.o gre_offload.o \
+	     tcp_rdb.o
=20
 obj-$(CONFIG_NET_IP_TUNNEL) +=3D ip_tunnel.o
 obj-$(CONFIG_SYSCTL) +=3D sysctl_net_ipv4.o
diff --git a/net/ipv4/proc.c b/net/ipv4/proc.c
index 9f665b6..b839022 100644
--- a/net/ipv4/proc.c
+++ b/net/ipv4/proc.c
@@ -302,6 +302,7 @@ static const struct snmp_mib snmp4_net_list[] =3D {
 	SNMP_MIB_ITEM("TCPKeepAlive", LINUX_MIB_TCPKEEPALIVE),
 	SNMP_MIB_ITEM("TCPMTUPFail", LINUX_MIB_TCPMTUPFAIL),
 	SNMP_MIB_ITEM("TCPMTUPSuccess", LINUX_MIB_TCPMTUPSUCCESS),
+	SNMP_MIB_ITEM("TCPRDBLossRepairs", LINUX_MIB_TCPRDBLOSSREPAIRS),
 	SNMP_MIB_SENTINEL
 };
=20
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 150969d..3b6c3cb 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -731,6 +731,40 @@ static struct ctl_table ipv4_net_table[] =3D {
 		.proc_handler	=3D proc_dointvec
 	},
 	{
+		.procname	=3D "tcp_rdb",
+		.data		=3D &init_net.ipv4.sysctl_tcp_rdb,
+		.maxlen		=3D sizeof(init_net.ipv4.sysctl_tcp_rdb),
+		.mode		=3D 0644,
+		.proc_handler	=3D proc_dointvec_minmax,
+		.extra1		=3D &zero,
+		.extra2		=3D &one,
+	},
+	{
+		.procname	=3D "tcp_rdb_await_congestion",
+		.data		=3D &init_net.ipv4.sysctl_tcp_rdb_await_congestion,
+		.maxlen		=3D sizeof(init_net.ipv4.sysctl_tcp_rdb_await_congestion),
+		.mode		=3D 0644,
+		.proc_handler	=3D proc_dointvec_minmax,
+		.extra1		=3D &zero,
+		.extra2		=3D &one,
+	},
+	{
+		.procname	=3D "tcp_rdb_max_bytes",
+		.data		=3D &init_net.ipv4.sysctl_tcp_rdb_max_bytes,
+		.maxlen		=3D sizeof(init_net.ipv4.sysctl_tcp_rdb_max_bytes),
+		.mode		=3D 0644,
+		.proc_handler	=3D proc_dointvec_minmax,
+		.extra1		=3D &zero,
+	},
+	{
+		.procname	=3D "tcp_rdb_max_packets",
+		.data		=3D &init_net.ipv4.sysctl_tcp_rdb_max_packets,
+		.maxlen		=3D sizeof(init_net.ipv4.sysctl_tcp_rdb_max_packets),
+		.mode		=3D 0644,
+		.proc_handler	=3D proc_dointvec_minmax,
+		.extra1		=3D &zero,
+	},
+	{
 		.procname	=3D "ip_dynaddr",
 		.data		=3D &init_net.ipv4.sysctl_ip_dynaddr,
 		.maxlen		=3D sizeof(int),
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 5c7ed14..9fb012b 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -405,6 +405,12 @@ void tcp_init_sock(struct sock *sk)
 	u64_stats_init(&tp->syncp);
=20
 	tp->reordering =3D sock_net(sk)->ipv4.sysctl_tcp_reordering;
+
+	tp->rdb =3D sock_net(sk)->ipv4.sysctl_tcp_rdb =3D=3D 2;
+	tp->rdb_await_congestion =3D sock_net(sk)->ipv4.sysctl_tcp_rdb_await_=
congestion;
+	tp->rdb_max_packets =3D sock_net(sk)->ipv4.sysctl_tcp_rdb_max_packets=
;
+	tp->rdb_max_bytes =3D sock_net(sk)->ipv4.sysctl_tcp_rdb_max_bytes;
+
 	tcp_enable_early_retrans(tp);
 	tcp_assign_congestion_control(sk);
=20
@@ -2416,6 +2422,29 @@ static int do_tcp_setsockopt(struct sock *sk, in=
t level,
 		}
 		break;
=20
+	case TCP_RDB:
+		if (val && !sock_net(sk)->ipv4.sysctl_tcp_rdb)
+			err =3D -EPERM;
+		else {
+			tp->rdb =3D val & TCP_RDB_ENABLE;
+			tp->rdb_await_congestion =3D !(val & TCP_RDB_BUNDLE_IMMEDIATE);
+		}
+		break;
+
+	case TCP_RDB_MAX_BYTES:
+		if (val < 0 || val > USHRT_MAX)
+			err =3D -EINVAL;
+		else
+			tp->rdb_max_bytes =3D val;
+		break;
+
+	case TCP_RDB_MAX_PACKETS:
+		if (val < 0 || val > USHRT_MAX)
+			err =3D -EINVAL;
+		else
+			tp->rdb_max_packets =3D val;
+		break;
+
 	case TCP_REPAIR:
 		if (!tcp_can_repair_sock(sk))
 			err =3D -EPERM;
@@ -2848,7 +2877,18 @@ static int do_tcp_getsockopt(struct sock *sk, in=
t level,
 	case TCP_THIN_DUPACK:
 		val =3D tp->thin_dupack;
 		break;
-
+	case TCP_RDB:
+		if (tp->rdb)
+			val |=3D TCP_RDB_ENABLE;
+		if (!tp->rdb_await_congestion)
+			val |=3D TCP_RDB_BUNDLE_IMMEDIATE;
+		break;
+	case TCP_RDB_MAX_BYTES:
+		val =3D tp->rdb_max_bytes;
+		break;
+	case TCP_RDB_MAX_PACKETS:
+		val =3D tp->rdb_max_packets;
+		break;
 	case TCP_REPAIR:
 		val =3D tp->repair;
 		break;
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 94d4aff..35a3d1a 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -3540,6 +3540,9 @@ static inline void tcp_in_ack_event(struct sock *=
sk, u32 flags)
=20
 	if (icsk->icsk_ca_ops->in_ack_event)
 		icsk->icsk_ca_ops->in_ack_event(sk, flags);
+
+	if (unlikely(tcp_sk(sk)->rdb))
+		tcp_rdb_ack_event(sk);
 }
=20
 /* Congestion control has updated the cwnd already. So if we're in
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 4e5e8e6..7f06c52 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -2395,6 +2395,11 @@ static int __net_init tcp_sk_init(struct net *ne=
t)
 	net->ipv4.sysctl_tcp_ecn =3D 2;
 	net->ipv4.sysctl_tcp_ecn_fallback =3D 1;
=20
+	net->ipv4.sysctl_tcp_rdb =3D 1;
+	net->ipv4.sysctl_tcp_rdb_await_congestion =3D 1;
+	net->ipv4.sysctl_tcp_rdb_max_bytes =3D 0;
+	net->ipv4.sysctl_tcp_rdb_max_packets =3D 1;
+
 	net->ipv4.sysctl_tcp_base_mss =3D TCP_BASE_MSS;
 	net->ipv4.sysctl_tcp_probe_threshold =3D TCP_PROBE_THRESHOLD;
 	net->ipv4.sysctl_tcp_probe_interval =3D TCP_PROBE_INTERVAL;
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index b1bcba0..30f2d47 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -897,8 +897,8 @@ out:
  * We are working here with either a clone of the original
  * SKB, or a fresh unique copy made by the retransmit engine.
  */
-static int tcp_transmit_skb(struct sock *sk, struct sk_buff *skb, int =
clone_it,
-			    gfp_t gfp_mask)
+int tcp_transmit_skb(struct sock *sk, struct sk_buff *skb, int clone_i=
t,
+		     gfp_t gfp_mask)
 {
 	const struct inet_connection_sock *icsk =3D inet_csk(sk);
 	struct inet_sock *inet;
@@ -2129,9 +2129,12 @@ static bool tcp_write_xmit(struct sock *sk, unsi=
gned int mss_now, int nonagle,
 				break;
 		}
=20
-		if (unlikely(tcp_transmit_skb(sk, skb, 1, gfp)))
+		if (unlikely(tcp_sk(sk)->rdb)) {
+			if (tcp_transmit_rdb_skb(sk, skb, mss_now, gfp))
+				break;
+		} else if (unlikely(tcp_transmit_skb(sk, skb, 1, gfp))) {
 			break;
-
+		}
 repair:
 		/* Advance the send_head.  This one is sent out.
 		 * This call will increment packets_out.
@@ -2472,15 +2475,33 @@ void tcp_skb_collapse_tstamp(struct sk_buff *sk=
b,
 	}
 }
=20
+/**
+ * tcp_skb_append_data() - copy the linear data from an SKB to the end
+ *                         of another and update end sequence number
+ *                         and checksum
+ * @from_skb: the SKB to copy data from
+ * @to_skb: the SKB to copy data to
+ */
+void tcp_skb_append_data(struct sk_buff *from_skb, struct sk_buff *to_=
skb)
+{
+	skb_copy_from_linear_data(from_skb, skb_put(to_skb, from_skb->len),
+				  from_skb->len);
+	TCP_SKB_CB(to_skb)->end_seq =3D TCP_SKB_CB(from_skb)->end_seq;
+
+	if (from_skb->ip_summed =3D=3D CHECKSUM_PARTIAL)
+		to_skb->ip_summed =3D CHECKSUM_PARTIAL;
+
+	if (to_skb->ip_summed !=3D CHECKSUM_PARTIAL)
+		to_skb->csum =3D csum_block_add(to_skb->csum, from_skb->csum,
+					      to_skb->len);
+
+}
+
 /* Collapses two adjacent SKB's during retransmission. */
 static void tcp_collapse_retrans(struct sock *sk, struct sk_buff *skb)
 {
 	struct tcp_sock *tp =3D tcp_sk(sk);
 	struct sk_buff *next_skb =3D tcp_write_queue_next(sk, skb);
-	int skb_size, next_skb_size;
-
-	skb_size =3D skb->len;
-	next_skb_size =3D next_skb->len;
=20
 	BUG_ON(tcp_skb_pcount(skb) !=3D 1 || tcp_skb_pcount(next_skb) !=3D 1)=
;
=20
@@ -2488,17 +2509,7 @@ static void tcp_collapse_retrans(struct sock *sk=
, struct sk_buff *skb)
=20
 	tcp_unlink_write_queue(next_skb, sk);
=20
-	skb_copy_from_linear_data(next_skb, skb_put(skb, next_skb_size),
-				  next_skb_size);
-
-	if (next_skb->ip_summed =3D=3D CHECKSUM_PARTIAL)
-		skb->ip_summed =3D CHECKSUM_PARTIAL;
-
-	if (skb->ip_summed !=3D CHECKSUM_PARTIAL)
-		skb->csum =3D csum_block_add(skb->csum, next_skb->csum, skb_size);
-
-	/* Update sequence range on original skb. */
-	TCP_SKB_CB(skb)->end_seq =3D TCP_SKB_CB(next_skb)->end_seq;
+	tcp_skb_append_data(next_skb, skb);
=20
 	/* Merge over control information. This moves PSH/FIN etc. over */
 	TCP_SKB_CB(skb)->tcp_flags |=3D TCP_SKB_CB(next_skb)->tcp_flags;
diff --git a/net/ipv4/tcp_rdb.c b/net/ipv4/tcp_rdb.c
new file mode 100644
index 0000000..0c1790a
--- /dev/null
+++ b/net/ipv4/tcp_rdb.c
@@ -0,0 +1,240 @@
+#include <linux/skbuff.h>
+#include <net/tcp.h>
+
+/**
+ * rdb_detect_loss() - perform RDB loss detection by analysing ACKs
+ * @sk: socket
+ *
+ * Traverse the output queue and check if the ACKed packet is an RDB
+ * packet and if the redundant data covers one or more un-ACKed SKBs.
+ * If the incoming ACK acknowledges multiple SKBs, we can presume
+ * packet loss has occurred.
+ *
+ * We can infer packet loss this way because we can expect one ACK per
+ * transmitted data packet, as delayed ACKs are disabled when a host
+ * receives packets where the sequence number is not the expected
+ * sequence number.
+ *
+ * Return: 1 if packet loss, else 0
+ */
+static unsigned int rdb_detect_loss(struct sock *sk)
+{
+	struct sk_buff *skb, *tmp;
+	struct tcp_skb_cb *scb;
+	u32 seq_acked =3D tcp_sk(sk)->snd_una;
+
+	tcp_for_write_queue(skb, sk) {
+		if (skb =3D=3D tcp_send_head(sk))
+			break;
+
+		scb =3D TCP_SKB_CB(skb);
+		/* The ACK acknowledges parts of the data in this SKB.
+		 * Can be caused by:
+		 * - TSO: We abort as RDB is not used on SKBs split across
+		 *        multiple packets on lower layers as these are greater
+		 *        than one MSS.
+		 * - Retrans collapse: We've had a retrans, so loss has already
+		 *                     been detected.
+		 */
+		if (after(scb->end_seq, seq_acked))
+			break;
+		else if (scb->end_seq !=3D seq_acked)
+			continue;
+
+		/* We have found the ACKed packet */
+
+		/* This packet was sent with no redundant data, or no prior
+		 * un-ACKed SKBs is in the output queue, so break here.
+		 */
+		if (scb->tx.rdb_start_seq =3D=3D scb->seq ||
+		    skb_queue_is_first(&sk->sk_write_queue, skb))
+			break;
+		/* Find number of prior SKBs whose data was bundled in this
+		 * (ACKed) SKB. We presume any redundant data covering previous
+		 * SKB's are due to loss. (An exception would be reordering).
+		 */
+		skb =3D skb->prev;
+		tcp_for_write_queue_reverse_from_safe(skb, tmp, sk) {
+			if (before(TCP_SKB_CB(skb)->seq, scb->tx.rdb_start_seq))
+				break;
+			return 1;
+		}
+		break;
+	}
+	return 0;
+}
+
+/**
+ * tcp_rdb_ack_event() - initiate RDB loss detection
+ * @sk: socket
+ *
+ * When RDB is able to repair a packet loss, the loss event is hidden
+ * from the regular loss detection mechanisms. To ensure RDB streams
+ * behave fairly towards competing TCP traffic, we call tcp_enter_cwr(=
)
+ * to enter congestion window reduction state.
+ * tcp_enter_cwr() disables undoing the CWND reduction, which avoids
+ * incorrectly undoing the reduction later on.
+ */
+void tcp_rdb_ack_event(struct sock *sk)
+{
+	unsigned int lost =3D rdb_detect_loss(sk);
+	if (lost) {
+		tcp_enter_cwr(sk);
+		NET_INC_STATS(sock_net(sk), LINUX_MIB_TCPRDBLOSSREPAIRS);
+	}
+}
+
+/**
+ * rdb_build_skb() - build a new RDB SKB and copy redundant + unsent
+ *                   data to the linear page buffer
+ * @sk: socket
+ * @xmit_skb: the SKB processed for transmission in the output engine
+ * @first_skb: the first SKB in the output queue to be bundled
+ * @bytes_in_rdb_skb: the total number of data bytes for the new
+ *                    rdb_skb (NEW + Redundant)
+ * @gfp_mask: gfp_t allocation
+ *
+ * Return: A new SKB containing redundant data, or NULL if memory
+ *         allocation failed
+ */
+static struct sk_buff *rdb_build_skb(const struct sock *sk,
+				     struct sk_buff *xmit_skb,
+				     struct sk_buff *first_skb,
+				     u32 bytes_in_rdb_skb,
+				     gfp_t gfp_mask)
+{
+	struct sk_buff *rdb_skb, *tmp_skb =3D first_skb;
+
+	rdb_skb =3D sk_stream_alloc_skb((struct sock *)sk,
+				      (int)bytes_in_rdb_skb,
+				      gfp_mask, false);
+	if (!rdb_skb)
+		return NULL;
+	copy_skb_header(rdb_skb, xmit_skb);
+	rdb_skb->ip_summed =3D xmit_skb->ip_summed;
+	TCP_SKB_CB(rdb_skb)->seq =3D TCP_SKB_CB(first_skb)->seq;
+	TCP_SKB_CB(xmit_skb)->tx.rdb_start_seq =3D TCP_SKB_CB(rdb_skb)->seq;
+
+	/* Start on first_skb and append payload from each SKB in the output
+	 * queue onto rdb_skb until we reach xmit_skb.
+	 */
+	tcp_for_write_queue_from(tmp_skb, sk) {
+		tcp_skb_append_data(tmp_skb, rdb_skb);
+
+		/* We reached xmit_skb, containing the unsent data */
+		if (tmp_skb =3D=3D xmit_skb)
+			break;
+	}
+	return rdb_skb;
+}
+
+/**
+ * rdb_can_bundle_test() - test if redundant data can be bundled
+ * @sk: socket
+ * @xmit_skb: the SKB processed for transmission by the output engine
+ * @max_payload: the maximum allowed payload bytes for the RDB SKB
+ * @bytes_in_rdb_skb: store the total number of payload bytes in the
+ *                    RDB SKB if bundling can be performed
+ *
+ * Traverse the output queue and check if any un-acked data may be
+ * bundled.
+ *
+ * Return: The first SKB to be in the bundle, or NULL if no bundling
+ */
+static struct sk_buff *rdb_can_bundle_test(const struct sock *sk,
+					   struct sk_buff *xmit_skb,
+					   unsigned int max_payload,
+					   u32 *bytes_in_rdb_skb)
+{
+	struct tcp_sock *tp =3D tcp_sk(sk);
+	struct sk_buff *first_to_bundle =3D NULL;
+	struct sk_buff *tmp, *skb =3D xmit_skb->prev;
+	u32 skbs_in_bundle_count =3D 1; /* Start on 1 to account for xmit_skb=
 */
+	u32 total_payload =3D xmit_skb->len;
+
+	if (tp->rdb_max_bytes)
+		max_payload =3D min_t(unsigned int, max_payload,
+				    tp->rdb_max_bytes);
+
+	/* We start at xmit_skb->prev, and go backwards */
+	tcp_for_write_queue_reverse_from_safe(skb, tmp, sk) {
+		/* Including data from this SKB would exceed payload limit */
+		if ((total_payload + skb->len) > max_payload)
+			break;
+
+		if (tp->rdb_max_packets &&
+		    (skbs_in_bundle_count > tp->rdb_max_packets))
+			break;
+
+		total_payload +=3D skb->len;
+		skbs_in_bundle_count++;
+		first_to_bundle =3D skb;
+	}
+	*bytes_in_rdb_skb =3D total_payload;
+	return first_to_bundle;
+}
+
+/**
+ * tcp_transmit_rdb_skb() - try to create and send an RDB packet
+ * @sk: socket
+ * @xmit_skb: the SKB processed for transmission by the output engine
+ * @mss_now: current mss value
+ * @gfp_mask: gfp_t allocation
+ *
+ * If an RDB packet could not be created and sent, transmit the
+ * original unmodified SKB (xmit_skb).
+ *
+ * Return: 0 if successfully sent packet, else error from
+ *         tcp_transmit_skb
+ */
+int tcp_transmit_rdb_skb(struct sock *sk, struct sk_buff *xmit_skb,
+			 unsigned int mss_now, gfp_t gfp_mask)
+{
+	struct sk_buff *rdb_skb =3D NULL;
+	struct sk_buff *first_to_bundle;
+	u32 bytes_in_rdb_skb =3D 0;
+
+	/* How we detect that RDB was used. When equal, no RDB data was sent =
*/
+	TCP_SKB_CB(xmit_skb)->tx.rdb_start_seq =3D TCP_SKB_CB(xmit_skb)->seq;
+
+	/* We must wait for a retransmission to occur before bundling */
+	if (tcp_sk(sk)->rdb_await_congestion) {
+		if (tcp_in_initial_slowstart(tcp_sk(sk)))
+			goto xmit_default;
+		tcp_sk(sk)->rdb_await_congestion =3D 0;
+	}
+
+	if (!tcp_stream_is_thin_dpifl(sk))
+		goto xmit_default;
+
+	/* No bundling if first in queue */
+	if (skb_queue_is_first(&sk->sk_write_queue, xmit_skb))
+		goto xmit_default;
+
+	/* Find number of (previous) SKBs to get data from */
+	first_to_bundle =3D rdb_can_bundle_test(sk, xmit_skb, mss_now,
+					      &bytes_in_rdb_skb);
+	if (!first_to_bundle)
+		goto xmit_default;
+
+	/* Create an SKB that contains redundant data starting from
+	 * first_to_bundle.
+	 */
+	rdb_skb =3D rdb_build_skb(sk, xmit_skb, first_to_bundle,
+				bytes_in_rdb_skb, gfp_mask);
+	if (!rdb_skb)
+		goto xmit_default;
+
+	/* Set skb_mstamp for the SKB in the output queue (xmit_skb) containi=
ng
+	 * the yet unsent data. Normally this would be done by
+	 * tcp_transmit_skb(), but as we pass in rdb_skb instead, xmit_skb's
+	 * timestamp will not be touched.
+	 */
+	skb_mstamp_get(&xmit_skb->skb_mstamp);
+	rdb_skb->skb_mstamp =3D xmit_skb->skb_mstamp;
+	return tcp_transmit_skb(sk, rdb_skb, 0, gfp_mask);
+
+xmit_default:
+	/* Transmit the unmodified SKB from output queue */
+	return tcp_transmit_skb(sk, xmit_skb, 1, gfp_mask);
+}
--=20
2.1.4
