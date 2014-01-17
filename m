From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH 11/13] net: mvneta: implement rx_copybreak
Date: Fri, 17 Jan 2014 10:48:04 +0100
Message-ID: <20140117094804.GB23276@1wt.eu>
References: <1389856819-6503-12-git-send-email-w@1wt.eu> <063D6719AE5E284EB5DD2968C1650D6D45D866@AcuExch.aculab.com> <20140116093640.GA16457@1wt.eu> <20140116.114905.1582218754259744747.davem@davemloft.net> <20140116200757.GA19969@1wt.eu> <063D6719AE5E284EB5DD2968C1650D6D45EA2B@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"thomas.petazzoni@free-electrons.com"
	<thomas.petazzoni@free-electrons.com>,
	"gregory.clement@free-electrons.com"
	<gregory.clement@free-electrons.com>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:55543 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751051AbaAQJsK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Jan 2014 04:48:10 -0500
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D45EA2B@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 17, 2014 at 09:28:13AM +0000, David Laight wrote:
> From: Willy Tarreau 
> ..
> > Ah that's an interesting trick! We don't have an IOMMU on this platform
> > so the call is cheap. However, it relies on an I/O barrier to wait for
> > a cache snoop completion. From what I read, it's not needed when going
> > to the device. But when going to the CPU for the Rx case, we're calling
> > it for every packet which is counter productive because I'd like to do
> > it only once when entering the rx loop and avoid any other call during
> > the loop. I measured that I could save 300 ns per packet by doing this
> > (thus slightly modifying the DMA API to add a new dma_io_barrier function).
> > 
> > I think it could be interesting (at least for this platform, I don't know
> > if other platforms work with cache coherent DMA which only require to
> > verify end of snooping), to have two distinct set of DMA calls, something
> > like this :
> > 
> >     rx_loop(napi, budget)
> >     {
> >          dma_wait_for_snoop_completion(dev);
> >          ...
> >          for_each_rx_packet(pkt) {
> >              dma_sync_single_range_for_cpu_unless_completed(dev, pkt->addr);
> >              /* use packet */
> >          }
> >     }
> 
> You'd need to scan the rx ring for completed entries before the waiting
> for the snoop to complete - and then only process those entries.
> (Or read a block of rx ring entries...)
> 
> Otherwise you might try to process a rx that finished after you
> waited for the snoop to complete.

That's already the case, the number of descs to use is computed first
thing when entering the function. That's why it's already safe.

Willy
