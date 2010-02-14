From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH tip/core/rcu 05/13] net: add checking to
 rcu_dereference()  primitives
Date: Sun, 14 Feb 2010 09:50:15 +0100
Message-ID: <1266137415.2939.11.camel@edumazet-laptop>
References: <20100212000016.GA25781@linux.vnet.ibm.com>
	 <1265932839-25899-5-git-send-email-paulmck@linux.vnet.ibm.com>
	 <1265948152.2891.25.camel@edumazet-laptop>
	 <e2d7436a1002140034h74617164p1a5dc90df3587095@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	linux-kernel@vger.kernel.org, mingo@elte.hu, laijs@cn.fujitsu.com,
	dipankar@in.ibm.com, akpm@linux-foundation.org,
	mathieu.desnoyers@polymtl.ca, josh@joshtriplett.org,
	dvhltc@us.ibm.com, niv@us.ibm.com, tglx@linutronix.de,
	peterz@infradead.org, rostedt@goodmis.org, Valdis.Kletnieks@vt.edu,
	dhowells@redhat.com, David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirqus@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <e2d7436a1002140034h74617164p1a5dc90df3587095@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le dimanche 14 f=C3=A9vrier 2010 =C3=A0 09:34 +0100, Micha=C5=82 Miros=C5=
=82aw a =C3=A9crit :
> 2010/2/12 Eric Dumazet <eric.dumazet@gmail.com>:
> > Le jeudi 11 f=C3=A9vrier 2010 =C3=A0 16:00 -0800, Paul E. McKenney =
a =C3=A9crit :
> [...]
> >> @@ -1654,12 +1654,12 @@ static struct dn_route *dn_rt_cache_get_fi=
rst(struct seq_file *seq)
> >>
> >>       for(s->bucket =3D dn_rt_hash_mask; s->bucket >=3D 0; --s->bu=
cket) {
> >>               rcu_read_lock_bh();
> >> -             rt =3D dn_rt_hash_table[s->bucket].chain;
> >> +             rt =3D rcu_dereference_bh(dn_rt_hash_table[s->bucket=
].chain);
> >>               if (rt)
> >>                       break;
> >>               rcu_read_unlock_bh();
> >>       }
> >> -     return rcu_dereference(rt);
> >> +     return rt;
> >>  }
>=20
> Isn't there a bug? Looks like data pointed to by rt should be
> protected by RCU, but the rcu_read_lock is withdrawn before access.
>=20

Not really a bug, since we exit from dn_rt_cache_get_first() with
rcu_read_lock_bh()

We call the unlock only if NULL is returned, and rcu_dereference(NULL)
can be done in any context.

Paul had to move the rcu_dereference() so that no lockdep warning
triggers for rcu_dereference(NULL), its more a cleanup than a bug fix.
