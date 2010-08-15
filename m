From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: [PATCH] tcp: allow effective reduction of TCP's rcv-buffer via setsockopt
Date: Sun, 15 Aug 2010 21:36:16 +0200
Message-ID: <1281900976-11852-1-git-send-email-hagen@jauu.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Hagen Paul Pfeifer <hagen@jauu.net>,
	"David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	=?UTF-8?q?Ilpo=20J=C3=A4rvinen?= <ilpo.jarvinen@helsinki.fi>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:49037 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751217Ab0HOTqL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Aug 2010 15:46:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Via setsockopt it is possible to reduce the socket RX buffer
(SO_RCVBUF). TCP method to select the initial window and window scaling
option in tcp_select_initial_window() currently misbehaves and do not
consider a reduced RX socket buffer via setsockopt.

Even though the server's RX buffer is reduced via setsockopt() to 256
byte (Initial Window 384 byte =3D> 256 * 2 - (256 * 2 / 4)) the window
scale option is still 7:

192.168.1.38.40676 > 78.47.222.210.5001: Flags [S], seq 2577214362, win=
 5840, options [mss 1460,sackOK,TS val 338417 ecr 0,nop,wscale 0], leng=
th 0
78.47.222.210.5001 > 192.168.1.38.40676: Flags [S.], seq 1570631029, ac=
k 2577214363, win 384, options [mss 1452,sackOK,TS val 2435248895 ecr 3=
38417,nop,wscale 7], length 0
192.168.1.38.40676 > 78.47.222.210.5001: Flags [.], ack 1, win 5840, op=
tions [nop,nop,TS val 338421 ecr 2435248895], length 0

Within tcp_select_initial_window() the original space argument - a
representation of the rx buffer size - is expanded during
tcp_select_initial_window(). Only sysctl_tcp_rmem[2], sysctl_rmem_max
and window_clamp are considered to calculate the initial window.

This patch adjust the window_clamp argument if the user explicitly
reduce the receive buffer.

Signed-off-by: Hagen Paul Pfeifer <hagen@jauu.net>
Cc: David S. Miller <davem@davemloft.net>
Cc: Patrick McHardy <kaber@trash.net>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Ilpo J=C3=A4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_output.c |   11 +++++++++++
 1 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index de3bd84..c605312 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2429,6 +2429,12 @@ struct sk_buff *tcp_make_synack(struct sock *sk,=
 struct dst_entry *dst,
 		__u8 rcv_wscale;
 		/* Set this up on the first call only */
 		req->window_clamp =3D tp->window_clamp ? : dst_metric(dst, RTAX_WIND=
OW);
+
+		/* limit the window selection if the user enforce a smaller rx buffe=
r */
+		if (sk->sk_userlocks & SOCK_RCVBUF_LOCK &&
+				(req->window_clamp > tcp_full_space(sk) || req->window_clamp =3D=3D=
 0))
+			req->window_clamp =3D tcp_full_space(sk);
+
 		/* tcp_full_space because it is guaranteed to be the first packet */
 		tcp_select_initial_window(tcp_full_space(sk),
 			mss - (ireq->tstamp_ok ? TCPOLEN_TSTAMP_ALIGNED : 0),
@@ -2555,6 +2561,11 @@ static void tcp_connect_init(struct sock *sk)
=20
 	tcp_initialize_rcv_mss(sk);
=20
+	/* limit the window selection if the user enforce a smaller rx buffer=
 */
+	if (sk->sk_userlocks & SOCK_RCVBUF_LOCK &&
+			(tp->window_clamp > tcp_full_space(sk) || tp->window_clamp =3D=3D 0=
))
+		tp->window_clamp =3D tcp_full_space(sk);
+
 	tcp_select_initial_window(tcp_full_space(sk),
 				  tp->advmss - (tp->rx_opt.ts_recent_stamp ? tp->tcp_header_len - =
sizeof(struct tcphdr) : 0),
 				  &tp->rcv_wnd,
--=20
1.6.6.196.g1f735.dirty

