From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [net-next PATCH v2 2/2] e1000: bundle xdp xmit routines
Date: Mon, 12 Sep 2016 13:56:35 +0200
Message-ID: <20160912135635.1fcb21f7@redhat.com>
References: <20160909212915.4001.25504.stgit@john-Precision-Tower-5810>
        <20160909212938.4001.40540.stgit@john-Precision-Tower-5810>
        <CALx6S35VCq9yPjcuhtx6jEJ78-WugkQZ6GSsqkcTr0Fa7edkVg@mail.gmail.com>
        <57D34D67.40804@gmail.com>
        <CALx6S36dH87e6TPxEBGsy0F-vD0fZzKyP8tbuuaAfLNSF1DGpw@mail.gmail.com>
        <57D35E08.8010204@gmail.com>
        <CALx6S36SM-wq6Fj8XK7GfMta1dVGr3RZ5uAgGdnxm7kgpVNFbw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.fastabend@gmail.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        "David S. Miller" <davem@davemloft.net>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
        William Tu <u9012063@gmail.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        brouer@redhat.com
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56490 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756103AbcILL4o (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 12 Sep 2016 07:56:44 -0400
In-Reply-To: <CALx6S36SM-wq6Fj8XK7GfMta1dVGr3RZ5uAgGdnxm7kgpVNFbw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Fri, 9 Sep 2016 18:19:56 -0700 Tom Herbert <tom@herbertland.com> wrote:
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

I agree, the only option is the drop the packet. For a DDoS use-case,
this is good, because this "switch" XDP into a more efficient mode
(direct recycling pages).

> >  
> That probably means that the stack will always win out under load.

Why would the stack win? Wouldn't XDP_TX win?

> Trying to used the same queue where half of the packets are well
> managed by a qdisc and half aren't is going to leave someone unhappy.
> Maybe in the this case where we have to share the qdisc we can
> allocate the skb on on returning XDP_TX and send through the normal
> qdisc for the device.

Hmmm. I'm not sure I like the approach of allocating an SKB, and
injecting into the qdisc.  Most of the performance gain goes out the
window.  Unless, we (1) bulk alloc SKBs, and (2) can avoid initializing
the entire SKB, and (3) bulk enqueue into qdisc.  It would be an
interesting "tool" for a zoom-in benchmark, what would allow us to
determine the cost/overhead of the network stack between RX to
qdisc-enqueue.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
