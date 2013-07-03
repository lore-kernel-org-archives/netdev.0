From: Fan Du <fan.du@windriver.com>
Subject: Re: [RFC PATCH] sctp: Don't lookup dst if transport dst is still
 valid
Date: Wed, 3 Jul 2013 10:39:16 +0800
Message-ID: <51D38ED4.1000000@windriver.com>
References: <1372747174-23580-1-git-send-email-fan.du@windriver.com> <51D2E3C8.5050100@gmail.com> <20130702155545.GB324@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Vlad Yasevich <vyasevich@gmail.com>, <nicolas.dichtel@6wind.com>,
	<davem@davemloft.net>, <netdev@vger.kernel.org>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:60883 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751691Ab3GCClL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jul 2013 22:41:11 -0400
In-Reply-To: <20130702155545.GB324@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2013=E5=B9=B407=E6=9C=8802=E6=97=A5 23:55, Neil Horman wrote:
> On Tue, Jul 02, 2013 at 10:29:28AM -0400, Vlad Yasevich wrote:
>> On 07/02/2013 02:39 AM, Fan Du wrote:
>>> When sctp sits on IPv6, sctp_transport_dst_check pass cookie as ZER=
O,
>>> as a result ip6_dst_check always fail out. This behaviour makes
>>> transport->dst useless, because every sctp_packet_transmit must loo=
k
>>> for valid dst(Is this what supposed to be?)
>>>
>>> One aggressive way is to call rt_genid_bump which invalid all dst t=
o
>>> make new dst for transport, apparently it also hurts others.
>>> I'm sure this may not be the best for all, so any commnets?
>>>
>>> Signed-off-by: Fan Du<fan.du@windriver.com>
>>> ---
>>>   include/net/sctp/sctp.h |   18 ++++++++++++------
>>>   net/sctp/ipv6.c         |    2 ++
>>>   2 files changed, 14 insertions(+), 6 deletions(-)
>>>
>>> diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
>>> index cd89510..f05af01 100644
>>> --- a/include/net/sctp/sctp.h
>>> +++ b/include/net/sctp/sctp.h
>>> @@ -719,14 +719,20 @@ static inline void sctp_v4_map_v6(union sctp_=
addr *addr)
>>>   	addr->v6.sin6_addr.s6_addr32[2] =3D htonl(0x0000ffff);
>>>   }
>>>
>>> -/* The cookie is always 0 since this is how it's used in the
>>> - * pmtu code.
>>> - */
>>> +/* Set cookie with the right one for IPv6 and zero for others */
>>>   static inline struct dst_entry *sctp_transport_dst_check(struct s=
ctp_transport *t)
>>>   {
>>> -	if (t->dst&&  !dst_check(t->dst, 0)) {
>>> -		dst_release(t->dst);
>>> -		t->dst =3D NULL;
>>> +
>>> +	if (t->dst) {
>>> +		struct rt6_info *rt =3D (struct rt6_info *)t->dst;
>>> +		u32 cookie =3D 0;
>>> +
>>> +		if ((t->af_specific->sa_family =3D=3D AF_INET6)&&  rt->rt6i_node=
)=09
>>> +			cookie =3D rt->rt6i_node->fn_sernum;=09
>>> +		if (!dst_check(t->dst, cookie)) {
>>> +			dst_release(t->dst);
>>> +			t->dst =3D NULL;
>>> +		}
>>>   	}
>>
>> I think it would be better if we stored the dst_cookie in the
>> transport structure and initialized it at lookup time.   If you do
>> that, then if the route table changes, we'd correctly detect it
>> without artificially bumping rt_genid (and hurting ipv4).
>>
> Agreed, thats how we do it for ipv4, IIRC
                                  ^^^^
Hello Neil

I'm sorry I didn't find such things about IPv4.

sctp_transport_dst_check
  -> ipv4_dst_check
    -> rt_is_expired
            ^^^^^^^^^
By "expired", currently we *do* check rt->rt_genid against net->rt_geni=
d,
and for IPv4, every adding/deleting an IPv4 address will bump net->rt_g=
enid,
(this does impact IPv6 dst checking as well) so when I delete an IPv4 a=
ddress,
ipv4_dst_check failed as expected to look for new dst, basically that's=
 what
I find after checking the code for IPv4 cookie things as mentioned abov=
e.
Am I missing something here?


> Neil
>
>> -vlad
>>
>>>
>>>   	return t->dst;
>>> diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
>>> index 8ee553b..cfae77e 100644
>>> --- a/net/sctp/ipv6.c
>>> +++ b/net/sctp/ipv6.c
>>> @@ -137,6 +137,8 @@ static int sctp_inet6addr_event(struct notifier=
_block *this, unsigned long ev,
>>>   		break;
>>>   	}
>>>
>>> +	/* invalid all transport dst forcing to look up new dst */
>>> +	rt_genid_bump(net);
>>>   	return NOTIFY_DONE;
>>>   }
>>>
>>>
>>
>>
>

--=20
=E6=B5=AE=E6=B2=89=E9=9A=8F=E6=B5=AA=E5=8F=AA=E8=AE=B0=E4=BB=8A=E6=9C=9D=
=E7=AC=91

--fan
