From: Damian Lukowski <damian@tvk.rwth-aachen.de>
Subject: [PATCH] tcp: Fix for stalling connections
Date: Mon, 07 Dec 2009 01:28:21 +0100
Message-ID: <4B1C4C25.1070104@tvk.rwth-aachen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?ISO-8859-15?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	Frederic Leroy <fredo@starox.org>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Greg KH <gregkh@suse.de>
To: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta-2.ms.rz.RWTH-Aachen.DE ([134.130.7.73]:52408 "EHLO
	mta-2.ms.rz.rwth-aachen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S934440AbZLGA2P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Dec 2009 19:28:15 -0500
Received: from ironport-out-1.rz.rwth-aachen.de ([134.130.5.40])
 by mta-2.ms.rz.RWTH-Aachen.de
 (Sun Java(tm) System Messaging Server 6.3-7.04 (built Sep 26 2008))
 with ESMTP id <0KU900G7LAN9AMC0@mta-2.ms.rz.RWTH-Aachen.de> for
 netdev@vger.kernel.org; Mon, 07 Dec 2009 01:28:21 +0100 (CET)
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

Thanks to Ilpo J=E4rvinen for code suggestions.

Signed-off-by: Damian Lukowski <damian@tvk.rwth-aachen.de>
---
 include/net/tcp.h |    9 ++++++++-
 1 files changed, 8 insertions(+), 1 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 03a49c7..46f06e0 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1267,10 +1267,17 @@ static inline bool retransmits_timed_out(const =
struct sock *sk,
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
@@ -1279,7 +1286,7 @@ static inline bool retransmits_timed_out(const st=
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

