From: John Eaglesham <johneagl@yahoo-inc.com>
Subject: Re: [PATCH] bonding: L2L3 xmit doesn't support IPv6
Date: Wed, 12 Oct 2011 14:15:18 -0700
Message-ID: <4E960366.4060302@yahoo-inc.com>
References: <1318052205-21991-1-git-send-email-Yinglin.Sun@emc.com>	 <20111011143348.GA20605@gospo.rdu.redhat.com> <23119.1318348739@death>	 <20111012025137.GB20605@gospo.rdu.redhat.com>	 <CAN17JHVsgRqkOgeJ0+vvQe3kN1W0ue0vKHa3uebFHa9oH2ngXA@mail.gmail.com> <1318392395.3686.12.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Yinglin Sun <yinglin.s@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Jay Vosburgh <fubar@us.ibm.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>, linux@8192.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mrout1-b.corp.bf1.yahoo.com ([98.139.253.104]:32895 "EHLO
	mrout1-b.corp.bf1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750903Ab1JLV2B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Oct 2011 17:28:01 -0400
In-Reply-To: <1318392395.3686.12.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> Le mardi 11 octobre 2011 =C3=A0 20:39 -0700, Yinglin Sun a =C3=A9crit=
 :
>> On Tue, Oct 11, 2011 at 7:51 PM, Andy Gospodarek <andy@greyhouse.net=
> wrote:
>>>        if (skb->protocol =3D=3D htons(ETH_P_IP)) {
>>> +               struct iphdr *iph =3D ip_hdr(skb);
>>> +               __be16 *layer4hdr =3D (__be16 *)((u32 *)iph + iph->=
ihl);
>>>                if (!ip_is_fragment(iph) &&
>>>                    (iph->protocol =3D=3D IPPROTO_TCP ||
>>>                     iph->protocol =3D=3D IPPROTO_UDP)) {
>>> @@ -3398,7 +3407,18 @@ static int bond_xmit_hash_policy_l34(struct =
sk_buff *skb, int count)
>>>                }
>>>                return (layer4_xor ^
>>>                        ((ntohl(iph->saddr ^ iph->daddr)) & 0xffff))=
 % count;
>>> -
>>> +       } else if (skb->protocol =3D=3D htons(ETH_P_IPV6)) {
>>> +               struct ipv6hdr *ipv6h =3D ipv6_hdr(skb);
>>> +               __be16 *layer4hdrv6 =3D (__be16 *)((u8 *)ipv6h + si=
zeof(*ipv6h));
>>> +               if (ipv6h->nexthdr =3D=3D IPPROTO_TCP || ipv6h->nex=
thdr =3D=3D IPPROTO_UDP) {
>> Does this work if this is a fragmentation packet? and if
>> ipv6h->nexthdr is not IPPROTO_TCP/IPPROTO_UDP, it doesn't mean this =
is
>> not TCP/UDP packet. We need to go through the extension header chain
>> and look at the last one. It's likely there are some other extension
>> headers before L4 header.
>>
>=20
> Its a best effort.
>=20
> If first header is not IPPROTO_TCP/UDP, I am not sure its wise to spe=
nd
> time in hope to find layer4 info (missing anyway in fragments)
>=20
> By the way I see no bound checking on SKB head : malicious packet cou=
ld
> make bond_xmit_hash_policy_l34() access unitialized memory.
>=20
> We have same 'fastpath' in __skb_get_rxhash()
>=20
>=20

Thanks for keeping me in the loop on this.

I caught the bounds checking bug and added checks to code I haven't=20
submitted in yet (I still need to test that it works before I submit a=20
patch).

I don't like the idea of sticking a loop in this part of the code,=20
especially one traversing a list of length controlled by outside users=20
with no guarantee it is properly formed. I ran some tests gathering=20
traffic and I never saw any packets with headers between the IPv6 and=20
TCP or UDP, so at least in the real world right now this code should=20
behave as expected for the vast majority of traffic. Things might chang=
e=20
in the future, but if this code is clear/clean/simple and solves the=20
problem today, I'd be happier with that than trying to parse a full IPv=
6=20
header.

I'll test and post my revised patch (including bounds checking and=20
documentation updates) in a day or so.

John
