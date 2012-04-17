From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [BUG] ixgbe: something wrong with queue selection ?
Date: Tue, 17 Apr 2012 09:38:41 -0700
Message-ID: <4F8D9C91.5010001@intel.com>
References: <1334653608.6226.11.camel@edumazet-laptop> <1334654187.2696.2.camel@jtkirshe-mobl> <4F8D93E1.9090000@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, Eric Dumazet <eric.dumazet@gmail.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	Greg Rose <gregory.v.rose@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev <netdev@vger.kernel.org>
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:21080 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751267Ab2DQQim (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Apr 2012 12:38:42 -0400
In-Reply-To: <4F8D93E1.9090000@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/17/2012 9:01 AM, Alexander Duyck wrote:
> On 04/17/2012 02:16 AM, Jeff Kirsher wrote:
>> On Tue, 2012-04-17 at 11:06 +0200, Eric Dumazet wrote:
>>> Hi guys
>>>
>>> I have bad feelings with ixgbe and its multiqueue selection.
>>>
>>> On a quad core machine (Q6600), I get lots of reorderings on a single
>>> TCP stream.
>>>
>>>
>>> Apparently packets happily spread on all available queues, instead of a
>>> single one.
>>>
>>> This defeats GRO at receiver and TCP performance is really bad.
>>>
>>> # ethtool -S eth5|egrep "x_queue_[0123]_packets" ; taskset 1 netperf -H
>>> 192.168.99.1 ; ethtool -S eth5|egrep "x_queue_[0123]_packets"
>>>      tx_queue_0_packets: 24
>>>      tx_queue_1_packets: 26
>>>      tx_queue_2_packets: 32
>>>      tx_queue_3_packets: 16
>>>      rx_queue_0_packets: 11
>>>      rx_queue_1_packets: 47
>>>      rx_queue_2_packets: 27
>>>      rx_queue_3_packets: 22
>>> MIGRATED TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to
>>> 192.168.99.1 (192.168.99.1) port 0 AF_INET
>>> Recv   Send    Send                          
>>> Socket Socket  Message  Elapsed              
>>> Size   Size    Size     Time     Throughput  
>>> bytes  bytes   bytes    secs.    10^6bits/sec  
>>>
>>>  87380  16384  16384    10.00    3866.43   
>>>      tx_queue_0_packets: 1653201
>>>      tx_queue_1_packets: 608000
>>>      tx_queue_2_packets: 541382
>>>      tx_queue_3_packets: 536543
>>>      rx_queue_0_packets: 434703
>>>      rx_queue_1_packets: 137444
>>>      rx_queue_2_packets: 131023
>>>      rx_queue_3_packets: 128407
>>>
>>> # ip ro get 192.168.99.1
>>> 192.168.99.1 dev eth5  src 192.168.99.2 
>>>     cache  ipid 0x438b rtt 4ms rttvar 4ms cwnd 57 reordering 127
>>>
>>> # lspci -v -s 02:00.0
>>> 02:00.0 Ethernet controller: Intel Corporation 82599EB 10-Gigabit
>>> SFI/SFP+ Network Connection (rev 01)
>>> 	Subsystem: Intel Corporation Ethernet Server Adapter X520-2
>>> 	Flags: bus master, fast devsel, latency 0, IRQ 16
>>> 	Memory at f1100000 (64-bit, prefetchable) [size=512K]
>>> 	I/O ports at b000 [size=32]
>>> 	Memory at f1200000 (64-bit, prefetchable) [size=16K]
>>> 	Capabilities: [40] Power Management version 3
>>> 	Capabilities: [50] MSI: Enable- Count=1/1 Maskable+ 64bit+
>>> 	Capabilities: [70] MSI-X: Enable+ Count=64 Masked-
>>> 	Capabilities: [a0] Express Endpoint, MSI 00
>>> 	Capabilities: [100] Advanced Error Reporting
>>> 	Capabilities: [140] Device Serial Number 00-1b-21-ff-ff-4a-fe-54
>>> 	Capabilities: [150] Alternative Routing-ID Interpretation (ARI)
>>> 	Capabilities: [160] Single Root I/O Virtualization (SR-IOV)
>>> 	Kernel driver in use: ixgbe
>>> 	Kernel modules: ixgbe
>>>
>>>
>> Adding Don Skidmore and Alex Duyck...
> This is probably the result of ATR and the load balancer on the system. 
> What is likely happening is that the netperf process is getting moved
> from CPU to CPU, and this is causing the transmit queue to change.  Once
> this happens the ATR will cause the receive queue to change in order to
> follow the transmitting process.
> 
> One thing you might try is using the "-T" option in netperf to see if
> the behaviour occurs if the process is bound to a specific CPU.  Another
> thing you might try would be to disable ATR by enabling ntuple.  You
> should be able to do that with  "ethtool -K eth5 ntuple on".
> 
> Thanks,
> 
> Alex
> --

We could consider using sk_tx_queue_get(sk) in select_queue or better
yet use XPS and initialize it at sw init time. I think this would work
nicely and finally remove the select_queue() logic I just haven't got
to it yet. Hoping to get there the next few weeks.

.John
