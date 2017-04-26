From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: Corrupted SKB
Date: Wed, 26 Apr 2017 10:38:23 -0700
Message-ID: <CAM_iQpWw-z7Nt4fUDKpqysPuPmdRLWk9RjHe_zArEe6z4Sodiw@mail.gmail.com>
References: <CAAmHdhx14ZH3ftE2SovFZfy8ZfOCEgsyqqcSbGPHqg87Wc+5SQ@mail.gmail.com>
 <CAM_iQpVOi0FH_quusHHpvREdvpqq6=RjVOQvcjAWGbh1X0_5tA@mail.gmail.com>
 <CAAmHdhy0N2VttXNXL+S+4G=4=mf4ihpW7KsNWUYpiOFXez3B7w@mail.gmail.com> <CAAmHdhwncVcbeKN+K4EnmWqwBRXPwuMOSFwtOfuwmgc6gw-5=g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        jin.oyj@alibaba-inc.com
To: Michael Ma <make0818@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f52.google.com ([74.125.82.52]:38412 "EHLO
        mail-wm0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752585AbdDZRip (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Apr 2017 13:38:45 -0400
Received: by mail-wm0-f52.google.com with SMTP id r190so11848618wme.1
        for <netdev@vger.kernel.org>; Wed, 26 Apr 2017 10:38:45 -0700 (PDT)
In-Reply-To: <CAAmHdhwncVcbeKN+K4EnmWqwBRXPwuMOSFwtOfuwmgc6gw-5=g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 25, 2017 at 9:42 PM, Michael Ma <make0818@gmail.com> wrote:
> 2017-04-18 21:46 GMT-07:00 Michael Ma <make0818@gmail.com>:
>> 2017-04-18 16:12 GMT-07:00 Cong Wang <xiyou.wangcong@gmail.com>:
>>> On Mon, Apr 17, 2017 at 5:39 PM, Michael Ma <make0818@gmail.com> wrote:
>>>> Hi -
>>>>
>>>> We've implemented a "glue" qdisc similar to mqprio which can associate
>>>> one qdisc to multiple txqs as the root qdisc. Reference count of the
>>>> child qdiscs have been adjusted properly in this case so that it
>>>> represents the number of txqs it has been attached to. However when
>>>> sending packets we saw the skb from dequeue_skb() corrupted with the
>>>> following call stack:
>>>>
>>>>     [exception RIP: netif_skb_features+51]
>>>>     RIP: ffffffff815292b3  RSP: ffff8817f6987940  RFLAGS: 00010246
>>>>
>>>>  #9 [ffff8817f6987968] validate_xmit_skb at ffffffff815294aa
>>>> #10 [ffff8817f69879a0] validate_xmit_skb at ffffffff8152a0d9
>>>> #11 [ffff8817f69879b0] __qdisc_run at ffffffff8154a193
>>>> #12 [ffff8817f6987a00] dev_queue_xmit at ffffffff81529e03
>>>>
>>>> It looks like the skb has already been released since its dev pointer
>>>> field is invalid.
>>>>
>>>> Any clue on how this can be investigated further? My current thought
>>>> is to add some instrumentation to the place where skb is released and
>>>> analyze whether there is any race condition happening there. However
>>>
>>> Either dropwatch or perf could do the work to instrument kfree_skb().
>>
>> Thanks - will try it out.
>
> I'm using perf to collect the callstack for kfree_skb and trying to
> correlate that with the corrupted SKB address however when system
> crashes the perf.data file is also corrupted - how can I view this
> file in case the system crashes before perf exits?

Hmm, KASAN is pretty good at detecting use-after-free,
its report can nicely shows where we allocate/free it and the
use after free.

https://01.org/linuxgraphics/gfx-docs/drm/dev-tools/kasan.html
