From: Dmitry Vyukov <dvyukov@google.com>
Subject: Re: Use-after-free in ipv4_conntrack_defrag
Date: Thu, 5 Nov 2015 20:31:54 +0100
Message-ID: <CACT4Y+bOwTL6q_huLrwNwAcCPUkSSeo9GRg_W=ha12-bi_7DkQ@mail.gmail.com>
References: <CACT4Y+bRvC2k_BLNYyANKz4+AT=q0XJ-RJBuAikUdZfzqd9RdQ@mail.gmail.com>
 <CANn89iKj6L0fyzh-o4AJHpTvE_toF=a75qxOj+-Aub_KXNboqw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	David Miller <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Sasha Levin <sasha.levin@oracle.com>,
	Kees Cook <keescook@google.com>,
	Julien Tinnes <jln@google.com>,
	Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Eric Dumazet <edumazet@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CANn89iKj6L0fyzh-o4AJHpTvE_toF=a75qxOj+-Aub_KXNboqw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

+netdev, lkml
Adding public lists as requested.

Below is a use-after-free report in ipv4_conntrack_defrag and a fix from Eric.


On Thu, Nov 5, 2015 at 7:57 PM, Eric Dumazet <edumazet@google.com> wrote:
> On Thu, Nov 5, 2015 at 10:33 AM, Dmitry Vyukov <dvyukov@google.com> wrote:
>> Hello,
>>
>> I've updated from bcee19f424a0d8c26ecf2607b73c690802658b29 (Sep 21) to
>> 8e483ed1342a4ea45b70f0f33ac54eff7a33d918 (Nov 4) and started seeing
>> constant stream of the following reports:
>>
>> BUG: KASan: use after free in ipv4_conntrack_defrag+0x39c/0x550 at
>> addr ffff88003d4981b8
>> Read of size 1 by task swapper/1/0
>> =============================================================================
>> BUG skbuff_fclone_cache (Tainted: G    B        L ): kasan: bad access detected
>> -----------------------------------------------------------------------------
>>
>> CPU: 1 PID: 0 Comm: swapper/1 Tainted: G    B        L  4.3.0+ #27
>> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
>>  00000000ffffffff ffff88003ed06ce8 ffffffff81aada96 ffff88003e952640
>>  ffff88003d498000 ffff88003d498000 ffff88003ed06d18 ffffffff814a6d54
>>  ffff88003e952640 ffffea0000f52600 ffff88003d498000 ffff88003ed06fb0
>> Call Trace:
>>  [<ffffffff814aedbe>] __asan_report_load1_noabort+0x3e/0x40
>> mm/kasan/report.c:248
>>  [<ffffffff82a62eac>] ipv4_conntrack_defrag+0x39c/0x550
>> net/ipv4/netfilter/nf_defrag_ipv4.c:72
>>  [<ffffffff8287b42d>] nf_iterate+0x15d/0x250 net/netfilter/core.c:274
>>  [<ffffffff8287b6c1>] nf_hook_slow+0x1a1/0x300 net/netfilter/core.c:306
>>  [<     inline     >] nf_hook_thresh include/linux/netfilter.h:187
>>  [<     inline     >] nf_hook include/linux/netfilter.h:197
>>  [<ffffffff82906593>] __ip_local_out+0x263/0x3c0 net/ipv4/ip_output.c:105
>>  [<ffffffff8290671d>] ip_local_out+0x2d/0x1c0 net/ipv4/ip_output.c:114
>>  [<ffffffff82906e56>] ip_build_and_send_pkt+0x5a6/0xa40 net/ipv4/ip_output.c:171
>>  [<ffffffff82993add>] tcp_v4_send_synack+0x18d/0x270 net/ipv4/tcp_ipv4.c:841
>>  [<ffffffff8294e18b>] tcp_conn_request+0x1f3b/0x2750 net/ipv4/tcp_input.c:6273
>>  [<ffffffff8298d75e>] tcp_v4_conn_request+0x17e/0x240 net/ipv4/tcp_ipv4.c:1234
>>  [<ffffffff829623ce>] tcp_rcv_state_process+0x6ae/0x4130
>> net/ipv4/tcp_input.c:5750
>>  [<ffffffff82991a7b>] tcp_v4_do_rcv+0x2fb/0x9f0 net/ipv4/tcp_ipv4.c:1405
>>  [<ffffffff82996bf2>] tcp_v4_rcv+0x2872/0x2f80 net/ipv4/tcp_ipv4.c:1630
>>  [<ffffffff828ed369>] ip_local_deliver_finish+0x2a9/0xa30
>> net/ipv4/ip_input.c:216
>>  [<     inline     >] NF_HOOK_THRESH include/linux/netfilter.h:226
>>  [<     inline     >] NF_HOOK include/linux/netfilter.h:249
>>  [<ffffffff828ef3c4>] ip_local_deliver+0x1c4/0x2f0 net/ipv4/ip_input.c:257
>>  [<     inline     >] dst_input include/net/dst.h:465
>>  [<ffffffff828ee104>] ip_rcv_finish+0x614/0x11d0 net/ipv4/ip_input.c:365
>>  [<     inline     >] NF_HOOK_THRESH include/linux/netfilter.h:226
>>  [<     inline     >] NF_HOOK include/linux/netfilter.h:249
>>  [<ffffffff828eff66>] ip_rcv+0xa76/0x1470 net/ipv4/ip_input.c:455
>>  [<ffffffff827c7379>] __netif_receive_skb_core+0x1cb9/0x38e0 net/core/dev.c:3940
>>  [<ffffffff827c8fca>] __netif_receive_skb+0x2a/0x160 net/core/dev.c:3975
>>  [<ffffffff827cb6a5>] netif_receive_skb_internal+0xe5/0x360 net/core/dev.c:4003
>>  [<     inline     >] napi_skb_finish net/core/dev.c:4328
>>  [<ffffffff827cfc70>] napi_gro_receive+0x1c0/0x260 net/core/dev.c:4357
>>  [<     inline     >] e1000_receive_skb
>> drivers/net/ethernet/intel/e1000/e1000_main.c:4007
>>  [<ffffffff823223cc>] e1000_clean_rx_irq+0x4ec/0x10c0
>> drivers/net/ethernet/intel/e1000/e1000_main.c:4459
>>  [<ffffffff8231ffe6>] e1000_clean+0xa56/0x2520
>> drivers/net/ethernet/intel/e1000/e1000_main.c:3814
>>  [<     inline     >] napi_poll net/core/dev.c:4793
>>  [<ffffffff827cc9dd>] net_rx_action+0x74d/0xc70 net/core/dev.c:4858
>>  [<ffffffff8110fdee>] __do_softirq+0x2ae/0x710 kernel/softirq.c:273
>>  [<     inline     >] invoke_softirq kernel/softirq.c:350
>>  [<ffffffff811104ed>] irq_exit+0x15d/0x190 kernel/softirq.c:391
>>  [<     inline     >] exiting_irq ./arch/x86/include/asm/apic.h:653
>>  [<ffffffff81013256>] do_IRQ+0x86/0x1a0 arch/x86/kernel/irq.c:252
>>  [<ffffffff82f255c7>] common_interrupt+0x87/0x87 arch/x86/entry/entry_64.S:545
>>  <EOI>  [<ffffffff810d0706>] ? native_safe_halt+0x6/0x10
>> ./arch/x86/include/asm/irqflags.h:49
>>  [<     inline     >] arch_safe_halt ./arch/x86/include/asm/paravirt.h:111
>>  [<ffffffff81026e62>] default_idle+0x22/0x1e0 arch/x86/kernel/process.c:304
>>  [<ffffffff81027f9a>] arch_cpu_idle+0xa/0x10 arch/x86/kernel/process.c:295
>>  [<ffffffff811d9c38>] default_idle_call+0x48/0x70 kernel/sched/idle.c:92
>>  [<     inline     >] cpuidle_idle_call kernel/sched/idle.c:156
>>  [<     inline     >] cpu_idle_loop kernel/sched/idle.c:251
>>  [<ffffffff811da15d>] cpu_startup_entry+0x41d/0x570 kernel/sched/idle.c:299
>>  [<ffffffff810ac8e3>] start_secondary+0x243/0x2d0 arch/x86/kernel/smpboot.c:251
>>
>> INFO: Allocated in __alloc_skb+0xba/0x5f0 age=3027 cpu=0 pid=2721
>> [<      none      >] __slab_alloc+0x23a/0x560 mm/slub.c:2402
>> [<     inline     >] slab_alloc_node mm/slub.c:2470
>> [<      none      >] kmem_cache_alloc_node+0x88/0x180 mm/slub.c:2540
>> [<      none      >] __alloc_skb+0xba/0x5f0 net/core/skbuff.c:216
>> [<     inline     >] alloc_skb_fclone include/linux/skbuff.h:855
>> [<      none      >] sk_stream_alloc_skb+0xa9/0x620 net/ipv4/tcp.c:827
>> [<      none      >] tcp_sendmsg+0x18c9/0x2c50 net/ipv4/tcp.c:1169
>> [<      none      >] inet_sendmsg+0x316/0x4f0 net/ipv4/af_inet.c:733
>> [<     inline     >] sock_sendmsg_nosec net/socket.c:610
>> [<      none      >] sock_sendmsg+0xca/0x110 net/socket.c:620
>> [<      none      >] sock_write_iter+0x216/0x3a0 net/socket.c:819
>> [<     inline     >] new_sync_write fs/read_write.c:478
>> [<      none      >] __vfs_write+0x2ed/0x3d0 fs/read_write.c:491
>> [<      none      >] vfs_write+0x16e/0x490 fs/read_write.c:538
>> [<     inline     >] SYSC_write fs/read_write.c:585
>> [<      none      >] SyS_write+0x111/0x220 fs/read_write.c:577
>> [<      none      >] entry_SYSCALL_64_fastpath+0x31/0x9a
>> arch/x86/entry/entry_64.S:187
>>
>> INFO: Freed in kfree_skbmem+0xca/0x100 age=3027 cpu=0 pid=2721
>> [<      none      >] __slab_free+0x1ec/0x350 mm/slub.c:2587
>> [<     inline     >] slab_free mm/slub.c:2736
>> [<      none      >] kmem_cache_free+0x1e5/0x200 mm/slub.c:2745
>> [<      none      >] kfree_skbmem+0xca/0x100 net/core/skbuff.c:633
>> [<      none      >] __kfree_skb+0x1d/0x20 net/core/skbuff.c:674
>> [<     inline     >] sk_wmem_free_skb include/net/sock.h:1431
>> [<     inline     >] tcp_clean_rtx_queue net/ipv4/tcp_input.c:3181
>> [<      none      >] tcp_ack+0x1a5d/0x4c60 net/ipv4/tcp_input.c:3611
>> [<      none      >] tcp_rcv_established+0xccd/0x20b0 net/ipv4/tcp_input.c:5284
>> [<      none      >] tcp_v4_do_rcv+0x573/0x9f0 net/ipv4/tcp_ipv4.c:1381
>> [<     inline     >] sk_backlog_rcv include/net/sock.h:866
>> [<     inline     >] __release_sock net/core/sock.c:2009
>> [<      none      >] release_sock+0x168/0x4f0 net/core/sock.c:2457
>> [<      none      >] tcp_sendmsg+0x1d9/0x2c50 net/ipv4/tcp.c:1307
>> [<      none      >] inet_sendmsg+0x316/0x4f0 net/ipv4/af_inet.c:733
>> [<     inline     >] sock_sendmsg_nosec net/socket.c:610
>> [<      none      >] sock_sendmsg+0xca/0x110 net/socket.c:620
>> [<      none      >] sock_write_iter+0x216/0x3a0 net/socket.c:819
>> [<     inline     >] new_sync_write fs/read_write.c:478
>> [<      none      >] __vfs_write+0x2ed/0x3d0 fs/read_write.c:491
>> [<      none      >] vfs_write+0x16e/0x490 fs/read_write.c:538
>> [<     inline     >] SYSC_write fs/read_write.c:585
>> [<      none      >] SyS_write+0x111/0x220 fs/read_write.c:577
>> [<      none      >] entry_SYSCALL_64_fastpath+0x31/0x9a
>> arch/x86/entry/entry_64.S:187
>>
>> INFO: Slab 0xffffea0000f52600 objects=19 used=0 fp=0xffff88003d498000
>> flags=0x100000000004080
>> INFO: Object 0xffff88003d498000 @offset=0 fp=0xffff88003d49ba80
>>
>>
>> They start happening during boot and there are so many of them that I
>> suspect that maybe it is something in my setup...
>> But the reports looks pretty legit. tcp_sendmsg allocates skb, frees
>> skb, but also enqueues it for transmission.
>> I've found only one recent commit to net/ipv4/tcp.c which is
>> 686a562449af96a0e8c18c6f1b87b47ff8c36de8, but it looks like no-op.
>>
>> What could cause these errors?
>
> Hi Dmitry
>
> Not sure why you spam so many people ?
> I can assure you netdev list is responsive, especially during merge
> window, where we expect bugs to surface.
>
> We had similar bugs caused by SYNACK attached to request sockets.
>
> Please try (sorry for bad formatting , but patch is trivial enough)
>
> Surely SYNACK messages fail ip_is_fragment() test anyway...
>
> diff --git a/net/ipv4/netfilter/nf_defrag_ipv4.c
> b/net/ipv4/netfilter/nf_defrag_ipv4.c
> index 0e5591c2ee9f..6fb869f646bf 100644
> --- a/net/ipv4/netfilter/nf_defrag_ipv4.c
> +++ b/net/ipv4/netfilter/nf_defrag_ipv4.c
> @@ -67,10 +67,9 @@ static unsigned int ipv4_conntrack_defrag(void *priv,
>    const struct nf_hook_state *state)
>  {
>   struct sock *sk = skb->sk;
> - struct inet_sock *inet = inet_sk(skb->sk);
>
> - if (sk && (sk->sk_family == PF_INET) &&
> -    inet->nodefrag)
> + if (sk && sk_fullsock(sk) && (sk->sk_family == PF_INET) &&
> +    inet_sk(sk)->nodefrag)
>   return NF_ACCEPT;
>
>  #if IS_ENABLED(CONFIG_NF_CONNTRACK)
