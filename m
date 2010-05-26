From: =?UTF-8?q?R=C3=A9mi=20Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
Subject: [PATCH net 1/1] Phonet: listening socket lock protects the connected socket list
Date: Wed, 26 May 2010 13:44:44 +0300
Message-ID: <1274870684-18428-1-git-send-email-remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.233]:26285 "EHLO
	mgw-mx06.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752265Ab0EZKnu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 May 2010 06:43:50 -0400
Received: from esebh106.NOE.Nokia.com (esebh106.ntc.nokia.com [172.21.138.213])
	by mgw-mx06.nokia.com (Switch-3.3.3/Switch-3.3.3) with ESMTP id o4QAhAcR032638
	for <netdev@vger.kernel.org>; Wed, 26 May 2010 13:43:47 +0300
Received: from localhost.localdomain (esdhcp037246.research.nokia.com [172.21.37.246])
	by mgw-sa02.ext.nokia.com (Switch-3.3.3/Switch-3.3.3) with ESMTP id o4QAh8lj009612
	for <netdev@vger.kernel.org>; Wed, 26 May 2010 13:43:08 +0300
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>

The accept()'d socket need to be unhashed while the (listen()'ing)
socket lock is held. This fixes a race condition that could lead to an
OOPS.

Signed-off-by: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>
---
 net/phonet/pep.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/phonet/pep.c b/net/phonet/pep.c
index 7b048a3..94d72e8 100644
--- a/net/phonet/pep.c
+++ b/net/phonet/pep.c
@@ -1045,12 +1045,12 @@ static void pep_sock_unhash(struct sock *sk)
 	lock_sock(sk);
 	if ((1 << sk->sk_state) & ~(TCPF_CLOSE|TCPF_LISTEN)) {
 		skparent =3D pn->listener;
-		sk_del_node_init(sk);
 		release_sock(sk);
=20
-		sk =3D skparent;
 		pn =3D pep_sk(skparent);
-		lock_sock(sk);
+		lock_sock(skparent);
+		sk_del_node_init(sk);
+		sk =3D skparent;
 	}
 	/* Unhash a listening sock only when it is closed
 	 * and all of its active connected pipes are closed. */
--=20
1.7.0.4

