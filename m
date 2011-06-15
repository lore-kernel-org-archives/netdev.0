From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: No traffic flow with Marvell 88E6095F using DSA
Date: Wed, 15 Jun 2011 12:33:30 +0200
Message-ID: <20110615103330.GT11275@wantstofly.org>
References: <BANLkTi=SLBskJu1BuXJzocabpwi8tURwDw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Barry G <mr.scada@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fw.wantstofly.org ([80.101.37.227]:51816 "EHLO
	mail.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754435Ab1FOKai (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jun 2011 06:30:38 -0400
Content-Disposition: inline
In-Reply-To: <BANLkTi=SLBskJu1BuXJzocabpwi8tURwDw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 10, 2011 at 09:52:08AM -0700, Barry G wrote:

> Hello all,

Hello,


> We are trying to bring up a board with two Marvell 88E6095F chips and
> one 88E6185 chip using the Distributed Switch Architecture (DSA)
> facilities in the kernel.
> 
> We have a rough driver working, but we can't get traffic to flow in
> or out of the Marvell chips.
> 
> To simplify the system, I am trying to bring up only the chip
> attached to the CPU (88E6095F).  I have a dsa_chip_data with
> static struct dsa_chip_data switches[] = {
>    {
>       .sw_addr = 0x9,
>       .port_names = {
>          "eth%d", //0
>          "eth%d", //1
>          "eth%d", //2
>          "eth%d", //3
>          "eth%d", //4
>          "eth%d", //5
>          "eth%d", //6
>          "eth%d", //7
>          NULL,   //8
>          NULL,   //9
>          "cpu",   //10
>       },
>    }
> };
> 
> port 8 and 9 are DSA interfaces to other chips.
> 
> The host CPU is an Freescale 8308 hooked up to TSEC1.
> We are using the mdio bus from the processor to drive
> the mdio on the Marells.
> 
> Using this configuration with the driver shell I posted
> previously the system boots and I see:
> Distributed Switch Architecture driver version 0.1
> eth0[0]: detected a Marvell 88E6095/88E6095F switch
> dsa slave smi: probed

So far so good.


> All good.  If I run ip link show I get:
> # ip link show
> 1: lo: <LOOPBACK,UP,LOWER_UP> mtu 16436 qdisc noqueue
>     link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
> 2: bond0: <BROADCAST,MULTICAST,MASTER> mtu 1500 qdisc noop
>     link/ether 00:00:00:00:00:00 brd ff:ff:ff:ff:ff:ff
> 3: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast qlen 1000
>     link/ether 00:30:a7:aa:aa:01 brd ff:ff:ff:ff:ff:ff
> 4: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast qlen 1000
>     link/ether 00:30:a7:aa:aa:02 brd ff:ff:ff:ff:ff:ff
> 5: teql0: <NOARP> mtu 1500 qdisc noop qlen 100
>     link/void
> 6: tunl0: <NOARP> mtu 1480 qdisc noop
>     link/ipip 0.0.0.0 brd 0.0.0.0
> 7: eth2@eth0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue
>     link/ether 00:30:a7:aa:aa:01 brd ff:ff:ff:ff:ff:ff
> 8: eth3@eth0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue
>     link/ether 00:30:a7:aa:aa:01 brd ff:ff:ff:ff:ff:ff
> 9: eth4@eth0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue
>     link/ether 00:30:a7:aa:aa:01 brd ff:ff:ff:ff:ff:ff
> 10: eth5@eth0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue
>     link/ether 00:30:a7:aa:aa:01 brd ff:ff:ff:ff:ff:ff
> 11: eth6@eth0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue
>     link/ether 00:30:a7:aa:aa:01 brd ff:ff:ff:ff:ff:ff
> 12: eth7@eth0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue
>     link/ether 00:30:a7:aa:aa:01 brd ff:ff:ff:ff:ff:ff
> 13: eth8@eth0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue
>     link/ether 00:30:a7:aa:aa:01 brd ff:ff:ff:ff:ff:ff
> 14: eth9@eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue
>     link/ether 00:30:a7:aa:aa:01 brd ff:ff:ff:ff:ff:ff

This looks good also.


> This is after running "ip link set dev eth0 up" and "ip link set dev eth9 up"
> 
> Eth9 is hooked up to a cable.  Removing the cable results in the
> "eth9: link down" message and plugging it back in gives the "eth9:
> link up, 100 Mb/s, half duplex, flow control disabled".

half duplex, is that correct?


> So it looks like everything is stellar, but we can't get traffic
> to leave the device.  I configure eth9 with an address (192.168.1.50/24)
> and I try to ping 192.168.1.25 I get the following with tcpdump on eth9:
> 20:23:11.682628 arp who-has 192.168.1.25 tell 192.168.1.50 (repeats)
> 
> And on eth0 I see:
> 20:23:54.692701 00:30:a7:aa:aa:01 (oui Unknown) > Broadcast, ethertype
> Unknown (0x4038), length 46:
>         0x0000:  0000 0806 0001 0800 0604 0001 0030 a7aa  .............0..
>         0x0010:  aa01 c0a8 0132 0000 0000 0000 c0a8 0119  .....2..........
> 
> 
> However if I hook up to the port with wireshark I see nothing leaving
> the port.  Likewise if I attempt to ping into the device from 192.168.1.25
> I see nothing coming in on the tcpdump for eth0 or eth9.

As far as I can see from the dump below, the packets _are_ making it
out of eth0.  Some things to try would be to check the switch chip's
port stats to make sure that the packets are really received on its CPU
interface, and then to just basically check all of the switch chip's
address/vlan/etc table registers to see where it's routing the packets
to.  I assume you have docs for the switch chip?


thanks,
Lennert
