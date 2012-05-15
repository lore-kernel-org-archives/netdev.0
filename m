From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: Re: [PATCH] ipv6: fix incorrect ipsec transport mode fragment
Date: Tue, 15 May 2012 11:44:26 +0800
Message-ID: <4FB1D11A.4040206@cn.fujitsu.com>
References: <20120215104021.GC31660@secunet.com> <1336965660-14201-1-git-send-email-gaofeng@cn.fujitsu.com> <20120514130528.GA24733@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net, lw@cn.fujitsu.com
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:37885 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1757772Ab2EODoB convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 May 2012 23:44:01 -0400
In-Reply-To: <20120514130528.GA24733@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi steffen:

=E4=BA=8E 2012=E5=B9=B405=E6=9C=8814=E6=97=A5 21:05, Steffen Klassert =E5=
=86=99=E9=81=93:
> On Mon, May 14, 2012 at 11:21:00AM +0800, Gao feng wrote:
>> Since commit 299b0767(ipv6: Fix IPsec slowpath fragmentation problem=
)
>> the fragment of ipsec transport mode packets is incorrect.
>> because tunnel mode needs IPsec headers and trailer for all fragment=
s,
>> while on transport mode it is sufficient to add the headers to the
>> first fragment and the trailer to the last.
>=20
> I mentioned this in an other thread some time ago,
> this is due to commit ad0081e43a
> "ipv6: Fragment locally generated tunnel-mode IPSec6 packets as neede=
d"
> changed tunnel mode to do fragmentation before the transformation
> while transport mode still does fragmentation after transformation.
> Now, tunnel mode needs IPsec headers and trailer for all fragments,
> while on transport mode it is sufficient to add the headers to the
> first fragment and the trailer to the last.
>=20
>>
>> so modify mtu and maxfraglen base on ipsec mode and if fragment is f=
irst
>> or last.
>=20
> There might be other opinions, but I don't like to see this IPsec mod=
e
> dependent stuff hacked into the generic ipv6 output path.
>=20
> Basically we have two cases. One where we have to add rt->dst.header_=
len
> to the first fragment and rt->dst.trailer_len to the last fragment,
> and the other where we have to add both to all fragments. So perhaps =
we
> could isolate this code and create two functions, one for each case.
>=20

how about add a function pointer append_data to the struct rt6_info?
so we can just call rt->append_data in ip6_append_data without conside
witch mode it is.

of course, we will set rt->append_data appropriatly in xfrm_lookup.

But the only problem is this will bloats up rt6_info,I don't konw if
it's worth doing it in this way.

>=20
>>
>> with my test,it work well and does not trigger slow fragment path.
>>
>> Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
>> ---
>>  net/ipv6/ip6_output.c |   80 +++++++++++++++++++++++++++++++++++++-=
----------
>>  1 files changed, 61 insertions(+), 19 deletions(-)
>>
>> diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
>> index b7ca461..9416887 100644
>> --- a/net/ipv6/ip6_output.c
>> +++ b/net/ipv6/ip6_output.c
>> @@ -1191,19 +1191,23 @@ int ip6_append_data(struct sock *sk, int get=
frag(void *from, char *to,
>>  	struct ipv6_pinfo *np =3D inet6_sk(sk);
>>  	struct inet_cork *cork;
>>  	struct sk_buff *skb;
>> -	unsigned int maxfraglen, fragheaderlen;
>> +	unsigned int maxfraglen, maxfraglen_prev, fragheaderlen;
>>  	int exthdrlen;
>>  	int dst_exthdrlen;
>>  	int hh_len;
>> -	int mtu;
>> +	int mtu, mtu_prev;
>>  	int copy;
>>  	int err;
>>  	int offset =3D 0;
>>  	int csummode =3D CHECKSUM_NONE;
>>  	__u8 tx_flags =3D 0;
>> -
>> +	bool transport_mode =3D false;
>> +	struct xfrm_state *x =3D rt->dst.xfrm;
>>  	if (flags&MSG_PROBE)
>>  		return 0;
>> +	if (x && x->props.mode =3D=3D XFRM_MODE_TRANSPORT)
>> +		transport_mode =3D true;
>> +
>=20
> Btw. beet mode should behave like transport mode here, just tunnel
> mode was changed to do fragmentation before the transformation.
>=20

thanks steffen,I miss it and CONFIG_XFRM...
