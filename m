From: Michael Ma <make0818@gmail.com>
Subject: Re: Corrupted SKB
Date: Tue, 18 Apr 2017 21:46:26 -0700
Message-ID: <CAAmHdhy0N2VttXNXL+S+4G=4=mf4ihpW7KsNWUYpiOFXez3B7w@mail.gmail.com>
References: <CAAmHdhx14ZH3ftE2SovFZfy8ZfOCEgsyqqcSbGPHqg87Wc+5SQ@mail.gmail.com>
 <CAM_iQpVOi0FH_quusHHpvREdvpqq6=RjVOQvcjAWGbh1X0_5tA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        jin.oyj@alibaba-inc.com
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f49.google.com ([209.85.218.49]:34934 "EHLO
        mail-oi0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752024AbdDSEq2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Apr 2017 00:46:28 -0400
Received: by mail-oi0-f49.google.com with SMTP id j201so14952073oih.2
        for <netdev@vger.kernel.org>; Tue, 18 Apr 2017 21:46:27 -0700 (PDT)
In-Reply-To: <CAM_iQpVOi0FH_quusHHpvREdvpqq6=RjVOQvcjAWGbh1X0_5tA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2017-04-18 16:12 GMT-07:00 Cong Wang <xiyou.wangcong@gmail.com>:
> On Mon, Apr 17, 2017 at 5:39 PM, Michael Ma <make0818@gmail.com> wrote:
>> Hi -
>>
>> We've implemented a "glue" qdisc similar to mqprio which can associate
>> one qdisc to multiple txqs as the root qdisc. Reference count of the
>> child qdiscs have been adjusted properly in this case so that it
>> represents the number of txqs it has been attached to. However when
>> sending packets we saw the skb from dequeue_skb() corrupted with the
>> following call stack:
>>
>>     [exception RIP: netif_skb_features+51]
>>     RIP: ffffffff815292b3  RSP: ffff8817f6987940  RFLAGS: 00010246
>>
>>  #9 [ffff8817f6987968] validate_xmit_skb at ffffffff815294aa
>> #10 [ffff8817f69879a0] validate_xmit_skb at ffffffff8152a0d9
>> #11 [ffff8817f69879b0] __qdisc_run at ffffffff8154a193
>> #12 [ffff8817f6987a00] dev_queue_xmit at ffffffff81529e03
>>
>> It looks like the skb has already been released since its dev pointer
>> field is invalid.
>>
>> Any clue on how this can be investigated further? My current thought
>> is to add some instrumentation to the place where skb is released and
>> analyze whether there is any race condition happening there. However
>
> Either dropwatch or perf could do the work to instrument kfree_skb().

Thanks - will try it out.
>
>> by looking through the existing code I think the case where one root
>> qdisc is associated with multiple txqs already exists (when mqprio is
>> not used) so not sure why it won't work when we group txqs and assign
>> each group a root qdisc. Any insight on this issue would be much
>> appreciated!
>
> How do you implement ->attach()? How does it work with netdev_pick_tx()?

attach() essentially grafts the default qdisc(pfifo) to each "txq
group" represented by a TC class. For netdev_pick_txq() we use classid
of the socket to select a class based on a "class id base" and the
class to txq mapping defined together with this glue qdisc - it's
pretty much the same as mqprio with the difference of mapping one
class to multiple txqs and selecting the txq through a hash.
