From: f6bvp <f6bvp@free.fr>
Subject: Re: [Patch] rose_route_frame() NULL pointer dereference kernel panic
Date: Sat, 5 Mar 2016 16:32:42 +0100
Message-ID: <56DAFC1A.5000408@free.fr>
References: <56CDDFF7.2040609@free.fr>
 <20160225.170957.836114237953219422.davem@davemloft.net>
 <56D5FD7A.5080104@free.fr>
 <20160303.170253.1102862150292919836.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, ralf@linux-mips.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shiva144.upmc.fr ([134.157.0.144]:58580 "EHLO shiva.upmc.fr"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753788AbcCEPdM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Mar 2016 10:33:12 -0500
In-Reply-To: <20160303.170253.1102862150292919836.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David,

I understand I did not explain clearly or completely things.

I agree that each time patched rose_xmit() is calling rose_route_frame(=
)=20
it will
get a 0 return.
And I think this is what was intended by the author of rose_xmit().
He wrote a null argument in order to obtain this result but this situat=
ion
was never reached until I configurerd a secondary network with the
following attributes (lack of route gateway) and thus the bug had not
been detected before.

/sbin/ifconfig enp4s0:1 44.168.19.22 netmask 255.255.255.240

With original rose_route_frame(),  when ax25cmp() was called with a NUL=
L
argument it always got a null dereference pointer and a kernel panic
occured.

I conducted a few trials with printks in rose functions and patched
rose_xmit() otherwise kernel panic would have occured.
=46or my setting of rose network, I configured a device axudp to send
encapsulated AX.25 frames into UDP frames via ax25ipd daemon.
=46irst, I set ax25ipd configuration with a rose neighbour with a local
network address.

# Route HAMNET
# F6BVP-10/11
route f6bvp-10 44.168.19.19 udp 10093
route f6bvp-11 44.168.19.19 udp 10093 b
#

kernel route looks like:

Destination     Passerelle      Genmask         Indic Metric Ref Use If=
ace
0.0.0.0         192.168.0.254   0.0.0.0         UG    10 0        0 enp=
4s0
44.168.19.16    0.0.0.0         255.255.255.240 U     0 0        0 enp4=
s0
169.254.0.0     0.0.0.0         255.255.0.0     U     10 0        0 enp=
4s0
192.168.0.0     0.0.0.0         255.255.255.0   U     10 0        0 enp=
4s0

Those are printks when starting AX.25, and  ROSE fpac node application:

[  410.759423] NET: Registered protocol family 3
[  410.784477] mkiss: AX.25 Multikiss, Hans Albas PE1AYX
[  410.785506] mkiss: ax0: crc mode is auto.
[  410.786135] IPv6: ADDRCONF(NETDEV_CHANGE): ax0: link becomes ready
[  411.011461] ROSE: rose_setup()
[  411.012685] ROSE: rose_setup()
[  411.014506] ROSE: rose_setup()
[  411.016902] ROSE: rose_setup()
[  411.021736] ROSE: rose_setup()
[  411.023884] ROSE: rose_setup()
[  411.026132] ROSE: rose_setup()
[  411.028349] ROSE: rose_setup()
[  411.030648] ROSE: rose_setup()
[  411.032975] ROSE: rose_setup()
[  411.033688] NET: Registered protocol family 11
[  411.037511] ROSE: rose_set_mac_address()
[  411.037987] ROSE: rose_open()
[  412.041361] ROSE: rose_connect()
[  414.053240] ROSE: rose_connect()
[  414.053599] mkiss: ax0: Trying crc-smack
[  414.058881] mkiss: ax0: Trying crc-flexnet
[  414.086670] ROSE: rose_route_frame()
[  414.152265] ROSE: rose_route_frame()
[  471.414622] ROSE: rose_connect()
[  471.449136] ROSE: rose_route_frame()
[  471.694472] ROSE: rose_route_frame()
[  471.695823] ROSE: rose_recvmsg()

Application fpacnode client shows that node is connected to local=20
neighbour and
application works normally.

Next configuration trial was with ax25ipd.conf configured for and a=20
remote subnet
rose neighbour:

# Route HAMNET
# F6BVP-10/11
route f6cnb-9 44.168.12.18 udp 10092 b
route f6cnb-11 44.168.12.20 udp 10092 b
#

Kernel route table is the same as before, i.e. still without any gatewa=
y
for 44.0.0.0 route.

This time printks show a different scenario when starting rose:

  1863.750045] mkiss: AX.25 Multikiss, Hans Albas PE1AYX
[ 1863.751165] mkiss: ax0: crc mode is auto.
[ 1863.755760] IPv6: ADDRCONF(NETDEV_CHANGE): ax0: link becomes ready
[ 1863.792418] ROSE: rose_set_mac_address()
[ 1863.795116] ROSE: rose_open()
[ 1864.797375] ROSE: rose_connect()
[ 1866.809240] ROSE: rose_connect()
[ 1866.809662] mkiss: ax0: Trying crc-smack
[ 1866.811740] ROSE: rose_connect()
[ 1866.811983] ROSE: rose_header()
[ 1866.811990] ROSE: rose_xmit()
[ 1866.811990] ROSE: rose_route_frame()
[ 1866.811992] rose_route : unknown neighbour or device '*'
[ 1866.813647] mkiss: ax0: Trying crc-flexnet
[ 1866.815623] ROSE: rose_header()
[ 1866.817228] ROSE: rose_xmit()
[ 1866.818808] ROSE: rose_route_frame()
[ 1866.820411] rose_route : unknown neighbour or device '*'
[ 1876.832984] ROSE: rose_header()
[ 1876.834572] ROSE: rose_xmit()
[ 1876.836093] ROSE: rose_route_frame()
[ 1876.837614] rose_route : unknown neighbour or device '*'
[ 1876.839574] ROSE: rose_header()
[ 1876.841099] ROSE: rose_xmit()
[ 1876.842586] ROSE: rose_route_frame()
[ 1876.844083] rose_route : unknown neighbour or device '*'

With the patch ax25cmp() comparison fails and message
unknown neighbor or device '*'
is correctly displayed for rose_neigh =3D=3D NULL

Of course, because there is no route or gateway toward this subnetwork
in kernel route table, neighbour node is not connected and fpacnode=20
application
is informed about it. Thus system operator knows there is something
wrong in rose network configuration.

Next trial was performed after adding a gateway toward remote rose neig=
hbour
sub net.

/sbin/route add -net 44.0.0.0/8 gw 44.168.19.17

This time starting rose shows no more rose_xmit():

  9871.374021] mkiss: AX.25 Multikiss, Hans Albas PE1AYX
[ 9871.375418] mkiss: ax0: crc mode is auto.
[ 9871.376747] IPv6: ADDRCONF(NETDEV_CHANGE): ax0: link becomes ready
[ 9871.479231] ROSE: rose_set_mac_address()
[ 9871.479795] ROSE: rose_open()
[ 9872.481622] ROSE: rose_connect()
[ 9874.494286] ROSE: rose_connect()
[ 9874.494712] mkiss: ax0: Trying crc-smack
[ 9874.496477] ROSE: rose_connect()
[ 9874.497012] mkiss: ax0: Trying crc-flexnet
[10029.645910] ROSE: rose_connect()
[10029.656025] ROSE: rose_sendmsg()
[10029.666022] ROSE: rose_recvmsg()
[10029.666390] ROSE: rose_sendmsg()
[10029.676014] ROSE: rose_recvmsg()
[10029.686035] ROSE: rose_recvmsg()
[10039.632987] ROSE: rose_connect()
[10039.643081] ROSE: rose_sendmsg()
[10039.653027] ROSE: rose_recvmsg()
[10039.653453] ROSE: rose_sendmsg()
[10039.663022] ROSE: rose_recvmsg()

And a final trial was after removing again subnet route and gateway:

/sbin/route del -net 44.0.0.0/8

[ 5707.295943] mkiss: AX.25 Multikiss, Hans Albas PE1AYX
[ 5707.297031] mkiss: ax0: crc mode is auto.
[ 5707.299063] IPv6: ADDRCONF(NETDEV_CHANGE): ax0: link becomes ready
[ 5707.339840] ROSE: rose_set_mac_address()
[ 5707.340550] ROSE: rose_open()
[ 5707.345682] ROSE: rose_connect()
[ 5709.358367] ROSE: rose_connect()
[ 5709.358785] mkiss: ax0: Trying crc-smack
[ 5709.360589] ROSE: rose_connect()
[ 5709.361116] mkiss: ax0: Trying crc-flexnet
[ 5709.361553] ROSE: rose_header()
[ 5709.361558] ROSE: rose_xmit()
[ 5709.361559] ROSE: rose_route_frame()
[ 5709.361560] rose_route : unknown neighbour or device '*'
[ 5709.369564] ROSE: rose_header()
[ 5709.371134] ROSE: rose_xmit()
[ 5709.372695] ROSE: rose_route_frame()
[ 5709.374258] rose_route : unknown neighbour or device '*'
[ 5719.392472] ROSE: rose_header()
[ 5719.394032] ROSE: rose_xmit()
[ 5719.395536] ROSE: rose_route_frame()
[ 5719.395538] rose_route : unknown neighbour or device '*'
[ 5719.396035] ROSE: rose_header()
[ 5719.396040] ROSE: rose_xmit()
[ 5719.396041] ROSE: rose_route_frame()
[ 5719.396042] rose_route : unknown neighbour or device '*'

Conclusion : rose_header and rose_xmit() are only activated when a rout=
e
to a rose_neighbour is not found in kernel table.

This is initialized in rose_setup() that sets

dev->netdev_ops         =3D &rose_netdev_ops;

and we have :

static const struct net_device_ops rose_netdev_ops =3D {
         .ndo_open               =3D rose_open,
         .ndo_stop               =3D rose_close,
         .ndo_start_xmit         =3D rose_xmit,
         .ndo_set_mac_address    =3D rose_set_mac_address,
};

I guess, there is no need for more demonstrations of this patch utility=
=2E
It avoids kernel panic in case of uncomplete subnet route setting
(lack of gateway) and triggers error message (when proper console
printk level is set).

One last remark. Patch uses an ax25_cb parameter for called
rose_route_device()  is looking for an  ax25->dest_address
in ax25_cb structure

Bernard Pidoux


Le 03/03/2016 23:02, David Miller a =E9crit :
> From: f6bvp <f6bvp@free.fr>
> Date: Tue, 1 Mar 2016 21:37:14 +0100
>
>> I built the following patch in order to obtain the same result witho=
ut
>> NULL pointer.
> But it will cause every packet to be dropped because rose_route_frame=
() won't
> find a matching neighbour, and therefore return 0 to rose_xmit().
