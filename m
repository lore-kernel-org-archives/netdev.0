From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Kernel rwlock design, Multicore and IGMP
Date: Thu, 11 Nov 2010 16:32:22 +0100
Message-ID: <1289489542.17691.1325.camel@edumazet-laptop>
References: <AANLkTikvT=x9eBovn2-m6HLqk7wyXSAR3sc9jCQ0C6mL@mail.gmail.com>
	 <1289489007.17691.1310.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Cypher Wu <cypher.w@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1289489007.17691.1310.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le jeudi 11 novembre 2010 =C3=A0 16:23 +0100, Eric Dumazet a =C3=A9crit=
 :
> Le jeudi 11 novembre 2010 =C3=A0 21:49 +0800, Cypher Wu a =C3=A9crit =
:
>=20
> Hi
>=20
> CC netdev, since you ask questions about network stuff _and_ rwlock
>=20
>=20
> > I'm using TILEPro and its rwlock in kernel is a liitle different th=
an
> > other platforms. It have a priority for write lock that when tried =
it
> > will block the following read lock even if read lock is hold by
> > others. Its code can be read in Linux Kernel 2.6.36 in
> > arch/tile/lib/spinlock_32.c.
>=20
> This seems a bug to me.
>=20
> read_lock() can be nested. We used such a schem in the past in iptabl=
es
> (it can re-enter itself),
> and we used instead a spinlock(), but with many discussions with lkml
> and Linus himself if I remember well.

I meant, a percpu spinlock, and extra logic to spin_lock() it one time,
even if nested.

static inline void xt_info_rdlock_bh(void)
{
        struct xt_info_lock *lock;

        local_bh_disable();
        lock =3D &__get_cpu_var(xt_info_locks);
        if (likely(!lock->readers++))
                spin_lock(&lock->lock);
}

static inline void xt_info_rdunlock_bh(void)
{
        struct xt_info_lock *lock =3D &__get_cpu_var(xt_info_locks);

        if (likely(!--lock->readers))
                spin_unlock(&lock->lock);
        local_bh_enable();
}

The write 'rwlock' side has to lock the percpu spinlock of all possible
cpus.

/*
 * The "writer" side needs to get exclusive access to the lock,
 * regardless of readers.  This must be called with bottom half
 * processing (and thus also preemption) disabled.
 */
static inline void xt_info_wrlock(unsigned int cpu)
{
        spin_lock(&per_cpu(xt_info_locks, cpu).lock);
}

static inline void xt_info_wrunlock(unsigned int cpu)
{
        spin_unlock(&per_cpu(xt_info_locks, cpu).lock);
}
