From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH 0/3] Basic deferred TX queue flushing infrastructure.
Date: Sun, 24 Aug 2014 10:57:32 -0400
Message-ID: <53F9FD5C.2090408@mojatatu.com>
References: <20140823.132811.751469424156827125.davem@davemloft.net> <20140823.213839.1953243016141233125.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: therbert@google.com, hannes@stressinduktion.org,
	edumazet@google.com, jeffrey.t.kirsher@intel.com,
	rusty@rustcorp.com.au
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:52203 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753093AbaHXO5k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Aug 2014 10:57:40 -0400
Received: by mail-pa0-f50.google.com with SMTP id et14so19049275pad.37
        for <netdev@vger.kernel.org>; Sun, 24 Aug 2014 07:57:40 -0700 (PDT)
In-Reply-To: <20140823.213839.1953243016141233125.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/24/14 00:38, David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Sat, 23 Aug 2014 13:28:11 -0700 (PDT)
>
>> This just adds the infrastructure, it does not actually add any
>> instances of actually doing multiple ndo_start_xmit calls per
>> ndo_xmit_flush invocation.
>
> So today I was looking more into this aspect.
>
> Like Tom Herbert has mentioned we have all the infrastructure (sort
> of) already to handle a list of SKBs going down into
> dev_hard_start_xmit() via the GSO handling.
>
> But that code is funny, because it keeps the original GSO head SKB
> around as a placeholder to maintain the list of segmented SKBs.
>
> So the list walker basically walks starting at skb->next.  That's
> awkward for what we want to do, which is pass in an arbitrary list of
> SKBs.
>
> All it really wants that head SKB for is essentially list management,
> which seems like overkill to me.
>
> Anyways, this got me thinking that we should have something that
> provides the segment list management and stop keeping that head GSO
> SKB around.
>
> Then we can make that "gso:" label list walker generic enough that we
> could pass down arbitrary lists of SKBs from the qdisc_restart() path.
>
> This list management seems to be the only reason why we keep the GSO
> head SKB around after dev_gso_segment(), we should be able to free it
> up early without any problems right?
>
> I'm also thinking about whether we should hang the generic SKB list
> management off of the txq or the qdisc.  Right now the gso_skb thing
> is in the qdisc.
>
> Thoughts?

I think leave it where it is (it messes with accounting otherwise)
and eventually you kill it when you have the batch interface right.

Clearly, the best thing to do is avoid altogether the need to have such
a list. The only reason you need a list around is because you dont know
how much you can send to the driver. tx_win idea may not be the best
but it tried to address that issue.

cheers,
jamal
