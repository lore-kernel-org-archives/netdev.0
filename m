From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] sched: use xps information for qdisc NUMA
 affinity
Date: Tue, 30 Nov 2010 10:48:34 -0800 (PST)
Message-ID: <20101130.104834.112604433.davem@davemloft.net>
References: <1290705163.4274.12.camel@localhost>
	<1291054477.3435.1302.camel@edumazet-laptop>
	<AANLkTimU+7aY0DZrnBtL=BsP_qGpCsBw0d4TCKOJSzRL@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	bhutchings@solarflare.com
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50009
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751117Ab0K3SsJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Nov 2010 13:48:09 -0500
In-Reply-To: <AANLkTimU+7aY0DZrnBtL=BsP_qGpCsBw0d4TCKOJSzRL@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Tue, 30 Nov 2010 10:31:48 -0800

> On Mon, Nov 29, 2010 at 10:14 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> I was thinking of using XPS tx_queue->cpu mapping to eventually allocate
>> memory with correct NUMA affinities, for qdisc/class stuff for example.
>>
> 
> An interesting idea, but the real question is can this be used for all
> queue related allocations.  This includes those that drivers allocate
> which are probably done in initialization.

Most drivers do, and all drivers ought to, allocate DMA queues and
whatnot when the interface is brought up.

That solves this particular issue.

For example, drivers/net/niu.c does this by calling
niu_alloc_channels() via niu_open().

The only thing we really can't handle currently is the netdev
itself (and the associated driver private).  Jesse Brandeburg
has been reminding me about this over and over :-)

There might be some things we can even do about that part.  For
example, we can put all of the things the driver touches in the
RX and TX fast paths via indirect pointers and therefore be able
to allocate and reallocate those portions as we want long after
device registry.

Doing the core netdev struct itself is too hard because it sits
in so many tables.
