From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: include/linux/pcounter.h
Date: Sat, 16 Feb 2008 11:07:29 +0100
Message-ID: <47B6B5E1.90705@cosmosbay.com>
References: <20080204014402.1c55d3fe.akpm@linux-foundation.org> <20080215193711.2e3d41f3.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from neuf-infra-smtp-out-sp604007av.neufgp.fr ([84.96.92.120]:48418
	"EHLO neuf-infra-smtp-out-sp604007av.neufgp.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751763AbYBPKH2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Feb 2008 05:07:28 -0500
In-Reply-To: <20080215193711.2e3d41f3.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Morton a =E9crit :
> - First up, why was this added at all?  We have percpu_counter.h whic=
h
>   has several years development invested in it.  afaict it would suit=
 the
>   present applications of pcounters.
>=20
>   If some deficiency in percpu_counters has been identified, is it
>   possible to correct that deficiency rather than implementing a whol=
e new
>   counter type?  That would be much better.
>=20
> - The comments in pcounter.h appear to indicate that there is a
>   performance advantage (and we infer that the advantage is when the
>   statically-allocated flavour of pcounters is used).  When compared =
with
>   percpu_counters the number of data-reference indirections is the sa=
me as
>   with percpu_counters, so no advantage there.
>=20
>   And, bizarrely, because of a quite inappropriate abstraction toy, b=
oth
>   flavours of pcounters add an indirect function call which I believe=
 is
>   significantly more expensive than a plain old pointer indirection.
>=20
>   So it's quite possible that DEFINE_PCOUNTER-style counters consume =
more
>   memory and are slower than percpu_counters.  They will surely be mu=
ch
>   slower on the read side.  More below.
>=20
>   If we really want to put some helper wrappers around
>   DEFINE_PER_CPU(s32) then I'd suggest that we should do that as a
>   standalone thing and not attempt to graft the same interface onto t=
wo
>   quite different types of storage (DEFINE_PER_CPU and alloc_per_cpu)
>=20
> - The comment "2)" in pcounter.h (which overflows 80 cols and probabl=
y
>   wasn't passed through checkpatch) indicates that some other
>   implementation (presumably plain old DEFINE_PER_CPU) will use
>   NR_CPUS*(32+sizeof(void *)) bytes of storage.  But DEFINE_PCOUNTER =
will
>   use as much memory as DEFINE_PER_CPU(s32) and both pcounter_alloc()=
-style
>   pcounters and percpu_counters use
>   num_possible_cpus()*sizeof(s32)+epsilon.
>=20
> - The CONFIG_SMP=3Dn stubs in pcounter.h are cheesy and are vulnerabl=
e to
>   several well-known compilation risks which I always forget.  Should=
 be
>   converted to regular static inlines.
>=20
> - the comment in lib/pcounter.c needlessly exceeds 80 cols.
>=20
> - pcounter_dyn_add() will spew a
>   use-of-smp_processor_id()-in-preemptible-code warning if used in pl=
aces
>   where one could reasonably use it.  The interface could do with a b=
it of
>   a rethink.  Or at least some justification and documentation.
>=20
> - pcounter_getval() will be disastrously inefficient if
>   num_possible_cpus() is much greater than num_online_cpus().  It sho=
uld
>   use for_each_online_cpu() (as does percpu_counter), and implement a=
 CPU
>   hotplug notifier (as does percpu_counter).
>=20
>   It will remain grossly inefficient at high CPU counts, unlike
>   percpu_counters, which solved this problem by doing a batched spill=
 into
>   a central counter at add/sub time.
>=20
>   The danger here is that someone will actually use this interface in=
 new
>   code.  Six months later (when it's too late to fix it) the big-NUMA=
 guys
>   come up and say "whaa, when our user does <this> it disabled interr=
upts
>   for N milliseconds".
>=20
> - pcounter_getval() can return incorrect negative numbers.  This can
>   cause caller malfunctions in very rare situations because callers j=
ust
>   don't expect the things which they're counting to go negative.
>=20
>   We experienced this during the evolution of percpu_counter.  See
>   percpu_counter_sum_positive() and friends.
>=20
> - pcounter_alloc() should return -ENOMEM on allocation error, not "1"=
=2E
>=20
> - pcounter_free() perhaps shouldn't test for (self->per_cpu_values !=3D
>   NULL), because callers shouldn't be calling it if pcounter_alloc() =
failed
>   (arguable).
>=20
>=20
>=20
> afaict the whole implementation can and should be removed and replace=
d with
> percpu_counters.  I don't think there's much point in its ability to =
manage
> DEFINE_PER_CPU counters: pcounter_getval() remains grossly inefficien=
t (and
> can return negative values) and quite a bit of new code will need to =
be put
> in place to address that.
>=20
> But perhaps there are plans to evolve it into something further in th=
e
> future, I don't know.  But I would suggest that the people who have w=
orked
> upon percpu_counters (principally Gautham, Peter Z, clameter and me) =
be
> involved in that work.
>=20

Andrew, pcounter is a temporary abstraction.

It is temporaty because it will vanish as soon as Christoph Clameter (o=
r=20
somebody else) provides real cheap per cpu counter implementation.

At time I introduced it in network tree (locally, not meant to invade k=
ernel=20
land and makes you unhappy :) ), the goals were :

Some counters (total sockets count) were a single integer, that were do=
ing=20
ping-pong between cpus (SMP/NUMA). As they are basically lazy values (a=
s we=20
dont really need to read their value), using plain atomic_t was overkil=
l.

Using a plain percpu_counters was expensive (NR_CPUS*(32+sizeof(void *)=
)=20
instead of num_possible_cpus()*4).

Using 'online' instead of 'possible' stuff is not really needed for a=20
temporary thing.

- We dont care of read sides. We want really fast write side. Real fast=
=2E

Read side is when you do a "cat /proc/net/sockstat".
That is ... once in a while...

Now when we allocate a new socket, code to increment the "socket count"=
 is :

c03a74a8 <tcp_pcounter_add>:
c03a74a8:   b8 90 26 5f c0          mov    $0xc05f2690,%eax
c03a74ad:   64 8b 0d 10 f1 5e c0    mov    %fs:0xc05ef110,%ecx
c03a74b4:   01 14 01                add    %edx,(%ecx,%eax,1)
c03a74b7:   c3                      ret

That is 4 instructions. I could be two in the future, thanks to current=
 work=20
on fs/gs based percpu variables.

Current percpu_counters implementation is more expensive :

c021467b <__percpu_counter_add>:
c021467b:       55                      push   %ebp
c021467c:       57                      push   %edi
c021467d:       89 c7                   mov    %eax,%edi
c021467f:       56                      push   %esi
c0214680:       53                      push   %ebx
c0214681:       83 ec 04                sub    $0x4,%esp
c0214684:       8b 40 14                mov    0x14(%eax),%eax
c0214687:       64 8b 1d 08 f0 5e c0    mov    %fs:0xc05ef008,%ebx
c021468e:       8b 6c 24 18             mov    0x18(%esp),%ebp
c0214692:       f7 d0                   not    %eax
c0214694:       8b 1c 98                mov    (%eax,%ebx,4),%ebx
c0214697:       89 1c 24                mov    %ebx,(%esp)
c021469a:       8b 03                   mov    (%ebx),%eax
c021469c:       89 c3                   mov    %eax,%ebx
c021469e:       89 c6                   mov    %eax,%esi
c02146a0:       c1 fe 1f                sar    $0x1f,%esi
c02146a3:       89 e8                   mov    %ebp,%eax
c02146a5:       01 d3                   add    %edx,%ebx
c02146a7:       11 ce                   adc    %ecx,%esi
c02146a9:       99                      cltd
c02146aa:       39 d6                   cmp    %edx,%esi
c02146ac:       7f 15                   jg     c02146c3=20
<__percpu_counter_add+0x48>
c02146ae:       7c 04                   jl     c02146b4=20
<__percpu_counter_add+0x39>
c02146b0:       39 eb                   cmp    %ebp,%ebx
c02146b2:       73 0f                   jae    c02146c3=20
<__percpu_counter_add+0x48>
c02146b4:       f7 dd                   neg    %ebp
c02146b6:       89 e8                   mov    %ebp,%eax
c02146b8:       99                      cltd
c02146b9:       39 d6                   cmp    %edx,%esi
c02146bb:       7f 20                   jg     c02146dd=20
<__percpu_counter_add+0x62>
c02146bd:       7c 04                   jl     c02146c3=20
<__percpu_counter_add+0x48>
c02146bf:       39 eb                   cmp    %ebp,%ebx
c02146c1:       77 1a                   ja     c02146dd=20
<__percpu_counter_add+0x62>
c02146c3:       89 f8                   mov    %edi,%eax
c02146c5:       e8 04 cc 1f 00          call   c04112ce <_spin_lock>
c02146ca:       01 5f 04                add    %ebx,0x4(%edi)
c02146cd:       11 77 08                adc    %esi,0x8(%edi)
c02146d0:       8b 04 24                mov    (%esp),%eax
c02146d3:       c7 00 00 00 00 00       movl   $0x0,(%eax)
c02146d9:       fe 07                   incb   (%edi)
c02146db:       eb 05                   jmp    c02146e2=20
<__percpu_counter_add+0x67>
c02146dd:       8b 04 24                mov    (%esp),%eax
c02146e0:       89 18                   mov    %ebx,(%eax)
c02146e2:       58                      pop    %eax
c02146e3:       5b                      pop    %ebx
c02146e4:       5e                      pop    %esi
c02146e5:       5f                      pop    %edi
c02146e6:       5d                      pop    %ebp
c02146e7:       c3                      ret


Once it is better, just make pcounter vanish.

It is even clearly stated at the top of include/linux/pcounter.h

/*
  * Using a dynamic percpu 'int' variable has a cost :
  * 1) Extra dereference
  * Current per_cpu_ptr() implementation uses an array per 'percpu vari=
able'.
  * 2) memory cost of NR_CPUS*(32+sizeof(void *)) instead of num_possib=
le_cpus()*4
  *
  * This pcounter implementation is an abstraction to be able to use
  * either a static or a dynamic per cpu variable.
  * One dynamic per cpu variable gets a fast & cheap implementation, we=
 can
  * change pcounter implementation too.
  */


We all agree.

Thank you
