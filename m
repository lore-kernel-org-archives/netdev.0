From: Valdis Kletnieks <Valdis.Kletnieks@vt.edu>
Subject: IPv6 patch mysteriously breaks IPv4 VPN
Date: Wed, 20 Apr 2016 22:24:13 -0400
Message-ID: <15023.1461205453@turing-police.cc.vt.edu>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1461205453_7324P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: bjorn@mork.no, "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--==_Exmh_1461205453_7324P
Content-Type: text/plain; charset="UTF-8"
Content-Id: <15016.1461205453.1@turing-police.cc.vt.edu>
Content-Transfer-Encoding: quoted-printable

I'll say up front - no, I do *not* have a clue why this commit causes this
problem - it makes exactly zero fsking sense.

Scenario:  $WORK is blessed with a Juniper VPN system.  I've been
seeing for a while now (since Dec-ish) an issue where at startup,
the tun0 device will get wedged.  ifconfig reports this:

tun0: flags=3D4305<UP,POINTOPOINT,RUNNING,NOARP,MULTICAST>  mtu 1400
        inet 172.27.1.165  netmask 255.255.255.255  destination 172.27.1.1=
65
        inet6 fe80::6802:d95c:f3f4:2a6f  prefixlen 64  scopeid 0x20<link>
        unspec 00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00  txqueuelen=
 500  (UNSPEC)
        RX packets 0  bytes 0 (0.0 B)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 1  bytes 48 (48.0 B)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

and no more packets cross - not even a ping.

Yes, the tunnel is ipv4 only, and only ipv4 routes get set by the VPN soft=
ware.

bisect results confirmed - linux-next 20160327 is bad, but 20160420 with t=
his
one conmmit reverted works.

% git bisect bad                  =

cc9da6cc4f56e05cc9e591459fe0192727ff58b3 is the first bad commit
commit cc9da6cc4f56e05cc9e591459fe0192727ff58b3
Author: Bj=C3=83=C2=B8rn Mork <bjorn@mork.no>
Date:   Wed Dec 16 16:44:38 2015 +0100
                                =

    ipv6: addrconf: use stable address generator for ARPHRD_NONE
                                =

    Add a new address generator mode, using the stable address generator
    with an automatically generated secret. This is intended as a default
    address generator mode for device types with no EUI64 implementation.
    The new generator is used for ARPHRD_NONE interfaces initially, adding
    default IPv6 autoconf support to e.g. tun interfaces.
    =

    If the addrgenmode is set to 'random', either by default or manually,
    and no stable secret is available, then a random secret is used as
    input for the stable-privacy address generator.  The secret can be
    read and modified like manually configured secrets, using the proc
    interface.  Modifying the secret will change the addrgen mode to
    'stable-privacy' to indicate that it operates on a known secret.
    =

    Existing behaviour of the 'stable-privacy' mode is kept unchanged. If
    a known secret is available when the device is created, then the mode
    will default to 'stable-privacy' as before.  The mode can be manually
    set to 'random' but it will behave exactly like 'stable-privacy' in
    this case. The secret will not change.
    =

    Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
    Cc: =C3=A5=C2=90=C2=89=C3=A8=C2=97=C2=A4=C3=A8=C2=8B=C2=B1=C3=A6=C2=98=
=C2=8E <hideaki.yoshifuji@miraclelinux.com>
    Signed-off-by: Bj=C3=83=C2=B8rn Mork <bjorn@mork.no>
    Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
    Signed-off-by: David S. Miller <davem@davemloft.net>

(Sorry for the delay in reporting this - bisecting this proved to be
a bear and a half, because this problematic commit landed only about 10 co=
mmits after
this one: =


git bisect start
# good: [1bd4978a88ac2589f3105f599b1d404a312fb7f6] tun: honor IFF_UP in tu=
n_get_user()

which fixed a *different* issue that prevented the tun device from getting
created at all (or it was immediately taken back down by the VPN software)=
.
End result was that unless I gave a "known good" start point in that dozen
commit range, there's be a month's worth of 'git commit skip' to wade thro=
ugh.
I got damned lucky and found a record on one of my servers of an ssh over =
VPN,
and correlated it to the one day that linux-next had the above fix for the
previous issue, and wasn't broken by this current issue....)

--==_Exmh_1461205453_7324P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: Exmh version 2.5 07/13/2001

iQIVAwUBVxg5zQdmEQWDXROgAQJqeA//Uo5TUplxH4xni12y7qL1n8cJDp1byL8S
G1v5SLbBB0JS6+jxof/YHM17XMaGV1nbKDAVpCFULJfu0wans1OQgDtspuJ7E/TF
L8JgnC49vuOdmDKfsVxCdlKOEUWP8IcQdfBhUeJ91RYAYzGNJpfsiGbf8Hp4uLJj
ZgSTTSlXnTKjxVR6B4g4bSlBBNG+BdbR5y38DgJWAlJsjeEySr0/9sVgqw67D2oB
AEhEp8SlYvL7o/erDbrVQ96mpA/nDSuSSoaaqbR/ls0hIlWcegI3FrJ3Jws7aWOd
q10pBAfx0hqHPA9pNEBStOofGKawE6Kj3pxXorjCDEm3jBTrKbJCSIQPoQCKCLe5
DvCJIipsv0LSWDdujjrfXJ8cpFw21DtKxuYBsh0wogAgWgnJGArrUWeNHwX5so+T
/Qezqu6nlc3Vp1Q2DvryBSb7ZtgcL2264g8rBu94+0mAqt4zgdCsdk8diyI9X/wI
n5DpuqKQZd/0zjvYgj4Wsawi+lwQu5+kB9d63jo1O3UrYmow2LJkymrnK00sYcz2
rG2QJheqxZMwEbjl767wTf57iPEtc5Bog2g6XRK340kLjoXNN7T2uibxNUpvoORM
y5ypvjgpOKst+OiRTOTL1LJnrR8Oz7sNwSW5zEzq+XLJZZR1jTXCc5CmvOITAUYR
098ki0WiDY0=
=CHn/
-----END PGP SIGNATURE-----

--==_Exmh_1461205453_7324P--
