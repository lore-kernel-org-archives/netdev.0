From: Jesse Brandeburg <jesse.brandeburg@intel.com>
Subject: Re: [PATCH 05/10] e1000: Update truesize with the length of the
 packet for packet split
Date: Fri, 14 Apr 2006 16:04:21 -0700 (Pacific Daylight Time)
Message-ID: <Pine.WNT.4.63.0604141555200.2116@jbrandeb-desk.amr.corp.intel.com>
References: <Pine.WNT.4.63.0604141448520.2116@jbrandeb-desk.amr.corp.intel.com>
 <20060414.153219.62111494.davem@davemloft.net>
 <Pine.WNT.4.63.0604141533250.2116@jbrandeb-desk.amr.corp.intel.com>
 <20060414.155129.121789313.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: jesse.brandeburg@intel.com, jgarzik@pobox.com,
	auke-jan.h.kok@intel.com, netdev@vger.kernel.org,
	john.ronciak@intel.com, Jeffrey.t.kirsher@intel.com,
	auke@foo-projects.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmr18.intel.com ([134.134.136.17]:1417 "EHLO
	orsfmr003.jf.intel.com") by vger.kernel.org with ESMTP
	id S1751440AbWDNXFM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Apr 2006 19:05:12 -0400
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20060414.155129.121789313.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 14 Apr 2006, David S. Miller wrote:

> From: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Date: Fri, 14 Apr 2006 15:43:02 -0700 (Pacific Daylight Time)
> 
> > Please help me understand how you think it should work when we have a 
> > device that wants to receive a packet using header in the skb->data, and 
> > application data in the ->frags[]? 
> 
> If you're removing the pages from ->frags[] and you already accounted
> for them in skb->truesize, then yes I guess it could be correct to
> subtract it back out.

they are not accounted for in the skb yet.  the way e1000 works is it 
pre-allocates all its 128 byte receive buffers using skb_alloc, and then 
chains in any pages that are used for receive packets.

> Looking at S2IO it's doing something very wrong with it's modification
> of skb->truesize.  It's not changing the amount of memory allocated
> to an SKB in any way yet it's bumping skb->truesize for some reason.
> That will definitely lead to performance problems.

I can only speak to what e1000 is trying to do. we're technically 
increasing the size of the skb after we've allocated it, so

does nr_frags and frags[] need truesize to be correct?

> That's why generally when we see an skb->truesize modification, it's
> just assumed to be a bug, it's generally not necessary but may be
> so in your e1000 situation here.

cool, I would really prefer that we extend the kernel api's to "do the 
right thing" for receives using frags[]

> Another problem to look out for is that once a socket has a reference
> to an SKB you must never ever modify skb->truesize because doing so
> will break socket memory accounting.  There is exactly one spot in
> the TCP stack where we are able to do this by adjusting the socket
> memory accounting variables carefully in a locked context at the same
> time, but otherwise it's not safe to modify skb->truesize when there
> is an attached socket.

Absolutely!  we're indicating the packet to the stack using netif_rx* (and 
we allocated it), so no socket has the reference until after we change 
truesize.

