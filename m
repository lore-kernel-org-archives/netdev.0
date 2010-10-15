From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH net-next] net: allocate skbs on local node
Date: Fri, 15 Oct 2010 11:57:42 -0500 (CDT)
Message-ID: <alpine.DEB.2.00.1010151153300.24683@router.home>
References: <1286838210.30423.128.camel@edumazet-laptop>  <1286839363.30423.130.camel@edumazet-laptop>  <1286859925.30423.184.camel@edumazet-laptop>  <20101011230322.f0f6dd47.akpm@linux-foundation.org>  <AANLkTin8FczYpPvi79w7iuKOZz3uZtYFfTPitAgQFxzD@mail.gmail.com>
 <1287072352.2712.84.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Tom Herbert <therbert@google.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Michael Chan <mchan@broadcom.com>,
	Eilon Greenstein <eilong@broadcom.com>,
	Christoph Hellwig <hch@lst.de>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	David Rientjes <rientjes@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp109.prem.mail.ac4.yahoo.com ([76.13.13.92]:25221 "HELO
	smtp109.prem.mail.ac4.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1756513Ab0JOQ5q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Oct 2010 12:57:46 -0400
In-Reply-To: <1287072352.2712.84.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 14 Oct 2010, Eric Dumazet wrote:

> > Some results running netper TCP_RR test with 200 instances, 1 byte
> > request and response on 16 core AMD using bnx2x with one 16 queues,
> > one for each CPU.
> >
> > SLAB
> >
> > Without patch 553570 tps at 86% CPU
> > With patch 791883 tps at 93% CPU
> >
> > SLUB
> >
> > Without patch 704879 tps at 95% CPU
> > With patch 775278 tps at 92% CPU

Shows one basic difference between SLAB and SLUB: SLAB always needs to go
the slow path when allocating from other nodes. SLUB allows other nodes to
use the fast path. First alloc will be slow but it will switch the "local
queue" to the new node ("queue" switching fast because the queue is
simply a linked list from the page struct of objects within the page).
Second and following access will be fast and coming from that node.

But the requirement that objects on the per page queue are only within the
page also limits the size of the queue and often requires more slow path
use on free....


