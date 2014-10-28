From: Pierre Pfister <pierre@darou.fr>
Subject: ipv6 mld: packets are not looped back to/from kernel/querier
Date: Tue, 28 Oct 2014 17:32:28 +0100
Message-ID: <CFCF0BD4-80F5-48B1-AA03-D0066DEC6B11@darou.fr>
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.polytechnique.org ([129.104.30.34]:60506 "EHLO
	mx1.polytechnique.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752235AbaJ1Qhi convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Oct 2014 12:37:38 -0400
Received: from [10.61.172.113] (173-38-208-169.cisco.com [173.38.208.169])
	(using TLSv1 with cipher ECDHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by ssl.polytechnique.org (Postfix) with ESMTPSA id 47E61140912E2
	for <netdev@vger.kernel.org>; Tue, 28 Oct 2014 17:32:29 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I=92m implementing a dual-stack multicast querier (IGMPv3 and MLDv2) al=
ong with the PIM protocol.
So I=92ve got two multicast sockets, one for each protocol.

I open the two sockets like this:

=97=97=97=97=97=97=97=97=97=97=97=97=97=97=97=97=97=97=20
fd =3D socket(AF_INET, SOCK_RAW, IPPROTO_IGMP);
val =3D 1;
setsockopt(fd, IPPROTO_IP, MRT_INIT, &val, sizeof(val));
setsockopt(fd, IPPROTO_IP, IP_PKTINFO, &val, sizeof(val));
setsockopt(fd, IPPROTO_IP, IP_MULTICAST_TTL, &val, sizeof(val));
val =3D 0xc0;
setsockopt(fd, IPPROTO_IP, IP_TOS, &val, sizeof(val));
setsockopt(fd, IPPROTO_IP, IP_OPTIONS, &ipv4_rtr_alert, sizeof(ipv4_rtr=
_alert))

fd =3D socket(AF_INET6, SOCK_RAW, IPPROTO_ICMPV6);
val =3D 1;
setsockopt(fd, IPPROTO_IPV6, MRT6_INIT, &val, sizeof(val));
setsockopt(fd, IPPROTO_IPV6, IPV6_RECVHOPOPTS, &val, sizeof(val));
setsockopt(fd, IPPROTO_IPV6, IPV6_RECVHOPLIMIT, &val, sizeof(val));
setsockopt(fd, IPPROTO_IPV6, IPV6_MULTICAST_HOPS, &val, sizeof(val));
val =3D 2;
setsockopt(fd, IPPROTO_RAW, IPV6_CHECKSUM, &val, sizeof(val));
setsockopt(fd, IPPROTO_IPV6, IPV6_HOPOPTS, &ipv6_rtr_alert, sizeof(ipv6=
_rtr_alert));
struct icmp6_filter flt;
ICMP6_FILTER_SETBLOCKALL(&flt);
ICMP6_FILTER_SETPASS(ICMPV6_MGM_QUERY, &flt);
ICMP6_FILTER_SETPASS(ICMPV6_MGM_REPORT, &flt);
ICMP6_FILTER_SETPASS(ICMPV6_MGM_REDUCTION, &flt);
ICMP6_FILTER_SETPASS(ICMPV6_MLD2_REPORT, &flt);
setsockopt(fd, IPPROTO_ICMPV6, ICMP6_FILTER, &flt, sizeof(flt));
=97=97=97=97=97=97=97=97=97=97=97=97=97=97=97=97=97=97=97=97=97=97=20

I=92ve got two issues with the IPv6 socket.
When I send an MLD query, it is sent on the wire, but the kernel doesn=92=
t interpret it (It doesn=92t send MLD Reports as reply).
Similarly, when the kernel sends a Report, my MLD Querier socket doesn=92=
t receive the message.

The resulting problem is that everything works fine as long as the rout=
er doesn=92t want to join a group. When it does, my Querier can=92t kno=
w it, and the kernel doesn=92t reply to Querier=92s requests.

It works well in IPv4.

I tried removing the ICMPV6 filter as well as using IPV6_MULTICAST_LOOP=
=2E

Am I doing something wrong or is it an actual bug ?
If you need more information, please ask.

Thanks,=20


Pierre
