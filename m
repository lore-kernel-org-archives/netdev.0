From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 2/3] [TCP]: Code duplication removal, added tcp_bound_to_half_wnd()
Date: Mon, 31 Dec 2007 16:21:46 +0200
Message-ID: <11991109072164-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <11991109072239-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:48127 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752895AbXLaOVs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Dec 2007 09:21:48 -0500
In-Reply-To: <11991109072239-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_output.c |   19 +++++++++++--------
 1 files changed, 11 insertions(+), 8 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index bb7e80a..b3110fc 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -888,6 +888,15 @@ void tcp_mtup_init(struct sock *sk)
 	icsk->icsk_mtup.probe_size =3D 0;
 }
=20
+/* Bound MSS / TSO packet size with the half of the window */
+static int tcp_bound_to_half_wnd(struct tcp_sock *tp, int pktsize)
+{
+	if (tp->max_window && pktsize > (tp->max_window >> 1))
+		return max(tp->max_window >> 1, 68U - tp->tcp_header_len);
+	else
+		return pktsize;
+}
+
 /* This function synchronize snd mss to current pmtu/exthdr set.
=20
    tp->rx_opt.user_mss is mss set by user by TCP_MAXSEG. It does NOT c=
ounts
@@ -920,10 +929,7 @@ unsigned int tcp_sync_mss(struct sock *sk, u32 pmt=
u)
 		icsk->icsk_mtup.search_high =3D pmtu;
=20
 	mss_now =3D tcp_mtu_to_mss(sk, pmtu);
-
-	/* Bound mss with half of window */
-	if (tp->max_window && mss_now > (tp->max_window >> 1))
-		mss_now =3D max((tp->max_window >> 1), 68U - tp->tcp_header_len);
+	mss_now =3D tcp_bound_to_half_wnd(tp, mss_now);
=20
 	/* And store cached results */
 	icsk->icsk_pmtu_cookie =3D pmtu;
@@ -977,10 +983,7 @@ unsigned int tcp_current_mss(struct sock *sk, int =
large_allowed)
 				  inet_csk(sk)->icsk_ext_hdr_len -
 				  tp->tcp_header_len);
=20
-		if (tp->max_window && (xmit_size_goal > (tp->max_window >> 1)))
-			xmit_size_goal =3D max((tp->max_window >> 1),
-					     68U - tp->tcp_header_len);
-
+		xmit_size_goal =3D tcp_bound_to_half_wnd(tp, xmit_size_goal);
 		xmit_size_goal -=3D (xmit_size_goal % mss_now);
 	}
 	tp->xmit_size_goal =3D xmit_size_goal;
--=20
1.5.0.6

