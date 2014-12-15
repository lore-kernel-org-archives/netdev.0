From: Ralf Baechle <ralf@linux-mips.org>
Subject: Re: [PATCH] ioc3: fix incorrect use of htons/ntohs
Date: Mon, 15 Dec 2014 19:14:44 +0100
Message-ID: <20141215181444.GD26674@linux-mips.org>
References: <1417344054-4374-1-git-send-email-LinoSanfilippo@gmx.de>
 <1417406976.7215.126.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Lino Sanfilippo <LinoSanfilippo@gmx.de>, linux-mips@linux-mips.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1417406976.7215.126.camel@decadent.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 01, 2014 at 04:09:36AM +0000, Ben Hutchings wrote:

> >  	/* Same as tx - compute csum of pseudo header  */
> >  	csum = hwsum +
> > -	       (ih->tot_len - (ih->ihl << 2)) +
> > -	       htons((uint16_t)ih->protocol) +
> > +	       (ih->tot_len - (ih->ihl << 2)) + ih->protocol +
> >  	       (ih->saddr >> 16) + (ih->saddr & 0xffff) +
> >  	       (ih->daddr >> 16) + (ih->daddr & 0xffff);
> >
> 
> The pseudo-header is specified as:
> 
>                      +--------+--------+--------+--------+
>                      |           Source Address          |
>                      +--------+--------+--------+--------+
>                      |         Destination Address       |
>                      +--------+--------+--------+--------+
>                      |  zero  |  PTCL  |    TCP Length   |
>                      +--------+--------+--------+--------+
> 
> The current code zero-extends the protocol number to produce the 5th
> 16-bit word of the pseudo-header, then uses htons() to put it in
> big-endian order, consistent with the other fields.  (Yes, it's doing
> addition on big-endian words; this works even on little-endian machines
> due to the way the checksum is specified.)
> 
> The driver should not be doing this at all, though.  It should set
> skb->csum = hwsum; skb->ip_summed = CHECKSUM_COMPLETE; and let the
> network stack adjust the hardware checksum.

Really?  The IOC3 isn't the exactly the smartest NIC around; it does add up
everything and the kitchen sink, that is ethernet headers, IP headers and
on RX the frame's trailing CRC.  All that needs to be subtracted in software
which is what this does.  I think others NICs are all smarted and don't
need this particular piece of magic.

I agree with your other comment wrt. to htons().

  Ralf
