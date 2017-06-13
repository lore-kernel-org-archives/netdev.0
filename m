From: Matthias May <matthias.may@neratec.com>
Subject: Re: Toggling link state breaks network connectivity
Date: Tue, 13 Jun 2017 16:40:30 +0200
Message-ID: <1edc2647-9164-0fb0-d9d3-c5c558143996@neratec.com>
References: <927c2f12-0d1b-1e80-fede-ad9abe807222@free.fr>
 <aef8dfb4-d11a-2859-3589-f477cd150071@neratec.com>
 <107a093d-ff5d-c138-fc03-5f7fc93ad6b2@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>, Mans Rullgard <mans@mansr.com>,
        Thibaud Cornic <thibaud_cornic@sigmadesigns.com>
To: Mason <slash.tmp@free.fr>,
        Zefir Kurtisi <zefir.kurtisi@neratec.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.neratec.com ([46.140.151.2]:50788 "EHLO mail.neratec.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752326AbdFMOkj (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 13 Jun 2017 10:40:39 -0400
In-Reply-To: <107a093d-ff5d-c138-fc03-5f7fc93ad6b2@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 13/06/17 16:20, Mason wrote:
> On 13/06/2017 11:39, Matthias May wrote:
>> On 12/06/17 15:22, Mason wrote:
>>> Hello,
>>>
>>> I am using the following drivers for Ethernet connectivity.
>>> drivers/net/ethernet/aurora/nb8800.c
>>> drivers/net/phy/at803x.c
>>>
>>> Pulling the cable and plugging it back works as expected.
>>> (I can ping both before and after.)
>>>
>>> However, if I toggle the link state in software (using ip link set),
>>> the board loses network connectivity.
>>>
>>> # Statically assign IP address
>>> ip addr add 172.27.64.77/18 brd 172.27.127.255 dev eth0
>>> # Set link state to "up"
>>> ip link set eth0 up
>>> # ping -c 3 172.27.64.1 > /tmp/v1
>>>
>>> PING 172.27.64.1 (172.27.64.1): 56 data bytes
>>> 64 bytes from 172.27.64.1: seq=0 ttl=64 time=18.321 ms
>>>
>>> --- 172.27.64.1 ping statistics ---
>>> 3 packets transmitted, 1 packets received, 66% packet loss
>>> round-trip min/avg/max = 18.321/18.321/18.321 ms
>>>
>>>
>>> 172.27.64.1 is a desktop system.
>>> Running
>>> % tcpdump -n -i eth1-boards ether host 00:16:e8:4d:7f:c4
>>> on the desktop, I get:
>>>
>>> 15:01:45.187346 ARP, Request who-has 172.27.64.1 tell 172.27.64.77, length 46
>>> 15:01:45.187359 ARP, Reply 172.27.64.1 is-at 00:15:17:24:e0:81, length 28
>>> 15:01:45.194633 IP 172.27.64.77 > 172.27.64.1: ICMP echo request, id 41219, seq 0, length 64
>>> 15:01:45.194662 IP 172.27.64.1 > 172.27.64.77: ICMP echo reply, id 41219, seq 0, length 64
>>> 15:01:50.198564 ARP, Request who-has 172.27.64.77 tell 172.27.64.1, length 28
>>> 15:01:50.205929 IP 172.27.64.77 > 172.27.64.1: ICMP echo request, id 41219, seq 1, length 64
>>> 15:01:50.205951 IP 172.27.64.1 > 172.27.64.77: ICMP echo reply, id 41219, seq 1, length 64
>>> 15:01:50.213217 IP 172.27.64.77 > 172.27.64.1: ICMP echo request, id 41219, seq 2, length 64
>>> 15:01:50.213232 IP 172.27.64.1 > 172.27.64.77: ICMP echo reply, id 41219, seq 2, length 64
>>> 15:01:51.198563 ARP, Request who-has 172.27.64.77 tell 172.27.64.1, length 28
>>> 15:01:51.209586 ARP, Reply 172.27.64.77 is-at 00:16:e8:4d:7f:c4, length 46
>>> 15:01:51.209598 ARP, Reply 172.27.64.77 is-at 00:16:e8:4d:7f:c4, length 46
>>>
>>> Packet #1: the board asks for the desktop's MAC address
>>> Packet #2: the desktop replies instantly
>>> Packet #3: the board sends the first ping
>>> Packet #4: the desktop replies instantly
>>> Then the board goes quiet for a long time (why???)
>>> Packet #5: the desktop asks for the board's MAC address (doesn't it have it already?)
>>> Packet #6: this seems to unwedge the board, which sends the second ping
>>> Packet #7: the desktop replies instantly
>>> Packet #8: the board sends the third ping
>>> Packet #9: the desktop replies instantly
>>> Packet #10: the desktop asks again for the board's MAC address
>>> Packet #11 and #12: the board answers twice (for the old and new requests?)
>>>
>>> Some oddities, but it seems to work.
>>>
>>> Now toggle the link state:
>>>
>>> % ip link set eth0 down
>>> % ip link set eth0 up
>>> % ping -c 3 172.27.64.1 > /tmp/v2
>>>
>>> PING 172.27.64.1 (172.27.64.1): 56 data bytes
>>>
>>> --- 172.27.64.1 ping statistics ---
>>> 3 packets transmitted, 0 packets received, 100% packet loss
>>>
>>>
>>> On the desktop, I see
>>>
>>> 15:14:03.900162 ARP, Request who-has 172.27.64.1 tell 172.27.64.77, length 46
>>> 15:14:03.900175 ARP, Reply 172.27.64.1 is-at 00:15:17:24:e0:81, length 28
>>> 15:14:05.017189 ARP, Request who-has 172.27.64.1 tell 172.27.64.77, length 46
>>> 15:14:05.017200 ARP, Reply 172.27.64.1 is-at 00:15:17:24:e0:81, length 28
>>> 15:14:06.030531 ARP, Request who-has 172.27.64.1 tell 172.27.64.77, length 46
>>> 15:14:06.030541 ARP, Reply 172.27.64.1 is-at 00:15:17:24:e0:81, length 28
>>>
>>> So basically, the board is asking the desktop for its MAC address,
>>> and the desktop is answering immediately. But the board doesn't seem
>>> to be getting the replies... Any ideas, or words of wisdom, as they say?
>>
>> You might want to read this thread:
>> https://www.mail-archive.com/netdev@vger.kernel.org/msg133896.html
>> The symptoms you describe are pretty much what we had at one point.
> 
> Hello Matthias,
> 
> Yes, I remember discussing the issue with Zefir.
> https://www.mail-archive.com/netdev@vger.kernel.org/msg147369.html
> 
> Do you think I should apply Zefir's patch?
> 
> In an attempt to remove the Atheros driver from the equation,
> I used the generic PHY driver (I didn't build the Atheros
> driver at all). But this had no impact on the issue.
> 
> Regards.
> 

Isn't this patch already accepted?
I sent the link more as reference to try to check what we checked to detect the underlying issue.
