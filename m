From: Rick Jones <rick.jones2@hp.com>
Subject: Re: Very low latency TCP for clusters
Date: Mon, 19 Jul 2010 11:13:33 -0700
Message-ID: <4C4495CD.3090605@hp.com>
References: <AANLkTilNmNZbFWS8LF-UHU65QYIC32HZlgVZ7lXJHxPh@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0027.austin.hp.com ([15.216.28.34]:44046 "EHLO
	g1t0027.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760784Ab0GSSNf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jul 2010 14:13:35 -0400
In-Reply-To: <AANLkTilNmNZbFWS8LF-UHU65QYIC32HZlgVZ7lXJHxPh@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tom Herbert wrote:
> We have been looking at best case TCP latencies that might be achieved
> within a cluster (low loss fabric).  The goal is to have latency
> numbers roughly comparable to that which can be produced using RDMA/IB
> in a low latency configuration  (<5 usecs round trip on netperf TCP_RR
> test with one byte data for directly connected hosts as a starting
> point).  This would be without changing sockets API, fabric, and
> preferably not using TCP offload or a user space stack.
> 
> I think there are at least two techniques that will drive down TCP
> latency: per connection queues and polling queues.  Per connection
> queues (supported by device) should eliminate costs of connection
> look-up, hopefully some locking.  Polling becomes viable as core
> counts on systems increase, and burning a few CPUs for networking
> polling on behalf of very low-latency threads would be reasonable.

Likely preaching to the choir - but "just so long as it doesn't give the 
system's coherence fits."  Every once and again there are things stuck into the 
idle loop of various OSes on the premis that it is only burning cycles on that 
idle core, but ends-up trashing cache lines and/or the memory subsystem and so 
drags-down other cores.

Just how close to even 5 usecs/tran is the service demand on a TCP_RR test now? 
  The best I've seen for a 10GbE NIC under SLES11 SP1 (sorry, not latest 
upstream) has been 10-12.6 usec/tran, but the range went as high as 20 or more - 
depended on where netperf/netserver were running relative to the interrupt CPU:

ftp://ftp.netperf.org/netperf/misc/dl380g6_X5560_sles11sp1_ad386a_cxgb3_1.1.3-ko_b2b_to_same_1500mtu_20100602.csv
ftp://ftp.netperf.org/netperf/misc/dl380g6_X5560_sles11sp1_nc550_be2net_2.102.147s_b2b_to_same_1500mtu_20100520.csv

Getting rid of connection lookup and some locking will no doubt be necessary, 
but I suspect there will be a lot more to it as well.  Quite a few sacred 
path-length cows may have to be slaughtered along the way to get the service 
demand << 5 microseconds to allow the < 5 usec RTT.

happy benchmarking,

rick jones
