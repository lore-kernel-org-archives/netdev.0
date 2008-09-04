From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: Re: [PATCH RESEND] ipv6: return with appropriate error code when
 sending RH0 using setsockopt()
Date: Thu, 04 Sep 2008 11:44:10 +0800
Message-ID: <48BF598A.6020702@cn.fujitsu.com>
References: <48BE4DA2.20800@cn.fujitsu.com> <48BED93E.2000204@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:58640 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753575AbYIDDqG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Sep 2008 23:46:06 -0400
In-Reply-To: <48BED93E.2000204@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Brian Haley =D0=B4=B5=C0:
> Shan Wei wrote:
>>  I'm sorry to resend the patch, for that no one replied it from Jun =
27.
>>
>>  The kernel had removed the RH0(Type 0 Routing Header), but we can s=
till
>>  send IPv6 packet with RH0 using sendmsg() or setsockopt().
>>
>>  Compare with sendmsg() that returns EINVAL, but setsockopt() return=
 EPERM.
>>  The patch fix it.
>>
>> Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>
>> ---
>>  net/ipv6/ipv6_sockglue.c |    6 ++++--
>>  1 files changed, 4 insertions(+), 2 deletions(-)
>>
>> diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
>> index 4e5eac3..7a58597 100644
>> --- a/net/ipv6/ipv6_sockglue.c
>> +++ b/net/ipv6/ipv6_sockglue.c
>> @@ -353,9 +353,10 @@ static int do_ipv6_setsockopt(struct sock *sk, =
int level, int optname,
>>  			goto e_inval;
>> =20
>>  		/* hop-by-hop / destination options are privileged option */
>> -		retv =3D -EPERM;
>> -		if (optname !=3D IPV6_RTHDR && !capable(CAP_NET_RAW))
>> +		if (optname !=3D IPV6_RTHDR && !capable(CAP_NET_RAW)) {
>> +			retv =3D -EPERM;
>>  			break;
>> +		}
>=20
> I'm not sure you need this since it doesn't actually change anything,
> setting the error before the check just seems like the style in this
> function.  It will get set to -EINVAL below...
>=20
=46or uncommon expection, if the check is true, we set the error.=20
it will reduce the number of setting retv value.

>> @@ -365,6 +366,7 @@ static int do_ipv6_setsockopt(struct sock *sk, i=
nt level, int optname,
>>  			break;
>>  		}
>> =20
>> +		retv =3D -EINVAL;
>>  		/* routing header option needs extra check */
>>  		if (optname =3D=3D IPV6_RTHDR && opt && opt->srcrt) {
>>  			struct ipv6_rt_hdr *rthdr =3D opt->srcrt;
>=20
> This seems correct as trying to set an unsupported routing header typ=
e
> is invalid, or trying to set a Type 2 that itself is invalid is bad.
> The Unix I checked does this.
>=20
yes=20
> There's actually another bug here and in the sendmsg() path in that y=
ou
> can set the hdrlen and segments_left fields to be invalid (according =
to
> RFC3775), as long as the math works out (segments * 2 =3D=3D length).
> Segments_left should always be 1 and hdrlen 2 for a Type2 routing
> header.  The packet should be dropped at the destination, but we
> probably shouldn't send it.  I can send a patch for that later.
>=20
> -Brian
>=20

