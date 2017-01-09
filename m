From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [net PATCH] net: virtio: cap mtu when XDP programs are running
Date: Tue, 10 Jan 2017 01:58:58 +0200
Message-ID: <20170110015759-mutt-send-email-mst@kernel.org>
References: <20170102223031.11541.28717.stgit@john-Precision-Tower-5810>
 <402027b4-58c7-aa1b-5079-74e31448f544@redhat.com>
 <586BD5D5.6020100@gmail.com>
 <1caf1ffc-0f46-067e-0f0d-a93b408b4ffd@redhat.com>
 <586D458F.5050705@gmail.com>
 <068f0116-b37e-eb44-8c60-1781a9d5255e@redhat.com>
 <20170110010531-mutt-send-email-mst@kernel.org>
 <5874190B.9050505@gmail.com>
 <20170110012044-mutt-send-email-mst@kernel.org>
 <58742187.8050505@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Jason Wang <jasowang@redhat.com>, john.r.fastabend@intel.com,
        netdev@vger.kernel.org, alexei.starovoitov@gmail.com,
        daniel@iogearbox.net
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34866 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753320AbdAIX7A (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 9 Jan 2017 18:59:00 -0500
Content-Disposition: inline
In-Reply-To: <58742187.8050505@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 09, 2017 at 03:49:27PM -0800, John Fastabend wrote:
> On 17-01-09 03:24 PM, Michael S. Tsirkin wrote:
> > On Mon, Jan 09, 2017 at 03:13:15PM -0800, John Fastabend wrote:
> >> On 17-01-09 03:05 PM, Michael S. Tsirkin wrote:
> >>> On Thu, Jan 05, 2017 at 11:09:14AM +0800, Jason Wang wrote:
> >>>>
> >>>>
> >>>> On 2017年01月05日 02:57, John Fastabend wrote:
> >>>>> [...]
> >>>>>
> >>>>>> On 2017年01月04日 00:48, John Fastabend wrote:
> >>>>>>> On 17-01-02 10:14 PM, Jason Wang wrote:
> >>>>>>>> On 2017年01月03日 06:30, John Fastabend wrote:
> >>>>>>>>> XDP programs can not consume multiple pages so we cap the MTU to
> >>>>>>>>> avoid this case. Virtio-net however only checks the MTU at XDP
> >>>>>>>>> program load and does not block MTU changes after the program
> >>>>>>>>> has loaded.
> >>>>>>>>>
> >>>>>>>>> This patch sets/clears the max_mtu value at XDP load/unload time.
> >>>>>>>>>
> >>>>>>>>> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> >>>>>>>>> ---
> >>>>> [...]
> >>>>>
> >>>>>>> OK so this logic is a bit too simply. When it resets the max_mtu I guess it
> >>>>>>> needs to read the mtu via
> >>>>>>>
> >>>>>>>      virtio_cread16(vdev, ...)
> >>>>>>>
> >>>>>>> or we may break the negotiated mtu.
> >>>>>> Yes, this is a problem (even use ETH_MAX_MTU). We may need a method to notify
> >>>>>> the device about the mtu in this case which is not supported by virtio now.
> >>>>> Note this is not really a XDP specific problem. The guest can change the MTU
> >>>>> after init time even without XDP which I assume should ideally result in a
> >>>>> notification if the MTU is negotiated.
> >>>>
> >>>> Yes, Michael, do you think we need add some mechanism to notify host about
> >>>> MTU change in this case?
> >>>>
> >>>> Thanks
> >>>
> >>> Why does host care?
> >>>
> >>
> >> Well the guest will drop packets after mtu has been reduced.
> > 
> > I didn't know. What place in code does this?
> > 
> 
> hmm in many of the drivers it is convention to use the mtu to set the rx
> buffer sizes and a receive side max length filter. For example in the Intel
> drivers if a packet with length greater than MTU + some headroom is received we
> drop it. I guess in the networking stack RX path though nothing forces this and
> virtio doesn't have any code to drop packets on rx size.
> 
> In virtio I don't see any existing case currently. In the XDP case though we
> need to ensure packets fit in a page for the time being which is why I was
> looking at this code and generated this patch.

I'd say just look at the hardware max mtu. Ignore the configured mtu.


> >> Although the guest
> >> by reducing its MTU in some sense must expect this. Likewise if the host were
> >> to change MTU after virtio_net probe time the guest would not learn about it.
> > 
> > The spec explicitly disallows this last one.
> 
> OK. By the way were do I get the latest source I see the published virtio1.0 at
> the oasis-open.org site but it doesn't mention the MTU logic.

You need to get it from svn.

> > 
> >> I think at best negotiating the mtu is just a hint? If system _really_ cares
> >> we could use lldp or some other out of band mechanism to learn/set/adjust MTU
> >> on both systems and it would be more robust. I'm not actually convinced this
> >> is a problem in bare metal systems we have the same issue with physical
> >> switches and solve it out of band via configuration, protocols, etc.
> >>
> >> .John
> > 
> > ATM we don't have negotiation in virtio, just a max mtu limit.
> > This doesn't free guest from configuring mtu correctly,
> > just helps it avoid doing something clearly bogus.
> > 
> 
> Yep. I'm fine with calling it a misconfiguration if the guest reduces the MTU
> and the host continues to send packets @ advertised MTU.
