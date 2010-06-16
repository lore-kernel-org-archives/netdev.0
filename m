From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: rt hash table / rt hash locks question
Date: Wed, 16 Jun 2010 14:27:38 +0200
Message-ID: <1276691258.2632.55.camel@edumazet-laptop>
References: <20100616104633.GW6138@laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Nick Piggin <npiggin@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:34651 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754402Ab0FPM1o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jun 2010 08:27:44 -0400
Received: by wyb40 with SMTP id 40so5632510wyb.19
        for <netdev@vger.kernel.org>; Wed, 16 Jun 2010 05:27:42 -0700 (PDT)
In-Reply-To: <20100616104633.GW6138@laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 16 juin 2010 =C3=A0 20:46 +1000, Nick Piggin a =C3=A9crit :
> I'm just converting this scalable dentry/inode hash table to a more
> compact form. I was previously using a dumb spinlock per bucket,
> but this doubles the size of the tables so isn't production quality.
>=20

Yes, we had this in the past (one rwlock or spinlock per hash chain),
and it was not very good with LOCKDEP on.

> What I've done at the moment is to use a bit_spinlock in bit 0 of eac=
h
> list pointer of the table. Bit spinlocks are now pretty nice because
> we can do __bit_spin_unlock() which gives non-atomic store with relea=
se
> ordering, so it should be almost as fast as spinlock.
>=20
> But I look at rt hash and it seems you use a small hash on the side
> for spinlocks. So I wonder, pros for each:
>=20
> - bitlocks have effectively zero storage
    yes but a mask is needed to get head pointer. Special care also mus=
t
be taken when insert/delete a node in chain, keeping this bit set.

> - bitlocks hit the same cacheline that the hash walk hits.
    yes
> - in RCU list, locked hash walks usually followed by hash modificatio=
n,
>   bitlock should have brought in the line for exclusive.
    But we usually perform a read only lookup, _then_ take the lock, to
perform a new lookup before insert. So at time we would take the
bitlock, cache line is in shared state. With spinlocks, we always use
the exclusive mode, but on a separate cache line...

> - bitlock number of locks scales with hash size
    Yes, but concurrency is more a function of online cpus, given we us=
e
jhash.=20

> - spinlocks may be slightly better at the cacheline level (bitops
>   sometimes require explicit load which may not acquire exclusive
>   line on some archs). On x86 ll/sc architectures, this shouldn't
>   be a problem.
    Yes, you can add fairness (if ticket spinlocks variant used), but o=
n
route cache I really doubt it can make a difference.

> - spinlocks better debugging (could be overcome with a LOCKDEP
>   option to revert to spinlocks, but a bit ugly).
	Definitely a good thing.

> - in practice, contention due to aliasing in buckets to lock mapping
>   is probably fairly minor.
     Agreed
>=20
> Net code is obviously tested and tuned well, but instinctively I woul=
d
> have tought bitlocks are the better way to go. Any comments on this?

Well, to be honest, this code is rather old, and at time I wrote it,
bitlocks were probably not available.

You can add :

- One downside of the hashed spinlocks is the X86_INTERNODE_CACHE_SHIFT
being 12 on X86_VSMP : All locks are probably in same internode block :=
(

- Another downside is all locks are currently on a single NUMA node,
since we kmalloc() them in one contiguous chunk.

So I guess it would be worth to try :)


