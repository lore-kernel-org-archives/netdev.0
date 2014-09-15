From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: DSA and skb->protocol
Date: Mon, 15 Sep 2014 20:32:46 +0200
Message-ID: <20140915183246.GG4255@lunn.ch>
References: <20140914153751.GA28585@lunn.ch>
 <5417223D.6070408@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Lunn <andrew@lunn.ch>, f.fainelli@gmail.com,
	seugene@marvell.com, netdev@vger.kernel.org
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:50240 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754399AbaIOSjZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Sep 2014 14:39:25 -0400
Content-Disposition: inline
In-Reply-To: <5417223D.6070408@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > making me think it is not actually needed to change
> > skb->protocol. When i remove this from edsa_xmit(), the warning goes
> > away and networking seems to work O.K.
> > 
> > Is this the right fix? Should we remove this setting of skb->protocol
> > in the other dsa xmit functions?
> > 
> > Thanks
> > 	Andrew
> > 
> 
> No, if anything they should all be using ETH_P_XDSA to indicate the
> protocol between the switch and the host network interface.  When you
> triggered this issue did you by any chance change some of the settings
> on the host netdev for the switch?

This is the first time i've used DSA. I'm adding support for a new
board which has a switch. So it is not too easy for me to go backwards
and see when the WARNING started appearing.
 
> The fix would probably be to update skb_network_protocol so that it can
> sort out ETH_P_XDSA tags and get the Ethertype from the frame.

I'm not sure how easy getting the correct Ethertype from the frame
is. The DSA tag can go in different places, depending on what tagging
protocol is used.

For EDSA, which is what the board/switch i'm using uses, the tag is
placed between the source address and the ethertype. If the frame is
not an 802.1q, the tag is 8 bytes. If it is 802.1q the tag is 6
bytes. The first 2 bytes are an Ethertype, indicating EDSA is being
used. You need to look at byte 4 of the tag to know how long it is, in
order to find the second Ethertype in the frame, for the SDU.

Similarly DSA tagging, is either 2 bytes or 4 bytes, and you need to
look at byte 0 of the tag to determine its length. There is no
Ethertype to know that DSA is being used.

Trailer tagging is different. It places 4 bytes at the end of the
frame, applying padding for frames < 60 bytes. The Ethertype is not
touched.

Florian recently added brcm tagging. This again goes between the
Source address and the Ethertype, and does not define a valid
Ethertype.

So unless you know what tagging protocol is in use, it is very hard to
peer inside the frame to work out what the real SDU Ethertype is. So
it seems easier to just pass it in skb->protocol.

   Andrew
