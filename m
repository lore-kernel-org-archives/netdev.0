From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [E1000-devel] [PATCH net-next] igbvf: fix setting
 addr_assign_type if PF is up
Date: Mon, 14 Jan 2013 17:25:42 -0500
Message-ID: <20130114222542.GA29729@gospo.rdu.redhat.com>
References: <1357725564-5581-1-git-send-email-sassmann@kpanic.de>
 <AAEA33E297BCAC4B9BB20A7C2DF0AB8D1F8B527A@FMSMSX107.amr.corp.intel.com>
 <50EDAFC6.3070700@kpanic.de>
 <AAEA33E297BCAC4B9BB20A7C2DF0AB8D1F8B539A@FMSMSX107.amr.corp.intel.com>
 <20130109133745.00004627@unknown>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Williams, Mitch A" <mitch.a.williams@intel.com>,
	Stefan Assmann <sassmann@kpanic.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>
To: Greg Rose <gregory.v.rose@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54064 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756535Ab3ANW3E (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Jan 2013 17:29:04 -0500
Content-Disposition: inline
In-Reply-To: <20130109133745.00004627@unknown>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 09, 2013 at 01:37:45PM -0800, Greg Rose wrote:
> On Wed, 9 Jan 2013 18:56:36 +0000
> "Williams, Mitch A" <mitch.a.williams@intel.com> wrote:
> 
> > > >> When the PF is up and igbvf is loaded the MAC address is not
> > > >> generated using eth_hw_addr_random(). This results in
> > > >> addr_assign_type not to be set.
> > > >> Make sure it gets set.
> > > >>
> > > >
> > > > NAK - In this case, the address may or may not be random. The
> > > > user may have (and should have!) explicitly set this address from
> > > > the host to ensure that the VF device receives the same address
> > > > each time it
> > > boots.
> > > 
> > > Maybe you can give me some advice on this then. Why is there
> > > different behaviour depending on the PF being up or down? The
> > > problem I'm facing is that if the user did not set a MAC address
> > > for the VF manually and the PF is up during igbvf_probe it will not
> > > be labelled as random although it is.
> > > What about checking IGB_VF_FLAG_PF_SET_MAC and only set
> > > NET_ADDR_RANDOM if the flag is cleared?
> > > 
> > 
> > The difference in behavior is because we cannot get any MAC address
> > at all if the PF is down. The interface won't operate at all in this
> > case, but if the PF comes up sometime later, we can start working.
> > The other alternative is to leave the MAC address as all zeros and
> > forcing the user to assign an address manually. We chose to use a
> > random address to at least give it a chance of working once the PF
> > woke up.
> 
> Having been around at the inception of SR-IOV in Linux I recall that
> the primary reason we used a random ethernet address was so
> that the VF could at least work because there was no infrastructure
> to allow the host administrator to set the MAC address of the VF.  This
> hobbled testing and validation because the user would have to go to
> each VM and use a command local to the VM to set the VF MAC address to
> some LAA via ifconfig or ip.  When testing large numbers of VFs this was
> a definite pain.
> 
> Now that has changed and I wonder if maybe we shouldn't back out the
> random ethernet address assignment and go ahead with all zeros, leaving
> the device non-functional until the user has intentionally set either
> an LAA through the VF itself, or an administratively assigned MAC
> through the ip tool via the PF.
> 
> Use of the random MAC address is not recommended by Intel's own best
> known methods literature, it was used mostly so that we could get the
> technology working and it should probably be at least considered for
> deprecation or out right elimination.
> 

It would be great to remove the bits that created random MAC addresses
for VFs, but wouldn't that break Linus' rule to "not break userspace" if
it was removed?

There are 2 options that immediately come to mind when looking to
resolve this: 

1.  Use some of the left-over bits in the mailbox messages to pass along
a flag with the E1000_VF_RESET messages to indicate whether the MAC was
randomly generated.  This would be pretty easy, but there could be
compatibility issues for a while.

2.  Default to a MAC address of all zeros, and as a device with
all-zeros for a MAC is brought up, randomly create one with
eth_hw_addr_random.  This may not immediately help cases where device
assignment are a problem, but it would ensure that any device with a
random MAC as assigned by the kernel, would have NET_ADDR_RANDOM set in
addr_assign_type.
