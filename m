From: Segher Boessenkool <segher@kernel.crashing.org>
Subject: Re: sky2 problem on powerpc
Date: Mon, 4 Sep 2006 23:05:01 +0200
Message-ID: <BA4B0E19-9989-4477-A623-9BD9F021E7F0@kernel.crashing.org>
References: <1157347462.22705.16.camel@localhost.localdomain> <1157354470.22705.26.camel@localhost.localdomain> <1157355748.22705.32.camel@localhost.localdomain>
Mime-Version: 1.0 (Apple Message framework v750)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@osdl.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-in-03.arcor-online.net ([151.189.21.43]:41891 "EHLO
	mail-in-01.arcor-online.net") by vger.kernel.org with ESMTP
	id S1751431AbWIDVF1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Sep 2006 17:05:27 -0400
In-Reply-To: <1157355748.22705.32.camel@localhost.localdomain>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> The patch has a couple of places where I reversed 2 assignments, they
> are harmless, it was before I figured out that the chip will
> (apparently) not access a descriptor before it's been told to do so  
> via
> MMIO, and thus the order of the writes to the descriptors is  
> irrelevant
> (I was also adding wmb's though I removed them).

wmb() between writing the descriptors to main memory and writing
an MMIO to the device to tell it to go fetch them?  That's still
required.  The 970 you tested on won't care though ;-)

> There is a couple of places where we were doing a BE and not LE
> conversion of a descriptor field (typically in the VLAN code). I'm not
> sure what's up there but BE "felt" wrong. I have turned them into LE
> conversions but then I haven't tested VLAN, and I might just
> misudnerstand what's happening there so I'll let you decide what to do
> about those.

VLAN tags are big-endian on the wire, it might well be that these
chips never swizzle that?

> --- linux-work.orig/drivers/net/sky2.c	2006-09-04  
> 17:35:20.000000000 +1000
> +++ linux-work/drivers/net/sky2.c	2006-09-04 17:41:50.000000000 +1000
> @@ -811,8 +811,9 @@ static void rx_set_checksum(struct sky2_
>  	struct sky2_rx_le *le;
>
>  	le = sky2_next_rx(sky2);
> -	le->addr = (ETH_HLEN << 16) | ETH_HLEN;
> +	le->addr = cpu_to_le32((ETH_HLEN << 16) | ETH_HLEN);
>  	le->ctrl = 0;
> +	le->length = 0;
>  	le->opcode = OP_TCPSTART | HW_OWNER;

Is this  le->length  thing a separate bugfix?  Or just overly
protective coding (you write the field later again).

> +	/* Don't let it byte swap descriptors in hardware. Clear the bit
> +	 * in case a previous driver have set it
> +	 */
> +	reg = sky2_pci_read32(hw, PCI_DEV_REG2);
> +	reg &= ~PCI_REV_DESC;
> +	sky2_pci_write32(hw, PCI_DEV_REG2, reg);

Probably not needed, the chip gets a full reset at startup (or so
I hope anyway, heh).


Segher

