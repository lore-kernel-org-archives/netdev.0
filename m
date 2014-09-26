From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [RFC PATCH net-next] net: pktgen: packet bursting via skb->xmit_more
Date: Fri, 26 Sep 2014 08:59:21 -0700
Message-ID: <CAMEtUuxduBWxRggN8b9yxQPb-0zVkpM5HhRYGh1Bdp6nm7c2eQ@mail.gmail.com>
References: <1411692382-8898-1-git-send-email-ast@plumgrid.com>
	<1411694414.16953.70.camel@edumazet-glaptop2.roam.corp.google.com>
	<1411717322.16953.99.camel@edumazet-glaptop2.roam.corp.google.com>
	<1411746270.16953.130.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Eric Dumazet <edumazet@google.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Network Development <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f180.google.com ([209.85.217.180]:63495 "EHLO
	mail-lb0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754755AbaIZP7Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Sep 2014 11:59:24 -0400
Received: by mail-lb0-f180.google.com with SMTP id f15so1320674lbj.39
        for <netdev@vger.kernel.org>; Fri, 26 Sep 2014 08:59:22 -0700 (PDT)
In-Reply-To: <1411746270.16953.130.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 26, 2014 at 8:44 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Fri, 2014-09-26 at 00:42 -0700, Eric Dumazet wrote:
>> On Thu, 2014-09-25 at 18:20 -0700, Eric Dumazet wrote:
>> > On Thu, 2014-09-25 at 17:46 -0700, Alexei Starovoitov wrote:
>> > > This patch demonstrates the effect of delaying update of HW tailptr.
>> > > (based on earlier patch by Jesper)
>> > >
>> > > burst=1 is a default. It sends one packet with xmit_more=false
>> > > burst=2 sends one packet with xmit_more=true and
>> > >         2nd copy of the same packet with xmit_more=false
>> > > burst=3 sends two copies of the same packet with xmit_more=true and
>> > >         3rd copy with xmit_more=false
>> >
>> > >
>> > > Cc: Jesper Dangaard Brouer <brouer@redhat.com>
>> > > Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
>> > > ---
>> >
>> > Perfect, this is what I had in mind, thanks !
>> >
>> > Acked-by: Eric Dumazet <edumazet@google.com>
>> >
>>
>> By the way with this patch, I now reach 10 Mpps on mlx4
>
> On the other hand, bnx2x is not that happy
>
> [  381.424736] bnx2x: [bnx2x_start_xmit:3772(eth0)]BUG! Tx ring full
> when queue awake!
> [  381.432660] bnx2x: [bnx2x_start_xmit:3772(eth0)]BUG! Tx ring full
> when queue awake!
> [  381.440337] bnx2x: [bnx2x_start_xmit:3772(eth0)]BUG! Tx ring full
> when queue awake!
> [  381.448255] bnx2x: [bnx2x_start_xmit:3772(eth0)]BUG! Tx ring full
> when queue awake!
>
> When TX_BUSY is replied, and/or  netif_tx_stop_queue(txq) was done by
> the driver, the 'burst' loop should stop
>
> So your :
>
>         if (more)
>                 goto xmit_more;
>
> Should instead be :
>
>         if (more && !netif_xmit_frozen_or_drv_stopped(txq))
>                 goto xmit_more;
>

oh. thanks for testing! That makes sense.
I don't think I can find bnx2x around to double check this.
Do you mind applying this fix and resubmitting with two sob?
This one was rfc anyway :)
