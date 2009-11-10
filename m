From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ifb: add multi-queue support
Date: Tue, 10 Nov 2009 14:34:41 +0100
Message-ID: <4AF96BF1.5070902@gmail.com>
References: <4AF924A5.1050303@gmail.com> <4AF92D6D.8060300@gmail.com>	 <412e6f7f0911100143k68284faes92e39d8ca94aa9d4@mail.gmail.com>	 <4AF9471C.5080606@gmail.com>	 <412e6f7f0911100314i33d6a49dl5163b5e8472babcf@mail.gmail.com>	 <4AF95174.3060104@trash.net>	 <412e6f7f0911100414w7b6f45aap39f6568b7af2c1a7@mail.gmail.com>	 <4AF95A3D.5060602@trash.net>	 <412e6f7f0911100437g2759eb6dg509af4edb8848291@mail.gmail.com>	 <4AF96055.90509@trash.net> <412e6f7f0911100506r6a922b8aoabd359e7e4290ebe@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Tom Herbert <therbert@google.com>
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:35403 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752891AbZKJNeo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Nov 2009 08:34:44 -0500
In-Reply-To: <412e6f7f0911100506r6a922b8aoabd359e7e4290ebe@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changli Gao a =C3=A9crit :
> On Tue, Nov 10, 2009 at 8:45 PM, Patrick McHardy <kaber@trash.net> wr=
ote:
>> Its a trivial change, you can put them in the same patch:
>>
>> static int ifb_get_tx_queues(struct net *net, struct nlattr *tb[],
>>                             unsigned int *num_tx_queues,
>>                             unsigned int *real_num_tx_queues)
>> {
>>    unsigned int n =3D 1;
>>
>>    if (tb[IFLA_NTXQ])
>>       n =3D nla_get_u32(tb[IFLA_NTXQ]);
>>
>>    *num_tx_queues =3D n;
>>    *real_num_tx_queues =3D n;
>>    return 0;
>> }
>>
>=20
> Is IFLA_NTXQ added? I didn't find it in any branch. And I think both
> num_tx_queueus and real_num_tx_queues are needed.
>=20

I believe Patrick was referring to vlan get_tx_queues() implementation,
but it actually gets values from real device (tb[IFLA_LINK])

In your case you'll need to add a new IFLA_NTXQ attribute, and
change iproute2 to pass this new attribute at link creation.
(check include/linux/if_link.h)

ip link add link .....  ntxq 2

static int vlan_get_tx_queues(struct net *net,
                              struct nlattr *tb[],
                              unsigned int *num_tx_queues,
                              unsigned int *real_num_tx_queues)
{
        struct net_device *real_dev;

        if (!tb[IFLA_LINK])
                return -EINVAL;

        real_dev =3D __dev_get_by_index(net, nla_get_u32(tb[IFLA_LINK])=
);
        if (!real_dev)
                return -ENODEV;

        *num_tx_queues      =3D real_dev->num_tx_queues;
        *real_num_tx_queues =3D real_dev->real_num_tx_queues;
        return 0;
}


