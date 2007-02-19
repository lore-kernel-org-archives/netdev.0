From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 15/18] [TCP] FRTO: Fake cwnd for ssthresh callback
Date: Mon, 19 Feb 2007 13:38:09 +0200
Message-ID: <1171885092244-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <11718850923446-git-send-email-ilpo.jarvinen@helsinki.fi> <1171885092563-git-send-email-ilpo.jarvinen@helsinki.fi> <11718850921459-git-send-email-ilpo.jarvinen@helsinki.fi> <11718850923208-git-send-email-ilpo.jarvinen@helsinki.fi> <11718850921817-git-send-email-ilpo.jarvinen@helsinki.fi> <11718850922528-git-send-email-ilpo.jarvinen@helsinki.fi> <11718850921864-git-send-email-ilpo.jarvinen@helsinki.fi> <11718850922604-git-send-email-ilpo.jarvinen@helsinki.fi> <11718850921021-git-send-email-ilpo.jarvinen@helsinki.fi> <11718850923324-git-send-email-ilpo.jarvinen@helsinki.fi> <11718850922734-git-send-email-ilpo.jarvinen@helsinki.fi> <11718850921158-git-send-email-ilpo.jarvinen@helsinki.fi> <11718850921574-git-send-email-ilpo.jarvinen@helsinki.fi> <11718850921409-git-send-email-ilpo.jarvinen@helsinki.fi> <11718850921389-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Pasi Sarolahti <pasi.sarolahti@nokia.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:50238 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932142AbXBSLiS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Feb 2007 06:38:18 -0500
In-Reply-To: <11718850921389-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

TCP without FRTO would be in Loss state with small cwnd. FRTO,
however, leaves cwnd (typically) to a larger value which causes
ssthresh to become too large in case RTO is triggered again
compared to what conventional recovery would do. Because
consecutive RTOs result in only a single ssthresh reduction,
RTO+cumulative ACK+RTO pattern is required to trigger this
event.

A large comment is included for congestion control module writers
trying to figure out what CA_EVENT_FRTO handler should do because
there exists a remote possibility of incompatibility between
=46RTO and module defined ssthresh functions.

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |   26 +++++++++++++++++++++++++-
 1 files changed, 25 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 2c0b387..5d935b1 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1289,7 +1289,31 @@ void tcp_enter_frto(struct sock *sk)
 	    ((icsk->icsk_ca_state =3D=3D TCP_CA_Loss || tp->frto_counter) &&
 	     !icsk->icsk_retransmits)) {
 		tp->prior_ssthresh =3D tcp_current_ssthresh(sk);
-		tp->snd_ssthresh =3D icsk->icsk_ca_ops->ssthresh(sk);
+		/* Our state is too optimistic in ssthresh() call because cwnd
+		 * is not reduced until tcp_enter_frto_loss() when previous FRTO
+		 * recovery has not yet completed. Pattern would be this: RTO,
+		 * Cumulative ACK, RTO (2xRTO for the same segment does not end
+		 * up here twice).
+		 * RFC4138 should be more specific on what to do, even though
+		 * RTO is quite unlikely to occur after the first Cumulative ACK
+		 * due to back-off and complexity of triggering events ...
+		 */
+		if (tp->frto_counter) {
+			u32 stored_cwnd;
+			stored_cwnd =3D tp->snd_cwnd;
+			tp->snd_cwnd =3D 2;
+			tp->snd_ssthresh =3D icsk->icsk_ca_ops->ssthresh(sk);
+			tp->snd_cwnd =3D stored_cwnd;
+		} else {
+			tp->snd_ssthresh =3D icsk->icsk_ca_ops->ssthresh(sk);
+		}
+		/* ... in theory, cong.control module could do "any tricks" in
+		 * ssthresh(), which means that ca_state, lost bits and lost_out
+		 * counter would have to be faked before the call occurs. We
+		 * consider that too expensive, unlikely and hacky, so modules
+		 * using these in ssthresh() must deal these incompatibility
+		 * issues if they receives CA_EVENT_FRTO and frto_counter !=3D 0
+		 */
 		tcp_ca_event(sk, CA_EVENT_FRTO);
 	}
=20
--=20
1.4.2

