From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH RFC 08/11] net/mlx5e: XDP fast RX drop bpf programs support
Date: Thu, 8 Sep 2016 12:31:47 +0300
Message-ID: <CAJ3xEMiDBZ2-FdE7wniW0Y_S6k8NKfKEdy3w+1vs83oPuMAG5Q@mail.gmail.com>
References: <1473252152-11379-1-git-send-email-saeedm@mellanox.com>
 <1473252152-11379-9-git-send-email-saeedm@mellanox.com> <CAJ3xEMgsGHqQ7x8wky6Sfs34Ry67PnZEhYmnK=g8XnnXbgWagg@mail.gmail.com>
 <20160908093833.58101878@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Saeed Mahameed <saeedm@mellanox.com>,
        iovisor-dev <iovisor-dev@lists.iovisor.org>,
        Linux Netdev List <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Tom Herbert <tom@herbertland.com>,
        Martin KaFai Lau <kafai@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Eric Dumazet <edumazet@google.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Rana Shahout <ranas@mellanox.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f54.google.com ([209.85.218.54]:34412 "EHLO
        mail-oi0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757997AbcIHJbt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Sep 2016 05:31:49 -0400
Received: by mail-oi0-f54.google.com with SMTP id m11so62858986oif.1
        for <netdev@vger.kernel.org>; Thu, 08 Sep 2016 02:31:48 -0700 (PDT)
In-Reply-To: <20160908093833.58101878@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 8, 2016 at 10:38 AM, Jesper Dangaard Brouer
<brouer@redhat.com> wrote:
> On Wed, 7 Sep 2016 23:55:42 +0300
> Or Gerlitz <gerlitz.or@gmail.com> wrote:
>
>> On Wed, Sep 7, 2016 at 3:42 PM, Saeed Mahameed <saeedm@mellanox.com> wrote:
>> > From: Rana Shahout <ranas@mellanox.com>
>> >
>> > Add support for the BPF_PROG_TYPE_PHYS_DEV hook in mlx5e driver.
>> >
>> > When XDP is on we make sure to change channels RQs type to
>> > MLX5_WQ_TYPE_LINKED_LIST rather than "striding RQ" type to
>> > ensure "page per packet".
>> >
>> > On XDP set, we fail if HW LRO is set and request from user to turn it
>> > off.  Since on ConnectX4-LX HW LRO is always on by default, this will be
>> > annoying, but we prefer not to enforce LRO off from XDP set function.
>> >
>> > Full channels reset (close/open) is required only when setting XDP
>> > on/off.
>> >
>> > When XDP set is called just to exchange programs, we will update
>> > each RQ xdp program on the fly and for synchronization with current
>> > data path RX activity of that RQ, we temporally disable that RQ and
>> > ensure RX path is not running, quickly update and re-enable that RQ,
>> > for that we do:
>> >         - rq.state = disabled
>> >         - napi_synnchronize
>> >         - xchg(rq->xdp_prg)
>> >         - rq.state = enabled
>> >         - napi_schedule // Just in case we've missed an IRQ
>> >
>> > Packet rate performance testing was done with pktgen 64B packets and on
>> > TX side and, TC drop action on RX side compared to XDP fast drop.
>> >
>> > CPU: Intel(R) Xeon(R) CPU E5-2680 v3 @ 2.50GHz
>> >
>> > Comparison is done between:
>> >         1. Baseline, Before this patch with TC drop action
>> >         2. This patch with TC drop action
>> >         3. This patch with XDP RX fast drop
>> >
>> > Streams    Baseline(TC drop)    TC drop    XDP fast Drop
>> > --------------------------------------------------------------
>> > 1           5.51Mpps            5.14Mpps     13.5Mpps
>>
>> This (13.5 M PPS) is less than 50% of the result we presented @ the
>> XDP summit which was obtained by Rana. Please see if/how much does
>> this grows if you use more sender threads, but all of them to xmit the
>> same stream/flows, so we're on one ring. That (XDP with single RX ring
>> getting packets from N remote TX rings) would be your canonical
>> base-line for any further numbers.
>
> Well, my experiments with this hardware (mlx5/CX4 at 50Gbit/s) show
> that you should be able to reach 23Mpps on a single CPU.  This is
> a XDP-drop-simulation with order-0 pages being recycled through my
> page_pool code, plus avoiding the cache-misses (notice you are using a
> CPU E5-2680 with DDIO, thus you should only see a L3 cache miss).

so this takes up from 13M to 23M, good.

Could you explain why the move from order-3 to order-0 is hurting the
performance so much (drop from 32M to 23M), any way we can overcome that?

> The 23Mpps number looks like some HW limitation, as the increase was

not HW, I think. As I said, Rana got 32M with striding RQ when she was
using order-3
(or did we use order-5?)

> is not proportional to page-allocator overhead I removed (and CPU freq
> starts to decrease).  I also did scaling tests to more CPUs, which
> showed it scaled up to 40Mpps (you reported 45M).  And at the Phy RX
> level I see 60Mpps (50G max is 74Mpps).
