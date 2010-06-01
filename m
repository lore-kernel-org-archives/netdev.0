From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] use unfair spinlock when running on hypervisor.
Date: Tue, 01 Jun 2010 23:39:14 +0200
Message-ID: <1275428354.2638.104.camel@edumazet-laptop>
References: <20100601093515.GH24302@redhat.com>
	 <87sk56ycka.fsf@basil.nowhere.org> <20100601162414.GA6191@redhat.com>
	 <20100601163807.GA11880@basil.fritz.box>  <4C053ACC.5020708@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andi Kleen <andi@firstfloor.org>, Gleb Natapov <gleb@redhat.com>,
	linux-kernel@vger.kernel.org, kvm@vger.kernel.org, hpa@zytor.com,
	mingo@elte.hu, npiggin@suse.de, tglx@linutronix.de,
	mtosatti@redhat.com, netdev <netdev@vger.kernel.org>
To: Avi Kivity <avi@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4C053ACC.5020708@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mardi 01 juin 2010 =C3=A0 19:52 +0300, Avi Kivity a =C3=A9crit :

> What I'd like to see eventually is a short-term-unfair, long-term-fai=
r=20
> spinlock.  Might make sense for bare metal as well.  But it won't be=20
> easy to write.
>=20

This thread rings a bell here :)

Yes, ticket spinlocks are sometime slower, especially in workloads wher=
e
a spinlock needs to be taken several times to handle one unit of work,
and many cpus competing.

We currently have kind of a similar problem in network stack, and we
have a patch to speedup xmit path by an order of magnitude, letting one
cpu (the consumer cpu) to get unfair access to the (ticket) spinlock.
(It can compete with no more than one other cpu)

Boost from ~50.000 to ~600.000 pps on a dual quad core machine (E5450
@3.00GHz) on a particular workload (many cpus want to xmit their
packets)

( patch : http://patchwork.ozlabs.org/patch/53163/ )


It could be possible to write such a generic beast, with a cascade or
regular ticket spinlocks ?

One ticket spinlock at first stage (only if some conditions are met, ak=
a
slow path), then an 'primary' spinlock at second stage.


// generic implementation
// (x86 could use 16bit fields for users_in & user_out)
struct cascade_lock {
	atomic_t 	users_in;
	int		users_out;
	spinlock_t	primlock;
	spinlock_t	slowpathlock; // could be outside of this structure, shared=
 by many 'cascade_locks'
};

/*
 * In kvm case, you might call hypervisor when slowpathlock is about to=
 be taken ?
 * When a cascade lock is unlocked, and relocked right after, this cpu =
has unfair
 * priority and could get the lock before cpus blocked in slowpathlock =
(especially if
 * an hypervisor call was done)
 *
 * In network xmit path, the dequeue thread would use highprio_user=3Dt=
rue mode
 * In network xmit path, the 'contended' enqueueing thread would set a =
negative threshold,
 *  to force a 'lowprio_user' mode.
 */
void cascade_lock(struct cascade_lock *l, bool highprio_user, int thres=
hold)
{
	bool slowpath =3D false;

	atomic_inc(&l->users_in); // no real need for atomic_inc_return()
	if (atomic_read(&l->users_in) - l->users_out > threshold && !highprio_=
user)) {
		spin_lock(&l->slowpathlock);
		slowpath =3D true;
	}
	spin_lock(&l->primlock);
	if (slowpath)
		spin_unlock(&l->slowpathlock);
}

void cascade_unlock(struct cascade_lock *l)
{
	l->users_out++;
	spin_unlock(&l->primlock);
}
