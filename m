From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 10/17] netfilter: ipv6: expand skb head in ip6_route_me_harder
 after oif change
Date: Mon, 21 Nov 2011 16:00:17 +0100
Message-ID: <4ECA6781.6000101@trash.net>
References: <1321854369-3432-1-git-send-email-kaber@trash.net>	 <1321854369-3432-11-git-send-email-kaber@trash.net> <1321871357.2552.24.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	ulrich.weber@sophos.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1321871357.2552.24.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/21/2011 11:29 AM, Eric Dumazet wrote:
> Le lundi 21 novembre 2011 =C3=A0 06:46 +0100, kaber@trash.net a =C3=A9=
crit :
>> From: Patrick McHardy<kaber@trash.net>
>>
>> Expand the skb headroom if the oif changed due to rerouting similar =
to
>> how IPv4 packets are handled.
>>
>> Signed-off-by: Patrick McHardy<kaber@trash.net>
>> ---
>>   net/ipv6/netfilter.c |    7 +++++++
>>   1 files changed, 7 insertions(+), 0 deletions(-)
>>
>> diff --git a/net/ipv6/netfilter.c b/net/ipv6/netfilter.c
>> index 30fcee4..d39e954 100644
>> --- a/net/ipv6/netfilter.c
>> +++ b/net/ipv6/netfilter.c
>> @@ -14,6 +14,7 @@ int ip6_route_me_harder(struct sk_buff *skb)
>>   {
>>   	struct net *net =3D dev_net(skb_dst(skb)->dev);
>>   	const struct ipv6hdr *iph =3D ipv6_hdr(skb);
>> +	unsigned int hh_len;
>>   	struct dst_entry *dst;
>>   	struct flowi6 fl6 =3D {
>>   		.flowi6_oif =3D skb->sk ? skb->sk->sk_bound_dev_if : 0,
>> @@ -46,6 +47,12 @@ int ip6_route_me_harder(struct sk_buff *skb)
>>   	}
>>   #endif
>>
>> +	/* Change in oif may mean change in hh_len. */
>> +	hh_len =3D skb_dst(skb)->dev->hard_header_len;
>> +	if (skb_headroom(skb)<  hh_len&&
>> +	    pskb_expand_head(skb, hh_len - skb_headroom(skb), 0, GFP_ATOMI=
C))
>> +		return -1;
>> +
> Hmm, We had a problem recently on Tile arches because of unaligned
> accesses.
>
> Had you seen the bug report and proposed patch ?
>
> Fix is to instead do :
>
> 	pskb_expand_head(skb,
> 			 HH_DATA_ALIGN(hh_len - skb_headroom(skb)),
> 			 0,
> 			 GFP_ATOMIC);

I'll have a look and will update the patch accordingly.

--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
