From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH 0/3] Basic deferred TX queue flushing infrastructure.
Date: Mon, 25 Aug 2014 15:21:00 -0700
Message-ID: <CAHA+R7O_RSyKVNqcHXePbahvU+ayf77w61jos=G38M93okVWKw@mail.gmail.com>
References: <20140823.132811.751469424156827125.davem@davemloft.net>
	<20140823.213839.1953243016141233125.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, Tom Herbert <therbert@google.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Eric Dumazet <edumazet@google.com>,
	jeffrey.t.kirsher@intel.com, rusty@rustcorp.com.au
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f176.google.com ([209.85.217.176]:63464 "EHLO
	mail-lb0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751780AbaHYWVB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Aug 2014 18:21:01 -0400
Received: by mail-lb0-f176.google.com with SMTP id c11so392791lbj.21
        for <netdev@vger.kernel.org>; Mon, 25 Aug 2014 15:21:00 -0700 (PDT)
In-Reply-To: <20140823.213839.1953243016141233125.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Aug 23, 2014 at 9:38 PM, David Miller <davem@davemloft.net> wrote:
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


When I tried to unify the list management of SKB's, I was surprised to see
there are still some places relying on skb->next and skb->prev to be
the head of the skb struct, since nowadays we have list API's, they still
play some magic on these pointers (sctp and tipc IIRC). This is why I
gave up, maybe it's time to revise this again.

Talking about skb->next, fortunately we do gso segmentation after
going out of qdisc queues, otherwise it's scary to play with these
pointers at same time. I think all queues of SKB's are either using
just ->next or both ->prev and ->next.

Just my two cents.
