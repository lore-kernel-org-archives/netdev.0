From: Rick Jones <rick.jones2@hp.com>
Subject: Re: e1000 performance issue in 4 simultaneous links
Date: Thu, 10 Jan 2008 10:37:32 -0800
Message-ID: <478665EC.7040206@hp.com>
References: <1199981839.8931.35.camel@cafe>	<20080110163626.GJ3544@solarflare.com> <1199986291.8931.62.camel@cafe>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com,
	Linux Network Development list <netdev@vger.kernel.org>
To: Breno Leitao <leitao@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0014.houston.hp.com ([15.201.24.17]:12292 "EHLO
	g4t0014.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754212AbYAJShe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jan 2008 13:37:34 -0500
In-Reply-To: <1199986291.8931.62.camel@cafe>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I also tried to increase my interface MTU to 9000, but I am afraid that
> netperf only transmits packets with less than 1500. Still investigating.

It may seem like picking a tiny nit, but netperf never transmits 
packets.  It only provides buffers of specified size to the stack. It is 
then the stack which transmits and determines the size of the packets on 
the network.

Drifting a bit more...

While there are settings, conditions and known stack behaviours where 
one can be confident of the packet size on the network based on the 
options passed to netperf, generally speaking one should not ass-u-me a 
direct relationship between the options one passes to netperf and the 
size of the packets on the network.

And for JumboFrames to be effective it must be set on both ends, 
otherwise the TCP MSS exchange will result in the smaller of the two 
MTU's "winning" as it were.

>>single CPU this can become a bottleneck.  Does the test system have
>>multiple CPUs?  Are IRQs for the multiple NICs balanced across
>>multiple CPUs?
> 
> Yes, this machine has 8 ppc 1.9Ghz CPUs. And the IRQs are balanced
> across the CPUs, as I see in /proc/interrupts: 

That suggests to me anyway that the dreaded irqbalanced is running, 
shuffling the interrupts as you go.  Not often a happy place for running 
netperf when one want's consistent results.

> 
> # cat /proc/interrupts 
>            CPU0       CPU1       CPU2       CPU3       CPU4       CPU5       CPU6       CPU7       
>  16:        940        760       1047        904        993        777        975        813   XICS      Level     IPI
>  18:          4          3          4          1          3          6          8          3   XICS      Level     hvc_console
>  19:          0          0          0          0          0          0          0          0   XICS      Level     RAS_EPOW
> 273:      10728      10850      10937      10833      10884      10788      10868      10776   XICS      Level     eth4
> 275:          0          0          0          0          0          0          0          0   XICS      Level     ehci_hcd:usb1, ohci_hcd:usb2, ohci_hcd:usb3
> 277:     234933     230275     229770     234048     235906     229858     229975     233859   XICS      Level     eth6
> 278:     266225     267606     262844     265985     268789     266869     263110     267422   XICS      Level     eth7
> 279:        893        919        857        909        867        917        894        881   XICS      Level     eth0
> 305:     439246     439117     438495     436072     438053     440111     438973     438951   XICS      Level     eth0 Neterion Xframe II 10GbE network adapter
> 321:       3268       3088       3143       3113       3305       2982       3326       3084   XICS      Level     ipr
> 323:     268030     273207     269710     271338     270306     273258     270872     273281   XICS      Level     eth16
> 324:     215012     221102     219494     216732     216531     220460     219718     218654   XICS      Level     eth17
> 325:       7103       3580       7246       3475       7132       3394       7258       3435   XICS      Level     pata_pdc2027x
> BAD:       4216

IMO, what you want (in the absence of multi-queue NICs) is one CPU 
taking the interrupts of one port/interface, and each port/interface's 
interrupts going to a separate CPU.  So, something that looks roughly 
like concocted example:

            CPU0     CPU1      CPU2     CPU3
   1:       1234        0         0        0   eth0
   2:          0     1234         0        0   eth1
   3:          0        0      1234        0   eth2
   4:          0        0         0     1234   eth3

which you should be able to acheive via the method I think someone else 
has already mentioned about echoing values into 
/proc/irq/<irq>/smp_affinity  - after you have slain the dreaded 
irqbalance daemon.

rick jones
