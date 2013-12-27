From: Alexandre DERUMIER <aderumier@odiso.com>
Subject: Re: bridge vlan_filtering don't work with tap devices (qemu guests)
Date: Fri, 27 Dec 2013 10:46:38 +0100 (CET)
Message-ID: <5dd2cfa8-b0d2-4f6b-a1bc-cbfbff4c7517@mailpro>
References: <1388132917.8290.22.camel@ubuntu-vm-makita>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Vlad Yasevich <vyasevic@redhat.com>
To: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailpro.odiso.net ([89.248.209.98]:60516 "EHLO
	mailpro.odiso.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754186Ab3L0Jqp convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Dec 2013 04:46:45 -0500
In-Reply-To: <1388132917.8290.22.camel@ubuntu-vm-makita>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>With these settings, you should be able to see tagged frames on bridg=
e=20
>>device with promisc mode.=20
>>Are you sure you enabled vlan_filtering by sysfs?=20
Yes,It's enabled.

>>Or didn't you set br0 in the same way as other ports like below?=20
>># bridge vlan add dev br0 vid 10 pvid untagged self=20

Indeed I didn't set vlan on br0. Isn't it only to tag packets coming fr=
om the bridge itself? (like a bridge management ip for example).
Or do we need to define all vlans allowed to pass through the bridge ?

about tcdpump:

I'm just using tcpdump -i br0 -e -n , and don't see any vlan tag.
But maybe it's related to tcpdump bug, I have also had some random kern=
el panic.


>>If you set pvid, incoming frames from the port will be tagged with th=
e=20
>>vlan.=20
>>If you set untagged, outgoing frames with the vlan from the port will=
 be=20
>>untagged.=20

>>So, if you want to send frames tagged with vlan 10, please don't set =
vid=20
>>10 untagged on outgoing ports you want.=20

Oh, ok, it's clear now.



----- Mail original -----=20

De: "Toshiaki Makita" <makita.toshiaki@lab.ntt.co.jp>=20
=C3=80: "Alexandre DERUMIER" <aderumier@odiso.com>=20
Cc: netdev@vger.kernel.org, "Vlad Yasevich" <vyasevic@redhat.com>=20
Envoy=C3=A9: Vendredi 27 D=C3=A9cembre 2013 09:28:37=20
Objet: Re: bridge vlan_filtering don't work with tap devices (qemu gues=
ts)=20

2013-12-26 (=E6=9C=A8) =E3=81=AE 14:57 +0100 =E3=81=AB Alexandre DERUMI=
ER =E3=81=95=E3=82=93=E3=81=AF=E6=9B=B8=E3=81=8D=E3=81=BE=E3=81=97=E3=81=
=9F:=20
> Hello Again,=20
>=20
> One more question :=20
>=20
> If I use tcpdump on br0, I don't see any tagged vlan10 packets on the=
 bridge.=20
> with=20
> # bridge vlan add dev tap0 vid 10 pvid untagged=20
> # bridge vlan add dev tap1 vid 10 pvid untagged=20

With these settings, you should be able to see tagged frames on bridge=20
device with promisc mode.=20
Are you sure you enabled vlan_filtering by sysfs?=20
Or didn't you set br0 in the same way as other ports like below?=20
# bridge vlan add dev br0 vid 10 pvid untagged self=20

>=20
>=20
> What I would like to do, is tagging vlan10, incoming (untagged) packe=
ts from tap0 and tap1.=20
>=20
> Is it possible ?=20

If you set pvid, incoming frames from the port will be tagged with the=20
vlan.=20
If you set untagged, outgoing frames with the vlan from the port will b=
e=20
untagged.=20

So, if you want to send frames tagged with vlan 10, please don't set vi=
d=20
10 untagged on outgoing ports you want.=20


BTW:=20
(CC: Vlad)=20
I tested to execute tcpdump on br0 with vlan_filtering enabled, but=20
kernel panic occurred with upstream net-tree kernel. br_handle_vlan()=20
seems to have a bug that it doesn't check pv is NULL or not.=20
br_pass_frame_up() calls br_handle_vlan() even if br->vlan_info is NULL=
=20
when bridge device is promisc mode.=20
This will occur if we don't add any vlan on the bridge device.=20
I'm going to make a patch to fix it.=20

Thanks,=20
Toshiaki Makita=20

>=20
> With openvswitch, I can do it simply with "ovs-vsctl set port tap0 ta=
g=3D10"=20
>=20
