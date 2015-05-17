From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next] tcp: add rfc3168, section 6.1.1.1. fallback
Date: Sun, 17 May 2015 22:11:49 +0200
Message-ID: <3f31d31107081ed4755ed9731c63a60798c41703.1431892289.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>,
	Florian Westphal <fw@strlen.de>,
	=?UTF-8?q?Mirja=20K=C3=BChlewind?=
	<mirja.kuehlewind@tik.ee.ethz.ch>,
	Brian Trammell <trammell@tik.ee.ethz.ch>,
	Eric Dumazet <edumazet@google.com>,
	Dave That <dave.taht@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:51931 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750876AbbEQUMQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 May 2015 16:12:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This work as a follow-up of commit f7b3bec6f516 ("net: allow setting ec=
n
via routing table") and adds RFC3168 section 6.1.1.1. fallback for outg=
oing
ECN connections. In other words, this work adds a retry with a non-ECN
setup SYN packet, as suggested from the RFC on the first timeout:

  [...] A host that receives no reply to an ECN-setup SYN within the
  normal SYN retransmission timeout interval MAY resend the SYN and
  any subsequent SYN retransmissions with CWR and ECE cleared. [...]

Schematic client-side view when assuming the server is in tcp_ecn=3D2 m=
ode,
that is, Linux default since 2009 via commit 255cac91c3c9 ("tcp: extend
ECN sysctl to allow server-side only ECN"):

 1) Normal ECN-capable path:

    SYN ECE CWR ----->
                <----- SYN ACK ECE
            ACK ----->

 2) Path with broken middlebox, when client has fallback:

    SYN ECE CWR ----X crappy middlebox drops packet
                      (timeout, rtx)
            SYN ----->
                <----- SYN ACK
            ACK ----->

In case we would not have the fallback implemented, the middlebox drop
point would basically end up as:

    SYN ECE CWR ----X crappy middlebox drops packet
                      (timeout, rtx)
    SYN ECE CWR ----X crappy middlebox drops packet
                      (timeout, rtx)
    SYN ECE CWR ----X crappy middlebox drops packet
                      (timeout, rtx)

In any case, it's rather a smaller percentage of sites where there woul=
d
occur such additional setup latency: it was found in end of 2014 that ~=
56%
of IPv4 and 65% of IPv6 servers of Alexa 1 million list would negotiate
ECN (aka tcp_ecn=3D2 default), 0.42% of these webservers will fail to c=
onnect
when trying to negotiate with ECN (tcp_ecn=3D1) due to timeouts, which =
the
fallback would mitigate with a slight latency trade-off. Recent related
paper on this topic:

  Brian Trammell, Mirja K=C3=BChlewind, Damiano Boppart, Iain Learmonth=
,
  Gorry Fairhurst, and Richard Scheffenegger:
    "Enabling Internet-Wide Deployment of Explicit Congestion Notificat=
ion."
    Proc. PAM 2015, New York.
  http://ecn.ethz.ch/ecn-pam15.pdf

Thus, when net.ipv4.tcp_ecn=3D1 is being set, the patch will perform RF=
C3168,
section 6.1.1.1. fallback on timeout. For users explicitly not wanting =
this
which can be in DC use case, we add a net.ipv4.tcp_ecn_fallback knob th=
at
allows for disabling the fallback.

Reference: https://www.ietf.org/proceedings/92/slides/slides-92-iccrg-1=
=2Epdf
Reference: https://www.ietf.org/proceedings/89/slides/slides-89-tsvarea=
-1.pdf
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Mirja K=C3=BChlewind <mirja.kuehlewind@tik.ee.ethz.ch>
Signed-off-by: Brian Trammell <trammell@tik.ee.ethz.ch>
Cc: Eric Dumazet <edumazet@google.com>
Cc: Dave That <dave.taht@gmail.com>
---
  [ This was still pending after the route ECN change set and we though=
t,
    we might propose this topic to netdev for further discussion. ]

 Documentation/networking/dctcp.txt     |  1 +
 Documentation/networking/ip-sysctl.txt |  9 +++++++++
 include/net/netns/ipv4.h               |  2 ++
 include/net/tcp.h                      |  2 ++
 net/ipv4/sysctl_net_ipv4.c             |  7 +++++++
 net/ipv4/tcp_ipv4.c                    |  5 ++++-
 net/ipv4/tcp_output.c                  | 14 ++++++++++++++
 7 files changed, 39 insertions(+), 1 deletion(-)

diff --git a/Documentation/networking/dctcp.txt b/Documentation/network=
ing/dctcp.txt
index 0d5dfbc..13a8577 100644
--- a/Documentation/networking/dctcp.txt
+++ b/Documentation/networking/dctcp.txt
@@ -8,6 +8,7 @@ the data center network to provide multi-bit feedback t=
o the end hosts.
 To enable it on end hosts:
=20
   sysctl -w net.ipv4.tcp_congestion_control=3Ddctcp
+  sysctl -w net.ipv4.tcp_ecn_fallback=3D0 (optional)
=20
 All switches in the data center network running DCTCP must support ECN
 marking and be configured for marking when reaching defined switch buf=
fer
diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/net=
working/ip-sysctl.txt
index 5095c63..6d39753 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -267,6 +267,15 @@ tcp_ecn - INTEGER
 		  but do not request ECN on outgoing connections.
 	Default: 2
=20
+tcp_ecn_fallback - BOOLEAN
+	If the kernel detects that ECN connection misbehaves, enable fall
+	back to non-ECN. Currently, this knob implements the fallback
+	from RFC3168, section 6.1.1.1., but we reserve that in future,
+	additional detection mechanisms could be implemented under this
+	knob. The value	is not used, if tcp_ecn or per route/cong. ctl
+	ECN settings are disabled.
+	Default: 1 (fallback enabled)
+
 tcp_fack - BOOLEAN
 	Enable FACK congestion avoidance and fast retransmission.
 	The value is not used, if tcp_sack is not enabled.
diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
index 614a49b..6848b8b 100644
--- a/include/net/netns/ipv4.h
+++ b/include/net/netns/ipv4.h
@@ -77,6 +77,8 @@ struct netns_ipv4 {
 	struct local_ports ip_local_ports;
=20
 	int sysctl_tcp_ecn;
+	int sysctl_tcp_ecn_fallback;
+
 	int sysctl_ip_no_pmtu_disc;
 	int sysctl_ip_fwd_use_pmtu;
 	int sysctl_ip_nonlocal_bind;
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 7ace6ac..3275f93 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -702,6 +702,8 @@ static inline u32 tcp_skb_timestamp(const struct sk=
_buff *skb)
 #define TCPHDR_ECE 0x40
 #define TCPHDR_CWR 0x80
=20
+#define TCPHDR_SYN_ECN	(TCPHDR_SYN | TCPHDR_ECE | TCPHDR_CWR)
+
 /* This is what the send packet queuing engine uses to pass
  * TCP per-packet control information to the transmission code.
  * We also store the host-order sequence numbers in here too.
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index c3852a7..841de32 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -821,6 +821,13 @@ static struct ctl_table ipv4_net_table[] =3D {
 		.proc_handler	=3D proc_dointvec
 	},
 	{
+		.procname	=3D "tcp_ecn_fallback",
+		.data		=3D &init_net.ipv4.sysctl_tcp_ecn_fallback,
+		.maxlen		=3D sizeof(int),
+		.mode		=3D 0644,
+		.proc_handler	=3D proc_dointvec
+	},
+	{
 		.procname	=3D "ip_local_port_range",
 		.maxlen		=3D sizeof(init_net.ipv4.ip_local_ports.range),
 		.data		=3D &init_net.ipv4.ip_local_ports.range,
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 91cb476..0cc4b5a 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -2411,12 +2411,15 @@ static int __net_init tcp_sk_init(struct net *n=
et)
 			goto fail;
 		*per_cpu_ptr(net->ipv4.tcp_sk, cpu) =3D sk;
 	}
+
 	net->ipv4.sysctl_tcp_ecn =3D 2;
+	net->ipv4.sysctl_tcp_ecn_fallback =3D 1;
+
 	net->ipv4.sysctl_tcp_base_mss =3D TCP_BASE_MSS;
 	net->ipv4.sysctl_tcp_probe_threshold =3D TCP_PROBE_THRESHOLD;
 	net->ipv4.sysctl_tcp_probe_interval =3D TCP_PROBE_INTERVAL;
-	return 0;
=20
+	return 0;
 fail:
 	tcp_sk_exit(net);
=20
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 7386d32..b05d6df 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -350,6 +350,16 @@ static void tcp_ecn_send_syn(struct sock *sk, stru=
ct sk_buff *skb)
 	}
 }
=20
+static void tcp_ecn_clear_syn(struct sock *sk, struct sk_buff *skb)
+{
+	struct tcp_sock *tp =3D tcp_sk(sk);
+
+	if (sock_net(sk)->ipv4.sysctl_tcp_ecn_fallback) {
+		TCP_SKB_CB(skb)->tcp_flags &=3D ~(TCPHDR_ECE | TCPHDR_CWR);
+		tp->ecn_flags =3D 0;
+	}
+}
+
 static void
 tcp_ecn_make_synack(const struct request_sock *req, struct tcphdr *th,
 		    struct sock *sk)
@@ -2615,6 +2625,10 @@ int __tcp_retransmit_skb(struct sock *sk, struct=
 sk_buff *skb)
 		}
 	}
=20
+	/* RFC3168, section 6.1.1.1. ECN fallback */
+	if ((TCP_SKB_CB(skb)->tcp_flags & TCPHDR_SYN_ECN) =3D=3D TCPHDR_SYN_E=
CN)
+		tcp_ecn_clear_syn(sk, skb);
+
 	tcp_retrans_try_collapse(sk, skb, cur_mss);
=20
 	/* Make a copy, if the first transmission SKB clone we made
--=20
1.9.3
