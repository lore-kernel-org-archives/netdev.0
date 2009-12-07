From: Damian Lukowski <damian@tvk.rwth-aachen.de>
Subject: [PATCHv2 2/2] tcp: Stalling connections: Fix timeout calculation
 routine
Date: Mon, 07 Dec 2009 12:41:34 +0100
Message-ID: <4B1CE9EE.1040903@tvk.rwth-aachen.de>
References: <4B1C4C25.1070104@tvk.rwth-aachen.de> <4B1C9D94.3070504@gmail.com>
 <4B1CE45A.9010908@tvk.rwth-aachen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Netdev <netdev@vger.kernel.org>,
	=?ISO-8859-15?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	Frederic Leroy <fredo@starox.org>,
	David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Greg KH <gregkh@suse.de>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta-1.ms.rz.RWTH-Aachen.DE ([134.130.7.72]:46279 "EHLO
	mta-1.ms.rz.rwth-aachen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S934122AbZLGLl3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Dec 2009 06:41:29 -0500
Received: from ironport-out-1.rz.rwth-aachen.de ([134.130.5.40])
 by mta-1.ms.rz.RWTH-Aachen.de
 (Sun Java(tm) System Messaging Server 6.3-7.04 (built Sep 26 2008))
 with ESMTP id <0KUA004N55TB9210@mta-1.ms.rz.RWTH-Aachen.de> for
 netdev@vger.kernel.org; Mon, 07 Dec 2009 12:41:35 +0100 (CET)
In-reply-to: <4B1CE45A.9010908@tvk.rwth-aachen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes a problem in the TCP connection timeout calculation.
Currently, timeout decisions are made on the basis of the current
tcp_time_stamp and retrans_stamp, which is usually set at the first
retransmission.
However, if the retransmission fails in tcp_retransmit_skb(),
retrans_stamp is not updated and remains zero. This leads to wrong
decisions in retransmits_timed_out() if tcp_time_stamp is larger than
the specified timeout, which is very likely.
In this case, the TCP connection dies after the first attempted
(and unsuccessful) retransmission.

With this patch, tcp_skb_cb->when is used instead, when retrans_stamp
is not available.

This bug has been introduced together with retransmits_timed_out()
in 2.6.32, as the number of retransmissions has been used for timeout
decisions before.

Thanks to Ilpo J=E4rvinen for code suggestions and Frederic Leroy for
testing.

Signed-off-by: Damian Lukowski <damian@tvk.rwth-aachen.de>
---
 net/ipv4/tcp_timer.c |    9 ++++++++-
 1 files changed, 8 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
index 5c5f739..a9d2891 100644
--- a/net/ipv4/tcp_timer.c
+++ b/net/ipv4/tcp_timer.c
@@ -140,10 +140,17 @@ static bool retransmits_timed_out(const struct so=
ck *sk,
 				  unsigned int boundary)
 {
 	unsigned int timeout, linear_backoff_thresh;
+	unsigned int start_ts;
=20
 	if (!inet_csk(sk)->icsk_retransmits)
 		return false;
=20
+	if (unlikely(!tcp_sk(sk)->retrans_stamp))
+		start_ts =3D TCP_SKB_CB(tcp_write_queue_head(
+					(struct sock *)sk))->when;
+	else
+		start_ts =3D tcp_sk(sk)->retrans_stamp;
+
 	linear_backoff_thresh =3D ilog2(TCP_RTO_MAX/TCP_RTO_MIN);
=20
 	if (boundary <=3D linear_backoff_thresh)
@@ -152,7 +159,7 @@ static bool retransmits_timed_out(const struct sock=
 *sk,
 		timeout =3D ((2 << linear_backoff_thresh) - 1) * TCP_RTO_MIN +
 			  (boundary - linear_backoff_thresh) * TCP_RTO_MAX;
=20
-	return (tcp_time_stamp - tcp_sk(sk)->retrans_stamp) >=3D timeout;
+	return (tcp_time_stamp - start_ts) >=3D timeout;
 }
=20
 /* A write timeout has occurred. Process the after effects. */
--=20
1.6.4.4


