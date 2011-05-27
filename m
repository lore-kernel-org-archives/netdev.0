From: Victor =?iso-8859-15?q?Matar=E9?= <matare@lih.rwth-aachen.de>
Subject: Re: [Bugme-new] [Bug 35862] New: arp requests from wrong src IP
Date: Sat, 28 May 2011 01:58:58 +0200
Message-ID: <201105280158.58927.matare@lih.rwth-aachen.de>
References: <bug-35862-10286@https.bugzilla.kernel.org/>
 <201105260400.22814.matare@lih.rwth-aachen.de>
 <alpine.LFD.2.00.1105270814360.1520@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta-1.ms.rz.RWTH-Aachen.DE ([134.130.7.72]:65487 "EHLO
	mta-1.ms.rz.rwth-aachen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755654Ab1E0X7D convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 May 2011 19:59:03 -0400
Received: from ironport-out-2.rz.rwth-aachen.de ([134.130.5.41])
 by mta-1.ms.rz.RWTH-Aachen.de
 (Sun Java(tm) System Messaging Server 6.3-7.04 (built Sep 26 2008))
 with ESMTP id <0LLV00I7WPACMIF0@mta-1.ms.rz.RWTH-Aachen.de> for
 netdev@vger.kernel.org; Sat, 28 May 2011 01:59:00 +0200 (CEST)
Received: from wald.localnet ([unknown] [134.61.98.110])
 by relay-auth-1.ms.rz.rwth-aachen.de
 (Sun Java(tm) System Messaging Server 7.0-3.01 64bit (built Dec  9 2008))
 with ESMTPA id <0LLV00CJFPACY280@relay-auth-1.ms.rz.rwth-aachen.de> for
 netdev@vger.kernel.org; Sat, 28 May 2011 01:59:00 +0200 (CEST)
In-reply-to: <alpine.LFD.2.00.1105270814360.1520@ja.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday, 27.05.2011 07:27:23 Julian Anastasov wrote:
>=20
> 	Hello,
>=20
> On Thu, 26 May 2011, Victor Matar=E9 wrote:
>=20
> > Examining the host which now has 137.226.164.2 (used to have 137.22=
6.164.13):
> >=20
> > # ip addr show dev eth0
> > 4: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state =
UP qlen 1000
> >      link/ether 00:e0:81:41:1f:e4 brd ff:ff:ff:ff:ff:ff
> >      inet 137.226.164.2/24 brd 137.226.164.255 scope global eth0
> >      inet 192.168.23.2/24 brd 137.226.164.255 scope global eth0:0
> > [...]
> >=20
> > Sorry, got confused with all the swapping. I'm *not* keeping the ol=
d address around, it's completely *gone*, from both ifconfig and ip. Bu=
t still it's being used as arp src address. That's what this bug is abo=
ut. Sorry for the confusion.
>=20
> 	It looks strange. Can you confirm the following things:
>=20
> - the kernel version

This host runs 2.6.36-hardened-r9. I'm not sure which vanilla release t=
hat's based on, but it's patched with grsec and PAX. However another ho=
st which exhibits the exact same behaviour runs 2.6.29-gentoo-r5. This =
one does not have hardened or grsec, but gentoo patches, so I'd assume =
this is neither a version- nor a patch-specific problem.

>=20
> - the order of 'ip' command used to add and change IPs on this box

ok - starting situation was 2 IPs: 137.226.164.13/24 (eth0) and 192.168=
=2E23.13/24 (eth0:0)
then I did "ifconfig eth0 137.226.164.2 netmask 255.255.255.0"
I'm not exactly sure what happened then, but the result was that "ip ad=
dr show dev eth0" showed that eth0 still had the old IP address, while =
ifconfig didn't. Ifconfig was misbehaving in some kind of way, that's w=
hy I checked the situation with the ip tool. Then I used ip to configur=
e everything as intended and now I have the situation described in this=
 bug. Note that the server has been in productive use for a week now de=
spite of that.

>=20
> - output of 'ip route list table local' after IPs are changed and
> before starting arping

broadcast 127.255.255.255 dev lo  proto kernel  scope link  src 127.0.0=
=2E1=20
broadcast 192.168.23.0 dev eth0  proto kernel  scope link  src 192.168.=
23.2=20
local 192.168.23.2 dev eth0  proto kernel  scope host  src 192.168.23.2=
=20
local 137.226.164.2 dev eth0  proto kernel  scope host  src 137.226.164=
=2E2=20
local 137.226.164.13 dev eth0  proto kernel  scope host  src 137.226.16=
4.13=20
broadcast 192.168.23.255 dev eth0  proto kernel  scope link  src 192.16=
8.23.2=20
broadcast 137.226.164.255 dev eth0  proto kernel  scope link  src 137.2=
26.164.2=20
broadcast 137.226.164.255 dev eth0  proto kernel  scope link  src 192.1=
68.23.2=20
broadcast 127.0.0.0 dev lo  proto kernel  scope link  src 127.0.0.1=20
local 127.0.0.1 dev lo  proto kernel  scope host  src 127.0.0.1=20
local 127.0.0.0/8 dev lo  proto kernel  scope host  src 127.0.0.1=20

I guess that entry "local 137.226.164.13" shouldn't be there? But shoul=
dn't that be removed automatically when I delete the IP from eth0?

>=20
> - output of 'strace arping', I assume it is using getsockname
> after UDP connect

# strace arping 137.226.164.13
[...]
socket(PF_PACKET, SOCK_DGRAM, 0)        =3D 3
setuid(0)                               =3D 0
ioctl(3, SIOCGIFINDEX, {ifr_name=3D"eth0", ifr_index=3D4}) =3D 0
ioctl(3, SIOCGIFFLAGS, {ifr_name=3D"eth0", ifr_flags=3DIFF_UP|IFF_BROAD=
CAST|IFF_RUNNING|IFF_MULTICAST}) =3D 0
socket(PF_INET, SOCK_DGRAM, IPPROTO_IP) =3D 4
setsockopt(4, SOL_SOCKET, SO_BINDTODEVICE, "eth0\0", 5) =3D 0
setsockopt(4, SOL_SOCKET, SO_DONTROUTE, [1], 4) =3D 0
connect(4, {sa_family=3DAF_INET, sin_port=3Dhtons(1025), sin_addr=3Dine=
t_addr("137.226.164.13")}, 16) =3D 0
getsockname(4, {sa_family=3DAF_INET, sin_port=3Dhtons(44125), sin_addr=3D=
inet_addr("137.226.164.13")}, [16]) =3D 0
close(4)                                =3D 0
bind(3, {sa_family=3DAF_PACKET, proto=3D0x806, if4, pkttype=3DPACKET_HO=
ST, addr(0)=3D{0, }, 128) =3D 0
getsockname(3, {sa_family=3DAF_PACKET, proto=3D0x806, if4, pkttype=3DPA=
CKET_HOST, addr(6)=3D{1, 00e081411fe4}, [18]) =3D 0
[...] no reply [...]

compare that with:

# strace arping 137.226.164.3
[...]
socket(PF_PACKET, SOCK_DGRAM, 0)        =3D 3
setuid(0)                               =3D 0
ioctl(3, SIOCGIFINDEX, {ifr_name=3D"eth0", ifr_index=3D4}) =3D 0
ioctl(3, SIOCGIFFLAGS, {ifr_name=3D"eth0", ifr_flags=3DIFF_UP|IFF_BROAD=
CAST|IFF_RUNNING|IFF_MULTICAST}) =3D 0
socket(PF_INET, SOCK_DGRAM, IPPROTO_IP) =3D 4
setsockopt(4, SOL_SOCKET, SO_BINDTODEVICE, "eth0\0", 5) =3D 0
setsockopt(4, SOL_SOCKET, SO_DONTROUTE, [1], 4) =3D 0
connect(4, {sa_family=3DAF_INET, sin_port=3Dhtons(1025), sin_addr=3Dine=
t_addr("137.226.164.3")}, 16) =3D 0
getsockname(4, {sa_family=3DAF_INET, sin_port=3Dhtons(45467), sin_addr=3D=
inet_addr("137.226.164.2")}, [16]) =3D 0
close(4)                                =3D 0
bind(3, {sa_family=3DAF_PACKET, proto=3D0x806, if4, pkttype=3DPACKET_HO=
ST, addr(0)=3D{0, }, 128) =3D 0
getsockname(3, {sa_family=3DAF_PACKET, proto=3D0x806, if4, pkttype=3DPA=
CKET_HOST, addr(6)=3D{1, 00e081411fe4}, [18]) =3D 0
[...] reply [...]

So that's the change in source address, and I guess it's due to the tab=
le above? Then this is more like a bug in the "ip" utility?

>=20
> - any reason to use broadcast 137.226.164.255 for all addresses?

Nope, none at all. I didn't see that because I thought ifconfig and ip =
use sensible defaults. Well...

So thanks, looks like you're pointing in the right direction.

Victor
