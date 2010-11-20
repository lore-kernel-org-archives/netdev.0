From: Ben Greear <greearb@candelatech.com>
Subject: Re: netlink stats and message ordering.
Date: Fri, 19 Nov 2010 21:10:50 -0800
Message-ID: <4CE7585A.8050408@candelatech.com>
References: <4CE6BFE1.6020404@candelatech.com> <1290228542.2756.57.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: NetDev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:57582 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750758Ab0KTFKx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Nov 2010 00:10:53 -0500
In-Reply-To: <1290228542.2756.57.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/19/2010 08:49 PM, Eric Dumazet wrote:
> Le vendredi 19 novembre 2010 =C3=A0 10:20 -0800, Ben Greear a =C3=A9c=
rit :
>> I have a single netlink socket that listens for various things,
>> as well as requests netdev stats and such.
>>
>> I am seeing a case during interface creation (mac-vlans) where I get=
 one set of stats
>> that appears to show 1 packet transmitted, and then immediately afte=
r that,
>> a second set of stats for the same device that shows all zero counte=
rs.
>>
>> Since I'm trying to handle wraps properly, my code tends to consider=
 this
>> a wrap and of course the numbers go all wrong since it wasn't really=
 a wrap.
>>
>> I am wondering if it's possible that netlink messages are somehow be=
ing
>> re-ordered before they are sent to my application?
>
> That's strange, maybe you could add a timestamp (or a sequence number=
)
> in the stats message to check if two messages are eventually re-order=
ed.

I am becoming suspicious that I may have a re-entrancy issue in my code=
=2E.maybe while
handling a dev-create message I am calling into the netlink-read logic =
again before
handling all of the messages that were read in the initial call.

I'm going to have to think on this more, and if nothing obvious comes u=
p,
I'll try your suggestion for incrementing one of the stats by one each =
time.

Thanks,
Ben

>
> diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
> index 93f0ba2..1d271ca 100644
> --- a/drivers/net/macvlan.c
> +++ b/drivers/net/macvlan.c
> @@ -444,6 +444,7 @@ static struct rtnl_link_stats64 *macvlan_dev_get_=
stats64(struct net_device *dev,
>   {
>   	struct macvlan_dev *vlan =3D netdev_priv(dev);
>
> +	atomic_long_inc(&dev->rx_dropped);
>   	if (vlan->pcpu_stats) {
>   		struct macvlan_pcpu_stats *p;
>   		u64 rx_packets, rx_bytes, rx_multicast, tx_packets, tx_bytes;
>


--=20
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
