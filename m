From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 11/13] net: mvneta: implement rx_copybreak
Date: Fri, 17 Jan 2014 09:28:13 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D45EA2B@AcuExch.aculab.com>
References: <1389856819-6503-12-git-send-email-w@1wt.eu>
 <063D6719AE5E284EB5DD2968C1650D6D45D866@AcuExch.aculab.com>
 <20140116093640.GA16457@1wt.eu>
 <20140116.114905.1582218754259744747.davem@davemloft.net>
 <20140116200757.GA19969@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"thomas.petazzoni@free-electrons.com"
	<thomas.petazzoni@free-electrons.com>,
	"gregory.clement@free-electrons.com"
	<gregory.clement@free-electrons.com>
To: 'Willy Tarreau' <w@1wt.eu>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:39042 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1750775AbaAQJa3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jan 2014 04:30:29 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 32228-02 for <netdev@vger.kernel.org>;
 Fri, 17 Jan 2014 09:30:26 +0000 (GMT)
In-Reply-To: <20140116200757.GA19969@1wt.eu>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willy Tarreau 
..
> Ah that's an interesting trick! We don't have an IOMMU on this platform
> so the call is cheap. However, it relies on an I/O barrier to wait for
> a cache snoop completion. From what I read, it's not needed when going
> to the device. But when going to the CPU for the Rx case, we're calling
> it for every packet which is counter productive because I'd like to do
> it only once when entering the rx loop and avoid any other call during
> the loop. I measured that I could save 300 ns per packet by doing this
> (thus slightly modifying the DMA API to add a new dma_io_barrier function).
> 
> I think it could be interesting (at least for this platform, I don't know
> if other platforms work with cache coherent DMA which only require to
> verify end of snooping), to have two distinct set of DMA calls, something
> like this :
> 
>     rx_loop(napi, budget)
>     {
>          dma_wait_for_snoop_completion(dev);
>          ...
>          for_each_rx_packet(pkt) {
>              dma_sync_single_range_for_cpu_unless_completed(dev, pkt->addr);
>              /* use packet */
>          }
>     }

You'd need to scan the rx ring for completed entries before the waiting
for the snoop to complete - and then only process those entries.
(Or read a block of rx ring entries...)

Otherwise you might try to process a rx that finished after you
waited for the snoop to complete.

	David
