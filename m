From: Eric Dumazet <edumazet@google.com>
Subject: Re: Uninitialized value in __sk_nulls_add_node_rcu()
Date: Thu, 26 Oct 2017 07:52:50 -0700
Message-ID: <CANn89iKT54_=0Ci85-Of1X1CoWKa83+9ZGm0AL8ucbKPWw3cPA@mail.gmail.com>
References: <CAG_fn=W381cHWTanVCjWTR3Zi==RvgNc31BnSgCTyGcu=N286g@mail.gmail.com>
 <CAG_fn=VL7ESOELWo3cFUgsyQp1PfLiXbm-AdqrkqCqEEdHW5eQ@mail.gmail.com> <CANn89iKvfCDoPn=Zz-m9bKtjG0a5rgdNfFwgPXARQ5PnqP1ngw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>
To: Alexander Potapenko <glider@google.com>,
        Craig Gallek <kraig@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f195.google.com ([209.85.161.195]:55673 "EHLO
        mail-yw0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932309AbdJZOww (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2017 10:52:52 -0400
Received: by mail-yw0-f195.google.com with SMTP id t11so3111055ywg.12
        for <netdev@vger.kernel.org>; Thu, 26 Oct 2017 07:52:52 -0700 (PDT)
In-Reply-To: <CANn89iKvfCDoPn=Zz-m9bKtjG0a5rgdNfFwgPXARQ5PnqP1ngw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 26, 2017 at 7:47 AM, Eric Dumazet <edumazet@google.com> wrote:
> On Thu, Oct 26, 2017 at 7:20 AM, Alexander Potapenko <glider@google.com> =
wrote:
>> On Thu, Oct 26, 2017 at 2:51 PM, Alexander Potapenko <glider@google.com>=
 wrote:
>>> Hi David, Eric,
>>>
>>> I've changed KMSAN instrumentation a bit and it's now reporting a new
>>> error (see below) when I SSH into a VM.
>> I've double-checked the old instrumentation and found a bug in it,
>> which led to masking some of the errors on uninitialized bitfields.
>> I now believe this is a true positive report.
>
>
> Please do not top post on netdev
>
> A child is cloned from the listener, check sock_copy()
>
> sk_reuseport is part of the copied fields.
>
> You might have some bug at your side ?
>

Oh these are request socket.

This is an harmless bug added in commit d894ba18d4e449b3a7f6eb491f16c9e0293=
3736e
("soreuseport: fix ordering for mixed v4/v6 sockets")

I will send a patch, but really this has no effect at all.


>
>>> For |req| allocated by inet_reqsk_alloc() the value of
>>> req_to_sk(req)->sk_reuseport is uninitialized.
>>> Does this look valid?
>>> I'm a bit surprised this didn't show up before, but I couldn't find
>>> any code to initialize sk_reuseport.
>>>
>>> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>>> BUG: KMSAN: use of uninitialized memory in inet_ehash_insert+0xd40/0x10=
50
>>> CPU: 0 PID: 0 Comm: swapper/0 Not tainted 4.13.0+ #3288
>>> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01=
/2011
>>> Call Trace:
>>>  <IRQ>
>>>  __dump_stack lib/dump_stack.c:16
>>>  dump_stack+0x185/0x1d0 lib/dump_stack.c:52
>>>  kmsan_report+0x13f/0x1c0 mm/kmsan/kmsan.c:1016
>>>  __msan_warning_32+0x69/0xb0 mm/kmsan/kmsan_instr.c:766
>>>  __sk_nulls_add_node_rcu ./include/net/sock.h:684
>>>  inet_ehash_insert+0xd40/0x1050 net/ipv4/inet_hashtables.c:413
>>>  reqsk_queue_hash_req net/ipv4/inet_connection_sock.c:754
>>>  inet_csk_reqsk_queue_hash_add+0x1cc/0x300 net/ipv4/inet_connection_soc=
k.c:765
>>>  tcp_conn_request+0x31e7/0x36f0 net/ipv4/tcp_input.c:6414
>>>  tcp_v4_conn_request+0x16d/0x220 net/ipv4/tcp_ipv4.c:1314
>>>  tcp_rcv_state_process+0x42a/0x7210 net/ipv4/tcp_input.c:5917
>>>  tcp_v4_do_rcv+0xa6a/0xcd0 net/ipv4/tcp_ipv4.c:1483
>>>  tcp_v4_rcv+0x3de0/0x4ab0 net/ipv4/tcp_ipv4.c:1763
>>>  ip_local_deliver_finish+0x6bb/0xcb0 net/ipv4/ip_input.c:216
>>>  NF_HOOK ./include/linux/netfilter.h:248
>>>  ip_local_deliver+0x3fa/0x480 net/ipv4/ip_input.c:257
>>>  dst_input ./include/net/dst.h:477
>>>  ip_rcv_finish+0x6fb/0x1540 net/ipv4/ip_input.c:397
>>>  NF_HOOK ./include/linux/netfilter.h:248
>>>  ip_rcv+0x10f6/0x15c0 net/ipv4/ip_input.c:488
>>>  __netif_receive_skb_core+0x36f6/0x3f60 net/core/dev.c:4298
>>>  __netif_receive_skb net/core/dev.c:4336
>>>  netif_receive_skb_internal+0x63c/0x19c0 net/core/dev.c:4497
>>>  napi_skb_finish net/core/dev.c:4858
>>>  napi_gro_receive+0x629/0xa50 net/core/dev.c:4889
>>>  e1000_receive_skb drivers/net/ethernet/intel/e1000/e1000_main.c:4018
>>>  e1000_clean_rx_irq+0x1492/0x1d30
>>> drivers/net/ethernet/intel/e1000/e1000_main.c:4474
>>>  e1000_clean+0x43aa/0x5970 drivers/net/ethernet/intel/e1000/e1000_main.=
c:3819
>>>  napi_poll net/core/dev.c:5500
>>>  net_rx_action+0x73c/0x1820 net/core/dev.c:5566
>>>  __do_softirq+0x4b4/0x8dd kernel/softirq.c:284
>>>  invoke_softirq kernel/softirq.c:364
>>>  irq_exit+0x203/0x240 kernel/softirq.c:405
>>>  exiting_irq+0xe/0x10 ./arch/x86/include/asm/apic.h:638
>>>  do_IRQ+0x15e/0x1a0 arch/x86/kernel/irq.c:263
>>>  common_interrupt+0x86/0x86
>>> ...
>>>  </IRQ>
>>>  arch_cpu_idle+0x20/0x30 arch/x86/kernel/process.c:332
>>>  default_idle_call kernel/sched/idle.c:98
>>>  cpuidle_idle_call kernel/sched/idle.c:156
>>>  do_idle+0x334/0x730 kernel/sched/idle.c:246
>>>  cpu_startup_entry+0x35/0x40 kernel/sched/idle.c:351
>>>  rest_init+0xb8/0xc0 init/main.c:437
>>>  start_kernel+0x4d7/0x530 init/main.c:703
>>>  x86_64_start_reservations arch/x86/kernel/head64.c:318
>>>  x86_64_start_kernel+0x3cd/0x3e0 arch/x86/kernel/head64.c:299
>>>  secondary_startup_64+0x9f/0x9f arch/x86/kernel/head_64.S:219
>>> origin:
>>>  save_stack_trace+0x16/0x20 arch/x86/kernel/stacktrace.c:59
>>>  kmsan_save_stack_with_flags mm/kmsan/kmsan.c:302
>>>  kmsan_internal_poison_shadow+0xb3/0x1b0 mm/kmsan/kmsan.c:198
>>>  kmsan_kmalloc+0x80/0xe0 mm/kmsan/kmsan.c:337
>>>  kmem_cache_alloc+0x1e2/0x220 mm/slub.c:2756
>>>  reqsk_alloc ./include/net/request_sock.h:88
>>>  inet_reqsk_alloc+0xb8/0x6b0 net/ipv4/tcp_input.c:6231
>>>  tcp_conn_request+0x89d/0x36f0 net/ipv4/tcp_input.c:6330
>>>  tcp_v4_conn_request+0x16d/0x220 net/ipv4/tcp_ipv4.c:1314
>>>  tcp_rcv_state_process+0x42a/0x7210 net/ipv4/tcp_input.c:5917
>>>  tcp_v4_do_rcv+0xa6a/0xcd0 net/ipv4/tcp_ipv4.c:1483
>>>  tcp_v4_rcv+0x3de0/0x4ab0 net/ipv4/tcp_ipv4.c:1763
>>>  ip_local_deliver_finish+0x6bb/0xcb0 net/ipv4/ip_input.c:216
>>>  NF_HOOK ./include/linux/netfilter.h:248
>>> ...
>>> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>>>
>>> --
>>> Alexander Potapenko
>>> Software Engineer
>>>
>>> Google Germany GmbH
>>> Erika-Mann-Stra=C3=9Fe, 33
>>> 80636 M=C3=BCnchen
>>>
>>> Gesch=C3=A4ftsf=C3=BChrer: Paul Manicle, Halimah DeLaine Prado
>>> Registergericht und -nummer: Hamburg, HRB 86891
>>> Sitz der Gesellschaft: Hamburg
>>
>>
>>
>> --
>> Alexander Potapenko
>> Software Engineer
>>
>> Google Germany GmbH
>> Erika-Mann-Stra=C3=9Fe, 33
>> 80636 M=C3=BCnchen
>>
>> Gesch=C3=A4ftsf=C3=BChrer: Paul Manicle, Halimah DeLaine Prado
>> Registergericht und -nummer: Hamburg, HRB 86891
>> Sitz der Gesellschaft: Hamburg
