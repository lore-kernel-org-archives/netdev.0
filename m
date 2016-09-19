From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next RESEND] xen-netfront: avoid packet loss when
 ethernet header crosses page boundary
Date: Sun, 18 Sep 2016 22:26:07 -0400 (EDT)
Message-ID: <20160918.222607.1930094684278444086.davem@davemloft.net>
References: <1474023554-24520-1-git-send-email-vkuznets@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        ptalbert@redhat.com, boris.ostrovsky@oracle.com,
        david.vrabel@citrix.com, jgross@suse.com,
        xen-devel@lists.xenproject.org
To: vkuznets@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1474023554-24520-1-git-send-email-vkuznets@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vitaly Kuznetsov <vkuznets@redhat.com>
Date: Fri, 16 Sep 2016 12:59:14 +0200

> @@ -595,6 +596,19 @@ static int xennet_start_xmit(struct sk_buff *skb, struct net_device *dev)
>  	offset = offset_in_page(skb->data);
>  	len = skb_headlen(skb);
>  
> +	/* The first req should be at least ETH_HLEN size or the packet will be
> +	 * dropped by netback.
> +	 */
> +	if (unlikely(PAGE_SIZE - offset < ETH_HLEN)) {
> +		nskb = skb_copy(skb, GFP_ATOMIC);
> +		if (!nskb)
> +			goto drop;
> +		dev_kfree_skb_any(skb);
> +		skb = nskb;
> +		page = virt_to_page(skb->data);
> +		offset = offset_in_page(skb->data);
> +	}
> +
>  	spin_lock_irqsave(&queue->tx_lock, flags);

I think you also have to recalculate 'len' in this case too, as
skb_headlen() will definitely be different for nskb.

In fact, I can't see how this code can work properly without that fix.
