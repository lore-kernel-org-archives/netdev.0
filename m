From: David Miller <davem@davemloft.net>
Subject: Re: TX pre-headers...
Date: Fri, 06 Feb 2009 03:11:00 -0800 (PST)
Message-ID: <20090206.031100.230934214.davem@davemloft.net>
References: <20090206.014107.231141422.davem@davemloft.net>
	<OF39F6FFF6.453811EF-ON80257555.003A4714-80257555.003B50C2@smsc.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Steve.Glendinning@smsc.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51945
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755534AbZBFLLE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Feb 2009 06:11:04 -0500
In-Reply-To: <OF39F6FFF6.453811EF-ON80257555.003A4714-80257555.003B50C2@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve.Glendinning@smsc.com
Date: Fri, 6 Feb 2009 10:46:24 +0000

> Many of the usbnet drivers do this as well - for example smsc95xx needs
> either 8 or 12 bytes for its pre-header (depending whether tx checksum
> offload is enabled) and does this in its tx_fixup:
> 
>         if (skb_headroom(skb) < overhead) {
>                 struct sk_buff *skb2 = skb_copy_expand(skb,
>                         overhead, 0, flags);
>                 dev_kfree_skb_any(skb);
>                 skb = skb2;
>                 if (!skb)
>                         return NULL;
>         }
> 
> It would be really good to get rid of these copies.

This is exactly the kind of code that the NIU transmit handler
has.

> Interestingly, this device can change the amount of pre-header space it
> needs if tx checksums are enabled/disabled at runtime.  I guess the
> device would just indicate its worst case requirement at registration.

Right.

> Does this just apply to the routing/bridging case, or can packets
> originating from the host also allocate this extra pre-header?

ARP packets, as one specific case, are still going to trigger that
conditional above and need the copy.

TCP, UDP and others don't trigger this usually only because
they add MAX_TCP_HEADER et al. to all of their allocations
which essentially gives 128 bytes of slack space at the front
of every TX frame from transport protocols.

