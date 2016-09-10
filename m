From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [net-next PATCH v2 2/2] e1000: bundle xdp xmit routines
Date: Fri, 9 Sep 2016 18:40:35 -0700
Message-ID: <20160910014032.GA83023@ast-mbp.thefacebook.com>
References: <20160909212915.4001.25504.stgit@john-Precision-Tower-5810>
 <20160909212938.4001.40540.stgit@john-Precision-Tower-5810>
 <CALx6S35VCq9yPjcuhtx6jEJ78-WugkQZ6GSsqkcTr0Fa7edkVg@mail.gmail.com>
 <57D34D67.40804@gmail.com>
 <CALx6S36dH87e6TPxEBGsy0F-vD0fZzKyP8tbuuaAfLNSF1DGpw@mail.gmail.com>
 <57D35E08.8010204@gmail.com>
 <CALx6S36SM-wq6Fj8XK7GfMta1dVGr3RZ5uAgGdnxm7kgpVNFbw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: John Fastabend <john.fastabend@gmail.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        "David S. Miller" <davem@davemloft.net>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
        William Tu <u9012063@gmail.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:35792 "EHLO
        mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751014AbcIJBkk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Sep 2016 21:40:40 -0400
Received: by mail-pa0-f54.google.com with SMTP id b2so33384466pat.2
        for <netdev@vger.kernel.org>; Fri, 09 Sep 2016 18:40:40 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CALx6S36SM-wq6Fj8XK7GfMta1dVGr3RZ5uAgGdnxm7kgpVNFbw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 09, 2016 at 06:19:56PM -0700, Tom Herbert wrote:
> On Fri, Sep 9, 2016 at 6:12 PM, John Fastabend <john.fastabend@gmail.com> wrote:
> > On 16-09-09 06:04 PM, Tom Herbert wrote:
> >> On Fri, Sep 9, 2016 at 5:01 PM, John Fastabend <john.fastabend@gmail.com> wrote:
> >>> On 16-09-09 04:44 PM, Tom Herbert wrote:
> >>>> On Fri, Sep 9, 2016 at 2:29 PM, John Fastabend <john.fastabend@gmail.com> wrote:
> >>>>> e1000 supports a single TX queue so it is being shared with the stack
> >>>>> when XDP runs XDP_TX action. This requires taking the xmit lock to
> >>>>> ensure we don't corrupt the tx ring. To avoid taking and dropping the
> >>>>> lock per packet this patch adds a bundling implementation to submit
> >>>>> a bundle of packets to the xmit routine.
> >>>>>
> >>>>> I tested this patch running e1000 in a VM using KVM over a tap
> >>>>> device using pktgen to generate traffic along with 'ping -f -l 100'.
> >>>>>
> >>>> Hi John,
> >>>>
> >>>> How does this interact with BQL on e1000?
> >>>>
> >>>> Tom
> >>>>
> >>>
> >>> Let me check if I have the API correct. When we enqueue a packet to
> >>> be sent we must issue a netdev_sent_queue() call and then on actual
> >>> transmission issue a netdev_completed_queue().
> >>>
> >>> The patch attached here missed a few things though.
> >>>
> >>> But it looks like I just need to call netdev_sent_queue() from the
> >>> e1000_xmit_raw_frame() routine and then let the tx completion logic
> >>> kick in which will call netdev_completed_queue() correctly.
> >>>
> >>> I'll need to add a check for the queue state as well. So if I do these
> >>> three things,
> >>>
> >>>         check __QUEUE_STATE_XOFF before sending
> >>>         netdev_sent_queue() -> on XDP_TX
> >>>         netdev_completed_queue()
> >>>
> >>> It should work agree? Now should we do this even when XDP owns the
> >>> queue? Or is this purely an issue with sharing the queue between
> >>> XDP and stack.
> >>>
> >> But what is the action for XDP_TX if the queue is stopped? There is no
> >> qdisc to back pressure in the XDP path. Would we just start dropping
> >> packets then?
> >
> > Yep that is what the patch does if there is any sort of error packets
> > get dropped on the floor. I don't think there is anything else that
> > can be done.
> >
> That probably means that the stack will always win out under load.
> Trying to used the same queue where half of the packets are well
> managed by a qdisc and half aren't is going to leave someone unhappy.
> Maybe in the this case where we have to share the qdisc we can
> allocate the skb on on returning XDP_TX and send through the normal
> qdisc for the device.

I wouldn't go to such extremes for e1k.
The only reason to have xdp in e1k is to use it for testing
of xdp programs. Nothing else. e1k is, best case, 1Gbps adapter.
Existing stack with skb is perfectly fine as it is.
No need to do recycling, batching or any other complex things.
xdp for e1k cannot be used as an example for other drivers either,
since there is only one tx ring and any high performance adapter
has more which makes the driver support quite different.
