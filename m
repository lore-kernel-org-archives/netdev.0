From: Kumar A Sanghvi <kumar.sanghvi@stericsson.com>
Subject: [PATCH 4/4] Phonet: restore flow control credits when sending fails
Date: Thu, 30 Sep 2010 13:55:05 +0530
Message-ID: <1285835105-20293-1-git-send-email-kumar.sanghvi@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <gulshan.karmani@stericsson.com>,
	Kumar Sanghvi <kumar.sanghvi@stericsson.com>,
	Linus Walleij <linus.walleij@stericsson.com>
To: <netdev@vger.kernel.org>, <davem@davemloft.net>,
	<remi.denis-courmont@nokia.com>, <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog108.obsmtp.com ([207.126.144.125]:49116 "EHLO
	eu1sys200aog108.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754696Ab0I3IZ0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Sep 2010 04:25:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>

This patch restores the below flow control patch submitted by R=C3=A9mi
Denis-Courmont, which accidentaly got lost due to Pipe controller patch
on Phonet.

	commit 1a98214feef2221cd7c24b17cd688a5a9d85b2ea
	Author: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>
	Date:   Mon Aug 30 12:57:03 2010 +0000

	Phonet: restore flow control credits when sending fails

	Signed-off-by: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com=
>
	Signed-off-by: David S. Miller <davem@davemloft.net>

Signed-off-by: Kumar Sanghvi <kumar.sanghvi@stericsson.com>
Acked-by: Linus Walleij <linus.walleij@stericsson.com>
---
 net/phonet/pep.c |   10 ++++++++--
 1 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/net/phonet/pep.c b/net/phonet/pep.c
index 9746c6d..aa3d870 100644
--- a/net/phonet/pep.c
+++ b/net/phonet/pep.c
@@ -1289,6 +1289,7 @@ static int pipe_skb_send(struct sock *sk, struct =
sk_buff *skb)
 {
 	struct pep_sock *pn =3D pep_sk(sk);
 	struct pnpipehdr *ph;
+	int err;
 #ifdef CONFIG_PHONET_PIPECTRLR
 	struct sockaddr_pn spn =3D {
 		.spn_family =3D AF_PHONET,
@@ -1315,10 +1316,15 @@ static int pipe_skb_send(struct sock *sk, struc=
t sk_buff *skb)
 		ph->message_id =3D PNS_PIPE_DATA;
 	ph->pipe_handle =3D pn->pipe_handle;
 #ifdef CONFIG_PHONET_PIPECTRLR
-	return pn_skb_send(sk, skb, &spn);
+	err =3D pn_skb_send(sk, skb, &spn);
 #else
-	return pn_skb_send(sk, skb, &pipe_srv);
+	err =3D pn_skb_send(sk, skb, &pipe_srv);
 #endif
+
+	if (err && pn_flow_safe(pn->tx_fc))
+		atomic_inc(&pn->tx_credits);
+	return err;
+
 }
=20
 static int pep_sendmsg(struct kiocb *iocb, struct sock *sk,
--=20
1.7.2.dirty

