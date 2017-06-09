From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net] Fix an intermittent pr_emerg warning about lo
 becoming free.
Date: Fri, 9 Jun 2017 11:18:44 -0700
Message-ID: <CAM_iQpUaenZa0o-eyt91sAE6SF+qk6Thh5vpKqPLXSc6xpjPqg@mail.gmail.com>
References: <20170608201238.GC2553@templeofstupid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: David Miller <davem@davemloft.net>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Kaiwen Xu <kaiwen.xu@hulu.com>
To: Krister Johansen <kjlx@templeofstupid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f181.google.com ([209.85.128.181]:33726 "EHLO
        mail-wr0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751735AbdFISTG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Jun 2017 14:19:06 -0400
Received: by mail-wr0-f181.google.com with SMTP id v104so41133859wrb.0
        for <netdev@vger.kernel.org>; Fri, 09 Jun 2017 11:19:05 -0700 (PDT)
In-Reply-To: <20170608201238.GC2553@templeofstupid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 8, 2017 at 1:12 PM, Krister Johansen
<kjlx@templeofstupid.com> wrote:
> After looking through the list of callbacks that the netdevice notifiers
> invoke in this path, it appears that the dst_dev_event is the most
> interesting.  The dst_ifdown path places a hold on the loopback_dev as
> part of releasing the dev associated with the original dst cache entry.
> Most of our notifier callbacks are straight-forward, but this one a)
> looks complex, and b) places a hold on the network interface in
> question.
>
> I constructed a new bcc script that watches various events in the
> liftime of a dst cache entry.  Note that dst_ifdown will take a hold on
> the loopback device until the invalidated dst entry gets freed.
>

Yeah, this is what I observed when Kevin (Cc'ed) reported a similar
(if not same) bug, I thought we have a refcnt leak on dst.

...
> The way this works is that if there's still a reference on the dst entry
> at the time we try to free it, it gets placed in the gc list by
> __dst_free and the dst_destroy() call is invoked by the gc task once the
> refcount is 0.  If the gc task processes a 10th or less of its entries
> on a single pass, it inreases the amount of time it waits between gc
> intervals.
>
> Looking at the gc_task intervals, they started at 663ms when we invoked
> __dst_free().  After that, they increased to 1663, 3136, 5567, 8191,
> 10751, and 14848.  The release that set the refcnt to 0 on our dst entry
> occurred after the gc_task was enqueued for 14 second interval so we had
> to wait longer than the warning time in wait_allrefs in order for the
> dst entry to get free'd and the hold on 'lo' to be released.
>

I am glad to see you don't have a dst leak here.

But from my experience of a similar bug (refcnt wait on lo), this goes
infinitely rather than just 14sec, so it looked more like a real leak than
just a gc delay. So in your case, this annoying warning eventually
disappears, right?


Thanks.
