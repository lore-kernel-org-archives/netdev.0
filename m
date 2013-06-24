From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC PATCH net-next 2/2] sit: add support of x-netns
Date: Mon, 24 Jun 2013 15:42:15 -0700
Message-ID: <874ncni114.fsf@xmission.com>
References: <87y5ijd98e.fsf@xmission.com>
	<1372083239-9451-1-git-send-email-nicolas.dichtel@6wind.com>
	<1372083239-9451-3-git-send-email-nicolas.dichtel@6wind.com>
	<878v1zjokr.fsf@xmission.com> <51C8B5F6.7020603@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net, bcrl@kvack.org,
	ravi.mlists@gmail.com
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:51736 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750858Ab3FXWmu convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jun 2013 18:42:50 -0400
In-Reply-To: <51C8B5F6.7020603@6wind.com> (Nicolas Dichtel's message of "Mon,
	24 Jun 2013 23:11:18 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nicolas Dichtel <nicolas.dichtel@6wind.com> writes:

> Le 24/06/2013 21:28, Eric W. Biederman a =C3=A9crit :
>> Nicolas Dichtel <nicolas.dichtel@6wind.com> writes:
>>
>>> This patch allows to switch the netns when packet is encapsulated o=
r
>>> decapsulated. In other word, the encapsulated packet is received in=
 a netns,
>>> where the lookup is done to find the tunnel. Once the tunnel is fou=
nd, the
>>> packet is decapsulated and injecting into the corresponding interfa=
ce which
>>> stands to another netns.
>>>
>>> When one of the two netns is removed, the tunnel is destroyed.
>>
>> I don't see any fundamental problems with this code.  There are bugs
>> with the cleanup noted below.
>>
>> The primary sit interface is marked as NETNS_LOCAL which is good.  A
>> comment might be nice explaining the reasonsing but for code
>> archeologists.
> Ok.
>
>>
>> Conditionally calling dev_cleanup_skb bugs me.  The extra conditiona=
l
>> looks like a maintenance hazard.   Unless I have missed some subtle
>> detail either we don't need the cleanup at all or actually it is a b=
ug
>> that we aren't scrubbing our packets as they progress through tunnel=
s
>> even in the same network namespace.
>>
>> Can we just make that function the skb scrubbing needed for packets =
to
>> traverse a tunnel?
>>
>> My concern going into this was that we would get code that would bre=
ak
>> because it would not be tested enough.  If we can remove the conditi=
onal
>> from dev_cleanup_skb we won't have any code that is conditionally ru=
n
>> and the logic looks simple enough not to bitrot in routine maintenan=
ce.
> My idea was to have the same level of cleanup/scrubbing that when a p=
acket is
> sent from a netns to another netns through a veth. I cannot use
> dev_forward_skb() because this function expects to have an ethernet h=
eader, it's
> why I split it in the patch #1.
>
> If we leave all information attached to the skb, we may have, for exa=
mple, an
> skb with a conntrack from netns1 and a netdevice from netns2. It seem=
s not safe,
> but maybe I'm wrong. And in fact, the conntrack will not be created i=
n the
> second netns (nf_conntrack_in() =3D> skb->nfct is not null and not a =
template =3D>
> stats ignore++).
> Another example is a socket from a netns and the netdevice or conntra=
ck from
> another netns.

All of that I agree with.

I just don't see any need to make that scrubbing/cleaning of the packet
conditional.

Semantically going through a tunnel is the same as crossing between
network namespaces.  So you can change

>>> +	if (tunnel->net !=3D dev_net(tunnel->dev))
>>> +		dev_cleanup_skb(skb);

to just:

	dev_cleanup_skb(skb);

> I was thinking that when a packet enter a namespace, it must not be a=
ssociated
> to any object from the previous namespace, it should be like if we ju=
st receive
> it on the host.

Overall agree.  Tunnels have the same properties.

Which leads me to conclude either we are missing something or the
current tunnel code is mildly buggy because it does not do this level o=
f
scrubbing.

Eric

>>> -static void __net_exit sit_destroy_tunnels(struct sit_net *sitn, s=
truct list_head *head)
>>> +static void __net_exit sit_destroy_tunnels(struct net *net,
>>> +					   struct list_head *head)
>>>   {
>>> -	int prio;
>>> +	struct net_device *dev, *aux;
>>>
>>> -	for (prio =3D 1; prio < 4; prio++) {
>>> -		int h;
>>> -		for (h =3D 0; h < HASH_SIZE; h++) {
>>> -			struct ip_tunnel *t;
>>> -
>>> -			t =3D rtnl_dereference(sitn->tunnels[prio][h]);
>>> -			while (t !=3D NULL) {
>>> -				unregister_netdevice_queue(t->dev, head);
>>> -				t =3D rtnl_dereference(t->next);
>>> -			}
>>> -		}
>>> -	}
>>> +	for_each_netdev_safe(net, dev, aux)
>>> +		if (dev->rtnl_link_ops &&
>>> +		    !strcmp(dev->rtnl_link_ops->kind, "sit"))
>>> +			unregister_netdevice_queue(dev, head);
>>
>> This entire idiom change is a bit ugly, and it is wrong.
>>
>> You need to look for two classes of tunnels to take down.  Tunnels t=
hat
>> originate in net and tunnels whose netdevice is in net.
>>
>> For tunnles that reside in net you should be able to just compare th=
e
>> rtnl_link_ops pointer, rather than an ascii name.
>>
>> Tunnels that originate in this network namespace most definitely nee=
d to
>> be taken down as among other things you wisely do not keep a referen=
ce
>> count on the originating network namespace.
> Yes sure. My beta version was doing the right things, but I change th=
is code
> before sending the patch :/

Bahahaha!  The dangers of the last minute cleanup.

Eric
