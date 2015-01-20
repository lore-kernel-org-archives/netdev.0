From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 3/3] netlink: Lock out table resizes while dumping
 Netlink sockets
Date: Tue, 20 Jan 2015 15:21:49 +0000
Message-ID: <20150120152149.GA3012@acer.localdomain>
References: <cover.1421759056.git.tgraf@suug.ch>
 <e164edeacaeffee43be64d4ed6a5b5e7e8923bd1.1421759056.git.tgraf@suug.ch>
 <20150120143154.GR14883@acer.localdomain>
 <20150120145551.GH20315@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, herbert@gondor.apana.org.au,
	paulmck@linux.vnet.ibm.com, ying.xue@windriver.com,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:45348 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751801AbbATPVz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jan 2015 10:21:55 -0500
Content-Disposition: inline
In-Reply-To: <20150120145551.GH20315@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 20.01, Thomas Graf wrote:
> On 01/20/15 at 02:31pm, Patrick McHardy wrote:
> > On 20.01, Thomas Graf wrote:
> > > Lock out table resizes while dumping Netlink sockets to user space.
> > > This keeps disruptions to a minimum for readers which don't handle
> > > the NLM_F_DUMP_INTR flag.
> > 
> > This doesn't lock them out for the duration of the entire dump of
> > course, so the benefit seems rather small. Still with this patch,
> > they will need to handle NLM_F_DUMP_INTR or will get unpredictable
> > behaviour, in which case I'd think it makes more sense to not even
> > try this, all it does is hide parts of the brokenness.
> 
> If it would lock out the resize for the entire dump I would not have
> done patches 1 and 2 ;-)
> 
> I does provide better behaviour if the whole dump fits into a single
> buffer or if it fits into 2 buffers and we are already dumping into
> the 2nd buffer when the resize occurs. Otherwise we will see resizes
> and thus tons of duplicates even in those scenarios even if no insert
> or removal occurs in parallel.
> 
> In the case of Netlink diag that should be typical case. Most systems
> will not have 1000s of Netlink sockets in parallel.

I think its preferrable to make the need to handle NETLINK_F_DUMP_INTR
as noticable as possible and not hide it. Silent failure is the worst
kind of failure.

> > An alternative would be to set a flag in ht when a dump begins that
> > indicates to skip resizing operations and on the end of the dump
> > perform any resizing operations that might be necessary. Herbert
> > disagrees though and he might be right.
> 
> I don't like the flag as it prevents resizes (and possibly rehashes
> further down the road) for a long period of time. The hashtable
> becomes attackable.

Yeah. The point could be made that this is a regression though. We didn't
require userspace to deal with interruptions before, and the behaviour
was well defined and acceptable for most cases, its not anymore.

So I think it should be handled by the kernel, without changes to
userspace.
