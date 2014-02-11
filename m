From: =?UTF-8?B?T3J0d2luIEdsw7xjaw==?= <odi@odi.ch>
Subject: Re: xfrm: is pmtu broken with ESP tunneling?
Date: Tue, 11 Feb 2014 21:20:40 +0100
Message-ID: <52FA8618.5030509@odi.ch>
References: <52F890D2.2060109@odi.ch> <20140211023258.GC11150@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140211023258.GC11150@order.stressinduktion.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/11/2014 03:32 AM, Hannes Frederic Sowa wrote:
>> net.ipv4.ip_no_pmtu_disc=1.
>
> This setting will shrink the path mtu to min_pmtu when a frag needed icmp is
> received.

The UDP+ESP encapsulation adds 60 bytes to the original packet size.

ifconfig wla0 shows an mtu of 1500.

The size of the first big packet on the interface:
net.ipv4.ip_no_pmtu_disc=1: packet length is 1300
net.ipv4.ip_no_pmtu_disc=0: packet length is 1500

Length is without the ESP wrapper and UDP encapsulation. The packets are so big 
that they can't even leave the wireless interface and never show up on the 
router. So no ICMP packets are received. PMTU can't work with initial packets of 
that size.

dump question: which layer discard these packets? qdisc? why no notification to 
the sender?

When I increase the mtu of the interface to 2000 with ifconfig, then I start 
seeing ICMP fragmentation needed from the next hop, indicating 1500 as the mtu 
as response to a 1560 byte UDP[ESP] packet.

The next UDP[ESP] packet is shorter: 1360 bytes. It gets hard to see what's 
going on after that, but the connection is still not working.

So, instead of somehow losing these packets on the way out of the interface 
should the kernel not start with a lower mtu in the first place? Now it seems it 
is trying with the maximum of the interface and expecting to scale down with 
pmtu - which can ever happen.

> Can you send a ip route get <ip> to the problematic target to see how
> far off the calculated value is?

That command doesn't return anything useful. No hint on the mtu here.

BTW, instead of disabling pmtu, setting mtu explicitly also helps:
ip route add 10.6.6.0/24 via ${localip} mtu 1300

Thanks,

Ortwin
