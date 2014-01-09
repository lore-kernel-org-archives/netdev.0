From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [PATCH net-next V3 1/3] net: Add GRO support for UDP encapsulating
 protocols
Date: Thu, 9 Jan 2014 08:25:38 +0200
Message-ID: <52CE40E2.7040408@mellanox.com>
References: <1389213278-2200-1-git-send-email-ogerlitz@mellanox.com>	<1389213278-2200-2-git-send-email-ogerlitz@mellanox.com> <CA+mtBx9yKSW5GFz-zrFSDdkshAmGmdVhds5wgwQKJd0SDEdBCw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jerry Chu <hkchu@google.com>, Eric Dumazet <edumazet@google.com>,
	"Herbert Xu" <herbert@gondor.apana.org.au>,
	Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Yan Burman <yanb@mellanox.com>,
	"Shlomo Pongratz" <shlomop@mellanox.com>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog123.obsmtp.com ([207.126.144.155]:58076 "EHLO
	eu1sys200aog123.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751135AbaAIGZt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jan 2014 01:25:49 -0500
In-Reply-To: <CA+mtBx9yKSW5GFz-zrFSDdkshAmGmdVhds5wgwQKJd0SDEdBCw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/01/2014 23:58, Tom Herbert wrote:
>> +static struct sk_buff **udp_gro_receive(struct sk_buff **head, struct sk_buff *skb)
>> >+{
>> >+       struct list_head *ohead = &udp_offload_base;
>> >+       struct udp_offload *poffload;
>> >+       struct sk_buff *p, **pp = NULL;
>> >+       struct udphdr *uh, *uh2;
>> >+       unsigned int hlen, off;
>> >+       int flush = 1;
>> >+
>> >+       if (NAPI_GRO_CB(skb)->udp_mark ||
>> >+           (!skb->encapsulation && skb->ip_summed != CHECKSUM_COMPLETE))
>> >+               goto out;
>> >+
>> >+       /* mark that this skb passed once through the udp gro layer */
>> >+       NAPI_GRO_CB(skb)->udp_mark = 1;
>> >+
>> >+       off  = skb_gro_offset(skb);
>> >+       hlen = off + sizeof(*uh);
>> >+       uh   = skb_gro_header_fast(skb, off);
>> >+       if (skb_gro_header_hard(skb, hlen)) {
>> >+               uh = skb_gro_header_slow(skb, hlen, off);
>> >+               if (unlikely(!uh))
>> >+                       goto out;
>> >+       }
>> >+
>> >+       rcu_read_lock();
>> >+       list_for_each_entry_rcu(poffload, ohead, list) {
>> >+               if (poffload->port != uh->dest || !poffload->callbacks.gro_receive)
> Is gro_receive == NULL ever valid? Maybe we can assert on registration instead of checking on every packet.

I see your point, however, the offload structure contains entries for 
both gro and  gso, asserting on registration could somehow limit the use 
cases, isn't that?


> Maybe make this poffload->port == uh->dest and goto "flush = 0". Check below that list end was reached becomes unnecessary.

Sure, will use goto "flush = 0" and if we didn't  go there we'll go to 
out_unlock
