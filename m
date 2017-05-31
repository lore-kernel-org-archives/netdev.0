From: Eric Dumazet <edumazet@google.com>
Subject: Re: net/ipv6: use-after-free in ip6_dst_ifdown
Date: Wed, 31 May 2017 09:55:16 -0700
Message-ID: <CANn89iJ0Qd6FHXBva1sztCL0cVNk70J+3sQ9S0VAbVyTTD41fg@mail.gmail.com>
References: <CAAeHK+wBQgfW_mRjmP-rScMtvUfs61iCzCHn1SmkdnLGNyRm0A@mail.gmail.com>
 <CAM_iQpUxmME-9Gi9=dtAgeGeK4v3R0NV-REFRtMAU26yBXwrPQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Andrey Konovalov <andreyknvl@google.com>,
        "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        David Ahern <dsa@cumulusnetworks.com>,
        Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAM_iQpUxmME-9Gi9=dtAgeGeK4v3R0NV-REFRtMAU26yBXwrPQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 31, 2017 at 9:45 AM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> On Wed, May 31, 2017 at 2:42 AM, Andrey Konovalov <andreyknvl@google.com> wrote:
>> Hi,
>>
>> I've got the following error report while fuzzing the kernel with syzkaller.
>>
>> On commit 5ed02dbb497422bf225783f46e6eadd237d23d6b (4.12-rc3).
>>
>> Unfortunately it's not reproducible.
>>
>> ==================================================================
>> BUG: KASAN: use-after-free in ip6_dst_ifdown+0x3cc/0x400 net/ipv6/route.c:422
>> Read of size 8 at addr ffff88006afa4ad8 by task syz-executor6/23554
>
>
> This one is very interesting.
>
> Here we are at:
>
>         if (dev != loopback_dev) {
>                 if (idev && idev->dev == dev) {
>                         struct inet6_dev *loopback_idev =
>                                 in6_dev_get(loopback_dev);
>                         if (loopback_idev) {
>                                 rt->rt6i_idev = loopback_idev;
>                                 in6_dev_put(idev);
>                         }
>                 }
>         }
>
> clearly no skb involved, it looks like idev is the one used-after-free.
>
> But below it is actually skb which is allocated and freed...
>

skb->head was a kmalloc(X)   with X = 1024 in this case.

So it is very possible the two different objects (skb->head and idev )
 were accidentally using the same slab (1024 bytes).

KASAN only remember the last pair of alloc/free for a particular memory zone.

>
>>
>> CPU: 3 PID: 23554 Comm: syz-executor6 Not tainted 4.12.0-rc3+ #370
>> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
>> Call Trace:
>>  __dump_stack lib/dump_stack.c:16 [inline]
>>  dump_stack+0x292/0x395 lib/dump_stack.c:52
>>  print_address_description+0x73/0x280 mm/kasan/report.c:252
>>  kasan_report_error mm/kasan/report.c:351 [inline]
>>  kasan_report+0x22b/0x340 mm/kasan/report.c:408
>>  __asan_report_load8_noabort+0x14/0x20 mm/kasan/report.c:429
>>  ip6_dst_ifdown+0x3cc/0x400 net/ipv6/route.c:422
>>  dst_ifdown+0x75/0x230 net/core/dst.c:439
>>  dst_dev_event+0xb1/0x230 net/core/dst.c:466
>>  notifier_call_chain+0x145/0x2e0 kernel/notifier.c:93
>>  __raw_notifier_call_chain kernel/notifier.c:394 [inline]
>>  raw_notifier_call_chain+0x2d/0x40 kernel/notifier.c:401
>>  call_netdevice_notifiers_info+0x51/0x90 net/core/dev.c:1649
>>  call_netdevice_notifiers net/core/dev.c:1665 [inline]
>>  __dev_notify_flags+0x1fd/0x320 net/core/dev.c:6640
>>  dev_change_flags+0xf5/0x140 net/core/dev.c:6671
>>  dev_ifsioc+0x62a/0x9f0 net/core/dev_ioctl.c:254
>>  dev_ioctl+0x249/0x1160 net/core/dev_ioctl.c:532
>>  sock_do_ioctl+0x94/0xb0 net/socket.c:913
>>  sock_ioctl+0x28f/0x440 net/socket.c:1004
>>  vfs_ioctl fs/ioctl.c:45 [inline]
>>  do_vfs_ioctl+0x1bf/0x1660 fs/ioctl.c:685
>>  SYSC_ioctl fs/ioctl.c:700 [inline]
>>  SyS_ioctl+0x8f/0xc0 fs/ioctl.c:691
>>  entry_SYSCALL_64_fastpath+0x1f/0xbe
>> RIP: 0033:0x446179
>> RSP: 002b:00007fd1da4bdc08 EFLAGS: 00000282 ORIG_RAX: 0000000000000010
>> RAX: ffffffffffffffda RBX: 0000000000003220 RCX: 0000000000446179
>> RDX: 0000000020d34000 RSI: 0000000000008914 RDI: 0000000000000005
>> RBP: 00000000ffffffff R08: 0000000000000000 R09: 0000000000000000
>> R10: 0000000000000000 R11: 0000000000000282 R12: 0000000000000005
>> R13: 0000000000000390 R14: 00000000006e1450 R15: 0000000000000000
>>
>> Allocated by task 23235:
>>  save_stack_trace+0x16/0x20 arch/x86/kernel/stacktrace.c:59
>>  save_stack+0x43/0xd0 mm/kasan/kasan.c:513
>>  set_track mm/kasan/kasan.c:525 [inline]
>>  kasan_kmalloc+0xad/0xe0 mm/kasan/kasan.c:617
>>  kasan_slab_alloc+0x12/0x20 mm/kasan/kasan.c:555
>>  slab_post_alloc_hook mm/slab.h:456 [inline]
>>  slab_alloc_node mm/slub.c:2718 [inline]
>>  __kmalloc_node_track_caller+0x20d/0x350 mm/slub.c:4303
>>  __kmalloc_reserve.isra.32+0x41/0xd0 net/core/skbuff.c:138
>>  __alloc_skb+0x157/0x770 net/core/skbuff.c:231
>>  alloc_skb include/linux/skbuff.h:936 [inline]
>>  alloc_skb_with_frags+0x12e/0x780 net/core/skbuff.c:4690
>>  sock_alloc_send_pskb+0x804/0xa30 net/core/sock.c:2000
>>  tun_alloc_skb drivers/net/tun.c:1144 [inline]
>>  tun_get_user+0x91a/0x2e10 drivers/net/tun.c:1274
>>  tun_chr_write_iter+0xd8/0x190 drivers/net/tun.c:1365
>>  call_write_iter include/linux/fs.h:1734 [inline]
>>  new_sync_write fs/read_write.c:497 [inline]
>>  __vfs_write+0x483/0x760 fs/read_write.c:510
>>  vfs_write+0x187/0x500 fs/read_write.c:558
>>  SYSC_write fs/read_write.c:605 [inline]
>>  SyS_write+0xfb/0x230 fs/read_write.c:597
>>  entry_SYSCALL_64_fastpath+0x1f/0xbe
>>
>> Freed by task 23235:
>>  save_stack_trace+0x16/0x20 arch/x86/kernel/stacktrace.c:59
>>  save_stack+0x43/0xd0 mm/kasan/kasan.c:513
>>  set_track mm/kasan/kasan.c:525 [inline]
>>  kasan_slab_free+0x72/0xc0 mm/kasan/kasan.c:590
>>  slab_free_hook mm/slub.c:1357 [inline]
>>  slab_free_freelist_hook mm/slub.c:1379 [inline]
>>  slab_free mm/slub.c:2961 [inline]
>>  kfree+0xe8/0x2b0 mm/slub.c:3882
>>  skb_free_head+0x74/0xb0 net/core/skbuff.c:579
>>  skb_release_data+0x3ce/0x4a0 net/core/skbuff.c:610
>>  skb_release_all+0x4a/0x60 net/core/skbuff.c:669
>>  __kfree_skb+0x15/0x20 net/core/skbuff.c:683
>>  kfree_skb+0x16e/0x4e0 net/core/skbuff.c:704
>>  llc_rcv+0x5c7/0xed0 net/llc/llc_input.c:214
>>  __netif_receive_skb_core+0x1ad1/0x3400 net/core/dev.c:4216
>>  __netif_receive_skb+0x2c/0x1b0 net/core/dev.c:4254
>>  netif_receive_skb_internal+0x240/0x1b20 net/core/dev.c:4416
>>  netif_receive_skb+0xae/0x3b0 net/core/dev.c:4440
>>  tun_rx_batched.isra.40+0x5e5/0x8c0 drivers/net/tun.c:1167
>>  tun_get_user+0x100d/0x2e10 drivers/net/tun.c:1339
>>  tun_chr_write_iter+0xd8/0x190 drivers/net/tun.c:1365
>>  call_write_iter include/linux/fs.h:1734 [inline]
>>  new_sync_write fs/read_write.c:497 [inline]
>>  __vfs_write+0x483/0x760 fs/read_write.c:510
>>  vfs_write+0x187/0x500 fs/read_write.c:558
>>  SYSC_write fs/read_write.c:605 [inline]
>>  SyS_write+0xfb/0x230 fs/read_write.c:597
>>  entry_SYSCALL_64_fastpath+0x1f/0xbe
>>
>> The buggy address belongs to the object at ffff88006afa4ad8
>>  which belongs to the cache kmalloc-1024 of size 1024
>> The buggy address is located 0 bytes inside of
>>  1024-byte region [ffff88006afa4ad8, ffff88006afa4ed8)
>> The buggy address belongs to the page:
>> page:ffffea0001abe800 count:1 mapcount:0 mapping:          (null)
>> index:0x0 compound_mapcount: 0
>> flags: 0x500000000008100(slab|head)
>> raw: 0500000000008100 0000000000000000 0000000000000000 0000000100170017
>> raw: ffffea00017ef420 ffffea0001aaa420 ffff88003e80efc0 0000000000000000
>> page dumped because: kasan: bad access detected
>>
>> Memory state around the buggy address:
>>  ffff88006afa4980: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
>>  ffff88006afa4a00: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
>>>ffff88006afa4a80: fc fc fc fc fc fc fc fc fc fc fc fb fb fb fb fb
>>                                                     ^
>>  ffff88006afa4b00: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
>>  ffff88006afa4b80: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
>> ==================================================================
