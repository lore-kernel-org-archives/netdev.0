From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: can we reuse an skb
Date: Sat, 20 Jun 2009 12:00:57 +0400
Message-ID: <20090620080057.GA16143@ioremap.net>
References: <962874.62146.qm@web94813.mail.in2.yahoo.com> <4A3BC326.4090203@hp.com> <20090619.162957.156347025.davem@davemloft.net> <1f808b4a0906192054k6182ac2fh1618f0e630033518@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, rick.jones2@hp.com,
	radhamohan_ch@yahoo.com, netdev@vger.kernel.org
To: Peter Chacko <peterchacko35@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from genesysrack.ru ([195.178.208.66]:58025 "EHLO tservice.net.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752885AbZFTIBL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 20 Jun 2009 04:01:11 -0400
Content-Disposition: inline
In-Reply-To: <1f808b4a0906192054k6182ac2fh1618f0e630033518@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jun 20, 2009 at 09:24:52AM +0530, Peter Chacko (peterchacko35@gmail.com) wrote:
> Assume that we have n-cores capable of processing packet at the same
> time. if we trade off memory for computing, why don't we pre-allocate
> "n" dedicated skb buffers regardless of the size of each packet, but
> just as big as the size of the MTU itself.(forget JUMBO packet for
> now).(  today, dev_alloc_skb() allocate based on the packet len, which
> is memory usage optimized.).
> 
> each dedicated memory buffer is now a per-CPU/thread data structure.
> 
> In the  IO stack world , we have buffer cache, identified by buffer
> headers. That design was conceived so early as each block level write
> was typically 512 bytes and same for all blocks. why don't we adapt
> that into network stack ?

And page cache has ugly buffer_head strucures to point partially updated
blocks within the page, while block IO has to perform read-modify-write
cycles when it updates less than a single block, which is rather costly,
especially on big-sized blocks.

Consider 100-byte writes and 1500 MTU (or consider 9k MTU for a moment)
- this is a huge overhead and if socket queue is 10 MB for example, you
will waste 140 MB of RAM or have miserable performance if the whole 1500
bytes are accounted into socket buffer while only 100 bytes are used.

For those who wants to play with skb recycling - just implement own pool
of skbs and provide private destructor, which will requeue the same
object into private pool. Not sure this will work any bit faster than
existing scheme though if proper memory accounting is implemented.

-- 
	Evgeniy Polyakov
