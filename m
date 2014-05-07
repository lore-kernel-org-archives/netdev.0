From: Ruben Herold <ruben@insecure.pw>
Subject: Problems with gre tunnel between 3.6.3 and 3.14.2
Date: Wed, 7 May 2014 12:47:33 +0200
Message-ID: <20140507104733.GK9704@insecure.pw>
Reply-To: Ruben Herold <ruben@insecure.pw>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="lt3WynA+XK9Fj6D4"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.insecure.pw ([194.97.1.30]:59297 "EHLO mail.insecure.pw"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932157AbaEGKxC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 May 2014 06:53:02 -0400
Received: from insecure.pw (unknown [194.97.1.21])
	(using TLSv1.2 with cipher DHE-RSA-AES128-SHA (128/128 bits))
	(No client certificate requested)
	by mail.insecure.pw (Postfix) with ESMTPSA id CCBEA2005A
	for <netdev@vger.kernel.org>; Wed,  7 May 2014 10:47:34 +0000 (UTC)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--lt3WynA+XK9Fj6D4
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

        hi,

I have a strange problem setting up an gre tunnel between to existing
linux router over the internet. (I have try to tunnel it over ipsec
with the same results described below, so I stopped using ipsec for
debugging the issue)

Here the setup with  anonymized IP Adresses

Router A: =20
         kernel:  3.6.3 (32bit)
         system:  Debian testing with custom kernel
         tunnel: =20

                  /sbin/ip tunnel add tun0 mode gre remote $REMOTE_IP local=
 $LOCAL_IP
                  /sbin/ip addr add 192.168.0.2/31 peer 192.168.0.1/31 dev =
tun0
                  /sbin/ifconfig tun0 up

   =20
Router B:=20
         kernel:  3.14.2 (64bit)
         system:  Debian testing with custom kernel
         tunnel:

                  /sbin/ip tunnel add tun0 mode gre remote $REMOTE_IP local=
 $LOCAL_IP
                  /sbin/ip addr add 192.168.0.1/31 peer 192.168.0.2/31 dev =
tun0
                  /sbin/ifconfig tun0 up


tracepath (Same version on both systems) between the systems:

Router A --> Router B:

        tracepath -n xxx.xxx.xxx.xxx
        1:  xxx.xxx.xxx.xxx                                          0.240m=
s pmtu 1500
        1:  xxx.xxx.xxx.xxx                                          0.360m=
s=20
        1:  xxx.xxx.xxx.xxx                                          0.222m=
s=20
        2:  xxx.xxx.xxx.xxx                                         1.280ms=
 asymm 3=20
        3:  xxx.xxx.xxx.xxx                                        1.439ms =
!H
        Resume: pmtu 1500=20


Router B --> Router A:

tracepath -n XXX.XXX.XXX.XXX
        1?: [LOCALHOST]                                         pmtu 1500
        1:  XXX.XXX.XXX.XXX                                        0.352ms =
asymm 2=20
        1:  XXX.XXX.XXX.XXX                                        0.234ms =
asymm 2=20
        2:  XXX.XXX.XXX.XXX                                         1.483ms=
=20
        3:  XXX.XXX.XXX.XXX                                          1.479m=
s reached
        Resume: pmtu 1500 hops 3 back 3=20


So we have clean pmtu 1500 between this hosts
Now the tunnel from both sides:

Router A --> Router B:

    tracepath -n 192.168.0.1
     1:  192.168.0.2                                          0.292ms pmtu =
1476
     1:  no reply
     2:  no reply
     3:  192.168.0.1                                          1.516ms !H
     Resume: pmtu 1476=20


Router B --> Router A:

    tracepath -n 192.168.0.2
     1?: [LOCALHOST]                                         pmtu 1476
     1:  no reply
     2:  no reply
     3:  192.168.0.1                                          1.482ms    re=
ached
     Resume: pmtu 1476 hops 3 back 1=20



icmp ping runs fine via the tunnel but if I try to get a large screen
output via ssh vor example from the dmesg output the connection freezed.

Same with other protocols, looks for me like an mtu problem but I can't
find it. Setting the mtu down on both sides also doesn't help.

But what I'm wondering is that on Router B the HWaddr is changeing on
every ifconfig run:

root@RouterB:[~] > ifconfig tun0 ; ifconfig tun0
tun0      Link encap:UNSPEC  HWaddr C2-61-6A-73-00-00-E0-34-00-00-00-00-00-=
00-00-00 =20
          inet addr:192.168.0.1  P-t-P:192.168.0.2  Mask:255.255.255.254
          inet6 addr: fe80::200:5efe:c261:6a73/64 Scope:Link
          UP POINTOPOINT RUNNING NOARP  MTU:1476  Metric:1
          RX packets:1228 errors:0 dropped:0 overruns:0 frame:0
          TX packets:34739 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0=20
          RX bytes:120614 (117.7 KiB)  TX bytes:2686718 (2.5 MiB)

tun0      Link encap:UNSPEC  HWaddr C2-61-6A-73-00-00-E0-24-00-00-00-00-00-=
00-00-00 =20
          inet addr:192.168.0.1  P-t-P:192.168.0.2  Mask:255.255.255.254
          inet6 addr: fe80::200:5efe:c261:6a73/64 Scope:Link
          UP POINTOPOINT RUNNING NOARP  MTU:1476  Metric:1
          RX packets:1228 errors:0 dropped:0 overruns:0 frame:0
          TX packets:34741 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0=20
          RX bytes:120614 (117.7 KiB)  TX bytes:2687442 (2.5 MiB)

This doesn't happend on Router A:

root@RouterA:[~] > ifconfig tun0; ifconfig tun0
tun0      Link encap:UNSPEC  HWaddr C2-61-01-8A-00-00-00-00-00-00-00-00-00-=
00-00-00 =20
          inet addr:192.168.0.2  P-t-P:192.168.0.1  Mask:255.255.255.254
          inet6 addr: fe80::200:5efe:c261:18a/64 Scope:Link
          UP POINTOPOINT RUNNING NOARP  MTU:1476  Metric:1
          RX packets:1615 errors:0 dropped:0 overruns:0 frame:0
          TX packets:45959 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0=20
          RX bytes:385274 (376.2 KiB)  TX bytes:2277674 (2.1 MiB)

tun0      Link encap:UNSPEC  HWaddr C2-61-01-8A-00-00-00-00-00-00-00-00-00-=
00-00-00 =20
          inet addr:192.168.0.2  P-t-P:192.168.0.1  Mask:255.255.255.254
          inet6 addr: fe80::200:5efe:c261:18a/64 Scope:Link
          UP POINTOPOINT RUNNING NOARP  MTU:1476  Metric:1
          RX packets:1615 errors:0 dropped:0 overruns:0 frame:0
          TX packets:45959 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0=20
          RX bytes:385274 (376.2 KiB)  TX bytes:2277674 (2.1 MiB)



What does this mean? Could this be the problem?

    thx for help

            Ruben



--=20
Ruben Herold=20
ruben@insecure.pw

--lt3WynA+XK9Fj6D4
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iEYEARECAAYFAlNqD0UACgkQgHHssbUmOEI3MACgnSZQOcUZYmTX/ulmpY2ejNog
y6AAoMlW7zbm1Zh4YwaXTFCy/v2bvw2O
=y5SO
-----END PGP SIGNATURE-----

--lt3WynA+XK9Fj6D4--
