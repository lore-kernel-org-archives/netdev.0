From: Stefan Hajnoczi <stefanha@gmail.com>
Subject: Re: [Qemu-devel] macvlan/macvtap: guest/host cannot communicate when
 network cable is unplugged
Date: Wed, 29 Aug 2012 08:03:08 +0100
Message-ID: <CAJSP0QWV_RmEteRMUj4U2B9QRjGMkKL=AG3iyKyqEYiqGftFWg@mail.gmail.com>
References: <503D486B.1030208@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: qemu-devel@nongnu.org, kaber@trash.net,
	"Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org
To: ching <lsching17@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lpp01m010-f46.google.com ([209.85.215.46]:38435 "EHLO
	mail-lpp01m010-f46.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751726Ab2H2HDK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Aug 2012 03:03:10 -0400
Received: by lagy9 with SMTP id y9so225219lag.19
        for <netdev@vger.kernel.org>; Wed, 29 Aug 2012 00:03:09 -0700 (PDT)
In-Reply-To: <503D486B.1030208@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 28, 2012 at 11:38 PM, ching <lsching17@gmail.com> wrote:
> Hi all,
>
> I try to setup guest network with macvlan, as guest cannot communicate with host directly, i try to workaround by configuring host to using a macvlan interface
>
> host: Gentoo x64, kernel 3.5.2, qemu-kvm 1.1.1-r1, libvirt 0.9.13
> guest: Ubuntu 12.04, kernel 3.4.9, virtio-net
>
> The host is using macvlan (interface name: znet0, ip: 192.168.1.2, bridge mode)
>
> The guest is using macvtap managed by libvirt (interface name: macvtap0, ip: 192.168.1.184, bridge mode, with vhost)
>
>
> I am facing a strange problem that the guest/host can communicate only when the network cable of the ethernet adapter is connected.
>
>
>
>
> The network config of the host
>
>     $ifconfig
>
>     eth0      Link encap:Ethernet  HWaddr f4:6d:xx:xx:xx:xx
>               inet6 addr: fe80::xx:xx:xx:xx/64 Scope:Link
>               UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
>               RX packets:86507 errors:0 dropped:0 overruns:0 frame:0
>               TX packets:55940 errors:0 dropped:0 overruns:0 carrier:0
>               collisions:0 txqueuelen:1000
>               RX bytes:126005746 (120.1 MiB)  TX bytes:4394225 (4.1 MiB)
>
>     macvtap0  Link encap:Ethernet  HWaddr 52:54:xx:xx:xx:xx
>               inet6 addr: fe80::xx:xx:xx:xx/64 Scope:Link
>               UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
>               RX packets:70 errors:0 dropped:0 overruns:0 frame:0
>               TX packets:84 errors:0 dropped:0 overruns:0 carrier:0
>               collisions:0 txqueuelen:500
>               RX bytes:9036 (8.8 KiB)  TX bytes:14734 (14.3 KiB)
>
>     znet0     Link encap:Ethernet  HWaddr 00:60:xx:xx:xx:xx
>               inet addr:192.168.1.2  Bcast:192.168.1.255  Mask:255.255.255.0
>               inet6 addr: 2002:xx:xx:xx:xx/64 Scope:Global
>               inet6 addr: fe80:xx:xx:xx:xx/64 Scope:Link
>               UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
>               RX packets:4463190 errors:0 dropped:0 overruns:0 frame:0
>               TX packets:12527522 errors:0 dropped:0 overruns:0 carrier:0
>               collisions:0 txqueuelen:0
>               RX bytes:3959213697 (3.6 GiB)  TX bytes:18590336476 (17.3 GiB)
>
> $ip -d link show
>
>     10: znet0@eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP mode DEFAULT
>         link/ether 00:60:xx:xx:xx:xx brd ff:ff:ff:ff:ff:ff
>         macvlan  mode bridge
>     17: macvtap0@eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UNKNOWN mode DEFAULT qlen 500
>         link/ether 52:54:xx:xx:xx:xx brd ff:ff:ff:ff:ff:ff
>         macvtap  mode bridge
>
> libvirt config of the guest network
>
>     <interface type='direct'>
>       <mac address='52:54:xx:xx:xx:xx'/>
>       <source dev='eth0' mode='bridge'/>
>       <model type='virtio'/>
>       <address type='pci' domain='0x0000' bus='0x00' slot='0x08' function='0x0'/>
>     </interface>
>
> The network config of the guest
>
> eth0      Link encap:Ethernet  HWaddr 52:54:xx:xx:xx:xx
>           inet addr:192.168.1.184  Bcast:192.168.1.255  Mask:255.255.255.0
>           inet6 addr: 2002:xx:xx:xx:xxx/64 Scope:Global
>           inet6 addr: 2002:xx:xx:xx:xx/64 Scope:Global
>           inet6 addr: fe80:xx:xx:xx:xx/64 Scope:Link
>           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
>           RX packets:25 errors:0 dropped:0 overruns:0 frame:0
>           TX packets:66 errors:0 dropped:0 overruns:0 carrier:0
>           collisions:0 txqueuelen:1000
>           RX bytes:3108 (3.1 KB)  TX bytes:13066 (13.0 KB)
>
> when network cable of host is plugged in
>
> $ ping 192.168.1.184
> PING 192.168.1.184 (192.168.1.184) 56(84) bytes of data.
> 64 bytes from 192.168.1.184: icmp_req=1 ttl=64 time=0.314 ms
> 64 bytes from 192.168.1.184: icmp_req=2 ttl=64 time=0.253 ms
> 64 bytes from 192.168.1.184: icmp_req=3 ttl=64 time=0.230 ms
>
>
> Afterward, i unplugged the network cable to ensure that packet is not routed via external router, but the test seems failed.
>
> $ ping 192.168.1.184
> PING 192.168.1.184 (192.168.1.184) 56(84) bytes of data.
> From 192.168.1.2: icmp_seq=10 Destination Host Unreachable
> From 192.168.1.2: icmp_seq=11 Destination Host Unreachable
>
>
> Do anyone have similar problem? Am i missing something?

Can you try the same test with two macvlan interfaces on the host (no
macvtap)?  You may need to use the ping -I <interface-address>
argument to force the ping source address to a specific macvlan
interface.

If you see the same problem, it may just be the macvlan design - it is
stacked on top of eth0 and might not work when eth0 is down.  CCing
macvlan/macvtap folks.

Stefan
