From: Michael Breuer <mbreuer@majjas.com>
Subject: sky2 DHCPOFFER packet loss under load (Was Re: [PATCH] sky2: safer
 transmit ring cleaning (v4))
Date: Sat, 16 Jan 2010 13:35:06 -0500
Message-ID: <4B5206DA.6050308@majjas.com>
References: <20100112085633.GB6628@ff.dom.local>
 <20100112.014218.112731835.davem@davemloft.net>
 <20100112.025620.210305029.davem@davemloft.net>
 <20100112081513.0175d579@nehalam> <4B4CC0E3.5050106@majjas.com>
 <4B4CC29E.4020703@majjas.com> <4B4CDC28.2050508@majjas.com>
 <20100112201012.21894fd3@nehalam> <4B4DEEF9.7020806@majjas.com>
 <20100113194148.139091a3@nehalam> <20100114101445.GA7210@ff.dom.local>
 <20100114095254.5cf7faa0@nehalam> <4B4FADEF.6020408@majjas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7BIT
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	David Miller <davem@davemloft.net>, mikem@ring3k.org,
	flyboy@gmail.com, rjw@sisk.pl, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta2.srv.hcvlny.cv.net ([167.206.4.197]:32960 "EHLO
	mta2.srv.hcvlny.cv.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755939Ab0APSff (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Jan 2010 13:35:35 -0500
Received: from mail.majjas.com (ool-44c00dc8.dyn.optonline.net [68.192.13.200])
 by mta2.srv.hcvlny.cv.net
 (Sun Java System Messaging Server 6.2-8.04 (built Feb 28 2007))
 with ESMTP id <0KWC0017RRNAUB40@mta2.srv.hcvlny.cv.net> for
 netdev@vger.kernel.org; Sat, 16 Jan 2010 13:35:35 -0500 (EST)
In-reply-to: <4B4FADEF.6020408@majjas.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/14/2010 6:51 PM, Michael Breuer wrote:
> On 1/14/2010 12:52 PM, Stephen Hemminger wrote:
>> On Thu, 14 Jan 2010 10:14:45 +0000
>> Jarek Poplawski<jarkao2@gmail.com>  wrote:
>>
>>> This makes it safe, but it still resembles the "short term fix"
>>> according do David's opinion.
>>>
>>> This change seems to affect dev->stats too. Since they are not
>>> updated in sky2_tx_clean(). Btw, I hope "&" is some optimization
>>> because it's less readable than "&&".
>> Stats don't matter for packets flushed during device reset.
>>
>> The&  is because in the most common case device is up,
>> and we don't want the additional conditional branch.
> I've been looking at what might explain the dhcp stuff - as well as 
> the dropped packets only when there's an extra hop. I came across one 
> path that seems suspect - although I'm really not familiar with the 
> network stack code... that said, I'm wondering about 
> neigh_compat_output (and eth_rebuild_header and arp_find). If I'm 
> following things correctly (or perhaps mostly correctly), the only 
> time anything goes this route (pun intentional) is when the packet was 
> routed to this box. I'm guessing that bridging makes this more likely. 
> So my dhcp stuff would all be going through here, as would the smb 
> stuff that seemed flaky. The race I'm seeing (maybe) is that when the 
> arp table is being rebuilt, there's a possibility that arp_find frees 
> the skb. There's some other locking and stuff going on that seems 
> maybe races with sky2.c in places on both the rx and tx path. I 
> *think* it's right from looking at it, but test results suggest 
> otherwise. Aside from the potential race, I think there's also a 
> corner case where neigh_compat_output can return either with or 
> without freeing the skb depending on the return from 
> dev_hard_header... this may also be part of the race.
>
> Maybe I've missed something... but as far as I can see, this is just 
> about the only difference in code path taken between stuff that is 
> working and stuff that is occasionally not.
Ok - brief update. I've confirmed that under load, outgoing DHCPOFFER 
packets are being silently dropped. I don't know yet where.

Test scenario, what I do know, etc.:

Scenario:

Two systems; one Gb switch; one wifi router; one Blackberry client.

System A: Linux host; Asus P6T Deluxe V2/Sky2. eth1-> internet eth0-> 
internal (10.0.0.1/24).
Switch: HP Procurve unmanaged - one port connected to System A; another 
to the wifi router; another to System B.
System B: Win7; Asus M2N Deluxe SLI/ Nforce 5 (10.0.0.11)
Router: Wrt54g-tm (dd-wrt) Connected to switch & various wifi clients 
including a Blackberry. WEP enabled. (10.0.0.60)
Blackberry Curve 8320 (wifi enabled). (10.0.0.56 via dhcp lease)

Test that causes packet loss:

1. Turn off BB wifi.
2. Start copy of large files (4GB) from System B to an CIFS share on 
System A.
3. Start nethogs on system A.
4. Start tcpdump on the wifi router (interface br0 - wired 10.0.0.60 
connection)
5. Start wireshark on System A
6. tail system A /var/log/messages - watching for DHCP activity
7. When smb traffic load (incoming) exceeds 40,000KBPS (nethogs) - 
enable wifi on the blackberry.
8. Stop test after multiple DHCPDISCOVER/OFFER observed without REQUEST/ACK.

Results:

1. It seems that the problem occurs intermittently below 40,000KBPS, and 
consistently over that number as reported by nethogs. Lots of 
fluctuation, so figure that the 40k is approximate.
2. wireshark (system A) shows DHCPOFFER traffic outgoing.
3. tcpdump (wifi - wired incoming interface) does NOT show DHCPOFFER 
traffic when this problem occurs.
4. Both traces show arp activity during the DISCOVER/OFFER sequence.
5. There is no evidence of tx errors or packet drops, in any statistics 
I can find.

Thoughts:

I still think there's a race happening between the arp neighbor update 
and sky2. Might be higher up, but as I'm seeing the outgoing packets 
when sniffing eth0, can't be too much higher up. This problem seems to 
be exacerbated by the more recent patches, however I believe that this 
is a result of the higher throughput achievable with these patches. With 
the older set, I saw this problem less frequently, but found it much 
harder to get over the 40K RX number.

I am also seeing (as previously reported - but haven't sniffed yet) SMB 
ACK dropped packets, but only when traversing the wifi router. Not sure 
if this is related, but hey, you never know.
