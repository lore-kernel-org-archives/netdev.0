From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: netconsole refcount warning
Date: Wed, 12 Jul 2017 15:35:51 -0700
Message-ID: <CAM_iQpWJ3O4Pa58L7pZxL5bt6ujaFiud-=z0h1WV+qPxpYBFxg@mail.gmail.com>
References: <20170709235757.43bjgxjbimwqx6yk@codemonkey.org.uk> <CAM_iQpXZPW+nMha=GQm8rnf_W-LZqq7jc_cBX6P5azNpF1ToWQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Dave Jones <davej@codemonkey.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:36309 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752801AbdGLWgN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Jul 2017 18:36:13 -0400
Received: by mail-wm0-f66.google.com with SMTP id y5so1612724wmh.3
        for <netdev@vger.kernel.org>; Wed, 12 Jul 2017 15:36:12 -0700 (PDT)
In-Reply-To: <CAM_iQpXZPW+nMha=GQm8rnf_W-LZqq7jc_cBX6P5azNpF1ToWQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 12, 2017 at 3:30 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> On Sun, Jul 9, 2017 at 4:57 PM, Dave Jones <davej@codemonkey.org.uk> wrote:
>> The new refcount debugging code spews this twice during boot on my router..
>>
>>
>> refcount_t: increment on 0; use-after-free.
>> ------------[ cut here ]------------
>> WARNING: CPU: 1 PID: 17 at lib/refcount.c:152 refcount_inc+0x2b/0x30
>> CPU: 1 PID: 17 Comm: ksoftirqd/1 Not tainted 4.12.0-firewall+ #8
>> task: ffff8801d4441ac0 task.stack: ffff8801d4450000
>> RIP: 0010:refcount_inc+0x2b/0x30
>> RSP: 0018:ffff8801d4456da8 EFLAGS: 00010046
>> RAX: 000000000000002c RBX: ffff8801d4c3cf40 RCX: 0000000000000000
>> RDX: 000000000000002c RSI: 0000000000000003 RDI: ffffed003a88adab
>> RBP: ffff8801d4456da8 R08: 0000000000000003 R09: fffffbfff4afcb57
>> R10: 0000000000000000 R11: fffffbfff4afcb58 R12: ffff8801d4c3c540
>> R13: 0000000000000082 R14: ffff8801ce9c7ff8 R15: ffff8801ce9c8aa0
>> FS:  0000000000000000(0000) GS:ffff8801d6a00000(0000) knlGS:0000000000000000
>> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
>> CR2: 00007fa2b803156e CR3: 00000001c405d000 CR4: 00000000000406e0
>> Call Trace:
>>  zap_completion_queue+0xad/0x1a0
>
>
> Sigh... it is on purpose:
>
> commit 8a455b087c9629b3ae3b521b4f1ed16672f978cc
> Author: Jarek Poplawski <jarkao2@gmail.com>
> Date:   Thu Mar 20 16:07:27 2008 -0700
>
>     netpoll: zap_completion_queue: adjust skb->users counter
>
>     zap_completion_queue() retrieves skbs from completion_queue where they have
>     zero skb->users counter.  Before dev_kfree_skb_any() it should be non-zero
>     yet, so it's increased now.
>
>     Reported-and-tested-by: Andrew Morton <akpm@linux-foundation.org>
>     Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
>     Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
>     Signed-off-by: David S. Miller <davem@davemloft.net>
>
> We need to review it now. :-/

I think we should explicitly set it to 1 with refcount_set() since
we know it was 0 for sure.

diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index d3408a6..8357f16 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -277,7 +277,7 @@ static void zap_completion_queue(void)
                        struct sk_buff *skb = clist;
                        clist = clist->next;
                        if (!skb_irq_freeable(skb)) {
-                               refcount_inc(&skb->users);
+                               refcount_set(&skb->users, 1);
                                dev_kfree_skb_any(skb); /* put this one back */
                        } else {
                                __kfree_skb(skb);
