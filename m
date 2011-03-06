From: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: Possible regression in __netif_receive_skb() between 2.6.38-rc7
 and net-next-2.6
Date: Sun, 06 Mar 2011 14:08:33 +0100
Message-ID: <4D738751.6050209@gmail.com>
References: <4D72AB79.3000605@gmail.com> <20110305220938.GK8573@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Patrick Mc Hardy <kaber@trash.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:57171 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752451Ab1CFNIh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Mar 2011 08:08:37 -0500
Received: by wyg36 with SMTP id 36so3453293wyg.19
        for <netdev@vger.kernel.org>; Sun, 06 Mar 2011 05:08:36 -0800 (PST)
In-Reply-To: <20110305220938.GK8573@psychotron.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 05/03/2011 23:09, Jiri Pirko a =E9crit :
> Sat, Mar 05, 2011 at 10:30:33PM CET, nicolas.2p.debian@gmail.com wrot=
e:
>> Hi,
>>
>> Comparing __netif_receive_skb() between 2.6.38-rc7 and net-next-2.6,
>> I noticed an important difference: The ptype_base loop used to
>> deliver to orig_dev and this is not true anymore.
>
> I believe this is adressed by submitted patch " net: allow handlers t=
o
> be processed for orig_dev"

I wonder whether we should address it that way (which is the former way=
 to address it).

There are still a difference between ptype_all and ptype_base delivery:

- For ptype_all, we deliver to every device crossed while walking the r=
x_handler path (inside the=20
another_round loop). (And there is no way to force exact match delivery=
).

- For ptype_base, we deliver to the lowest device (orig_dev) and to the=
 highest (skb->dev) and we=20
can ask for exact match delivery.

This sounds very inconsistent. The only difference between ptype_all an=
d ptype_base is the fact that=20
ptype->type is NULL (wildcard) for the first and not NULL (a particular=
 protocol) for the second.

I think we should:

1/ deliver to both ptype_all and ptype_base while walking the rx_handle=
r path, but only exact match=20
(ptype->dev =3D=3D skb->dev).
2/ deliver to both ptype_all and ptype_base at the end of __netif_recei=
ve_skb(), but only wildcard=20
match (ptype->dev =3D=3D NULL), skipping this part if the last rx_handl=
er returned RX_HANDLER_EXACT.

	Nicolas.

>> Imagine the following simple setup:
>>
>> eth0 ->  bond0
>>
>> - A packet handler registered on eth0, with ptype->type =3D=3D NULL =
will
>> receive the packet, because it will be delivered in the ptype_all
>> loop, which is inside the another_round loop.
>> - The same packet handler, registered on eth0, but with ptype->type
>> !=3D NULL won't receive the packet, because the ptype_base loop does=
n't
>> deliver to orig_dev anymore.
>>
>> I think this can lead to a regression for user space: an application
>> using af_packet to listen to eth0 will receive the packet flow if th=
e
>> registered protocol is NULL, but won't receive anything if the
>> registered protocol is not NULL.
>>
>> Can someone confirm?
>>
>> 	Nicolas.
>

