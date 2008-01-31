From: Rick Jones <rick.jones2@hp.com>
Subject: Re: e1000 full-duplex TCP performance well below wire speed
Date: Thu, 31 Jan 2008 10:03:22 -0800
Message-ID: <47A20D6A.2000609@hp.com>
References: <Pine.LNX.4.63.0801300621290.6391@trinity.phys.uwm.edu>	<36D9DB17C6DE9E40B059440DB8D95F52044F81DF@orsmsx418.amr.corp.intel.com>	<Pine.LNX.4.63.0801301635470.19938@trinity.phys.uwm.edu>	<36D9DB17C6DE9E40B059440DB8D95F52044F8BA3@orsmsx418.amr.corp.intel.com> <47A1E553.8010006@aei.mpg.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	Bruce Allen <ballen@gravity.phys.uwm.edu>,
	netdev@vger.kernel.org,
	Henning Fehrmann <henning.fehrmann@aei.mpg.de>,
	Bruce Allen <bruce.allen@aei.mpg.de>
To: Carsten Aulbert <carsten.aulbert@aei.mpg.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0006.atlanta.hp.com ([15.192.0.43]:25301 "EHLO
	g5t0006.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757826AbYAaSDZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jan 2008 13:03:25 -0500
In-Reply-To: <47A1E553.8010006@aei.mpg.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Carsten Aulbert wrote:
> Hi all, slowly crawling through the mails.
> 
> Brandeburg, Jesse wrote:
> 
>>>>> The test was done with various mtu sizes ranging from 1500 to 9000,
>>>>> with ethernet flow control switched on and off, and using reno and
>>>>> cubic as a TCP congestion control.
>>>>
>>>> As asked in LKML thread, please post the exact netperf command used
>>>> to start the client/server, whether or not you're using irqbalanced
>>>> (aka irqbalance) and what cat /proc/interrupts looks like (you ARE
>>>> using MSI, right?)
> 
> 
> We are using MSI, /proc/interrupts look like:
> n0003:~# cat /proc/interrupts
>            CPU0       CPU1       CPU2       CPU3
>   0:    6536963          0          0          0   IO-APIC-edge      timer
>   1:          2          0          0          0   IO-APIC-edge      i8042
>   3:          1          0          0          0   IO-APIC-edge      serial
>   8:          0          0          0          0   IO-APIC-edge      rtc
>   9:          0          0          0          0   IO-APIC-fasteoi   acpi
>  14:      32321          0          0          0   IO-APIC-edge      libata
>  15:          0          0          0          0   IO-APIC-edge      libata
>  16:          0          0          0          0   IO-APIC-fasteoi 
> uhci_hcd:usb5
>  18:          0          0          0          0   IO-APIC-fasteoi 
> uhci_hcd:usb4
>  19:          0          0          0          0   IO-APIC-fasteoi 
> uhci_hcd:usb3
>  23:          0          0          0          0   IO-APIC-fasteoi 
> ehci_hcd:usb1, uhci_hcd:usb2
> 378:   17234866          0          0          0   PCI-MSI-edge      eth1
> 379:     129826          0          0          0   PCI-MSI-edge      eth0
> NMI:          0          0          0          0
> LOC:    6537181    6537326    6537149    6537052
> ERR:          0
> 
> (sorry for the line break).
> 
> What we don't understand is why only core0 gets the interrupts, since 
> the affinity is set to f:
> # cat /proc/irq/378/smp_affinity
> f
> 
> Right now, irqbalance is not running, though I can give it shot if 
> people think this will make a difference.
> 
>> I would suggest you try TCP_RR with a command line something like this:
>> netperf -t TCP_RR -H <hostname> -C -c -- -b 4 -r 64K
> 
> 
> I did that and the results can be found here:
> https://n0.aei.uni-hannover.de/wiki/index.php/NetworkTest

For convenience, 2.4.4 (perhaps earlier I can never remember when I've 
added things :) allows the output format for a TCP_RR test to be set to 
the same as a _STREAM or _MAERTS test.  And if you add a -v 2 to it you 
will get the "each way" values and the average round-trip latency:

raj@tardy:~/netperf2_trunk$ src/netperf -t TCP_RR -H oslowest.cup -f m 
-v 2 -- -r 64K -b 4
TCP REQUEST/RESPONSE TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 
oslowest.cup.hp.com (16.89.84.17) port 0 AF_INET : first burst 4
Local /Remote
Socket Size   Request  Resp.   Elapsed
Send   Recv   Size     Size    Time     Throughput
bytes  Bytes  bytes    bytes   secs.    10^6bits/sec

16384  87380  65536    65536   10.01     105.63
16384  87380
Alignment      Offset         RoundTrip  Trans    Throughput
Local  Remote  Local  Remote  Latency    Rate     10^6bits/s
Send   Recv    Send   Recv    usec/Tran  per sec  Outbound   Inbound
     8      0       0      0   49635.583   100.734 52.814    52.814
raj@tardy:~/netperf2_trunk$

(this was a WAN test :)

rick jones

one of these days I may tweak netperf further so if the CPU utilization 
method for either end doesn't require calibration, CPU utilization will 
always be done on that end.  people's thoughts on that tweak would be 
most welcome...
