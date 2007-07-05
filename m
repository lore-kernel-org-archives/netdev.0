From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] ixgbe: Introduce new 10GbE driver for Intel 82598 based PCI	Express adapters...
Date: Thu, 5 Jul 2007 08:37:05 -0400
Message-ID: <20070705123705.GA19656@hmsreliant.homelinux.net>
References: <4688F512.3030801@garzik.org> <E35F4F4D7F6C9E4E826FEC1F86CEF58304193063@orsmsx412.amr.corp.intel.com> <20070703125346.GB4988@hmsreliant.homelinux.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>,
	arjan@linux.intel.com, akpm@linux-foundation.org
To: "Veeraiyan, Ayyappan" <ayyappan.veeraiyan@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:3122 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752778AbXGEMiM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Jul 2007 08:38:12 -0400
Content-Disposition: inline
In-Reply-To: <20070703125346.GB4988@hmsreliant.homelinux.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 03, 2007 at 08:53:46AM -0400, Neil Horman wrote:
> On Mon, Jul 02, 2007 at 12:00:29PM -0700, Veeraiyan, Ayyappan wrote:
> > On 7/2/07, Jeff Garzik <jeff@garzik.org> wrote:
> > > Ayyappan Veeraiyan wrote:
> > > > +#define IXGBE_TX_FLAGS_VLAN_MASK     0xffff0000
> > > > +#define IXGBE_TX_FLAGS_VLAN_SHIFT    16
> > > 
> > > defining bits using the form "(1 << n)" is preferred.  Makes it easier
> > > to read, by eliminating the requirement of the human brain to decode
> > hex
> > > into bit numbers.
> > > 
> > > 
> > 
> > Ok.
> > 
> > > > +             struct net_device netdev;
> > > > +     };
> > > 
> > > Embedded a struct net_device into your ring?  How can I put this?
> > > 
> > > Wrong, wrong.  Wrong, wrong, wrong.  Wrong.
> > > 
> > 
> > Agreed. 
> > Fake netdevs are needed for doing the multiple Rx queues in NAPI mode.
> > We are thinking to solve in 2 ways. Having netdev pointer in ring
> > structure or having an array of netdev pointers in ixgbe_adatper struct
> > which would be visible to all rings.
> > 
> If thats what you're using the netdev pointers in the ring structure for, I'd
> like to remind you that you tried using Fake netdevs in e1000 last year, and the
> results were crashes and potential data corruption.
> 
> http://marc.info/?l=linux-netdev&m=114954878711789&w=2
> 
> The consensus there at the
> end of the above thread was to revert out the e1000 multiple rx queue code until
> such time as the netpoll code could be updated to better interoperate with
> multiple rx queues (Andy Grover I believe was the person who volunteered for the
> job).  Given that I've not seen any netpoll updates regarding netpoll and
> multi-rx since then, I'm guessing the use of fake netdevs is still a problem.
> I've not checked this driver for all of the potential problems we found, but I
> will, and let you know if I see any.
> 
> Regards
> Neil
>  
Replying to myself...
	I've looked through the driver pretty throughly with regards to my above
concern, and it appears the driver is reasonably free of netpoll issues at the
moment, at least as far as what we found in e1000 was concerned.  I do however,
see a concern in the use of the in_netpoll flag within the driver.  Given that
the primary registered net_device, and all the dummy net_devices in the rx_ring
point to the same ixgbe_adapter structure, there can be some level of confusion
over weather a given rx queue is in netpoll_mode or not.  When the primary
adapter prforms a netpoll, all the individual rx queues will follow the
in_netpoll path in the receive path (assuming misx interrupts are used).  The
result I think is the potential for a large amount of packet reordering during a
netpoll operation.  Perhaps not a serious problem, but likely worth looking into
further.

Regards
Neil


-- 
/***************************************************
 *Neil Horman
 *Software Engineer
 *Red Hat, Inc.
 *nhorman@tuxdriver.com
 *gpg keyid: 1024D / 0x92A74FA1
 *http://pgp.mit.edu
 ***************************************************/
