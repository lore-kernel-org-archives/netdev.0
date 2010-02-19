From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/2] packet: convert socket list to RCU
Date: Fri, 19 Feb 2010 16:16:24 +0100
Message-ID: <1266592584.3136.41.camel@edumazet-laptop>
References: <20100219054145.959067404@vyatta.com>
	 <20100219054201.501571315@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Li Zefan <lizf@cn.fujitsu.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:36684 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753894Ab0BSPQb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Feb 2010 10:16:31 -0500
In-Reply-To: <20100219054201.501571315@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 18 f=C3=A9vrier 2010 =C3=A0 21:41 -0800, Stephen Hemminger a =C3=
=A9crit :

> Convert AF_PACKET to use RCU, eliminating one more reader/writer lock=
=2E
>=20
> I needed to create some minor additional socket list RCU infrastructu=
re
> to make this work. Note: there is no need for a real sk_del_node_init=
_rcu(),=20
> because sk_del_node_init is doing the equivalent thing to=20
> hlst_del_init_rcu already; but added some comments to try and make th=
at obvious.
>=20
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>=20

Stephen, I am a bit worried by the interaction between packet_release()
and packet_notifier()

With your version, packet_notifier() can run and let another cpu run
packet_release() un-contented. Both cpus could manipulate same po (and
particularly po->running)

Before your patch, the read_lock() done in packet_notifier() was
preventing packet_release() runnning at the same time.

Maybe packet_release() should lock po->bind_lock before manipulating
po->running, avoiding a refcount error.

Something like this preliminary patch :

[PATCH] packet: fix a race in packet_release

packet_release() has a potential race with packet_notifier(NETDEV_DOWN)=
,
leading to a double __sock_put(). (dev_remove_pack() is safe)

=46ix is to always use po->bind_lock before accessing po->running

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 10f7295..b706031 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -1271,15 +1271,15 @@ static int packet_release(struct socket *sock)
 	 *	Unhook packet receive handler.
 	 */
=20
+	spin_lock(&po->bind_lock);
 	if (po->running) {
-		/*
-		 *	Remove the protocol hook
-		 */
-		dev_remove_pack(&po->prot_hook);
+		__sock_put(sk);
 		po->running =3D 0;
 		po->num =3D 0;
-		__sock_put(sk);
-	}
+		spin_unlock(&po->bind_lock);
+		dev_remove_pack(&po->prot_hook);
+	} else
+		spin_unlock(&po->bind_lock);
=20
 	packet_flush_mclist(sk);
=20


