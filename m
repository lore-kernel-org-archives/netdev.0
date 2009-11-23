From: Alex Samad <alex@samad.com.au>
Subject: icmp redirects problem
Date: Mon, 23 Nov 2009 15:31:24 +1100
Message-ID: <20091123043124.GA14795@samad.com.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="jRHKVT23PllUwdXP"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail15.tpgi.com.au ([203.12.160.61]:52651 "EHLO
	mail15.tpgi.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756343AbZKWEo7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Nov 2009 23:44:59 -0500
Received: from sydrt01.samad.com.au (adsl.samad.com.au [60.241.248.86])
	by mail15.tpgi.com.au (envelope-from alex@samad.com.au) (8.14.3/8.14.3) with ESMTP id nAN4VO8a027258
	(version=TLSv1/SSLv3 cipher=AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Mon, 23 Nov 2009 15:31:27 +1100
Received: from alex by smtp.samad.com.au with local  (Exim 4.69 #1 (Debian))
	id 1NCQaC-0003xy-RE
	for <netdev@vger.kernel.org>; Mon, 23 Nov 2009 15:31:24 +1100
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--jRHKVT23PllUwdXP
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi


I seem to be having problems with icmp redirects

My network setup, I have

sydrt01=20
  eth0 192.168.11.1/24=20
  eth1 192.168.10.1/24
  ppp0 attached to eth2 internet

max
  eth0 192.168.11.10/24 DGW 192.168.11.1

because sydrt01 only have 10/100 ports I moved 192.168.10.1/24 (my
wireless to max), which had a spare 1g port. so I ended up with=20


sydrt01=20
  eth0 192.168.11.1/24=20
  ppp0 attached to eth2 internet

max
  eth0 192.168.11.10/24
  eth1 192.168.10.1/24

I add a ip r r 192.168.10.0/24 via 192.168.11.10 to sydrt01 and I see
that sydrt01 sends out the icmp redirects.


But in this situation when I have

laptop connected to 192.168.11.0/24 (192.168.11.200) and I have
alex-mini connected to 192.168.10.0/24 (192.168.10.201), I can ssh from
alex-mini to laptop, pings seem to work but ssh has a problem.

When I investigated this, tcpdump -pni eth0 hostname alex-mini or icmp
on laptop, I can see that the return packets (syn-ack) goes to sydrt01
(DGW) and a icmp comes back to redirect - which laptop fails to act
upon.  I tried ping -c 6 alex-mini from laptop and after each icmp ping
advised that there was a icmp redirect, but again the kernel did not
take the information in.

I have=20

net.ipv4.conf.all.accept_redirects =3D 0                                   =
                                                                           =
                           =20
net.ipv4.conf.all.secure_redirects =3D 1                                   =
                                                                           =
                           =20
(presume all the interface ones are 1)

as my default, the documentation seems to suggest that I don't need the
former for the later to work ie I can have either one.

But for me to get this to work I had to set=20

net.ipv4.conf.all.accept_redirects =3D 1
net.ipv4.conf.all.secure_redirects =3D 1

to get it to work properly.

My understanding is secure_redirects means that the kernel should listen
to icmp redirect if the redirect comes from the default gateway as per
the route table.

laptop gets its ip from dchp server that make 192.168.11.1 the default
gateway and its 192.168.11.1 that sends out the icmp redirect.

I had a quick look at the kernel tree for 2.6.31 (which is what I am
using).

I am no expert of the kernel source.  but from what I found
http://git.kernel.org/?p=3Dlinux/kernel/git/stable/linux-2.6.31.y.git;a=3Db=
lob;f=3Dnet/ipv4/icmp.c;h=3D97c410e8438895664a9abdbbf5670b26af01dffa;hb=3DH=
EAD
line 774 which handles the icmp redirects uses ip_rt_redirect

http://git.kernel.org/?p=3Dlinux/kernel/git/stable/linux-2.6.31.y.git;a=3Db=
lob;f=3Dnet/ipv4/route.c;h=3D278f46f5011beb2ab85747543f84dfd3ce7c6d1c;hb=3D=
HEAD
line 1334 has ip_rt_redirect

This is where I loose it a bit

my guess is line 1349 which seems to check to see if redirects are allow
does a IN_DEV_RX_REDIRECTS and this macro
(http://git.kernel.org/?p=3Dlinux/kernel/git/stable/linux-2.6.31.y.git;a=3D=
blob;f=3Dinclude/linux/inetdevice.h;h=3Dad27c7da87986da346da3d62f29e88bec95=
7280a;hb=3DHEAD)


and I think it fails the test here and thus get bounced out. Which sort
of corrosponds to what i have seen - but  doesn't match up with the
documentation
http://git.kernel.org/?p=3Dlinux/kernel/git/stable/linux-2.6.31.y.git;a=3Db=
lob;f=3DDocumentation/networking/ip-sysctl.txt;h=3D8be76235fe6724c43e0c2b39=
778f3f741e53b619;hb=3DHEAD

Line 680
 secure_redirects - BOOLEAN
 681         Accept ICMP redirect messages only for gateways,
 682         listed in default gateway list.
 683         secure_redirects for the interface will be enabled if at
 least one of
 684         conf/{all,interface}/secure_redirects is set to TRUE,
 685         it will be disabled otherwise
 686         default TRUE


I had conf/interface/secure_redirect =3D 1 and conf/all/secure_redirect=3D1


Thanks
Alex
PS I am not subscribed please cc me on replies thanks

I sent this to linux-net, but realises that might not be the right list

--jRHKVT23PllUwdXP
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEARECAAYFAksKEBwACgkQkZz88chpJ2P4lgCeLTnkj+DX8JlJOorG4WNedx5A
gLcAoMmf4dOHd2Hw4YwdQp5CBRVyi474
=o+Gc
-----END PGP SIGNATURE-----

--jRHKVT23PllUwdXP--
