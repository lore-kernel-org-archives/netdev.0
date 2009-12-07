From: Damian Lukowski <damian@tvk.rwth-aachen.de>
Subject: [PATCHv3 1/2] tcp: Stalling connections: Fix timeout calculation
 routine
Date: Mon, 07 Dec 2009 17:06:15 +0100
Message-ID: <4B1D27F7.9000502@tvk.rwth-aachen.de>
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
Received: from mta-2.ms.rz.RWTH-Aachen.DE ([134.130.7.73]:61858 "EHLO
	mta-2.ms.rz.rwth-aachen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932820AbZLGQGJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Dec 2009 11:06:09 -0500
Received: from ironport-out-1.rz.rwth-aachen.de ([134.130.5.40])
 by mta-2.ms.rz.RWTH-Aachen.de
 (Sun Java(tm) System Messaging Server 6.3-7.04 (built Sep 26 2008))
 with ESMTP id <0KUA00LABI2CX820@mta-2.ms.rz.RWTH-Aachen.de> for
 netdev@vger.kernel.org; Mon, 07 Dec 2009 17:06:15 +0100 (CET)
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
decisions before. The corresponding commit was
6fa12c85031485dff38ce550c24f10da23b0adaa.

Thanks to Ilpo J=E4rvinen for code suggestions and Frederic Leroy for
testing.

Signed-off-by: Damian Lukowski <damian@tvk.rwth-aachen.de>
---
 include/net/tcp.h |   10 ++++++++--
 1 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 03a49c7..842ac4d 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1263,14 +1263,20 @@ static inline struct sk_buff *tcp_write_queue_p=
rev(struct sock *sk, struct sk_bu
  * TCP connection after "boundary" unsucessful, exponentially backed-o=
ff
  * retransmissions with an initial RTO of TCP_RTO_MIN.
  */
-static inline bool retransmits_timed_out(const struct sock *sk,
+static inline bool retransmits_timed_out(struct sock *sk,
 					 unsigned int boundary)
 {
 	unsigned int timeout, linear_backoff_thresh;
+	unsigned int start_ts;
=20
 	if (!inet_csk(sk)->icsk_retransmits)
 		return false;
=20
+	if (unlikely(!tcp_sk(sk)->retrans_stamp))
+		start_ts =3D TCP_SKB_CB(tcp_write_queue_head(sk))->when;
+	else
+		start_ts =3D tcp_sk(sk)->retrans_stamp;
+
 	linear_backoff_thresh =3D ilog2(TCP_RTO_MAX/TCP_RTO_MIN);
=20
 	if (boundary <=3D linear_backoff_thresh)
@@ -1279,7 +1285,7 @@ static inline bool retransmits_timed_out(const st=
ruct sock *sk,
 		timeout =3D ((2 << linear_backoff_thresh) - 1) * TCP_RTO_MIN +
 			  (boundary - linear_backoff_thresh) * TCP_RTO_MAX;
=20
-	return (tcp_time_stamp - tcp_sk(sk)->retrans_stamp) >=3D timeout;
+	return (tcp_time_stamp - start_ts) >=3D timeout;
 }
=20
 static inline struct sk_buff *tcp_send_head(struct sock *sk)
--=20
1.6.4.4

