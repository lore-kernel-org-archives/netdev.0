From: Fan Du <fan.du@windriver.com>
Subject: Re: [DISCUSSION] rt6i_genid
Date: Fri, 19 Jul 2013 08:01:47 +0800
Message-ID: <51E881EB.5040600@windriver.com>
References: <51E75F82.4080300@windriver.com> <51E7B1B0.3000109@6wind.com> <51E7B522.4070105@windriver.com> <51E805D9.9040408@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:63311 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932228Ab3GSABX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jul 2013 20:01:23 -0400
In-Reply-To: <51E805D9.9040408@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2013=E5=B9=B407=E6=9C=8818=E6=97=A5 23:12, Nicolas Dichtel wrote:
> Le 18/07/2013 11:28, Fan Du a =C3=A9crit :
>>
>> Thanks for replying :)
>>
>> On 2013=E5=B9=B407=E6=9C=8818=E6=97=A5 17:13, Nicolas Dichtel wrote:
>>> Le 18/07/2013 05:22, Fan Du a =C3=A9crit :
>>>> Hello Nicolas
>>>>
>>>> Commit 6f3118b571b8a4c06c7985dc3172c3526cb86253: "ipv6: use net->r=
t_genid to
>>>> check dst validity"
>>>> makes ip6_dst_check to check rt6i_genid against with struct net->r=
t_genid,
>>>> As a matter of fact, struct net->rt_genid could only be modified b=
y two places,
>>>> first is adding/delete IPv4 address, second is inserting new XFRM =
policy.
>>>>
>>>> Is there any other considerations that adding/deleting IPv4 addres=
s would
>>>> invalid all IPv6 dst
>>>> as well? because I'm working a patch which actually depends on the=
 result of
>>>> this question.
>>> No, the goal was to cover the IPsec case, ie invalidate dst entries=
 when an
>>> xfrm policy is inserted/deleted.
>>
>> Ok, then how about we only checking rt6i_genid against rt_genid *onl=
y*
>> when XFRM is enabled for IPv6, because when XFRM is not enabled for =
IPv6
>> ip6_dst_check for rt_genid is really not necessary.
>>
>> So what do you think of below modifications?
> Seems good. Just a small comment below.

Will send v2 for your reviewing when net-next is reopen.

Thanks

>>
>> diff --git a/include/net/ip6_fib.h b/include/net/ip6_fib.h
>> index 2a601e7..4ae35fd 100644
>> --- a/include/net/ip6_fib.h
>> +++ b/include/net/ip6_fib.h
>> @@ -119,7 +119,9 @@ struct rt6_info {
>> struct inet6_dev *rt6i_idev;
>> unsigned long _rt6i_peer;
>>
>> +#ifdef CONFIG_XFRM
>> u32 rt6i_genid;
>> +#endif
>>
>> /* more non-fragment space at head required */
>> unsigned short rt6i_nfheader_len;
>> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
>> index bd5fd70..1b64406 100644
>> --- a/net/ipv6/route.c
>> +++ b/net/ipv6/route.c
>> @@ -277,7 +277,9 @@ static inline struct rt6_info *ip6_dst_alloc(str=
uct net *net,
>>
>> memset(dst + 1, 0, sizeof(*rt) - sizeof(*dst));
>> rt6_init_peer(rt, table ? &table->tb6_peers : net->ipv6.peers);
>> +#ifdef CONFIG_XFRM
>> rt->rt6i_genid =3D rt_genid(net);
>> +#endif
>> INIT_LIST_HEAD(&rt->rt6i_siblings);
>> rt->rt6i_nsiblings =3D 0;
>> }
>> @@ -1041,12 +1043,15 @@ static struct dst_entry *ip6_dst_check(struc=
t dst_entry
>> *dst, u32 cookie)
>>
>> rt =3D (struct rt6_info *) dst;
>>
>> +#ifdef CONFIG_XFRM
>> /* All IPV6 dsts are created with ->obsolete set to the value
>> * DST_OBSOLETE_FORCE_CHK which forces validation calls down
>> * into this function always.
>> + * Note: for IPv6, rt6i_genid is noly used when XFRM enabled.
> indentation is wrong, but I'm not sure this comment is really needed =
=2E.. you've put the ifdef 4 lines above.
>
>> */
>> if (rt->rt6i_genid !=3D rt_genid(dev_net(rt->dst.dev)))
>> return NULL;
>> +#endif
>>
>> if (rt->rt6i_node && (rt->rt6i_node->fn_sernum =3D=3D cookie))
>> return dst;
>

--=20
=E6=B5=AE=E6=B2=89=E9=9A=8F=E6=B5=AA=E5=8F=AA=E8=AE=B0=E4=BB=8A=E6=9C=9D=
=E7=AC=91

--fan
