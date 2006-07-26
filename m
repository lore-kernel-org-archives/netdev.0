From: David Miller <davem@davemloft.net>
Subject: Re: H/W requirements for NETIF_F_HW_CSUM
Date: Wed, 26 Jul 2006 14:07:38 -0700 (PDT)
Message-ID: <20060726.140738.39464304.davem@davemloft.net>
References: <20060726121627.724c6652@localhost.localdomain>
	<006b01c6b0ea$82ed3f60$4510100a@pc.s2io.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, netdev@vger.kernel.org,
	Steve.Whitaker@neterion.com, Mike.Doyle@neterion.com,
	Andrew.LaCroix@neterion.com, Ananda.Raju@neterion.com,
	dave.fenton@neterion.com, leonid.grossman@neterion.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:44761
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751159AbWGZVHZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Jul 2006 17:07:25 -0400
To: ravinandan.arakali@neterion.com
In-Reply-To: <006b01c6b0ea$82ed3f60$4510100a@pc.s2io.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Ravinandan Arakali" <ravinandan.arakali@neterion.com>
Date: Wed, 26 Jul 2006 12:34:28 -0700

> "You CANNOT use NETIF_F_HW_CSUM, when your hardware does not provide the 
> checksum value.  You must use NETIF_F_IP_CSUM.  Your use of 
> NETIF_F_HW_CSUM + CHECKSUM_UNNECESSARY is flat out incorrect."

NETIF_F_HW_CSUM means, on transmit, that you can handle being given a
skb with ip_summed set to CHECKSUM_HW.

When you see CHECKSUM_HW on transmit, this means that skb->csum holds
the offset into the packet where you should place the computed
checksum.  Actually you are given two packet offsets, defined as
follows:

	csum_start_off = (u32) (skb->h.raw - skb->data);
	csum_stuff_off = (u32) ((skb->h.raw + skb->csum) - skb->data);

The first value is where you should start calculating the two's
complement checksum, and the second value is the offset into the
packet where you should place the 16-bit checksum after you have
folded it.

The thing I think you are misunderstanding is that in order to support
NETIF_F_HW_CSUM you must be able to compute the two's complement over
_ARBITRARY_ portions of the packet and be able to place the 16-bit
checkum you compute at _ARBITRARY_ locations in the packet.

Therefore, saying things like "our card can only handle IPV4 and IPV6"
have no sense when discussing CHECKSUM_HW.  The algorithm of
CHECKSUM_HW on transmit is generic, the protocol in use doesn't
matter, it does a generic two's complement checksum over some section
of the packet data.  This allows to handle arbitrary protocols that
make use of two's complement checksums, not just "ipv4 and ipv6".

On receive, if you want to set CHECKSUM_HW, the card must compute the
two's complement checksum over the entire packet data and place it
in skb->csum.

