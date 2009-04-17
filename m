From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] netfilter: use per-cpu recursive spinlock  (v6)
Date: Thu, 16 Apr 2009 17:13:04 -0700
Message-ID: <20090417001304.GA21657@linux.vnet.ibm.com>
References: <20090415.164811.19905145.davem@davemloft.net> <20090415170111.6e1ca264@nehalam> <alpine.LFD.2.00.0904151705120.4042@localhost.localdomain> <20090415174551.529d241c@nehalam> <49E6BBA9.2030701@cosmosbay.com> <49E7384B.5020707@trash.net> <20090416144748.GB6924@linux.vnet.ibm.com> <49E75876.10509@cosmosbay.com> <20090416175850.GH6924@linux.vnet.ibm.com> <49E77BF6.1080206@cosmosbay.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>, jeff.chua.linux@gmail.com,
	paulus@samba.org, mingo@elte.hu, laijs@cn.fujitsu.com,
	jengelh@medozas.de, r000n@r000n.net, linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	benh@kernel.crashing.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <49E77BF6.1080206@cosmosbay.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 16, 2009 at 08:41:58PM +0200, Eric Dumazet wrote:
>=20
>=20
> Paul E. McKenney a =E9crit :
> >=20
> > But if some other CPU holds the lock, this code would fail to wait =
for
> > that other CPU to release the lock, right?  It also might corrupt t=
he
> > rl->count field due to two CPUs accessing it concurrently non-atomi=
cally.
>=20
> If another cpu holds the lock, this cpu will spin on its own lock.
>=20
> Remember other cpus dont touch rl->count. This is a private field, on=
ly touched
> by the cpu on its own per_cpu data. There is no possible 'corruption'

Ah!!!  I must confess that I didn't make it that far into the code...

> So the owner of the per_cpu data does :
>=20
> /*
>  * disable preemption, get rl =3D &__get_cpu_var(arp_tables_lock);
>  * then :
>  */
> lock_time :
> if (++rl->count =3D=3D 0)
> 	spin_lock(&rl->lock);
>=20
> unlock_time:
> if (likely(--rl->count =3D=3D 0))
> 	spin_unlock(&rl->lock);
>=20
>=20
> while other cpus only do :
>=20
> spin_lock(&rl->lock);
> /* work on data */
> spin_unlock(&rl->lock);
>=20
> So they cannot corrupt 'count' stuff.

OK, that does function.  Hurts my head, though.  ;-)

> > I suggest the following, preferably in a function or macro or somet=
hing:
> >=20
> > 	cur_cpu =3D smp_processor_id();
> > 	if (likely(rl->owner !=3D cur_cpu) {
> > 		spin_lock(&rl->lock);
> > 		rl->owner =3D smp_processor_id();
> > 		rl->count =3D 1;
> > 	} else {
> > 		rl->count++;
> > 	}
> >=20
> > And the inverse for unlock.
> >=20
> > Or am I missing something subtle?
>=20
> Apparently Linus missed it too, and reacted badly to my mail.
> I dont know why we discuss of this stuff on lkml either...

Encapsulating them so that they appear in the same place might (or migh=
t
not) have gotten the fact that you were not doing a recursive lock
through my head.  Even so, the name "rec_lock" might have overwhelmed
the code structure in my mind.  ;-)

> I stop working on this subject and consider drinking dome hard stuf a=
nd
> watching tv :)

That -is- extreme!  ;-)

							Thanx, Paul

> See you
>=20
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
