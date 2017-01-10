From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [net PATCH] net: virtio: cap mtu when XDP programs are running
Date: Tue, 10 Jan 2017 07:00:57 +0200
Message-ID: <20170110065056-mutt-send-email-mst@kernel.org>
References: <20170110010531-mutt-send-email-mst@kernel.org>
 <5874190B.9050505@gmail.com>
 <20170110012044-mutt-send-email-mst@kernel.org>
 <58742187.8050505@gmail.com>
 <20170110015759-mutt-send-email-mst@kernel.org>
 <9102bb4b-223a-d441-7546-8b4144d970fb@redhat.com>
 <20170110044910-mutt-send-email-mst@kernel.org>
 <5874555A.3070307@gmail.com>
 <20170110055023-mutt-send-email-mst@kernel.org>
 <58746247.604@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Jason Wang <jasowang@redhat.com>, john.r.fastabend@intel.com,
        netdev@vger.kernel.org, alexei.starovoitov@gmail.com,
        daniel@iogearbox.net
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58814 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750701AbdAJFA7 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 10 Jan 2017 00:00:59 -0500
Content-Disposition: inline
In-Reply-To: <58746247.604@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 09, 2017 at 08:25:43PM -0800, John Fastabend wrote:
> On 17-01-09 07:55 PM, Michael S. Tsirkin wrote:
> > On Mon, Jan 09, 2017 at 07:30:34PM -0800, John Fastabend wrote:
> >> On 17-01-09 06:51 PM, Michael S. Tsirkin wrote:
> >>> On Tue, Jan 10, 2017 at 10:29:39AM +0800, Jason Wang wrote:
> >>>>
> >>>>
> >>>> On 2017年01月10日 07:58, Michael S. Tsirkin wrote:
> >>>>> On Mon, Jan 09, 2017 at 03:49:27PM -0800, John Fastabend wrote:
> >>>>>> On 17-01-09 03:24 PM, Michael S. Tsirkin wrote:
> >>>>>>> On Mon, Jan 09, 2017 at 03:13:15PM -0800, John Fastabend wrote:
> >>>>>>>> On 17-01-09 03:05 PM, Michael S. Tsirkin wrote:
> >>>>>>>>> On Thu, Jan 05, 2017 at 11:09:14AM +0800, Jason Wang wrote:
> >>>>>>>>>> On 2017年01月05日 02:57, John Fastabend wrote:
> >>>>>>>>>>> [...]
> >>>>>>>>>>>
> >>>>>>>>>>>> On 2017年01月04日 00:48, John Fastabend wrote:
> >>>>>>>>>>>>> On 17-01-02 10:14 PM, Jason Wang wrote:
> >>>>>>>>>>>>>> On 2017年01月03日 06:30, John Fastabend wrote:
> >>>>>>>>>>>>>>> XDP programs can not consume multiple pages so we cap the MTU to
> >>>>>>>>>>>>>>> avoid this case. Virtio-net however only checks the MTU at XDP
> >>>>>>>>>>>>>>> program load and does not block MTU changes after the program
> >>>>>>>>>>>>>>> has loaded.
> >>>>>>>>>>>>>>>
> >>>>>>>>>>>>>>> This patch sets/clears the max_mtu value at XDP load/unload time.
> >>>>>>>>>>>>>>>
> >>>>>>>>>>>>>>> Signed-off-by: John Fastabend<john.r.fastabend@intel.com>
> >>>>>>>>>>>>>>> ---
> >>>>>>>>>>> [...]
> >>>>>>>>>>>
> >>>>>>>>>>>>> OK so this logic is a bit too simply. When it resets the max_mtu I guess it
> >>>>>>>>>>>>> needs to read the mtu via
> >>>>>>>>>>>>>
> >>>>>>>>>>>>>       virtio_cread16(vdev, ...)
> >>>>>>>>>>>>>
> >>>>>>>>>>>>> or we may break the negotiated mtu.
> >>>>>>>>>>>> Yes, this is a problem (even use ETH_MAX_MTU). We may need a method to notify
> >>>>>>>>>>>> the device about the mtu in this case which is not supported by virtio now.
> >>>>>>>>>>> Note this is not really a XDP specific problem. The guest can change the MTU
> >>>>>>>>>>> after init time even without XDP which I assume should ideally result in a
> >>>>>>>>>>> notification if the MTU is negotiated.
> >>>>>>>>>> Yes, Michael, do you think we need add some mechanism to notify host about
> >>>>>>>>>> MTU change in this case?
> >>>>>>>>>>
> >>>>>>>>>> Thanks
> >>>>>>>>> Why does host care?
> >>>>>>>>>
> >>>>>>>> Well the guest will drop packets after mtu has been reduced.
> >>>>>>> I didn't know. What place in code does this?
> >>>>>>>
> >>>>>> hmm in many of the drivers it is convention to use the mtu to set the rx
> >>>>>> buffer sizes and a receive side max length filter. For example in the Intel
> >>>>>> drivers if a packet with length greater than MTU + some headroom is received we
> >>>>>> drop it. I guess in the networking stack RX path though nothing forces this and
> >>>>>> virtio doesn't have any code to drop packets on rx size.
> >>>>>>
> >>>>>> In virtio I don't see any existing case currently. In the XDP case though we
> >>>>>> need to ensure packets fit in a page for the time being which is why I was
> >>>>>> looking at this code and generated this patch.
> >>>>> I'd say just look at the hardware max mtu. Ignore the configured mtu.
> >>>>>
> >>>>>
> >>>>
> >>>> Does this work for small buffers consider it always allocate skb with size
> >>>> of GOOD_PACKET_LEN?
> >>>
> >>> Spec says hardware won't send in packets > max mtu in config space.
> >>>
> >>>> I think in any case, we should limit max_mtu to
> >>>> GOOD_PACKET_LEN for small buffers.
> >>>>
> >>>> Thanks
> >>>
> >>> XDP seems to have a bunch of weird restrictions, I just
> >>> do not like it that the logic spills out to all drivers.
> >>> What if someone decides to extend it to two pages in the future?
> >>> Recode it all in all drivers ...
> >>>
> >>> Why can't net core enforce mtu?
> >>>
> >>
> >> OK I agree I'll put most the logic in rtnetlink.c when the program is added
> >> or removed.
> >>
> >> But, I'm looking at the non-XDP receive_small path now and wondering how does
> >> multiple buffer receives work (e.g. packet larger than GOOD_PACKET_LEN?)
> > 
> > I don't understand the question. Look at add_recvbuf_small,
> > it adds a tiny buffer for head and then the skb.
> > 
> 
> Specifically this seems to fail with mergeable buffers disabled
> 
> On the host:
> 
> # ip link set dev tap0 mtu 9000
> # ping 22.2 -s 2048
> 
> On the guest:
> 
> # insmod ./drivers/net/virtio_net.ko
> # ip link set dev eth0 mtu 9000

Why would it work? You are sending a packet larger than ethernet MTU.

> With mergeable buffers enabled no problems it works as I expect at least.

We don't expect to get these packets but
mergeable is able to process them anyway.
It's an accident :) 

> 
> > 
> >> I think
> >> this is what Jason is looking at as well? The mergeable case clearly looks at
> >> num_bufs in the descriptor to construct multi-buffer packets but nothing like
> >> that exists in the small_receive path as best I can tell.
> >>
> >> .John
> > 
> > There's always a single buffer there.
> > BTW it was always a legacy path but if it's now important for people we
> > should probably check ANY_LAYOUT and put header linearly with the packet
> > if there.
> > 
