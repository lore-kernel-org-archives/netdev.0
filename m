From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] cls_flow: add sanity check for the packet length
Date: Wed, 4 Aug 2010 21:51:31 +0800
Message-ID: <AANLkTi=th9x0yWv3h1eT4Za7pqh0UDcT1QC_D9X1POOQ@mail.gmail.com>
References: <1280905687-8463-1-git-send-email-xiaosuo@gmail.com>
	<1280929183.5669.7.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:56147 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757538Ab0HDNvw convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Aug 2010 09:51:52 -0400
Received: by wwj40 with SMTP id 40so6466317wwj.1
        for <netdev@vger.kernel.org>; Wed, 04 Aug 2010 06:51:51 -0700 (PDT)
In-Reply-To: <1280929183.5669.7.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 4, 2010 at 9:39 PM, jamal <hadi@cyberus.ca> wrote:
> On Wed, 2010-08-04 at 15:08 +0800, Changli Gao wrote:
>> The packet length should be checked before the packet data is derefe=
renced.
>>
>> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
>> ---
>> =A0include/linux/skbuff.h | =A0 =A06 ++--
>> =A0net/sched/cls_flow.c =A0 | =A0 69 +++++++++++++++++++++++++++++++=
++----------------
>> =A02 files changed, 50 insertions(+), 25 deletions(-)
>> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
>> index d20d9e7..3f0ac50 100644
>> --- a/include/linux/skbuff.h
>> +++ b/include/linux/skbuff.h
>> @@ -1210,12 +1210,12 @@ static inline unsigned char *pskb_pull(struc=
t sk_buff *skb, unsigned int len)
>> =A0 =A0 =A0 return unlikely(len > skb->len) ? NULL : __pskb_pull(skb=
, len);
>> =A0}
>>
>> -static inline int pskb_may_pull(struct sk_buff *skb, unsigned int l=
en)
>> +static inline bool pskb_may_pull(struct sk_buff *skb, unsigned int =
len)
>> =A0{
>> =A0 =A0 =A0 if (likely(len <=3D skb_headlen(skb)))
>> - =A0 =A0 =A0 =A0 =A0 =A0 return 1;
>> + =A0 =A0 =A0 =A0 =A0 =A0 return true;
>> =A0 =A0 =A0 if (unlikely(len > skb->len))
>> - =A0 =A0 =A0 =A0 =A0 =A0 return 0;
>> + =A0 =A0 =A0 =A0 =A0 =A0 return false;
>> =A0 =A0 =A0 return __pskb_pull_tail(skb, len - skb_headlen(skb)) !=3D=
 NULL;
>> =A0}
>
> Above is a different patch?

Patrick thinks such things don't worth individual patches. I remember
my such patch was applied by David. It is for netdev, not netfilter. I
should obey David's rules. I'll remove this in the next version.
Thanks.

>
>> diff --git a/net/sched/cls_flow.c b/net/sched/cls_flow.c
>> index f73542d..d63a374 100644
>> --- a/net/sched/cls_flow.c
>> +++ b/net/sched/cls_flow.c
>> @@ -65,37 +65,48 @@ static inline u32 addr_fold(void *addr)
>> =A0 =A0 =A0 return (a & 0xFFFFFFFF) ^ (BITS_PER_LONG > 32 ? a >> 32 =
: 0);
>> =A0}
>>
>> -static u32 flow_get_src(const struct sk_buff *skb)
>> +static inline bool flow_pskb_may_pull(struct sk_buff *skb, unsigned=
 int len)
>> +{
>> + =A0 =A0 return pskb_may_pull(skb, skb_network_offset(skb) + len);
>> +}
>
> network_pskb_may_pull() would make it more generic (probably in
> skbuff.h) and reused everywhere you need skb_network_offset
>

I think pskb_network_may_pull() is better.

>
>> +static u32 flow_get_src(struct sk_buff *skb)
>> =A0{
>> =A0 =A0 =A0 switch (skb->protocol) {
>> =A0 =A0 =A0 case htons(ETH_P_IP):
>> - =A0 =A0 =A0 =A0 =A0 =A0 return ntohl(ip_hdr(skb)->saddr);
>> + =A0 =A0 =A0 =A0 =A0 =A0 return flow_pskb_may_pull(skb, sizeof(stru=
ct iphdr)) ?
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ntohl(ip_hdr(skb)->saddr) :=
 0;
>> =A0 =A0 =A0 case htons(ETH_P_IPV6):
>> - =A0 =A0 =A0 =A0 =A0 =A0 return ntohl(ipv6_hdr(skb)->saddr.s6_addr3=
2[3]);
>> + =A0 =A0 =A0 =A0 =A0 =A0 return flow_pskb_may_pull(skb, sizeof(stru=
ct ipv6hdr)) ?
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ntohl(ipv6_hdr(skb)->saddr.=
s6_addr32[3]) : 0;
>> =A0 =A0 =A0 default:
>
>
> BTW - does returning zero above make sense or is returning the defaul=
t below better?
>
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 return addr_fold(skb->sk);
>
> Same comment applies in all other switch statements..
>

Oh, good suggestion. Thanks.

--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
