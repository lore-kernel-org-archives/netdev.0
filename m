From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Problems Receiving UDP Broadcasts on Some Versions of Linux
Date: Wed, 27 Jan 2010 04:56:05 +0100
Message-ID: <1264564565.2810.11.camel@edumazet-laptop>
References: <20100125072749.GG21419@analytic.cynic.net>
	 <4B5D51E6.5090601@gmail.com>  <20100127003744.GA16322@analytic.cynic.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: Curt Sampson <cjs@starling-software.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753173Ab0A0D5O@vger.kernel.org>
In-Reply-To: <20100127003744.GA16322@analytic.cynic.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mercredi 27 janvier 2010 =C3=A0 09:37 +0900, Curt Sampson a =C3=A9cr=
it :
> On 2010-01-25 09:10 +0100 (Mon), Eric Dumazet wrote:
>=20
> > > The short summary is that on two very similar servers on the same
> > > network, an application that listens for broadcast UDP packets on=
 a
> > > given port works fine on the Ubuntu 8.04/Linux 2.6.24-26-server b=
ox but
> > > does not receive the packets on the Ubuntu 9.04/Linux 2.6.28-17-s=
erver
> > > box.
> >
> > Could you post a sample of tcpdump trafic you receive on the 9.04
> > host, and your network config ? "ifconfig -a"
>=20
> I've added both to the end of the StackOverflow entry:
>=20
>   http://stackoverflow.com/questions/2130563/udp-broadcast-reception-=
problems-with-ubuntu-9-04-but-not-8-04
>=20
> Again, please cc me on any responses; I'm on neither the linux-kernel
> nor netdev lists.
>=20
> cjs

1: lo: <LOOPBACK,UP,LOWER_UP> mtu 16436 qdisc noqueue state UNKNOWN=20
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1362 qdisc pfifo_fast st=
ate UP qlen 1000
    link/ether 00:30:48:d9:38:da brd ff:ff:ff:ff:ff:ff
3: eth2: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN qlen 1000
    link/ether 00:1b:21:36:19:fd brd ff:ff:ff:ff:ff:ff
4: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast st=
ate UP qlen 100
    link/ether 00:30:48:d9:38:db brd ff:ff:ff:ff:ff:ff
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 16436 qdisc noqueue state UNKNOWN=20
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
    inet6 ::1/128 scope host=20
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1362 qdisc pfifo_fast st=
ate UP qlen 1000
    link/ether 00:30:48:d9:38:da brd ff:ff:ff:ff:ff:ff
    inet 192.168.228.132/28 brd 192.168.228.143 scope global eth0
    inet6 fe80::230:48ff:fed9:38da/64 scope link=20
       valid_lft forever preferred_lft forever
3: eth2: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN qlen 1000
    link/ether 00:1b:21:36:19:fd brd ff:ff:ff:ff:ff:ff
4: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast st=
ate UP qlen 100
    link/ether 00:30:48:d9:38:db brd ff:ff:ff:ff:ff:ff
    inet 172.40.4.132/24 brd 172.40.4.255 scope global eth1
    inet6 fe80::230:48ff:fed9:38db/64 scope link=20
       valid_lft forever preferred_lft forever

And you receive a frame on eth1 with src ip address =3D 192.166.1.120

I suspect your kernel drops this frame because of asymetric routing

Check "ip route get 192.166.1.120" and if answer is directed to another=
 interface,
this may explain the problem.

Solution : tweak rp_filter settings.

Documentation/networking/ip-sysctl.txt

rp_filter - INTEGER
        0 - No source validation.
        1 - Strict mode as defined in RFC3704 Strict Reverse Path
            Each incoming packet is tested against the FIB and if the
interface
            is not the best reverse path the packet check will fail.
            By default failed packets are discarded.
        2 - Loose mode as defined in RFC3704 Loose Reverse Path
            Each incoming packet's source address is also tested agains=
t
the FIB
            and if the source address is not reachable via any interfac=
e
            the packet check will fail.

        Current recommended practice in RFC3704 is to enable strict mod=
e
        to prevent IP spoofing from DDos attacks. If using asymmetric
routing
        or other complicated routing, then loose mode is recommended.

        The max value from conf/{all,interface}/rp_filter is used
        when doing source validation on the {interface}.

        Default value is 0. Note that some distributions enable it
        in startup scripts.


I suspect Ubuntu 9.04 enables rp_filter (set to one)

(note 2 value (loose mode) might be not available yet on 2.6.28 kernels=
)

Check/change /etc/sysctl.conf settings
