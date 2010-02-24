From: Jorrit Kronjee <j.kronjee@infopact.nl>
Subject: Re: stress testing netfilter's hashlimit
Date: Wed, 24 Feb 2010 14:43:32 +0100
Message-ID: <4B852D04.8010201@infopact.nl>
References: <4B8292C6.4000207@infopact.nl> <41885A88D9043444B138491FB10E15420476E86A91@azsmsx506.amr.corp.intel.com> <4B8385EF.9060802@infopact.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: "Tadepalli, Hari K" <hari.k.tadepalli@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.infopact.nl ([212.29.160.232]:60794 "EHLO
	smtp1.infopact.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756984Ab0BXNnq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Feb 2010 08:43:46 -0500
In-Reply-To: <4B8385EF.9060802@infopact.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hari,

Actually, I take it back. Without any bridging or routing it receives
packets at a rate of 800 kpps. With bridging switched on, the throughput
becomes 400 kpps and with basic routing on, the throughput goes further
down to 200 kpps. We've tried messing with SMP affinity settings by
binding the first network interface to core #0 and core #1 and the
second interface to #2 and #3, which mostly resulted in having four
ksoftirqd processes running at 100% instead of just one.

Any ideas?

Regards,

Jorrit Kronjee


On 2/23/2010 8:38 AM, Jorrit Kronjee wrote:
> Hari,
>
> Thank you very much for your quick response. I have a follow-up
> question however.
>
> Tadepalli, Hari K wrote:
>>>> Each of these are separate machines. The sender has a Gigabit Ethernet
>>>> interface and sends ~410,000 packets per second (52 bytes Ethernet
>>>> frames). The bridge has two Gigabit Ethernet interfaces, a quad core
>>>> Xeon X3330 and is running Ubuntu 9.10 (Karmic Koala) with kernel
>>>> 2.6.31-19-generic-pae.
>>>>       
>>
>> This is a Penryn class quad core processor, advertized at 2.66GHz. On
>> this platform & with PCI express NICs, you can expect an IPv4
>> forwarding rate of ~1 Mpps per CPU core. Given the processing cost
>> involved in forwarding/routing a packet, it is not possible to
>> approach line rate forwarding line rate on stock kernels. Looks like,
>> @ 52B packets, you are using a packet size that will NOT be
>> sufficient to fill a full UDP header in the packet.
>>   
> You are writing that it's not possible with a stock kernel; what would
> I need to change to the kernel to do make it work at higher speeds? My
> goal is to be able to bridge/route a stable 1 Mpps.
>
>> Coming to BRIDGING: I have not worked on bridging, but have seen
>> anecdotal evidence that bridging costs far more CPU cycles than
>> routing/forwarding (on a per packet basis). What you are observing
>> seems to align well with this. You can play with a few platform level
>> tunings; setting interrupt affinity of each NIC port to align with
>> adjacent processor pair, as in:
>>
>> echo 1 > /proc/irq/22/smp_affinity
>> echo 2 > /proc/irq/23/smp_affinity
>>
>> - assuming your NIC ports are assigned IRQs of 22 and 23
>> respectively. This will balance the traffic from each NIC to be
>> handled by a different CPU core, while minimizing the impact of
>> inter-cpu cache thrashes.
>>   
> You are absolutely right. Just turning off bridging increased the
> speed to ~800,000 pps. After that the kernel started dropping packets
> again. Weird, because my gut feeling would say that just copying
> packets from one interface to another requires less work than routing
> them.
>
> Thanks again for your reply!
>
> Regards,
>
> Jorrit
>
>
>> - Hari
>>
>> ____________________________________
>> Intel/ Embedded Comms/ Chandler, AZ
>>
>>
>> -----Original Message-----
>> From: netdev-owner@vger.kernel.org
>> [mailto:netdev-owner@vger.kernel.org] On Behalf Of Jorrit Kronjee
>> Sent: Monday, February 22, 2010 7:21 AM
>> To: netdev@vger.kernel.org
>> Subject: stress testing netfilter's hashlimit
>>
>> Dear list,
>>
>> I'm not entirely sure if this is the right list for this question, but
>> if someone could me give me some pointers where to ask otherwise, it
>> would be most appreciated.
>>
>> We're trying to stress test netfilter's hashlimit module. To do so,
>> we've built the following setup.
>>
>> [ sender ] --> [ bridge ] --> [ receiver ]
>>
>> Each of these are separate machines. The sender has a Gigabit Ethernet
>> interface and sends ~410,000 packets per second (52 bytes Ethernet
>> frames). The bridge has two Gigabit Ethernet interfaces, a quad core
>> Xeon X3330 and is running Ubuntu 9.10 (Karmic Koala) with kernel
>> 2.6.31-19-generic-pae. The receiver is a non-descript machine with a
>> Gigabit Ethernet interface and is not really important for my question.
>> We disabled connection tracking (because the packets are UDP) on the
>> bridge as follows:
>>
>> # iptables -t raw -nL
>> Chain PREROUTING (policy ACCEPT)
>> target     prot opt source               destination       
>> NOTRACK    all  --  0.0.0.0/0            0.0.0.0/0         
>> Chain OUTPUT (policy ACCEPT)
>> target     prot opt source               destination       
>> NOTRACK    all  --  0.0.0.0/0            0.0.0.0/0         
>> We used brctl to make a bridge between eth3 and eth4 (even though we
>> don't have a eth[0,1,2]):
>>
>> # brctl show
>> bridge name    bridge id        STP enabled    interfaces
>> br1        8000.001517b30cb3    no        eth3
>>                             eth4
>>
>>
>>   
>

-- 
Manager ICT

Infopact Network Solutions
Hoogvlietsekerkweg 170
3194 AM  Rotterdam Hoogvliet
tel. +31 (0)88 - 4636700
fax. +31 (0)88 - 4636799
j.kronjee@infopact.nl
http://www.infopact.nl/ 


