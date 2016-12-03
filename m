From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: net: use-after-free in worker_thread
Date: Sat, 3 Dec 2016 09:41:45 -0800
Message-ID: <CAM_iQpUSSc6xvAd3u5C3d=xk_yL4LUBgui7pgK5AHxJ8LP363A@mail.gmail.com>
References: <CAAeHK+x95-n__YSbzebp51ez78yjqjK4CJL=tgOgPuBuGh+q1A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
        Johannes Berg <johannes.berg@intel.com>,
        Florian Westphal <fw@strlen.de>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        Eric Dumazet <edumazet@google.com>,
        Bob Copeland <me@bobcopeland.com>,
        Tom Herbert <tom@herbertland.com>,
        David Decotigny <decot@googlers.com>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>
To: Andrey Konovalov <andreyknvl@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:33712 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750919AbcLCRmf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 3 Dec 2016 12:42:35 -0500
In-Reply-To: <CAAeHK+x95-n__YSbzebp51ez78yjqjK4CJL=tgOgPuBuGh+q1A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Dec 3, 2016 at 4:56 AM, Andrey Konovalov <andreyknvl@google.com> wrote:
> Hi!
>
> I'm seeing lots of the following error reports while running the
> syzkaller fuzzer.
>
> Reports appeared when I updated to 3c49de52 (Dec 2) from 2caceb32 (Dec 1).
>
> ==================================================================
> BUG: KASAN: use-after-free in worker_thread+0x17d8/0x18a0
> Read of size 8 at addr ffff880067f3ecd8 by task kworker/3:1/774
>
> page:ffffea00019fce00 count:1 mapcount:0 mapping:          (null)
> index:0xffff880067f39c10 compound_mapcount: 0
> flags: 0x500000000004080(slab|head)
> page dumped because: kasan: bad access detected
>
> CPU: 3 PID: 774 Comm: kworker/3:1 Not tainted 4.9.0-rc7+ #66
> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
>  ffff88006c267838 ffffffff81f882da ffffffff6c25e338 1ffff1000d84ce9a
>  ffffed000d84ce92 ffff88006c25e340 0000000041b58ab3 ffffffff8541e198
>  ffffffff81f88048 0000000100000000 0000000041b58ab3 ffffffff853d3ee8
> Call Trace:
>  [<     inline     >] __dump_stack lib/dump_stack.c:15
>  [<ffffffff81f882da>] dump_stack+0x292/0x398 lib/dump_stack.c:51
>  [<     inline     >] describe_address mm/kasan/report.c:262
>  [<ffffffff817e50d1>] kasan_report_error+0x121/0x560 mm/kasan/report.c:368
>  [<     inline     >] kasan_report mm/kasan/report.c:390
>  [<ffffffff817e560e>] __asan_report_load8_noabort+0x3e/0x40
> mm/kasan/report.c:411
>  [<ffffffff81329b88>] worker_thread+0x17d8/0x18a0 kernel/workqueue.c:2228
>  [<ffffffff8133ebf3>] kthread+0x323/0x3e0 kernel/kthread.c:209
>  [<ffffffff84a2a22a>] ret_from_fork+0x2a/0x40 arch/x86/entry/entry_64.S:433

Heck... this is the pending work vs. sk_destruct() race. :-/
We can't wait for the work in RCU callback, let me think about it...
