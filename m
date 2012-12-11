From: Duan Jiong <djduanjiong@gmail.com>
Subject: Re: [PATCH] ipv6: fix the bug when propagating Redirect Message
Date: Tue, 11 Dec 2012 20:58:20 +0800
Message-ID: <50C72DEC.1000008@gmail.com>
References: <5086B721.1090905@gmail.com> <20121024045410.GF27385@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:55813 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752173Ab2LKM60 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Dec 2012 07:58:26 -0500
Received: by mail-pa0-f46.google.com with SMTP id bh2so2867468pad.19
        for <netdev@vger.kernel.org>; Tue, 11 Dec 2012 04:58:25 -0800 (PST)
In-Reply-To: <20121024045410.GF27385@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2012/10/24 12:54, Steffen Klassert =E5=86=99=E9=81=93:
> On Tue, Oct 23, 2012 at 11:26:25PM +0800, Duan Jiong wrote:
>>
>> Before using icmpv6_notify() to propagate redirect, change skb->data
>> to poing the IP packet that triggered the sending of the Redirect.
>>
>> Signed-off-by: Duan Jiong <djduanjiong@gmail.com>
>> ---
>>  net/ipv6/ndisc.c |   39 +++++++++++++++++++++++++++++++++++++++
>>  1 files changed, 39 insertions(+), 0 deletions(-)
>>
>> diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
>> index ff36194..0f73303 100644
>> --- a/net/ipv6/ndisc.c
>> +++ b/net/ipv6/ndisc.c
>> @@ -1334,6 +1334,11 @@ out:
>> =20
>>  static void ndisc_redirect_rcv(struct sk_buff *skb)
>>  {
>> +	int opt_len;
>> +	int opt_offset;
>> +	int ndisc_head_len;
>> +	struct nd_opt_hdr *nd_opt;
>> +=09
>>  #ifdef CONFIG_IPV6_NDISC_NODETYPE
>>  	switch (skb->ndisc_nodetype) {
>>  	case NDISC_NODETYPE_HOST:
>> @@ -1350,6 +1355,40 @@ static void ndisc_redirect_rcv(struct sk_buff=
 *skb)
>>  		return;
>>  	}
>> =20
>> +	ndisc_head_len =3D sizeof(struct icmp6hdr) + 2*sizeof(struct in6_a=
ddr);
>> +	if (!pskb_may_pull(skb, ndisc_head_len)) {
>> +		return;
>> +	}
>> +
>> +	nd_opt =3D (struct nd_opt_hdr *)(skb->data + ndisc_head_len);
>> +
>> +	opt_len =3D skb->tail - skb->transport_header - ndisc_head_len;
>> +	if (opt_len < 0) {
>> +		return;
>> +	}
>> +	while (opt_len) {
>> +		int l;
>> +=09
>> +		if (opt_len < sizeof(struct nd_opt_hdr)) {
>> +			return;
>> +		}
>> +		l =3D nd_opt->nd_opt_len << 3;
>> +		if (opt_len < l || l =3D=3D 0) {
>> +			return;
>> +		}
>> +		if (nd_opt->nd_opt_type =3D=3D ND_OPT_REDIRECT_HDR) {
>> +			__skb_pull(skb, ndisc_head_len + opt_offset + 8);
>> +			break;
>> +		}
>> +		opt_len -=3D l;
>> +		nd_opt =3D ((void *)nd_opt) + 1;
>> +		opt_offset +=3D 1;
>> +	}
>=20
> Instead of the above loop, you could use ndisc_parse_options().
> This does the same what you are doing here and it would make it
> a bit clearer what's going on.
>=20
I apologize for not replying to you earlier,and i will continue=20
to update my patches.=20

Just like you said, i try to use ndisc_parse_options() to instead
of the loop, but i find the skb->data can't be changed in function
ndisc_parse_options() due to lack of  arguments. So i think it is
better to continue to use the loop. How do you think this?

Thanks!
