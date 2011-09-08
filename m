From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [net-next-2.6 PATCH 0/3 RFC] macvlan: MAC Address filtering
 support for passthru mode
Date: Thu, 8 Sep 2011 22:11:33 +0300
Message-ID: <20110908182509.GB469@redhat.com>
References: <CA8E3924.33B60%roprabhu@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, dragos.tatulea@gmail.com, arnd@arndb.de,
	dwang2@cisco.com, benve@cisco.com, kaber@trash.net, sri@us.ibm.com,
	davem@davemloft.net, eric.dumazet@gmail.com, mchan@broadcom.com,
	kvm@vger.kernel.org
To: Roopa Prabhu <roprabhu@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38526 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755140Ab1IHX3j (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Sep 2011 19:29:39 -0400
Content-Disposition: inline
In-Reply-To: <CA8E3924.33B60%roprabhu@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 08, 2011 at 09:19:32AM -0700, Roopa Prabhu wrote:
> >>> There are more features we'll want down the road though,
> >>> so let's see whether the interface will be able to
> >>> satisfy them in a backwards compatible way before we
> >>> set it in stone. Here's what I came up with:
> >>> 
> >>> How will the filtering table be partitioned within guests?
> >> 
> >> Since this patch supports macvlan PASSTHRU mode only, in which the lower
> >> device has 1-1 mapping to the guest nic, it does not require any
> >> partitioning of filtering table within guests. Unless I missed understanding
> >> something. 
> >> If the lower device were being shared by multiple guest network interfaces
> >> (non PASSTHRU mode), only then we will need to maintain separate filter
> >> tables for each guest network interface in macvlan and forward the pkt to
> >> respective guest interface after a filter lookup. This could affect
> >> performance too I think.
> > 
> > Not with hardware filtering support. Which is where we'd need to
> > partition the host nic mac table between guests.
> > 
> I need to understand this more. In non passthru case when a VF or physical
> nic is shared between guests,

For example, consider a VF given to each guest. Hardware supports a fixed
total number of filters, which can be partitioned between VFs.

> the nic does not really know about the guests,
> so I was thinking we do the same thing as we do for the passthru case (ie
> send all the address filters from macvlan to the physical nic). So at the
> hardware, filtering is done for all guests sharing the nic. But if we want
> each virtio-net nic or guest to get exactly what it asked for
> macvlan/macvtap needs to maintain a copy of each guest filter and do a
> lookup and send only the requested traffic to the guest. Here is the
> performance hit that I was seeing. Please see my next comment for further
> details. 

It won't be any slower than attaching a non-passthrough macvlan
to a device, will it?

> 
> >> I chose to support PASSTHRU Mode only at first because its simpler and all
> >> code additions are in control path only.
> > 
> > I agree. It would be a bit silly to have a dedicated interface
> > for passthough and a completely separate one for
> > non passthrough.
> >
> Agree. The reason I did not focus on non-passthru case in the initial
> version was because I was thinking things to do in the non-passthru case
> will be just add-ons to the passthru case. But true Better to flush out the
> non-pasthru case details.
> 
> After dwelling on this a bit more how about the below:
> 
> Phase 1: Goal: Enable hardware filtering for all macvlan modes
>     - In macvlan passthru mode the single guest virtio-nic connected will
>       receive traffic that he requested for
>     - In macvlan non-passthru mode all guest virtio-nics sharing the
>       physical nic will see all other guest traffic
>       but the filtering at guest virtio-nic

I don't think guests currently filter anything.

>       will make sure each guest
>       eventually sees traffic he asked for. This is still better than
>       putting the physical nic in promiscuous mode.
> 
> (This is mainly what my patch does...but will need to remove the passthru
> check and see if there are any thing else needed for non-passthru case)

I'm fine with sticking with passthrough, make non passthrough
a separate phase.

> 
> Phase 2: Goal: Enable filtering at macvlan so that each guest virtio-nic
> receives only what he requested for.
>     - In this case, in addition to pushing the filters down to the physical
>       nic we will have to maintain the same filter in macvlan and do a filter
>       lookup before forwarding the traffic to a virtio-nic.
> 
> But I am thinking phase 2 might be redundant given virtio-nic already does
> filtering for the guest.

It does? Do you mean the filter that qemu does in userspace?

> In which case we might not need phase 2 at all. I
> might have been over complicating things.
> 
> Please comment. And please correct if I missed something.
>  
>  
> >>> 
> >>> A way to limit what the guest can do would also be useful.
> >>> How can this be done? selinux?
> >> 
> >> I vaguely remember a thread on the same context.. had a suggestion to
> >> maintain pre-approved address lists and allow guest filter registration of
> >> only those addresses for security. This seemed reasonable. Plus the ability
> >> to support additional address registration from guest could be made
> >> configurable (One of your ideas again from prior work).
> >> 
> >> I am not an selinux expert, but I am thinking we can use it to only allow or
> >> disallow access or operations to the macvtap device. (?). I will check more
> >> on this.
> > 
> > We'd have to have a way to revoke that as well.
> > 
> Yes true.
> 
> 
> >>> 
> >>> Any thoughts on spoofing filtering?
> >> 
> >> I can only think of checking addresses against an allowed address list.
> >> Don't know of any other ways. Any hints ?
> > 
> > Hardware (esp SRIOV) often has ways to do this check, too.
> > 
> Yes correct. Hw sriov and even switch in 802.1Qbh has anti-spoofing feature.
> In which case I am thinking having It at the macvtap layer is not an
> absolute must (?).

Exactly. But let's figure out *how* it will be programmed.
If anti-spoofing is programmed with netlink, maybe that's
a better interface for rx filter too, for consistency.

> >> 
> >> In any case I am assuming all the protection/security measures should be
> >> taken at the layer calling the TUNSETTXFILTER ie..In macvtap virtualization
> >> use case its libvirt or qemu-kvm. No ?
> > 
> > Ideally we'd have a way to separate these capabilities, so that libvirt
> > can override qemu.
> > 
> >>> 
> >>> Would it be possible to make the filtering programmable
> >>> using netlink, e.g. ethtool, ip, or some such?
> >> 
> >> Should be possible via ethtool or ip calling ioctl TUNSETTXFILTER. Are you
> >> thinking of macvlan having a netlink interface to set filter and not ioctl
> >> ?. Sure.
> > 
> > Yes.
> > 
> >> But I was thinking the point of implementing TUNSETTXFILTER was to
> >> maintain compatibility with the generic tap interface that does the same
> >> thing. 
> > 
> > Yes. OTOH I don't think anyone uses that ATM so it might not
> > be important if it's not a good fit.
> > E.g. we could notify libvirt and have it use netlink for us
> > if we like that better.
> > 
> Ok thanks for clarifying that. One more reason to use TUNSETTXFILTER
> interface was for qemu-kvm who uses the same tap interface for macvtap and
> regular tap. So if we use netlink we have to do different things for macvtap
> and tap filters in qemu. And qemu-kvm does not distinguish between macvtap
> and tap as far as I know. No ?

It's not a question of simplifying qemu as much as trying to
make the kernel interface abstract device differences
away from users. Using same interface for tun and macvtap
gave us some confidence that the interface is a good one.

But this does not seem to have worked with TUNSETTXFILTER -
at least qemu doesn't use it yet, and it's been upstream
a while. So there's no proof it's a good interface.

So if we decide netlink is a better interface we can add it for tun too.
We need to be backwards compatible and figure out what happens if someone
tries to use both methods: probably apply both or ignore TUNSETTXFILTER ...

> 
> Thanks you for your review and comments.
> 
> 
> >> And having both the netlink op and ioctl interface might not be clean ?.
> > 
> > No idea.
> > 
> >> Sorry if I misunderstood your question.
> >> 
> >>> That would make this useful for bridged setups besides
> >>> macvtap/virtualization.
> >>> 
> >> 
> >> Thanks for the comments. 

Overall good progress, and don't let the interface discussions
block you. You want to push in two directions - stabilize code in one
branch, and play with interfaces in another one. By the time there's a
concensus on the interfaces you have the main logic all ready,
then you merge.

-- 
MST
