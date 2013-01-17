From: "Williams, Mitch A" <mitch.a.williams@intel.com>
Subject: RE: [E1000-devel] [PATCH net-next] igbvf: fix setting
 addr_assign_type if PF is up
Date: Thu, 17 Jan 2013 00:42:30 +0000
Message-ID: <AAEA33E297BCAC4B9BB20A7C2DF0AB8D2A3468AE@FMSMSX107.amr.corp.intel.com>
References: <1357725564-5581-1-git-send-email-sassmann@kpanic.de>
	<AAEA33E297BCAC4B9BB20A7C2DF0AB8D1F8B527A@FMSMSX107.amr.corp.intel.com>
	<50EDAFC6.3070700@kpanic.de>
	<AAEA33E297BCAC4B9BB20A7C2DF0AB8D1F8B539A@FMSMSX107.amr.corp.intel.com>
	<20130109133745.00004627@unknown>
	<20130114222542.GA29729@gospo.rdu.redhat.com>
 <20130115103141.00001e96@unknown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Stefan Assmann <sassmann@kpanic.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>
To: "Rose, Gregory V" <gregory.v.rose@intel.com>,
	Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:26515 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756161Ab3AQAmg convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jan 2013 19:42:36 -0500
In-Reply-To: <20130115103141.00001e96@unknown>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Rose, Gregory V
> Sent: Tuesday, January 15, 2013 10:32 AM
> To: Andy Gospodarek
> Cc: Williams, Mitch A; Stefan Assmann; netdev@vger.kernel.org; e1000-
> devel@lists.sourceforge.net
> Subject: Re: [E1000-devel] [PATCH net-next] igbvf: fix setting
> addr_assign_type if PF is up
> 
> On Mon, 14 Jan 2013 17:25:42 -0500
> Andy Gospodarek <andy@greyhouse.net> wrote:
> 
> > On Wed, Jan 09, 2013 at 01:37:45PM -0800, Greg Rose wrote:
> > > On Wed, 9 Jan 2013 18:56:36 +0000
> > > "Williams, Mitch A" <mitch.a.williams@intel.com> wrote:
> > >
> > > > > >> When the PF is up and igbvf is loaded the MAC address is not
> > > > > >> generated using eth_hw_addr_random(). This results in
> > > > > >> addr_assign_type not to be set.
> > > > > >> Make sure it gets set.
> > > > > >>
> > > > > >
> > > > > > NAK - In this case, the address may or may not be random. The
> > > > > > user may have (and should have!) explicitly set this address
> > > > > > from the host to ensure that the VF device receives the same
> > > > > > address each time it
> > > > > boots.
> > > > >
> > > > > Maybe you can give me some advice on this then. Why is there
> > > > > different behaviour depending on the PF being up or down? The
> > > > > problem I'm facing is that if the user did not set a MAC address
> > > > > for the VF manually and the PF is up during igbvf_probe it will
> > > > > not be labelled as random although it is.
> > > > > What about checking IGB_VF_FLAG_PF_SET_MAC and only set
> > > > > NET_ADDR_RANDOM if the flag is cleared?
> > > > >
> > > >
> > > > The difference in behavior is because we cannot get any MAC
> > > > address at all if the PF is down. The interface won't operate at
> > > > all in this case, but if the PF comes up sometime later, we can
> > > > start working. The other alternative is to leave the MAC address
> > > > as all zeros and forcing the user to assign an address manually.
> > > > We chose to use a random address to at least give it a chance of
> > > > working once the PF woke up.
> > >
> > > Having been around at the inception of SR-IOV in Linux I recall that
> > > the primary reason we used a random ethernet address was so that the
> > > VF could at least work because there was no infrastructure to allow
> > > the host administrator to set the MAC address of the VF.
> > > This hobbled testing and validation because the user would have to
> > > go to each VM and use a command local to the VM to set the VF MAC
> > > address to some LAA via ifconfig or ip.  When testing large numbers
> > > of VFs this was a definite pain.
> > >
> > > Now that has changed and I wonder if maybe we shouldn't back out the
> > > random ethernet address assignment and go ahead with all zeros,
> > > leaving the device non-functional until the user has intentionally
> > > set either an LAA through the VF itself, or an administratively
> > > assigned MAC through the ip tool via the PF.
> > >
> > > Use of the random MAC address is not recommended by Intel's own best
> > > known methods literature, it was used mostly so that we could get
> > > the technology working and it should probably be at least considered
> > > for deprecation or out right elimination.
> > >
> >
> > It would be great to remove the bits that created random MAC addresses
> > for VFs, but wouldn't that break Linus' rule to "not break userspace"
> > if it was removed?
> 
> It may, I'm not sure but before we make any changes we'd want to do our
> due diligence.
> 
> >
> > There are 2 options that immediately come to mind when looking to
> > resolve this:
> >
> > 1.  Use some of the left-over bits in the mailbox messages to pass
> > along a flag with the E1000_VF_RESET messages to indicate whether the
> > MAC was randomly generated.  This would be pretty easy, but there
> > could be compatibility issues for a while.
> 
> We recently introduced the concept of mailbox message API versions in
> our PF and VF drivers to handle this sort of thing.  We could probably
> leverage that method to introduce a new API version that supports the
> additional bits in the reset message.  It would only be used if the VF
> could negotiate to the proper mailbox message API version with the PF.
> 
> >
> > 2.  Default to a MAC address of all zeros, and as a device with
> > all-zeros for a MAC is brought up, randomly create one with
> > eth_hw_addr_random.  This may not immediately help cases where device
> > assignment are a problem, but it would ensure that any device with a
> > random MAC as assigned by the kernel, would have NET_ADDR_RANDOM set
> > in addr_assign_type.
> 
> Thanks for the suggestions.  We're considering some changes in this area
> but we (Intel) need to give this a lot of thought and right now we're
> just in a preliminary discussion mode about it.  Stay tuned.
> 
> - Greg

OK, here's what I'm thinking. We don't need to change the communications
protocol for this, and it shouldn't break userspace.

First, have the PF driver quit assigning random addresses. It will either
give the VF the address assigned by the administrator, or it will give
all zeros.

Second, modify the VF driver init sequence slightly. If it gets all
zeros from the PF driver, then it should give itself a random address
and set NET_ADDR_RANDOM.

If we do it this way, the VF will still come up with a random address if
one has not been assigned, and it will always know whether or not the
address that it is using is random.

If there are no objections, I'll try to get some patches done in the next
few days and get them into our internal test queue. These would then 
escape into the real world in a few weeks.

-Mitch
