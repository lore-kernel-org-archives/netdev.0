From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCHv5 2/2] memory barrier: adding smp_mb__after_lock
Date: Tue, 07 Jul 2009 16:42:01 +0200
Message-ID: <4A535EB9.2020406@gmail.com>
References: <20090703081219.GE2902@jolsa.lab.eng.brq.redhat.com> <20090703081445.GG2902@jolsa.lab.eng.brq.redhat.com> <20090703090606.GA3902@elte.hu> <4A4DCD54.1080908@gmail.com> <20090703092438.GE3902@elte.hu> <20090703095659.GA4518@jolsa.lab.eng.brq.redhat.com> <20090703102530.GD32128@elte.hu> <20090703111848.GA10267@jolsa.lab.eng.brq.redhat.com> <20090707101816.GA6619@jolsa.lab.eng.brq.redhat.com> <20090707134601.GB6619@jolsa.lab.eng.brq.redhat.com> <20090707140135.GA5506@Krystal>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jiri Olsa <jolsa@redhat.com>, Ingo Molnar <mingo@elte.hu>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	fbl@redhat.com, nhorman@redhat.com, davem@redhat.com,
	htejun@gmail.com, jarkao2@gmail.com, oleg@redhat.com,
	davidel@xmailserver.org
To: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:57645 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756672AbZGGOmf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jul 2009 10:42:35 -0400
In-Reply-To: <20090707140135.GA5506@Krystal>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mathieu Desnoyers a =E9crit :
> * Jiri Olsa (jolsa@redhat.com) wrote:
>> On Tue, Jul 07, 2009 at 12:18:16PM +0200, Jiri Olsa wrote:
>>> On Fri, Jul 03, 2009 at 01:18:48PM +0200, Jiri Olsa wrote:
>>>> On Fri, Jul 03, 2009 at 12:25:30PM +0200, Ingo Molnar wrote:
>>>>> * Jiri Olsa <jolsa@redhat.com> wrote:
>>>>>
>>>>>> On Fri, Jul 03, 2009 at 11:24:38AM +0200, Ingo Molnar wrote:
>>>>>>> * Eric Dumazet <eric.dumazet@gmail.com> wrote:
>>>>>>>
>>>>>>>> Ingo Molnar a =E9crit :
>>>>>>>>> * Jiri Olsa <jolsa@redhat.com> wrote:
>>>>>>>>>
>>>>>>>>>> +++ b/arch/x86/include/asm/spinlock.h
>>>>>>>>>> @@ -302,4 +302,7 @@ static inline void __raw_write_unlock(ra=
w_rwlock_t *rw)
>>>>>>>>>>  #define _raw_read_relax(lock)	cpu_relax()
>>>>>>>>>>  #define _raw_write_relax(lock)	cpu_relax()
>>>>>>>>>> =20
>>>>>>>>>> +/* The {read|write|spin}_lock() on x86 are full memory barr=
iers. */
>>>>>>>>>> +#define smp_mb__after_lock() do { } while (0)
>>>>>>>>> Two small stylistic comments, please make this an inline func=
tion:
>>>>>>>>>
>>>>>>>>> static inline void smp_mb__after_lock(void) { }
>>>>>>>>> #define smp_mb__after_lock
>>>>>>>>>
>>>>>>>>> (untested)
>>>>>>>>>
>>>>>>>>>> +/* The lock does not imply full memory barrier. */
>>>>>>>>>> +#ifndef smp_mb__after_lock
>>>>>>>>>> +#define smp_mb__after_lock() smp_mb()
>>>>>>>>>> +#endif
>>>>>>>>> ditto.
>>>>>>>>>
>>>>>>>>> 	Ingo
>>>>>>>> This was following existing implementations of various smp_mb_=
_??? helpers :
>>>>>>>>
>>>>>>>> # grep -4 smp_mb__before_clear_bit include/asm-generic/bitops.=
h
>>>>>>>>
>>>>>>>> /*
>>>>>>>>  * clear_bit may not imply a memory barrier
>>>>>>>>  */
>>>>>>>> #ifndef smp_mb__before_clear_bit
>>>>>>>> #define smp_mb__before_clear_bit()      smp_mb()
>>>>>>>> #define smp_mb__after_clear_bit()       smp_mb()
>>>>>>>> #endif
>>>>>>> Did i mention that those should be fixed too? :-)
>>>>>>>
>>>>>>> 	Ingo
>>>>>> ok, could I include it in the 2/2 or you prefer separate patch?
>>>>> depends on whether it will regress ;-)
>>>>>
>>>>> If it regresses, it's better to have it separate. If it wont, it =
can=20
>>>>> be included. If unsure, default to the more conservative option.
>>>>>
>>>>> 	Ingo
>>>>
>>>> how about this..=20
>>>> and similar change for smp_mb__before_clear_bit in a separate patc=
h
>>>>
>>>>
>>>> diff --git a/arch/x86/include/asm/spinlock.h b/arch/x86/include/as=
m/spinlock.h
>>>> index b7e5db8..4e77853 100644
>>>> --- a/arch/x86/include/asm/spinlock.h
>>>> +++ b/arch/x86/include/asm/spinlock.h
>>>> @@ -302,4 +302,8 @@ static inline void __raw_write_unlock(raw_rwlo=
ck_t *rw)
>>>>  #define _raw_read_relax(lock)	cpu_relax()
>>>>  #define _raw_write_relax(lock)	cpu_relax()
>>>> =20
>>>> +/* The {read|write|spin}_lock() on x86 are full memory barriers. =
*/
>>>> +static inline void smp_mb__after_lock(void) { }
>>>> +#define ARCH_HAS_SMP_MB_AFTER_LOCK
>>>> +
>>>>  #endif /* _ASM_X86_SPINLOCK_H */
>>>> diff --git a/include/linux/spinlock.h b/include/linux/spinlock.h
>>>> index 252b245..4be57ab 100644
>>>> --- a/include/linux/spinlock.h
>>>> +++ b/include/linux/spinlock.h
>>>> @@ -132,6 +132,11 @@ do {								\
>>>>  #endif /*__raw_spin_is_contended*/
>>>>  #endif
>>>> =20
>>>> +/* The lock does not imply full memory barrier. */
>>>> +#ifndef ARCH_HAS_SMP_MB_AFTER_LOCK
>>>> +static inline void smp_mb__after_lock(void) { smp_mb(); }
>>>> +#endif
>>>> +
>>>>  /**
>>>>   * spin_unlock_wait - wait until the spinlock gets unlocked
>>>>   * @lock: the spinlock in question.
>>>> diff --git a/include/net/sock.h b/include/net/sock.h
>>>> index 4eb8409..98afcd9 100644
>>>> --- a/include/net/sock.h
>>>> +++ b/include/net/sock.h
>>>> @@ -1271,6 +1271,9 @@ static inline int sk_has_allocations(const s=
truct sock *sk)
>>>>   * in its cache, and so does the tp->rcv_nxt update on CPU2 side.=
  The CPU1
>>>>   * could then endup calling schedule and sleep forever if there a=
re no more
>>>>   * data on the socket.
>>>> + *
>>>> + * The sk_has_helper is always called right after a call to read_=
lock, so we
>>>> + * can use smp_mb__after_lock barrier.
>>>>   */
>>>>  static inline int sk_has_sleeper(struct sock *sk)
>>>>  {
>>>> @@ -1280,7 +1283,7 @@ static inline int sk_has_sleeper(struct sock=
 *sk)
>>>>  	 *
>>>>  	 * This memory barrier is paired in the sock_poll_wait.
>>>>  	 */
>>>> -	smp_mb();
>>>> +	smp_mb__after_lock();
>>>>  	return sk->sk_sleep && waitqueue_active(sk->sk_sleep);
>>>>  }
>>>> =20
>>> any feedback on this?=20
>>> I'd send v6 if this way is acceptable..
>>>
>>> thanks,
>>> jirka
>> also I checked the smp_mb__before_clear_bit/smp_mb__after_clear_bit =
and
>> it is used quite extensivelly.
>>
>> I'd prefer to send it in a separate patch, so we can move on with th=
e=20
>> changes I've sent so far..
>>
>=20
> As with any optimization (and this is one that adds a semantic that w=
ill
> just grow the memory barrier/locking rule complexity), it should come
> with performance benchmarks showing real-life improvements.
>=20
> Otherwise I'd recommend sticking to smp_mb() if this execution path i=
s
> not that critical, or to move to RCU if it's _that_ critical.
>=20
> A valid argument would be if the data structures protected are so
> complex that RCU is out of question but still the few cycles saved by
> removing a memory barrier are really significant. And even then, the
> proper solution would be more something like a
> __read_lock()+smp_mb+smp_mb+__read_unlock(), so we get the performanc=
e
> improvements on architectures other than x86 as well.
>=20
> So in all cases, I don't think the smp_mb__after_lock() is the
> appropriate solution.

RCU on this part is out of the question, as David already mentioned it.

It would be a regression for short lived tcp/udp sessions, and some wor=
kloads
use them a lot...

We gained about 20% performance between 2.6.26 and 2.6.31, carefuly rem=
oving
some atomic ops in network stack, adding RCU where it was sensible, but=
 this
is a painful process, not something Jiri can use to fix bugs on legacy =
RedHat
kernels :) (We still are sorting out regressions)

To solve problem pointed by Jiri, we have to insert an smp_mb() at this=
 point,
(not mentioning the other change in select() logic of course)

 static void sock_def_readable(struct sock *sk, int len)
 {
 	read_lock(&sk->sk_callback_lock);
+	smp_mb(); /* paired with opposite smp_mb() in sk poll logic */
 	if (sk->sk_sleep && waitqueue_active(sk->sk_sleep))
 		wake_up_interruptible_sync_poll(sk->sk_sleep, POLLIN |
 						POLLRDNORM | POLLRDBAND);
 	sk_wake_async(sk, SOCK_WAKE_WAITD, POLL_IN);
 	read_unlock(&sk->sk_callback_lock);
 }

As about every incoming packet calls this path, we should be very caref=
ul not
slowing down stack if not necessary.

On x86 this extra smp_mb() is not needed, since previous call to read_l=
ock()
already gives the full barrier for free.


