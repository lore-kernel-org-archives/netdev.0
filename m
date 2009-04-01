From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] x86: percpu_to_op() misses memory and flags clobbers
Date: Wed, 01 Apr 2009 12:14:24 +0200
Message-ID: <49D33E80.70802@cosmosbay.com>
References: <49D32212.80607@cosmosbay.com> <49D32DC2.9010003@goop.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ingo Molnar <mingo@elte.hu>, Tejun Heo <htejun@gmail.com>,
	linux kernel <linux-kernel@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Joe Perches <joe@perches.com>
To: Jeremy Fitzhardinge <jeremy@goop.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:37262 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757811AbZDAKO4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2009 06:14:56 -0400
In-Reply-To: <49D32DC2.9010003@goop.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeremy Fitzhardinge a =E9crit :
> Eric Dumazet wrote:
>> While playing with new percpu_{read|write|add|sub} stuff in network =
tree,
>> I found x86 asm was a litle bit optimistic.
>>
>> We need to tell gcc that percpu_{write|add|sub|or|xor} are modyfing
>> memory and possibly eflags. We could add another parameter to
>> percpu_to_op()
>> to separate the plain "mov" case (not changing eflags),
>> but let keep it simple for the moment.
>>  =20
>=20
> Did you observe an actual failure that this patch fixed?
>=20

Not in current tree, as we dont use yet percpu_xxxx() very much.

If deployed for SNMP mibs with hundred of call sites,
can you guarantee it will work as is ?

>> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
>>
>> diff --git a/arch/x86/include/asm/percpu.h
>> b/arch/x86/include/asm/percpu.h
>> index aee103b..fd4f8ec 100644
>> --- a/arch/x86/include/asm/percpu.h
>> +++ b/arch/x86/include/asm/percpu.h
>> @@ -82,22 +82,26 @@ do {                            \
>>      case 1:                        \
>>          asm(op "b %1,"__percpu_arg(0)        \
>>              : "+m" (var)            \
>> -            : "ri" ((T__)val));            \
>> +            : "ri" ((T__)val)            \
>> +            : "memory", "cc");            \
>>  =20
>=20
> This shouldn't be necessary.   The "+m" already tells gcc that var is=
 a
> memory input and output, and there are no other memory side-effects
> which it needs to be aware of; clobbering "memory" will force gcc to
> reload all register-cached memory, which is a pretty hard hit.  I thi=
nk
> all asms implicitly clobber "cc", so that shouldn't have any effect, =
but
> it does no harm.


So, we can probably cleanup many asms in tree :)

static inline void __down_read(struct rw_semaphore *sem)
{
        asm volatile("# beginning down_read\n\t"
                     LOCK_PREFIX "  incl      (%%eax)\n\t"
                     /* adds 0x00000001, returns the old value */
                     "  jns        1f\n"
                     "  call call_rwsem_down_read_failed\n"
                     "1:\n\t"
                     "# ending down_read\n\t"
                     : "+m" (sem->count)
                     : "a" (sem)
                     : "memory", "cc");
}




>=20
> Now, its true that the asm isn't actually modifying var itself, but
> %gs:var, which is a different location.  But from gcc's perspective t=
hat
> shouldn't matter because var makes a perfectly good proxy for that
> location, and will make sure it correctly order all accesses to var.
>=20
> I'd be surprised if this were broken, because we'd be seeing all sort=
s
> of strange crashes all over the place.  We've seen it before when the
> old x86-64 pda code didn't have proper constraints on its asm stateme=
nts.

I was not saying it is broken, but a "litle bit optimistic" :)

Better be safe than sorry, because those errors are very hard to track,=
 since
it depends a lot on gcc being aggressive or not. I dont have time to te=
st
all gcc versions all over there.


