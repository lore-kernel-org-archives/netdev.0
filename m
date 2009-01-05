From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Fix up truesize after pskb_expand_head() in wireless
 stack
Date: Sun, 04 Jan 2009 22:49:16 -0800 (PST)
Message-ID: <20090104.224916.253586382.davem@davemloft.net>
References: <20090104174339.GX496@one.firstfloor.org>
	<1231090388.3296.17.camel@johannes>
	<20090104184136.GY496@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johannes@sipsolutions.net, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linville@tuxdriver.com
To: andi@firstfloor.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50600
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750904AbZAEGtP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jan 2009 01:49:15 -0500
In-Reply-To: <20090104184136.GY496@one.firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andi Kleen <andi@firstfloor.org>
Date: Sun, 4 Jan 2009 19:41:36 +0100

> On Sun, Jan 04, 2009 at 06:33:08PM +0100, Johannes Berg wrote:
> > On Sun, 2009-01-04 at 18:43 +0100, Andi Kleen wrote:
> > 
> > > > we need to do is figure out is why the skb has a wrong truesize.
> > > 
> > > Because it was expanded without truesize being adjusted (see my
> > > original mail) 
> > 
> > So why is this not making trouble with all the other users?
> 
> I think most adjustments are too small to be noticed. Typically
> they are just for a few bytes in the header. truesize
> is already larger, so it can tolerate some slag.
> 
> I also only see it occasionally (maybe 5-10 times/day) when
> the wireless stack appends a lot of data.
> 
> My proposal would be to include this patch for 2.6.28/2.6.29
> and investigate fixing pskb_expand_head for 2.6.30.

At a minimum you need to add a skb->sk == NULL warn-on and abort path
here, otherwise we will corrupt socket accounting and just explode
somewhere else.  Adding this patch as-is will just introduce a new
bug in exchange for an existing one.

There are cases where the Tx path of the wireless loops back packets
back to the Rx path, and in such cases we certainly could see sockets
attached to the SKB.

And Johannes is right, the other alternative is to orphan the SKB, you
absolutely cannot modify ->truesize blindly.  You can't change the
truesize value if a socket is attached.

There is, as usual, an exception.  TCP does this kind of adjustment,
but it also fixes the socket memory accounting to match.  Only it can
do this because it happens to have the socket locked at the time and
it's running in the proper context.
