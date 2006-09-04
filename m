From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: sky2 problem on powerpc
Date: Tue, 05 Sep 2006 07:33:16 +1000
Message-ID: <1157405596.22705.54.camel@localhost.localdomain>
References: <1157347462.22705.16.camel@localhost.localdomain>
	 <1157354470.22705.26.camel@localhost.localdomain>
	 <1157355748.22705.32.camel@localhost.localdomain>
	 <BA4B0E19-9989-4477-A623-9BD9F021E7F0@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@osdl.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:49069 "EHLO gate.crashing.org")
	by vger.kernel.org with ESMTP id S964989AbWIDVdg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Sep 2006 17:33:36 -0400
To: Segher Boessenkool <segher@kernel.crashing.org>
In-Reply-To: <BA4B0E19-9989-4477-A623-9BD9F021E7F0@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2006-09-04 at 23:05 +0200, Segher Boessenkool wrote:
> > The patch has a couple of places where I reversed 2 assignments, they
> > are harmless, it was before I figured out that the chip will
> > (apparently) not access a descriptor before it's been told to do so  
> > via
> > MMIO, and thus the order of the writes to the descriptors is  
> > irrelevant
> > (I was also adding wmb's though I removed them).
> 
> wmb() between writing the descriptors to main memory and writing
> an MMIO to the device to tell it to go fetch them?  That's still
> required.  The 970 you tested on won't care though ;-)

Won't it ? Anyway, you misunderstood, there is a wmb() already in the
right place
in sky2_put_idx() if I understand things correctly (but then I don't
know the chip hardware well) and the ones I originally added weren't
necessary.

> > There is a couple of places where we were doing a BE and not LE
> > conversion of a descriptor field (typically in the VLAN code). I'm not
> > sure what's up there but BE "felt" wrong. I have turned them into LE
> > conversions but then I haven't tested VLAN, and I might just
> > misudnerstand what's happening there so I'll let you decide what to do
> > about those.
> 
> VLAN tags are big-endian on the wire, it might well be that these
> chips never swizzle that?

Maybe yes.

> > --- linux-work.orig/drivers/net/sky2.c	2006-09-04  
> > 17:35:20.000000000 +1000
> > +++ linux-work/drivers/net/sky2.c	2006-09-04 17:41:50.000000000 +1000
> > @@ -811,8 +811,9 @@ static void rx_set_checksum(struct sky2_
> >  	struct sky2_rx_le *le;
> >
> >  	le = sky2_next_rx(sky2);
> > -	le->addr = (ETH_HLEN << 16) | ETH_HLEN;
> > +	le->addr = cpu_to_le32((ETH_HLEN << 16) | ETH_HLEN);
> >  	le->ctrl = 0;
> > +	le->length = 0;
> >  	le->opcode = OP_TCPSTART | HW_OWNER;
> 
> Is this  le->length  thing a separate bugfix?  Or just overly
> protective coding (you write the field later again).

Overly protective coding when I was still looking for what the problem
was (wanted to have nice descriptors in memory without crap in them :)
I'll try without

> > +	/* Don't let it byte swap descriptors in hardware. Clear the bit
> > +	 * in case a previous driver have set it
> > +	 */
> > +	reg = sky2_pci_read32(hw, PCI_DEV_REG2);
> > +	reg &= ~PCI_REV_DESC;
> > +	sky2_pci_write32(hw, PCI_DEV_REG2, reg);
> 
> Probably not needed, the chip gets a full reset at startup (or so
> I hope anyway, heh).

It is needed. I've verified that this bit resists to anything we do in
the driver. So if you load the old driver that sets it, unload it, then
load the fixed driver, you are toast... I'm also taking no risk in case
one has a firmware that sets this bit.

Ben.


