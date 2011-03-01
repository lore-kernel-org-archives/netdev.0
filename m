From: Thomas Graf <tgraf@infradead.org>
Subject: Re: SO_REUSEPORT - can it be done in kernel?
Date: Tue, 1 Mar 2011 06:07:08 -0500
Message-ID: <20110301110708.GJ9763@canuck.infradead.org>
References: <20110226005718.GA19889@gondor.apana.org.au>
 <20110227110205.GE9763@canuck.infradead.org>
 <20110227110614.GA6246@gondor.apana.org.au>
 <20110228113659.GA20726@gondor.apana.org.au>
 <20110228141322.GF9763@canuck.infradead.org>
 <1298910174.2941.585.camel@edumazet-laptop>
 <20110228163742.GH9763@canuck.infradead.org>
 <1298912869.2941.687.camel@edumazet-laptop>
 <20110301101955.GI9763@canuck.infradead.org>
 <1298975602.3284.13.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>, rick.jones2@hp.com,
	therbert@google.com, wsommerfeld@google.com,
	daniel.baluta@gmail.com, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:47413 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756124Ab1CALHO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2011 06:07:14 -0500
Content-Disposition: inline
In-Reply-To: <1298975602.3284.13.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 01, 2011 at 11:33:22AM +0100, Eric Dumazet wrote:
> > I retested with net-2.6 w/o Herbert's patch:
> > 
> > named -n 1: 36.9kqps
> > named:      16.2kqps
> 
> Thats better ;)
> 
> You could do "cat /proc/net/udp" to check if drops occur on port 53
> socket (last column)
> 
> But maybe your queryperf is limited to few queries in flight (default is
> 20 per queryperf instance) 

I tried -q 10, 20, 30, 50, 100. Starting with 20 I see drops, at q=50
queryperf reports 99% drops.

I also tested again on the Intel machine that did ~650kqps using SO_REUSEPORT.

net-2.6: 106.3kqps, 101.2kqps
net-2.6 lockless udp: 251.7kqps, 250.4kqps

I see drops in both test cases occur so I believe the rate supplied by the
clients is sufficient.

The difference is obvious when looking at top and mpstat:

UDP lockless (250kqps):

Cpu0  : 46.4%us, 28.8%sy,  0.0%ni, 24.8%id,  0.0%wa,  0.0%hi,  0.0%si,  0.0%st
Cpu1  :  2.0%us,  1.3%sy,  0.0%ni,  3.0%id,  0.0%wa,  0.0%hi, 93.6%si,  0.0%st
Cpu2  : 45.9%us, 28.2%sy,  0.0%ni, 25.9%id,  0.0%wa,  0.0%hi,  0.0%si,  0.0%st
Cpu3  : 50.0%us, 21.6%sy,  0.0%ni, 28.4%id,  0.0%wa,  0.0%hi,  0.0%si,  0.0%st
Cpu4  : 45.4%us, 27.8%sy,  0.0%ni, 26.5%id,  0.0%wa,  0.0%hi,  0.3%si,  0.0%st
Cpu5  : 50.7%us, 23.2%sy,  0.0%ni, 26.1%id,  0.0%wa,  0.0%hi,  0.0%si,  0.0%st
Cpu6  : 45.2%us, 28.9%sy,  0.0%ni, 25.9%id,  0.0%wa,  0.0%hi,  0.0%si,  0.0%st
Cpu7  : 50.5%us, 22.0%sy,  0.0%ni, 27.5%id,  0.0%wa,  0.0%hi,  0.0%si,  0.0%st
Cpu8  : 45.3%us, 29.3%sy,  0.0%ni, 25.4%id,  0.0%wa,  0.0%hi,  0.0%si,  0.0%st
Cpu9  : 50.8%us, 20.8%sy,  0.0%ni, 28.3%id,  0.0%wa,  0.0%hi,  0.0%si,  0.0%st
Cpu10 : 46.1%us, 27.8%sy,  0.0%ni, 26.1%id,  0.0%wa,  0.0%hi,  0.0%si,  0.0%st
Cpu11 : 27.2%us, 11.3%sy,  0.0%ni,  3.3%id,  0.0%wa,  0.0%hi, 58.1%si,  0.0%st

05:50:44 AM  CPU    %usr   %nice    %sys %iowait    %irq   %soft  %steal  %guest   %idle
05:50:44 AM  all   23.86    0.00   13.02    0.22    0.00    6.98    0.00    0.00   55.92
05:50:44 AM    0   26.16    0.00   17.20    0.73    0.00    0.30    0.00    0.00   55.61
05:50:44 AM    1    2.36    0.00    2.11    0.70    0.00   51.97    0.00    0.00   42.87
05:50:44 AM    2   25.90    0.00   16.38    0.32    0.00    0.03    0.00    0.00   57.36
05:50:44 AM    3   28.26    0.00   12.73    0.27    0.00    0.02    0.00    0.00   58.73
05:50:44 AM    4   25.63    0.00   16.04    0.13    0.00    0.03    0.00    0.00   58.17
05:50:44 AM    5   28.19    0.00   12.54    0.17    0.00    0.01    0.00    0.00   59.09
05:50:44 AM    6   25.28    0.00   15.21    0.02    0.00    1.95    0.00    0.00   57.54
05:50:44 AM    7   28.34    0.00   12.40    0.10    0.00    0.01    0.00    0.00   59.14
05:50:44 AM    8   25.70    0.00   15.91    0.01    0.00    0.02    0.00    0.00   58.37
05:50:44 AM    9   28.31    0.00   12.56    0.11    0.00    0.01    0.00    0.00   59.01
05:50:44 AM   10   25.85    0.00   15.65    0.01    0.00    0.02    0.00    0.00   58.47
05:50:44 AM   11   16.11    0.00    7.44    0.10    0.00   29.87    0.00    0.00   46.49

SO_REUSEPORT test (doing 640kqps):

Cpu0  : 57.3%us, 26.5%sy,  0.0%ni,  3.3%id,  0.0%wa,  0.0%hi, 12.9%si,  0.0%st
Cpu1  : 25.7%us, 10.0%sy,  0.0%ni,  0.3%id,  0.0%wa,  0.0%hi, 64.0%si,  0.0%st
Cpu2  : 56.3%us, 28.8%sy,  0.0%ni,  3.0%id,  0.0%wa,  0.0%hi, 11.9%si,  0.0%st
Cpu3  : 29.1%us, 10.9%sy,  0.0%ni,  1.3%id,  0.0%wa,  0.0%hi, 58.6%si,  0.0%st
Cpu4  : 57.3%us, 28.5%sy,  0.0%ni,  2.3%id,  0.0%wa,  0.0%hi, 11.9%si,  0.0%st
Cpu5  : 64.8%us, 22.6%sy,  0.0%ni,  3.0%id,  0.0%wa,  0.0%hi,  9.6%si,  0.0%st
Cpu6  : 59.0%us, 26.7%sy,  0.0%ni,  2.7%id,  0.0%wa,  0.0%hi, 11.7%si,  0.0%st
Cpu7  : 64.1%us, 22.3%sy,  0.0%ni,  3.7%id,  0.0%wa,  0.0%hi, 10.0%si,  0.0%st
Cpu8  : 57.6%us, 27.5%sy,  0.0%ni,  3.0%id,  0.0%wa,  0.0%hi, 11.9%si,  0.0%st
Cpu9  : 65.2%us, 22.2%sy,  0.0%ni,  2.3%id,  0.0%wa,  0.0%hi, 10.3%si,  0.0%st
Cpu10 : 56.9%us, 28.3%sy,  0.0%ni,  3.0%id,  0.0%wa,  0.0%hi, 11.8%si,  0.0%st
Cpu11 : 40.2%us, 14.6%sy,  0.0%ni,  2.3%id,  0.0%wa,  0.0%hi, 42.9%si,  0.0%st



