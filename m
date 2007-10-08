From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] rtnl: Simplify ASSERT_RTNL
Date: Mon, 08 Oct 2007 06:40:54 +0200
Message-ID: <4709B4D6.3040805@trash.net>
References: <E1IbTz0-0000FK-00@gondolin.me.apana.org.au> <46FE7019.4030705@trash.net> <20070930002421.GA7502@gondor.apana.org.au> <46FFC512.9060101@trash.net> <20071002092819.GA29824@gondor.apana.org.au> <alpine.DEB.0.9999.0710021658100.12705@x2> <20071003060603.GA6457@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, davem@davemloft.net,
	netdev@vger.kernel.org, oliver@neukum.name,
	linux-usb-devel@lists.sourceforge.net
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:51182 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750792AbXJHEnP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Oct 2007 00:43:15 -0400
In-Reply-To: <20071003060603.GA6457@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> On Tue, Oct 02, 2007 at 05:29:11PM +0200, Patrick McHardy wrote:
> 
>>I think this doesn't completely fix it, when dev_unicast_add is
>>interrupted by dev_mc_add before the unicast changes are performed,
>>they will get committed in the dev_mc_add context, so we might still
>>call change_flags with BH disabled. Taking the TX lock around the
>>dev->uc_count and dev->uc_promisc checks and changes in __dev_set_rx_mode
>>should fix this.
> 
> 
> Good catch.  Digging back in history it seems that you added
> the change_rx_flags function so that the driver didn't have to
> do it under TX lock, right?


Yes, and to make sure the RTNL is held.

> The problem with this is that the stack can now call
> change_rx_flags and set_multicast_list simultaneously
> which presents a potential headache for the driver
> author (if they were to use change_rx_flags).


The change_rx_flags function was intended to be used by software
devices that want to synchronize flags to a different device,
in which case they shouldn't interfere since set_multicast_list
would only be used for the multicast list and not the flags.

> It seems to me what we could do is in fact separate out the
> part that adds the address and the part that syncs it with
> hardware.


That sounds like a really good idea to get rid of all the
confusion.

> That way we can call the hardware from a process context later
> and use the RTNL to guarantee that we only enter the driver
> once.
> 
> So dev_mc_add would look like:
> 
> 1) Hold some form of lock L.
> 2) Modify mc list A (a copy of the current mc list).
> 3) Drop lock.
> 4) Schedule an update to the hardware.
> 
> The update to the hardware would look lie:
> 
> 1) Hold RTNL.
> 2) Hold lock L.
> 3) Copy list A to list B (B would be our current list).
> 4) Drop lock L.
> 5) Call the hardware.
> 6) Drop RTNL.
> 
> For compatibility, set_multicast_list would still be invoked
> under the TX lock while set_rx_mode would do exactly the same
> thing but would only hold the RTNL.
> 
> What do you think about this approach?


Sounds great :)
