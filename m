From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [iovisor-dev] README: [PATCH RFC 11/11] net/mlx5e: XDP TX xmit more
Date: Fri, 9 Sep 2016 18:03:09 +0300
Message-ID: <CALzJLG_r0pDJgxqqak5=NatT8tF7UP2NkGS1wjeWcS5C=Zvv2A@mail.gmail.com>
References: <1473252152-11379-1-git-send-email-saeedm@mellanox.com>
 <1473252152-11379-12-git-send-email-saeedm@mellanox.com> <20160908101147.1b351432@redhat.com>
 <20160909032202.GA62966@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
        Tom Herbert <tom@herbertland.com>,
        iovisor-dev <iovisor-dev@lists.iovisor.org>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Eric Dumazet <edumazet@google.com>,
        Linux Netdev List <netdev@vger.kernel.org>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f67.google.com ([209.85.215.67]:36637 "EHLO
        mail-lf0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750760AbcIIPDc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Sep 2016 11:03:32 -0400
Received: by mail-lf0-f67.google.com with SMTP id s29so2818814lfg.3
        for <netdev@vger.kernel.org>; Fri, 09 Sep 2016 08:03:31 -0700 (PDT)
In-Reply-To: <20160909032202.GA62966@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 9, 2016 at 6:22 AM, Alexei Starovoitov via iovisor-dev
<iovisor-dev@lists.iovisor.org> wrote:
> On Thu, Sep 08, 2016 at 10:11:47AM +0200, Jesper Dangaard Brouer wrote:
>>
>> I'm sorry but I have a problem with this patch!
>
> is it because the variable is called 'xdp_doorbell'?
> Frankly I see nothing scary in this patch.
> It extends existing code by adding a flag to ring doorbell or not.
> The end of rx napi is used as an obvious heuristic to flush the pipe.
> Looks pretty generic to me.
> The same code can be used for non-xdp as well once we figure out
> good algorithm for xmit_more in the stack.
>
>> Looking at this patch, I want to bring up a fundamental architectural
>> concern with the development direction of XDP transmit.
>>
>>
>> What you are trying to implement, with delaying the doorbell, is
>> basically TX bulking for TX_XDP.
>>
>>  Why not implement a TX bulking interface directly instead?!?
>>
>> Yes, the tailptr/doorbell is the most costly operation, but why not
>> also take advantage of the benefits of bulking for other parts of the
>> code? (benefit is smaller, by every cycles counts in this area)
>>
>> This hole XDP exercise is about avoiding having a transaction cost per
>> packet, that reads "bulking" or "bundling" of packets, where possible.
>>
>>  Lets do bundling/bulking from the start!

Jesper, what we did here is also bulking, instead of bulkin in a
temporary list in the driver
we list the packets in the HW and once done we transmit all at once via the
xdp_doorbell indication.

I agree with you that we can take advantage and improve the icahce by
bulkin first in software and then queue all at once in the hw then
ring one doorbell.

but I also agree with Alexei that this will introduce an extra
pointer/list handling
in the diver and we need to do the comparison between both approaches
before we decide which is better.

this must be marked as future work and not have this from the start.

>
> mlx4 already does bulking and this proposed mlx5 set of patches
> does bulking as well.
> See nothing wrong about it. RX side processes the packets and
> when it's done it tells TX to xmit whatever it collected.
>
>> The reason behind the xmit_more API is that we could not change the
>> API of all the drivers.  And we found that calling an explicit NDO
>> flush came at a cost (only approx 7 ns IIRC), but it still a cost that
>> would hit the common single packet use-case.
>>
>> It should be really easy to build a bundle of packets that need XDP_TX
>> action, especially given you only have a single destination "port".
>> And then you XDP_TX send this bundle before mlx5_cqwq_update_db_record.
>
> not sure what are you proposing here?
> Sounds like you want to extend it to multi port in the future?
> Sure. The proposed code is easily extendable.
>
> Or you want to see something like a link list of packets
> or an array of packets that RX side is preparing and then
> send the whole array/list to TX port?
> I don't think that would be efficient, since it would mean
> unnecessary copy of pointers.
>
>> In the future, XDP need to support XDP_FWD forwarding of packets/pages
>> out other interfaces.  I also want bulk transmit from day-1 here.  It
>> is slightly more tricky to sort packets for multiple outgoing
>> interfaces efficiently in the pool loop.
>
> I don't think so. Multi port is natural extension to this set of patches.
> With multi port the end of RX will tell multiple ports (that were
> used to tx) to ring the bell. Pretty trivial and doesn't involve any
> extra arrays or link lists.
>
>> But the mSwitch[1] article actually already solved this destination
>> sorting.  Please read[1] section 3.3 "Switch Fabric Algorithm" for
>> understanding the next steps, for a smarter data structure, when
>> starting to have more TX "ports".  And perhaps align your single
>> XDP_TX destination data structure to this future development.
>>
>> [1] http://info.iet.unipi.it/~luigi/papers/20150617-mswitch-paper.pdf
>
> I don't see how this particular paper applies to the existing kernel code.
> It's great to take ideas from research papers, but real code is different.
>
>> --Jesper
>> (top post)
>
> since when it's ok to top post?
>
>> On Wed,  7 Sep 2016 15:42:32 +0300 Saeed Mahameed <saeedm@mellanox.com> wrote:
>>
>> > Previously we rang XDP SQ doorbell on every forwarded XDP packet.
>> >
>> > Here we introduce a xmit more like mechanism that will queue up more
>> > than one packet into SQ (up to RX napi budget) w/o notifying the hardware.
>> >
>> > Once RX napi budget is consumed and we exit napi RX loop, we will
>> > flush (doorbell) all XDP looped packets in case there are such.
>> >
>> > XDP forward packet rate:
>> >
>> > Comparing XDP with and w/o xmit more (bulk transmit):
>> >
>> > Streams     XDP TX       XDP TX (xmit more)
>> > ---------------------------------------------------
>> > 1           4.90Mpps      7.50Mpps
>> > 2           9.50Mpps      14.8Mpps
>> > 4           16.5Mpps      25.1Mpps
>> > 8           21.5Mpps      27.5Mpps*
>> > 16          24.1Mpps      27.5Mpps*
>> >
>> > *It seems we hit a wall of 27.5Mpps, for 8 and 16 streams,
>> > we will be working on the analysis and will publish the conclusions
>> > later.
>> >
>> > Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
>> > ---
>> >  drivers/net/ethernet/mellanox/mlx5/core/en.h    |  9 ++--
>> >  drivers/net/ethernet/mellanox/mlx5/core/en_rx.c | 57 +++++++++++++++++++------
>> >  2 files changed, 49 insertions(+), 17 deletions(-)
> ...
>> > @@ -131,7 +132,7 @@ static inline u32 mlx5e_decompress_cqes_cont(struct mlx5e_rq *rq,
>> >                     mlx5e_read_mini_arr_slot(cq, cqcc);
>> >
>> >     mlx5e_tx_notify_hw(sq, &wqe->ctrl, 0);
>> >
>> > +#if 0 /* enable this code only if MLX5E_XDP_TX_WQEBBS > 1 */
>
> Saeed,
> please make sure to remove such debug bits.
>

Sure, will fix this.

Thanks,
Saeed.
