From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v5] rps: Receive Packet Steering
Date: Fri, 15 Jan 2010 07:19:33 +0100
Message-ID: <4B5008F5.6090007@gmail.com>
References: <alpine.DEB.1.00.1001141353140.19018@pokey.mtv.corp.google.com> <412e6f7f1001141822pffa070ap15c73e2931402294@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Tom Herbert <therbert@google.com>, davem@davemloft.net,
	netdev@vger.kernel.org,
	Netfilter Developer Mailing List
	<netfilter-devel@vger.kernel.org>
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <412e6f7f1001141822pffa070ap15c73e2931402294@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 15/01/2010 03:22, Changli Gao a =C3=A9crit :
> On Fri, Jan 15, 2010 at 5:56 AM, Tom Herbert <therbert@google.com> wr=
ote:
>> +
>> +       if (skb->rxhash)
>> +               goto got_hash; /* Skip hash computation on packet he=
ader */
>> +
>> +       switch (skb->protocol) {
>> +       case __constant_htons(ETH_P_IP):
>> +               if (!pskb_may_pull(skb, sizeof(*ip)))
>> +                       goto done;
>> +
>> +               ip =3D (struct iphdr *) skb->data;
>> +               ip_proto =3D ip->protocol;
>> +               addr1 =3D ip->saddr;
>> +               addr2 =3D ip->daddr;
>> +               ihl =3D ip->ihl;
>> +               break;
>> +       case __constant_htons(ETH_P_IPV6):
>> +               if (!pskb_may_pull(skb, sizeof(*ip6)))
>> +                       goto done;
>> +
>> +               ip6 =3D (struct ipv6hdr *) skb->data;
>> +               ip_proto =3D ip6->nexthdr;
> This code can't work, when there are extra headers. ipv6_skip_exthdr(=
)
> can be used to get the l4 header.

Could you give exact code please ?

>=20
>> +               addr1 =3D ip6->saddr.s6_addr32[3];
>> +               addr2 =3D ip6->daddr.s6_addr32[3];
>> +               ihl =3D (40 >> 2);
>> +               break;
>> +       default:
>> +               goto done;
>> +       }
>> +       ports =3D 0;
>> +       switch (ip_proto) {
>> +       case IPPROTO_TCP:
>> +       case IPPROTO_UDP:
>> +       case IPPROTO_DCCP:
>> +       case IPPROTO_ESP:
>> +       case IPPROTO_AH:
>> +       case IPPROTO_SCTP:
>> +       case IPPROTO_UDPLITE:
>> +               if (pskb_may_pull(skb, (ihl * 4) + 4))
>> +                       ports =3D *((u32 *) (skb->data + (ihl * 4)))=
;
>> +               break;
>> +
>> +       default:
>> +               break;
>> +       }
>> +
>> +       skb->rxhash =3D jhash_3words(addr1, addr2, ports, hashrnd);
> For connection based packet processing, such as netfilter,
> distributing the packets in two directions into one CPU will reduce
> cache miss, when NAT isn't used. I think the code bellow will help:
> if (addr1 > addr2)
>   swap(addr1, addr2);

Yes, I already gave this hint in a previous review, but this adds a tes=
t
and I suspect Google is not using NAT :)

>=20
>> +       if (!skb->rxhash)
>> +               skb->rxhash =3D 1;
>=20
> Why not put the above code into a new function, and add more protocol=
s
> support, such as 802.1Q.  Though rxhash is based on 4-tuple, I think
> netfilter will benefit from it.
>=20

Sure, this can be done in a followup patch.

Thanks
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
