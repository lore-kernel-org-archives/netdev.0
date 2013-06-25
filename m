From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [RFC PATCH net-next 2/2] sit: add support of x-netns
Date: Tue, 25 Jun 2013 16:10:43 +0200
Message-ID: <51C9A4E3.2060906@6wind.com>
References: <87y5ijd98e.fsf@xmission.com> <1372083239-9451-1-git-send-email-nicolas.dichtel@6wind.com> <1372083239-9451-3-git-send-email-nicolas.dichtel@6wind.com> <878v1zjokr.fsf@xmission.com> <51C8B5F6.7020603@6wind.com> <874ncni114.fsf@xmission.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net, bcrl@kvack.org,
	ravi.mlists@gmail.com
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:42117 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751102Ab3FYOKr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Jun 2013 10:10:47 -0400
Received: by mail-we0-f174.google.com with SMTP id q58so9257374wes.19
        for <netdev@vger.kernel.org>; Tue, 25 Jun 2013 07:10:46 -0700 (PDT)
In-Reply-To: <874ncni114.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 25/06/2013 00:42, Eric W. Biederman a =C3=A9crit :
> Nicolas Dichtel <nicolas.dichtel@6wind.com> writes:
>
>> Le 24/06/2013 21:28, Eric W. Biederman a =C3=A9crit :
>>> Nicolas Dichtel <nicolas.dichtel@6wind.com> writes:
>>>
>>>> This patch allows to switch the netns when packet is encapsulated =
or
>>>> decapsulated. In other word, the encapsulated packet is received i=
n a netns,
>>>> where the lookup is done to find the tunnel. Once the tunnel is fo=
und, the
>>>> packet is decapsulated and injecting into the corresponding interf=
ace which
>>>> stands to another netns.
>>>>
>>>> When one of the two netns is removed, the tunnel is destroyed.
>>>
>>> I don't see any fundamental problems with this code.  There are bug=
s
>>> with the cleanup noted below.
>>>
>>> The primary sit interface is marked as NETNS_LOCAL which is good.  =
A
>>> comment might be nice explaining the reasonsing but for code
>>> archeologists.
>> Ok.
>>
>>>
>>> Conditionally calling dev_cleanup_skb bugs me.  The extra condition=
al
>>> looks like a maintenance hazard.   Unless I have missed some subtle
>>> detail either we don't need the cleanup at all or actually it is a =
bug
>>> that we aren't scrubbing our packets as they progress through tunne=
ls
>>> even in the same network namespace.
>>>
>>> Can we just make that function the skb scrubbing needed for packets=
 to
>>> traverse a tunnel?
>>>
>>> My concern going into this was that we would get code that would br=
eak
>>> because it would not be tested enough.  If we can remove the condit=
ional
>>> from dev_cleanup_skb we won't have any code that is conditionally r=
un
>>> and the logic looks simple enough not to bitrot in routine maintena=
nce.
>> My idea was to have the same level of cleanup/scrubbing that when a =
packet is
>> sent from a netns to another netns through a veth. I cannot use
>> dev_forward_skb() because this function expects to have an ethernet =
header, it's
>> why I split it in the patch #1.
>>
>> If we leave all information attached to the skb, we may have, for ex=
ample, an
>> skb with a conntrack from netns1 and a netdevice from netns2. It see=
ms not safe,
>> but maybe I'm wrong. And in fact, the conntrack will not be created =
in the
>> second netns (nf_conntrack_in() =3D> skb->nfct is not null and not a=
 template =3D>
>> stats ignore++).
>> Another example is a socket from a netns and the netdevice or conntr=
ack from
>> another netns.
>
> All of that I agree with.
>
> I just don't see any need to make that scrubbing/cleaning of the pack=
et
> conditional.
>
> Semantically going through a tunnel is the same as crossing between
> network namespaces.  So you can change
>
>>>> +	if (tunnel->net !=3D dev_net(tunnel->dev))
>>>> +		dev_cleanup_skb(skb);
>
> to just:
>
> 	dev_cleanup_skb(skb);
>
>> I was thinking that when a packet enter a namespace, it must not be =
associated
>> to any object from the previous namespace, it should be like if we j=
ust receive
>> it on the host.
>
> Overall agree.  Tunnels have the same properties.
>
> Which leads me to conclude either we are missing something or the
> current tunnel code is mildly buggy because it does not do this level=
 of
> scrubbing.
I'm afraid to break an existing scenario, but you're probably right. Le=
t's=20
remove this test.


Nicolas

>
> Eric
>
>>>> -static void __net_exit sit_destroy_tunnels(struct sit_net *sitn, =
struct list_head *head)
>>>> +static void __net_exit sit_destroy_tunnels(struct net *net,
>>>> +					   struct list_head *head)
>>>>    {
>>>> -	int prio;
>>>> +	struct net_device *dev, *aux;
>>>>
>>>> -	for (prio =3D 1; prio < 4; prio++) {
>>>> -		int h;
>>>> -		for (h =3D 0; h < HASH_SIZE; h++) {
>>>> -			struct ip_tunnel *t;
>>>> -
>>>> -			t =3D rtnl_dereference(sitn->tunnels[prio][h]);
>>>> -			while (t !=3D NULL) {
>>>> -				unregister_netdevice_queue(t->dev, head);
>>>> -				t =3D rtnl_dereference(t->next);
>>>> -			}
>>>> -		}
>>>> -	}
>>>> +	for_each_netdev_safe(net, dev, aux)
>>>> +		if (dev->rtnl_link_ops &&
>>>> +		    !strcmp(dev->rtnl_link_ops->kind, "sit"))
>>>> +			unregister_netdevice_queue(dev, head);
>>>
>>> This entire idiom change is a bit ugly, and it is wrong.
>>>
>>> You need to look for two classes of tunnels to take down.  Tunnels =
that
>>> originate in net and tunnels whose netdevice is in net.
>>>
>>> For tunnles that reside in net you should be able to just compare t=
he
>>> rtnl_link_ops pointer, rather than an ascii name.
>>>
>>> Tunnels that originate in this network namespace most definitely ne=
ed to
>>> be taken down as among other things you wisely do not keep a refere=
nce
>>> count on the originating network namespace.
>> Yes sure. My beta version was doing the right things, but I change t=
his code
>> before sending the patch :/
>
> Bahahaha!  The dangers of the last minute cleanup.
>
> Eric
