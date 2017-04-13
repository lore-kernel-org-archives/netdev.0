From: Andrey Konovalov <andreyknvl@google.com>
Subject: Re: net/ipv4: use-after-free in ip_queue_xmit
Date: Thu, 13 Apr 2017 20:49:36 +0200
Message-ID: <CAAeHK+wV1aKoP_2cog-dp0-17g4QimfK5j8P3oxypE3mCxMGUw@mail.gmail.com>
References: <CAAeHK+z5=b4PdSrq8ff-btYbd-aKFR+uzQnoC5Pq4du4uVQjzQ@mail.gmail.com>
 <CAM_iQpWsEpJYHG1WvC9kQPt8iezBuLC8PeSqM20=W9cpkRE6=Q@mail.gmail.com> <CAAeHK+xZG+V8W85=bzpj0EgbmZo0c2Sq6e0LxtHMZM8wje-yPA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f53.google.com ([74.125.83.53]:34191 "EHLO
        mail-pg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751944AbdDMSti (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Apr 2017 14:49:38 -0400
Received: by mail-pg0-f53.google.com with SMTP id 21so34423161pgg.1
        for <netdev@vger.kernel.org>; Thu, 13 Apr 2017 11:49:38 -0700 (PDT)
In-Reply-To: <CAAeHK+xZG+V8W85=bzpj0EgbmZo0c2Sq6e0LxtHMZM8wje-yPA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 10, 2017 at 7:46 PM, Andrey Konovalov <andreyknvl@google.com> w=
rote:
> On Mon, Apr 10, 2017 at 7:42 PM, Cong Wang <xiyou.wangcong@gmail.com> wro=
te:
>> On Mon, Apr 10, 2017 at 7:40 AM, Andrey Konovalov <andreyknvl@google.com=
> wrote:
>>> Hi,
>>>
>>> I've got the following error report while fuzzing the kernel with syzka=
ller.
>>>
>>> On commit 39da7c509acff13fc8cb12ec1bb20337c988ed36 (4.11-rc6).
>>>
>>> Unfortunately it's not reproducible.
>>>
>>> BUG: KASAN: use-after-free in ip_select_ttl include/net/dst.h:176
>>> [inline] at addr ffff88006ab3602c
>>> BUG: KASAN: use-after-free in ip_queue_xmit+0x1817/0x1a30
>>> net/ipv4/ip_output.c:485 at addr ffff88006ab3602c
>>> Read of size 4 by task syz-executor1/12627
>>> CPU: 3 PID: 12627 Comm: syz-executor1 Not tainted 4.11.0-rc6+ #206
>>> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01=
/2011
>>> Call Trace:
>>>  __dump_stack lib/dump_stack.c:16 [inline]
>>>  dump_stack+0x292/0x398 lib/dump_stack.c:52
>>>  kasan_object_err+0x1c/0x70 mm/kasan/report.c:164
>>>  print_address_description mm/kasan/report.c:202 [inline]
>>>  kasan_report_error mm/kasan/report.c:291 [inline]
>>>  kasan_report+0x252/0x510 mm/kasan/report.c:347
>>>  __asan_report_load4_noabort+0x14/0x20 mm/kasan/report.c:367
>>>  ip_select_ttl include/net/dst.h:176 [inline]
>>
>> Probably same as the one you reported on ipv4_mtu(), it would
>> be nice if you could test the patch I proposed:
>>
>> https://patchwork.ozlabs.org/patch/747556/
>
> Applied your patch.

Oops, apparently your patch doesn't compile:

  CC      net/ipv4/route.o
net/ipv4/route.c: In function =E2=80=98ipv4_dst_destroy=E2=80=99:
net/ipv4/route.c:1394:8: error: =E2=80=98struct rtable=E2=80=99 has no memb=
er named =E2=80=98fi=E2=80=99
  if (rt->fi) {
        ^~
net/ipv4/route.c:1395:18: error: =E2=80=98struct rtable=E2=80=99 has no mem=
ber named =E2=80=98fi=E2=80=99
   fib_info_put(rt->fi);
                  ^~
net/ipv4/route.c:1396:5: error: =E2=80=98struct rtable=E2=80=99 has no memb=
er named =E2=80=98fi=E2=80=99
   rt->fi =3D NULL;
     ^~
net/ipv4/route.c: In function =E2=80=98rt_init_metrics=E2=80=99:
net/ipv4/route.c:1440:5: error: =E2=80=98struct rtable=E2=80=99 has no memb=
er named =E2=80=98fi=E2=80=99
   rt->fi =3D fi;
     ^~
net/ipv4/route.c: In function =E2=80=98rt_dst_alloc=E2=80=99:
net/ipv4/route.c:1512:5: error: =E2=80=98struct rtable=E2=80=99 has no memb=
er named =E2=80=98fi=E2=80=99
   rt->fi =3D NULL;
     ^~
make[2]: *** [net/ipv4/route.o] Error 1
make[1]: *** [net/ipv4] Error 2
make[1]: *** Waiting for unfinished jobs....
make: *** [net] Error 2


>
> The bug gets triggered very rarely (only twice so far), but I'll let
> you know if I see it again.
>
> Thanks!
>
>>
>>
>> Thanks!
>>
>>>  ip_queue_xmit+0x1817/0x1a30 net/ipv4/ip_output.c:485
>>>  sctp_v4_xmit+0x10d/0x140 net/sctp/protocol.c:994
>>>  sctp_packet_transmit+0x215c/0x3560 net/sctp/output.c:637
>>>  sctp_outq_flush+0xade/0x3f90 net/sctp/outqueue.c:885
>>>  sctp_outq_uncork+0x5a/0x70 net/sctp/outqueue.c:750
>>>  sctp_cmd_interpreter net/sctp/sm_sideeffect.c:1773 [inline]
>>>  sctp_side_effects net/sctp/sm_sideeffect.c:1175 [inline]
>>>  sctp_do_sm+0x5a0/0x6a50 net/sctp/sm_sideeffect.c:1147
>>>  sctp_primitive_ASSOCIATE+0x9d/0xd0 net/sctp/primitive.c:88
>>>  sctp_sendmsg+0x270d/0x3b50 net/sctp/socket.c:1954
>>>  inet_sendmsg+0x164/0x5b0 net/ipv4/af_inet.c:762
>>>  sock_sendmsg_nosec net/socket.c:633 [inline]
>>>  sock_sendmsg+0xca/0x110 net/socket.c:643
>>>  SYSC_sendto+0x660/0x810 net/socket.c:1696
>>>  SyS_sendto+0x40/0x50 net/socket.c:1664
>>>  entry_SYSCALL_64_fastpath+0x1f/0xc2
>>> RIP: 0033:0x4458d9
>>> RSP: 002b:00007fdceca85b58 EFLAGS: 00000282 ORIG_RAX: 000000000000002c
>>> RAX: ffffffffffffffda RBX: 0000000000000016 RCX: 00000000004458d9
>>> RDX: 0000000000000087 RSI: 0000000020003000 RDI: 0000000000000016
>>> RBP: 00000000006e2fe0 R08: 0000000020003000 R09: 0000000000000010
>>> R10: 0000000000040841 R11: 0000000000000282 R12: 00000000007080a8
>>> R13: 000000000000000a R14: 0000000000000005 R15: 0000000000000084
>>> Object at ffff88006ab36008, in cache kmalloc-64 size: 64
>>> Allocated:
>>> PID =3D 7243
>>>  save_stack_trace+0x16/0x20 arch/x86/kernel/stacktrace.c:59
>>>  save_stack+0x43/0xd0 mm/kasan/kasan.c:513
>>>  set_track mm/kasan/kasan.c:525 [inline]
>>>  kasan_kmalloc+0xad/0xe0 mm/kasan/kasan.c:616
>>>  kmem_cache_alloc_trace+0x82/0x270 mm/slub.c:2745
>>>  kmalloc include/linux/slab.h:490 [inline]
>>>  kzalloc include/linux/slab.h:663 [inline]
>>>  fib_create_info+0x8e0/0x3a30 net/ipv4/fib_semantics.c:1040
>>>  fib_table_insert+0x1a5/0x1550 net/ipv4/fib_trie.c:1221
>>>  ip_rt_ioctl+0xddc/0x1590 net/ipv4/fib_frontend.c:597
>>>  inet_ioctl+0xf2/0x1c0 net/ipv4/af_inet.c:882
>>>  sock_do_ioctl+0x65/0xb0 net/socket.c:906
>>>  sock_ioctl+0x28f/0x440 net/socket.c:1004
>>>  vfs_ioctl fs/ioctl.c:45 [inline]
>>>  do_vfs_ioctl+0x1bf/0x1780 fs/ioctl.c:685
>>>  SYSC_ioctl fs/ioctl.c:700 [inline]
>>>  SyS_ioctl+0x8f/0xc0 fs/ioctl.c:691
>>>  entry_SYSCALL_64_fastpath+0x1f/0xc2
>>> Freed:
>>> PID =3D 12622
>>>  save_stack_trace+0x16/0x20 arch/x86/kernel/stacktrace.c:59
>>>  save_stack+0x43/0xd0 mm/kasan/kasan.c:513
>>>  set_track mm/kasan/kasan.c:525 [inline]
>>>  kasan_slab_free+0x73/0xc0 mm/kasan/kasan.c:589
>>>  slab_free_hook mm/slub.c:1357 [inline]
>>>  slab_free_freelist_hook mm/slub.c:1379 [inline]
>>>  slab_free mm/slub.c:2961 [inline]
>>>  kfree+0xe8/0x2b0 mm/slub.c:3882
>>>  free_fib_info_rcu+0x4ba/0x5e0 net/ipv4/fib_semantics.c:218
>>>  __rcu_reclaim kernel/rcu/rcu.h:118 [inline]
>>>  rcu_do_batch.isra.64+0x947/0xcc0 kernel/rcu/tree.c:2879
>>>  invoke_rcu_callbacks kernel/rcu/tree.c:3142 [inline]
>>>  __rcu_process_callbacks kernel/rcu/tree.c:3109 [inline]
>>>  rcu_process_callbacks+0x2cc/0xb90 kernel/rcu/tree.c:3126
>>>  __do_softirq+0x2fb/0xb7d kernel/softirq.c:284
>>> Memory state around the buggy address:
>>>  ffff88006ab35f00: ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
>>>  ffff88006ab35f80: ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
>>>>ffff88006ab36000: fc fb fb fb fb fb fb fb fb fc fc fc fc fc fc fc
>>>                                   ^
>>>  ffff88006ab36080: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
>>>  ffff88006ab36100: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
>>> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>>
>> --
>> You received this message because you are subscribed to the Google Group=
s "syzkaller" group.
>> To unsubscribe from this group and stop receiving emails from it, send a=
n email to syzkaller+unsubscribe@googlegroups.com.
>> For more options, visit https://groups.google.com/d/optout.
