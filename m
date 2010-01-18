From: Michael Breuer <mbreuer@majjas.com>
Subject: Re: [PATCH] af_packet: Don't use skb after dev_queue_xmit()
Date: Mon, 18 Jan 2010 16:39:24 -0500
Message-ID: <4B54D50C.90608@majjas.com>
References: <4B4E3834.3000609@majjas.com> <4B533A46.9050600@majjas.com>
 <20100117221746.GA3161@del.dom.local> <4B53906B.2020608@majjas.com>
 <20100117230531.GC3161@del.dom.local> <4B539A0A.2000504@majjas.com>
 <20100118073018.GA6270@ff.dom.local> <4B548C6B.10607@majjas.com>
 <20100118204658.GC3157@del.dom.local> <4B54CB0D.5070604@majjas.com>
 <20100118212516.GE3157@del.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7BIT
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	flyboy@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756137Ab0ARVkS@vger.kernel.org>
In-reply-to: <20100118212516.GE3157@del.dom.local>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 1/18/2010 4:25 PM, Jarek Poplawski wrote:
> On Mon, Jan 18, 2010 at 03:56:45PM -0500, Michael Breuer wrote:
>    
>> On 1/18/2010 3:46 PM, Jarek Poplawski wrote:
>>      
>>> On Mon, Jan 18, 2010 at 11:29:31AM -0500, Michael Breuer wrote:
>>>        
>>>> Ok - up on the two patches, no DMAR. Some early observations:
>>>>
>>>> 1. There's an early on MMAP oops (see below). This happens once, at
>>>> the completion of the transition to runlevel 5 (I've seen it
>>>> entering runlevel 3 as well). This does not recur when runlevels are
>>>> subsequently changed. I do not see this when running with DMAR
>>>> enabled.
>>>>          
>>> OK, you mentioned this oops (actually a warning only) happened during
>>> previous tests too.
>>>        
>> Yes - dk if it's significant or not. Only obvious difference between
>> DMAR and not.
>>      
> OK, let's try (as long as possible) if it can break so hard as with
> DMAR.
>
>    
>>>> 2. The dropped tx packet (DHCP) is a bit harder to recreate, but it
>>>> still happens.
>>>>          
>>> Btw, I guess you improved the test because you didn't mention it here,
>>> even after my explicit question?:
>>> http://permalink.gmane.org/gmane.linux.network/149171
>>>        
>> I had been focusing on the hangs - dhcp causing the initial crash
>> from December. After things stabilized with the af patch&  skb may
>> pull I started noticing the dropped tx packets. I reported the TX
>> loss on the 16th of January after confirming the issue.
>>      
> OK, but we need to establish some status quo after these patches
> before any new things (including DMAR), so I'd suggest trying this
> config really longer and harder.
>
>    
>>>> Interestingly, I initially saw no dropped packets
>>>> with ping - but after I went the DCHP route and eventually
>>>> reconnected, I could then cause dropped tx packets with ping. To
>>>> clarify:
>>>>
>>>> a) start throughput
>>>> b) ping device - no packet loss - this was true for the entire test run.
>>>> c) start throughput again
>>>> d) ping - no loss.
>>>> e) drop wifi on the device&   restart - first attempt worked. Repeat
>>>> attempt yielded the dropped DHCPOFFER packets. After about 6 tries,
>>>> the device reconnected to wifi.
>>>> f) ping again (after the reconnection) - packet loss rate about 80%.
>>>> g) simultaneously ping the wifi router - no loss.
>>>> h) After a while, packets are no longer dropped during ping. If I
>>>> manage to cause the dhcp drop again, and then ping after the device
>>>> finally reconnects, packet loss is significant for a while (maybe 30
>>>> sec to a minute). Then things return to normal. Note that the packet
>>>> loss continues even if the reported throughput drops to nil.
>>>> i) I can't cause the initial packet loss at RX rates below about
>>>> 30,000KBPS (as reported by nethogs).  At rates over 40 I can
>>>> reproduce this on this set of patches&   config about 60% of the
>>>> time.
>>>>          
>>> I forgot to mention, but did you try to check if these lost ping
>>> packets are "being dropped somewhere after wireshark sees them and
>>> before hitting the wire" like DHCPOFFER? Aren't there any sky2
>>> warnings/resets while this happens?
>>>
>>> Jarek P.
>>>        
>> Yes. There are no errors, and no statistics anywhere that I know to
>> look reflect the loss. Nothing in netstat; ethtool -S; etc. The only
>> loss reported is RX. The recent TX warnings/resets happened while
>> the machine was up for several days and while unattended and under
>> high RX load.
>>      
> Please check "tc -s qdisc" each time as well.
>
> Jarek P
>    

Some output from tc -s qdisc:

Before test:
qdisc pfifo_fast 0: dev eth0 root refcnt 2 bands 3 priomap  1 2 2 2 1 2 
0 0 1 1 1 1 1 1 1 1
  Sent 35279532 bytes 291080 pkt (dropped 0, overlimits 0 requeues 0)
  rate 0bit 0pps backlog 0b 0p requeues 0
qdisc pfifo_fast 0: dev eth1 root refcnt 2 bands 3 priomap  1 2 2 2 1 2 
0 0 1 1 1 1 1 1 1 1
  Sent 377308 bytes 3107 pkt (dropped 0, overlimits 0 requeues 0)
  rate 0bit 0pps backlog 0b 0p requeues 0

During test (after initial observed packet loss):
qdisc pfifo_fast 0: dev eth0 root refcnt 2 bands 3 priomap  1 2 2 2 1 2 
0 0 1 1 1 1 1 1 1 1
  Sent 123389424 bytes 1781403 pkt (dropped 0, overlimits 0 requeues 0)
  rate 0bit 0pps backlog 0b 0p requeues 0
qdisc pfifo_fast 0: dev eth1 root refcnt 2 bands 3 priomap  1 2 2 2 1 2 
0 0 1 1 1 1 1 1 1 1
  Sent 400862 bytes 3250 pkt (dropped 0, overlimits 0 requeues 0)
  rate 0bit 0pps backlog 0b 0p requeues 0

During test - while packet loss occuring:
qdisc pfifo_fast 0: dev eth0 root refcnt 2 bands 3 priomap  1 2 2 2 1 2 
0 0 1 1 1 1 1 1 1 1
  Sent 150518974 bytes 2138312 pkt (dropped 0, overlimits 0 requeues 0)
  rate 0bit 0pps backlog 0b 0p requeues 0
qdisc pfifo_fast 0: dev eth1 root refcnt 2 bands 3 priomap  1 2 2 2 1 2 
0 0 1 1 1 1 1 1 1 1
  Sent 422003 bytes 3432 pkt (dropped 0, overlimits 0 requeues 0)
  rate 0bit 0pps backlog 0b 0p requeues 0

After the conclusion of the test:
qdisc pfifo_fast 0: dev eth0 root refcnt 2 bands 3 priomap  1 2 2 2 1 2 
0 0 1 1 1 1 1 1 1 1
  Sent 244900497 bytes 3416350 pkt (dropped 0, overlimits 0 requeues 0)
  rate 0bit 0pps backlog 0b 0p requeues 0
qdisc pfifo_fast 0: dev eth1 root refcnt 2 bands 3 priomap  1 2 2 2 1 2 
0 0 1 1 1 1 1 1 1 1
  Sent 564380 bytes 4708 pkt (dropped 0, overlimits 0 requeues 0)
  rate 0bit 0pps backlog 0b 0p requeues 0


During the test, 8.9GB received; 232.9MB sent).

I also connected a second device through the wifi router. I was able to 
ping that device w/o loss while DHCP packets were being dropped to the 
other connected device.

Last note: just moved to 2.6.32.4 from .3 for this test (from git).
