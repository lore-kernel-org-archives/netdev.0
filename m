From: Andrey Konovalov <andreyknvl@google.com>
Subject: Re: net: use-after-free in worker_thread
Date: Sat, 3 Dec 2016 16:39:41 +0100
Message-ID: <CAAeHK+wyYCSePv3KoCLb9gDQa43xkdyvzffFEobD-EOD2w-8OA@mail.gmail.com>
References: <CAAeHK+x95-n__YSbzebp51ez78yjqjK4CJL=tgOgPuBuGh+q1A@mail.gmail.com>
 <CAAeHK+zDnDugPcdEGBnC6rt5iJMffz+tmmDkF=vv6u0YF=EMwg@mail.gmail.com>
 <CAAeHK+wtAhv2vvLva5a9J52A-bZj1kY8tF8RT7bC=5QVnxOr7A@mail.gmail.com> <1480772947.18162.402.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=001a11406a82f9dd5c0542c2dcd0
Cc: "David S. Miller" <davem@davemloft.net>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Johannes Berg <johannes.berg@intel.com>,
        Florian Westphal <fw@strlen.de>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        Eric Dumazet <edumazet@google.com>,
        Bob Copeland <me@bobcopeland.com>,
        Tom Herbert <tom@herbertland.com>,
        David Decotigny <decot@googlers.com>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Kostya Serebryany <kcc@google.com>,
        Dmitry Vyukov <dvyukov@google.com>
To: syzkaller <syzkaller@googlegroups.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1480772947.18162.402.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--001a11406a82f9dd5c0542c2dcd0
Content-Type: text/plain; charset=UTF-8

On Sat, Dec 3, 2016 at 2:49 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Sat, 2016-12-03 at 14:05 +0100, Andrey Konovalov wrote:
>> On Sat, Dec 3, 2016 at 1:58 PM, Andrey Konovalov <andreyknvl@google.com> wrote:
>> > +syzkaller@googlegroups.com
>> >
>> > On Sat, Dec 3, 2016 at 1:56 PM, Andrey Konovalov <andreyknvl@google.com> wrote:
>> >> Hi!
>> >>
>> >> I'm seeing lots of the following error reports while running the
>> >> syzkaller fuzzer.
>> >>
>> >> Reports appeared when I updated to 3c49de52 (Dec 2) from 2caceb32 (Dec 1).
>> >>
>> >> ==================================================================
>> >> BUG: KASAN: use-after-free in worker_thread+0x17d8/0x18a0
>> >> Read of size 8 at addr ffff880067f3ecd8 by task kworker/3:1/774
>> >>
>> >> page:ffffea00019fce00 count:1 mapcount:0 mapping:          (null)
>> >> index:0xffff880067f39c10 compound_mapcount: 0
>> >> flags: 0x500000000004080(slab|head)
>> >> page dumped because: kasan: bad access detected
>> >>
>> >> CPU: 3 PID: 774 Comm: kworker/3:1 Not tainted 4.9.0-rc7+ #66
>> >> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
>> >>  ffff88006c267838 ffffffff81f882da ffffffff6c25e338 1ffff1000d84ce9a
>> >>  ffffed000d84ce92 ffff88006c25e340 0000000041b58ab3 ffffffff8541e198
>> >>  ffffffff81f88048 0000000100000000 0000000041b58ab3 ffffffff853d3ee8
>> >> Call Trace:
>> >>  [<     inline     >] __dump_stack lib/dump_stack.c:15
>> >>  [<ffffffff81f882da>] dump_stack+0x292/0x398 lib/dump_stack.c:51
>> >>  [<     inline     >] describe_address mm/kasan/report.c:262
>> >>  [<ffffffff817e50d1>] kasan_report_error+0x121/0x560 mm/kasan/report.c:368
>> >>  [<     inline     >] kasan_report mm/kasan/report.c:390
>> >>  [<ffffffff817e560e>] __asan_report_load8_noabort+0x3e/0x40
>> >> mm/kasan/report.c:411
>> >>  [<ffffffff81329b88>] worker_thread+0x17d8/0x18a0 kernel/workqueue.c:2228
>> >>  [<ffffffff8133ebf3>] kthread+0x323/0x3e0 kernel/kthread.c:209
>> >>  [<ffffffff84a2a22a>] ret_from_fork+0x2a/0x40 arch/x86/entry/entry_64.S:433
>> >>
>> >> The buggy address belongs to the object at ffff880067f3e6d0
>> >>  which belongs to the cache kmalloc-2048 of size 2048
>> >> The buggy address ffff880067f3ecd8 is located 1544 bytes inside
>> >>  of 2048-byte region [ffff880067f3e6d0, ffff880067f3eed0)
>> >>
>> >> Freed by task 0:
>> >>  [<ffffffff81203526>] save_stack_trace+0x16/0x20 arch/x86/kernel/stacktrace.c:57
>> >>  [<ffffffff817e4173>] save_stack+0x43/0xd0 mm/kasan/kasan.c:495
>> >>  [<     inline     >] set_track mm/kasan/kasan.c:507
>> >>  [<ffffffff817e4a53>] kasan_slab_free+0x73/0xc0 mm/kasan/kasan.c:571
>> >>  [<     inline     >] slab_free_hook mm/slub.c:1352
>> >>  [<     inline     >] slab_free_freelist_hook mm/slub.c:1374
>> >>  [<     inline     >] slab_free mm/slub.c:2951
>> >>  [<ffffffff817e0eb7>] kfree+0xe7/0x2b0 mm/slub.c:3871
>> >>  [<     inline     >] sk_prot_free net/core/sock.c:1372
>> >>  [<ffffffff831ea1c7>] __sk_destruct+0x5c7/0x6e0 net/core/sock.c:1445
>> >>  [<ffffffff831f3517>] sk_destruct+0x47/0x80 net/core/sock.c:1453
>> >>  [<ffffffff831f35a7>] __sk_free+0x57/0x230 net/core/sock.c:1461
>> >>  [<ffffffff831f37a3>] sk_free+0x23/0x30 net/core/sock.c:1472
>> >>  [<     inline     >] sock_put include/net/sock.h:1591
>> >>  [<ffffffff8348ca9c>] deferred_put_nlk_sk+0x2c/0x40 net/netlink/af_netlink.c:671
>> >>  [<     inline     >] __rcu_reclaim kernel/rcu/rcu.h:118
>> >>  [<ffffffff8146d42f>] rcu_do_batch.isra.67+0x8ff/0xc50 kernel/rcu/tree.c:2776
>> >>  [<     inline     >] invoke_rcu_callbacks kernel/rcu/tree.c:3040
>> >>  [<     inline     >] __rcu_process_callbacks kernel/rcu/tree.c:3007
>> >>  [<ffffffff8146e097>] rcu_process_callbacks+0x2b7/0xba0 kernel/rcu/tree.c:3024
>> >>  [<ffffffff84a2d08b>] __do_softirq+0x2fb/0xb63 kernel/softirq.c:284
>> >>
>> >> Allocated by task 10748:
>> >>  [<ffffffff81203526>] save_stack_trace+0x16/0x20 arch/x86/kernel/stacktrace.c:57
>> >>  [<ffffffff817e4173>] save_stack+0x43/0xd0 mm/kasan/kasan.c:495
>> >>  [<     inline     >] set_track mm/kasan/kasan.c:507
>> >>  [<ffffffff817e43fd>] kasan_kmalloc+0xad/0xe0 mm/kasan/kasan.c:598
>> >>  [<ffffffff817e0050>] __kmalloc+0xa0/0x2d0 mm/slub.c:3734
>> >>  [<     inline     >] kmalloc include/linux/slab.h:495
>> >>  [<ffffffff831e4c01>] sk_prot_alloc+0x101/0x2a0 net/core/sock.c:1333
>> >>  [<ffffffff831efd15>] sk_alloc+0x105/0x1000 net/core/sock.c:1389
>> >>  [<ffffffff8348ad46>] __netlink_create+0x66/0x1d0 net/netlink/af_netlink.c:588
>> >>  [<ffffffff8348cdab>] netlink_create+0x2fb/0x500 net/netlink/af_netlink.c:647
>> >>  [<ffffffff831dd1d6>] __sock_create+0x4f6/0x880 net/socket.c:1168
>> >>  [<     inline     >] sock_create net/socket.c:1208
>> >>  [<     inline     >] SYSC_socket net/socket.c:1238
>> >>  [<ffffffff831dd799>] SyS_socket+0xf9/0x230 net/socket.c:1218
>> >>  [<ffffffff84a29fc1>] entry_SYSCALL_64_fastpath+0x1f/0xc2
>> >>
>> >> Memory state around the buggy address:
>> >>  ffff880067f3eb80: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
>> >>  ffff880067f3ec00: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
>> >>>ffff880067f3ec80: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
>> >>                                                     ^
>> >>  ffff880067f3ed00: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
>> >>  ffff880067f3ed80: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
>> >> ==================================================================
>>
>> Here is another report that looks related:
>>
>> ==================================================================
>> BUG: KASAN: use-after-free in __list_add+0x236/0x2c0
>> Read of size 8 at addr ffff880068854780 by task ksoftirqd/2/20
>>
>> page:ffffea0001a21400 count:1 mapcount:0 mapping:          (null)
>> index:0x0 compound_mapcount: 0
>> flags: 0x500000000004080(slab|head)
>> page dumped because: kasan: bad access detected
>>
>> CPU: 2 PID: 20 Comm: ksoftirqd/2 Not tainted 4.9.0-rc7+ #66
>> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
>>  ffff88006daf6578 ffffffff81f882da ffffffff6daf62a0 1ffff1000db5ec42
>>  ffffed000db5ec3a dffffc0000000000 0000000041b58ab3 ffffffff8541e198
>>  ffffffff81f88048 ffff88006dac3610 ffff88006daf6300 0000000000000802
>> Call Trace:
>>  [<     inline     >] __dump_stack lib/dump_stack.c:15
>>  [<ffffffff81f882da>] dump_stack+0x292/0x398 lib/dump_stack.c:51
>>  [<     inline     >] describe_address mm/kasan/report.c:262
>>  [<ffffffff817e50d1>] kasan_report_error+0x121/0x560 mm/kasan/report.c:368
>>  [<     inline     >] kasan_report mm/kasan/report.c:390
>>  [<ffffffff817e560e>] __asan_report_load8_noabort+0x3e/0x40
>> mm/kasan/report.c:411
>>  [<ffffffff8200c166>] __list_add+0x236/0x2c0 lib/list_debug.c:30
>>  [<     inline     >] list_add_tail include/linux/list.h:77
>>  [<ffffffff8131e295>] insert_work+0x175/0x4b0 kernel/workqueue.c:1298
>>  [<ffffffff8131eb52>] __queue_work+0x582/0x11e0 kernel/workqueue.c:1459
>>  [<ffffffff81320c21>] queue_work_on+0x231/0x240 kernel/workqueue.c:1484
>>  [<     inline     >] queue_work include/linux/workqueue.h:474
>>  [<     inline     >] schedule_work include/linux/workqueue.h:532
>>  [<ffffffff8348c8cc>] netlink_sock_destruct+0x23c/0x2d0
>> net/netlink/af_netlink.c:361
>>  [<ffffffff831e9ce1>] __sk_destruct+0xe1/0x6e0 net/core/sock.c:1423
>>  [<ffffffff831f3517>] sk_destruct+0x47/0x80 net/core/sock.c:1453
>>  [<ffffffff831f35a7>] __sk_free+0x57/0x230 net/core/sock.c:1461
>>  [<ffffffff831f37a3>] sk_free+0x23/0x30 net/core/sock.c:1472
>>  [<     inline     >] sock_put include/net/sock.h:1591
>>  [<ffffffff8348ca9c>] deferred_put_nlk_sk+0x2c/0x40 net/netlink/af_netlink.c:671
>>  [<     inline     >] __rcu_reclaim kernel/rcu/rcu.h:118
>>  [<ffffffff8146d42f>] rcu_do_batch.isra.67+0x8ff/0xc50 kernel/rcu/tree.c:2776
>>  [<     inline     >] invoke_rcu_callbacks kernel/rcu/tree.c:3040
>>  [<     inline     >] __rcu_process_callbacks kernel/rcu/tree.c:3007
>>  [<ffffffff8146e097>] rcu_process_callbacks+0x2b7/0xba0 kernel/rcu/tree.c:3024
>>  [<ffffffff84a2d08b>] __do_softirq+0x2fb/0xb63 kernel/softirq.c:284
>>  [<ffffffff812d38c0>] run_ksoftirqd+0x20/0x60 kernel/softirq.c:676
>>  [<ffffffff81350132>] smpboot_thread_fn+0x562/0x860 kernel/smpboot.c:163
>>  [<ffffffff8133ebf3>] kthread+0x323/0x3e0 kernel/kthread.c:209
>>  [<ffffffff84a2a22a>] ret_from_fork+0x2a/0x40 arch/x86/entry/entry_64.S:433
>>
>> The buggy address belongs to the object at ffff880068854170
>>  which belongs to the cache kmalloc-2048 of size 2048
>> The buggy address ffff880068854780 is located 1552 bytes inside
>>  of 2048-byte region [ffff880068854170, ffff880068854970)
>>
>> Freed by task 20:
>>  [<ffffffff81203526>] save_stack_trace+0x16/0x20 arch/x86/kernel/stacktrace.c:57
>>  [<ffffffff817e4173>] save_stack+0x43/0xd0 mm/kasan/kasan.c:495
>>  [<     inline     >] set_track mm/kasan/kasan.c:507
>>  [<ffffffff817e4a53>] kasan_slab_free+0x73/0xc0 mm/kasan/kasan.c:571
>>  [<     inline     >] slab_free_hook mm/slub.c:1352
>>  [<     inline     >] slab_free_freelist_hook mm/slub.c:1374
>>  [<     inline     >] slab_free mm/slub.c:2951
>>  [<ffffffff817e0eb7>] kfree+0xe7/0x2b0 mm/slub.c:3871
>>  [<     inline     >] sk_prot_free net/core/sock.c:1372
>>  [<ffffffff831ea1c7>] __sk_destruct+0x5c7/0x6e0 net/core/sock.c:1445
>>  [<ffffffff831f3517>] sk_destruct+0x47/0x80 net/core/sock.c:1453
>>  [<ffffffff831f35a7>] __sk_free+0x57/0x230 net/core/sock.c:1461
>>  [<ffffffff831f37a3>] sk_free+0x23/0x30 net/core/sock.c:1472
>>  [<     inline     >] sock_put include/net/sock.h:1591
>>  [<ffffffff8348ca9c>] deferred_put_nlk_sk+0x2c/0x40 net/netlink/af_netlink.c:671
>>  [<     inline     >] __rcu_reclaim kernel/rcu/rcu.h:118
>>  [<ffffffff8146d42f>] rcu_do_batch.isra.67+0x8ff/0xc50 kernel/rcu/tree.c:2776
>>  [<     inline     >] invoke_rcu_callbacks kernel/rcu/tree.c:3040
>>  [<     inline     >] __rcu_process_callbacks kernel/rcu/tree.c:3007
>>  [<ffffffff8146e097>] rcu_process_callbacks+0x2b7/0xba0 kernel/rcu/tree.c:3024
>>  [<ffffffff84a2d08b>] __do_softirq+0x2fb/0xb63 kernel/softirq.c:284
>>
>> Allocated by task 9480:
>>  [<ffffffff81203526>] save_stack_trace+0x16/0x20 arch/x86/kernel/stacktrace.c:57
>>  [<ffffffff817e4173>] save_stack+0x43/0xd0 mm/kasan/kasan.c:495
>>  [<     inline     >] set_track mm/kasan/kasan.c:507
>>  [<ffffffff817e43fd>] kasan_kmalloc+0xad/0xe0 mm/kasan/kasan.c:598
>>  [<ffffffff817e0050>] __kmalloc+0xa0/0x2d0 mm/slub.c:3734
>>  [<     inline     >] kmalloc include/linux/slab.h:495
>>  [<ffffffff831e4c01>] sk_prot_alloc+0x101/0x2a0 net/core/sock.c:1333
>>  [<ffffffff831efd15>] sk_alloc+0x105/0x1000 net/core/sock.c:1389
>>  [<ffffffff8348ad46>] __netlink_create+0x66/0x1d0 net/netlink/af_netlink.c:588
>>  [<ffffffff8348cdab>] netlink_create+0x2fb/0x500 net/netlink/af_netlink.c:647
>>  [<ffffffff831dd1d6>] __sock_create+0x4f6/0x880 net/socket.c:1168
>>  [<     inline     >] sock_create net/socket.c:1208
>>  [<     inline     >] SYSC_socket net/socket.c:1238
>>  [<ffffffff831dd799>] SyS_socket+0xf9/0x230 net/socket.c:1218
>>  [<ffffffff84a29fc1>] entry_SYSCALL_64_fastpath+0x1f/0xc2
>>
>> Memory state around the buggy address:
>>  ffff880068854680: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
>>  ffff880068854700: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
>> >ffff880068854780: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
>>                    ^
>>  ffff880068854800: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
>>  ffff880068854880: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
>> ==================================================================
>
>
> Hi Andrey. Please give us some rest during the week end ;)

Hi Eric,

Sorry, wanted to restart fuzzer on newer kernel and immediately
started getting enormous amount of crashes :)

>
> This looks like the bug I mentioned earlier for which I have a pending
> patch ? Can you try it ?

No, it seems that your patch doesn't help, this is apparently something else.

I've attached a reproducer.

Thanks!

>
> The RCU conversion done by Thomas was quite buggy.
>
> Thanks.
>
>
> diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
> index 602e5ebe9db39ec6c72708628bc48efad9f0e680..c348c4a5ea4ecc05dcc9e2afbc069ab65a1a57fe 100644
> --- a/net/netlink/af_netlink.c
> +++ b/net/netlink/af_netlink.c
> @@ -475,8 +475,8 @@ static struct sock *netlink_lookup(struct net *net, int protocol, u32 portid)
>
>         rcu_read_lock();
>         sk = __netlink_lookup(table, portid, net);
> -       if (sk)
> -               sock_hold(sk);
> +       if (sk && !atomic_inc_not_zero(&sk->sk_refcnt))
> +               sk = NULL;
>         rcu_read_unlock();
>
>         return sk;
> @@ -600,6 +600,7 @@ static int __netlink_create(struct net *net, struct socket *sock,
>         }
>         init_waitqueue_head(&nlk->wait);
>
> +       sock_set_flag(sk, SOCK_RCU_FREE);
>         sk->sk_destruct = netlink_sock_destruct;
>         sk->sk_protocol = protocol;
>         return 0;
> @@ -664,13 +665,6 @@ static int netlink_create(struct net *net, struct socket *sock, int protocol,
>         goto out;
>  }
>
> -static void deferred_put_nlk_sk(struct rcu_head *head)
> -{
> -       struct netlink_sock *nlk = container_of(head, struct netlink_sock, rcu);
> -
> -       sock_put(&nlk->sk);
> -}
> -
>  static int netlink_release(struct socket *sock)
>  {
>         struct sock *sk = sock->sk;
> @@ -743,7 +737,7 @@ static int netlink_release(struct socket *sock)
>         local_bh_disable();
>         sock_prot_inuse_add(sock_net(sk), &netlink_proto, -1);
>         local_bh_enable();
> -       call_rcu(&nlk->rcu, deferred_put_nlk_sk);
> +       sock_put(sk);
>         return 0;
>  }
>
> diff --git a/net/netlink/af_netlink.h b/net/netlink/af_netlink.h
> index 4fdb3831897775547f77c069a8018c0d2a253c8c..988d1a02487e37b7efd4872dd0ab6d230e5a2021 100644
> --- a/net/netlink/af_netlink.h
> +++ b/net/netlink/af_netlink.h
> @@ -33,7 +33,6 @@ struct netlink_sock {
>         struct module           *module;
>
>         struct rhash_head       node;
> -       struct rcu_head         rcu;
>         struct work_struct      work;
>  };
>
>
>
>
> --
> You received this message because you are subscribed to the Google Groups "syzkaller" group.
> To unsubscribe from this group and stop receiving emails from it, send an email to syzkaller+unsubscribe@googlegroups.com.
> For more options, visit https://groups.google.com/d/optout.

--001a11406a82f9dd5c0542c2dcd0
Content-Type: text/x-csrc; charset=US-ASCII; name="worker-crash-poc.c"
Content-Disposition: attachment; filename="worker-crash-poc.c"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_iw9dxf2a0

Ly8gYXV0b2dlbmVyYXRlZCBieSBzeXprYWxsZXIgKGh0dHA6Ly9naXRodWIuY29tL2dvb2dsZS9z
eXprYWxsZXIpCgojaWZuZGVmIF9fTlJfc29ja2V0CiNkZWZpbmUgX19OUl9zb2NrZXQgNDEKI2Vu
ZGlmCiNpZm5kZWYgX19OUl93cml0ZQojZGVmaW5lIF9fTlJfd3JpdGUgMQojZW5kaWYKI2lmbmRl
ZiBfX05SX3JlYWR2CiNkZWZpbmUgX19OUl9yZWFkdiAxOQojZW5kaWYKI2lmbmRlZiBfX05SX21t
YXAKI2RlZmluZSBfX05SX21tYXAgOQojZW5kaWYKCiNkZWZpbmUgX0dOVV9TT1VSQ0UKCiNpbmNs
dWRlIDxzeXMvaW9jdGwuaD4KI2luY2x1ZGUgPHN5cy9tb3VudC5oPgojaW5jbHVkZSA8c3lzL3By
Y3RsLmg+CiNpbmNsdWRlIDxzeXMvcmVzb3VyY2UuaD4KI2luY2x1ZGUgPHN5cy9zb2NrZXQuaD4K
I2luY2x1ZGUgPHN5cy9zdGF0Lmg+CiNpbmNsdWRlIDxzeXMvc3lzY2FsbC5oPgojaW5jbHVkZSA8
c3lzL3RpbWUuaD4KI2luY2x1ZGUgPHN5cy90eXBlcy5oPgojaW5jbHVkZSA8c3lzL3dhaXQuaD4K
CiNpbmNsdWRlIDxsaW51eC9jYXBhYmlsaXR5Lmg+CiNpbmNsdWRlIDxsaW51eC9pZi5oPgojaW5j
bHVkZSA8bGludXgvaWZfdHVuLmg+CiNpbmNsdWRlIDxsaW51eC9zY2hlZC5oPgojaW5jbHVkZSA8
bmV0L2lmX2FycC5oPgoKI2luY2x1ZGUgPGFzc2VydC5oPgojaW5jbHVkZSA8ZGlyZW50Lmg+CiNp
bmNsdWRlIDxlcnJuby5oPgojaW5jbHVkZSA8ZmNudGwuaD4KI2luY2x1ZGUgPGdycC5oPgojaW5j
bHVkZSA8cHRocmVhZC5oPgojaW5jbHVkZSA8c2V0am1wLmg+CiNpbmNsdWRlIDxzaWduYWwuaD4K
I2luY2x1ZGUgPHN0ZGFyZy5oPgojaW5jbHVkZSA8c3RkYm9vbC5oPgojaW5jbHVkZSA8c3RkZGVm
Lmg+CiNpbmNsdWRlIDxzdGRpbnQuaD4KI2luY2x1ZGUgPHN0ZGlvLmg+CiNpbmNsdWRlIDxzdGRs
aWIuaD4KI2luY2x1ZGUgPHN0cmluZy5oPgojaW5jbHVkZSA8dW5pc3RkLmg+Cgpjb25zdCBpbnQg
a0ZhaWxTdGF0dXMgPSA2NzsKY29uc3QgaW50IGtFcnJvclN0YXR1cyA9IDY4Owpjb25zdCBpbnQg
a1JldHJ5U3RhdHVzID0gNjk7CgpfX2F0dHJpYnV0ZV9fKChub3JldHVybikpIHZvaWQgZmFpbChj
b25zdCBjaGFyKiBtc2csIC4uLikKewogIGludCBlID0gZXJybm87CiAgZmZsdXNoKHN0ZG91dCk7
CiAgdmFfbGlzdCBhcmdzOwogIHZhX3N0YXJ0KGFyZ3MsIG1zZyk7CiAgdmZwcmludGYoc3RkZXJy
LCBtc2csIGFyZ3MpOwogIHZhX2VuZChhcmdzKTsKICBmcHJpbnRmKHN0ZGVyciwgIiAoZXJybm8g
JWQpXG4iLCBlKTsKICBleGl0KGtGYWlsU3RhdHVzKTsKfQoKX19hdHRyaWJ1dGVfXygobm9yZXR1
cm4pKSB2b2lkIGV4aXRmKGNvbnN0IGNoYXIqIG1zZywgLi4uKQp7CiAgaW50IGUgPSBlcnJubzsK
ICBmZmx1c2goc3Rkb3V0KTsKICB2YV9saXN0IGFyZ3M7CiAgdmFfc3RhcnQoYXJncywgbXNnKTsK
ICB2ZnByaW50ZihzdGRlcnIsIG1zZywgYXJncyk7CiAgdmFfZW5kKGFyZ3MpOwogIGZwcmludGYo
c3RkZXJyLCAiIChlcnJubyAlZClcbiIsIGUpOwogIGV4aXQoa1JldHJ5U3RhdHVzKTsKfQoKc3Rh
dGljIGludCBmbGFnX2RlYnVnOwoKdm9pZCBkZWJ1Zyhjb25zdCBjaGFyKiBtc2csIC4uLikKewog
IGlmICghZmxhZ19kZWJ1ZykKICAgIHJldHVybjsKICB2YV9saXN0IGFyZ3M7CiAgdmFfc3RhcnQo
YXJncywgbXNnKTsKICB2ZnByaW50ZihzdGRvdXQsIG1zZywgYXJncyk7CiAgdmFfZW5kKGFyZ3Mp
OwogIGZmbHVzaChzdGRvdXQpOwp9CgpfX3RocmVhZCBpbnQgc2tpcF9zZWd2OwpfX3RocmVhZCBq
bXBfYnVmIHNlZ3ZfZW52OwoKc3RhdGljIHZvaWQgc2Vndl9oYW5kbGVyKGludCBzaWcsIHNpZ2lu
Zm9fdCogaW5mbywgdm9pZCogdWN0eCkKewogIGlmIChfX2F0b21pY19sb2FkX24oJnNraXBfc2Vn
diwgX19BVE9NSUNfUkVMQVhFRCkpCiAgICBfbG9uZ2ptcChzZWd2X2VudiwgMSk7CiAgZXhpdChz
aWcpOwp9CgpzdGF0aWMgdm9pZCBpbnN0YWxsX3NlZ3ZfaGFuZGxlcigpCnsKICBzdHJ1Y3Qgc2ln
YWN0aW9uIHNhOwogIG1lbXNldCgmc2EsIDAsIHNpemVvZihzYSkpOwogIHNhLnNhX3NpZ2FjdGlv
biA9IHNlZ3ZfaGFuZGxlcjsKICBzYS5zYV9mbGFncyA9IFNBX05PREVGRVIgfCBTQV9TSUdJTkZP
OwogIHNpZ2FjdGlvbihTSUdTRUdWLCAmc2EsIE5VTEwpOwogIHNpZ2FjdGlvbihTSUdCVVMsICZz
YSwgTlVMTCk7Cn0KCiNkZWZpbmUgTk9ORkFJTElORyguLi4pICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgXAogIHsgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIFwKICAgIF9fYXRvbWlj
X2ZldGNoX2FkZCgmc2tpcF9zZWd2LCAxLCBfX0FUT01JQ19TRVFfQ1NUKTsgICAgICAgICAgICAg
ICBcCiAgICBpZiAoX3NldGptcChzZWd2X2VudikgPT0gMCkgeyAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgXAogICAgICBfX1ZBX0FSR1NfXzsgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIFwKICAgIH0gICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICBcCiAgICBf
X2F0b21pY19mZXRjaF9zdWIoJnNraXBfc2VndiwgMSwgX19BVE9NSUNfU0VRX0NTVCk7ICAgICAg
ICAgICAgICAgXAogIH0KCnN0YXRpYyB1aW50cHRyX3QgZXhlY3V0ZV9zeXNjYWxsKGludCBuciwg
dWludHB0cl90IGEwLCB1aW50cHRyX3QgYTEsCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgIHVpbnRwdHJfdCBhMiwgdWludHB0cl90IGEzLAogICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICB1aW50cHRyX3QgYTQsIHVpbnRwdHJfdCBhNSwKICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgdWludHB0cl90IGE2LCB1aW50cHRyX3QgYTcsCiAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgIHVpbnRwdHJfdCBhOCkKewogIHN3aXRjaCAobnIpIHsKICBkZWZhdWx0
OgogICAgcmV0dXJuIHN5c2NhbGwobnIsIGEwLCBhMSwgYTIsIGEzLCBhNCwgYTUpOwogIH0KfQoK
c3RhdGljIHZvaWQgc2V0dXBfbWFpbl9wcm9jZXNzKHVpbnQ2NF90IHBpZCwgYm9vbCBlbmFibGVf
dHVuKQp7CiAgc3RydWN0IHNpZ2FjdGlvbiBzYTsKICBtZW1zZXQoJnNhLCAwLCBzaXplb2Yoc2Ep
KTsKICBzYS5zYV9oYW5kbGVyID0gU0lHX0lHTjsKICBzeXNjYWxsKFNZU19ydF9zaWdhY3Rpb24s
IDB4MjAsICZzYSwgTlVMTCwgOCk7CiAgc3lzY2FsbChTWVNfcnRfc2lnYWN0aW9uLCAweDIxLCAm
c2EsIE5VTEwsIDgpOwogIGluc3RhbGxfc2Vndl9oYW5kbGVyKCk7CgogIGNoYXIgdG1wZGlyX3Rl
bXBsYXRlW10gPSAiLi9zeXprYWxsZXIuWFhYWFhYIjsKICBjaGFyKiB0bXBkaXIgPSBta2R0ZW1w
KHRtcGRpcl90ZW1wbGF0ZSk7CiAgaWYgKCF0bXBkaXIpCiAgICBmYWlsKCJmYWlsZWQgdG8gbWtk
dGVtcCIpOwogIGlmIChjaG1vZCh0bXBkaXIsIDA3NzcpKQogICAgZmFpbCgiZmFpbGVkIHRvIGNo
bW9kIik7CiAgaWYgKGNoZGlyKHRtcGRpcikpCiAgICBmYWlsKCJmYWlsZWQgdG8gY2hkaXIiKTsK
fQoKc3RhdGljIHZvaWQgbG9vcCgpOwoKc3RhdGljIHZvaWQgc2FuZGJveF9jb21tb24oKQp7CiAg
cHJjdGwoUFJfU0VUX1BERUFUSFNJRywgU0lHS0lMTCwgMCwgMCwgMCk7CiAgc2V0cGdycCgpOwog
IHNldHNpZCgpOwoKICBzdHJ1Y3QgcmxpbWl0IHJsaW07CiAgcmxpbS5ybGltX2N1ciA9IHJsaW0u
cmxpbV9tYXggPSAxMjggPDwgMjA7CiAgc2V0cmxpbWl0KFJMSU1JVF9BUywgJnJsaW0pOwogIHJs
aW0ucmxpbV9jdXIgPSBybGltLnJsaW1fbWF4ID0gMSA8PCAyMDsKICBzZXRybGltaXQoUkxJTUlU
X0ZTSVpFLCAmcmxpbSk7CiAgcmxpbS5ybGltX2N1ciA9IHJsaW0ucmxpbV9tYXggPSAxIDw8IDIw
OwogIHNldHJsaW1pdChSTElNSVRfU1RBQ0ssICZybGltKTsKICBybGltLnJsaW1fY3VyID0gcmxp
bS5ybGltX21heCA9IDA7CiAgc2V0cmxpbWl0KFJMSU1JVF9DT1JFLCAmcmxpbSk7CgogIHVuc2hh
cmUoQ0xPTkVfTkVXTlMpOwogIHVuc2hhcmUoQ0xPTkVfTkVXSVBDKTsKICB1bnNoYXJlKENMT05F
X0lPKTsKfQoKc3RhdGljIGludCBkb19zYW5kYm94X25vbmUoKQp7CiAgaW50IHBpZCA9IGZvcmso
KTsKICBpZiAocGlkKQogICAgcmV0dXJuIHBpZDsKICBzYW5kYm94X2NvbW1vbigpOwogIGxvb3Ao
KTsKICBleGl0KDEpOwp9CgpzdGF0aWMgdm9pZCByZW1vdmVfZGlyKGNvbnN0IGNoYXIqIGRpcikK
ewogIERJUiogZHA7CiAgc3RydWN0IGRpcmVudCogZXA7CiAgaW50IGl0ZXIgPSAwOwpyZXRyeToK
ICBkcCA9IG9wZW5kaXIoZGlyKTsKICBpZiAoZHAgPT0gTlVMTCkgewogICAgaWYgKGVycm5vID09
IEVNRklMRSkgewogICAgICBleGl0Zigib3BlbmRpciglcykgZmFpbGVkIGR1ZSB0byBOT0ZJTEUs
IGV4aXRpbmciKTsKICAgIH0KICAgIGV4aXRmKCJvcGVuZGlyKCVzKSBmYWlsZWQiLCBkaXIpOwog
IH0KICB3aGlsZSAoKGVwID0gcmVhZGRpcihkcCkpKSB7CiAgICBpZiAoc3RyY21wKGVwLT5kX25h
bWUsICIuIikgPT0gMCB8fCBzdHJjbXAoZXAtPmRfbmFtZSwgIi4uIikgPT0gMCkKICAgICAgY29u
dGludWU7CiAgICBjaGFyIGZpbGVuYW1lW0ZJTEVOQU1FX01BWF07CiAgICBzbnByaW50ZihmaWxl
bmFtZSwgc2l6ZW9mKGZpbGVuYW1lKSwgIiVzLyVzIiwgZGlyLCBlcC0+ZF9uYW1lKTsKICAgIHN0
cnVjdCBzdGF0IHN0OwogICAgaWYgKGxzdGF0KGZpbGVuYW1lLCAmc3QpKQogICAgICBleGl0Zigi
bHN0YXQoJXMpIGZhaWxlZCIsIGZpbGVuYW1lKTsKICAgIGlmIChTX0lTRElSKHN0LnN0X21vZGUp
KSB7CiAgICAgIHJlbW92ZV9kaXIoZmlsZW5hbWUpOwogICAgICBjb250aW51ZTsKICAgIH0KICAg
IGludCBpOwogICAgZm9yIChpID0gMDs7IGkrKykgewogICAgICBkZWJ1ZygidW5saW5rKCVzKVxu
IiwgZmlsZW5hbWUpOwogICAgICBpZiAodW5saW5rKGZpbGVuYW1lKSA9PSAwKQogICAgICAgIGJy
ZWFrOwogICAgICBpZiAoZXJybm8gPT0gRVJPRlMpIHsKICAgICAgICBkZWJ1ZygiaWdub3Jpbmcg
RVJPRlNcbiIpOwogICAgICAgIGJyZWFrOwogICAgICB9CiAgICAgIGlmIChlcnJubyAhPSBFQlVT
WSB8fCBpID4gMTAwKQogICAgICAgIGV4aXRmKCJ1bmxpbmsoJXMpIGZhaWxlZCIsIGZpbGVuYW1l
KTsKICAgICAgZGVidWcoInVtb3VudCglcylcbiIsIGZpbGVuYW1lKTsKICAgICAgaWYgKHVtb3Vu
dDIoZmlsZW5hbWUsIE1OVF9ERVRBQ0gpKQogICAgICAgIGV4aXRmKCJ1bW91bnQoJXMpIGZhaWxl
ZCIsIGZpbGVuYW1lKTsKICAgIH0KICB9CiAgY2xvc2VkaXIoZHApOwogIGludCBpOwogIGZvciAo
aSA9IDA7OyBpKyspIHsKICAgIGRlYnVnKCJybWRpciglcylcbiIsIGRpcik7CiAgICBpZiAocm1k
aXIoZGlyKSA9PSAwKQogICAgICBicmVhazsKICAgIGlmIChpIDwgMTAwKSB7CiAgICAgIGlmIChl
cnJubyA9PSBFUk9GUykgewogICAgICAgIGRlYnVnKCJpZ25vcmluZyBFUk9GU1xuIik7CiAgICAg
ICAgYnJlYWs7CiAgICAgIH0KICAgICAgaWYgKGVycm5vID09IEVCVVNZKSB7CiAgICAgICAgZGVi
dWcoInVtb3VudCglcylcbiIsIGRpcik7CiAgICAgICAgaWYgKHVtb3VudDIoZGlyLCBNTlRfREVU
QUNIKSkKICAgICAgICAgIGV4aXRmKCJ1bW91bnQoJXMpIGZhaWxlZCIsIGRpcik7CiAgICAgICAg
Y29udGludWU7CiAgICAgIH0KICAgICAgaWYgKGVycm5vID09IEVOT1RFTVBUWSkgewogICAgICAg
IGlmIChpdGVyIDwgMTAwKSB7CiAgICAgICAgICBpdGVyKys7CiAgICAgICAgICBnb3RvIHJldHJ5
OwogICAgICAgIH0KICAgICAgfQogICAgfQogICAgZXhpdGYoInJtZGlyKCVzKSBmYWlsZWQiLCBk
aXIpOwogIH0KfQoKc3RhdGljIHVpbnQ2NF90IGN1cnJlbnRfdGltZV9tcygpCnsKICBzdHJ1Y3Qg
dGltZXNwZWMgdHM7CgogIGlmIChjbG9ja19nZXR0aW1lKENMT0NLX01PTk9UT05JQywgJnRzKSkK
ICAgIGZhaWwoImNsb2NrX2dldHRpbWUgZmFpbGVkIik7CiAgcmV0dXJuICh1aW50NjRfdCl0cy50
dl9zZWMgKiAxMDAwICsgKHVpbnQ2NF90KXRzLnR2X25zZWMgLyAxMDAwMDAwOwp9CgpzdGF0aWMg
dm9pZCB0ZXN0KCk7Cgp2b2lkIGxvb3AoKQp7CiAgaW50IGl0ZXI7CiAgZm9yIChpdGVyID0gMDs7
IGl0ZXIrKykgewogICAgY2hhciBjd2RidWZbMjU2XTsKICAgIHNwcmludGYoY3dkYnVmLCAiLi8l
ZCIsIGl0ZXIpOwogICAgaWYgKG1rZGlyKGN3ZGJ1ZiwgMDc3NykpCiAgICAgIGZhaWwoImZhaWxl
ZCB0byBta2RpciIpOwogICAgaW50IHBpZCA9IGZvcmsoKTsKICAgIGlmIChwaWQgPCAwKQogICAg
ICBmYWlsKCJjbG9uZSBmYWlsZWQiKTsKICAgIGlmIChwaWQgPT0gMCkgewogICAgICBwcmN0bChQ
Ul9TRVRfUERFQVRIU0lHLCBTSUdLSUxMLCAwLCAwLCAwKTsKICAgICAgc2V0cGdycCgpOwogICAg
ICBpZiAoY2hkaXIoY3dkYnVmKSkKICAgICAgICBmYWlsKCJmYWlsZWQgdG8gY2hkaXIiKTsKICAg
ICAgdGVzdCgpOwogICAgICBleGl0KDApOwogICAgfQogICAgaW50IHN0YXR1cyA9IDA7CiAgICB1
aW50NjRfdCBzdGFydCA9IGN1cnJlbnRfdGltZV9tcygpOwogICAgZm9yICg7OykgewogICAgICBp
bnQgcmVzID0gd2FpdHBpZChwaWQsICZzdGF0dXMsIF9fV0FMTCB8IFdOT0hBTkcpOwogICAgICBp
bnQgZXJybm8wID0gZXJybm87CiAgICAgIGlmIChyZXMgPT0gcGlkKQogICAgICAgIGJyZWFrOwog
ICAgICB1c2xlZXAoMTAwMCk7CiAgICAgIGlmIChjdXJyZW50X3RpbWVfbXMoKSAtIHN0YXJ0ID4g
NSAqIDEwMDApIHsKICAgICAgICBraWxsKC1waWQsIFNJR0tJTEwpOwogICAgICAgIGtpbGwocGlk
LCBTSUdLSUxMKTsKICAgICAgICB3YWl0cGlkKHBpZCwgJnN0YXR1cywgX19XQUxMKTsKICAgICAg
ICBicmVhazsKICAgICAgfQogICAgfQogICAgcmVtb3ZlX2Rpcihjd2RidWYpOwogIH0KfQoKbG9u
ZyByWzddOwp2b2lkKiB0aHIodm9pZCogYXJnKQp7CiAgc3dpdGNoICgobG9uZylhcmcpIHsKICBj
YXNlIDA6CiAgICByWzBdID0KICAgICAgICBleGVjdXRlX3N5c2NhbGwoX19OUl9tbWFwLCAweDIw
MDAwMDAwdWwsIDB4ZTQzMDAwdWwsIDB4M3VsLAogICAgICAgICAgICAgICAgICAgICAgICAweDMy
dWwsIDB4ZmZmZmZmZmZmZmZmZmZmZnVsLCAweDB1bCwgMCwgMCwgMCk7CiAgICBicmVhazsKICBj
YXNlIDE6CiAgICByWzFdID0gZXhlY3V0ZV9zeXNjYWxsKF9fTlJfc29ja2V0LCAweDEwdWwsIDB4
M3VsLCAweDB1bCwgMCwgMCwgMCwKICAgICAgICAgICAgICAgICAgICAgICAgICAgMCwgMCwgMCk7
CiAgICBicmVhazsKICBjYXNlIDI6CiAgICBOT05GQUlMSU5HKG1lbWNweSgodm9pZCopMHgyMGU0
MmZlMSwKICAgICAgICAgICAgICAgICAgICAgICJceDFmXHgwMFx4MDBceDAwXHgxYVx4MDBceDAz
XHhmMlx4MDBceDAwXHgxM1x4ZmYiCiAgICAgICAgICAgICAgICAgICAgICAiXHgwN1x4MDBceDAw
XHg3N1x4MDBceDAwXHhmZlx4ZmZceGZmXHg3Zlx4ZDhceDAwIgogICAgICAgICAgICAgICAgICAg
ICAgIlx4MDBceDAwXHgwMFx4MDBceDAwXHgwMFx4MzQiLAogICAgICAgICAgICAgICAgICAgICAg
MzEpKTsKICAgIHJbM10gPSBleGVjdXRlX3N5c2NhbGwoX19OUl93cml0ZSwgclsxXSwgMHgyMGU0
MmZlMXVsLCAweDFmdWwsIDAsIDAsCiAgICAgICAgICAgICAgICAgICAgICAgICAgIDAsIDAsIDAs
IDApOwogICAgYnJlYWs7CiAgY2FzZSAzOgogICAgTk9ORkFJTElORygqKHVpbnQ2NF90KikweDIw
ZTQxMDAwID0gKHVpbnQ2NF90KTB4MjBlM2VmMTEpOwogICAgTk9ORkFJTElORygqKHVpbnQ2NF90
KikweDIwZTQxMDA4ID0gKHVpbnQ2NF90KTB4MSk7CiAgICByWzZdID0gZXhlY3V0ZV9zeXNjYWxs
KF9fTlJfcmVhZHYsIHJbMV0sIDB4MjBlNDEwMDB1bCwgMHgxdWwsIDAsIDAsCiAgICAgICAgICAg
ICAgICAgICAgICAgICAgIDAsIDAsIDAsIDApOwogICAgYnJlYWs7CiAgfQogIHJldHVybiAwOwp9
Cgp2b2lkIHRlc3QoKQp7CiAgbG9uZyBpOwogIHB0aHJlYWRfdCB0aFs4XTsKCiAgbWVtc2V0KHIs
IC0xLCBzaXplb2YocikpOwogIHNyYW5kKGdldHBpZCgpKTsKICBmb3IgKGkgPSAwOyBpIDwgNDsg
aSsrKSB7CiAgICBwdGhyZWFkX2NyZWF0ZSgmdGhbaV0sIDAsIHRociwgKHZvaWQqKWkpOwogICAg
dXNsZWVwKDEwMDAwKTsKICB9CiAgdXNsZWVwKDEwMDAwMCk7Cn0KCmludCBtYWluKCkKewogIHNl
dHVwX21haW5fcHJvY2VzcygwLCBmYWxzZSk7CiAgaW50IHBpZCA9IGRvX3NhbmRib3hfbm9uZSgp
OwogIGludCBzdGF0dXMgPSAwOwogIHdoaWxlICh3YWl0cGlkKHBpZCwgJnN0YXR1cywgX19XQUxM
KSAhPSBwaWQpIHsKICB9CiAgcmV0dXJuIDA7Cn0K
--001a11406a82f9dd5c0542c2dcd0--
