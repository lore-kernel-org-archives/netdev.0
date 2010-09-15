From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: af_packet: don't call tpacket_destruct_skb()
 until the skb is sent out
Date: Tue, 14 Sep 2010 20:20:23 -0700 (PDT)
Message-ID: <20100914.202023.193706826.davem@davemloft.net>
References: <1284175403-3228-1-git-send-email-xiaosuo@gmail.com>
	<20100912121349.GD22982@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xiaosuo@gmail.com, eric.dumazet@gmail.com, socketcan@hartkopp.net,
	netdev@vger.kernel.org
To: mst@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57336
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753517Ab0IODUF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Sep 2010 23:20:05 -0400
In-Reply-To: <20100912121349.GD22982@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Sun, 12 Sep 2010 14:13:49 +0200

> On Sat, Sep 11, 2010 at 11:23:23AM +0800, Changli Gao wrote:
>> @@ -799,7 +806,9 @@ int pskb_expand_head(struct sk_buff *skb, int nhead, int ntail,
>>  
>>  	memcpy((struct skb_shared_info *)(data + size),
>>  	       skb_shinfo(skb),
>> -	       offsetof(struct skb_shared_info, frags[skb_shinfo(skb)->nr_frags]));
>> +	       offsetof(struct skb_shared_info,
>> +			frags[skb_shinfo(skb)->nr_frags]));
>> +	skb_shinfo(skb)->destructor = NULL;
>>  
>>  	/* Check if we can avoid taking references on fragments if we own
>>  	 * the last reference on skb->head. (see skb_release_data())
> 
> So it looks like pskb_expand_head will prevent the shinfo desctructor
> from being called, ever? If so, won't this break af_packet?

>From what I read, he is propagating it into the new SKB data blob
with expanded head area.  It would get invoked when the skb's
new data is put.

I am not sure this is correct, however.

Destructor register only cares about original data area, but what
constitutes "original data" is ambiguous.  In fact it seems
impossible to catch the freeing of all parts properly.

When pskb_expand_head() is invoked we get new linear part, but
non-linear part stays the same.  However, entity which registered
skb data destructor cares about old linear data lifetime, which
we will no longer track after destructor is propagated only to
the new shinfo.

So we need to do something different here.  I bet original code
overriding socket destructor semantics had a similar problem.

Changli, I have one other minor request, please name this something
like "shinfo->data_destructor" and "shinfo->data_destructor_arg".

I think that will make it easier for other humans to understand :)

Thank you.
