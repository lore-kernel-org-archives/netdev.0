From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Kernel rwlock design, Multicore and IGMP
Date: Thu, 11 Nov 2010 16:23:27 +0100
Message-ID: <1289489007.17691.1310.camel@edumazet-laptop>
References: <AANLkTikvT=x9eBovn2-m6HLqk7wyXSAR3sc9jCQ0C6mL@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Cypher Wu <cypher.w@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AANLkTikvT=x9eBovn2-m6HLqk7wyXSAR3sc9jCQ0C6mL@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le jeudi 11 novembre 2010 =C3=A0 21:49 +0800, Cypher Wu a =C3=A9crit :

Hi

CC netdev, since you ask questions about network stuff _and_ rwlock


> I'm using TILEPro and its rwlock in kernel is a liitle different than
> other platforms. It have a priority for write lock that when tried it
> will block the following read lock even if read lock is hold by
> others. Its code can be read in Linux Kernel 2.6.36 in
> arch/tile/lib/spinlock_32.c.

This seems a bug to me.

read_lock() can be nested. We used such a schem in the past in iptables
(it can re-enter itself),
and we used instead a spinlock(), but with many discussions with lkml
and Linus himself if I remember well.


>=20
> That different could cause a deadlock in kernel if we join/leave
> Multicast Group simultaneous and frequently on mutlicores. IGMP
> message is sent by
>=20
> igmp_ifc_timer_expire() -> igmpv3_send_cr() -> igmpv3_sendpack()
>=20
> in timer interrupt, igmpv3_send_cr() will generate the sk_buff for
> IGMP message with mc_list_lock read locked and then call
> igmpv3_sendpack() with it unlocked.
> But if we have so many join/leave messages have to generate and it
> can't be sent in one sk_buff then igmpv3_send_cr() -> add_grec() will
> call igmpv3_sendpack() to send it and reallocate a new buffer. When
> the message is sent:
>=20
> __mkroute_output() -> ip_check_mc()
>=20
> will read lock mc_list_lock again. If there is another core is try
> write lock mc_list_lock between the two read lock, then deadlock
> ocurred.
>=20
> The rwlock on other platforms I've check, say, PowerPC, x86, ARM, is
> just read lock shared and write_lock mutex, so if we've hold read loc=
k
> the write lock will just wait, and if there have a read lock again it
> will success.
>=20
> So, What's the criteria of rwlock design in the Linux kernel? Is that
> read lock re-hold of IGMP a design error in Linux kernel, or the read
> lock has to be design like that?
>=20

Well, we try to get rid of all rwlocks in performance critical sections=
=2E

I would say, if you believe one rwlock can justify the special TILE
behavior you tried to make, then we should instead migrate this rwlock
to a RCU + spinlock schem (so that all arches benefit from this work,
not only TILE)

> There is a other thing, that the timer interrupt will start timer on
> the same in_dev, should that be optimized?
>=20

Not sure I understand what you mean.

> BTW: If we have so many cores, say 64, is there other things we have
> to think about spinlock? If there have collisions ocurred, should we
> just read the shared memory again and again, or just a very little
> 'delay' is better? I've seen relax() is called in the implementation
> of spinlock on TILEPro platform.
> --

Is TILE using ticket spinlocks ?
