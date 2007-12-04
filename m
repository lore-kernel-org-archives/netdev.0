From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 1/3] [TCP] FRTO: Use of existing funcs make code more obvious & robust
Date: Tue,  4 Dec 2007 18:48:48 +0200
Message-ID: <11967869303567-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <11967869303114-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	"=?ISO-8859-1?q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:35735 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751564AbXLDQsw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Dec 2007 11:48:52 -0500
In-Reply-To: <11967869303114-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: =3D?ISO-8859-1?q?Ilpo_J=3DE4rvinen?=3D <ilpo.jarvinen@helsinki.=
fi>

Though there's little need for everything that tcp_may_send_now
does (actually, even the state had to be adjusted to pass some
checks FRTO does not want to occur), it's more robust to let it
make the decision if sending is allowed. State adjustments
needed:
- Make sure snd_cwnd limit is not hit in there
- Disable nagle (if necessary) through the frto_counter =3D=3D 2

The result of check for frto_counter in argument to call for
tcp_enter_frto_loss can just be open coded, therefore there
isn't need to store the previous frto_counter past
tcp_may_send_now.

In addition, returns can then be combined.

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |   14 +++++---------
 1 files changed, 5 insertions(+), 9 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 227977d..5f93d88 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -3118,17 +3118,13 @@ static int tcp_process_frto(struct sock *sk, in=
t flag)
 	}
=20
 	if (tp->frto_counter =3D=3D 1) {
-		/* Sending of the next skb must be allowed or no F-RTO */
-		if (!tcp_send_head(sk) ||
-		    after(TCP_SKB_CB(tcp_send_head(sk))->end_seq,
-				     tp->snd_una + tp->snd_wnd)) {
-			tcp_enter_frto_loss(sk, (tp->frto_counter =3D=3D 1 ? 2 : 3),
-					    flag);
-			return 1;
-		}
-
+		/* tcp_may_send_now needs to see updated state */
 		tp->snd_cwnd =3D tcp_packets_in_flight(tp) + 2;
 		tp->frto_counter =3D 2;
+
+		if (!tcp_may_send_now(sk))
+			tcp_enter_frto_loss(sk, 2, flag);
+
 		return 1;
 	} else {
 		switch (sysctl_tcp_frto_response) {
--=20
1.5.0.6

