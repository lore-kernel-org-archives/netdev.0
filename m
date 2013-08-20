From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Subject: Re: [PATCH] ipv6: handle Redirect ICMP Message with no Redirected
 Header option
Date: Tue, 20 Aug 2013 09:56:33 +0800
Message-ID: <5212CCD1.8080808@cn.fujitsu.com>
References: <5211F97B.4090209@cn.fujitsu.com> <20130819115512.GC9414@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:16083 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751723Ab3HTB4z convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Aug 2013 21:56:55 -0400
In-Reply-To: <20130819115512.GC9414@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2013=E5=B9=B408=E6=9C=8819=E6=97=A5 19:55, Hannes Frederic So=
wa =E5=86=99=E9=81=93:
> On Mon, Aug 19, 2013 at 06:54:51PM +0800, Duan Jiong wrote:
>> From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
>>
>> rfc 4861 says the Redirected Header option is optional, so
>> the kernel should not drop the Redirect Message that has no
>> Redirected Header option. In this patch, the function
>> ip6_redirect_no_header() is introduced to deal with that
>> condition.
>>
>> Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>
>> ---
>>  include/net/ip6_route.h |    1 +
>>  net/ipv6/ndisc.c        |    4 +++-
>>  net/ipv6/route.c        |   21 +++++++++++++++++++++
>>  3 files changed, 25 insertions(+), 1 deletions(-)
>>
>> diff --git a/include/net/ip6_route.h b/include/net/ip6_route.h
>> index 260f83f..7966f54 100644
>> --- a/include/net/ip6_route.h
>> +++ b/include/net/ip6_route.h
>> @@ -135,6 +135,7 @@ extern void ip6_update_pmtu(struct sk_buff *skb,=
 struct net *net, __be32 mtu,
>>  extern void ip6_sk_update_pmtu(struct sk_buff *skb, struct sock *sk=
,
>>  			       __be32 mtu);
>>  extern void ip6_redirect(struct sk_buff *skb, struct net *net, int =
oif, u32 mark);
>> +extern void ip6_redirect_no_header(struct sk_buff *skb, struct net =
*net, int oif, u32 mark);
>>  extern void ip6_sk_redirect(struct sk_buff *skb, struct sock *sk);
>> =20
>>  struct netlink_callback;
>> diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
>> index 79aa965..04d31c2 100644
>> --- a/net/ipv6/ndisc.c
>> +++ b/net/ipv6/ndisc.c
>> @@ -1369,8 +1369,10 @@ static void ndisc_redirect_rcv(struct sk_buff=
 *skb)
>>  	if (!ndisc_parse_options(msg->opt, ndoptlen, &ndopts))
>>  		return;
>> =20
>> -	if (!ndopts.nd_opts_rh)
>> +	if (!ndopts.nd_opts_rh) {
>> +		ip6_redirect_no_header(skb, dev_net(skb->dev), 0, 0);
>>  		return;
>> +	}
>=20
> Can't we just jump down to icmpv6_notify without introducing
> ip6_redirect_no_header?
>=20
No, the function icmpv6_notify need the skb->data point the inner IP
packet that triggered the sending of the ICMP Message, so when the
Redirect Message has no Redirected Header option, it should not be
handled in icmpv6_notify.
>> =20
>>  	hdr =3D (u8 *)ndopts.nd_opts_rh;
>>  	hdr +=3D 8;
>> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
>> index b70f897..9934b87 100644
>> --- a/net/ipv6/route.c
>> +++ b/net/ipv6/route.c
>> @@ -1178,6 +1178,27 @@ void ip6_redirect(struct sk_buff *skb, struct=
 net *net, int oif, u32 mark)
>>  }
>>  EXPORT_SYMBOL_GPL(ip6_redirect);
>> =20
>> +void ip6_redirect_no_header(struct sk_buff *skb, struct net *net, i=
nt oif, u32 mark)
>> +{
>> +	const struct ipv6hdr *iph =3D (struct ipv6hdr *) skb_network_heade=
r(skb);
>=20
> const struct ipv6hdr *iph =3D ipv6_hdr(skb);
>=20
Thanks for you help, i will apply it in next version.

Thanks,
  Duan
