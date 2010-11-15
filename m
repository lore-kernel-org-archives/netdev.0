From: Chris Metcalf <cmetcalf@tilera.com>
Subject: Re: [PATCH] arch/tile: fix rwlock so would-be write lockers don't
 block new readers
Date: Mon, 15 Nov 2010 10:10:55 -0500
Message-ID: <4CE14D7F.1010307@tilera.com>
References: <AANLkTikvT=x9eBovn2-m6HLqk7wyXSAR3sc9jCQ0C6mL@mail.gmail.com>	 <1289489007.17691.1310.camel@edumazet-laptop>	 <AANLkTik93QUQxSDmwd4Qj-gXQiWWPzd68JPAYAHBAsHR@mail.gmail.com>	 <ZXmP8hjgLHA.4648@exchange1.tad.internal.tilera.com>	 <4CDF1945.8090101@tilera.com>	 <AANLkTind92uwcigzmDn8yn9a22exDy7zcreGQ5-6NLV-@mail.gmail.com>	 <201011151425.oAFEPU3W005682@farm-0010.internal.tilera.com> <1289832730.2607.87.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <linux-kernel@vger.kernel.org>,
	=?UTF-8?B?QW3DqXJpY28gV2FuZw==?= <xiyou.wangcong@gmail.com>,
	netdev <netdev@vger.kernel.org>, Cypher Wu <cypher.w@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usmamail.tilera.com ([72.1.168.231]:26863 "EHLO
	USMAMAIL.TILERA.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755066Ab0KOPK6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Nov 2010 10:10:58 -0500
In-Reply-To: <1289832730.2607.87.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/15/2010 9:52 AM, Eric Dumazet wrote:
> Le lundi 15 novembre 2010 =C3=A0 09:18 -0500, Chris Metcalf a =C3=A9c=
rit :
>> This avoids a deadlock in the IGMP code where one core gets a read
>> lock, another core starts trying to get a write lock (thus blocking
>> new readers), and then the first core tries to recursively re-acquir=
e
>> the read lock.
>>
>> We still try to preserve some degree of balance by giving priority
>> to additional write lockers that come along while the lock is held
>> for write, so they can all complete quickly and return the lock to
>> the readers.
>>
>> Signed-off-by: Chris Metcalf <cmetcalf@tilera.com>
>> ---
>> This should apply relatively cleanly to 2.6.26.7 source code too.
>>
>>  arch/tile/lib/spinlock_32.c |   29 ++++++++++++++++++-----------
>>  1 files changed, 18 insertions(+), 11 deletions(-)
>>
>> diff --git a/arch/tile/lib/spinlock_32.c b/arch/tile/lib/spinlock_32=
=2Ec
>> index 485e24d..5cd1c40 100644
>> --- a/arch/tile/lib/spinlock_32.c
>> +++ b/arch/tile/lib/spinlock_32.c
>> @@ -167,23 +167,30 @@ void arch_write_lock_slow(arch_rwlock_t *rwloc=
k, u32 val)
>>  	 * when we compare them.
>>  	 */
>>  	u32 my_ticket_;
>> +	u32 iterations =3D 0;
>> =20
>> -	/* Take out the next ticket; this will also stop would-be readers.=
 */
>> -	if (val & 1)
>> -		val =3D get_rwlock(rwlock);
>> -	rwlock->lock =3D __insn_addb(val, 1 << WR_NEXT_SHIFT);
>> +	/*
>> +	 * Wait until there are no readers, then bump up the next
>> +	 * field and capture the ticket value.
>> +	 */
>> +	for (;;) {
>> +		if (!(val & 1)) {
>> +			if ((val >> RD_COUNT_SHIFT) =3D=3D 0)
>> +				break;
>> +			rwlock->lock =3D val;
>> +		}
>> +		delay_backoff(iterations++);
> Are you sure a writer should have a growing delay_backoff() ?

We always do this bounded exponential backoff on all locking operations
that require memory-network traffic.  With 64 cores, it's possible
otherwise to get into a situation where the cores are attempting to acq=
uire
the lock sufficiently aggressively that lock acquisition performance is
worse than it would be with backoff.  In any case this path is unlikely=
 to
run many times, since it only triggers if two cores both try to pull a
ticket at the same time; it doesn't correspond to writers actually wait=
ing
once they have their ticket, which is handled later in this function.

> It seems to me this only allow new readers to come (so adding more
> unfairness to the rwlock, that already favor readers against writer[s=
])

Well, that is apparently the required semantic.  Once there is one read=
er,
you must allow new readers, to handle the case of recursive
re-acquisition.  In principle you could imagine doing something like ha=
ving
a bitmask of cores that held the readlock (instead of a count), and onl=
y
allowing recursive re-acquisition when a write lock request is pending,=
 but
this would make the lock structure bigger, and I'm not sure it's worth =
it.=20
x86 certainly doesn't bother.

> Maybe allow one cpu to spin, and eventually other 'writers' be queued=
 ?

Other than the brief spin to acquire the ticket, writers don't actually
spin on the lock.  They just wait for their ticket to come up.  This do=
es
require spinning on memory reads, but those are satisfied out of the lo=
cal
core's cache, with the exception that each time a writer completes, the
cache line is invalidated on the readers, and they have to re-fetch it =
from
the home cache.

>> +		val =3D __insn_tns((int *)&rwlock->lock);
>> +	}
>> =20
>> -	/* Extract my ticket value from the original word. */
>> +	/* Take out the next ticket and extract my ticket value. */
>> +	rwlock->lock =3D __insn_addb(val, 1 << WR_NEXT_SHIFT);
>>  	my_ticket_ =3D val >> WR_NEXT_SHIFT;
>> =20
>> -	/*
>> -	 * Wait until the "current" field matches our ticket, and
>> -	 * there are no remaining readers.
>> -	 */
>> +	/* Wait until the "current" field matches our ticket. */
>>  	for (;;) {
>>  		u32 curr_ =3D val >> WR_CURR_SHIFT;
>> -		u32 readers =3D val >> RD_COUNT_SHIFT;
>> -		u32 delta =3D ((my_ticket_ - curr_) & WR_MASK) + !!readers;
>> +		u32 delta =3D ((my_ticket_ - curr_) & WR_MASK);
>>  		if (likely(delta =3D=3D 0))
>>  			break;
>> =20
>

--=20
Chris Metcalf, Tilera Corp.
http://www.tilera.com

