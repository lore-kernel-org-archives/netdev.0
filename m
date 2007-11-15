From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 02/10] [TCP]: Extend reordering detection to cover CA_Loss partially
Date: Thu, 15 Nov 2007 15:37:26 +0200
Message-ID: <11951338543953-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <11951338542267-git-send-email-ilpo.jarvinen@helsinki.fi> <1195133854795-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:45931 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757371AbXKONhh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Nov 2007 08:37:37 -0500
In-Reply-To: <1195133854795-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This implements more accurately what is stated in sacktag's
overall comment:

  "Both of these heuristics are not used in Loss state, when
   we cannot account for retransmits accurately."

When CA_Loss state is entered, the state changer ensures that
undo_marker is only set if no TCPCB_RETRANS skbs were found,
thus having non-zero undo_marker in CA_Loss basically tells
that the R-bits still accurately reflect the current state
of TCP.

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index c470b5a..48c059d 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1511,7 +1511,8 @@ tcp_sacktag_write_queue(struct sock *sk, struct s=
k_buff *ack_skb, u32 prior_snd_
=20
 	tcp_verify_left_out(tp);
=20
-	if ((reord < tp->fackets_out) && icsk->icsk_ca_state !=3D TCP_CA_Loss=
 &&
+	if ((reord < tp->fackets_out) &&
+	    ((icsk->icsk_ca_state !=3D TCP_CA_Loss) || tp->undo_marker) &&
 	    (!tp->frto_highmark || after(tp->snd_una, tp->frto_highmark)))
 		tcp_update_reordering(sk, tp->fackets_out - reord, 0);
=20
--=20
1.5.0.6

