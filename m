From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC,PATCH] mutex: mutex_is_owner() helper
Date: Wed, 04 Nov 2009 18:19:35 +0100
Message-ID: <4AF1B7A7.6030902@gmail.com>
References: <4AF19D06.3060401@gmail.com> <20091104154015.GA32567@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	linux kernel <linux-kernel@vger.kernel.org>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:38893 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757149AbZKDRTl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2009 12:19:41 -0500
In-Reply-To: <20091104154015.GA32567@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ingo Molnar a =E9crit :

> To make sure this does not extend mutexes to be used a recursive=20
> mutexes, mind naming it more clearly, like debug_mutex_is_owned(), an=
d=20
> adding a comment that says that this shouldnt be taken?
>=20
> Also, it's somewhat imprecise: on !SMP && !DEBUG_MUTEXES we might ret=
urn=20
> a false '1'. Which happens to work for the rtnl usecase - but might n=
ot=20
> in other cases.
>

Sure, we can chose another name, but what do you mean by a false '1' ?

1 means mutex is locked and that we could not check ownership.
(best effort, ie same imprecise result than mutex_is_locked())


BTW, I was thinking of a mutex_yield() implementation, but could not
cook it without hard thinking, maybe you already have some nice impleme=
ntation ?

We have some uses of "mutex_unlock();mutex_lock();" things that are
not working nicely because current thread immediately takes again mutex=
=2E


a true mutex_yield() would force current thread to go at the end of wai=
t_list.

int mutex_yield(struct mutex *lock)
{
	unsigned long flags;

	// OK to test list without locking
	if (list_empty(&lock->wait_list))
		return 0;

	spin_lock_mutex(&lock->wait_lock, flags);
	if (!list_empty(&lock->wait_list)) {
		atomic_xchg(&lock->count, 1);// free mutex
		list_add_tail(&waiter.list, &lock->wait_list);//insert me at tail of =
wait_list
		wake head of wait_list
		__mutex_lock_common_condadd(mutex, TASK_UNINTERRUPTIBLE, DONT_ADD_TAI=
L, ...);
	} else {
		spin_unlock_mutex(&lock->wait_lock, flags);
	}
	return 1;
}


Or maybe we should try something less complex (slowpath anyway)

int mutex_yield(struct mutex *lock)
{
	int ret =3D 0;

	if (mutex_needbreak(lock) || should_resched()) {
		mutex_unlock(lock);=20
		__cond_resched();
		mutex_lock(lock);
		ret =3D 1;
	}
	return ret;
}

Thanks
