From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 1/2] [TCP] FRTO: Fix fallback to conventional recovery
Date: Tue, 13 May 2008 12:43:53 +0300
Message-ID: <1210671834-15406-1-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "Damon L. Chesser" <damon@damtek.com>,
	"=?utf-8?q?Ilpo=20J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:33045 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750845AbYEMJnz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 May 2008 05:43:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It seems that commit 009a2e3e4ec ("[TCP] FRTO: Improve
interoperability with other undo_marker users") run into
another land-mine which caused fallback to conventional
recovery to break:

1. Cumulative ACK arrives after FRTO retransmission
2. tcp_try_to_open sees zero retrans_out, clears retrans_stamp
   which should be kept like in CA_Loss state it would be
3. undo_marker change allowed tcp_packet_delayed to return
   true because of the cleared retrans_stamp once FRTO is
   terminated causing LossUndo to occur, which means all loss
   markings FRTO made are reverted.

This means that the conventional recovery basically recovered
one loss per RTT, which is not that efficient. It was quite
unobvious that the undo_marker change broken something like
this, I had a quite long session to track it down because of
the non-intuitiviness of the bug (luckily I had a trivial
reproducer at hand and I was also able to learn to use kprobes
in the process as well :-)).

This together with the NewReno+FRTO fix and FRTO in-order
workaround this fixes Damon's problems, this and the first
mentioned are enough to fix Bugzilla #10063.

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
Reported-by: Damon L. Chesser <damon@damtek.com>
Tested-by: Damon L. Chesser <damon@damtek.com>
Tested-by: Sebastian Hyrwall <zibbe@cisko.org>
---
 net/ipv4/tcp_input.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 81ece1f..4c2255c 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2481,7 +2481,7 @@ static void tcp_try_to_open(struct sock *sk, int =
flag)
=20
 	tcp_verify_left_out(tp);
=20
-	if (tp->retrans_out =3D=3D 0)
+	if (!tp->frto_counter && tp->retrans_out =3D=3D 0)
 		tp->retrans_stamp =3D 0;
=20
 	if (flag & FLAG_ECE)
--=20
1.5.2.2

