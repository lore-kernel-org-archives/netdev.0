From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [PATCH] bonding: send IPv6 neighbor advertisement on failover
Date: Wed, 08 Oct 2008 15:53:23 -0400
Message-ID: <48ED0FB3.7040600@hp.com>
References: <OF4E8F44F8.B83D3AFA-ON882574DC.006B0778-882574DC.006C2639@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Alex Sidorenko <alexandre.sidorenko@hp.com>,
	Brian Haley <brian.haley@hp.com>,
	David Miller <davem@davemloft.net>, fubar@linux.vnet.ibm.com,
	Simon Horman <horms@verge.net.au>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	netdev-owner@vger.kernel.org
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0007.atlanta.hp.com ([15.192.0.44]:26204 "EHLO
	g5t0007.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753848AbYJHTx0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Oct 2008 15:53:26 -0400
In-Reply-To: <OF4E8F44F8.B83D3AFA-ON882574DC.006B0778-882574DC.006C2639@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Stevens wrote:
> Well, I think the reason to send mulitple of them is identical.
> If one is dropped due to network load, it won't happen; sending
> multiple increases the odds of success.
> 
> DAD itself should update caches for neighboring nodes, so I
> guess it makes sense that it isn't sending unsolicited NA's, But
> that makes me think that the DAD retransmit counter is the one
> you want. At least, the part of the DAD retransmit counter that is
> for updating other nodes' caches. :-)

Nope, DAD doesn't trigger a cache update.

> 
> For MLD and IGMP, they were explicit SHOULD's-- I need to have
> a look at ND RFC's to again to see what it says about it.
> 
> I don't think that alone is a reason to block the patch, but I also
> don't think that updating neighbor caches with a new MAC address
> is a unique requirement of bonding.

Well, the mac address is not new since the same address is replicated
across all slaves.  Also, unsolicited NAs are not permitted to change
the neighbor cache entries other then state.  An unsolicited NA will
cause an existing entry to go from REACHABLE to STALE, and nothing else.
So, it use in bonding is really the same as gratuitous ARP.

> Moving an address manually
> ought to be identical in needs and behavior, as well as very-quick
> reboots where the hardware changed. Thus, I don't think the knob
> ought to be specific to bonding. I guess that leads to the suggestion
> that you re-use the DAD counter for that.

Yes, a dad counter could be re-used for this, but in some scenarios
it's overkill.  Frankly, NA itself is an overkill.  There may be
some unintentional consequences to using it that I am looking at now.

> 
> References to MLD now and before are just me looking for an
> analog to what ND should be doing. No new knob is definitely
> required for them, since they already have this support for
> unsolicited reports.
> 

The problem is MLDs are only triggered when you are adding a new IPv6
multicast address.  However, in the bond failover case, we are simply
moving a hardware multicast address from one slave interface to
another while leaving the IPv6 multicast address on the master bond interface.
Thus there is not trigger to fire off an MLD report.

-vlad
