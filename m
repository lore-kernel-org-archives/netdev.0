From: shengyong <shengyong1@huawei.com>
Subject: Re: Question: should local address be expired when updating PMTU?
Date: Wed, 4 Feb 2015 09:59:54 +0800
Message-ID: <54D17D1A.3020706@huawei.com>
References: <54CF3348.40207@huawei.com> <20150203092845.GT13046@secunet.com> <54D0A8DB.4010106@huawei.com> <20150203120140.GU13046@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<yangyingliang@huawei.com>, <hannes@redhat.com>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:45709 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750944AbbBDCBZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Feb 2015 21:01:25 -0500
In-Reply-To: <20150203120140.GU13046@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



=E5=9C=A8 2015/2/3 20:01, Steffen Klassert =E5=86=99=E9=81=93:
> On Tue, Feb 03, 2015 at 06:54:19PM +0800, shengyong wrote:
>>
>>
>> =E5=9C=A8 2015/2/3 17:28, Steffen Klassert =E5=86=99=E9=81=93:
>>> On Mon, Feb 02, 2015 at 04:20:24PM +0800, shengyong wrote:
>>>
>>> We first need to find out why you receive this Packet Too Big messa=
ge,
>> The packet is sent by a commercial-off-the-shelf testcase, and I can=
 reproduce the
>> situation by using scapy and creating a packet as the following:
>>
>> 	$ cat packet-too-big.py
>> 	#!/usr/bin/python
>> =09
>> 	from scapy.all import *
>>
>> 	# fe80::800:27ff:fe00:0 is linklocal addr of PC
>> 	# fe80::a00:27ff:fe1a:e2a0 is linklocal addr of VM
>> 	base=3DIPv6(src=3D'fe80::800:27ff:fe00:0',dst=3D'fe80::a00:27ff:fe1=
a:e2a0')
>> 	pkt_too_big=3DICMPv6PacketTooBig(mtu=3D1024)
>> 	ext_base=3DIPv6(src=3D'fe80::a00:27ff:fe1a:e2a0',dst=3D'fe80::a00:2=
7ff:fe1a:e2a0',plen=3D24)
>> 	ext_nd_na=3DICMPv6ND_NA()
>> =09
>> 	packet=3Dbase/pkt_too_big/ext_base/ext_nd_na
>> 	send(packet)
>=20
> So it is not a valid pmtu update, this make life easier.
>=20
> Can you please test the patch below (compile tested only)?
Sorry, the later. I test it on 3.10-stable. It can fix this problem. So=
 maybe this is a bug?
And the 3 approaches (different flags are used: RTF_LOCAL, IFF_LOOPBACK=
 and RTF_CACHE) in
these mails can fix the expire of local address. I'm confused about the=
se flags:
* RTF_LOCAL: the entries of local address, like address binded to the n=
ative NIC
* RTF_CACHE: all cached entries
* IFF_LOOPBACK: this is a device-related flag, which has the same meani=
ng as RTF_LOCAL

Am I right? If so, I think RTF_LOCAL is appropriate, because we just wa=
nt entries of local
addresses to be not expired and we don't care other entries (I think if=
 they get expired,
a neigh discovery could find them back).

thx,
Sheng
>=20
> This should fix your problem, and in combination with the two patches=
 I sent
> out last week, it should cure the whole 'expiring of uncached routes'=
 problem.
>=20
> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
> index 49596535..4ccfb9c 100644
> --- a/net/ipv6/route.c
> +++ b/net/ipv6/route.c
> @@ -1156,7 +1156,8 @@ static void ip6_rt_update_pmtu(struct dst_entry=
 *dst, struct sock *sk,
>  	struct rt6_info *rt6 =3D (struct rt6_info *)dst;
> =20
>  	dst_confirm(dst);
> -	if (mtu < dst_mtu(dst) && rt6->rt6i_dst.plen =3D=3D 128) {
> +	if (mtu < dst_mtu(dst) && rt6->rt6i_dst.plen =3D=3D 128 &&
> +	    (rt6->rt6i_flags & RTF_CACHE)) {
>  		struct net *net =3D dev_net(dst->dev);
> =20
>  		rt6->rt6i_flags |=3D RTF_MODIFIED;
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20
> .
>=20
