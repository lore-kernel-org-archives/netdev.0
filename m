From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [Bugme-new] [Bug 13760] New: 2.6.30 kernel locks up with pppoe
 in 	back trace (regression)
Date: Tue, 28 Jul 2009 10:44:56 +0200
Message-ID: <4A6EBA88.8030205@cosmosbay.com>
References: <bug-13760-10286@http.bugzilla.kernel.org/> <20090722134557.2457c5f5.akpm@linux-foundation.org> 	<43d009740907222339n50ebe411ya6453dc5a294b9a0@mail.gmail.com> 	<20090723000100.d74d6b1c.akpm@linux-foundation.org> <43d009740907272340g7f98ed55lfff38bfedd867a99@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm@linux-foundation.org>,
	bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org,
	Pavel Emelyanov <xemul@openvz.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	"David S. Miller" <davem@davemloft.net>
To: Igor M Podlesny <for.poige+bugzilla.kernel.org@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:57546 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752753AbZG1Iql (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jul 2009 04:46:41 -0400
In-Reply-To: <43d009740907272340g7f98ed55lfff38bfedd867a99@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Igor M Podlesny a =C3=A9crit :
> [...]
>> Could have been a problem in net core, perhaps.
>>
>> Below is a ppp fix from 2.6.31, but it seems unlikely to fix your pr=
oblem.
>>
>> It would help if we could see that trace, please.  A digital photo
>> would suit.
>=20
> 	Here it is:
>=20
> 		http://bugzilla.kernel.org/attachment.cgi?id=3D22516
>=20
> 	(It's 2.6.30.3)
> =09

Looking at this, I believe net_assign_generic() is not safe.

Two cpus could try to expand/update the array at same time, one update =
could be lost.

register_pernet_gen_device() has a mutex to guard against concurrent
calls, but net_assign_generic() has no locking at all.

I doubt this is the reason of the crash, still worth to mention it...

[PATCH] net: net_assign_generic() is not SMP safe

Two cpus could try to expand/update the array at same time, one update
could be lost during the copy of old array.

Re-using net_mutex is an easy way to fix this, it was used right
before to allocate the 'id'

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---

diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
index b7292a2..9c31ad1 100644
--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -467,15 +467,17 @@ int net_assign_generic(struct net *net, int id, v=
oid *data)
 	BUG_ON(!mutex_is_locked(&net_mutex));
 	BUG_ON(id =3D=3D 0);
=20
+	mutex_lock(&net_mutex);
 	ng =3D old_ng =3D net->gen;
 	if (old_ng->len >=3D id)
 		goto assign;
=20
 	ng =3D kzalloc(sizeof(struct net_generic) +
 			id * sizeof(void *), GFP_KERNEL);
-	if (ng =3D=3D NULL)
+	if (ng =3D=3D NULL) {
+		mutex_unlock(&net_mutex);
 		return -ENOMEM;
-
+	}
 	/*
 	 * Some synchronisation notes:
 	 *
@@ -494,6 +496,7 @@ int net_assign_generic(struct net *net, int id, voi=
d *data)
 	call_rcu(&old_ng->rcu, net_generic_release);
 assign:
 	ng->ptr[id - 1] =3D data;
+	mutex_unlock(&net_mutex);
 	return 0;
 }
 EXPORT_SYMBOL_GPL(net_assign_generic);
