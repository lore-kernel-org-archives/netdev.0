From: Dan Williams <dcbw@redhat.com>
Subject: Re: Generic interface to make physical port number used by a
 netdevice available to user space
Date: Thu, 23 May 2013 14:05:00 -0500
Message-ID: <1369335900.25066.14.camel@dcbw.foobar.com>
References: <20130522075331.GA1363@fedora-17-guest.blr.amer.dell.com>
	 <1369238658.2670.9.camel@bwh-desktop.uk.level5networks.com>
	 <20130523132729.GA11584@fedora-17-guest.blr.amer.dell.com>
	 <1369325920.1950.20.camel@bwh-desktop.uk.level5networks.com>
	 <1369334028.25066.8.camel@dcbw.foobar.com>
	 <1369334904.6963.17.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Narendra_K@Dell.com, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57085 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758028Ab3EWTE2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 May 2013 15:04:28 -0400
In-Reply-To: <1369334904.6963.17.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-05-23 at 19:48 +0100, Ben Hutchings wrote:
> On Thu, 2013-05-23 at 13:33 -0500, Dan Williams wrote:
> > On Thu, 2013-05-23 at 17:18 +0100, Ben Hutchings wrote:
> > > On Thu, 2013-05-23 at 06:27 -0700, Narendra_K@Dell.com wrote:
> > > > On Wed, May 22, 2013 at 09:34:18PM +0530, Ben Hutchings wrote:
> > > > > 
> > > > > On Wed, 2013-05-22 at 13:24 +0530, Narendra_K@Dell.com wrote:
> > > > > > While looking for already existing generic facility, 'dev_id' sysfs attribute
> > > > > > seemed relevant. Looking into the sources seemed to indicate that majority of
> > > > > > the drivers do not set it and it could be interpreted differently.
> > > > > 
> > > > > That is what it's for.  Unfortunately it is defined to be 0-based and as
> > > > > you've seen the default (unknown) value is also 0, creating ambiguity.
> > > > > (It also seems to be more common for user-facing documentation and
> > > > > physical labels to use 1-based numbering.)
> > > > > 
> > > > > I wonder whether it would do any harm to make it signed and initialised
> > > > > it to -1 in alloc_netdev_mqs() would do any harm?  That would make the
> > > > > unknown case unambiguous.
> > > > > 
> > > > > > It would be great to know list's thoughts on  'dev_id' being used as the
> > > > > interface
> > > > > > to make the physical port number information used by netdevice available to
> > > > > user
> > > > > > space or do we need a new sysfs attribute for the same.
> > > > > >
> > > > > > Note: I think in the scenario of SRIOV VF devices assigned to guest and being
> > > > > > bonded, additional information would be needed to differentiate the network
> > > > > > controller in the host.  But I suppose it is a different problem than this.
> > > > > 
> > > > > You're thinking about hybrid guest acceleration?  A combination of PCIe
> > > > > serial number and port number should work.
> > > > 
> > > > Hi Ben,
> > > > 
> > > > Thank you for the response.
> > > > 
> > > > I was thinking about the scenario of VF0 and VF1 coming from PF0 in the host
> > > > Network Controller 1 being direct assigned to a KVM guest via VTD and netdevices
> > > > from VF0 and VF1 being bonded in the guest. Assuming that physical port number used
> > > > by VF0 and VF1 is 1, additional information is needed to identify if port number 1
> > > > is on Network controller 1 or Network controller 2. (In the host we could use
> > > > PCI b/d/f to differentiate two Network Controllers). I think it is similar to
> > > > hybrid guest acceleration on the VF assignment aspect.
> > > 
> > > OK.  Either way, the hypervisor or management stack will have to help
> > > the guest by providing the identifier(s) to tie the devices together.  I
> > > suggested PCIe serial number as the controller identifier.
> > 
> > Forgive my ignorance, but is the PCIe serial number anything like the
> > USB serial number?  Almost nobody sets a unique serial number for USB
> > devices and often it's all zeros or 0123456789abcdef, so hopefully the
> > PCIe one is saner.  If not, we shouldn't use it for anything important.
> 
> The PCIe serial number is specified as an EUI-64, which is trivially
> derived from a MAC address.  So this is relatively easy to get right as
> you need to assign unique MAC addresses anyway.  It's also an optional
> capability, so there's no particular reason to set a dummy value.
> 
> That's not to say no-one ever gets this wrong.  SFC4000-based boards
> have the bytes in reverse order.  Other potential mistakes would be
> exposing different serial numbers in different functions, or changing
> the serial number when the MAC address is temporarily changed.

Hmm, that's not making me feel warm and fuzzy inside when thinking about
using this as an identifier of the parent interface.  If you happened to
bond two interfaces and the firmware did change the serial number in
response to a MAC address change, I think we'd be hosed, no?

Dan
