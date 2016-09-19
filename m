From: David Vrabel <david.vrabel@citrix.com>
Subject: Re: [PATCH net-next RESEND] xen-netfront: avoid packet loss when
 ethernet header crosses page boundary
Date: Mon, 19 Sep 2016 11:23:53 +0100
Message-ID: <57DFBCB9.1090500@citrix.com>
References: <1474023554-24520-1-git-send-email-vkuznets@redhat.com>
 <20160918.222607.1930094684278444086.davem@davemloft.net>
 <87mvj4xk8i.fsf@vitty.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <ptalbert@redhat.com>, <boris.ostrovsky@oracle.com>,
        <jgross@suse.com>, <xen-devel@lists.xenproject.org>
To: Vitaly Kuznetsov <vkuznets@redhat.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:50746 "EHLO SMTP.CITRIX.COM"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S935254AbcISKYE (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 19 Sep 2016 06:24:04 -0400
In-Reply-To: <87mvj4xk8i.fsf@vitty.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 19/09/16 11:22, Vitaly Kuznetsov wrote:
> David Miller <davem@davemloft.net> writes:
> 
>> From: Vitaly Kuznetsov <vkuznets@redhat.com>
>> Date: Fri, 16 Sep 2016 12:59:14 +0200
>>
>>> @@ -595,6 +596,19 @@ static int xennet_start_xmit(struct sk_buff *skb, struct net_device *dev)
>>>  	offset = offset_in_page(skb->data);
>>>  	len = skb_headlen(skb);
>>>  
>>> +	/* The first req should be at least ETH_HLEN size or the packet will be
>>> +	 * dropped by netback.
>>> +	 */
>>> +	if (unlikely(PAGE_SIZE - offset < ETH_HLEN)) {
>>> +		nskb = skb_copy(skb, GFP_ATOMIC);
>>> +		if (!nskb)
>>> +			goto drop;
>>> +		dev_kfree_skb_any(skb);
>>> +		skb = nskb;
>>> +		page = virt_to_page(skb->data);
>>> +		offset = offset_in_page(skb->data);
>>> +	}
>>> +
>>>  	spin_lock_irqsave(&queue->tx_lock, flags);
>>
>> I think you also have to recalculate 'len' in this case too, as
>> skb_headlen() will definitely be different for nskb.
>>
>> In fact, I can't see how this code can work properly without that fix.
> 
> Thank you for your feedback David,
> 
> in my testing (even when I tried doing skb_copy() for all skbs
> unconditionally) skb_headlen(nskb) always equals 'len' so I was under an
> impression that both 'skb->len' and 'skb->data_len' remain the same when
> we do skb_copy(). However, in case you think there are cases when
> headlen changes, I see no problem with re-calculating 'len' as it won't
> bring any significant performace penalty compared to the already added
> skb_copy().

I think you can move the len = skb_headlen(skb) after the if, no need to
recalculate it.

David
