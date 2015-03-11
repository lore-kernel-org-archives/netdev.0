From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: RFC: dsa: add support for multiple CPU ports
Date: Tue, 10 Mar 2015 17:01:49 -0700
Message-ID: <CAGVrzcZcLgMWuNJ9R_izuBRyyY21=ZJw+2Dk8RfxijGd2fMXNQ@mail.gmail.com>
References: <20150310190129.GB5636@codeaurora.org> <20150310193151.GE10838@lunn.ch>
 <20150310204021.GA2740@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Andrew Lunn <andrew@lunn.ch>, netdev <netdev@vger.kernel.org>,
	Guenter Roeck <linux@roeck-us.net>,
	Jonas Gorski <jogo@openwrt.org>
To: Mathieu Olivari <mathieu@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f173.google.com ([209.85.223.173]:33030 "EHLO
	mail-ie0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751259AbbCKACb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Mar 2015 20:02:31 -0400
Received: by iecvj10 with SMTP id vj10so1235601iec.0
        for <netdev@vger.kernel.org>; Tue, 10 Mar 2015 17:02:30 -0700 (PDT)
In-Reply-To: <20150310204021.GA2740@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2015-03-10 13:42 GMT-07:00 Mathieu Olivari <mathieu@codeaurora.org>:
> On Tue, Mar 10, 2015 at 08:31:51PM +0100, Andrew Lunn wrote:
>> > The third point would allow to perform operations currently limited to switch
>> > ports. Typically, "ethtool -S eth0" could return the corresponding port's MIB
>> > statistics in addition to the eth0 statistics.
>>
>> Hi Mathieu
>>
>> This already works with DSA. I have a WRT1900AC which has a 7 port
>> switch. With DSA i have:
>>
>> # ip link show
>> 1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT group default
>>     link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
>> 2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP mode DEFAULT group default qlen 532
>>     link/ether 94:10:3e:80:bc:f3 brd ff:ff:ff:ff:ff:ff
>> 3: eth1: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 532
>>     link/ether 52:33:3a:a7:c1:8a brd ff:ff:ff:ff:ff:ff
>> 4: lan4@eth0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode DEFAULT group default
>>     link/ether 94:10:3e:80:bc:f3 brd ff:ff:ff:ff:ff:ff
>> 5: lan3@eth0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode DEFAULT group default
>>     link/ether 94:10:3e:80:bc:f3 brd ff:ff:ff:ff:ff:ff
>> 6: lan2@eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP mode DEFAULT group default
>>     link/ether 94:10:3e:80:bc:f3 brd ff:ff:ff:ff:ff:ff
>> 7: lan1@eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP mode DEFAULT group default
>>     link/ether 94:10:3e:80:bc:f3 brd ff:ff:ff:ff:ff:ff
>> 8: internet@eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP mode DEFAULT group default
>>     link/ether 94:10:3e:80:bc:f3 brd ff:ff:ff:ff:ff:ff
>>
>> internet would be your WAN port in your diagram. I just named it the
>> same as the label on the case.
>>
>> I can get MIB statistics in the normal way for the DSA ports, e.g:
>>
>> root@wrt1900ac:~# ethtool -S lan1
>> NIC statistics:
>>      tx_packets: 153009
>>      tx_bytes: 13307317
>>      rx_packets: 161136
>>      rx_bytes: 21840683
>> ...
>>
>>       Andrew
>>
>>
>
> I was thinking about the MIB counters, maintained by the switch, on the CPU
> port(s).
>
> On this picture:
>
> +-----------+       +--------------------+
> |           | RGMII |                    |
> |       eth0+-------+ P0              P1 +------ 1000baseT MDI ("WAN")
> |        wan|       |      7-port     P2 +------ 1000baseT MDI ("LAN1")
> |   CPU     |       |      ethernet   P3 +------ 1000baseT MDI ("LAN2")
> |           | RGMII |      switch     P4 +------ 1000baseT MDI ("LAN3")
> |       eth1+-------+ P6   w/5 PHYs   P5 +------ 1000baseT MDI ("LAN4")
> |        lan|       |                    |
> +-----------+       +--------------------+
>           |     MDIO   |
>           \------------/
>
> We can see MIB stats of P1/P2/P3/P4/P5 by using ethtool -S. But as CPU
> ports don't have a net_device, there isn't a way to access MIB stats of
> P0 & P6.

That's right, we actually discussed that earlier during the swconfig
discussions, and one of the reasons why this is not exposed is because
it can be confusing for users, and the difference between your conduit
interfaces: eth0 or eth1, and their switch-facing interfaces: p0 or
p6, is that p0 and p6 are only useful for counters, but not for much
else, in particular not data passing.

>
> If we have the eth0 <--> P0 and eth1 <--> P6 relationship information in dts,
> we could use it to lookup which switch port is connected to this net_dev and
> show the corresponding counters when running "ethtool -S ethN".

Once we have that, interfaces p0 and p6 are not going to be
sending/receiving traffic, their conduit interfaces: eth0 and eth1,
will, and those could also maintain statistics in their own MIB (when
using unmodified Ethernet MAC drivers). I agree this is useful in xMII
cases to debug interface problems between a switch and a CPU Ethernet
MAC for instance.
-- 
Florian
