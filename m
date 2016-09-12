From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [net-next PATCH v2 2/2] e1000: bundle xdp xmit routines
Date: Sun, 11 Sep 2016 21:12:41 -0700
Message-ID: <20160912041239.GA8529@ast-mbp.thefacebook.com>
References: <CALx6S35VCq9yPjcuhtx6jEJ78-WugkQZ6GSsqkcTr0Fa7edkVg@mail.gmail.com>
 <57D34D67.40804@gmail.com>
 <CALx6S36dH87e6TPxEBGsy0F-vD0fZzKyP8tbuuaAfLNSF1DGpw@mail.gmail.com>
 <57D35E08.8010204@gmail.com>
 <CALx6S36SM-wq6Fj8XK7GfMta1dVGr3RZ5uAgGdnxm7kgpVNFbw@mail.gmail.com>
 <20160910014032.GA83023@ast-mbp.thefacebook.com>
 <CALx6S36Xo4ZJJg5k2RT9rcT_1_zKRG1n_EOruU=JqvXBnq=E3w@mail.gmail.com>
 <57D37D79.1050806@gmail.com>
 <CALx6S373K92E5uabb8MtyHpDvkpWUQmZRmoRF7pFnZ3wBW68Cw@mail.gmail.com>
 <57D61DD0.40504@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tom Herbert <tom@herbertland.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        "David S. Miller" <davem@davemloft.net>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
        William Tu <u9012063@gmail.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:36653 "EHLO
        mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751506AbcILEM4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Sep 2016 00:12:56 -0400
Received: by mail-pf0-f173.google.com with SMTP id 128so48095029pfb.3
        for <netdev@vger.kernel.org>; Sun, 11 Sep 2016 21:12:55 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <57D61DD0.40504@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Sep 11, 2016 at 08:15:28PM -0700, John Fastabend wrote:
> >>>>>>>>
> >>>>>>> But what is the action for XDP_TX if the queue is stopped? There is no
> >>>>>>> qdisc to back pressure in the XDP path. Would we just start dropping
> >>>>>>> packets then?
> >>>>>>
> >>>>>> Yep that is what the patch does if there is any sort of error packets
> >>>>>> get dropped on the floor. I don't think there is anything else that
> >>>>>> can be done.
> >>>>>>
> >>>>> That probably means that the stack will always win out under load.
> >>>>> Trying to used the same queue where half of the packets are well
> >>>>> managed by a qdisc and half aren't is going to leave someone unhappy.
> >>>>> Maybe in the this case where we have to share the qdisc we can
> >>>>> allocate the skb on on returning XDP_TX and send through the normal
> >>>>> qdisc for the device.
> >>>>
> >>>> I wouldn't go to such extremes for e1k.
> >>>> The only reason to have xdp in e1k is to use it for testing
> >>>> of xdp programs. Nothing else. e1k is, best case, 1Gbps adapter.
> >>>
> >>> I imagine someone may want this for the non-forwarding use cases like
> >>> early drop for DOS mitigation. Regardless of the use case, I don't
> >>> think we can break the fundamental assumptions made for qdiscs or the
> >>> rest of the transmit path. If XDP must transmit on a queue shared with
> >>> the stack we need to abide by the stack's rules for transmitting on
> >>> the queue-- which would mean alloc skbuff and go through qdisc (which
> >>
> >> If we require XDP_TX to go up to qdisc layer its best not to implement
> >> it at all and just handle it in normal ingress path. That said I think
> >> users have to expect that XDP will interfere with qdisc schemes. Even
> >> with its own tx queue its going to interfere at the hardware level with
> >> bandwidth as the hardware round robins through the queues or uses
> >> whatever hardware strategy it is configured to use. Additionally it
> >> will bypass things like BQL, etc.
> >>
> > Right, but not all use cases involve XDP_TX (like DOS mitigation as I
> > pointed out). Since you've already done 95% of the work, can you take
> > a look at creating the skbuff and injecting into the stack for XDP_TX
> > so we can evaluate the performance and impact of that :-)
> > 
> > With separate TX queues it's explicit which queues are managed by the
> > stack. This is no different than what kernel bypass gives use, we are
> > relying on HW to do something reasonable in scheduling MQ.
> > 
> 
> How about instead of dropping packets on xdp errors we make the
> behavior to send the packet to the stack by default. Then the stack can
> decide what to do with it. This is easier from the drivers perspective
> and avoids creating a qdisc inject path for XDP. We could set the mark
> field if the stack wants to handle XDP exceptions somehow differently.
> 
> If we really want XDP to have an inject path I think we should add
> another action XDP_QDISC_INJECT. And add some way for XDP to run
> programs on exceptions. Perhaps via an exception map.

Nack for any new features just for e1k.
I don't like where this discussion is going.
I've been hacking xdp support for e1k only to be able to debug
xdp programs in kvm instead of messing with physical hosts where
every bpf program mistake kills ssh connection.
Please stop this overdesign. I'd rather not have xdp for e1k
instead of going into this crazy new action codes and random
punt to stack. If there is a conflict between stack and xdp, just
drop the packet. e1k is _not_ an example for any other drivers.
When high performance NIC will have such tx ring sharing issues
only then we'd need to come with a solution. Currently that's not
the case, so there is no need to come up with anything but
the simplest approach.
