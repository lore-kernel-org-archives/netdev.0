From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH] net: dsa: fix mv88e6xxx switches
Date: Sat, 23 Jan 2016 19:06:22 +0000
Message-ID: <20160123190622.GA10826@n2100.arm.linux.org.uk>
References: <E1aMvmm-0006G3-8T@rmk-PC.arm.linux.org.uk>
 <20160123181526.GD3880@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.arm.linux.org.uk ([78.32.30.218]:58961 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753832AbcAWTG3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Jan 2016 14:06:29 -0500
Content-Disposition: inline
In-Reply-To: <20160123181526.GD3880@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 23, 2016 at 07:15:26PM +0100, Andrew Lunn wrote:
> Thanks for digging into this.

I hope you saw v2, which is functionally identical.

> I think this is a step towards a solution, but does not solve all the
> problems.
> 
> e.g. I have a switch interface lan0 with the IP address
> 192.168.10.2. I can ping this address from another host. I then take
> the IP address off the interface, create a br0 device, add lan0 to the
> bridge, and put 192.168.10.2 onto the bridge. I should be able to then
> ping the address. But it does not work.

That works for me.  Maybe it's differences in the switch device?  I
seem to remember you said your switch was an older generation than
mine (88E6176).

root@clearfog:~# brctl show br0
bridge name     bridge id               STP enabled     interfaces
br0             8000.005043020202       no              lan1
                                                        lan2
                                                        lan3
                                                        lan4
                                                        lan5
                                                        lan6
root@clearfog:~# ip addr show|grep 192.168.254
root@clearfog:~# ip addr add 192.168.254.3/24 dev br0
root@clearfog:~# ping 192.168.254.2
PING 192.168.254.2 (192.168.254.2) 56(84) bytes of data.
64 bytes from 192.168.254.2: icmp_seq=1 ttl=255 time=0.648 ms
^C
--- 192.168.254.2 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 0.648/0.648/0.648/0.000 ms
root@clearfog:~# ip addr del 192.168.254.3/24 dev br0
root@clearfog:~# brctl delif br0 lan1
root@clearfog:~# ip addr add 192.168.254.3/24 dev lan1
root@clearfog:~# ping 192.168.254.2
PING 192.168.254.2 (192.168.254.2) 56(84) bytes of data.
64 bytes from 192.168.254.2: icmp_seq=1 ttl=255 time=0.331 ms
^C
--- 192.168.254.2 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 0.331/0.331/0.331/0.000 ms
root@clearfog:~# ip addr del 192.168.254.3/24 dev lan1
root@clearfog:~# brctl addif br0 lan1
root@clearfog:~# ip addr add 192.168.254.3/24 dev br0
root@clearfog:~# ping 192.168.254.2
PING 192.168.254.2 (192.168.254.2) 56(84) bytes of data.
64 bytes from 192.168.254.2: icmp_seq=1 ttl=255 time=0.630 ms
^C
--- 192.168.254.2 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 0.630/0.630/0.630/0.000 ms

I have no other patches for DSA other than the v2 I posted on this
kernel.

I'd suggest adding back the debugfs register dumping so you can get
some diagnostics, and work out what's different in the configuration
between a working kernel and a non-working kernel:

https://github.com/vivien/linux/commit/b23c6568011c84b80a8f5632ac819a5dbdca2dc1.patch

However, what I do notice is that trying to use vlans is a complete
fail - the switch strips _all_ vlan tags off the outgoing packets
no matter how I setup a vlan, whether it's on br0, or on a switch
port:

Packet as observed on a host connected to the switch port with no
vlan capability:
         0x0000:  ffff ffff ffff 0050 4302 0202 0806 0001
         0x0010:  0800 0604 0001 0050 4302 0202 c0a8 fe03 ...

Packet observed on Armada 388's eth interface connected to the 88E6176
switch:
         0x0000:  ffff ffff ffff 0050 4302 0202 dada 0000
         0x0010:  6030 0800 0806 0001 0800 0604 0001 0050 ...

The packet should appear on the wire with the 8100 0800 vlan protocol
ID + tag, but it appears with the vlan protocol and tag stripped.  So
there's yet more issues here.

Incoming packets from the interface appear to be dropped as far as I
can tell - the response to those ARP packets doesn't appear, though
I'm not convinced that I've been able to get the only vlan-capable
device on that side of the network to be setup correctly for vlans -
but obviously it's a total loss if vlan transmission isn't working.

-- 
RMK's Patch system: http://www.arm.linux.org.uk/developer/patches/
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
