From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH v3] net: #ifdef inet_bind_bucket::ib_net
Date: Fri, 14 Nov 2008 05:54:26 +0100
Message-ID: <491D0482.1030706@cosmosbay.com>
References: <b6fcc0a0811131521h69419b4an102a0cee98841a83@mail.gmail.com>	<491D003F.7060605@cosmosbay.com> <20081113.204025.162228911.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: adobriyan@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:53059 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750957AbYKNEye convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Nov 2008 23:54:34 -0500
In-Reply-To: <20081113.204025.162228911.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller a =E9crit :
> From: Eric Dumazet <dada1@cosmosbay.com>
> Date: Fri, 14 Nov 2008 05:36:15 +0100
>=20
>> This is better because :
>>
>> 1) No #ifdef CONFIG_NET_NS
>>
>> 2) The magic about &init_net is not duplicated in ten different incl=
ude files, but
>>    centralized in the right file : include/net/net_namespace.h
>=20
> I %100 agree.

Speaking of those functions, what do you think of this one ?

static inline
void dev_net_set(struct net_device *dev, struct net *net)
{
#ifdef CONFIG_NET_NS
        release_net(dev->nd_net);
        dev->nd_net =3D hold_net(net);
#endif
}

I believe that its safer to hold a reference on "new" *before*
releasing reference on "old" object.

Also, release_net() and hold_net() can be defined to do
the use_count refcounting regardless of CONFIG_NET_NS
(Its a different NETNS_REFCNT_DEBUG #ifdef)

Yet another example where read_pnet() and write_pnet()
are the right answer : Its cleaner and fixes *bugs*.

static inline
void dev_net_set(struct net_device *dev, struct net *net)
{
	hold_net(net);
	release_net(read_pnet(&dev->nd_net);
        write_pnet(&dev->nd_net, net);
}


