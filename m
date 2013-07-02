From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [RFC ] netlink: limit large vmalloc() based skbs to
 NETLINK_NETFILTER
Date: Wed, 3 Jul 2013 01:11:05 +0200
Message-ID: <20130702231105.GA8178@localhost>
References: <20130702215015.GA1979@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	Dave Jones <davej@redhat.com>
To: Sebastian Andrzej Siewior <sebastian@breakpoint.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:56166 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751312Ab3GBXLR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Jul 2013 19:11:17 -0400
Content-Disposition: inline
In-Reply-To: <20130702215015.GA1979@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 02, 2013 at 11:50:15PM +0200, Sebastian Andrzej Siewior wrote:
> Since commit c05cdb1b ("netlink: allow large data transfers from
> user-space") the large skbs are allocated via vmalloc(). Trinity
> triggered this in response:
> 
> | BUG: unable to handle kernel paging request at ffffc900001bf001
> | IP: [<ffffffff8135270a>] skb_clone+0x1a/0xa0
> | Call Trace:
> |  [<ffffffff813cb107>] nl_fib_input+0x37/0x230
> |  [<ffffffff8142c9b2>] ? _raw_read_unlock+0x22/0x40
> |  [<ffffffff81380b1a>] netlink_unicast+0x13a/0x1f0
> |  [<ffffffff81380ef7>] netlink_sendmsg+0x327/0x420
> 
> The problem is that the vmalloc() based skb ends exactly at size (where
> ->end is pointing) and skb_shinfo() starts past ->end where we have our
> guard page and hence we BUG().
> The question is should we fix this or forbid the skb_clone(). Fixing this
> behaviour is tricky because even after we add space for struct
> skb_shared_info we release the memory from the destructor so once the
> first skbs is gone, the memory in the clone is invalid.
> The other case where skb_clone() is used is when we have mutltiple
> destinations.
> Since I assume the initial target was to extend the size for
> NETLINK_NETFILTER this patch limits to this target only and with single
> destination.
> Is this okay?

Did you notice this patch?

3a36515 netlink: fix splat in skb_clone with large messages

Regards.
