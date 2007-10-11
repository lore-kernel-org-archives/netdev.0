From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 1/7] [TCP]: Add bytes_acked (ABC) clearing to FRTO too
Date: Thu, 11 Oct 2007 14:41:01 +0300
Message-ID: <11921028673599-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <1192102867479-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, TAKANO Ryousei <takano@axe-inc.co.jp>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:49824 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754547AbXJKLlP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Oct 2007 07:41:15 -0400
In-Reply-To: <1192102867479-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I was reading tcp_enter_loss while looking for Cedric's bug and
noticed bytes_acked adjustment is missing from FRTO side.

Since bytes_acked will only be used in tcp_cong_avoid, I think
it's safe to assume RTO would be spurious. During FRTO cwnd
will be not controlled by tcp_cong_avoid and if FRTO calls for
conventional recovery, cwnd is adjusted and the result of wrong
assumption is cleared from bytes_acked. If RTO was in fact
spurious, we did normal ABC already and can continue without
any additional adjustments.

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 101054c..e40857e 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1687,6 +1687,7 @@ static void tcp_enter_frto_loss(struct sock *sk, =
int allowed_segments, int flag)
 	tp->snd_cwnd_cnt =3D 0;
 	tp->snd_cwnd_stamp =3D tcp_time_stamp;
 	tp->frto_counter =3D 0;
+	tp->bytes_acked =3D 0;
=20
 	tp->reordering =3D min_t(unsigned int, tp->reordering,
 					     sysctl_tcp_reordering);
@@ -2824,6 +2825,7 @@ static void tcp_conservative_spur_to_response(str=
uct tcp_sock *tp)
 {
 	tp->snd_cwnd =3D min(tp->snd_cwnd, tp->snd_ssthresh);
 	tp->snd_cwnd_cnt =3D 0;
+	tp->bytes_acked =3D 0;
 	TCP_ECN_queue_cwr(tp);
 	tcp_moderate_cwnd(tp);
 }
--=20
1.5.0.6

