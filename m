From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: include/linux/pcounter.h
Date: Sat, 16 Feb 2008 02:50:51 -0800
Message-ID: <20080216025051.751b4a86.akpm@linux-foundation.org>
References: <20080204014402.1c55d3fe.akpm@linux-foundation.org>
	<20080215193711.2e3d41f3.akpm@linux-foundation.org>
	<47B6B5E1.90705@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:49769 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751438AbYBPKwp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Feb 2008 05:52:45 -0500
In-Reply-To: <47B6B5E1.90705@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 16 Feb 2008 11:07:29 +0100 Eric Dumazet <dada1@cosmosbay.com> wrote:

> 
> Andrew, pcounter is a temporary abstraction.

It's buggy!  Main problems are a) possible return of negative numbers b)
some of the API can't be from preemptible code c) excessive interrupt-off
time on some machines if used from irq-disabled sections.

> It is temporaty because it will vanish as soon as Christoph Clameter (or 
> somebody else) provides real cheap per cpu counter implementation.

numbers?

most of percpu_counter_add() is only executed once per FBC_BATCH calls.

> At time I introduced it in network tree (locally, not meant to invade kernel 
> land and makes you unhappy :) ), the goals were :

Well maybe as a temporary networking-only thing OK, based upon
performance-tested results.  But I don't think the present code is suitable
as part of the kernel-wide toolkit.

> Some counters (total sockets count) were a single integer, that were doing 
> ping-pong between cpus (SMP/NUMA). As they are basically lazy values (as we 
> dont really need to read their value), using plain atomic_t was overkill.
> 
> Using a plain percpu_counters was expensive (NR_CPUS*(32+sizeof(void *)) 
> instead of num_possible_cpus()*4).

No, percpu_counters use alloc_percpu(), which is O(num_possible_cpus), not
O(NR_CPUS).

> Using 'online' instead of 'possible' stuff is not really needed for a 
> temporary thing.

This was put in ./lib/!

> - We dont care of read sides.

Well the present single caller in networking might not care.  But this was
put in ./lib/ and was exported to modules.  That is an invitation to all
kernel developers to use it in new code.  Which may result in truly awful
performance on high-cpu-count machines.

>  We want really fast write side. Real fast.

eh?  It's called on a per-connection basis, not on a per-packet basis?

> Read side is when you do a "cat /proc/net/sockstat".
> That is ... once in a while...

For the current single caller.  But it's in ./lib/.

And there's always someone out there who does whatever we don't expect them
to do.

> Now when we allocate a new socket, code to increment the "socket count" is :
> 
> c03a74a8 <tcp_pcounter_add>:
> c03a74a8:   b8 90 26 5f c0          mov    $0xc05f2690,%eax
> c03a74ad:   64 8b 0d 10 f1 5e c0    mov    %fs:0xc05ef110,%ecx
> c03a74b4:   01 14 01                add    %edx,(%ecx,%eax,1)
> c03a74b7:   c3                      ret

I can't find that code.  I suspect that's the DEFINE_PER_CPU flavour, which
isn't used anywhere afaict.  Plus this omits the local_irq_save/restore (or
preempt_disable/enable) and the indirect function call, which can be
expensive.

> That is 4 instructions. I could be two in the future, thanks to current work 
> on fs/gs based percpu variables.
> 
> Current percpu_counters implementation is more expensive :
> 
> c021467b <__percpu_counter_add>:
> c021467b:       55                      push   %ebp
> c021467c:       57                      push   %edi
> c021467d:       89 c7                   mov    %eax,%edi
> c021467f:       56                      push   %esi
> c0214680:       53                      push   %ebx
> c0214681:       83 ec 04                sub    $0x4,%esp
> c0214684:       8b 40 14                mov    0x14(%eax),%eax
> c0214687:       64 8b 1d 08 f0 5e c0    mov    %fs:0xc05ef008,%ebx
> c021468e:       8b 6c 24 18             mov    0x18(%esp),%ebp
> c0214692:       f7 d0                   not    %eax
> c0214694:       8b 1c 98                mov    (%eax,%ebx,4),%ebx
> c0214697:       89 1c 24                mov    %ebx,(%esp)
> c021469a:       8b 03                   mov    (%ebx),%eax
> c021469c:       89 c3                   mov    %eax,%ebx
> c021469e:       89 c6                   mov    %eax,%esi
> c02146a0:       c1 fe 1f                sar    $0x1f,%esi
> c02146a3:       89 e8                   mov    %ebp,%eax
> c02146a5:       01 d3                   add    %edx,%ebx
> c02146a7:       11 ce                   adc    %ecx,%esi
> c02146a9:       99                      cltd
> c02146aa:       39 d6                   cmp    %edx,%esi
> c02146ac:       7f 15                   jg     c02146c3 
> <__percpu_counter_add+0x48>
> c02146ae:       7c 04                   jl     c02146b4 

One of the above two branches is taken ((FBC_BATCH-1)/FBC_BATCH)ths of the
time.


> <__percpu_counter_add+0x39>
> c02146b0:       39 eb                   cmp    %ebp,%ebx
> c02146b2:       73 0f                   jae    c02146c3 
> <__percpu_counter_add+0x48>
> c02146b4:       f7 dd                   neg    %ebp
> c02146b6:       89 e8                   mov    %ebp,%eax
> c02146b8:       99                      cltd
> c02146b9:       39 d6                   cmp    %edx,%esi
> c02146bb:       7f 20                   jg     c02146dd 
> <__percpu_counter_add+0x62>
> c02146bd:       7c 04                   jl     c02146c3 
> <__percpu_counter_add+0x48>
> c02146bf:       39 eb                   cmp    %ebp,%ebx
> c02146c1:       77 1a                   ja     c02146dd 
> <__percpu_counter_add+0x62>
> c02146c3:       89 f8                   mov    %edi,%eax
> c02146c5:       e8 04 cc 1f 00          call   c04112ce <_spin_lock>
> c02146ca:       01 5f 04                add    %ebx,0x4(%edi)
> c02146cd:       11 77 08                adc    %esi,0x8(%edi)
> c02146d0:       8b 04 24                mov    (%esp),%eax
> c02146d3:       c7 00 00 00 00 00       movl   $0x0,(%eax)
> c02146d9:       fe 07                   incb   (%edi)
> c02146db:       eb 05                   jmp    c02146e2 
> <__percpu_counter_add+0x67>
> c02146dd:       8b 04 24                mov    (%esp),%eax
> c02146e0:       89 18                   mov    %ebx,(%eax)
> c02146e2:       58                      pop    %eax
> c02146e3:       5b                      pop    %ebx
> c02146e4:       5e                      pop    %esi
> c02146e5:       5f                      pop    %edi
> c02146e6:       5d                      pop    %ebp
> c02146e7:       c3                      ret
> 
> 
> Once it is better, just make pcounter vanish.

Some of the stuff in there is from the __percpu_disguise() thing which we
probably can live without.

But I'd be surprised if benchmarking reveals that the pcounter code is
justifiable in its present networking application or indeed in any future
ones.

> It is even clearly stated at the top of include/linux/pcounter.h
> 
> /*
>   * Using a dynamic percpu 'int' variable has a cost :
>   * 1) Extra dereference
>   * Current per_cpu_ptr() implementation uses an array per 'percpu variable'.
>   * 2) memory cost of NR_CPUS*(32+sizeof(void *)) instead of num_possible_cpus()*4
>   *
>   * This pcounter implementation is an abstraction to be able to use
>   * either a static or a dynamic per cpu variable.
>   * One dynamic per cpu variable gets a fast & cheap implementation, we can
>   * change pcounter implementation too.
>   */
> 
> 
> We all agree.
> 

No we don't.  That comment is afaict wrong about the memory consumption and
the abstraction *isn't useful*.

Why do we want some abstraction which makes alloc_percpu() storage and
DEFINE_PERCPU storage "look the same"?  What use is there in that?  One is
per-object storage and one is singleton storage - they're quite different
things and they are used in quite different situations and they are
basically never interchangeable.  Yet we add this pretend-they're-the-same
wrapper around them which costs us an indirect function call on the
fastpath.
