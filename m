From: Raphael Hertzog <raphael@ouaza.com>
Subject: Constantly varying download rate with a complex xen networking
	setup, why?
Date: Mon, 15 Jun 2009 09:53:13 +0200
Message-ID: <20090615075313.GA22819@rivendell>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from arrakeen.ouaza.com ([212.85.152.62]:51027 "EHLO
	arrakeen.ouaza.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750767AbZFOIBi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jun 2009 04:01:38 -0400
Received: from localhost (localhost [127.0.0.1])
	by arrakeen.ouaza.com (Postfix) with ESMTP id BAE2033330
	for <netdev@vger.kernel.org>; Mon, 15 Jun 2009 09:53:17 +0200 (CEST)
Received: from arrakeen.ouaza.com ([127.0.0.1])
	by localhost (arrakeen.ouaza.com [127.0.0.1]) (amavisd-new, port 10024)
	with LMTP id lJwoYRxznwHN for <netdev@vger.kernel.org>;
	Mon, 15 Jun 2009 09:53:17 +0200 (CEST)
Received: from soleymieux.ouaza.com (soleymieux.ouaza.com [78.225.60.32])
	by arrakeen.ouaza.com (Postfix) with ESMTPA id 7667E33324
	for <netdev@vger.kernel.org>; Mon, 15 Jun 2009 09:53:17 +0200 (CEST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[ Please put me in CC of your answers ]

Hello,

I have a weird problem and I'm not sure if it comes from linux or from
Xen. Thus I'd like your opinion and maybe your help so that I can
do a proper bugreport where it belongs. I can do supplementary tests on
request of course.

I probably should try to reproduce it with kvm and a newer kernel but t=
he
hardware where this got tested doesn't have the CPU instructions for
virtualization. If you don't have any idea of what can be wrong in this
setup, I will try to arrange that test but otherwise I would like your
feedback before I do more tests.

(Note the full description below has also been submitted to
http://serverfault.com/questions/22219/)

The network configuration in my Xen setup:
- the dom0 has 3 network cards (eth0, eth1, eth2), 3 brigdes (xenbrE,
  xenbrI, xenbrD) and each brigde integrates the corresponding network
  card. Only xenbrD has an IP address configured (192.168.78.2, a priva=
te
  LAN) so that it can discuss with all domU.
- there's a domU that is a firewall/router and it also contains 3 virtu=
al
  cards (eth0, eth1, eth2). It does masquerading for traffic going out =
on
  eth0 (the external interface which is part of xenbrE).
  # grep vif /etc/xen/xm.slis=20
  vif =3D [ 'mac=3D00:16:3e:14:85:11, bridge=3DxenbrE', 'mac=3D00:16:3e=
:14:85:12, bridge=3DxenbrI', 'mac=3D00:16:3e:14:85:13, bridge=3DxenbrD'=
 ]

My problem is that when I download a big file from the internet by HTTP=
 in
the dom0, the download rate is not stable. It goes up progressively and=
 then
stalls for a few seconds, and restart again going up progressively (and
all this in loop until the download is complete). During the stalls, it=
 looks
like all networking is blocked on the machine (noticed on interactive S=
SH
sessions).

    dom0                             =E2=94=82domU
         wget                        =E2=94=82
           =E2=86=95                         =E2=94=82
    eth2=E2=86=94xenbrD(192.168.78.2)=E2=86=94vif2.2=E2=86=90=E2=94=BC=E2=
=86=92eth2(192.168.78.1/24)
                                     =E2=94=82   =E2=86=95 masquerading
    eth0=E2=86=94xenbrE=E2=86=94vif2.0=E2=86=90=E2=80=94=E2=80=94=E2=80=
=94=E2=80=94=E2=80=94=E2=80=94=E2=80=94=E2=80=94=E2=80=94=E2=80=94=E2=80=
=94=E2=80=94=E2=80=94=E2=80=94=E2=94=BC=E2=86=92eth0(192.168.1.20/24)
     =E2=86=95
    internet

If I do the same download but uses a (non-caching) HTTP proxy that runs=
 in
the firewall domU, the download rate is stable at its maximum value.

How can I avoid this problem?

I suspect it's a bug in the networking stack but I would like assistanc=
e
to diagnose it more precisely (and maybe find a work-around).

This is a Debian Etch system with Xen 3.2 and the 2.6.26-xen-686 kernel=
 of
Debian Lenny (backports). The bridges are created with
/etc/network/interfaces:

    auto lo
    iface lo inet loopback

    auto xenbrE
    iface xenbrE inet manual
            bridge_ports eth0
            bridge_maxwait 0

    auto xenbrI
    iface xenbrI inet manual
            bridge_ports eth1
            bridge_maxwait 0

    auto xenbrD
    iface xenbrD inet static
            address 192.168.78.2
            netmask 255.255.255.0
            gateway 192.168.78.1
            bridge_ports eth2
            bridge_maxwait 0

The xend configuration is not complicated:

    # grep '^(' /etc/xen/xend-config.sxp=20
    (network-script network-dummy)
    (vif-script vif-bridge)
    (dom0-min-mem 150)
    (dom0-cpus 0)
    (vncpasswd '')

And the only routing in dom0 redirects to the domU via xenbrD:

    # route -n
    Kernel IP routing table
    Destination     Gateway         Genmask         Flags Metric Ref   =
 Use Iface
    192.168.78.0    0.0.0.0         255.255.255.0   U     0      0     =
   0 xenbrD
    0.0.0.0         192.168.78.1    0.0.0.0         UG    0      0     =
   0 xenbrD

In the domU, the only iptables configuration done is `iptables -t nat -=
A
POSTROUTING -s 192.168.78.0/24 -o eth0 -j MASQUERADE`.

Thank you for your help.
--=20
Rapha=C3=ABl Hertzog -+- http://www.ouaza.com

=46reexian : des d=C3=A9veloppeurs Debian au service des entreprises
http://www.freexian.com
