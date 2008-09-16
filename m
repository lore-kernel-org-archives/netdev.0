From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: Re: [PATCH RESEND] ipv6: return with appropriate error code when
 sending RH0 using setsockopt()
Date: Tue, 16 Sep 2008 15:13:33 +0800
Message-ID: <48CF5C9D.5090200@cn.fujitsu.com>
References: <48BE4DA2.20800@cn.fujitsu.com>	<48BED93E.2000204@hp.com>	<48BF598A.6020702@cn.fujitsu.com> <20080911.201458.162553481.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: brian.haley@hp.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:61676 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751400AbYIPHPp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Sep 2008 03:15:45 -0400
In-Reply-To: <20080911.201458.162553481.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller =D0=B4=B5=C0:
> From: Shan Wei <shanwei@cn.fujitsu.com>
> Date: Thu, 04 Sep 2008 11:44:10 +0800
>=20
>> Brian Haley =D0=B4=B5=C0:
>>> Shan Wei wrote:
>>>> diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
>>>> index 4e5eac3..7a58597 100644
>>>> --- a/net/ipv6/ipv6_sockglue.c
>>>> +++ b/net/ipv6/ipv6_sockglue.c
>>>> @@ -353,9 +353,10 @@ static int do_ipv6_setsockopt(struct sock *sk=
, int level, int optname,
>>>>  			goto e_inval;
>>>> =20
>>>>  		/* hop-by-hop / destination options are privileged option */
>>>> -		retv =3D -EPERM;
>>>> -		if (optname !=3D IPV6_RTHDR && !capable(CAP_NET_RAW))
>>>> +		if (optname !=3D IPV6_RTHDR && !capable(CAP_NET_RAW)) {
>>>> +			retv =3D -EPERM;
>>>>  			break;
>>>> +		}
>>> I'm not sure you need this since it doesn't actually change anythin=
g,
>>> setting the error before the check just seems like the style in thi=
s
>>> function.  It will get set to -EINVAL below...
>>>
>> For uncommon expection, if the check is true, we set the error.=20
>> it will reduce the number of setting retv value.
>=20
> Do you have some emotional attachment to this change? :-/
>=20
> The compiler optimizer will make the transformation you claim is
> now possible, all by itself, if it is deemed more optimal.
>=20
> Never make any claims about how many times something will or will not
> happen in the compiled output without consulting and providing
> examples of the resulting assembler.  Otherwise you are just guessing=
=2E
>=20
> This is just a pointless change, and as Brian said it disagrees with
> the way this construct is made in the rest of this function.  So
> please take it out of your patch.
sorry for repling late.
maybe what i describe is not explicit.

in this function the style is like this:
case XX:
{
  retv =3D -EPROTO;
  if (condition1) break;
  ...
  retv =3D -EFAULT;
  if (condition2) break;
  ...
  retv =3D -EINVAL;
  if (condition3) break;
  ...
}
when the conditions are all false, the retv value is set three times.

but with the following style, the retv value is not set.
case XX:
{
  if (condition1){ retv =3D -EPROTO;break;}
  ...
  if (condition2){ retv =3D -EFAULT;break;}
  ...
  if (condition3){ retv =3D -EINVAL;break;}
  ...
}
Seting the retv value when expection is occurred almost don't improve
the performance, but it's a little better.

