From: Matt Wilson <msw@amazon.com>
Subject: Re: [PATCH net-next] pkt_sched: fq: Fair Queue packet scheduler
Date: Thu, 29 Aug 2013 12:19:40 -0700
Message-ID: <20130829191938.GA18645@u109add4315675089e695.ant.amazon.com>
References: <1377400082.8828.100.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-fw-2101.amazon.com ([72.21.196.25]:16441 "EHLO
	smtp-fw-2101.amazon.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754051Ab3H2TUS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Aug 2013 15:20:18 -0400
Content-Disposition: inline
In-Reply-To: <1377400082.8828.100.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Aug 24, 2013 at 08:08:02PM -0700, Eric Dumazet wrote:
[...] 
> Attempts have been made to add TCP pacing in TCP stack, but this
> seems to add complex code to an already complex stack.
> 
> TCP pacing is welcomed for flows having idle times, as the cwnd
> permits TCP stack to queue a possibly large number of packets.
> 
> This removes the 'slow start after idle' choice, hitting badly
> large BDP flows.
> 
> Nicely spaced packets : here interface is 10Gbit, but flow bottleneck is
> ~100Mbit

This is great. I just gave this a try in a real-world scenario where
TCP pacing (implemented in the TCP stack) has provided a significant
performance improvement.

# netperf -v 2 -H 10.162.184.110 
TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 10.162.184.110 (10.162.184.110) port 0 AF_INET
Recv   Send    Send                          
Socket Socket  Message  Elapsed              
Size   Size    Size     Time     Throughput  
bytes  bytes   bytes    secs.    10^6bits/sec  

 87380  16384  16384    10.20      85.25   

Alignment      Offset         Bytes    Bytes       Sends   Bytes    Recvs
Local  Remote  Local  Remote  Xfered   Per                 Per
Send   Recv    Send   Recv             Send (avg)          Recv (avg)
    8       8      0       0 1.087e+08  16385.34      6635   14583.07   7455

Maximum
Segment
Size (bytes)
  1424

# tc qdisc add dev eth0 root fq
# netperf -v 2 -H 10.162.184.110
TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 10.162.184.110 (10.162.184.110) port 0 AF_INET
Recv   Send    Send                          
Socket Socket  Message  Elapsed              
Size   Size    Size     Time     Throughput  
bytes  bytes   bytes    secs.    10^6bits/sec  

 87380  16384  16384    10.12     354.79   

Alignment      Offset         Bytes    Bytes       Sends   Bytes    Recvs
Local  Remote  Local  Remote  Xfered   Per                 Per
Send   Recv    Send   Recv             Send (avg)          Recv (avg)
    8       8      0       0 4.488e+08  16384.08     27394   15526.00  28908

Maximum
Segment
Size (bytes)
  1424

Is there an iproute2 patch? I don't think I've seen one yet.

As far as this patch is concerned, I like what I see so far from
performance. Are there concerns about boundary crossing through
teaching the scheduler about things like the rate limit, special
handling of TCP retransmits, etc?

--msw
