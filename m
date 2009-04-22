From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] myr10ge: again fix lro_gen_skb() alignment
Date: Wed, 22 Apr 2009 18:48:11 +0800
Message-ID: <20090422104811.GA30981@gondor.apana.org.au>
References: <20090415.030213.249634462.davem@davemloft.net> <49E5DABB.9070806@myri.com> <49E64BE4.1050908@myri.com> <20090415.164248.188350673.davem@davemloft.net> <20090416085022.GA19731@gondor.apana.org.au> <49EE1C32.1060202@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, brice@myri.com,
	sgruszka@redhat.com, netdev@vger.kernel.org
To: Andrew Gallatin <gallatin@myri.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:59904 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755594AbZDVKsV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Apr 2009 06:48:21 -0400
Content-Disposition: inline
In-Reply-To: <49EE1C32.1060202@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 21, 2009 at 03:19:14PM -0400, Andrew Gallatin wrote:
>
> So to compare inet_lro and GRO, I'm binding the netserver and device IRQ
> to the same CPU.  When I do this, that CPU is saturated and GRO is
> roughly 17% slower than inet_lro.  For comparison, here are netperf
> results from a fast peer sending to my weak machine (AMD Athlon(tm) 64
> X2 Dual Core Processor 3800+, 2GHz).  First inet_lro:
>
> Recv   Send    Send                          Utilization       Service  
> Demand
> Socket Socket  Message  Elapsed              Send     Recv     Send    Recv
> Size   Size    Size     Time     Throughput  local    remote   local  
> remote
> bytes  bytes   bytes    secs.    10^6bits/s  % S      % S      us/KB   us/KB
>
>  87380  65536  65536    60.02      6631.52   12.45    50.10    0.308  
> 1.238
>
> And now GRO:
>  87380  65536  65536    60.01      5488.99   9.79     50.00    0.292  
> 1.492

I was sure I had tested my case with the IRQs bound (using a cxgb3),
but when I tried it again today GRO was indeed slower (8G vs. 9.4G)!
I fiddled with it all day and couldn't figure out why this was
so.  We weren't spending any more time in the GRO code than LRO,
and in fact we were aggregating more packets with GRO (700k segments
instead of 900k segments).  GRO was also sending a lot less ACKs
than LRO.

It finally dawned on me that my sender had been upgraded from 2.6.18
to 2.6.30-rc1.  Indeed, rebooting into 2.6.18 seems to restore
the balance between GRO and LRO.  I wonder if the ACK reduction
has anything to do with this.

Hopefully tomorrow I'll get my hands onto a myricom and try to
replicate your problem.

In the mean time, can you see if there is any disparity in the
number of aggregated segments and ACKs between GRO and LRO?
netstat -s should be sufficient to measure this (TCP segments
received and sent).

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
