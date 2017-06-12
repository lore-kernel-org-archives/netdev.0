From: Mason <slash.tmp@free.fr>
Subject: Re: Toggling link state breaks network connectivity
Date: Mon, 12 Jun 2017 20:58:10 +0200
Message-ID: <424ec742-b349-4c1a-7ecc-2a5d70ac596e@free.fr>
References: <927c2f12-0d1b-1e80-fede-ad9abe807222@free.fr>
 <2c12bc7a-fd57-3d3d-7dc0-f522cfadd042@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Andrew Lunn <andrew@lunn.ch>, Mans Rullgard <mans@mansr.com>,
        Thibaud Cornic <thibaud_cornic@sigmadesigns.com>
To: Florian Fainelli <f.fainelli@gmail.com>,
        netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2-g21.free.fr ([212.27.42.2]:20699 "EHLO smtp2-g21.free.fr"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752050AbdFLS62 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 12 Jun 2017 14:58:28 -0400
In-Reply-To: <2c12bc7a-fd57-3d3d-7dc0-f522cfadd042@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Florian,

On 12/06/2017 18:38, Florian Fainelli wrote:

> On 06/12/2017 06:22 AM, Mason wrote:
>
>> I am using the following drivers for Ethernet connectivity.
>> drivers/net/ethernet/aurora/nb8800.c
>> drivers/net/phy/at803x.c
>>
>> Pulling the cable and plugging it back works as expected.
>> (I can ping both before and after.)
>>
>> However, if I toggle the link state in software (using ip link set),
>> the board loses network connectivity.
>>
>> # Statically assign IP address
>> ip addr add 172.27.64.77/18 brd 172.27.127.255 dev eth0
>> # Set link state to "up"
>> ip link set eth0 up
>> # ping -c 3 172.27.64.1 > /tmp/v1
>>
>> PING 172.27.64.1 (172.27.64.1): 56 data bytes
>> 64 bytes from 172.27.64.1: seq=0 ttl=64 time=18.321 ms
> 
> This delay seems abnormally long unless you are purposely introducing
> delay (e.g: with cls_netem) or this is a really remote host, does not
> seem to be based on your traces later on.

172.27.64.1 and 172.27.64.77 are connected to the
same switch. Purely local traffic. It seems to me
that the ARP request/reply could explain the delay.

Start op at 45.187346
Receive ICMP echo reply at 45.194662
Hmmm, that's only 7 ms


>> 172.27.64.1 is a desktop system.
>> Running
>> % tcpdump -n -i eth1-boards ether host 00:16:e8:4d:7f:c4
>> on the desktop, I get:
>>
>> 15:01:45.187346 ARP, Request who-has 172.27.64.1 tell 172.27.64.77, length 46
>> 15:01:45.187359 ARP, Reply 172.27.64.1 is-at 00:15:17:24:e0:81, length 28
>> 15:01:45.194633 IP 172.27.64.77 > 172.27.64.1: ICMP echo request, id 41219, seq 0, length 64
>> 15:01:45.194662 IP 172.27.64.1 > 172.27.64.77: ICMP echo reply, id 41219, seq 0, length 64
>> 15:01:50.198564 ARP, Request who-has 172.27.64.77 tell 172.27.64.1, length 28
>> 15:01:50.205929 IP 172.27.64.77 > 172.27.64.1: ICMP echo request, id 41219, seq 1, length 64
>> 15:01:50.205951 IP 172.27.64.1 > 172.27.64.77: ICMP echo reply, id 41219, seq 1, length 64
>> 15:01:50.213217 IP 172.27.64.77 > 172.27.64.1: ICMP echo request, id 41219, seq 2, length 64
>> 15:01:50.213232 IP 172.27.64.1 > 172.27.64.77: ICMP echo reply, id 41219, seq 2, length 64
>> 15:01:51.198563 ARP, Request who-has 172.27.64.77 tell 172.27.64.1, length 28
>> 15:01:51.209586 ARP, Reply 172.27.64.77 is-at 00:16:e8:4d:7f:c4, length 46
>> 15:01:51.209598 ARP, Reply 172.27.64.77 is-at 00:16:e8:4d:7f:c4, length 46
>>
>> Packet #1: the board asks for the desktop's MAC address
>> Packet #2: the desktop replies instantly
>> Packet #3: the board sends the first ping
>> Packet #4: the desktop replies instantly
>> Then the board goes quiet for a long time (why???)
>> Packet #5: the desktop asks for the board's MAC address (doesn't it have it already?)
>> Packet #6: this seems to unwedge the board, which sends the second ping
>> Packet #7: the desktop replies instantly
>> Packet #8: the board sends the third ping
>> Packet #9: the desktop replies instantly
>> Packet #10: the desktop asks again for the board's MAC address
>> Packet #11 and #12: the board answers twice (for the old and new requests?)
>>
>> Some oddities, but it seems to work.
>>
>> Now toggle the link state:
>>
>> % ip link set eth0 down
>> % ip link set eth0 up
>> % ping -c 3 172.27.64.1 > /tmp/v2
>>
>> PING 172.27.64.1 (172.27.64.1): 56 data bytes
>>
>> --- 172.27.64.1 ping statistics ---
>> 3 packets transmitted, 0 packets received, 100% packet loss
>>
>>
>> On the desktop, I see
>>
>> 15:14:03.900162 ARP, Request who-has 172.27.64.1 tell 172.27.64.77, length 46
>> 15:14:03.900175 ARP, Reply 172.27.64.1 is-at 00:15:17:24:e0:81, length 28
>> 15:14:05.017189 ARP, Request who-has 172.27.64.1 tell 172.27.64.77, length 46
>> 15:14:05.017200 ARP, Reply 172.27.64.1 is-at 00:15:17:24:e0:81, length 28
>> 15:14:06.030531 ARP, Request who-has 172.27.64.1 tell 172.27.64.77, length 46
>> 15:14:06.030541 ARP, Reply 172.27.64.1 is-at 00:15:17:24:e0:81, length 28
>>
>> So basically, the board is asking the desktop for its MAC address,
>> and the desktop is answering immediately. But the board doesn't seem
>> to be getting the replies... Any ideas, or words of wisdom, as they say?
> 
> - check the Ethernet MAC counters to see if there is packet loss, or
> error, or both

I'll take a look, but I don't expect any packet loss
(LAN traffic on an idle switch).

> - consult with your HW engineers for possible flaws in your
> ndo_open/ndo_close paths and possible interactions with the MAC/PHY
> clocks, or reset etc.

(The HW engineers have no knowledge of Linux use-cases.)
The crazy thing is that I can use the same driver on the
previous chip, and I don't see this behavior... Will
retest tomorrow to be sure. What does change between
the two chips are a few clock frequencies though.
So maybe some race is now consistently lost on the
new chip...

> - see if your PHY needs a complete re-init after an up/down sequence and
> if you are doing this properly

Thanks for these suggestions. I'll take a closer look
tomorrow.

Regards.
