From: Tom Marshall <tmarshall@real.com>
Subject: icmpv6_send filling the logs
Date: Thu, 20 May 2004 09:01:59 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040520160158.GA785@real.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=_flawless.real.com-12835-1085069310-0001-2"
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_flawless.real.com-12835-1085069310-0001-2
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

I have a Linux bridge machine with a 2.6.6 kernel.  It's a simple setup: two
ethernet cards (both using the eepro100 driver) acting as a bridge to my
office.  Here's the relevant ifconfig output:

    br0       Link encap:Ethernet  HWaddr 00:02:B3:16:D3:16 =20
              inet addr:172.23.22.199  Bcast:172.23.255.255  Mask:255.255.0=
=2E0
              inet6 addr: feed:4d56::202:b3ff:fe16:d316/64 Scope:Site
              inet6 addr: fe80::202:b3ff:fe16:d316/64 Scope:Link
              UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1

    eth0      Link encap:Ethernet  HWaddr 00:D0:B7:74:76:CE =20
              inet6 addr: fe80::2d0:b7ff:fe74:76ce/64 Scope:Link
              UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1

    eth1      Link encap:Ethernet  HWaddr 00:02:B3:16:D3:16 =20
              inet6 addr: fe80::202:b3ff:fe16:d316/64 Scope:Link
              UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1

I've manually assigned the site address to br0.  I am running radvd 0.7.2 on
the machine.  Its configuration looks like this:

    interface br0 {
            AdvSendAdvert on;
    #       UnicastOnly on;
            prefix feed:4d56::/64 {
                    AdvOnLink on;
                    AdvAutonomous on;
            };
    };  =20

Occasionally the machine will get into a state where this message fills the
logs (thank goodness for the ratelimit):

    hashi kernel: icmpv6_send: no reply to icmp error

It looks like this traffic may be related to the error:

    08:14:49.389415 fe80::202:b3ff:fe16:d316 > ff02::1:ffb4:fdbb: icmp6: ne=
ighbor sol: who has fe80::20c:76ff:feb4:fdbb
    08:14:49.389455 fe80::20c:76ff:feb4:fdbb > fe80::202:b3ff:fe16:d316: ic=
mp6: neighbor adv: tgt is fe80::20c:76ff:feb4:fdbb
    08:14:49.389486 fe80::202:b3ff:fe16:d316 > ff02::1:ff16:d316: icmp6: ne=
ighbor sol: who has fe80::202:b3ff:fe16:d316
    08:14:50.389265 fe80::202:b3ff:fe16:d316 > ff02::1:ffb4:fdbb: icmp6: ne=
ighbor sol: who has fe80::20c:76ff:feb4:fdbb
    08:14:50.389306 fe80::20c:76ff:feb4:fdbb > fe80::202:b3ff:fe16:d316: ic=
mp6: neighbor adv: tgt is fe80::20c:76ff:feb4:fdbb
    08:14:50.389341 fe80::202:b3ff:fe16:d316 > ff02::1:ff16:d316: icmp6: ne=
ighbor sol: who has fe80::202:b3ff:fe16:d316

Note in the third and sixth lines the bridge is requesting its own address.
fe80::20c:76ff:feb4:fdbb belongs to another one of my machines, also running
Linux 2.6.6.  There's very little IPv6 traffic on this LAN (mostly my own
ssh sessions), though there are quite a few machines with various OS's that
have IPv6 enabled.  I can provide packet dumps if they are needed.

I've temporarily worked around this problem with the following command:

    # ip6tables -A OUTPUT -p icmpv6 -s fe80::/16 -j DROP

This works out okay for me because I always use the site local addresses,
but obviously it isn't an ideal solution...

--=20
The universe is ruled by letting things take their course.  It cannot be
ruled by interfering.
        -- Chinese proverb

--=_flawless.real.com-12835-1085069310-0001-2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Transfer-Encoding: 7bit
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQFArNZ2qznSmcYu2m8RAh51AJ0YMdUA98k0bynk1uidJ0not93FcwCggEax
Svt0ZnjeVdRnwGZ7CDssqgM=
=bA7L
-----END PGP SIGNATURE-----

--=_flawless.real.com-12835-1085069310-0001-2--
