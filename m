From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: Re: vlan performance issue on outgoing traffic
Date: Tue, 27 Apr 2010 11:32:39 -0700 (Pacific Daylight Time)
Message-ID: <alpine.WNT.2.00.1004271110300.4368@jbrandeb-desk1.amr.corp.intel.com>
References: <4BD4C037.2070003@yahoo.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "R. Weinedel" <r.weinedel@yahoo.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:28647 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752292Ab0D0Scl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Apr 2010 14:32:41 -0400
In-Reply-To: <4BD4C037.2070003@yahoo.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 25 Apr 2010, R. Weinedel wrote:

> hallo,
>=20
> I have an performance issue with vlan interfaces on an Debian Lenny
> server. The problem occurs only on outgoing traffic from the vlan
> interfaces. They use only half of the available bandwidth - (490 Mbit=
/s
> measured with iperf ). Incoming traffic is handled @ 950 Mbit/s and i=
s
> fine. The issue remains even with no switch and an direct connection
> between pc and server on the same nic. Removing (on server) the vlans
> from eth0 and configure one net on eth0 results in full speed (950
> Mbit/s) in both directions. Even another nic (onboard nvidia3 - mod
> forcedeth) couldn't solve it. I tested only in the same networking
> segment (vlan) without the need for ip forwarding or NAT, but the iss=
ue
> occurs on all my vlan's.
>=20
> All values were taken with iperf between the server and an ubuntu 9.0=
4
> workstation (and vice versa). I have controlled (w. ethtool / stats f=
rom
> switch) that all connection was 1000-BaseT/full duplex. It looks like
> some kind of trafficshaping to me, but i don't use tc, qos,tos nor ot=
her
> priority handling.
=20
> The network ist quite simple: One Server, one switch and then the
> workstations. No need for cascading or using (r)stp.
>=20
> Here some information about my network:
>=20
> Switch: Netgear GSM7224 Layer 2 managed switch, FW 6.2.0.14
> (independent, issue remains on direct connection).
>=20
> Server: Debian Lenny, kernel 2.6.26-2,

This version of the kernel doesn't support offloads for vlan adapters,=20
which is probably causing most of your decrease in throughput due to=20
either exhausting socket buffer size, or because of the round trip time=
=20
being so much more relevant when not sending large bursts using TSO. =20
Sometimes the flood of ACK packets causes higher cpu which could reduce=
=20
your throughput also.

The newer kernels will have a major impact on your setup due to a patch=
=20
that enabled pass through of hardware offloads to the vlan device's=20
offload advertisement.

The commit id of the patch is 5fb13570543f4ae022996c9d7c0c099c8abf22dd,=
=20
you can view it at:
http://git.kernel.org/?p=3Dlinux/kernel/git/torvalds/linux-2.6.git;a=3D=
commitdiff;h=3D5fb13570543f4ae022996c9d7c0c099c8abf22dd

=20
> NIC: Intel Corporation 82541PI Gigabit Ethernet Con. (e1000 module).

This PCI adapter is bandwidth limited on the PCI bus, and so will be ev=
en=20
more sensitive to offload on (TSO) vs offload off.

> # ethtool eth0
> Settings for eth0:
>         Supported ports: [ TP ]
>         Supported link modes:   10baseT/Half 10baseT/Full
>                                 100baseT/Half 100baseT/Full
>                                 1000baseT/Full
>         Supports auto-negotiation: Yes
>         Advertised link modes:  1000baseT/Full
>         Advertised auto-negotiation: Yes
>         Speed: 1000Mb/s
>         Duplex: Full
>         Port: Twisted Pair
>         PHYAD: 0
>         Transceiver: internal
>         Auto-negotiation: on
>         Supports Wake-on: umbg
>         Wake-on: g
>         Current message level: 0x00000007 (7)
>         Link detected: yes
>=20
> 8021q:
> filename:       /lib/modules/2.6.26-2-686/kernel/net/8021q/8021q.ko
> version:        1.8
> license:        GPL
> alias:          rtnl-link-vlan
> srcversion:     A61E1168F65EE335A91D4E1
> depends:
> vermagic:       2.6.26-2-686 SMP mod_unload modversions 686
>=20
> VLAN: #/proc/net/vlan/config
> VLAN Dev name    | VLAN ID
> Name-Type: VLAN_NAME_TYPE_RAW_PLUS_VID_NO_PAD
> eth0.5         | 5  | eth0
> eth0.101       | 101  | eth0
> eth0.90        | 90  | eth0
>=20
> IFCONFIG:
> eth0      Link encap:Ethernet  Hardware Adresse 00:0e:0c:bc:43:43
>           inet6-Adresse: fe80::20e:cff:febc:4343/64
> G=FCltigkeitsbereich:Verbindung
>           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metrik:1
>           RX packets:28140829 errors:0 dropped:218 overruns:0 frame:0
>           TX packets:44994420 errors:0 dropped:0 overruns:0 carrier:0
>           Kollisionen:0 Sendewarteschlangenl=E4nge:1000
>           RX bytes:3472864138 (3.2 GiB)  TX bytes:3908682627 (3.6 GiB=
)
>=20
> eth0.5    Link encap:Ethernet  Hardware Adresse 00:0e:0c:bc:43:43
>           inet Adresse:XXX.YYY.5.1  Bcast:XXX.YYY.5.255  Maske:255.25=
5.255.0
>           inet6-Adresse: fe80::20e:cff:febc:4343/64
> G=FCltigkeitsbereich:Verbindung
>           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metrik:1
>           RX packets:77807 errors:0 dropped:0 overruns:0 frame:0
>           TX packets:69699 errors:0 dropped:0 overruns:0 carrier:0
>           Kollisionen:0 Sendewarteschlangenl=E4nge:0
>           RX bytes:57578233 (54.9 MiB)  TX bytes:7782844 (7.4 MiB)
>=20
> eth0.90   Link encap:Ethernet  Hardware Adresse 00:0e:0c:bc:43:43
>           inet Adresse:XXX.YYY.90.1  Bcast:XXX.YYY.90.255=20
> Maske:255.255.255.0
>           inet6-Adresse: fe80::20e:cff:febc:4343/64
> G=FCltigkeitsbereich:Verbindung
>           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metrik:1
>           RX packets:457850 errors:0 dropped:0 overruns:0 frame:0
>           TX packets:913988 errors:0 dropped:0 overruns:0 carrier:0
>           Kollisionen:0 Sendewarteschlangenl=E4nge:0
>           RX bytes:23824841 (22.7 MiB)  TX bytes:1311485281 (1.2 GiB)
>=20
> eth0.101  Link encap:Ethernet  Hardware Adresse 00:0e:0c:bc:43:43
>           inet Adresse:XXX.YYY.101.1  Bcast:XXX.YYY.101.255=20
> Maske:255.255.255.0
>           inet6-Adresse: fe80::20e:cff:febc:4343/64
> G=FCltigkeitsbereich:Verbindung
>           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metrik:1
>           RX packets:24856818 errors:0 dropped:0 overruns:0 frame:0
>           TX packets:41608593 errors:0 dropped:0 overruns:0 carrier:0
>           Kollisionen:0 Sendewarteschlangenl=E4nge:0
>           RX bytes:423116676 (403.5 MiB)  TX bytes:3855703636 (3.5 Gi=
B)
>=20
> ROUTE: #route -n
> Ziel            Router          Genmask         Flags Metric Ref    U=
se
> Iface
> XXX.YYY.101.0   0.0.0.0         255.255.255.0   U     0      0       =
 0
> eth0.101
> XXX.YYY.5.0     0.0.0.0         255.255.255.0   U     0      0       =
 0
> eth0.5
> XXX.YYY.90.0    0.0.0.0         255.255.255.0   U     0      0       =
 0
> eth0.90
> 0.0.0.0         192.168.5.4     0.0.0.0         UG    0      0       =
 0
> eth0.5
>=20
> Can someone give me a hint, where my search for an solution should be
> going on ?
>=20
> Many thanks !
> Regards
> Ralf Weinedel
> Falkensee/Germany
>=20
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20
