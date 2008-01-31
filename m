From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: RE: e1000 full-duplex TCP performance well below wire speed
Date: Thu, 31 Jan 2008 09:20:12 -0800
Message-ID: <36D9DB17C6DE9E40B059440DB8D95F52044F8EC9@orsmsx418.amr.corp.intel.com>
References: <Pine.LNX.4.63.0801300621290.6391@trinity.phys.uwm.edu> <36D9DB17C6DE9E40B059440DB8D95F52044F81DF@orsmsx418.amr.corp.intel.com> <Pine.LNX.4.63.0801301635470.19938@trinity.phys.uwm.edu> <36D9DB17C6DE9E40B059440DB8D95F52044F8BA3@orsmsx418.amr.corp.intel.com> <47A1E553.8010006@aei.mpg.de>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Bruce Allen" <ballen@gravity.phys.uwm.edu>,
	<netdev@vger.kernel.org>,
	"Henning Fehrmann" <henning.fehrmann@aei.mpg.de>,
	"Bruce Allen" <bruce.allen@aei.mpg.de>
To: "Carsten Aulbert" <carsten.aulbert@aei.mpg.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:10492 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1764019AbYAaRUo convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jan 2008 12:20:44 -0500
Content-class: urn:content-classes:message
In-Reply-To: <47A1E553.8010006@aei.mpg.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Carsten Aulbert wrote:
> We are using MSI, /proc/interrupts look like:
> n0003:~# cat /proc/interrupts
> 378:   17234866          0          0          0   PCI-MSI-edge     
> eth1 
> 379:     129826          0          0          0   PCI-MSI-edge 
> eth0

> (sorry for the line break).
> 
> What we don't understand is why only core0 gets the interrupts, since
> the affinity is set to f:
> # cat /proc/irq/378/smp_affinity
> f

without CONFIG_IRQBALANCE set, and no irqbalance daemon running, this is
expected.  Seems it is also dependent upon your system hardware.
 
> Right now, irqbalance is not running, though I can give it shot if
> people think this will make a difference.

probably won't make much of a difference if you only have a single
interrupt source generating interrupts.  If you are using both adapters
simultaneously, please use smp_affinity or turn on irqbalance.
 
>> I would suggest you try TCP_RR with a command line something like
>> this: netperf -t TCP_RR -H <hostname> -C -c -- -b 4 -r 64K
> 
> I did that and the results can be found here:
> https://n0.aei.uni-hannover.de/wiki/index.php/NetworkTest

seems something went wrong and all you ran was the 1 byte tests, where
it should have been 64K both directions (request/response).
 
> The results with netperf running like
> netperf -t TCP_STREAM -H <host> -l 20
> can be found here:
> https://n0.aei.uni-hannover.de/wiki/index.php/NetworkTestNetperf1

 
> I reran the tests with
> netperf -t <test> -H <host> -l 20 -c -C
> or in the case of TCP_RR with the suggested burst settings -b 4 -r 64k

I get: 
TCP REQUEST/RESPONSE TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to foo
(134.134.3.121) port 0 AF_INET : first burst 4
Local /Remote
Socket Size   Request Resp.  Elapsed Trans.   CPU    CPU    S.dem
S.dem
Send   Recv   Size    Size   Time    Rate     local  remote local
remote
bytes  bytes  bytes   bytes  secs.   per sec  % S    % S    us/Tr
us/Tr

16384  87380  65536   65536  10.00   1565.34  14.17  27.18  362.220
347.243
16384  87380 
 
>> Yes, InterruptThrottleRate=8000 means there will be no more than 8000
>> ints/second from that adapter, and if interrupts are generated faster
>> than that they are "aggregated."
>> 
>> Interestingly since you are interested in ultra low latency, and may
>> be willing to give up some cpu for it during bulk transfers you
>> should try InterruptThrottleRate=1 (can generate up to 70000 ints/s)
>> 
> 
> On the web page you'll see that there are about 4000 interrupts/s for
> most tests and up to 20,000/s for the TCP_RR test. Shall I change the
> throttle rate?

that's the auto-tuning, I suggest just InterruptThrottleRate=4000 or
8000 if all you're concerned about is bulk traffic performance.
 
>>>> just for completeness can you post the dump of ethtool -e eth0 and
>>>> lspci -vvv?
>>> Yup, we'll give that info also.
> 
> n0002:~# ethtool -e eth1
> Offset          Values
> ------          ------
> 0x0000          00 30 48 93 94 2d 20 0d 46 f7 57 00 ff ff ff ff
> 0x0010          ff ff ff ff 6b 02 9a 10 d9 15 9a 10 86 80 df 80
> 0x0020          00 00 00 20 54 7e 00 00 00 10 da 00 04 00 00 27
> 0x0030          c9 6c 50 31 32 07 0b 04 84 29 00 00 00 c0 06 07
> 0x0040          08 10 00 00 04 0f ff 7f 01 4d ff ff ff ff ff ff
> 0x0050          14 00 1d 00 14 00 1d 00 af aa 1e 00 00 00 1d 00
> 0x0060          00 01 00 40 1e 12 ff ff ff ff ff ff ff ff ff ff
> 0x0070          ff ff ff ff ff ff ff ff ff ff ff ff ff ff cf 2f

this looks fine.
 
> lspci -vvv for this card:
> 0e:00.0 Ethernet controller: Intel Corporation 82573L Gigabit Ethernet
> Controller
>          Subsystem: Super Micro Computer Inc Unknown device 109a
>          Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
> ParErr- Stepping- SERR+ FastB2B-
>          Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast
> >TAbort- <TAbort- <MAbort- >SERR- <PERR-
>          Latency: 0, Cache Line Size: 64 bytes
>          Interrupt: pin A routed to IRQ 378
>          Region 0: Memory at ee200000 (32-bit, non-prefetchable)
>          [size=128K] Region 2: I/O ports at 5000 [size=32]
>          Capabilities: [c8] Power Management version 2
>                  Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA
> PME(D0+,D1-,D2-,D3hot+,D3cold+)
>                  Status: D0 PME-Enable- DSel=0 DScale=1 PME-
>          Capabilities: [d0] Message Signalled Interrupts: Mask- 64bit+
> Queue=0/0 Enable+
>                  Address: 00000000fee0f00c  Data: 41b9
>          Capabilities: [e0] Express Endpoint IRQ 0
>                  Device: Supported: MaxPayload 256 bytes, PhantFunc 0,
> ExtTag-
>                  Device: Latency L0s <512ns, L1 <64us
>                  Device: AtnBtn- AtnInd- PwrInd-
>                  Device: Errors: Correctable- Non-Fatal- Fatal-
>                  Unsupported- Device: RlxdOrd+ ExtTag- PhantFunc-
>                  AuxPwr- NoSnoop+ Device: MaxPayload 128 bytes,
>                  MaxReadReq 512 bytes Link: Supported Speed 2.5Gb/s,
> Width x1, ASPM unknown, 
> Port 0
>                  Link: Latency L0s <128ns, L1 <64us
>                  Link: ASPM Disabled RCB 64 bytes CommClk- ExtSynch-
>                  Link: Speed 2.5Gb/s, Width x1
>          Capabilities: [100] Advanced Error Reporting
>          Capabilities: [140] Device Serial Number
> 2d-94-93-ff-ff-48-30-00 

this also looks good, no APSM, MSI enabled, 
 
