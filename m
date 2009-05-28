From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [PATCH net-next] bonding: allow bond in mode balance-alb to
	work properly in bridge -try4.2
Date: Thu, 28 May 2009 11:57:20 +0200
Message-ID: <20090528095719.GD22391@psychotron.englab.brq.redhat.com>
References: <20090313183303.GF3436@psychotron.englab.brq.redhat.com> <20090326155205.GA28868@psychotron.englab.brq.redhat.com> <20090526151717.GB11147@psychotron.englab.brq.redhat.com> <20090527135351.GD1652@psychotron.englab.brq.redhat.com> <4A1D509A.5020205@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, jgarzik@pobox.com, davem@davemloft.net,
	shemminger@linux-foundation.org, bridge@lists.linux-foundation.org,
	fubar@us.ibm.com, bonding-devel@lists.sourceforge.net,
	kaber@trash.net, mschmidt@redhat.com, andy@greyhouse.net,
	oleg@redhat.com
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:49130 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753591AbZE1J6B (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 May 2009 05:58:01 -0400
Content-Disposition: inline
In-Reply-To: <4A1D509A.5020205@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, May 27, 2009 at 04:39:22PM CEST, dada1@cosmosbay.com wrote:
>Jiri Pirko a =E9crit :
>> [PATCH net-next] bonding: allow bond in mode balance-alb to work pro=
perly in bridge -try4.2
>>=20
>> (updated)
>> changes v4.1 -> v4.2
>> - use skb->pkt_type =3D=3D PACKET_HOST compare rather then comparing=
 skb dest addr
>>   against skb->dev->dev_addr
>>=20
>> Hi all.
>>=20
>> The problem is described in following bugzilla:
>> https://bugzilla.redhat.com/show_bug.cgi?id=3D487763
>>=20
>> Basically here's what's going on. In every mode, bonding interface u=
ses the same
>> mac address for all enslaved devices (except fail_over_mac). Only ba=
lance-alb
>> will simultaneously use multiple MAC addresses across different slav=
es. When you
>> put this kind of bond device into a bridge it will only add one of m=
ac adresses
>> into a hash list of mac addresses, say X. This mac address is marked=
 as local.
>> But this bonding interface also has mac address Y. Now then packet a=
rrives with
>> destination address Y, this address is not marked as local and the p=
acked looks
>> like it needs to be forwarded. This packet is then lost which is wro=
ng.
>>=20
>> Notice that interfaces can be added and removed from bond while it i=
s in bridge.
>>=20
>> ***
>> When the multiple addresses for bridge port approach failed to solve=
 this issue
>> due to STP I started to think other way to solve this. I returned to=
 previous
>> solution but tweaked one.
>>=20
>> This patch solves the situation in the bonding without touching brid=
ge code.
>> For every incoming frame to bonding the destination address is compa=
red to
>> current address of the slave device from which tha packet came. If t=
hese two
>> match destination address is replaced by mac address of the master. =
This address
>> is known by bridge so it is delivered properly. Note that the compar=
sion is not
>> made directly, it's used skb->pkt_type =3D=3D PACKET_HOST instead. T=
his is "set"
>> previously in eth_type_trans().
>>=20
>> I experimentally tried that this works as good as searching through =
the slave
>> list (v4 of this patch).
>>=20
>> I was forced to create a new header because I need to use
>> compare_ether_addr_64bits() (defined in linux/etherdevice.h) in
>> linux/netdevice.h. I've hit some cross include issues. I think that =
it's good
>> to have skb_bond_should_drop() in a separate file anyway.
>>=20
>> Jirka
>>=20
>>=20
>> Signed-off-by: Jiri Pirko <jpirko@redhat.com>
>>=20
>> diff --git a/include/linux/bonding.h b/include/linux/bonding.h
>> new file mode 100644
>> index 0000000..e50939d
>> --- /dev/null
>> +++ b/include/linux/bonding.h
>> @@ -0,0 +1,78 @@
>> +/*
>> + * include/linux/bonding.h
>> + *
>> + * Copyright (C) 2009 Jiri Pirko <jpirko@redhat.com>
>> + *
>> + * This program is free software; you can redistribute it and/or mo=
dify
>> + * it under the terms of the GNU General Public License version 2
>> + * as published by the Free Software Foundation.
>> + *
>> + * Bonding device helpers.
>> + */
>> +
>> +#ifndef _LINUX_BONDING_H
>> +#define _LINUX_BONDING_H
>> +
>> +#ifdef __KERNEL__
>> +
>> +#include <linux/skbuff.h>
>> +#include <linux/netdevice.h>
>> +#include <linux/if.h>
>> +#include <linux/etherdevice.h>
>> +#include <linux/if_ether.h>
>> +#include <linux/if_packet.h>
>> +
>> +static inline void skb_bond_set_mac_by_master(struct sk_buff *skb,
>> +					      struct net_device *master)
>> +{
>> +	unsigned char *dest =3D eth_hdr(skb)->h_dest;
>> +
>> +	if (compare_ether_addr_64bits(dest, master->dev_addr) &&
>> +	    (skb->pkt_type =3D=3D PACKET_HOST))
>> +		memcpy(dest, master->dev_addr, ETH_ALEN);
>
>Just overwriting the dest would be faster, and avoids
>to include <linux/etherdevice.h>, maybe a new include file
>could be avoided ?
>
>If it is already the master->dev_addr, then memcpy() is a no-op
>If it wasnt the master->dev_addr, then memcpy() does what you wanted.
>
>You can also give a hint to gcc as h_dest is guaranteed to be 16 bit a=
ligned
>
>static inline void skb_bond_set_mac_by_master(struct sk_buff *skb,
>					      struct net_device *master)
>{
>	if (skb->pkt_type =3D=3D PACKET_HOST) {
>		u16 *dest =3D (u16 *)eth_hdr(skb)->h_dest;
>
>		memcpy(dest, master->dev_addr, ETH_ALEN);
>	}
>}
>
>Compiler will emit better code for memcpy() on some arches.
>(not on x86, as it already does one 32bit and one 16bit move)

Okay, I consulted the comparing/memcpy question with Oleg (cc'ed) and h=
e also
agree to do this your way. I'll make a patch, test it and post it soon.

Thanks Eric.
>
>
