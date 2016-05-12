From: Doug Ledford <dledford@redhat.com>
Subject: Re: mlx5 core/en oops in 4.6-rc6+
Date: Thu, 12 May 2016 13:28:08 -0400
Message-ID: <79e8e8c2-6905-e9c4-b817-f5d5a21b8873@redhat.com>
References: <56df9c0a-39dd-6e07-9466-23195dc60860@redhat.com>
 <CALzJLG9_PLzU=Qwvv=_3aEd0KQr1c9rZyfcrfuLPo8wF=F_B0A@mail.gmail.com>
 <b4a8c4ca-74c5-b9b4-f9a5-4386cf6857fe@redhat.com>
 <CALzJLG8ho88yJStHbPg+XFtEJHDQf3s20gjnsEdRdh4mGye7FQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="euBbJWTuDBlaqpBc8kKGEJqwC5JaqFwGs"
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41258 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752428AbcELR2K (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 May 2016 13:28:10 -0400
In-Reply-To: <CALzJLG8ho88yJStHbPg+XFtEJHDQf3s20gjnsEdRdh4mGye7FQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--euBbJWTuDBlaqpBc8kKGEJqwC5JaqFwGs
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 05/05/2016 04:51 PM, Saeed Mahameed wrote:
> On Thu, May 5, 2016 at 8:16 PM, Doug Ledford <dledford@redhat.com> wrot=
e:
>>
>> That depends on which interface actually generated the oops.  If it wa=
s
>> the base interface, then I don't manually set any special params on it=
=2E
>> If it's one of the vlan interfaces, then there is a NetworkManager
>> dispatcher script that is intended to set the tc count on interface up=
:
>>
>> [root@rdma-virt-03 ~]$ more /etc/NetworkManager/dispatcher.d/98-mlx5_r=
oce.4*
>> ::::::::::::::
>> /etc/NetworkManager/dispatcher.d/98-mlx5_roce.43-egress.conf
>> ::::::::::::::
>> #!/bin/sh
>> interface=3D$1
>> status=3D$2
>> [ "$interface" =3D mlx5_roce.43 ] || exit 0
>> case $status in
>> up)
>>         tc qdisc add dev mlx5_roce root mqprio num_tc 8 map 5 5 5 5 5 =
5 5 5 5 5
>> 5 5 5 5 5 5
>=20
> Well, here you are configuring 8 TCs on the base mlx5 interface, so
> the answer to my question is yes.

Correct.  I mentioned that at the end of my email ;-)

> It appears that we have a bug in mlx5e_slelect_queue
>=20
> int channel_ix =3D fallback(dev, skb);
> return priv->channeltc_to_txq_map[channel_ix][tc];
>=20
> When num_tc > 1 the fallback can return any value between [0..
> num_channles * num_tc ]
>=20
> while channeltc_to_txq_map is an array of the size num_channels.
>=20
> so there is a good chance that channel_ix exceeds the array limits and
> resulting OOPs.
>=20
>>         # tc_wrap.py -i mlx5_roce -u 5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5
>>         ;;
>> esac
>> --More--(Next file:
>> /etc/NetworkManager/dispatcher.d/98-mlx5_roce.45-egress.conf::::::::::=
::::
>> /etc/NetworkManager/dispatcher.d/98-mlx5_roce.45-egress.conf
>> ::::::::::::::
>> #!/bin/sh
>> interface=3D$1
>> status=3D$2
>> [ "$interface" =3D mlx5_roce.45 ] || exit 0
>> case $status in
>> up)
>>         tc qdisc add dev mlx5_roce root mqprio num_tc 8 map 5 5 5 5 5 =
5 5 5 5 5
>> 5 5 5 5 5 5
>=20
> will, here you map all user skb prios (skb->priority) to HW tc 5.
> BTW skprio or user prio in this example is never the vlan prio it is
> the ipv4 (ToS).
>=20
> please see http://lartc.org/manpages/tc-prio.html

Ok.

> So to achieve a vlan prio to HW tc mapping, you will need to map the
> skprios to vlan prios using vlan egress mapping
> which i see you already do down below.

I do, and this is all related to trying to get PFC working for RoCE on
these cards.  For the most part, the things you see here are documented
in the Mellanox guides related to RoCE setup, or they are things I
pulled from the tcwrap.py program that you guys distribute for setting
this stuff up.

> But, our select queue implementation will extract the vlan priority
> and use the corresponding TC from our own
> priv->channeltc_to_txq_map[channel_ix][up] mapping
> where up is vlan user priority.  but this only applies to kernel
> traffic, i don't see why it is needed for RoCE.

Read your own guides ;-).

I'm using this one for your switches:
https://community.mellanox.com/docs/DOC-1417

And these to try and get the linux machines configured properly:
https://community.mellanox.com/docs/DOC-1414
https://community.mellanox.com/docs/DOC-1415
https://community.mellanox.com/docs/DOC-2311
https://community.mellanox.com/docs/DOC-2474
http://www.mellanox.com/related-docs/prod_software/RoCE_with_Priority_Flo=
w_Control_Application_Guide.pdf

The guides are helpful if your setup allows you to follow their exact
example.  But, they are shy on information about how to modify the
examples to your specific situation.  For instance, I have to use vlan
priority 5 as my no-drop priority for RoCE traffic.  I can't reliably
tell which portions of the guide I must switch the 3s to 5s in order to
get the new priority, and which uses of 3s in the guides relate to other
things that could be mapped to 5.  On a separate note, it's unclear to
me if your switches and cards support more than one no-drop priority
(other vendor's RoCE cards I'm using here don't, they only allow one
no-drop priority for RoCE traffic and it must be 5).  If it does support
more than one, I'd actually like both 3 and 5 to be no-drop and for one
vlan to use 3 and another to use 5.

> As i said above configuring any num_tc > 1 might cause the panic you sa=
w.
>=20
> Regarding the proper mapping to do for 45 =3D> priority 5, 43 =3D> prio=
 3.
> the egress mappings you already did above should be sufficient, the
> question is, do you need the vlan priorities to be mapped to a
> specific HW TC dispatchers ?

You'd have to tell me.  The switch docs make it clear that it's best if
no-drop priorities are mapped to TC1 or TC2 (which is not necessarily
the same as the TC mapping you refer to here as far as I know, but it
might be similar).  The doc on setting up ConnectX-4 cards talks about
the same basic TC dispatchers on the card, but instead of 4 like the
switches have, there are 8.  So, does the card's built in
firmware/silicon have a preference for where no-drop traffic is queued
via TC dispatches like the switches do?

>=20
> if not, then you don't need to configure  "tc qdisc add dev mlx5_roce
> root ..." at all.

That appears to be a question for Mellanox to answer.  I can't say.


--=20
Doug Ledford <dledford@redhat.com>
              GPG KeyID: 0E572FDD



--euBbJWTuDBlaqpBc8kKGEJqwC5JaqFwGs
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQIcBAEBCAAGBQJXNL0pAAoJELgmozMOVy/dbmYQAK8RnPcJAXtnTnJzDLLCK27y
lZqhC3X6xVme28RzcRJmU6iOQBq3toflhhqsjPn5SvbzgIM3JA51zmLdWPDkmFh4
zm0ktgvu++AAxkh6m6pfr/xrIRPPeh+kycdENdNF7PktVhOlhvrkT7h0eclO3Dpr
K1m0VFhmUSYK9Qv0rvChEqWnM6ATz5f5TQF3ixW9IrJ/e+dPm2x42NeszGFkxLFt
OyxzHuGYRZHErh98C+qqZhW6JUuGjSfG2NNcyElzhKcz2OdhxdKIP6u3C098tbfH
laZ18D6d21rps0u8WSZxD5oQDzkRwNpfOaK6MvIBE1OflR8rJMeP2hASX8i2Eyo0
r3J246achmFqta75SwEOFF3bqiT6fI+4nt/jk3X4oTPaQRau7tH2haZ3zB3ZmpLH
G7QgHuGWIlwXpnP6g98+t49OS+2s54/mARdEhAvE4M3H3qkvox8jKvoEeYR9hwiD
rSgk00aDKF89xWZWbB+3kibF7oPXigOYFL4Wb/VvBhrnFw68g5GDwhtFv9dzWRPG
4sReh2weDYReaxSRY8QpdJWbSG5W+KUH+VQDrI8dWtk0H4zPwmLbtOZfs8/UK0sH
5/vyBJu7XoOg7CJ4g+owr7juYVcxgFFEu+JeyPGVaHOuRVNXWFrRhH03AI8kc/hw
iUzv0xiqQbCNDVQSxpju
=XA5J
-----END PGP SIGNATURE-----

--euBbJWTuDBlaqpBc8kKGEJqwC5JaqFwGs--
