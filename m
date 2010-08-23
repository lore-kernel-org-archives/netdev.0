From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: [PATCH] tcp: make TCP quick ACK behavior modifiable
Date: Mon, 23 Aug 2010 21:00:37 +0200
Message-ID: <1282590037-18566-1-git-send-email-hagen@jauu.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Hagen Paul Pfeifer <hagen@jauu.net>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	=?UTF-8?q?Ilpo=20J=C3=A4rvinen?= <ilpo.jarvinen@helsinki.fi>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:38264 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753021Ab0HWTBF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Aug 2010 15:01:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The TCP quick ACK mechanism analyze if a connection is interactive or
not. Per default the quick ACK mechanism is enabled and ACK packets are
triggered instantly to raise the CWND fast - which is clever for
bulk data (non-interactive) flows. On the other hand interactive protoc=
ols
like HTTP, SMTP or XMPP will suffer from the quick ACK mechanism
because one additional packets is generated. A simple heuristic
detects if a connection is interactive (pingpong) and if so,
disable the quick ACK. But, the mechanism is not in the ability to
blindly guess if a connection is interactive, and so it must wait for a=
t
least one return packet with payload.

=46or the server side this requires one additional packet because (pack=
et
number 5 and 6 can be combined):

192.168.1.35.44833 > 78.47.222.210.80: Flags [S], seq 2854340018, win 5=
840, options [mss 1460,sackOK,TS val 4382726 ecr 0,nop,wscale 7], lengt=
h 0
78.47.222.210.80 > 192.168.1.35.44833: Flags [S.], seq 719041385, ack 2=
854340019, win 5792, options [mss 1452,sackOK,TS val 2606891996 ecr 438=
2726,nop,wscale 7], length 0
192.168.1.35.44833 > 78.47.222.210.80: Flags [.], ack 1, win 46, option=
s [nop,nop,TS val 4382730 ecr 2606891996], length 0
192.168.1.35.44833 > 78.47.222.210.80: Flags [P.], seq 1:682, ack 1, wi=
n 46, options [nop,nop,TS val 4382730 ecr 2606891996], length 681
78.47.222.210.80 > 192.168.1.35.44833: Flags [.], ack 682, win 56, opti=
ons [nop,nop,TS val 2606892002 ecr 4382730], length 0
78.47.222.210.80 > 192.168.1.35.44833: Flags [.], seq 1:1441, ack 682, =
win 56, options [nop,nop,TS val 2606892002 ecr 4382730], length 1440
192.168.1.35.44833 > 78.47.222.210.80: Flags [.], ack 1441, win 69, opt=
ions [nop,nop,TS val 4382737 ecr 2606892002], length 0

This patch provides a sysctl interface for the administrator to globall=
y
enable or disable TCP quick ACKs. Short lived protocols like HTTP will
save a non unimportant portion of packets!

Disable TCP Quick ACK:
$ echo 0 > /proc/sys/net/ipv4/tcp_quickack

Enable TCP Quick ACK:
$ echo 1 > /proc/sys/net/ipv4/tcp_quickack

Signed-off-by: Hagen Paul Pfeifer <hagen@jauu.net>
Cc: David S. Miller <davem@davemloft.net>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Ilpo J=C3=A4rvinen <ilpo.jarvinen@helsinki.fi>
---
 include/net/inet_connection_sock.h |    3 +++
 net/ipv4/sysctl_net_ipv4.c         |    7 +++++++
 net/ipv4/tcp.c                     |    2 ++
 3 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/include/net/inet_connection_sock.h b/include/net/inet_conn=
ection_sock.h
index b6d3b55..da2fbaf 100644
--- a/include/net/inet_connection_sock.h
+++ b/include/net/inet_connection_sock.h
@@ -170,9 +170,12 @@ static inline int inet_csk_ack_scheduled(const str=
uct sock *sk)
 	return inet_csk(sk)->icsk_ack.pending & ICSK_ACK_SCHED;
 }
=20
+extern int sysctl_tcp_quickack;
+
 static inline void inet_csk_delack_init(struct sock *sk)
 {
 	memset(&inet_csk(sk)->icsk_ack, 0, sizeof(inet_csk(sk)->icsk_ack));
+	inet_csk(sk)->icsk_ack.pingpong =3D sysctl_tcp_quickack ? 0 : 1;
 }
=20
 extern void inet_csk_delete_keepalive_timer(struct sock *sk);
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index d96c1da..8923ca8 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -394,6 +394,13 @@ static struct ctl_table ipv4_table[] =3D {
 		.proc_handler	=3D proc_dointvec
 	},
 	{
+		.procname	=3D "tcp_quickack",
+		.data		=3D &sysctl_tcp_quickack,
+		.maxlen		=3D sizeof(int),
+		.mode		=3D 0644,
+		.proc_handler	=3D proc_dointvec
+	},
+	{
 		.procname	=3D "tcp_mem",
 		.data		=3D &sysctl_tcp_mem,
 		.maxlen		=3D sizeof(sysctl_tcp_mem),
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 176e11a..5161689 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -279,6 +279,8 @@
=20
 int sysctl_tcp_fin_timeout __read_mostly =3D TCP_FIN_TIMEOUT;
=20
+int sysctl_tcp_quickack __read_mostly =3D 1;
+
 struct percpu_counter tcp_orphan_count;
 EXPORT_SYMBOL_GPL(tcp_orphan_count);
=20
--=20
1.7.2.1.95.g3d045.dirty

