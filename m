From: Pierre Pfister <pierre@darou.fr>
Subject: Re: ipv6 mld: packets are not looped back to/from kernel/querier
Date: Wed, 29 Oct 2014 09:49:57 +0100
Message-ID: <D79FE41E-A856-487C-9E00-35E3A973205D@darou.fr>
References: <CFCF0BD4-80F5-48B1-AA03-D0066DEC6B11@darou.fr> <544FDDA7.8020007@redhat.com> <4F039FC5-0FE5-4944-8371-75F927B185C6@darou.fr>
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Daniel Borkmann <dborkman@redhat.com>, netdev@vger.kernel.org,
	liuhangbin@gmail.com
To: Pierre Pfister <pierre@darou.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.polytechnique.org ([129.104.30.34]:42239 "EHLO
	mx1.polytechnique.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753699AbaJ2It7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2014 04:49:59 -0400
In-Reply-To: <4F039FC5-0FE5-4944-8371-75F927B185C6@darou.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It doesn=92t work with 3.16 neither.

Cheers,

- Pierre

Le 29 oct. 2014 =E0 09:14, Pierre Pfister <pierre@darou.fr> a =E9crit :

> Thanks for the quick answer,
>=20
> See inline,
>=20
> Le 28 oct. 2014 =E0 19:17, Daniel Borkmann <dborkman@redhat.com> a =E9=
crit :
>=20
>> On 10/28/2014 05:32 PM, Pierre Pfister wrote:
>>> Hello,
>>>=20
>>> I=92m implementing a dual-stack multicast querier (IGMPv3 and MLDv2=
) along with the PIM protocol.
>>> So I=92ve got two multicast sockets, one for each protocol.
>>>=20
>>> I open the two sockets like this:
>>>=20
>>> =97=97=97=97=97=97=97=97=97=97=97=97=97=97=97=97=97=97
>>> fd =3D socket(AF_INET, SOCK_RAW, IPPROTO_IGMP);
>>> val =3D 1;
>>> setsockopt(fd, IPPROTO_IP, MRT_INIT, &val, sizeof(val));
>>> setsockopt(fd, IPPROTO_IP, IP_PKTINFO, &val, sizeof(val));
>>> setsockopt(fd, IPPROTO_IP, IP_MULTICAST_TTL, &val, sizeof(val));
>>> val =3D 0xc0;
>>> setsockopt(fd, IPPROTO_IP, IP_TOS, &val, sizeof(val));
>>> setsockopt(fd, IPPROTO_IP, IP_OPTIONS, &ipv4_rtr_alert, sizeof(ipv4=
_rtr_alert))
>>>=20
>>> fd =3D socket(AF_INET6, SOCK_RAW, IPPROTO_ICMPV6);
>>> val =3D 1;
>>> setsockopt(fd, IPPROTO_IPV6, MRT6_INIT, &val, sizeof(val));
>>> setsockopt(fd, IPPROTO_IPV6, IPV6_RECVHOPOPTS, &val, sizeof(val));
>>> setsockopt(fd, IPPROTO_IPV6, IPV6_RECVHOPLIMIT, &val, sizeof(val));
>>> setsockopt(fd, IPPROTO_IPV6, IPV6_MULTICAST_HOPS, &val, sizeof(val)=
);
>>> val =3D 2;
>>> setsockopt(fd, IPPROTO_RAW, IPV6_CHECKSUM, &val, sizeof(val));
>>> setsockopt(fd, IPPROTO_IPV6, IPV6_HOPOPTS, &ipv6_rtr_alert, sizeof(=
ipv6_rtr_alert));
>>=20
>> What kernel are you using? How do you setup ipv6_rtr_alert here?
>>=20
>> For inbound queries in IPv6, the kernel might be more picky after
>> [correct] commit e940f5d6ba6a ("ipv6: Fix MLD Query message check"),
>> so you need to make sure you have hop limit of 1 and a proper set
>> up RA option =85
>=20
> I can reproduce the problem with both 3.10.28 and 3.14-0. I will try =
to try a later version.
> I don=92t think the packet itself can be a problem as other routers c=
orrectly receive it.
> The problem comes with loopbacking to kernel and userspace (Depending=
 whether the kernel or querier sent it).
>=20
> Here is the router alert struct.
> static struct {
> 	struct ip6_hbh hdr;
> 	struct ip6_opt_router rt;
> 	uint8_t pad[2];
> } ipv6_rtr_alert =3D {
> 	.hdr =3D {0, 0},
> 	.rt =3D {IP6OPT_ROUTER_ALERT, 2, {0, IP6_ALERT_MLD}},
> 	.pad =3D {0, 0}
> }
>=20
> I also checked what that commit checks (wiresharked), and everything =
seems correct.
>=20
> Thanks,
>=20
> - Pierre
>=20
>=20
>=20
>>=20
>>> struct icmp6_filter flt;
>>> ICMP6_FILTER_SETBLOCKALL(&flt);
>>> ICMP6_FILTER_SETPASS(ICMPV6_MGM_QUERY, &flt);
>>> ICMP6_FILTER_SETPASS(ICMPV6_MGM_REPORT, &flt);
>>> ICMP6_FILTER_SETPASS(ICMPV6_MGM_REDUCTION, &flt);
>>> ICMP6_FILTER_SETPASS(ICMPV6_MLD2_REPORT, &flt);
>>> setsockopt(fd, IPPROTO_ICMPV6, ICMP6_FILTER, &flt, sizeof(flt));
>>> =97=97=97=97=97=97=97=97=97=97=97=97=97=97=97=97=97=97=97=97=97=97
>>>=20
>>> I=92ve got two issues with the IPv6 socket.
>>> When I send an MLD query, it is sent on the wire, but the kernel do=
esn=92t interpret it (It doesn=92t send MLD Reports as reply).
>>> Similarly, when the kernel sends a Report, my MLD Querier socket do=
esn=92t receive the message.
>>>=20
>>> The resulting problem is that everything works fine as long as the =
router doesn=92t want to join a group. When it does, my Querier can=92t=
 know it, and the kernel doesn=92t reply to Querier=92s requests.
>>>=20
>>> It works well in IPv4.
>>>=20
>>> I tried removing the ICMPV6 filter as well as using IPV6_MULTICAST_=
LOOP.
>>>=20
>>> Am I doing something wrong or is it an actual bug ?
>>> If you need more information, please ask.
>>>=20
>>> Thanks,
>>>=20
>>>=20
>>> Pierre
>>>=20
>>>=20
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe netdev" i=
n
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>=20
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
