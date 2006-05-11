From: "David S. Miller" <davem@davemloft.net>
Subject: Re: Initial benchmarks of some VJ ideas [mmap memcpy vs
 copy_to_user].
Date: Thu, 11 May 2006 00:07:21 -0700 (PDT)
Message-ID: <20060511.000721.60889163.davem@davemloft.net>
References: <20060508122418.GA22554@2ka.mipt.ru>
	<20060510.125848.44052388.davem@davemloft.net>
	<20060511064037.GB22770@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, caitlinb@broadcom.com, kelly@au1.ibm.com,
	rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:21124
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S965180AbWEKHMC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 May 2006 03:12:02 -0400
To: johnpol@2ka.mipt.ru
In-Reply-To: <20060511064037.GB22770@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Date: Thu, 11 May 2006 10:40:37 +0400

> > It is absolutely necessary to find ways to get rid of these layering
> > costs.  "Layering is how you design networking protocols, not how you
> > implement them."
> 
> If I provide a patch which will allow to mark special socket as
> no-protocol-and-any-upper-layer-lookup, but instead process skb->data
> (like copying to userspace, or just allow recv() to return without any
> copy) and performance will not differ from what we have with layers, 
> will it justify that not abstract cache trashing and lookup split into
> socket/route are not the problem?
> 
> Or have you switched from engineering to researching mode? :)

You test with single socket and single source ID, what do you expect?
Everything is hot in the cache, as expected.

It is not research, I did put cycle counter sampling all over these
spots on sparc64 a long time ago just to familiarize myself with where
cpu spends most of it's time in softint processing when there are lots
of sockets and unique remote addresses.

And most of the time from netif_receive_skb() to the meat of
{udp,tcp}_rcv() is touching the routing cache and socket demux hash
tables.  Add bonus costs to netfilter if that is enabled too.  Once
you are past that point, for TCP, tcp_ack() is the primary cpu cycle
eater.

You can test with single stream, but then you are only testing
in-cache case.  Try several thousand sockets and real load from many
unique source systems, it becomes interesting then.

>From profiles of heavily used web server, what shows up is bulk of cpu
being in socket demux and tcp_ack().  Next bubble is routing cache.
I have not seen good profiles from a heavy web server employing any
real use of netfilter, that would be interesting as well.
