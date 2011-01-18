From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [regression] 2.6.37+ commit 0363466866d9.... breaks tcp ipv6
Date: Tue, 18 Jan 2011 23:03:58 +0100
Message-ID: <1295388238.8449.10.camel@edumazet-laptop>
References: <4D335417.80704@xmsnet.nl>	<4D35EF64.1040906@xmsnet.nl>
	 <AANLkTinejKw0pY5HncB2e0ocjqYuCwTBUwd2xkroWu+E@mail.gmail.com>
	 <4D36092B.1090406@xmsnet.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jesse Gross <jesse@nicira.com>,
	LKML <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Hans de Bruin <jmdebruin@xmsnet.nl>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4D36092B.1090406@xmsnet.nl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mardi 18 janvier 2011 =C3=A0 22:42 +0100, Hans de Bruin a =C3=A9crit=
 :
> On 01/18/2011 09:06 PM, Jesse Gross wrote:
> > On Tue, Jan 18, 2011 at 11:52 AM, Hans de Bruin<jmdebruin@xmsnet.nl=
>  wrote:
> >> On 01/16/2011 09:24 PM, Hans de Bruin wrote:
> >>>
> >>> After last nights compile i lost the possibility to connect to ss=
h and
> >>> http over ipv6. The connection stops at syn_sent. connections to =
my
> >>> machine end in syn_recv. ping6 still works.
> >>>
> >>
> >> The bisect ended in:
> >>
> >> 0363466866d901fbc658f4e63dd61e7cc93dd0af is the first bad commit
> >> commit 0363466866d901fbc658f4e63dd61e7cc93dd0af
> >> Author: Jesse Gross<jesse@nicira.com>
> >> Date:   Sun Jan 9 06:23:35 2011 +0000
> >>
> >>     net offloading: Convert checksums to use centrally computed fe=
atures.
> >>
> >>     In order to compute the features for other offloads (primarily
> >>     scatter/gather), we need to first check the ability of the NIC=
 to
> >>     offload the checksum for the packet.  Since we have already co=
mputed
> >>     this, we can directly use the result instead of figuring it ou=
t
> >>     again.
> >>
> >>     Signed-off-by: Jesse Gross<jesse@nicira.com>
> >>     Signed-off-by: David S. Miller<davem@davemloft.net>
> >>
> >>
> >> ssh ::1  still works. And since dns still works I guess udp is not=
 affected.
> >> My nic is a:
> >>
> >> 09:00.0 Ethernet controller: Broadcom Corporation NetXtreme BCM575=
2 Gigabit
> >> Ethernet PCI Express (rev 02)
> >
> > Are you using vlans?  If so, can you please test this patch?
> > http://patchwork.ozlabs.org/patch/79264/
> >
>=20
> No I am not using vlans. The option is even not set in the config fil=
e.=20
> Except for the disk less bit is a straightforward setup:
>=20
>    bash-4.1# ip addr show
> 1: lo: <LOOPBACK,UP,LOWER_UP> mtu 16436 qdisc noqueue state UNKNOWN
>      link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
>      inet 127.0.0.1/8 scope host lo
>      inet6 ::1/128 scope host
>         valid_lft forever preferred_lft forever
> 2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP=
=20
> qlen 1000
>      link/ether 00:1c:23:2d:73:87 brd ff:ff:ff:ff:ff:ff
>      inet 10.10.0.6/16 brd 10.10.255.255 scope global eth0
>      inet6 2001:610:76e:0:21c:23ff:fe2d:7387/64 scope global dynamic
>         valid_lft 86399sec preferred_lft 14399sec
>      inet6 fe80::21c:23ff:fe2d:7387/64 scope link
>         valid_lft forever preferred_lft forever
> 3: sit0: <NOARP> mtu 1480 qdisc noop state DOWN
>      link/sit 0.0.0.0 brd 0.0.0.0
> bash-4.1# ip route show
> 10.10.0.0/16 dev eth0  proto kernel  scope link  src 10.10.0.6
> default via 10.10.0.1 dev eth0
> bash-4.1# ip -6 route show
> 2001:610:76e::/64 dev eth0  proto kernel  metric 256  expires 86404se=
c
> fe80::/64 dev eth0  proto kernel  metric 256
> ff00::/8 dev eth0  metric 256
> default via fe80::230:18ff:feae:75d8 dev eth0  proto kernel  metric 1=
024=20
>   expires 29sec hoplimit 64
> bash-4.1# iptables -L
> Chain INPUT (policy ACCEPT)
> target     prot opt source               destination
>=20
> Chain FORWARD (policy ACCEPT)
> target     prot opt source               destination
>=20
> Chain OUTPUT (policy ACCEPT)
> target     prot opt source               destination
> bash-4.1# ip6tables -L
> Chain INPUT (policy ACCEPT)
> target     prot opt source               destination
>=20
> Chain FORWARD (policy ACCEPT)
> target     prot opt source               destination
>=20
> Chain OUTPUT (policy ACCEPT)
> target     prot opt source               destination
> bash-4.1# brctl show
> bridge name     bridge id               STP enabled     interfaces
> bash-4.1# cat /proc/cmdline
> root=3D/dev/nfs nfsroot=3D10.10.0.2:/nfs/root/psion/,v3,tcp ro ip=3D:=
:: ::dhcp=20
> BOOT_IMAGE=3Dnightlybuild-psion
>=20


You could try "tcpdump -i eth0 ip6 -v"

I guess you receive frames with bad checksums

You can ask other system to not offload tx checksums

ethtool -K eth0 tx off

Please give result of (on both machines)
lspci -v
