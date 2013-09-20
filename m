From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Subject: Re: [PATCH v2] ip6tnl: do route updating for redirect in ip6_tnl_err()
Date: Fri, 20 Sep 2013 18:43:08 +0800
Message-ID: <523C26BC.5050408@cn.fujitsu.com>
References: <1379474877-3097-1-git-send-email-duanj.fnst@cn.fujitsu.com> <20130919.140213.417316271045370155.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: djduanjiong@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:54043 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1754516Ab3ITKoN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Sep 2013 06:44:13 -0400
In-Reply-To: <20130919.140213.417316271045370155.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2013=E5=B9=B409=E6=9C=8820=E6=97=A5 02:02, David Miller =E5=86=
=99=E9=81=93:
> From: Duan Jiong <djduanjiong@gmail.com>
> Date: Tue, 17 Sep 2013 20:27:57 -0700
>=20
>> After the ip6_tnl_err() is called, the rel_msg is assigned to
>> 0, and the ip4ip6_err() will return directly, the instruction
>> below will not be executed.
>>
>> In rfc2473, we can know that the tunnel ICMP redirect message
>> should not be reported to the source of the original packet,
>> so we can handle it in ip6_tnl_err().
>>
>> Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>
>=20
> I do not think this change is correct.
>=20
>> @@ -576,9 +579,6 @@ ip4ip6_err(struct sk_buff *skb, struct inet6_skb=
_parm *opt,
>>  		rel_type =3D ICMP_DEST_UNREACH;
>>  		rel_code =3D ICMP_FRAG_NEEDED;
>>  		break;
>> -	case NDISC_REDIRECT:
>> -		rel_type =3D ICMP_REDIRECT;
>> -		rel_code =3D ICMP_REDIR_HOST;
>>  	default:
>>  		return 0;
>>  	}
>=20
> The bug is a missing "break;" statement for this case, and:

You can read the ip6_tnl_err(). when the message is NDISC_REDIRECT, the
rel_msg is assigned to 0, then=20

 561         if (rel_msg =3D=3D 0)
 562                 return 0;

the function ip4ip6_err() return directly. so even though you add "brea=
k;"
statement for this case, the redirect message will not be handled.

>=20
>> @@ -637,8 +637,6 @@ ip4ip6_err(struct sk_buff *skb, struct inet6_skb=
_parm *opt,
>> =20
>>  		skb_dst(skb2)->ops->update_pmtu(skb_dst(skb2), NULL, skb2, rel_in=
fo);
>>  	}
>> -	if (rel_type =3D=3D ICMP_REDIRECT)
>> -		skb_dst(skb2)->ops->redirect(skb_dst(skb2), NULL, skb2);
>> =20
>=20
> We absolutely must run the ipv4 dst_ops redirect handler here so you =
must
> keep this code around as well.
>=20

Because the Redirect Message is sent to tunnel entry-point, so the targ=
et address in
Redirect ICMPv6 Message is an ipv6 address, then we could not run the i=
pv4 dst_ops=20
redirect handler here.

Thanks,
  Duan

> The only change you need to make is to add the missing break;
> statement to ip4ip6_err() and then also add appropriate NDISC_REDIREC=
T
> handling to ip6ip6_err().
