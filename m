From: "Leonid Grossman" <leonid.grossman@neterion.com>
Subject: RE: [PATCH] TSO Reloaded
Date: Fri, 6 May 2005 21:48:51 -0700
Message-ID: <200505070448.j474mqVG021788@guinness.s2io.com>
References: <20050506123411.7073cf15.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "'David S. Miller'" <davem@davemloft.net>
In-Reply-To: <20050506123411.7073cf15.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: netdev-bounce@oss.sgi.com [mailto:netdev-bounce@oss.sgi.com] On
> Behalf Of David S. Miller
> Sent: Friday, May 06, 2005 12:34 PM
> To: Leonid Grossman
> Cc: netdev@oss.sgi.com
> Subject: Re: [PATCH] TSO Reloaded
> 
> On Fri, 6 May 2005 07:09:17 -0700
> "Leonid Grossman" <leonid.grossman@neterion.com> wrote:
> 
> > Our ASIC supports ipv6 CSUM and TSO (and header splitting) even if
> extension
> > headers are present, but I suspect the majority ipv6-capable NICs will
> not
> > implement this; the stack needs to query NIC header-processing
> capabilities
> > (for both CSUM and TSO) and act accordingly.
> 
> Any particular reason for adding protocol specific checksumming
> instead of a protocol agnostic one?  That is what NETIF_F_CSUM_HW
> represents, and we were hoping NIC vendors would do.

I guess some NIC vendors choose to support a single pass/fail flag (rather
than a 16-bit checksum field), because increasing the size of receive
descriptors may not come for free.

Our older card supports NETIF_F_IP_CSUM only, the newer card can support
NETIF_F_HW_CSUM so we will probably change the driver at some point.

> 
> If you supported this, then you wouldn't need to keep adding checksum
> support for new protocols, NETIF_F_CSUM_HW works for anything which
> uses a 16-bit 2's complement checksum stuffed to an arbitray 16-bit
> location.  The chip merely needs to:
> 
> 1) calculate a 2's complement sum starting at the offset:
>      (skb->h.raw - skb->data)
>    into the packet, to the end.
> 2) Place the 16-bit result at offset:
>      (skb->h.raw + skb->csum) - skb->data
> 
> and that's it.  This single checksumming engine works for ipv4 as well.
> 
> See drivers/net/sunhme.c:happy_meal_start_xmit() and drivers/net/sungem.c:
> gem_start_xmit() for two example implementations.

Thanks for the pointer!
Leonid

> 
> I can't belive Sun understood this years ago and yet they are pretty
> much the only vendor who has made networking cards supporting this
> scheme.  Probably the Microsoft's NDIS driver specification is to blame :-
> /
