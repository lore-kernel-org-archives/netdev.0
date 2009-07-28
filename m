From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] pppoe: fix race at init time
Date: Tue, 28 Jul 2009 19:46:37 +0200
Message-ID: <4A6F397D.6010606@gmail.com>
References: <bug-13760-10286@http.bugzilla.kernel.org/> <20090722134557.2457c5f5.akpm@linux-foundation.org> 	<43d009740907222339n50ebe411ya6453dc5a294b9a0@mail.gmail.com> 	<20090723000100.d74d6b1c.akpm@linux-foundation.org> <43d009740907272340g7f98ed55lfff38bfedd867a99@mail.gmail.com> <4A6EBA88.8030205@cosmosbay.com> <4A6ECA3A.4050309@openvz.org> <4A6EEF69.1050001@cosmosbay.com> <4A6EF0BF.2050801@gmail.com> <4A6EF705.6070403@openvz.org> <4A6EFA35.3060309@gmail.com> <4A6EFB81.4090105@gmail.com> <4A6F017B.4060909@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Pavel Emelyanov <xemul@openvz.org>,
	Igor M Podlesny <for.poige+bugzilla.kernel.org@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, Cyrill Gorcunov <gorcunov@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:48051 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753533AbZG1Rqu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jul 2009 13:46:50 -0400
In-Reply-To: <4A6F017B.4060909@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet a =C3=A9crit :
> Eric Dumazet a =C3=A9crit :
>> Seems drivers/net/pppol2tp.c is a suspect...
>>
>> It uses register_pernet_gen_device() from pppol2tp_init()
>> but doesnt call unregister_pernet_gen_device()
>=20
> OK patch seems really easy...
>=20
> This bug was added in commit 4e9fb8016a351b5b9da7fea32bcfdbc9d836e421
> net: pppol2tp - introduce net-namespace functionality
>=20
> So this is a stable candidate I guess ?
>=20
> Thank you

So Igor still has a panic... lets try a third patch then :)

[PATCH] pppoe: fix race at init time

I believe we have a race in ppoe_init() :

As soon as dev_add_pack(&pppoes_ptype); and/or dev_add_pack(&pppoed_pty=
pe);=20
are called, we can receive packets while nets not yet fully ready
(ie : pppoe_init_net() not yet called)

This means we should be prepared to get a NULL pointer
from net_generic(net, pppoe_net_id) call.

We miss this NULL check in get_item() and possibly crash if this nets=20
has no struct pppoe_net attached yet. Other subroutines
are safe.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
diff --git a/drivers/net/pppoe.c b/drivers/net/pppoe.c
index f0031f1..e50af8c 100644
--- a/drivers/net/pppoe.c
+++ b/drivers/net/pppoe.c
@@ -237,14 +237,15 @@ static struct pppox_sock *__delete_item(struct pp=
poe_net *pn, __be16 sid,
 static inline struct pppox_sock *get_item(struct pppoe_net *pn, __be16=
 sid,
 					unsigned char *addr, int ifindex)
 {
-	struct pppox_sock *po;
-
-	read_lock_bh(&pn->hash_lock);
-	po =3D __get_item(pn, sid, addr, ifindex);
-	if (po)
-		sock_hold(sk_pppox(po));
-	read_unlock_bh(&pn->hash_lock);
-
+	struct pppox_sock *po =3D NULL;
+
+	if (pn) {
+		read_lock_bh(&pn->hash_lock);
+		po =3D __get_item(pn, sid, addr, ifindex);
+		if (po)
+			sock_hold(sk_pppox(po));
+		read_unlock_bh(&pn->hash_lock);
+	}
 	return po;
 }
=20
