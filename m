From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: net-next: broken IP_PKTINFO
Date: Thu, 18 Dec 2008 06:59:26 +0100
Message-ID: <4949E6BE.9080709@cosmosbay.com>
References: <20081124.210038.90767194.davem@davemloft.net>	<492C919E.3050108@cosmosbay.com>	<1229513101.3685.57.camel@localhost.localdomain> <20081217.193406.102253657.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: markmc@redhat.com, andi@firstfloor.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:53950 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751425AbYLRF7u convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Dec 2008 00:59:50 -0500
In-Reply-To: <20081217.193406.102253657.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller a =E9crit :
> From: Mark McLoughlin <markmc@redhat.com>
> Date: Wed, 17 Dec 2008 11:25:01 +0000
>=20
>> On Wed, 2008-11-26 at 01:00 +0100, Eric Dumazet wrote:
>>
>>> [PATCH] net: release skb->dst in sock_queue_rcv_skb()
>  ...
>> IP_PKTINFO cmsg data is one post-queueing user:
>=20
> Eric, we'll need to rever this change I think.

I am afraid we have to revert it, yes.

META_COLLECTOR(int_rtiif) & META_COLLECTOR(int_rtclassid)=20
in net/sched/em_meta.c also need rtable, I am not sure how it is used.

About ip_cmsg_recv_pktinfo() :

iif can be found in skb->iif instead of rt->rt_iif, but I am not sure
about rt_spec_dst : Shouldnt we find it in ip_hdr(skb)->saddr ?
=20
Do you know if we really need rtable in ip_cmsg_recv_pktinfo() ?

diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index 43c0585..e854893 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -64,8 +64,8 @@ static void ip_cmsg_recv_pktinfo(struct msghdr *msg, =
struct sk_buff *skb)
 		info.ipi_ifindex =3D rt->rt_iif;
 		info.ipi_spec_dst.s_addr =3D rt->rt_spec_dst;
 	} else {
-		info.ipi_ifindex =3D 0;
-		info.ipi_spec_dst.s_addr =3D 0;
+		info.ipi_ifindex =3D skb->iif;
+		info.ipi_spec_dst.s_addr =3D ip_hdr(skb)->saddr;
 	}
=20
 	put_cmsg(msg, SOL_IP, IP_PKTINFO, sizeof(info), &info);

