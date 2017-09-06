From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net-next] virtio-net: invoke zerocopy callback on xmit
 path if no tx napi
Date: Wed, 6 Sep 2017 06:27:12 +0300
Message-ID: <20170906062441-mutt-send-email-mst@kernel.org>
References: <CAF=yD-+1wheMmC+HFKe_B_ULO0Mmh6HMSEbYY5D-HgqxVJee6A@mail.gmail.com>
 <20170826022744-mutt-send-email-mst@kernel.org>
 <CAF=yD-Lre0NATUVH8p0zS=G5CiY=WfKSefLmOZw940jZFgECgQ@mail.gmail.com>
 <CAF=yD-+Wk9sc9dXMUq1+x_hh=3ThTXa6BnZkygP3tgVpjbp93g@mail.gmail.com>
 <CAF=yD-+AjQLLUKdvnrwd2tqFtw4Hm81cR7WUJd65oLnziNGM8A@mail.gmail.com>
 <5ef7fcf3-d4f0-be16-6ddb-724d954cfc68@redhat.com>
 <CAF=yD-JREJqpsRdCi31qo1QNFEE2DDCaTGYw1f1waPgtov8WEg@mail.gmail.com>
 <CAF=yD-LZ4Abn8CFSQyuNnYSRZkHx4FTzK4hSi9WQaHO-28rsHQ@mail.gmail.com>
 <96819b6a-6d44-fd7e-37af-5a0db81b3840@redhat.com>
 <CAF=yD-JQ5vL8fhLwtz9yY9B4NZR3Tf0kmZHAi-9ht_-Bz0n4Sw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Jason Wang <jasowang@redhat.com>, Koichiro Den <den@klaipeden.com>,
        virtualization@lists.linux-foundation.org,
        Network Development <netdev@vger.kernel.org>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49076 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754386AbdIFD1Q (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 5 Sep 2017 23:27:16 -0400
Content-Disposition: inline
In-Reply-To: <CAF=yD-JQ5vL8fhLwtz9yY9B4NZR3Tf0kmZHAi-9ht_-Bz0n4Sw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 05, 2017 at 04:09:19PM +0200, Willem de Bruijn wrote:
> On Mon, Sep 4, 2017 at 5:03 AM, Jason Wang <jasowang@redhat.com> wrote:
> >
> >
> > On 2017年09月02日 00:17, Willem de Bruijn wrote:
> >>>>>
> >>>>> This is not a 50/50 split, which impliesTw that some packets from the
> >>>>> large
> >>>>> packet flow are still converted to copying. Without the change the rate
> >>>>> without queue was 80k zerocopy vs 80k copy, so this choice of
> >>>>> (vq->num >> 2) appears too conservative.
> >>>>>
> >>>>> However, testing with (vq->num >> 1) was not as effective at mitigating
> >>>>> stalls. I did not save that data, unfortunately. Can run more tests on
> >>>>> fine
> >>>>> tuning this variable, if the idea sounds good.
> >>>>
> >>>>
> >>>> Looks like there're still two cases were left:
> >>>
> >>> To be clear, this patch is not intended to fix all issues. It is a small
> >>> improvement to avoid HoL blocking due to queued zerocopy skbs.
> >
> >
> > Right, just want to see if there's anything left.
> >
> >>>
> >>> The trade-off is that reverting to copying in these cases increases
> >>> cycle cost. I think that that is a trade-off worth making compared to
> >>> the alternative drop in throughput. It probably would be good to be
> >>> able to measure this without kernel instrumentation: export
> >>> counters similar to net->tx_zcopy_err and net->tx_packets (though
> >>> without reset to zero, as in vhost_net_tx_packet).
> >
> >
> > I think it's acceptable if extra cycles were spent if we detect HOL anyhow.
> >
> >>>
> >>>> 1) sndbuf is not INT_MAX
> >>>
> >>> You mean the case where the device stalls, later zerocopy notifications
> >>> are queued, but these are never cleaned in free_old_xmit_skbs,
> >>> because it requires a start_xmit and by now the (only) socket is out of
> >>> descriptors?
> >>
> >> Typo, sorry. I meant out of sndbuf.
> >
> >
> > I mean e.g for tun. If its sndbuf is smaller than e.g (vq->num >> 1) *
> > $pkt_size and if all packet were held by some modules, limitation like
> > vq->num >> 1 won't work since we hit sudbuf before it.
> 
> Good point.

I agree however anyone using SNDBUF < infinity already hits HOQ blocking
in some scenarios.


> >>
> >>> A watchdog would help somewhat. With tx-napi, this case cannot occur,
> >>> either, as free_old_xmit_skbs no longer depends on a call to start_xmit.
> >>>
> >>>> 2) tx napi is used for virtio-net
> >>>
> >>> I am not aware of any issue specific to the use of tx-napi?
> >
> >
> > Might not be clear here, I mean e.g virtio_net (tx-napi) in guest +
> > vhost_net (zerocopy) in host. In this case, even if we switch to datacopy if
> > ubuf counts exceeds vq->num >> 1, we still complete tx buffers in order, tx
> > interrupt could be delayed for indefinite time.
> 
> Copied buffers are completed immediately in handle_tx.
> 
> Do you mean when a process sends fewer packets than vq->num >> 1,
> so that all are queued? Yes, then the latency is indeed that of the last
> element leaving the qdisc.
> 
> >>>
> >>>> 1) could be a corner case, and for 2) what your suggest here may not
> >>>> solve
> >>>> the issue since it still do in order completion.
> >>>
> >>> Somewhat tangential, but it might also help to break the in-order
> >>> completion processing in vhost_zerocopy_signal_used. Complete
> >>> all descriptors between done_idx and upend_idx. done_idx should
> >>> then only be forward to the oldest still not-completed descriptor.
> >>>
> >>> In the test I ran, where the oldest descriptors are held in a queue and
> >>> all newer ones are tail-dropped,
> >
> >
> > Do you mean the descriptors were tail-dropped by vhost?
> 
> Tail-dropped by netem. The dropped items are completed out of
> order by vhost before the held items.
