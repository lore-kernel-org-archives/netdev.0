From: "Ravinandan Arakali" <ravinandan.arakali@neterion.com>
Subject: RE: H/W requirements for NETIF_F_HW_CSUM
Date: Wed, 26 Jul 2006 12:34:28 -0700
Message-ID: <006b01c6b0ea$82ed3f60$4510100a@pc.s2io.com>
References: <20060726121627.724c6652@localhost.localdomain>
Reply-To: <ravinandan.arakali@neterion.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <Steve.Whitaker@neterion.com>,
	<Mike.Doyle@neterion.com>, <Andrew.LaCroix@neterion.com>,
	<Ananda.Raju@neterion.com>, <dave.fenton@neterion.com>,
	"'Leonid. Grossman \(E-mail\)'" <leonid.grossman@neterion.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:28854 "EHLO
	barracuda.mail.s2io.com") by vger.kernel.org with ESMTP
	id S1751774AbWGZTfV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Jul 2006 15:35:21 -0400
To: "'Stephen Hemminger'" <shemminger@osdl.org>
In-Reply-To: <20060726121627.724c6652@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Steve,
Thanks for the response.
Pls see my comments below.

> -----Original Message-----
> From: Stephen Hemminger [mailto:shemminger@osdl.org]
> Sent: Wednesday, July 26, 2006 12:16 PM
> To: ravinandan.arakali@neterion.com
> Cc: netdev@vger.kernel.org; Steve.Whitaker@neterion.com;
> Mike.Doyle@neterion.com; Andrew.LaCroix@neterion.com;
> Ananda.Raju@neterion.com; dave.fenton@neterion.com; Leonid. Grossman
> (E-mail)
> Subject: Re: H/W requirements for NETIF_F_HW_CSUM
> 
> 
> On Wed, 26 Jul 2006 10:28:00 -0700
> "Ravinandan Arakali" <ravinandan.arakali@neterion.com> wrote:
> 
> > Hello,
> > Our current NIC does not provide the actual checksum value 
> on receive path.
> > Hence we only claim NETIF_F_IP_CSUM instead of the more general
> > NETIF_F_HW_CSUM.
> > 
> > To support this in a future adapter, we would like to know 
> what exactly are
> > the requirements (on both Rx and Tx )to claim NETIF_F_HW_CSUM ?
> 
> If you set NETIF_F_HW_CSUM, on transmit the adapter if 
> ip_summed is set
> will be handed an unchecksummed frame with the offset to 
> stuff the checksum at.
> Only difference between NETIF_F_HW_CSUM and NETIF_F_IP_CSUM 
> is that IP_CSUM
> means the device can handle IPV4 only.

Since our adapter does IPv4 and IPv6 checksum, do we then satisfy
the requirements to claim NETIF_F_HW_CSUM on Tx side ?
Also, for non-TSO, we can stuff the checksum at specified offset
in skb. What about TSO frames ?

> 
> NETIF_F_HW_CSUM has no impact on receive. The form of receive 
> checksumming format
> is up to the device. It can either put one's complement in 
> skb->csum and
> set ip_summed to CHECKSUM_HW or if device only reports 
> checksum good then
> set CHECKSUM_UNNECESSARY.

The reason for thinking that NETIF_F_HW_CSUM and CHECKSUM_UNNECESSARY
don't go together was a comment from Jeff way back in '04 when our 
driver was initially submitted. Quoting from that mail:

"You CANNOT use NETIF_F_HW_CSUM, when your hardware does not provide the 
checksum value.  You must use NETIF_F_IP_CSUM.  Your use of 
NETIF_F_HW_CSUM + CHECKSUM_UNNECESSARY is flat out incorrect."

> 
> Several are a couple of subtleties to the receive processing:
> * Meaning of ip_summed changes from tx to rx path and that 
> has to be handled
>   in code that does forwarding like bridges.
> * If device only reports checksum okay vs bad. The packets 
> marked bad might
>   be another protocol, so should be passed up with 
> CHECKSUM_NONE and let any
>   checksum errors get detected in software.
> * Checksum HW on receive should work better since then IPV6 
> and nested protocols like
>   VLAN's can be handled.
> 
> > Following are some specific questions:
> > 1. On Tx, our adapter supports checksumming of TCP/UDP over 
> IPv4 and IPv6.
> > This computation is TCP/UDP specific. Does the checksum 
> calculation need to
> > be more generic ? Also, skbuff.h says that the checksum 
> needs to be placed
> > at a specific location(skb->h.raw+skb->csum). I guess this 
> means the adapter
> > needs to pass back the checksum to host driver after 
> transmission. What
> > happens in case of TSO ?
> > 2. On Rx, is it suffficient if we place the L4 checksum in 
> skb->csum ? What
> > about L3 checksum ?
> > 
> 
> The L3 checksum (IP) is always computed. Since the header is 
> in CPU cache anyway
> it is faster that way.
