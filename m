From: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: [patch net-next-2.6] bonding: remove skb_share_check in handle_frame
Date: Wed, 02 Mar 2011 22:54:03 +0100
Message-ID: <4D6EBC7B.8040502@gmail.com>
References: <20110301062250.GB2855@psychotron.redhat.com> <20110301092907.GG2855@psychotron.redhat.com> <20110301203843.GN11864@gospo.rdu.redhat.com> <20110302100354.GB2858@psychotron.brq.redhat.com> <4D6EACF6.2040005@gmail.com> <20110302211238.GC3360@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org,
	davem@davemloft.net, fubar@us.ibm.com, eric.dumazet@gmail.com
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:36551 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754777Ab1CBVyH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2011 16:54:07 -0500
Received: by wwb22 with SMTP id 22so579594wwb.1
        for <netdev@vger.kernel.org>; Wed, 02 Mar 2011 13:54:06 -0800 (PST)
In-Reply-To: <20110302211238.GC3360@psychotron.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 02/03/2011 22:12, Jiri Pirko a =E9crit :
> Wed, Mar 02, 2011 at 09:47:50PM CET, nicolas.2p.debian@gmail.com wrot=
e:
>> Hi Jiri,
>>
>> Do you plan to call the bonding ARP handler from inside bond_handle_=
frame()?
>
> I do - it's part of patchset I've cooked (going to test that tomorrow=
).
>
>> A few days ago
>> (http://marc.info/?l=3Dlinux-netdev&m=3D129883949022340&w=3D2), I no=
ticed
>> that it is not possible to call the bonding ARP handler from inside
>> the bonding rx_handler, because some frame processing may be require=
d
>> after the bonding rx_handler call, to put the frame in a suitable
>> state for the bonding ARP handler.
>
> Do you see another scenario besides the next one?

None that currently work, but eth0 -> bond0 -> br0 -> br0.100 should wo=
rk too.

>> This is at least true with the following setup, eth0 ->  bond0 ->
>> bond0.100, where the ARP frames are VLAN tagged at the time the
>> bonding rx_handler process them.
>
> Isn't this scenario resolved by vlan_on_bond_hook ?
>
> eth0
>    ->rx_handler ->  another round
> bond0
>    ->vlan_hwaccel_do_receive ->  __netif_receive_skb
> bond0.100
>    ->vlan_on_bond_hook ->  reinject to bond0

Yes, it is, but this hack does not solve the eth0 -> bond0 -> br0 -> br=
0.100 configuration.

All those handlers that call netif_rx() or __netif_receive_skb() sound =
horrible to me. Can you=20
imagine the global overhead of the above receive path?

The reason why I suggested you introduce the goto another_round is beca=
use most - if not all -=20
stacking configurations could/should be handled simply by returning the=
 right skb from the=20
rx_handler and let __netif_receive_skb() loop. And by having the right =
orig_dev logic inside=20
__netif_receive_skb(), it could be possible to remove the current vlan_=
on_bond_hook hack.

My question about whether the skb is shared between the protocol handle=
rs (in another thread) also=20
target at this idea.

You will probably told me I'm free to propose patchs for all that, and =
you are right. Just missing=20
the time to do so.

	Nicolas.
