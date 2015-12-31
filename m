From: Doug Ledford <dledford@redhat.com>
Subject: Re: 4.4-rc7 failure report
Date: Wed, 30 Dec 2015 21:02:12 -0500
Message-ID: <56848CA4.5050007@redhat.com>
References: <5681AF69.4040204@redhat.com> <5681B594.70304@iogearbox.net>
 <5681E154.7040101@redhat.com> <20151230034300.GA8670@ast-mbp.thefacebook.com>
 <5683531F.9000704@redhat.com> <20151230041611.GA9209@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="7lhGsLP8WKNpmmMNkICvHFTIcF8LQ9F96"
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41943 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752153AbbLaCCO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Dec 2015 21:02:14 -0500
In-Reply-To: <20151230041611.GA9209@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--7lhGsLP8WKNpmmMNkICvHFTIcF8LQ9F96
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 12/29/2015 11:16 PM, Alexei Starovoitov wrote:
> On Tue, Dec 29, 2015 at 10:44:31PM -0500, Doug Ledford wrote:
>> On 12/29/2015 10:43 PM, Alexei Starovoitov wrote:
>>> On Mon, Dec 28, 2015 at 08:26:44PM -0500, Doug Ledford wrote:
>>>> On 12/28/2015 05:20 PM, Daniel Borkmann wrote:
>>>>> On 12/28/2015 10:53 PM, Doug Ledford wrote:
>>>>>> The 4.4-rc7 kernel is failing for me.  In my case, all of my vlan
>>>>>> interfaces are failing to obtain a dhcp address using dhclient.  I=
've
>>>>>> tried a hand built 4.4-rc7, and the Fedora rawhide 4.4-rc7 kernel,=
 both
>>>>>> failed.  I've tried NetworkManager and the old SysV network servic=
e,
>>>>>> both fail.  I tried a working dhclient from rhel7 on the Fedora ra=
whide
>>>>>> install and it failed too.  Running tcpdump on the interface shows=
 the
>>>>>> dhcp request going out, and a dhcp response coming back in.  Runni=
ng
>>>>>> strace on dhclient shows that it writes the dhcp request, but it n=
ever
>>>>>> recvs a dhcp response.  If I manually bring the interface up with =
a
>>>>>> static IP address then I'm able to run typical IP traffic across t=
he
>>>>>> link (aka, ping).  It would seem that when dhclient registers a pa=
cket
>>>>>> filter on the socket, that filter is preventing it from ever getti=
ng the
>>>>>> dhcp response.  The same dhclient works on any non-vlan interfaces=
 in
>>>>>> the system, so the filter must work for non-vlan interfaces.  Asid=
e from
>>>>>> the fact that the interface is a vlan, we also use a priority egre=
ss map
>>>>>> on the interface, and we use PFC flow control.  Let me know if you=
 need
>>>>>> anymore to debug the issue, or email me off list and I can get you=

>>>>>> logins to my reproducer machines.
>>>>>
>>>>> When you say 4.4-rc7 kernel is failing for you, what latest kernel =
version
>>>>> was working, where the socket filter was properly receiving the res=
ponse on
>>>>> your vlan iface?
>>>>
>>>> v4.3 final works.  I haven't bisected where in the 4.4 series it qui=
ts
>>>> working.  I can do that tomorrow.
>>>
>>> I've tried to reproduce, but cannot seem to make dnsmasq work properl=
y
>>> over vlan, so bisect would be great.
>>>
>>
>> Yeah, I've been working on it.  Issues with available machines that
>> reproduce combined with what hardware they have and whether or not tha=
t
>> hardware works at various steps in the bisection :-/
>=20
> I've looked through all bpf related commits between v4.3..HEAD and don'=
t see
> anything suspicious. Could it be that your setup exploited a bug that w=
as fixed by=20
> 28f9ee22bcdd ("vlan: Do not put vlan headers back on bridge and macvlan=
 ports")
>=20
> Could you also provide more details on vlan+dhcp setup to help narrow i=
t
> down if bisect is taking too long.
>=20

My bisection got down to the last few steps and just didn't make sense.
 So, I ended up starting it over.  I'm not sure how/why I saw that v4.3
worked the first time around, but the second time around it failed.  So
I also tried a pre-made 4.2.8-300 kernel from Fedora 23 and it failed as
well.  The problem at least spans 4.2 through 4.4, so it's been a while.
 I'll continue searching more kernels tomorrow, but I've been doing this
while I still have company in town for the holidays so I'm gonna go be
with them when I'm done writing this.

I've recently made some changes to my network setup here, so that might
be related to why I'm seeing it now.  I'll provide details on my test
setup in case any of it helps people on this:

Ethernet network is used for RDMA testing.  Switches are Mellanox 56GigE
switches.  The ports with multiple vlans are all set in hybrid mode,
untagged frames to vlan 40, tagged frames for vlans 43 and 45 allowed.
Switch has DCB enabled, priority 5 is no-drop, ports are set to use PFC
and MTU 9216 and LLDP is enabled on the ports as well.

The head node of the cluster runs dhcpd on the vlans (as well as the
InfiniBand ports).  The test machine has a static IP address configured
for each port/vlan in the server's config.

On the client, I've set the base interface to dhcp, vlan 43 to static IP
assignment, and vlan 45 to dhcp.  This allows me to see at a glance if
things are working since I know if the base device gets an IP and vlan
45 doesn't and instead times out and goes away, then the dhcp on the
vlan failed.  (I needed to set one vlan to static so the vlan creation
didn't depend on dhcp success because with some kernel versions and some
hardware types, namely mlx5, vlans weren't working at all and you could
mistake no vlans made for a problem with dhcp when it was really a
problem with vlans on mlx5 hardware).

This is the failing device's config:

[root@rdma-perf-00 ~]$ more
/etc/sysconfig/network-scripts/ifcfg-mlx4_roce.45
DEVICE=3Dmlx4_roce.45
VLAN=3Dyes
VLAN_ID=3D45
REORDER_HDR=3D0
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
NAME=3Dmlx4_roce.45

And if the interface actually comes up, there is this NetworkManager
dispatcher script:

[root@rdma-perf-00 ~]$ more
/etc/NetworkManager/dispatcher.d/98-mlx4_roce.45-egress.conf
#!/bin/sh
interface=3D$1
status=3D$2
[ "$interface" =3D mlx4_roce.45 ] || exit 0
case $status in
up)
	tc qdisc add dev mlx4_roce root mqprio num_tc 8 map 5 5 5 5 5 5 5 5 5 5
5 5 5 5 5 5 queues 32@0 32@32 32@64 32@96 32@128 32@160 32@192 32@224
	# tc_wrap.py -i mlx4_roce -u 5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5
	;;
esac


The base device's config file is this:

[root@rdma-perf-00 ~]$ more /etc/sysconfig/network-scripts/ifcfg-mlx4_roc=
e
DEVICE=3Dmlx4_roce
TYPE=3DEthernet
ONBOOT=3Dyes
HWADDR=3D00:02:c9:31:77:91
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
MTU=3D9000
NAME=3Dmlx4_roce


Let me know if you need any more details on the setup.  I'll report back
when I've actually *really* identified when the bug appeared.

--=20
Doug Ledford <dledford@redhat.com>
              GPG KeyID: 0E572FDD



--7lhGsLP8WKNpmmMNkICvHFTIcF8LQ9F96
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQIcBAEBCAAGBQJWhIykAAoJELgmozMOVy/du8sP/1LTHK1PZbt0pIp51y9IA3JC
n1QBlw3QWX2gen4vPd8FId9vKObcqAW8yoCnl1yDCxCIV4GE88qVOuqdai+lkgU4
rcGitfYINSJlybIifcc33oeCXZuULBtNHwjHR4e89/3H3+NfF5G/1H1M+XJQPo/Z
eUyPlXzhX28ti4/P1pvq1JY7xmTz+u/PDLjhWxWp0JAYtaQ/UALWuS2lbFfYcKez
crU2mWz/rwaX7yjcCfFlJCXYGAppgmpc/JFCBOOlEBBhleFGqCYgONtFKfBRrisl
Tibi1N1JTsNHcJTjbzIFW6yJJQ9nQlLhJKocShu6FuBqsr/vERBypSLGOKW1QyFp
Fgcv8n6HOqpJrQLGRK+4SZ61k2yCz/fd8rPD2MxZoKYM49VehzS18mJwvqvnJ776
uLpfdshPwO8jUeMFDW2QbC6pduJd4t6DBB0TmsehJ34RVeszoMgcGOI0DswzZ2tm
EH9m/z34C16y7YCdBcl9dGpJbpt9l66yTHzVEmGh/Pwy6tQGaZ/1Wz6sMiGC0qgM
VSjKArimaM/L9gySJTCisrRoP3zEsOPSkw1okmeCX6fI+BWHSrg4h2m4fJMo+YqK
JYqxtAWhn7CM/+l55HOXjUfdx9BZRlC71reKBMf81IxVi6E4fO2TmVb64YQN8cWU
xLiRmV8I3TiBvXHopvnj
=AMmK
-----END PGP SIGNATURE-----

--7lhGsLP8WKNpmmMNkICvHFTIcF8LQ9F96--
