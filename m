From: Vitaly Kuznetsov <vkuznets@redhat.com>
Subject: Re: [PATCH net-next RESEND] xen-netfront: avoid packet loss when ethernet header crosses page boundary
Date: Mon, 19 Sep 2016 12:22:05 +0200
Message-ID: <87mvj4xk8i.fsf@vitty.brq.redhat.com>
References: <1474023554-24520-1-git-send-email-vkuznets@redhat.com>
        <20160918.222607.1930094684278444086.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        ptalbert@redhat.com, boris.ostrovsky@oracle.com,
        david.vrabel@citrix.com, jgross@suse.com,
        xen-devel@lists.xenproject.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160918.222607.1930094684278444086.davem@davemloft.net> (David
        Miller's message of "Sun, 18 Sep 2016 22:26:07 -0400 (EDT)")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> writes:

> From: Vitaly Kuznetsov <vkuznets@redhat.com>
> Date: Fri, 16 Sep 2016 12:59:14 +0200
>
>> @@ -595,6 +596,19 @@ static int xennet_start_xmit(struct sk_buff *skb, struct net_device *dev)
>>  	offset = offset_in_page(skb->data);
>>  	len = skb_headlen(skb);
>>  
>> +	/* The first req should be at least ETH_HLEN size or the packet will be
>> +	 * dropped by netback.
>> +	 */
>> +	if (unlikely(PAGE_SIZE - offset < ETH_HLEN)) {
>> +		nskb = skb_copy(skb, GFP_ATOMIC);
>> +		if (!nskb)
>> +			goto drop;
>> +		dev_kfree_skb_any(skb);
>> +		skb = nskb;
>> +		page = virt_to_page(skb->data);
>> +		offset = offset_in_page(skb->data);
>> +	}
>> +
>>  	spin_lock_irqsave(&queue->tx_lock, flags);
>
> I think you also have to recalculate 'len' in this case too, as
> skb_headlen() will definitely be different for nskb.
>
> In fact, I can't see how this code can work properly without that fix.

Thank you for your feedback David,

in my testing (even when I tried doing skb_copy() for all skbs
unconditionally) skb_headlen(nskb) always equals 'len' so I was under an
impression that both 'skb->len' and 'skb->data_len' remain the same when
we do skb_copy(). However, in case you think there are cases when
headlen changes, I see no problem with re-calculating 'len' as it won't
bring any significant performace penalty compared to the already added
skb_copy().

I'll send 'v2'.

-- 
  Vitaly
