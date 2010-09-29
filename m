From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH] ipv4: remove all rt cache entries on UNREGISTER event
Date: Wed, 29 Sep 2010 09:49:48 +0200
Message-ID: <4CA2EF9C.9040909@6wind.com>
References: <4CA208C9.1020800@6wind.com>	 <1285691629.3154.80.camel@edumazet-laptop>  <4CA21BC6.5070300@6wind.com> <1285692969.3154.86.camel@edumazet-laptop>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Octavian Purdila <opurdila@ixiacom.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:55638 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752819Ab0I2Htw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Sep 2010 03:49:52 -0400
Received: by wyb28 with SMTP id 28so462892wyb.19
        for <netdev@vger.kernel.org>; Wed, 29 Sep 2010 00:49:50 -0700 (PDT)
In-Reply-To: <1285692969.3154.86.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> Le mardi 28 septembre 2010 =C3=A0 18:45 +0200, Nicolas Dichtel a =C3=A9=
crit :
>> Eric Dumazet wrote:
>>> Le mardi 28 septembre 2010 =C3=A0 17:24 +0200, Nicolas Dichtel a =C3=
=A9crit :
>>>> Hi,
>>>>
>>>> I face a problem when I try to remove an interface,=20
>>>> netdev_wait_allrefs() complains about refcount.
>>>>
>>>> Here is a trivial scenario to reproduce the problem:
>>>> # ip tunnel add mode ipip remote 10.16.0.164 local 10.16.0.72 dev =
eth0
>>>> # ./a.out tunl1
>>>> # ip tunnel del tunl1
>>>>
>>>> Note: a.out binary create an IPv4 raw socket, attach it to tunl1=20
>>>> (SO_BINDTODEVICE), set it as multicast (IP_MULTICAST_LOOP), set th=
e=20
>>>> multicast interface to tunl1 (IP_MULTICAST_IF), build the IP heade=
r=20
>>>> (IP_HDRINCL) and then send a single packet (192.168.6.1 -> 224.0.0=
=2E18).
>>>>
>>>> Note2: when a.out is executed, tunl1 has no ip address and is down=
=2E
>>>>
>>> CC Octavian Purdila, the patch author.
>>>
>>> I am just wondering why this route is created in the first place.
The route is created because no function will check interface status (u=
p=20
and running or down). Just at the end, the packet will be enqueued in=20
the noop qdisc.

>> At first, I asked myself the same question, but it seems that this i=
s=20
>> allowed to send a packet through this kind of socket, even if interf=
ace=20
>> is down. Packet will be destroyed by the noop qdisk.
>> But I agree that it is strange to perform route lookup and everythin=
g to=20
>>    destroy the packet at the end ...
>> Maybe raw_sendmsg() can delete it directly ;-) ... or maybe=20
>> ip_route_output_flow().
>>
>> Any suggestions welcome.
>>
>=20
> Hmm...
>=20
> One way to track this kind of problem would be to add a WARN_ON() in
> dev_hold()
>=20
> -> Check that when a reference on dev is taken, we are in a known sta=
te.
>=20
> Something like this ?
dev_hold() is done when interface is down, but before unregistering=20
process start.

Regards,
Nicolas

>=20
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index 83de0eb..54bef78 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -1773,6 +1774,7 @@ static inline void dev_put(struct net_device *d=
ev)
>   */
>  static inline void dev_hold(struct net_device *dev)
>  {
> +	WARN_ON(dev->reg_state !=3D NETREG_REGISTERED);
>  	atomic_inc(&dev->refcnt);
>  }
> =20
>=20
>=20
