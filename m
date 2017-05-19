From: Andrey Konovalov <andreyknvl@google.com>
Subject: Re: general protection fault in skb_release_data
Date: Fri, 19 May 2017 16:50:42 +0200
Message-ID: <CAAeHK+xGCjM8oDCZcNXbaZZNqenREi4DUgHM5=Ab7GKrVEmO4Q@mail.gmail.com>
References: <ebd31eba-3675-474a-a3ea-1d91cd31f2df@googlegroups.com>
 <CAAeHK+wet1o-F+-Q5jEh9DigDwouERjvrh1wQ1kFBxA5geGJpg@mail.gmail.com> <CANn89iJ4GJfrJvdzpMesGkUvYzJfUnMwbyPOzDxZdQDAJbkptg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: idaifish@gmail.com, "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        syzkaller <syzkaller@googlegroups.com>,
        Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>
To: Eric Dumazet <edumazet@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CANn89iJ4GJfrJvdzpMesGkUvYzJfUnMwbyPOzDxZdQDAJbkptg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, May 19, 2017 at 4:36 PM, 'Eric Dumazet' via syzkaller
<syzkaller@googlegroups.com> wrote:
> On Fri, May 19, 2017 at 5:57 AM, Andrey Konovalov <andreyknvl@google.com> wrote:
>> On Fri, May 19, 2017 at 12:18 PM,  <idaifish@gmail.com> wrote:
>>> Hi,
>>>
>>> I've got the following bug report while fuzzing the
>>> kernel(master-f83246089ca) with syzkaller.
>>>
>>> program and config are attached.
>>
>> Hi!
>>
>> Thanks for the report!
>>
>> Adding kernel maintainers.
>>
>> I can confirm that we've hist this bug multiple times, but never been
>> able to reproduce it.
>>
>> I was able to reproduce it on 2ea659a9ef488125eb46da6eb571de5eae5c43f6
>> (4.12-rc1).
>>
>> Using the attached syzkaller program I was able to generate C
>> reproducer, attached. Sometimes I need to run it a few times to
>> trigger the bug.
>>
>> @idaifish If you find more bugs please run ./scripts/get_maintainer.pl
>> to get the list of subsystem maintainers and add them to the
>> recipients. I've updated instructions of how to report kernel bugs
>> found with syzkaller in README.
>>
>> Thanks!
>>
>>>
>>> =======================================================
>>> kasan: GPF could be caused by NULL-ptr deref or user memory access
>>> general protection fault: 0000 [#1] SMP KASAN
>>> Dumping ftrace buffer:
>>>    (ftrace buffer empty)
>>> Modules linked in:
>>> CPU: 2 PID: 21599 Comm: syz-executor3 Not tainted 4.11.0-rc8+ #1
>>> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS
>>> Ubuntu-1.8.2-1ubuntu1 04/01/2014
>>> task: ffff88006c16dec0 task.stack: ffff880058bb8000
>>> RIP: 0010:__read_once_size include/linux/compiler.h:254 [inline]
>>> RIP: 0010:compound_head include/linux/page-flags.h:146 [inline]
>>> RIP: 0010:put_page include/linux/mm.h:796 [inline]
>>> RIP: 0010:__skb_frag_unref include/linux/skbuff.h:2613 [inline]
>>> RIP: 0010:skb_release_data+0x201/0x3b0 net/core/skbuff.c:593
>>> RSP: 0018:ffff880058bbf570 EFLAGS: 00010a02
>>> RAX: 11032b488bad1523 RBX: ffff88006c6e8ec8 RCX: ffffc9000190e000
>>> RDX: 1ffff1000d8dd1df RSI: ffffffff8293d7e3 RDI: 88195a445d68a919
>>> RBP: ffff880058bbf5a8 R08: 7bdf27567b31597f R09: 0000000000000000
>>> R10: 00000000000000d2 R11: 7dc9ab6dec891f24 R12: 0000000000000000
>>> R13: dffffc0000000000 R14: ffff88006a475940 R15: 88195a445d68a8f9
>>> FS:  00007fbbc6a34700(0000) GS:ffff88006e400000(0000) knlGS:0000000000000000
>>> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
>>> CR2: 000000002004e000 CR3: 000000006b868000 CR4: 00000000000006e0
>>> Call Trace:
>>>  skb_release_all+0x4a/0x60 net/core/skbuff.c:669
>>>  __kfree_skb net/core/skbuff.c:683 [inline]
>>>  kfree_skb+0x85/0x1b0 net/core/skbuff.c:704
>>>  __ip6_append_data.isra.42+0x26ed/0x33b0 net/ipv6/ip6_output.c:1519
>>>  ip6_append_data+0x1a8/0x2f0 net/ipv6/ip6_output.c:1633
>>>  udpv6_sendmsg+0x7bd/0x2360 net/ipv6/udp.c:1264
>>>  inet_sendmsg+0x123/0x3a0 net/ipv4/af_inet.c:762
>>>  sock_sendmsg_nosec net/socket.c:633 [inline]
>>>  sock_sendmsg+0xca/0x110 net/socket.c:643
>>>  ___sys_sendmsg+0x79f/0x900 net/socket.c:1997
>>>  __sys_sendmsg+0xd1/0x170 net/socket.c:2031
>>>  SYSC_sendmsg net/socket.c:2042 [inline]
>>>  SyS_sendmsg+0x2d/0x50 net/socket.c:2038
>>>  entry_SYSCALL_64_fastpath+0x1a/0xa9
>>> RIP: 0033:0x44fb79
>>> RSP: 002b:00007fbbc6a33b58 EFLAGS: 00000212 ORIG_RAX: 000000000000002e
>>> RAX: ffffffffffffffda RBX: 0000000000718000 RCX: 000000000044fb79
>>> RDX: 0000000000000000 RSI: 000000002000afc8 RDI: 0000000000000005
>>> RBP: 00000000000003fb R08: 0000000000000000 R09: 0000000000000000
>>> R10: 0000000000000000 R11: 0000000000000212 R12: 0000000000000005
>>> R13: 0000000020001000 R14: 0000000000048000 R15: 0000000000000000
>>> Code: 48 83 c0 03 48 c1 e0 04 48 01 d8 48 89 c2 48 c1 ea 03 42 80 3c 2a 00
>>> 0f 85 92 01 00 00 4c 8b 38 49 8d 7f 20 48 89 f8 48 c1 e8 03 <42> 80 3c 28 00
>>> 0f 85 6f 01 00 00 49 8b 47 20 a8 01 0f 84 3b ff
>>> RIP: __read_once_size include/linux/compiler.h:254 [inline] RSP:
>>> ffff880058bbf570
>>> RIP: compound_head include/linux/page-flags.h:146 [inline] RSP:
>>> ffff880058bbf570
>>> RIP: put_page include/linux/mm.h:796 [inline] RSP: ffff880058bbf570
>>> RIP: __skb_frag_unref include/linux/skbuff.h:2613 [inline] RSP:
>>> ffff880058bbf570
>>> RIP: skb_release_data+0x201/0x3b0 net/core/skbuff.c:593 RSP:
>>> ffff880058bbf570
>>> ---[ end trace 46c9f72a66cd8627 ]---
>>> Kernel panic - not syncing: Fatal exception
>>> Dumping ftrace buffer:
>>>    (ftrace buffer empty)
>>> Kernel Offset: disabled
>>> Rebooting in 86400 seconds..
>>>
>>> --
>>> You received this message because you are subscribed to the Google Groups
>>> "syzkaller" group.
>>> To unsubscribe from this group and stop receiving emails from it, send an
>>> email to syzkaller+unsubscribe@googlegroups.com.
>>> For more options, visit https://groups.google.com/d/optout.
>
> Hi Andrey, please try following patch
> Thanks.

Hi Eric,

Your patch fixes the bug for me.

Thanks!

Tested-by: Andrey Konovalov <andreyknvl@google.com>

>
> --
> You received this message because you are subscribed to the Google Groups "syzkaller" group.
> To unsubscribe from this group and stop receiving emails from it, send an email to syzkaller+unsubscribe@googlegroups.com.
> For more options, visit https://groups.google.com/d/optout.
