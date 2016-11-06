From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net-next RFC WIP] Patch for XDP support for virtio_net
Date: Sun, 6 Nov 2016 08:50:23 +0200
Message-ID: <20161106084922-mutt-send-email-mst@kernel.org>
References: <ec23c734c23d81884349484927140741@mail.gmail.com>
 <20161029112514.GC1810@pox.localdomain>
 <20161102152708.5cb40a0c@redhat.com>
 <b09333565b4ead1f90719cfb3643f6af@mail.gmail.com>
 <20161103041145.arylaxxssbdylfwn@redhat.com>
 <581ADCD1.3040404@gmail.com>
 <20161104002503-mutt-send-email-mst@kernel.org>
 <581BC852.7010304@gmail.com>
 <20161104022927-mutt-send-email-mst@kernel.org>
 <581D144F.8080007@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Shrijeet Mukherjee <shm@cumulusnetworks.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Thomas Graf <tgraf@suug.ch>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Jakub Kicinski <kubakici@wp.pl>,
        David Miller <davem@davemloft.net>, alexander.duyck@gmail.com,
        shrijeet@gmail.com, tom@herbertland.com, netdev@vger.kernel.org,
        Roopa Prabhu <roopa@cumulusnetworks.com>,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
        aconole@redhat.com
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36608 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751393AbcKFGu0 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 6 Nov 2016 01:50:26 -0500
Content-Disposition: inline
In-Reply-To: <581D144F.8080007@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 04, 2016 at 04:05:51PM -0700, John Fastabend wrote:
> On 16-11-03 05:34 PM, Michael S. Tsirkin wrote:
> > On Thu, Nov 03, 2016 at 04:29:22PM -0700, John Fastabend wrote:
> >> [...]
> >>
> >>>>> - when XDP is attached disable all LRO using VIRTIO_NET_CTRL_GUEST_OFFLOADS_SET
> >>>>>   (not used by driver so far, designed to allow dynamic LRO control with
> >>>>>    ethtool)
> >>>>
> >>>> I see there is a UAPI bit for this but I guess we also need to add
> >>>> support to vhost as well? Seems otherwise we may just drop a bunch
> >>>> of packets on the floor out of handle_rx() when recvmsg returns larger
> >>>> than a page size. Or did I read this wrong...
> >>>
> >>> It's already supported host side. However you might
> >>> get some packets that were in flight when you attached.
> >>>
> >>
> >> Really I must have missed it I don't see any *GUEST_FEATURES* flag in
> >> ./drivers/vhost/?
> > 
> > It's all done by QEMU catching these commands and calling
> > ioctls on the tun/macvtap/packet socket.
> > 
> 
> Well at least for the tap vhost backend in linux that I found here,
> 
>  ./qemu/net/tap-linux.c
> 
> there is no LRO feature flag but that is OK I can get it working next
> week looks fairly straight forward.
> 
> [...]

This is because tun/tap is the reverse of virtio. LRO in virtio
maps to TSO in tun.
The relevant function is tap_fd_set_offload in QEMU.


> >> And if I try to merge the last email I sent out here. In mergeable and
> >> big_packets modes if LRO is off and MTU < PAGE_SIZE it seems we should
> >> always get physically contiguous data on a single page correct?
> > 
> > Unfortunately not in the mergeable buffer case according to spec, even though
> > linux hosts will do that, so it's fine to optimize for that
> > but need to somehow work in other cases e.g. by doing a data copy.
> > 
> 
> ah OK this makes sense I was looking at vhost implementation in Linux.
> 
> > 
> >> It
> >> may be at some offset in a page however. But the offset should not
> >> matter to XDP. If I read this right we wouldn't need to add a new
> >> XDP mode and could just use the existing merge or big modes. This would
> >> seem cleaner to me than adding a new mode and requiring a qemu option.
> >>
> >> Thanks for all the pointers by the way its very helpful.
> > 
> > So for mergeable we spend cycles trying to make buffers as small
> > as possible and I have a patch to avoid copies for that too,
> > I'll post it next week hopefully.
> > 
> 
> Good to know. I'll get the XDP stuff wrapped up next week or see
> if Srijeet wants to do it.
> 
> Thanks,
> John
