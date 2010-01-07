From: Michael Breuer <mbreuer@majjas.com>
Subject: Re: [PATCH] af_packet: Don't use skb after dev_queue_xmit()
Date: Thu, 07 Jan 2010 02:20:22 -0500
Message-ID: <4B458B36.6050509@majjas.com>
References: <20100105230746.GA6612@del.dom.local> <4B43F72C.9090004@majjas.com>
 <20100106072208.GA6711@ff.dom.local> <4B44E952.5000804@majjas.com>
 <20100106131044.25b4e500@nehalam> <4B451C31.3000309@majjas.com>
 <4B454A16.3030909@majjas.com> <4B455C62.6030504@majjas.com>
 <20100106205343.5460d658@nehalam> <4B4571D5.30002@majjas.com>
 <4B457711.1040008@majjas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7BIT
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	flyboy@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta1.srv.hcvlny.cv.net ([167.206.4.196]:36026 "EHLO
	mta1.srv.hcvlny.cv.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756094Ab0AGHVB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2010 02:21:01 -0500
In-reply-to: <4B457711.1040008@majjas.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/7/2010 12:54 AM, Michael Breuer wrote:
> On 1/7/2010 12:32 AM, Michael Breuer wrote:
>> On 1/6/2010 11:53 PM, Stephen Hemminger wrote:
>>> On Wed, 06 Jan 2010 23:00:34 -0500
>>> Michael Breuer<mbreuer@majjas.com>  wrote:
>>>
>>>> Changing MTU to 9000, everything basically breaks - Can't use X11 
>>>> (local
>>>> or remote - get X11 screen after gdm login locally, but then goes back
>>>> to greeter; remote gets no greeter); ssh sessions hang; etc. This 
>>>> time I
>>>> was able to reset the MTU back to 1500 without a reboot - but I did 
>>>> have
>>>> to ifconfig eth0 down and then up. Looking at the sk98lin code, it 
>>>> looks
>>>> to me like they do a bit more work with existing buffers before
>>>> completing the MTU switch. Note that even doing this, X11 did not work
>>>> (it did with the old mtu change code). Tried changing to mtu 4500 - 
>>>> same
>>>> effect as 9000... but when I switched back to 1500, ksoftirqd started
>>>> spinning using 100% of one core.
>>> The problem is that patch was enabling scatter-gather and checksum 
>>> offload
>>> that won't work on EC_U hardware with 9K MTU.  At least, it never 
>>> worked
>>> for me when I tested it. So because of that it really doesn't change 
>>> anything
>>> for the better on that chip version.
>>>
>>> What version chip is on that motherboard?  Mine is:
>>>   Yukon-2 EC Ultra chip revision 3
>>> which corresponds to B0 step.
>>>
>>> Another possibility is the PHY register which controls number of ticks
>>> of buffering.  The default is zero, which gives the most buffering 
>>> (good),
>>> but the firmware could be reprogramming it (bad).  In general, the 
>>> driver
>>> doesn't fiddle with bits that are already set correctly, because 
>>> sometimes
>>> vendors need to tweak PCI timing in firmware/BIOS.  It seems the 
>>> firmware on this
>>> chip is just a bunch of register setups done on power on.
>> Also - I'm seeing a huge number of dropped packets  (RX) 
>> 200-300/second. Probably why this is so slow.
>>
>> Current ifconfig:
>> eth0      Link encap:Ethernet  HWaddr 00:26:18:00:1C:3B
>>           inet addr:10.0.0.1  Bcast:10.0.0.255  Mask:255.255.255.0
>>           inet6 addr: fe80::226:18ff:fe00:1c3b/64 Scope:Link
>>           UP BROADCAST RUNNING ALLMULTI MULTICAST  MTU:1500  Metric:1
>>           RX packets:26647536 errors:0 dropped:517884 overruns:0 frame:0
>>           TX packets:12112780 errors:0 dropped:0 overruns:0 carrier:0
>>           collisions:0 txqueuelen:1000
>>           RX bytes:38960063319 (36.2 GiB)  TX bytes:1889879762 (1.7 GiB)
>>           Interrupt:18
>>
>>
>>
>
> Never mind... spoke too soon. Crashed again. Just took longer:
...
Reapplied a couple of earlier patches - still can't do jumbo frames, but 
the rx errors are gone and speed has improved. Too early to assure that 
it's stable.

Patches that seem to fix the rx drops (all from Stephen):
1) Patch change to tx_init
2) Patch to lock netif_device_detach
3) Patch to sky2_tx_complete to add netif_device_present test
Also in the mix: Jarek's alternative 2

With this set and mtu=1500 all seems good - decent if not stellar 
throughput; no logged errors; no reported packet loss. As before, will 
leave running and see if anything falls apart.
