From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [RFC PATCH net-next 2/2] sit: add support of x-netns
Date: Mon, 24 Jun 2013 23:11:18 +0200
Message-ID: <51C8B5F6.7020603@6wind.com>
References: <87y5ijd98e.fsf@xmission.com> <1372083239-9451-1-git-send-email-nicolas.dichtel@6wind.com> <1372083239-9451-3-git-send-email-nicolas.dichtel@6wind.com> <878v1zjokr.fsf@xmission.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net, bcrl@kvack.org,
	ravi.mlists@gmail.com
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f178.google.com ([74.125.82.178]:63483 "EHLO
	mail-we0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750797Ab3FXVLV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jun 2013 17:11:21 -0400
Received: by mail-we0-f178.google.com with SMTP id u53so8726573wes.9
        for <netdev@vger.kernel.org>; Mon, 24 Jun 2013 14:11:20 -0700 (PDT)
In-Reply-To: <878v1zjokr.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 24/06/2013 21:28, Eric W. Biederman a =C3=A9crit :
> Nicolas Dichtel <nicolas.dichtel@6wind.com> writes:
>
>> This patch allows to switch the netns when packet is encapsulated or
>> decapsulated. In other word, the encapsulated packet is received in =
a netns,
>> where the lookup is done to find the tunnel. Once the tunnel is foun=
d, the
>> packet is decapsulated and injecting into the corresponding interfac=
e which
>> stands to another netns.
>>
>> When one of the two netns is removed, the tunnel is destroyed.
>
> I don't see any fundamental problems with this code.  There are bugs
> with the cleanup noted below.
>
> The primary sit interface is marked as NETNS_LOCAL which is good.  A
> comment might be nice explaining the reasonsing but for code
> archeologists.
Ok.

>
> Conditionally calling dev_cleanup_skb bugs me.  The extra conditional
> looks like a maintenance hazard.   Unless I have missed some subtle
> detail either we don't need the cleanup at all or actually it is a bu=
g
> that we aren't scrubbing our packets as they progress through tunnels
> even in the same network namespace.
>
> Can we just make that function the skb scrubbing needed for packets t=
o
> traverse a tunnel?
>
> My concern going into this was that we would get code that would brea=
k
> because it would not be tested enough.  If we can remove the conditio=
nal
> from dev_cleanup_skb we won't have any code that is conditionally run
> and the logic looks simple enough not to bitrot in routine maintenanc=
e.
My idea was to have the same level of cleanup/scrubbing that when a pac=
ket is=20
sent from a netns to another netns through a veth. I cannot use=20
dev_forward_skb() because this function expects to have an ethernet hea=
der, it's=20
why I split it in the patch #1.

If we leave all information attached to the skb, we may have, for examp=
le, an=20
skb with a conntrack from netns1 and a netdevice from netns2. It seems =
not safe,=20
but maybe I'm wrong. And in fact, the conntrack will not be created in =
the=20
second netns (nf_conntrack_in() =3D> skb->nfct is not null and not a te=
mplate =3D>=20
stats ignore++).
Another example is a socket from a netns and the netdevice or conntrack=
 from=20
another netns.
I was thinking that when a packet enter a namespace, it must not be ass=
ociated=20
to any object from the previous namespace, it should be like if we just=
 receive=20
it on the host.

Nicolas

>
> Eric
>
>> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
>> ---
>>   include/net/ip_tunnels.h |  1 +
>>   net/ipv4/ip_tunnel.c     |  7 ++++++-
>>   net/ipv6/sit.c           | 49 ++++++++++++++++++++++++------------=
------------
>>   3 files changed, 32 insertions(+), 25 deletions(-)
>>
>> diff --git a/include/net/ip_tunnels.h b/include/net/ip_tunnels.h
>> index b0d9824..781b3cf 100644
>> --- a/include/net/ip_tunnels.h
>> +++ b/include/net/ip_tunnels.h
>> @@ -42,6 +42,7 @@ struct ip_tunnel {
>>   	struct ip_tunnel __rcu	*next;
>>   	struct hlist_node hash_node;
>>   	struct net_device	*dev;
>> +	struct net		*net;	/* netns for packet i/o */
>>
>>   	int		err_count;	/* Number of arrived ICMP errors */
>>   	unsigned long	err_time;	/* Time when the last ICMP error
>> diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
>> index bd227e5..b6a7704 100644
>> --- a/net/ipv4/ip_tunnel.c
>> +++ b/net/ipv4/ip_tunnel.c
>> @@ -304,6 +304,7 @@ static struct net_device *__ip_tunnel_create(str=
uct net *net,
>>
>>   	tunnel =3D netdev_priv(dev);
>>   	tunnel->parms =3D *parms;
>> +	tunnel->net =3D net;
>>
>>   	err =3D register_netdevice(dev);
>>   	if (err)
>> @@ -453,6 +454,9 @@ int ip_tunnel_rcv(struct ip_tunnel *tunnel, stru=
ct sk_buff *skb,
>>   	tstats->rx_bytes +=3D skb->len;
>>   	u64_stats_update_end(&tstats->syncp);
>>
>> +	if (tunnel->net !=3D dev_net(tunnel->dev))
>> +		dev_cleanup_skb(skb);
>> +
>>   	if (tunnel->dev->type =3D=3D ARPHRD_ETHER) {
>>   		skb->protocol =3D eth_type_trans(skb, tunnel->dev);
>>   		skb_postpull_rcsum(skb, eth_hdr(skb), ETH_HLEN);
>> @@ -541,7 +545,7 @@ void ip_tunnel_xmit(struct sk_buff *skb, struct =
net_device *dev,
>>   			tos =3D ipv6_get_dsfield((const struct ipv6hdr *)inner_iph);
>>   	}
>>
>> -	rt =3D ip_route_output_tunnel(dev_net(dev), &fl4,
>> +	rt =3D ip_route_output_tunnel(tunnel->net, &fl4,
>>   				    tunnel->parms.iph.protocol,
>>   				    dst, tnl_params->saddr,
>>   				    tunnel->parms.o_key,
>> @@ -888,6 +892,7 @@ int ip_tunnel_newlink(struct net_device *dev, st=
ruct nlattr *tb[],
>>   	if (ip_tunnel_find(itn, p, dev->type))
>>   		return -EEXIST;
>>
>> +	nt->net =3D net;
>>   	nt->parms =3D *p;
>>   	err =3D register_netdevice(dev);
>>   	if (err)
>> diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
>> index f639866..4e03904 100644
>> --- a/net/ipv6/sit.c
>> +++ b/net/ipv6/sit.c
>> @@ -466,14 +466,14 @@ isatap_chksrc(struct sk_buff *skb, const struc=
t iphdr *iph, struct ip_tunnel *t)
>>
>>   static void ipip6_tunnel_uninit(struct net_device *dev)
>>   {
>> -	struct net *net =3D dev_net(dev);
>> -	struct sit_net *sitn =3D net_generic(net, sit_net_id);
>> +	struct ip_tunnel *tunnel =3D netdev_priv(dev);
>> +	struct sit_net *sitn =3D net_generic(tunnel->net, sit_net_id);
>>
>>   	if (dev =3D=3D sitn->fb_tunnel_dev) {
>>   		RCU_INIT_POINTER(sitn->tunnels_wc[0], NULL);
>>   	} else {
>> -		ipip6_tunnel_unlink(sitn, netdev_priv(dev));
>> -		ipip6_tunnel_del_prl(netdev_priv(dev), NULL);
>> +		ipip6_tunnel_unlink(sitn, tunnel);
>> +		ipip6_tunnel_del_prl(tunnel, NULL);
>>   	}
>>   	dev_put(dev);
>>   }
>> @@ -621,6 +621,8 @@ static int ipip6_rcv(struct sk_buff *skb)
>>   		tstats->rx_packets++;
>>   		tstats->rx_bytes +=3D skb->len;
>>
>> +		if (tunnel->net !=3D dev_net(tunnel->dev))
>> +			dev_cleanup_skb(skb);
>>   		netif_rx(skb);
>>
>>   		return 0;
>> @@ -803,7 +805,7 @@ static netdev_tx_t ipip6_tunnel_xmit(struct sk_b=
uff *skb,
>>   			goto tx_error;
>>   	}
>>
>> -	rt =3D ip_route_output_ports(dev_net(dev), &fl4, NULL,
>> +	rt =3D ip_route_output_ports(tunnel->net, &fl4, NULL,
>>   				   dst, tiph->saddr,
>>   				   0, 0,
>>   				   IPPROTO_IPV6, RT_TOS(tos),
>> @@ -858,6 +860,9 @@ static netdev_tx_t ipip6_tunnel_xmit(struct sk_b=
uff *skb,
>>   			tunnel->err_count =3D 0;
>>   	}
>>
>> +	if (tunnel->net !=3D dev_net(dev))
>> +		dev_cleanup_skb(skb);
>> +
>>   	/*
>>   	 * Okay, now see if we can stuff it in the buffer as-is.
>>   	 */
>> @@ -944,7 +949,8 @@ static void ipip6_tunnel_bind_dev(struct net_dev=
ice *dev)
>>   	iph =3D &tunnel->parms.iph;
>>
>>   	if (iph->daddr) {
>> -		struct rtable *rt =3D ip_route_output_ports(dev_net(dev), &fl4, N=
ULL,
>> +		struct rtable *rt =3D ip_route_output_ports(tunnel->net, &fl4,
>> +							  NULL,
>>   							  iph->daddr, iph->saddr,
>>   							  0, 0,
>>   							  IPPROTO_IPV6,
>> @@ -959,7 +965,7 @@ static void ipip6_tunnel_bind_dev(struct net_dev=
ice *dev)
>>   	}
>>
>>   	if (!tdev && tunnel->parms.link)
>> -		tdev =3D __dev_get_by_index(dev_net(dev), tunnel->parms.link);
>> +		tdev =3D __dev_get_by_index(tunnel->net, tunnel->parms.link);
>>
>>   	if (tdev) {
>>   		dev->hard_header_len =3D tdev->hard_header_len + sizeof(struct i=
phdr);
>> @@ -972,7 +978,7 @@ static void ipip6_tunnel_bind_dev(struct net_dev=
ice *dev)
>>
>>   static void ipip6_tunnel_update(struct ip_tunnel *t, struct ip_tun=
nel_parm *p)
>>   {
>> -	struct net *net =3D dev_net(t->dev);
>> +	struct net *net =3D t->net;
>>   	struct sit_net *sitn =3D net_generic(net, sit_net_id);
>>
>>   	ipip6_tunnel_unlink(sitn, t);
>> @@ -1248,7 +1254,6 @@ static void ipip6_tunnel_setup(struct net_devi=
ce *dev)
>>   	dev->priv_flags	       &=3D ~IFF_XMIT_DST_RELEASE;
>>   	dev->iflink		=3D 0;
>>   	dev->addr_len		=3D 4;
>> -	dev->features		|=3D NETIF_F_NETNS_LOCAL;
>>   	dev->features		|=3D NETIF_F_LLTX;
>>   }
>>
>> @@ -1257,6 +1262,7 @@ static int ipip6_tunnel_init(struct net_device=
 *dev)
>>   	struct ip_tunnel *tunnel =3D netdev_priv(dev);
>>
>>   	tunnel->dev =3D dev;
>> +	tunnel->net =3D dev_net(dev);
>>
>>   	memcpy(dev->dev_addr, &tunnel->parms.iph.saddr, 4);
>>   	memcpy(dev->broadcast, &tunnel->parms.iph.daddr, 4);
>> @@ -1277,6 +1283,7 @@ static int __net_init ipip6_fb_tunnel_init(str=
uct net_device *dev)
>>   	struct sit_net *sitn =3D net_generic(net, sit_net_id);
>>
>>   	tunnel->dev =3D dev;
>> +	tunnel->net =3D dev_net(dev);
>>   	strcpy(tunnel->parms.name, dev->name);
>>
>>   	iph->version		=3D 4;
>> @@ -1562,22 +1569,15 @@ static struct xfrm_tunnel ipip_handler __rea=
d_mostly =3D {
>>   	.priority	=3D	2,
>>   };
>>
>> -static void __net_exit sit_destroy_tunnels(struct sit_net *sitn, st=
ruct list_head *head)
>> +static void __net_exit sit_destroy_tunnels(struct net *net,
>> +					   struct list_head *head)
>>   {
>> -	int prio;
>> +	struct net_device *dev, *aux;
>>
>> -	for (prio =3D 1; prio < 4; prio++) {
>> -		int h;
>> -		for (h =3D 0; h < HASH_SIZE; h++) {
>> -			struct ip_tunnel *t;
>> -
>> -			t =3D rtnl_dereference(sitn->tunnels[prio][h]);
>> -			while (t !=3D NULL) {
>> -				unregister_netdevice_queue(t->dev, head);
>> -				t =3D rtnl_dereference(t->next);
>> -			}
>> -		}
>> -	}
>> +	for_each_netdev_safe(net, dev, aux)
>> +		if (dev->rtnl_link_ops &&
>> +		    !strcmp(dev->rtnl_link_ops->kind, "sit"))
>> +			unregister_netdevice_queue(dev, head);
>
> This entire idiom change is a bit ugly, and it is wrong.
>
> You need to look for two classes of tunnels to take down.  Tunnels th=
at
> originate in net and tunnels whose netdevice is in net.
>
> For tunnles that reside in net you should be able to just compare the
> rtnl_link_ops pointer, rather than an ascii name.
>
> Tunnels that originate in this network namespace most definitely need=
 to
> be taken down as among other things you wisely do not keep a referenc=
e
> count on the originating network namespace.
Yes sure. My beta version was doing the right things, but I change this=
 code=20
before sending the patch :/
