From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] net: net_assign_generic()  fix
Date: Tue, 28 Jul 2009 14:36:15 +0200
Message-ID: <4A6EF0BF.2050801@gmail.com>
References: <bug-13760-10286@http.bugzilla.kernel.org/> <20090722134557.2457c5f5.akpm@linux-foundation.org> 	<43d009740907222339n50ebe411ya6453dc5a294b9a0@mail.gmail.com> 	<20090723000100.d74d6b1c.akpm@linux-foundation.org> <43d009740907272340g7f98ed55lfff38bfedd867a99@mail.gmail.com> <4A6EBA88.8030205@cosmosbay.com> <4A6ECA3A.4050309@openvz.org> <4A6EEF69.1050001@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Igor M Podlesny <for.poige+bugzilla.kernel.org@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	"David S. Miller" <davem@davemloft.net>
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:42870 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752703AbZG1Mga (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jul 2009 08:36:30 -0400
In-Reply-To: <4A6EEF69.1050001@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet a =C3=A9crit :
> Pavel Emelyanov a =C3=A9crit :
>> Eric Dumazet wrote:
>>> Igor M Podlesny a =C3=A9crit :
>>>> [...]
>>>>> Could have been a problem in net core, perhaps.
>>>>>
>>>>> Below is a ppp fix from 2.6.31, but it seems unlikely to fix your=
 problem.
>>>>>
>>>>> It would help if we could see that trace, please.  A digital phot=
o
>>>>> would suit.
>>>> 	Here it is:
>>>>
>>>> 		http://bugzilla.kernel.org/attachment.cgi?id=3D22516
>>>>
>>>> 	(It's 2.6.30.3)
>>>> =09
>>> Looking at this, I believe net_assign_generic() is not safe.
>>>
>>> Two cpus could try to expand/update the array at same time, one upd=
ate could be lost.
>>>
>>> register_pernet_gen_device() has a mutex to guard against concurren=
t
>>> calls, but net_assign_generic() has no locking at all.
>>>
>>> I doubt this is the reason of the crash, still worth to mention it.=
=2E.
>>>
>>> [PATCH] net: net_assign_generic() is not SMP safe
>>>
>>> Two cpus could try to expand/update the array at same time, one upd=
ate
>>> could be lost during the copy of old array.
>> How can this happen? The array is updated only during ->init routine=
s
>> of the pernet_operations, which are called from under the net_mutex.
>>
>> Do I miss anything?
>>
>=20
> Oops, I missed the obvious "BUG_ON(!mutex_is_locked(&net_mutex));"
>=20
> Sorry for the noise and untested patch as well :)
>

Hmm...

Real bug may be fixed by followed patch ? (yet untested, sorry...)

[PATCH] net: net_assign_generic() fix=20

memcpy() should take into account size of pointers,
not only number of pointers to copy.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
index b7292a2..1972830 100644
--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -488,7 +488,7 @@ int net_assign_generic(struct net *net, int id, voi=
d *data)
 	 */
=20
 	ng->len =3D id;
-	memcpy(&ng->ptr, &old_ng->ptr, old_ng->len);
+	memcpy(&ng->ptr, &old_ng->ptr, old_ng->len * sizeof(void*));
=20
 	rcu_assign_pointer(net->gen, ng);
 	call_rcu(&old_ng->rcu, net_generic_release);
