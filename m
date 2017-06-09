From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net] Fix an intermittent pr_emerg warning about lo
 becoming free.
Date: Fri, 9 Jun 2017 14:48:49 -0700
Message-ID: <CAM_iQpXHUjxTF6=heY9psJb5pFfm4tRz9KiLOB87CbwEA1K=3A@mail.gmail.com>
References: <20170608201238.GC2553@templeofstupid.com> <CAM_iQpUaenZa0o-eyt91sAE6SF+qk6Thh5vpKqPLXSc6xpjPqg@mail.gmail.com>
 <20170609184303.GC2766@templeofstupid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: David Miller <davem@davemloft.net>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Kaiwen Xu <kaiwen.xu@hulu.com>
To: Krister Johansen <kjlx@templeofstupid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f174.google.com ([209.85.128.174]:34821 "EHLO
        mail-wr0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751545AbdFIVtL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Jun 2017 17:49:11 -0400
Received: by mail-wr0-f174.google.com with SMTP id q97so45522117wrb.2
        for <netdev@vger.kernel.org>; Fri, 09 Jun 2017 14:49:10 -0700 (PDT)
In-Reply-To: <20170609184303.GC2766@templeofstupid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 9, 2017 at 11:43 AM, Krister Johansen
<kjlx@templeofstupid.com> wrote:
> On Fri, Jun 09, 2017 at 11:18:44AM -0700, Cong Wang wrote:
>> On Thu, Jun 8, 2017 at 1:12 PM, Krister Johansen
>> <kjlx@templeofstupid.com> wrote:
>> > The way this works is that if there's still a reference on the dst entry
>> > at the time we try to free it, it gets placed in the gc list by
>> > __dst_free and the dst_destroy() call is invoked by the gc task once the
>> > refcount is 0.  If the gc task processes a 10th or less of its entries
>> > on a single pass, it inreases the amount of time it waits between gc
>> > intervals.
>> >
>> > Looking at the gc_task intervals, they started at 663ms when we invoked
>> > __dst_free().  After that, they increased to 1663, 3136, 5567, 8191,
>> > 10751, and 14848.  The release that set the refcnt to 0 on our dst entry
>> > occurred after the gc_task was enqueued for 14 second interval so we had
>> > to wait longer than the warning time in wait_allrefs in order for the
>> > dst entry to get free'd and the hold on 'lo' to be released.
>> >
>>
>> I am glad to see you don't have a dst leak here.
>>
>> But from my experience of a similar bug (refcnt wait on lo), this goes
>> infinitely rather than just 14sec, so it looked more like a real leak than
>> just a gc delay. So in your case, this annoying warning eventually
>> disappears, right?
>
> That's correct.  The problem occurs intermittently, and the warnings are
> less frequent than the interval in netdev_wait_allrefs().  At least when
> I observed it, it tended to conincide with our controlplane canary
> issuing an API call that lead to a network namespace teardown on the
> dataplane.

Great! Then the bug I saw is different from this one and it is probably
a dst leak.

Thanks.
