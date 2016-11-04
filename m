From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net-next RFC WIP] Patch for XDP support for virtio_net
Date: Fri, 4 Nov 2016 02:34:09 +0200
Message-ID: <20161104022927-mutt-send-email-mst@kernel.org>
References: <20161028171812.48073f1f@jkicinski-Precision-T1700>
 <20161028182223.GA53930@ast-mbp.thefacebook.com>
 <ec23c734c23d81884349484927140741@mail.gmail.com>
 <20161029112514.GC1810@pox.localdomain>
 <20161102152708.5cb40a0c@redhat.com>
 <b09333565b4ead1f90719cfb3643f6af@mail.gmail.com>
 <20161103041145.arylaxxssbdylfwn@redhat.com>
 <581ADCD1.3040404@gmail.com>
 <20161104002503-mutt-send-email-mst@kernel.org>
 <581BC852.7010304@gmail.com>
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
Received: from mx1.redhat.com ([209.132.183.28]:59640 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933428AbcKDAeO (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 3 Nov 2016 20:34:14 -0400
Content-Disposition: inline
In-Reply-To: <581BC852.7010304@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 03, 2016 at 04:29:22PM -0700, John Fastabend wrote:
> [...]
> 
> >>> - when XDP is attached disable all LRO using VIRTIO_NET_CTRL_GUEST_OFFLOADS_SET
> >>>   (not used by driver so far, designed to allow dynamic LRO control with
> >>>    ethtool)
> >>
> >> I see there is a UAPI bit for this but I guess we also need to add
> >> support to vhost as well? Seems otherwise we may just drop a bunch
> >> of packets on the floor out of handle_rx() when recvmsg returns larger
> >> than a page size. Or did I read this wrong...
> > 
> > It's already supported host side. However you might
> > get some packets that were in flight when you attached.
> > 
> 
> Really I must have missed it I don't see any *GUEST_FEATURES* flag in
> ./drivers/vhost/?

It's all done by QEMU catching these commands and calling
ioctls on the tun/macvtap/packet socket.

> >>> - start adding page-sized buffers
> >>
> >> I started to mangle add_recvbuf_big() and receive_big() here and this
> >> didn't seem too bad.
> > 
> > I imagine it won't be ATM but I think we'll need to support
> > mrg buffers with time and then it will be messy.
> > Besides, it's not an architectural thing that receive_big
> > uses page sized buffers, it could use any size.
> > So a separate path just for xdp would be better imho.
> > 
> >>> - do something with non-page-sized buffers added previously - what
> >>>   exactly? copy I guess? What about LRO packets that are too large -
> >>>   can we drop or can we split them up?
> >>
> >> hmm not sure I understand this here. With LRO disabled and mergeable
> >> buffers disabled all packets should fit in a page correct?
> > 
> > Assuing F_MTU is negotiated and MTU field is small enough, yes.
> > But if you disable mrg buffers dynamically you will get some packets
> > in buffers that were added before the disable.
> > Similarly for disabling LRO dynamically.
> > 
> >> With LRO enabled case I guess to start with we block XDP from being
> >> loaded for the same reason we don't allow jumbo frames on physical
> >> nics.
> > 
> > If you ask that host disables the capability, then yes, it's easy.
> > Let's do that for now, it's a start.
> > 
> > 
> >>>
> >>> I'm fine with disabling XDP for some configurations as the first step,
> >>> and we can add that support later.
> >>>
> >>
> >> In order for this to work though I guess we need to be able to
> >> dynamically disable mergeable buffers at the moment I just commented
> >> it out of the features list and fixed up virtio_has_features so it
> >> wont bug_on.
> > 
> > For now we can just set mrg_rxbuf=off on qemu command line, and
> > fail XDP attach if not there. I think we'll be able to support it
> > long term but you will need host side changes, or fully reset
> > device and reconfigure it.
> 
> see question below. I agree disabling mrg_rxbuff=off lro=off and an
> xdp receive path makes this relatively straight forward and clean with
> the MTU patch noted below as well.
> 
> > 
> >>> Ideas about mergeable buffers (optional):
> >>>
> >>> At the moment mergeable buffers can't be disabled dynamically.
> >>> They do bring a small benefit for XDP if host MTU is large (see below)
> >>> and aren't hard to support:
> >>> - if header is by itself skip 1st page
> >>> - otherwise copy all data into first page
> >>> and it's nicer not to add random limitations that require guest reboot.
> >>> It might make sense to add a command that disables/enabled
> >>> mergeable buffers dynamically but that's for newer hosts.
> >>
> >> Yep it seems disabling mergeable buffers solves this but didn't look at
> >> it too closely. I'll look closer tomorrow.
> >>
> >>>
> >>> Spec does not require it but in practice most hosts put all data
> >>> in the 1st page or all in the 2nd page so the copy will be nop
> >>> for these cases.
> >>>
> >>> Large host MTU - newer hosts report the host MTU, older ones don't.
> >>> Using mergeable buffers we can at least detect this case
> >>> (and then what? drop I guess).
> >>>
> >>
> >> The physical nics just refuse to load XDP with large MTU.
> > 
> > So let's do the same for now, unfortunately you don't know
> > the MTU unless _F_MTU is negitiated and QEMU does not
> > implement that yet, but it's easy to add.
> > In fact I suspect Aaron (cc) has an implementation since
> > he posted a patch implementing that.
> > Aaron could you post it pls?
> > 
> 
> Great! Aaron if you want me to review/test at all let me know I have
> a few systems setup running this now so can help if needed.
> 
> >> Any reason
> >> not to negotiate the mtu with the guest so that the guest can force
> >> this?
> > 
> > There are generally many guests and many NICs on the host.
> > A big packet arrives, what do you want to do with it?
> 
> Drop it just like a physical nic would do if packet is larger
> than MTU. Maybe splat a message in the log so user has some
> clue something got misconfigured.
> 
> > We probably want to build propagating MTU across all VMs and NICs
> > but let's get a basic thing merged first.
> 
> That feels like an orchestration/QEMU type problem to me. Just because
> some NIC has jumbo frames enabled doesn't necessarily mean they would
> ever get to any specific VM based on forwarding configuration.
> 
> And if I try to merge the last email I sent out here. In mergeable and
> big_packets modes if LRO is off and MTU < PAGE_SIZE it seems we should
> always get physically contiguous data on a single page correct?

Unfortunately not in the mergeable buffer case according to spec, even though
linux hosts will do that, so it's fine to optimize for that
but need to somehow work in other cases e.g. by doing a data copy.


> It
> may be at some offset in a page however. But the offset should not
> matter to XDP. If I read this right we wouldn't need to add a new
> XDP mode and could just use the existing merge or big modes. This would
> seem cleaner to me than adding a new mode and requiring a qemu option.
> 
> Thanks for all the pointers by the way its very helpful.

So for mergeable we spend cycles trying to make buffers as small
as possible and I have a patch to avoid copies for that too,
I'll post it next week hopefully.

-- 
MST
