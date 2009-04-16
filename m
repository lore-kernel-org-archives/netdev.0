From: Rick Jones <rick.jones2@hp.com>
Subject: Re: Network latency regressions from 2.6.22 to 2.6.29
Date: Thu, 16 Apr 2009 13:05:01 -0700
Message-ID: <49E78F6D.1070603@hp.com>
References: <alpine.DEB.1.10.0904161151330.13531@qirst.com>	<49E76906.2060205@hp.com> <alpine.DEB.1.10.0904161504090.15835@qirst.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Christoph Lameter <cl@linux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0028.austin.hp.com ([15.216.28.35]:2271 "EHLO
	g1t0028.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757763AbZDPUFE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2009 16:05:04 -0400
In-Reply-To: <alpine.DEB.1.10.0904161504090.15835@qirst.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Christoph Lameter wrote:
> On Thu, 16 Apr 2009, Rick Jones wrote:
> 
> 
>>Does udpping have a concept of service demand a la netperf?  That could help
>>show how much was code bloat vs say some tweak to interrupt coalescing
>>parameters in the NIC/driver.
> 
> 
> No. What does service on demand mean? The ping pong tests are very simple
> back and forths without any streaming or overlay.

It is a measure of efficiency - quantity of CPU consumed per unit of work.  For 
example, from my previous email:

UDP REQUEST/RESPONSE TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to bl870c2.west 
(10.208.0.210) port 0 AF_INET : histogram : first burst 0 : cpu bind
Local /Remote
Socket Size   Request Resp.  Elapsed Trans.   CPU    CPU    S.dem   S.dem
Send   Recv   Size    Size   Time    Rate     local  remote local   remote
bytes  bytes  bytes   bytes  secs.   per sec  % S    % S    us/Tr   us/Tr

126976 126976 1       1      10.00   7550.46   2.33   2.41   24.721  25.551
126976 126976

The transaction rate was 7550 (invert for the latency) and service demand was 
24.721 (give or take :) microseconds of CPU time consumed per transaction on the 
one side and 25.551 on the other (identical systems and kernels).  If we make the 
handwaving assumption that virtually all the CPU consumption on either side is in 
the latency path, and calculate the overall latency we have:

overall: 132.44 microseconds per transaction
CPU time: 50.27
other:    80.17

With "other" being such a large component, it is a tip-off (not a slam dunk, but 
a big clue, that there was a sub-standard interrupt avoidance mechanism at work. 
  Even if we calculate the transmission time on the wire for the request and 
response - 1 byte payload, 8 bytes UDP header, 20 bytes IPv4 header, 14 bytes 
Ethernet header - 344 bits or 688 both request and response (does full-duplex GbE 
still enforce the 60 byte minimum?  I forget) we have:

wiretime: 0.69

and even if DMA time were twice that, there is still 75+ microseconds 
unaccounted.  Smells like a timer running in a NIC.  And/or some painfully slow 
firmware on the NIC.

If the latency were constrained almost entirely by the CPU consumption in the 
case above, the transaction rate should have been more like 19000 transactions 
per second.  And with those two systems, with a different, 10G NIC installed (not 
that 10G speed is required for single-byte _RR), I've seen 20,000 
transactions/second.

That is with netperf/netserver running on the same CPU as taking the NIC 
interrupt(s).  When running on a different core from the interrupt(s) the 
cache-to-cache traffic dropped the transaction rate by 30% (a 2.6.18esque kernel, 
but I've seen similar stuff elsewhere).

So, when looking for latency regressions, there can be a lot of variables.

rick jones
