From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: e1000 full-duplex TCP performance well below wire speed
Date: Thu, 31 Jan 2008 11:32:17 -0800
Message-ID: <47A22241.70600@intel.com>
References: <Pine.LNX.4.63.0801300621290.6391@trinity.phys.uwm.edu> <36D9DB17C6DE9E40B059440DB8D95F52044F81DF@orsmsx418.amr.corp.intel.com> <Pine.LNX.4.63.0801301635470.19938@trinity.phys.uwm.edu> <36D9DB17C6DE9E40B059440DB8D95F52044F8BA3@orsmsx418.amr.corp.intel.com> <Pine.LNX.4.63.0801310213010.3240@trinity.phys.uwm.edu> <47A20E9E.7070503@intel.com> <Pine.LNX.4.63.0801311251040.14403@trinity.phys.uwm.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org,
	Carsten Aulbert <carsten.aulbert@aei.mpg.de>,
	Henning Fehrmann <henning.fehrmann@aei.mpg.de>,
	Bruce Allen <bruce.allen@aei.mpg.de>
To: Bruce Allen <ballen@gravity.phys.uwm.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:43718 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751557AbYAaTdF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Jan 2008 14:33:05 -0500
In-Reply-To: <Pine.LNX.4.63.0801311251040.14403@trinity.phys.uwm.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bruce Allen wrote:
> Hi Auke,
> 
>>>>> Important note: we ARE able to get full duplex wire speed (over 900
>>>>> Mb/s simulaneously in both directions) using UDP.  The problems occur
>>>>> only with TCP connections.
>>>>
>>>> That eliminates bus bandwidth issues, probably, but small packets take
>>>> up a lot of extra descriptors, bus bandwidth, CPU, and cache resources.
>>>
>>> I see.  Your concern is the extra ACK packets associated with TCP.  Even
>>> those these represent a small volume of data (around 5% with MTU=1500,
>>> and less at larger MTU) they double the number of packets that must be
>>> handled by the system compared to UDP transmission at the same data
>>> rate. Is that correct?
>>
>> A lot of people tend to forget that the pci-express bus has enough
>> bandwidth on first glance - 2.5gbit/sec for 1gbit of traffix, but
>> apart from data going over it there is significant overhead going on:
>> each packet requires transmit, cleanup and buffer transactions, and
>> there are many irq register clears per second (slow ioread/writes).
>> The transactions double for TCP ack processing, and this all
>> accumulates and starts to introduce latency, higher cpu utilization
>> etc...
> 
> Based on the discussion in this thread, I am inclined to believe that
> lack of PCI-e bus bandwidth is NOT the issue.  The theory is that the
> extra packet handling associated with TCP acknowledgements are pushing
> the PCI-e x1 bus past its limits.  However the evidence seems to show
> otherwise:
> 
> (1) Bill Fink has reported the same problem on a NIC with a 133 MHz
> 64-bit PCI connection.  That connection can transfer data at 8Gb/s.

That was even a PCI-X connection, which is known to have extremely good latency
numbers, IIRC better than PCI-e? (?) which could account for a lot of the
latency-induced lower performance...

also, 82573's are _not_ a serverpart and were not designed for this usage. 82546's
are and that really does make a difference. 82573's are full of power savings
features and all that does make a difference even with some of them turned off.
It's not for nothing that these 82573's are used in a ton of laptops like from
toshiba, lenovo etc.... A lot of this has to do with the cards internal clock
timings as usual.

So, you'd really have to compare the 82546 to a 82571 card to be fair. You get
what you pay for so to speak.

> (2) If the theory is right, then doubling the MTU from 1500 to 3000
> should have significantly reduce the problem, since it drops the number
> of ACK's by two.  Similarly, going from MTU 1500 to MTU 9000 should
> reduce the number of ACK's by a factor of six, practically eliminating
> the problem. But changing the MTU size does not help.
> 
> (3) The interrupt counts are quite reasonable.  Broadcom NICs without
> interrupt aggregation generate an order of magnitude more irq/s and this
> doesn't prevent wire speed performance there.
> 
> (4) The CPUs on the system are largely idle.  There are plenty of
> computing resources available.
> 
> (5) I don't think that the overhead will increase the bandwidth needed
> by more than a factor of two.  Of course you and the other e1000
> developers are the experts, but the dominant bus cost should be copying
> data buffers across the bus. Everything else in minimal in comparison.
> 
> Intel insiders: isn't there some simple instrumentation available (which
> read registers or statistics counters on the PCI-e interface chip) to
> tell us statistics such as how many bits have moved over the link in
> each direction? This plus some accurate timing would make it easy to see
> if the TCP case is saturating the PCI-e bus.  Then the theory addressed
> with data rather than with opinions.

the only tools we have are expensive bus analyzers. As said in the thread with
Rick Jones, I think there might be some tools avaialable from Intel for this but I
have never seen these.

Auke

