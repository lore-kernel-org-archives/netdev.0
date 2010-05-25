From: =?UTF-8?q?R=C3=A9mi=20Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
Subject: [PATCH net] Phonet: fix potential use-after-free in pep_sock_close()
Date: Tue, 25 May 2010 17:11:49 +0300
Message-ID: <1274796709-29988-1-git-send-email-remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.230]:43661 "EHLO
	mgw-mx03.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932557Ab0EYOKk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 May 2010 10:10:40 -0400
Received: from esebh106.NOE.Nokia.com (esebh106.ntc.nokia.com [172.21.138.213])
	by mgw-mx03.nokia.com (Switch-3.3.3/Switch-3.3.3) with ESMTP id o4PEAQgE011167
	for <netdev@vger.kernel.org>; Tue, 25 May 2010 17:10:37 +0300
Received: from localhost.localdomain (helruo-dhcp021131.ntc.nokia.com [172.21.21.131])
	by mgw-sa02.ext.nokia.com (Switch-3.3.3/Switch-3.3.3) with ESMTP id o4PEAClH032114
	for <netdev@vger.kernel.org>; Tue, 25 May 2010 17:10:13 +0300
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>

sk_common_release() might destroy our last reference to the socket.
So an extra temporary reference is needed during cleanup.

Signed-off-by: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>
---
 net/phonet/pep.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/net/phonet/pep.c b/net/phonet/pep.c
index af4d38b..7b048a3 100644
--- a/net/phonet/pep.c
+++ b/net/phonet/pep.c
@@ -626,6 +626,7 @@ static void pep_sock_close(struct sock *sk, long ti=
meout)
 	struct pep_sock *pn =3D pep_sk(sk);
 	int ifindex =3D 0;
=20
+	sock_hold(sk); /* keep a reference after sk_common_release() */
 	sk_common_release(sk);
=20
 	lock_sock(sk);
@@ -644,6 +645,7 @@ static void pep_sock_close(struct sock *sk, long ti=
meout)
=20
 	if (ifindex)
 		gprs_detach(sk);
+	sock_put(sk);
 }
=20
 static int pep_wait_connreq(struct sock *sk, int noblock)
--=20
1.7.0.4

