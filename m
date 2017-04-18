From: Andrey Konovalov <andreyknvl@google.com>
Subject: Re: net/ipv4: use-after-free in ip_queue_xmit
Date: Tue, 18 Apr 2017 14:15:27 +0200
Message-ID: <CAAeHK+wYLwZqGWjBNbw6mbvTiHCeXC91dYmMY410YwprU8OG1w@mail.gmail.com>
References: <CAAeHK+z5=b4PdSrq8ff-btYbd-aKFR+uzQnoC5Pq4du4uVQjzQ@mail.gmail.com>
 <CAM_iQpWsEpJYHG1WvC9kQPt8iezBuLC8PeSqM20=W9cpkRE6=Q@mail.gmail.com>
 <CAAeHK+xZG+V8W85=bzpj0EgbmZo0c2Sq6e0LxtHMZM8wje-yPA@mail.gmail.com>
 <CAAeHK+wV1aKoP_2cog-dp0-17g4QimfK5j8P3oxypE3mCxMGUw@mail.gmail.com> <CAM_iQpU_frn6bB6HHrRrF6omKDoXjxZmSoJZSu=PjZ35pUVOuA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
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
Received: from mail-pf0-f181.google.com ([209.85.192.181]:34911 "EHLO
        mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755050AbdDRMPb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Apr 2017 08:15:31 -0400
Received: by mail-pf0-f181.google.com with SMTP id i5so80148566pfc.2
        for <netdev@vger.kernel.org>; Tue, 18 Apr 2017 05:15:30 -0700 (PDT)
In-Reply-To: <CAM_iQpU_frn6bB6HHrRrF6omKDoXjxZmSoJZSu=PjZ35pUVOuA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 13, 2017 at 9:59 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> On Thu, Apr 13, 2017 at 11:49 AM, Andrey Konovalov
> <andreyknvl@google.com> wrote:
>> On Mon, Apr 10, 2017 at 7:46 PM, Andrey Konovalov <andreyknvl@google.com> wrote:
>>> On Mon, Apr 10, 2017 at 7:42 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
>>>> On Mon, Apr 10, 2017 at 7:40 AM, Andrey Konovalov <andreyknvl@google.com> wrote:
>>>>> Hi,
>>>>>
>>>>> I've got the following error report while fuzzing the kernel with syzkaller.
>>>>>
>>>>> On commit 39da7c509acff13fc8cb12ec1bb20337c988ed36 (4.11-rc6).
>>>>>
>>>>> Unfortunately it's not reproducible.
>>>>>
>>>>> BUG: KASAN: use-after-free in ip_select_ttl include/net/dst.h:176
>>>>> [inline] at addr ffff88006ab3602c
>>>>> BUG: KASAN: use-after-free in ip_queue_xmit+0x1817/0x1a30
>>>>> net/ipv4/ip_output.c:485 at addr ffff88006ab3602c
>>>>> Read of size 4 by task syz-executor1/12627
>>>>> CPU: 3 PID: 12627 Comm: syz-executor1 Not tainted 4.11.0-rc6+ #206
>>>>> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
>>>>> Call Trace:
>>>>>  __dump_stack lib/dump_stack.c:16 [inline]
>>>>>  dump_stack+0x292/0x398 lib/dump_stack.c:52
>>>>>  kasan_object_err+0x1c/0x70 mm/kasan/report.c:164
>>>>>  print_address_description mm/kasan/report.c:202 [inline]
>>>>>  kasan_report_error mm/kasan/report.c:291 [inline]
>>>>>  kasan_report+0x252/0x510 mm/kasan/report.c:347
>>>>>  __asan_report_load4_noabort+0x14/0x20 mm/kasan/report.c:367
>>>>>  ip_select_ttl include/net/dst.h:176 [inline]
>>>>
>>>> Probably same as the one you reported on ipv4_mtu(), it would
>>>> be nice if you could test the patch I proposed:
>>>>
>>>> https://patchwork.ozlabs.org/patch/747556/
>>>
>>> Applied your patch.
>>
>> Oops, apparently your patch doesn't compile:
>>
>
> Weird, it compiles fine here. Either you have a different config
> or the following piece is missing for some reason?
>
> @@ -69,6 +69,7 @@  struct rtable {
>
>   struct list_head rt_uncached;
>   struct uncached_list *rt_uncached_list;
> + struct fib_info *fi; /* for refcnt to shared metrics */
>  };

Yes, I don't have this field in the rtable struct.

I'm on 39da7c509acff13fc8cb12ec1bb20337c988ed36 (4.11-rc6).

I also don't see it in the cross reference:
http://lxr.free-electrons.com/source/include/net/route.h#L51

>
> --
> You received this message because you are subscribed to the Google Groups "syzkaller" group.
> To unsubscribe from this group and stop receiving emails from it, send an email to syzkaller+unsubscribe@googlegroups.com.
> For more options, visit https://groups.google.com/d/optout.
