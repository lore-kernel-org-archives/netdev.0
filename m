From: Steve.Glendinning@smsc.com
Subject: Re: TX pre-headers...
Date: Fri, 6 Feb 2009 10:46:24 +0000
Message-ID: <OF39F6FFF6.453811EF-ON80257555.003A4714-80257555.003B50C2@smsc.com>
References: <20090206.014107.231141422.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.smsc.com ([170.129.50.11]:1894 "EHLO smsc.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753717AbZBFKsR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Feb 2009 05:48:17 -0500
In-Reply-To: <20090206.014107.231141422.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote on 06/02/2009 09:41:07:
> 
> Some NIC hardware wants a pre-header pushed in front of the packet
> data on transmit.
> 
> When routing or bridging this will cause a reallocation of skb->data
> on every packet forwarded because there will only be NET_IP_ALIGN
> space reserved at the head by the device receive path.
> 
> NIU is one such NIC and I only noticed this because of some things I
> saw in some of Robert Olsson's routing stress test oprofile dumps.

Many of the usbnet drivers do this as well - for example smsc95xx needs
either 8 or 12 bytes for its pre-header (depending whether tx checksum
offload is enabled) and does this in its tx_fixup:

        if (skb_headroom(skb) < overhead) {
                struct sk_buff *skb2 = skb_copy_expand(skb,
                        overhead, 0, flags);
                dev_kfree_skb_any(skb);
                skb = skb2;
                if (!skb)
                        return NULL;
        }

It would be really good to get rid of these copies.

Interestingly, this device can change the amount of pre-header space it
needs if tx checksums are enabled/disabled at runtime.  I guess the
device would just indicate its worst case requirement at registration.

Does this just apply to the routing/bridging case, or can packets
originating from the host also allocate this extra pre-header?

Steve
