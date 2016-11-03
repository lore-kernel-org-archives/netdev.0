From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net-next RFC WIP] Patch for XDP support for virtio_net
Date: Fri, 4 Nov 2016 00:42:29 +0200
Message-ID: <20161104002503-mutt-send-email-mst@kernel.org>
References: <20161027.221027.109834362557507518.davem@davemloft.net>
 <58137533.4030105@gmail.com>
 <20161028171812.48073f1f@jkicinski-Precision-T1700>
 <20161028182223.GA53930@ast-mbp.thefacebook.com>
 <ec23c734c23d81884349484927140741@mail.gmail.com>
 <20161029112514.GC1810@pox.localdomain>
 <20161102152708.5cb40a0c@redhat.com>
 <b09333565b4ead1f90719cfb3643f6af@mail.gmail.com>
 <20161103041145.arylaxxssbdylfwn@redhat.com>
 <581ADCD1.3040404@gmail.com>
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
Received: from mx1.redhat.com ([209.132.183.28]:54564 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751500AbcKCWme (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 3 Nov 2016 18:42:34 -0400
Content-Disposition: inline
In-Reply-To: <581ADCD1.3040404@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 02, 2016 at 11:44:33PM -0700, John Fastabend wrote:
> On 16-11-02 09:11 PM, Michael S. Tsirkin wrote:
> > On Wed, Nov 02, 2016 at 06:28:34PM -0700, Shrijeet Mukherjee wrote:
> >>> -----Original Message-----
> >>> From: Jesper Dangaard Brouer [mailto:brouer@redhat.com]
> >>> Sent: Wednesday, November 2, 2016 7:27 AM
> >>> To: Thomas Graf <tgraf@suug.ch>
> >>> Cc: Shrijeet Mukherjee <shm@cumulusnetworks.com>; Alexei Starovoitov
> >>> <alexei.starovoitov@gmail.com>; Jakub Kicinski <kubakici@wp.pl>; John
> >>> Fastabend <john.fastabend@gmail.com>; David Miller
> >>> <davem@davemloft.net>; alexander.duyck@gmail.com; mst@redhat.com;
> >>> shrijeet@gmail.com; tom@herbertland.com; netdev@vger.kernel.org;
> >>> Roopa Prabhu <roopa@cumulusnetworks.com>; Nikolay Aleksandrov
> >>> <nikolay@cumulusnetworks.com>; brouer@redhat.com
> >>> Subject: Re: [PATCH net-next RFC WIP] Patch for XDP support for
> >> virtio_net
> >>>
> >>> On Sat, 29 Oct 2016 13:25:14 +0200
> >>> Thomas Graf <tgraf@suug.ch> wrote:
> >>>
> >>>> On 10/28/16 at 08:51pm, Shrijeet Mukherjee wrote:
> >>>>> Generally agree, but SRIOV nics with multiple queues can end up in a
> >>>>> bad spot if each buffer was 4K right ? I see a specific page pool to
> >>>>> be used by queues which are enabled for XDP as the easiest to swing
> >>>>> solution that way the memory overhead can be restricted to enabled
> >>>>> queues and shared access issues can be restricted to skb's using
> >> that
> >>> pool no ?
> >>>
> >>> Yes, that is why that I've been arguing so strongly for having the
> >> flexibility to
> >>> attach a XDP program per RX queue, as this only change the memory model
> >>> for this one queue.
> >>>
> >>>
> >>>> Isn't this clearly a must anyway? I may be missing something
> >>>> fundamental here so please enlighten me :-)
> >>>>
> >>>> If we dedicate a page per packet, that could translate to 14M*4K worth
> >>>> of memory being mapped per second for just a 10G NIC under DoS attack.
> >>>> How can one protect such as system? Is the assumption that we can
> >>>> always drop such packets quickly enough before we start dropping
> >>>> randomly due to memory pressure? If a handshake is required to
> >>>> determine validity of a packet then that is going to be difficult.
> >>>
> >>> Under DoS attacks you don't run out of memory, because a diverse set of
> >>> socket memory limits/accounting avoids that situation.  What does happen
> >>> is the maximum achievable PPS rate is directly dependent on the
> >>> time you spend on each packet.   This use of CPU resources (and
> >>> hitting mem-limits-safe-guards) push-back on the drivers speed to
> >> process
> >>> the RX ring.  In effect, packets are dropped in the NIC HW as RX-ring
> >> queue
> >>> is not emptied fast-enough.
> >>>
> >>> Given you don't control what HW drops, the attacker will "successfully"
> >>> cause your good traffic to be among the dropped packets.
> >>>
> >>> This is where XDP change the picture. If you can express (by eBPF) a
> >> filter
> >>> that can separate "bad" vs "good" traffic, then you can take back
> >> control.
> >>> Almost like controlling what traffic the HW should drop.
> >>> Given the cost of XDP-eBPF filter + serving regular traffic does not use
> >> all of
> >>> your CPU resources, you have overcome the attack.
> >>>
> >>> --
> >> Jesper,  John et al .. to make this a little concrete I am going to spin
> >> up a v2 which has only bigbuffers mode enabled for xdp acceleration, all
> >> other modes will reject the xdp ndo ..
> >>
> >> Do we have agreement on that model ?
> >>
> >> It will need that all vhost implementations will need to start with
> >> mergeable buffers disabled to get xdp goodness, but that sounds like a
> >> safe thing to do for now ..
> > 
> > It's ok for experimentation, but really after speaking with Alexei it's
> > clear to me that xdp should have a separate code path in the driver,
> > e.g. the separation between modes is something that does not
> > make sense for xdp.
> > 
> > The way I imagine it working:
> 
> OK I tried to make some sense out of this and get it working,
> 
> > 
> > - when XDP is attached disable all LRO using VIRTIO_NET_CTRL_GUEST_OFFLOADS_SET
> >   (not used by driver so far, designed to allow dynamic LRO control with
> >    ethtool)
> 
> I see there is a UAPI bit for this but I guess we also need to add
> support to vhost as well? Seems otherwise we may just drop a bunch
> of packets on the floor out of handle_rx() when recvmsg returns larger
> than a page size. Or did I read this wrong...

It's already supported host side. However you might
get some packets that were in flight when you attached.

> > - start adding page-sized buffers
> 
> I started to mangle add_recvbuf_big() and receive_big() here and this
> didn't seem too bad.

I imagine it won't be ATM but I think we'll need to support
mrg buffers with time and then it will be messy.
Besides, it's not an architectural thing that receive_big
uses page sized buffers, it could use any size.
So a separate path just for xdp would be better imho.

> > - do something with non-page-sized buffers added previously - what
> >   exactly? copy I guess? What about LRO packets that are too large -
> >   can we drop or can we split them up?
> 
> hmm not sure I understand this here. With LRO disabled and mergeable
> buffers disabled all packets should fit in a page correct?

Assuing F_MTU is negotiated and MTU field is small enough, yes.
But if you disable mrg buffers dynamically you will get some packets
in buffers that were added before the disable.
Similarly for disabling LRO dynamically.

> With LRO enabled case I guess to start with we block XDP from being
> loaded for the same reason we don't allow jumbo frames on physical
> nics.

If you ask that host disables the capability, then yes, it's easy.
Let's do that for now, it's a start.


> > 
> > I'm fine with disabling XDP for some configurations as the first step,
> > and we can add that support later.
> > 
> 
> In order for this to work though I guess we need to be able to
> dynamically disable mergeable buffers at the moment I just commented
> it out of the features list and fixed up virtio_has_features so it
> wont bug_on.

For now we can just set mrg_rxbuf=off on qemu command line, and
fail XDP attach if not there. I think we'll be able to support it
long term but you will need host side changes, or fully reset
device and reconfigure it.

> > Ideas about mergeable buffers (optional):
> > 
> > At the moment mergeable buffers can't be disabled dynamically.
> > They do bring a small benefit for XDP if host MTU is large (see below)
> > and aren't hard to support:
> > - if header is by itself skip 1st page
> > - otherwise copy all data into first page
> > and it's nicer not to add random limitations that require guest reboot.
> > It might make sense to add a command that disables/enabled
> > mergeable buffers dynamically but that's for newer hosts.
> 
> Yep it seems disabling mergeable buffers solves this but didn't look at
> it too closely. I'll look closer tomorrow.
> 
> > 
> > Spec does not require it but in practice most hosts put all data
> > in the 1st page or all in the 2nd page so the copy will be nop
> > for these cases.
> > 
> > Large host MTU - newer hosts report the host MTU, older ones don't.
> > Using mergeable buffers we can at least detect this case
> > (and then what? drop I guess).
> > 
> 
> The physical nics just refuse to load XDP with large MTU.

So let's do the same for now, unfortunately you don't know
the MTU unless _F_MTU is negitiated and QEMU does not
implement that yet, but it's easy to add.
In fact I suspect Aaron (cc) has an implementation since
he posted a patch implementing that.
Aaron could you post it pls?

> Any reason
> not to negotiate the mtu with the guest so that the guest can force
> this?

There are generally many guests and many NICs on the host.
A big packet arrives, what do you want to do with it?
We probably want to build propagating MTU across all VMs and NICs
but let's get a basic thing merged first.

> > 
> > 
> > 
> 
> Thanks,
> John
