From: Stefan Bader <stefan.bader@canonical.com>
Subject: rtl8168e-vl dropping tftp ack
Date: Wed, 17 Apr 2013 16:31:23 +0200
Message-ID: <516EB23B.3080504@canonical.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="------------enig232461FC4410B22FB1B9998A"
Cc: Realtek linux nic maintainers <nic_swsd@realtek.com>,
	Francois Romieu <romieu@fr.zoreil.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:33641 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966341Ab3DQOb2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Apr 2013 10:31:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig232461FC4410B22FB1B9998A
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: quoted-printable

There seems to be a subtle problem in handling the tftp part of
pxe booting a vm guest that is related to the specific hw /
driver.

I could observe this when using the r8169 driver from kernels
3.2, 3.5 and 3.8. It does not seem to happen when I replaced
the driver with r8168-8.035.00.tar.bz2 from the realtek site
(this I only did for kernel 3.2 for now).
It also seems to be worked-around by changing the tftp sequence
(see below).

The setup is as follows:

+-------------+
| TFTP server |
|      +------+
|      | eth0 +---+
+------+------+   |
                  |
+-------------+   |
| Xen host    |   |
|             |   |
| +-----------+   |
| | br0       |   |
| |    +------+   |   +-----------+
| |    | eth0 +---+   | Xen guest |
| |    +------+       +------+    |
| |    | vif0 +-------+ eth0 |    |
+-+----+------+       +------+----+

The Xen host has the Realtek NIC:

2:00.0 Ethernet controller [0200]: Realtek Semiconductor Co., Ltd.
       RTL8111/8168B PCI Express Gigabit Ethernet controller
       [10ec:8168] (rev 06)
       Subsystem: Micro-Star International Co., Ltd. Device [1462:7798]

This is configured to be the external port of a transparent bridge.
Normal networking is working without any apparent issues.
The problem arises when a xen guest tries to pxe boot. I had tcpdump
processes running on eth0 of the Xen host and on eth0 of the TFTP
server.

- DHCP of the Xen guest is successful (and can be pinged from then on)
- Transfer of pxelinux.0 via tftp works
- The guest then tries to load a config file named like the UUID of
  the virtual adapter. This does not exist and tftp returns "file not
  found"
  - Read Request, File: pxelinux.cfg/df80012c-a855-d44b-3fb2-4ef4932fdf83=
,
    Transfer type: octet, tsize\000=3D0\000, blksize\000=3D1408\000
  - Error Code, Code: File not found, Message: File not found
- Next the guest tries to transfer a config file which is named like
  the MAC address of the guest. This file exists.
  - Read Request, File: pxelinux.cfg/01-00-16-3e-cd-a2-82,
    Transfer type: octet, tsize\000=3D0\000, blksize\000=3D1408\000
- The tftp server returns an ACK together with the size of the file.
  - Option Acknowledgement, tsize\000=3D103\000, blksize\000=3D1408\000
- The guest would ACK with
  - Acknowledgement, Block: 0

However, that last package only shows up on the Xen host side tcpdump.
It never seems to make it out. The server retries its ack a few times
but without any reaction from the vm guest side.
Avoiding the "file not found" situation by creating a properly named
soft link on the tftp servers side seems to avoid this problem, too.
Also there are a few occations (but I cannot tell why those happen)
when the tftp sequence works even with the first file not found. But
in the majority of cases the transfer fails due to that ack of block 0
not reaching the tftp server.

I am not sure this is enough to find out what goes wrong but I can
add debugging code to the kernel driver or gather other info if
someone can hint me which things would be of interest.

Thanks,
-Stefan


--------------enig232461FC4410B22FB1B9998A
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)
Comment: Using GnuPG with undefined - http://www.enigmail.net/

iQIcBAEBCgAGBQJRbrI7AAoJEOhnXe7L7s6jTM8QAMxdMg9N9LIZ85CXNpTKHIVb
mGESI2+IEVUofUSPZ2LmfLIPLPwefT2fIKcozb1Kxm4BY+/v4CTm7T6/vGxuom+0
MN0j1iqZk1EqwzdsfnJz+OM6bECu1SZNwGbW625obUjeF0fF22gsJxjCUfTTqu5Y
KnAe4G+ht5bFP5atENeNlYzGmfzegmlVVQiW/ZuAi/BtabqGh41zEBtbzvdabr7P
Yn5sEwNzDgoCygME+UpkJvSXajhpCqIYACEpmnRx67jMOvssG6YTyqIZaG0OyS7v
LwbK23VHXxx4aY75a3k13JsqCF8XqbNwQ2qbMukS1lzMBGOPz8hvpDkoaR17KJXT
gX0DpQdB5jQpotlM9vx7GFoMgFzgdMk5RinTkXrVbhYbq5pjxvWtd2jqMgASXBhr
b7SigVbR/NL2lodzU6YOHDxGEPE6jwhGKEKEB70ticIz2JmMF2YZXJUwda0kJ7Ip
AzAf9dYInTWJHli6tnP3RbUiBsRUTB3Oe+NklxvsHMs53qOHhj9Fe0gXfo7vwGfc
9W/v85+Z0H7+f9jAmsbuTJ3kVofLtd0MZUDsvztLJylc0CwhOBnRgosVrhpLmq76
gm5RM3+LvmKgY4GGPMt/g6a8QoQZvzde3uqXOknntJidaCaWHVSxb3LjWhgah+QW
pvPeYg/tIoc7vwblWnAl
=tDSY
-----END PGP SIGNATURE-----

--------------enig232461FC4410B22FB1B9998A--
