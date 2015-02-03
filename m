From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: Question: should local address be expired when updating PMTU?
Date: Tue, 3 Feb 2015 13:01:41 +0100
Message-ID: <20150203120140.GU13046@secunet.com>
References: <54CF3348.40207@huawei.com>
 <20150203092845.GT13046@secunet.com>
 <54D0A8DB.4010106@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<yangyingliang@huawei.com>, <hannes@redhat.com>
To: shengyong <shengyong1@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:44322 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932933AbbBCMBu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Feb 2015 07:01:50 -0500
Content-Disposition: inline
In-Reply-To: <54D0A8DB.4010106@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 03, 2015 at 06:54:19PM +0800, shengyong wrote:
>=20
>=20
> =E5=9C=A8 2015/2/3 17:28, Steffen Klassert =E5=86=99=E9=81=93:
> > On Mon, Feb 02, 2015 at 04:20:24PM +0800, shengyong wrote:
> >=20
> > We first need to find out why you receive this Packet Too Big messa=
ge,
> The packet is sent by a commercial-off-the-shelf testcase, and I can =
reproduce the
> situation by using scapy and creating a packet as the following:
>=20
> 	$ cat packet-too-big.py
> 	#!/usr/bin/python
> =09
> 	from scapy.all import *
>=20
> 	# fe80::800:27ff:fe00:0 is linklocal addr of PC
> 	# fe80::a00:27ff:fe1a:e2a0 is linklocal addr of VM
> 	base=3DIPv6(src=3D'fe80::800:27ff:fe00:0',dst=3D'fe80::a00:27ff:fe1a=
:e2a0')
> 	pkt_too_big=3DICMPv6PacketTooBig(mtu=3D1024)
> 	ext_base=3DIPv6(src=3D'fe80::a00:27ff:fe1a:e2a0',dst=3D'fe80::a00:27=
ff:fe1a:e2a0',plen=3D24)
> 	ext_nd_na=3DICMPv6ND_NA()
> =09
> 	packet=3Dbase/pkt_too_big/ext_base/ext_nd_na
> 	send(packet)

So it is not a valid pmtu update, this make life easier.

Can you please test the patch below (compile tested only)?

This should fix your problem, and in combination with the two patches I=
 sent
out last week, it should cure the whole 'expiring of uncached routes' p=
roblem.

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 49596535..4ccfb9c 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1156,7 +1156,8 @@ static void ip6_rt_update_pmtu(struct dst_entry *=
dst, struct sock *sk,
 	struct rt6_info *rt6 =3D (struct rt6_info *)dst;
=20
 	dst_confirm(dst);
-	if (mtu < dst_mtu(dst) && rt6->rt6i_dst.plen =3D=3D 128) {
+	if (mtu < dst_mtu(dst) && rt6->rt6i_dst.plen =3D=3D 128 &&
+	    (rt6->rt6i_flags & RTF_CACHE)) {
 		struct net *net =3D dev_net(dst->dev);
=20
 		rt6->rt6i_flags |=3D RTF_MODIFIED;
