From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [BUG]  behaviour mismatch between ipv4 and ipv6 in UDP rx path
Date: Wed, 16 Feb 2011 21:59:02 +0100
Message-ID: <1297889942.2645.22.camel@edumazet-laptop>
References: <4D5C3128.4080101@genband.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Herbert Xu <herbert@gondor.apana.org.au>
To: Chris Friesen <chris.friesen@genband.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:56267 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751005Ab1BPU7I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Feb 2011 15:59:08 -0500
Received: by bwz15 with SMTP id 15so1039408bwz.19
        for <netdev@vger.kernel.org>; Wed, 16 Feb 2011 12:59:07 -0800 (PST)
In-Reply-To: <4D5C3128.4080101@genband.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 16 f=C3=A9vrier 2011 =C3=A0 14:18 -0600, Chris Friesen a =C3=
=A9crit :
> Hi,
>=20
> I sent this out a week ago but didn't see a reply, so I'm sending it =
out
> again.
>=20
> One of our guys is seeing occasional dropped ipv4 packets coming in o=
n
> an ipv6 udp socket obtained via socket(AF_INET6,  SOCK_DGRAM, IPPROTO=
_UDP).
>=20
> Here's what he says:
>=20
>=20
> "The problem happens when release_sock() goes down an interesting cod=
e
> path.  If (sk->sk_backlog.tail) is non-NULL then release_sock() invok=
es
> __release_sock() which loops over all queue packets and invokes the
> socket's backlog receive function for each previously queued packet.
>=20
> Now for the interesting part.  The UDPv6 backlog receive function (in
> net/ipv6/udp.c, udpv6_queue_rcv_skb()) invokes xfrm6_policy_check() t=
o
> confirm that the packet is allowed, but the problem is that it calls
> this function regardless of whether the packet is IPv4 or IPv6.  The
> xfrm6_policy_check() function then assumes that it is an IPv6 packet =
and
> tries to match a policy based on its packet header... but that clearl=
y
> won't work because the addresses that it finds when it decodes the sk=
b
> are completely bogus."
>=20
>=20
> Looking at the ipv4 code, git commit 9382177 split __udp_queue_rcv_sk=
b()
> out of udp_queue_rcv_skb().  It was done for locking purposes, but it
> also means that backlog_rcv is bound to __udp_queue_rcv_skb(), which
> doesn't call xfrm4_policy_check().
>=20
>=20
> Should a new function __udpv6_queue_rcv_skb() be split out from
> udpv6_queue_rcv_skb() and bound to backlog_rcv to resolve the xfrm
> issue?  What about the locking that was the reason for the split in t=
he
> ipv4 case--is there a similar problem with ipv6?
>=20


Yes, please submit a patch ?

Ideally, __udp_queue_rcv_skb() should be the common .backlog

In practice, because of sock_rps_save_rxhash() and MIB counters, I
suspect a __udp6_queue_rcv_skb() is OK.



