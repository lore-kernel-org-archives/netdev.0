From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ip: generate unique IP identificator if local
 fragmentation is allowed
Date: Wed, 18 Sep 2013 12:55:13 -0400 (EDT)
Message-ID: <20130918.125513.1767844012534596974.davem@davemloft.net>
References: <1379456700-8033-1-git-send-email-aatteka@nicira.com>
	<20130918.122018.1088822749792394509.davem@davemloft.net>
	<CAA=3Oq=Kxfe8KKnWV7QjLnT1Art3UEMJBTE=tXBLZPa6diug6g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: aatteka@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36608 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751460Ab3IRQzP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Sep 2013 12:55:15 -0400
In-Reply-To: <CAA=3Oq=Kxfe8KKnWV7QjLnT1Art3UEMJBTE=tXBLZPa6diug6g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ansis Atteka <aatteka@nicira.com>
Date: Wed, 18 Sep 2013 09:50:31 -0700

> On Wed, Sep 18, 2013 at 9:20 AM, David Miller <davem@davemloft.net> wrote:
>> From: Ansis Atteka <aatteka@nicira.com>
>> Date: Tue, 17 Sep 2013 15:25:00 -0700
>>
>>> @@ -1317,6 +1317,7 @@ struct sk_buff *__ip_make_skb(struct sock *sk,
>>>               ttl = ip_select_ttl(inet, &rt->dst);
>>>
>>>       iph = (struct iphdr *)skb->data;
>>> +
>>>       iph->version = 4;
>>>       iph->ihl = 5;
>>>       iph->tos = inet->tos;
>>> @@ -1324,7 +1325,7 @@ struct sk_buff *__ip_make_skb(struct sock *sk,
>>>       iph->ttl = ttl;
>>>       iph->protocol = sk->sk_protocol;
>>>       ip_copy_addrs(iph, fl4);
>>> -     ip_select_ident(iph, &rt->dst, sk);
>>> +     ip_select_ident(skb, &rt->dst, sk);
>>>
>>>       if (opt) {
>>>               iph->ihl += opt->optlen>>2;
>>
>> This transformation is not equivalent.
>>
>> ip_select_ident() is going to use ip_hdr() which obtains the header
>> pointer via skb_network_header().
>>
>> But here, the code is using skb->data for this, which is different.
> 
> I dared to do that because three lines below ip_options_build() seems
> to be already doing the same thing, if IP options are present:
> 
> struct sk_buff *__ip_make_skb() {
>     ...
>     ip_select_ident(skb, &rt->dst, sk);
>     if (opt) {
>         iph->ihl += opt->optlen>>2;
>         ip_options_build(skb, opt, cork->addr, rt, 0);
>     }
> 
> and
> 
> void ip_options_build(struct sk_buff *skb, struct ip_options *opt,
> __be32 daddr, struct rtable *rt, int is_frag) {
>     unsigned char *iph = skb_network_header(skb);
>     ....

Then change the first hunk to use ip_hdr() if you are so confident.

Having inconsistent calculations of the ip header pointer is just
asking for trouble.
