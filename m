From: =?UTF-8?q?R=C3=A9mi=20Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
Subject: [PATCH 1/3] Phonet: restore flow control credits when sending fails
Date: Tue, 31 Aug 2010 01:57:03 +0300
Message-ID: <1283209025-28658-1-git-send-email-remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw-sa02.nokia.com ([147.243.1.48]:47081 "EHLO
	mgw-sa02.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753982Ab0H3W5E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Aug 2010 18:57:04 -0400
Received: from localhost.localdomain (sddhcp197215.americas.nokia.com [172.19.197.215])
	by mgw-sa02.nokia.com (Switch-3.4.3/Switch-3.4.3) with ESMTP id o7UMv0AY024246
	for <netdev@vger.kernel.org>; Tue, 31 Aug 2010 01:57:01 +0300
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>

Signed-off-by: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>
---
 net/phonet/pep.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/net/phonet/pep.c b/net/phonet/pep.c
index b2a3ae6..5034f0f 100644
--- a/net/phonet/pep.c
+++ b/net/phonet/pep.c
@@ -834,6 +834,7 @@ static int pipe_skb_send(struct sock *sk, struct sk=
_buff *skb)
 {
 	struct pep_sock *pn =3D pep_sk(sk);
 	struct pnpipehdr *ph;
+	int err;
=20
 	if (pn_flow_safe(pn->tx_fc) &&
 	    !atomic_add_unless(&pn->tx_credits, -1, 0)) {
@@ -852,7 +853,10 @@ static int pipe_skb_send(struct sock *sk, struct s=
k_buff *skb)
 		ph->message_id =3D PNS_PIPE_DATA;
 	ph->pipe_handle =3D pn->pipe_handle;
=20
-	return pn_skb_send(sk, skb, &pipe_srv);
+	err =3D pn_skb_send(sk, skb, &pipe_srv);
+	if (err && pn_flow_safe(pn->tx_fc))
+		atomic_inc(&pn->tx_credits);
+	return err;
 }
=20
 static int pep_sendmsg(struct kiocb *iocb, struct sock *sk,
--=20
1.7.0.4

