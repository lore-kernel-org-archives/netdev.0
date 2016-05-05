From: Doug Ledford <dledford@redhat.com>
Subject: Re: mlx5 core/en oops in 4.6-rc6+
Date: Thu, 5 May 2016 13:16:37 -0400
Message-ID: <b4a8c4ca-74c5-b9b4-f9a5-4386cf6857fe@redhat.com>
References: <56df9c0a-39dd-6e07-9466-23195dc60860@redhat.com>
 <CALzJLG9_PLzU=Qwvv=_3aEd0KQr1c9rZyfcrfuLPo8wF=F_B0A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="1ruMnjtNh13DJXjKwuibkF0fgKUQ7TkpK"
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55653 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751190AbcEERQj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 May 2016 13:16:39 -0400
In-Reply-To: <CALzJLG9_PLzU=Qwvv=_3aEd0KQr1c9rZyfcrfuLPo8wF=F_B0A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--1ruMnjtNh13DJXjKwuibkF0fgKUQ7TkpK
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 05/05/2016 12:42 PM, Saeed Mahameed wrote:
> On Thu, May 5, 2016 at 7:00 PM, Doug Ledford <dledford@redhat.com> wrot=
e:
>> Just had this pop up during testing, happened very soon after bootup:
>>

[ snip oops ]

> Hi Doug,
>=20
> did you by change configure  TC queues for the netdev ? i.e. dev->num_t=
c > 1
> if not i would be happy to get more info in you network configuration.

That depends on which interface actually generated the oops.  If it was
the base interface, then I don't manually set any special params on it.
If it's one of the vlan interfaces, then there is a NetworkManager
dispatcher script that is intended to set the tc count on interface up:

[root@rdma-virt-03 ~]$ more /etc/NetworkManager/dispatcher.d/98-mlx5_roce=
=2E4*
::::::::::::::
/etc/NetworkManager/dispatcher.d/98-mlx5_roce.43-egress.conf
::::::::::::::
#!/bin/sh
interface=3D$1
status=3D$2
[ "$interface" =3D mlx5_roce.43 ] || exit 0
case $status in
up)
	tc qdisc add dev mlx5_roce root mqprio num_tc 8 map 5 5 5 5 5 5 5 5 5 5
5 5 5 5 5 5
	# tc_wrap.py -i mlx5_roce -u 5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5
	;;
esac
--More--(Next file:
/etc/NetworkManager/dispatcher.d/98-mlx5_roce.45-egress.conf:::::::::::::=
:
/etc/NetworkManager/dispatcher.d/98-mlx5_roce.45-egress.conf
::::::::::::::
#!/bin/sh
interface=3D$1
status=3D$2
[ "$interface" =3D mlx5_roce.45 ] || exit 0
case $status in
up)
	tc qdisc add dev mlx5_roce root mqprio num_tc 8 map 5 5 5 5 5 5 5 5 5 5
5 5 5 5 5 5
	# tc_wrap.py -i mlx5_roce -u 5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5
	;;
esac
[root@rdma-virt-03 ~]$


However, I should note that this usage of tc is a bit out of date last I
checked and doesn't even work any more.  Let me double check...

[root@rdma-virt-02 vlan]$ cd /proc/net/vlan/
[root@rdma-virt-02 vlan]$ ls
config  mlx5_roce.43  mlx5_roce.45
[root@rdma-virt-02 vlan]$
[root@rdma-virt-02 vlan]$ for i in *; do echo "$i:"; cat $i; echo; done
config:
VLAN Dev name	 | VLAN ID
Name-Type: VLAN_NAME_TYPE_RAW_PLUS_VID_NO_PAD
mlx5_roce.45   | 45  | mlx5_roce
mlx5_roce.43   | 43  | mlx5_roce

mlx5_roce.43:
mlx5_roce.43  VID: 43	 REORDER_HDR: 1  dev->priv_flags: 1001
         total frames received           57
          total bytes received         5010
      Broadcast/Multicast Rcvd            0

      total frames transmitted           20
       total bytes transmitted         2525
Device: mlx5_roce
INGRESS priority mappings: 0:0  1:0  2:0  3:0  4:0  5:0  6:0 7:0
 EGRESS priority mappings: 0:3 1:3 2:3 3:3 4:3 5:3 6:3 7:3

mlx5_roce.45:
mlx5_roce.45  VID: 45	 REORDER_HDR: 1  dev->priv_flags: 1001
         total frames received           57
          total bytes received         5010
      Broadcast/Multicast Rcvd            0

      total frames transmitted           21
       total bytes transmitted         2603
Device: mlx5_roce
INGRESS priority mappings: 0:0  1:0  2:0  3:0  4:0  5:0  6:0 7:0
 EGRESS priority mappings: 0:5 1:5 2:5 3:5 4:5 5:5 6:5 7:5

OK, so the vlans have egress mappings, but they don't match what the
mlx5_roce.43 egress.conf file should have enabled.  Digging a little
further on this machine:

[root@rdma-virt-03 vlan]$ more
/etc/sysconfig/network-scripts/ifcfg-mlx5_roce.4?
::::::::::::::
/etc/sysconfig/network-scripts/ifcfg-mlx5_roce.43
::::::::::::::
DEVICE=3Dmlx5_roce.43
VLAN=3Dyes
VLAN_ID=3D43
VLAN_EGRESS_PRIORITY_MAP=3D0:3,1:3,2:3,3:3,4:3,5:3,6:3,7:3
TYPE=3DVlan
ONBOOT=3Dyes
BOOTPROTO=3Ddhcp
DEFROUTE=3Dno
PEERDNS=3Dno
PEERROUTES=3Dyes
IPV4_FAILURE_FATAL=3Dyes
IPV6INIT=3Dyes
IPV6_AUTOCONF=3Dyes
IPV6_DEFROUTE=3Dno
IPV6_PEERDNS=3Dno
IPV6_PEERROUTES=3Dyes
IPV6_FAILURE_FATAL=3Dno
NAME=3Dmlx5_roce.43
::::::::::::::
/etc/sysconfig/network-scripts/ifcfg-mlx5_roce.45
::::::::::::::
DEVICE=3Dmlx5_roce.45
VLAN=3Dyes
VLAN_ID=3D45
VLAN_EGRESS_PRIORITY_MAP=3D0:5,1:5,2:5,3:5,4:5,5:5,6:5,7:5
TYPE=3DVlan
ONBOOT=3Dyes
BOOTPROTO=3Ddhcp
DEFROUTE=3Dno
PEERDNS=3Dno
PEERROUTES=3Dyes
IPV4_FAILURE_FATAL=3Dyes
IPV6INIT=3Dyes
IPV6_AUTOCONF=3Dyes
IPV6_DEFROUTE=3Dno
IPV6_PEERDNS=3Dno
IPV6_PEERROUTES=3Dyes
IPV6_FAILURE_FATAL=3Dno
NAME=3Dmlx5_roce.45
[root@rdma-virt-03 vlan]$

This is a Fedora rawhide machine, using NetworkManager to handle the
network interfaces.  So, the egress priority mappings are being set by
NM.  I don't know if they are overriding the egress mapping dispatchers
or if the egress mapping dispatchers are failing to work/run properly.
It might be the latter.  Let me double check the command...

OK, re-reading the egress dispatchers above, they work on the base
interface, not on the vlan interface that triggers them.  That's why
they both use the same command (mapping to egress 5) instead of being
like the ifcfg files, which map the 43 vlan to egress priority 3, and
the 45 vlan to egress priority 5.  Running tc qdisc | grep mlx5_roce
shows that the egress mapping is being applied (although I'm not sure it
should be...I made that mapping many kernels ago when that was the right
thing to do, the modern mlx5 ethernet drivers create their own mappings
that are drastically different).

So, to answer your question, yes, num_tc > 1, num_tc =3D=3D 8, and I
probably need to reconfigure that egress dispatcher to do what I want it
to do (which is merely to make sure that all packets from specific
interfaces are tagged with specific vlan priorities so per-priority flow
control between the card and switch works properly, the base interface
is supposed to have no priority tag, the 43 vlan is supposed to have
priority tag 3, and vlan 45 is supposed to have priority tag 5) on
modern kernels.

--=20
Doug Ledford <dledford@redhat.com>
              GPG KeyID: 0E572FDD



--1ruMnjtNh13DJXjKwuibkF0fgKUQ7TkpK
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQIcBAEBCAAGBQJXK3/1AAoJELgmozMOVy/dsigQAJDKDzPs52jLHTQadGUq5MCg
4stpzupfAQxhZNUQpLGbX+M7hYZ7pEm3z1Sw5ExfDP1+Lk3GpOpIjD5ngjZ+nLjR
qSmFzEBm5KlPpstZ9JdGLyGVPbp9jasIyezOC3z8+x07mHpBg3I4GBMOfZpOjY3P
5wQ9oz9GaHLbngfx+F97SbTcJiGd692OAc6i0judeTqFlKfDxUT0xRxvlDwrvXNp
2g677046omIzriRcuWhMvmEYiTxU1Wh4UVmMFRypi/xUeXFZnoA89LE7Tm1Lt3Kg
0O9xcwH+wMOxUdNUnY3uSRgQoBFoK5gBKQARuXcOHUnDrZzhg0W+vCS97BpOfuLg
YKhWxa3Er+Kn++2PkcNpf59bYfHnv3IG9WUpBLJeHXhzP/Lv8yJBV8XPRfT9GnBy
1s+xJcOCqZMWScey0G+K5bHwi2HX1HWMDZGH4EeQjfrqBNUR2BGWlGJhvYS10SG4
4N3xU4BDAHA3lWr4UgVWp8zDWYLXrxRe4TN2PUjJA6c/94kQ3claqNTJ/wwwKOrE
slJb4HDaDD6X4z9oQzWBNra6Z0ue8DuLx9XrqYW7BchMdPqkf6QNfvkywTbFT+m/
WSZ/YO+AwWB40hjes+we2w4mOmjg6KLfEzSaF2DRS4LBsn3NJLp/QQsyLXYGGEZU
vZ7wSYBIRu+l0zpwReaj
=QGTN
-----END PGP SIGNATURE-----

--1ruMnjtNh13DJXjKwuibkF0fgKUQ7TkpK--
