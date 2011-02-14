From: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: [patch net-next-2.6] net: make dev->master general
Date: Mon, 14 Feb 2011 15:11:14 +0100
Message-ID: <4D593802.8090508@gmail.com>
References: <20110212164836.GB12156@psychotron.redhat.com> <4D58EC6C.7030005@gmail.com> <20110214090133.GB2746@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	shemminger@linux-foundation.org, kaber@trash.net, fubar@us.ibm.com,
	eric.dumazet@gmail.com
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:52711 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754293Ab1BNOLR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Feb 2011 09:11:17 -0500
Received: by fxm20 with SMTP id 20so5257498fxm.19
        for <netdev@vger.kernel.org>; Mon, 14 Feb 2011 06:11:16 -0800 (PST)
In-Reply-To: <20110214090133.GB2746@psychotron.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 14/02/2011 10:01, Jiri Pirko a =E9crit :
> Mon, Feb 14, 2011 at 09:48:44AM CET, nicolas.2p.debian@gmail.com wrot=
e:
>> Le 12/02/2011 17:48, Jiri Pirko a =E9crit :
>>> dev->master is now tightly connected to bonding driver. This patch =
makes
>>> this pointer more general and ready to be used by others.
>>>
>>>   - netdev_set_master() - bond specifics moved to new function
>>>     netdev_set_bond_master()
>>>   - introduced netif_is_bond_slave() to check if device is a bondin=
g slave
>>>
>>> Signed-off-by: Jiri Pirko<jpirko@redhat.com>
>>
>> Hi Jiri,
>>
>> Even if DaveM already applied your patch, I'm not comfortable with i=
t.
>>
>> What is the rational behind it? Do you have anything in mind to use
>> the now "more general" master field of net_device?
>>
>> Of course, I won't advocate for every fields having only a single
>> possible usage, but, using master for several different things might
>> jeopardize our ability to share an interface between several logical
>> interface systems:
>>
>> Due to the current usage of the rx_handler field in net_device, the
>> code suggest that an interface cannot be part of a bridge and of a
>> macvlan at the same time. Even if bridge provide an hook for ebtable=
s
>> to ignore an skb and allow other to get it, macvlan cannot be
>> registered on the same lower interface as a bridge, because
>> rx_handler can only hold a single value.
>>
>> By giving master a more general meaning, I think we might face a
>> similar problem. It might disallow an interface to be enslaved to
>> bonding and part of another logical interface at the same time, if
>> such logical interface also use the master field.
>
> That is true. I think that it makes no sense to have iface enslaved i=
n
> bond and bridge at the same time. Do you have a scenario where it mak=
es
> sense?

Agreed for bonding/bridge, because both tend to eat all skb, even if br=
idge has a way to give skb to=20
others, as stated above. Bonding might/should do the same.

But, for macvlan or vlan for example, it is different. They will ignore=
 skb not matching the correct=20
dst_mac (macvlan) or vlan_id (vlan) and give a chance to other to use t=
he skb.

Many setups involving several logical ifaces sharing a physical iface m=
ake sense:

- bridge+vlan (see "2.6.37 regression: adding main interface to a bridg=
e breaks vlan interface RX")
- bride+macvlan (In particular because bridge might no know about the o=
ther dst_macs that should be=20
considered local. I didn't check that particular point in detail.)
- bonding+vlan
- bonding+macvlan

So, would master be used only for ifaces that "eat all skb"?

	Nicolas.
