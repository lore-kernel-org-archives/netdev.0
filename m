From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: BUG: IPv6 stops working after a while, needs ip ne del command
 to reset
Date: Tue, 17 Aug 2010 15:15:20 +0200
Message-ID: <1282050920.2448.47.camel@edumazet-laptop>
References: <alpine.DEB.1.10.1008131952470.19570@red.crap.retrofitta.se>
	 <1281953960.2524.23.camel@edumazet-laptop>
	 <alpine.DEB.1.10.1008161224510.13728@red.crap.retrofitta.se>
	 <alpine.DEB.1.10.1008170719180.21857@red.crap.retrofitta.se>
	 <1282024802.2487.687.camel@edumazet-laptop>
	 <alpine.DEB.1.10.1008171053230.21857@red.crap.retrofitta.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Thomas Habets <thomas@habets.pp.se>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.1.10.1008171053230.21857@red.crap.retrofitta.se>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mardi 17 ao=C3=BBt 2010 =C3=A0 13:08 +0200, Thomas Habets a =C3=A9cr=
it :
> Aha! New development:
>=20
> The Cisco router can't discover the address of the Linux box because =
Linux=20
> doesn't seem to be listening to ff02::1 (all-nodes).
>=20
> -----------
> cisco#ping ff02::1
> Output Interface: GigabitEthernet1/2
> Type escape sequence to abort.
> Sending 5, 100-byte ICMP Echos to FF02::1, timeout is 2 seconds:
> Packet sent with a source address of=20
> FE80::222:55FF:FE17:4B80%GigabitEthernet1/2
>=20
> Request 0 timed out
> Request 1 timed out
> Request 2 timed out
> Request 3 timed out
> Request 4 timed out
> Success rate is 0 percent (0/5)
> 0 multicast replies and 0 errors.
> ------------
>=20
> If i set promisc mode on the interface (tcpdump without -p or "ip lin=
k set=20
> promisc on eth0") it starts working (both normal ping and the above p=
ing=20
> from the Cisco to ff02::1). It continues working until I guess the=20
> neighbor table on the cisco times out (leaving it overnight seems to=20
> be enough idle time) or I manually do a "clear ipv6 neig".
>=20
> So great news! I can reproduce it at will with no waiting time! Right=
=20
> after rebooting the Linux box I run "clear ipv6 neighbors" and Linux =
can=20
> no longer ping the router. Tested reproducing it immediately after re=
boot.
>=20
> The Linux box itself can ping ff02::1%eth0 with no problem, and gets=20
> replies from the fe80:: link-local of itself and the Cisco router.
>=20
> So could this be that for some reason the NIC isn't listening=20
> multicast MAC address 33:33:ff:5c:00:02 ?
>=20

That would be very surprising, but who knows...

Can you try : "ifconfig eth0 allmulti"

Maybe tg3 driver has a problem building the mulicast table for this 571=
5


> Is there a way to see the list of addresses that get past the NIC? Or=
 can=20
> this perhaps be filtered after the NIC, but before tcpdump -p?
>=20
> Since this now looks like a NIC thing, here's some info about eth0:
>=20
> $ dmesg | grep eth0
> [...]
> tg3 0000:03:04.0: eth0: Tigon3 [partno(N/A) rev 9003] (PCIX:133MHz:64=
-bit)=20
> MAC address 00:24:81:a3:44:24
> tg3 0000:03:04.0: eth0: attached PHY is 5714 (10/100/1000Base-T Ether=
net)=20
> (WireSpeed[1])
> tg3 0000:03:04.0: eth0: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[1] TSOc=
ap[1]
> tg3 0000:03:04.0: eth0: dma_rwctrl[76148000] dma_mask[40-bit]
> [...]
>=20
> $ sudo lspci -v -s 03:04.0
> 03:04.0 Ethernet controller: Broadcom Corporation NetXtreme BCM5715=20
> Gigabit Ethernet (rev a3)
> Subsystem: Hewlett-Packard Company NC326i PCIe Dual Port Gigabit Serv=
er=20
> Adapter
> Flags: bus master, 66MHz, medium devsel, latency 64, IRQ 47
> Memory at fdff0000 (64-bit, non-prefetchable) [size=3D64K]
> Memory at fdfe0000 (64-bit, non-prefetchable) [size=3D64K]
> Expansion ROM at <ignored> [disabled]
> Capabilities: [40] PCI-X non-bridge device
> Capabilities: [48] Power Management version 2
> Capabilities: [50] Vital Product Data <?>
> Capabilities: [58] Message Signalled Interrupts: Mask- 64bit+ Queue=3D=
0/3=20
> Enable+
> Kernel driver in use: tg3
> Kernel modules: tg3
>=20
> $ sudo ifconfig eth0
> eth0      Link encap:Ethernet  HWaddr 00:24:81:a3:44:24
>            inet addr:x.x.x.x  Bcast:x.x.x.x=20
> Mask:255.255.255.252
>            inet6 addr: 2a00:800:752:1::5c:2/112 Scope:Global
>            inet6 addr: fe80::224:81ff:fea3:4424/64 Scope:Link
>            UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
>            RX packets:928 errors:0 dropped:0 overruns:0 frame:0
>            TX packets:834 errors:0 dropped:0 overruns:0 carrier:0
>            collisions:0 txqueuelen:1000
>            RX bytes:142281 (138.9 KiB)  TX bytes:154616 (150.9 KiB)
>            Interrupt:16
>=20
> I have doublechecked iptables, ip6tables and arptables, and they are=20
> either not compiled in the kernel or they are empty ACCEPT lists.


If you let a "tcpdump" running with -p option, do you receive the packe=
t
sent to ethernet dest 33:33:ff:5c:00:02 ?

If you can see it with tcpdump, then NIC gave the frame to us.
