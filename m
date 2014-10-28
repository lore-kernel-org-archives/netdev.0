From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: ipv6 mld: packets are not looped back to/from kernel/querier
Date: Tue, 28 Oct 2014 19:17:11 +0100
Message-ID: <544FDDA7.8020007@redhat.com>
References: <CFCF0BD4-80F5-48B1-AA03-D0066DEC6B11@darou.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, liuhangbin@gmail.com
To: Pierre Pfister <pierre@darou.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54314 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750898AbaJ1SRT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Oct 2014 14:17:19 -0400
In-Reply-To: <CFCF0BD4-80F5-48B1-AA03-D0066DEC6B11@darou.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/28/2014 05:32 PM, Pierre Pfister wrote:
> Hello,
>
> I=92m implementing a dual-stack multicast querier (IGMPv3 and MLDv2) =
along with the PIM protocol.
> So I=92ve got two multicast sockets, one for each protocol.
>
> I open the two sockets like this:
>
> =97=97=97=97=97=97=97=97=97=97=97=97=97=97=97=97=97=97
> fd =3D socket(AF_INET, SOCK_RAW, IPPROTO_IGMP);
> val =3D 1;
> setsockopt(fd, IPPROTO_IP, MRT_INIT, &val, sizeof(val));
> setsockopt(fd, IPPROTO_IP, IP_PKTINFO, &val, sizeof(val));
> setsockopt(fd, IPPROTO_IP, IP_MULTICAST_TTL, &val, sizeof(val));
> val =3D 0xc0;
> setsockopt(fd, IPPROTO_IP, IP_TOS, &val, sizeof(val));
> setsockopt(fd, IPPROTO_IP, IP_OPTIONS, &ipv4_rtr_alert, sizeof(ipv4_r=
tr_alert))
>
> fd =3D socket(AF_INET6, SOCK_RAW, IPPROTO_ICMPV6);
> val =3D 1;
> setsockopt(fd, IPPROTO_IPV6, MRT6_INIT, &val, sizeof(val));
> setsockopt(fd, IPPROTO_IPV6, IPV6_RECVHOPOPTS, &val, sizeof(val));
> setsockopt(fd, IPPROTO_IPV6, IPV6_RECVHOPLIMIT, &val, sizeof(val));
> setsockopt(fd, IPPROTO_IPV6, IPV6_MULTICAST_HOPS, &val, sizeof(val));
> val =3D 2;
> setsockopt(fd, IPPROTO_RAW, IPV6_CHECKSUM, &val, sizeof(val));
> setsockopt(fd, IPPROTO_IPV6, IPV6_HOPOPTS, &ipv6_rtr_alert, sizeof(ip=
v6_rtr_alert));

What kernel are you using? How do you setup ipv6_rtr_alert here?

=46or inbound queries in IPv6, the kernel might be more picky after
[correct] commit e940f5d6ba6a ("ipv6: Fix MLD Query message check"),
so you need to make sure you have hop limit of 1 and a proper set
up RA option ...

> struct icmp6_filter flt;
> ICMP6_FILTER_SETBLOCKALL(&flt);
> ICMP6_FILTER_SETPASS(ICMPV6_MGM_QUERY, &flt);
> ICMP6_FILTER_SETPASS(ICMPV6_MGM_REPORT, &flt);
> ICMP6_FILTER_SETPASS(ICMPV6_MGM_REDUCTION, &flt);
> ICMP6_FILTER_SETPASS(ICMPV6_MLD2_REPORT, &flt);
> setsockopt(fd, IPPROTO_ICMPV6, ICMP6_FILTER, &flt, sizeof(flt));
> =97=97=97=97=97=97=97=97=97=97=97=97=97=97=97=97=97=97=97=97=97=97
>
> I=92ve got two issues with the IPv6 socket.
> When I send an MLD query, it is sent on the wire, but the kernel does=
n=92t interpret it (It doesn=92t send MLD Reports as reply).
> Similarly, when the kernel sends a Report, my MLD Querier socket does=
n=92t receive the message.
>
> The resulting problem is that everything works fine as long as the ro=
uter doesn=92t want to join a group. When it does, my Querier can=92t k=
now it, and the kernel doesn=92t reply to Querier=92s requests.
>
> It works well in IPv4.
>
> I tried removing the ICMPV6 filter as well as using IPV6_MULTICAST_LO=
OP.
>
> Am I doing something wrong or is it an actual bug ?
> If you need more information, please ask.
>
> Thanks,
>
>
> Pierre
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
