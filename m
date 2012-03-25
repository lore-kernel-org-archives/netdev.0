From: Marc Haber <mh+linux-kernel@zugschlus.de>
Subject: Linux 3.2 and 3.3 - "network is down" when pinging IPv6.
Date: Sun, 25 Mar 2012 10:37:42 +0200
Message-ID: <20120325083742.GB12998@torres.zugschlus.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from torres.zugschlus.de ([85.214.131.164]:59268 "EHLO
	torres.zugschlus.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753145Ab2CYIhn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Mar 2012 04:37:43 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

it's me again with a different issue regarding IPv6. This may be
related to the issue I reported in http://lkml.org/lkml/2012/3/22/59
and http://lkml.org/lkml/2012/3/25/8, but not necessarily. This was
really bizarrely fixed.

Again, this is seen on a single box with native IPv6 on eth0, routing
IPv4 and IPv6 to two bridges where KVM VMs are attached to. Setup:

myhost$ ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 16436 qdisc noqueue state UNKNOWN
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP qlen 1000
    link/ether 00:24:21:af:8f:cb brd ff:ff:ff:ff:ff:ff
    inet 172.24.53.218/32 scope global eth0
    inet6 2001:db8:40b7:9100::100:100/128 scope global
       valid_lft forever preferred_lft forever
    inet6 2001:db8:40b7:9100:6686:29f:cdfc:9713/128 scope global deprecated
       valid_lft forever preferred_lft forever
3: eth1: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN qlen 1000
    link/ether 00:24:21:af:8f:cc brd ff:ff:ff:ff:ff:ff
4: br0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP
    link/ether fe:54:00:23:47:46 brd ff:ff:ff:ff:ff:ff
    inet 192.168.145.254/24 brd 192.168.145.255 scope global br0
    inet6 2001:db8:40b7:9101::100:153/64 scope global deprecated
       valid_lft forever preferred_lft forever
    inet6 2001:db8:40b7:9101::100:100/64 scope global
       valid_lft forever preferred_lft forever
    inet6 fe80::1/64 scope link
       valid_lft forever preferred_lft forever
    inet6 fe80::c091:aaff:fe67:fd99/64 scope link
       valid_lft forever preferred_lft forever
5: br1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP
    link/ether fe:54:00:fa:de:7d brd ff:ff:ff:ff:ff:ff
    inet 192.168.146.254/24 brd 192.168.146.255 scope global br1
    inet6 2001:db8:40b7:9102::100:153/64 scope global deprecated
       valid_lft forever preferred_lft forever
    inet6 2001:db8:40b7:9102::100:100/64 scope global
       valid_lft forever preferred_lft forever
    inet6 fe80::1/64 scope link
       valid_lft forever preferred_lft forever
    inet6 fe80::2c46:f8ff:feb9:16bf/64 scope link
       valid_lft forever preferred_lft forever
7: vnet0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast master br0 state UNKNOWN qlen 500
    link/ether fe:54:00:23:47:46 brd ff:ff:ff:ff:ff:ff
    inet6 fe80::fc54:ff:fe23:4746/64 scope link
       valid_lft forever preferred_lft forever
8: vnet1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast master br0 state UNKNOWN qlen 500
    link/ether fe:54:00:67:86:fb brd ff:ff:ff:ff:ff:ff
    inet6 fe80::fc54:ff:fe67:86fb/64 scope link
       valid_lft forever preferred_lft forever
9: vnet2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast master br1 state UNKNOWN qlen 500
    link/ether fe:54:00:fa:de:7d brd ff:ff:ff:ff:ff:ff
    inet6 fe80::fc54:ff:fefa:de7d/64 scope link
       valid_lft forever preferred_lft forever
myhost$ ip r
default via 172.29.179.1 dev eth0
172.29.179.1 dev eth0  scope link
172.29.179.176 dev br0  scope link
192.168.145.0/24 dev br0  proto kernel  scope link  src 192.168.145.254
192.168.146.0/24 dev br1  proto kernel  scope link  src 192.168.146.254
myhost$ ip -6 r
2001:db8:40b7:9100::100:100 dev eth0  proto kernel  metric 256
2001:db8:40b7:9100:6686:29f:cdfc:9713 dev eth0  proto kernel  metric 256
2001:db8:40b7:9101::/64 dev br0  proto kernel  metric 256
2001:db8:40b7:9102::/64 dev br1  proto kernel  metric 256
fe80::/64 dev br0  proto kernel  metric 256
fe80::/64 dev br1  proto kernel  metric 256
fe80::/64 dev eth0  proto kernel  metric 256
fe80::/64 dev vnet0  proto kernel  metric 256
fe80::/64 dev vnet1  proto kernel  metric 256
fe80::/64 dev vnet2  proto kernel  metric 256
default via fe80::1 dev eth0  metric 1024
myhost$ sudo brctl show
bridge name     bridge id               STP enabled     interfaces
br0             8000.fe5400234746       no              vnet0
                                                        vnet1
br1             8000.fe5400fade7d       no              vnet2
myhost$

On br0/vnet0, there is a Linux VM with the following IP configuration:
myvm$ ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 16436 qdisc noqueue state UNKNOWN
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP qlen 1000
    link/ether 52:54:00:23:47:46 brd ff:ff:ff:ff:ff:ff
    inet 172.29.179.176 peer 192.168.145.254/32 scope global eth0
    inet6 2001:db8:40b7:9101::2:53/64 scope global deprecated
       valid_lft forever preferred_lft forever
    inet6 2001:db8:40b7:9101::1:53/64 scope global deprecated
       valid_lft forever preferred_lft forever
    inet6 2001:db8:40b7:9101::6667/64 scope global deprecated
       valid_lft forever preferred_lft forever
    inet6 2001:db8:40b7:9101::1/64 scope global
       valid_lft forever preferred_lft forever
    inet6 2001:db8:40b7:9101:5054:ff:fe23:4746/64 scope global
       valid_lft forever preferred_lft forever
    inet6 fe80::5054:ff:fe23:4746/64 scope link
       valid_lft forever preferred_lft forever
3: tun0: <POINTOPOINT,MULTICAST,NOARP,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UNKNOWN qlen 100
    link/none
    inet 10.11.12.1 peer 10.11.12.2/32 scope global tun0
4: tun1: <POINTOPOINT,MULTICAST,NOARP,UP,LOWER_UP> mtu 1498 qdisc pfifo_fast state UNKNOWN qlen 100
    link/none
    inet 10.11.25.1 peer 10.11.25.2/32 scope global tun1
myvm$ ip r
default via 192.168.145.254 dev eth0
10.11.12.0/24 via 10.11.12.2 dev tun0
10.11.12.2 dev tun0  proto kernel  scope link  src 10.11.12.1
10.11.25.0/24 via 10.11.25.2 dev tun1
10.11.25.2 dev tun1  proto kernel  scope link  src 10.11.25.1
192.168.145.254 dev eth0  proto kernel  scope link  src 172.29.179.176
myvm$ ip -6 r
2001:db8:40b7:9101::/64 dev eth0  proto kernel  metric 256
fe80::/64 dev eth0  proto kernel  metric 256
default via fe80::c091:aaff:fe67:fd99 dev eth0  proto kernel  metric 1024  expires 1435sec
myvm$

Please note that myvm has both 2001:db8:40b7:9101::1/64 and
2001:db8:40b7:9101::1:53/64 configured.

Most of the time (but not always!), myhost does not even try to send
out a packet when I ping6 2001:db8:40b7:9101::1. Instead, ping6 says
that sendmsg cannot send the packet ("network is down").
2001:db8:40b7:9101::1 is not in the neighbor table, and myhost does not
send out a neighbor solicitation. It simple immediately claims that
the network is down.

At the same time, ping6'ing 2001:db8:40b7:9101::1:53 works just fine.
IPv4 is not affected as well.

I can see similiar behavior with other VMs as well, on both br0 and br1.

Now for the real bizarre solution: Setting a more specific route for
2a01:238:40b7:9101::/65 immediately fixes the issue. Same holds for
br1 and the route 2a01:238:40b7:9102::/65.

The IPv6 routing table on myhost now looks like
myhost$ ip -6 r
2001:db8:40b7:9100::100:100 dev eth0  proto kernel  metric 256 
2001:db8:40b7:9100:6686:29f:cdfc:9713 dev eth0  proto kernel  metric 256 
2001:db8:40b7:9101::/65 dev br0  metric 1024 
2001:db8:40b7:9101::/64 dev br0  proto kernel  metric 256 
2001:db8:40b7:9102::/65 dev br1  metric 1024 
2001:db8:40b7:9102::/64 dev br1  proto kernel  metric 256 
fe80::/64 dev br0  proto kernel  metric 256 
fe80::/64 dev br1  proto kernel  metric 256 
fe80::/64 dev eth0  proto kernel  metric 256 
fe80::/64 dev vnet0  proto kernel  metric 256 
fe80::/64 dev vnet1  proto kernel  metric 256 
fe80::/64 dev vnet2  proto kernel  metric 256 
default via fe80::1 dev eth0  metric 1024 
and everything works as designed.

Why do I need the /65 route? Why can I ping one address from the /64
network and not another?

If you need more information, please say so.

Greetings
Marc

-- 
-----------------------------------------------------------------------------
Marc Haber         | "I don't trust Computers. They | Mailadresse im Header
Mannheim, Germany  |  lose things."    Winona Ryder | Fon: *49 621 31958061
Nordisch by Nature |  How to make an American Quilt | Fax: *49 621 31958062
