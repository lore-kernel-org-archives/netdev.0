From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] netfilter: use per-cpu recursive spinlock  (v6)
Date: Thu, 16 Apr 2009 20:41:58 +0200
Message-ID: <49E77BF6.1080206@cosmosbay.com>
References: <20090415135526.2afc4d18@nehalam> <49E64C91.5020708@cosmosbay.com> <20090415.164811.19905145.davem@davemloft.net> <20090415170111.6e1ca264@nehalam> <alpine.LFD.2.00.0904151705120.4042@localhost.localdomain> <20090415174551.529d241c@nehalam> <49E6BBA9.2030701@cosmosbay.com> <49E7384B.5020707@trash.net> <20090416144748.GB6924@linux.vnet.ibm.com> <49E75876.10509@cosmosbay.com> <20090416175850.GH6924@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>, jeff.chua.linux@gmail.com,
	paulus@samba.org, mingo@elte.hu, laijs@cn.fujitsu.com,
	jengelh@medozas.de, r000n@r000n.net, linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	benh@kernel.crashing.org
To: paulmck@linux.vnet.ibm.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758765AbZDPSmn@vger.kernel.org>
In-Reply-To: <20090416175850.GH6924@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



Paul E. McKenney a =E9crit :
>=20
> But if some other CPU holds the lock, this code would fail to wait fo=
r
> that other CPU to release the lock, right?  It also might corrupt the
> rl->count field due to two CPUs accessing it concurrently non-atomica=
lly.

If another cpu holds the lock, this cpu will spin on its own lock.

Remember other cpus dont touch rl->count. This is a private field, only=
 touched
by the cpu on its own per_cpu data. There is no possible 'corruption'


So the owner of the per_cpu data does :

/*
 * disable preemption, get rl =3D &__get_cpu_var(arp_tables_lock);
 * then :
 */
lock_time :
if (++rl->count =3D=3D 0)
	spin_lock(&rl->lock);

unlock_time:
if (likely(--rl->count =3D=3D 0))
	spin_unlock(&rl->lock);


while other cpus only do :

spin_lock(&rl->lock);
/* work on data */
spin_unlock(&rl->lock);

So they cannot corrupt 'count' stuff.

>=20
> I suggest the following, preferably in a function or macro or somethi=
ng:
>=20
> 	cur_cpu =3D smp_processor_id();
> 	if (likely(rl->owner !=3D cur_cpu) {
> 		spin_lock(&rl->lock);
> 		rl->owner =3D smp_processor_id();
> 		rl->count =3D 1;
> 	} else {
> 		rl->count++;
> 	}
>=20
> And the inverse for unlock.
>=20
> Or am I missing something subtle?

Apparently Linus missed it too, and reacted badly to my mail.
I dont know why we discuss of this stuff on lkml either...

I stop working on this subject and consider drinking dome hard stuf and
watching tv :)

See you
