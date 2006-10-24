From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/5] netpoll: use sk_buff_head for txq
Date: Mon, 23 Oct 2006 23:03:50 -0700 (PDT)
Message-ID: <20061023.230350.05157566.davem@davemloft.net>
References: <20061020153027.3bed8c86@dxpl.pdx.osdl.net>
	<20061022.204220.78710782.davem@davemloft.net>
	<20061023120253.5dd146d2@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:16270
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1752080AbWJXGD5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Oct 2006 02:03:57 -0400
To: shemminger@osdl.org
In-Reply-To: <20061023120253.5dd146d2@dxpl.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@osdl.org>
Date: Mon, 23 Oct 2006 12:02:53 -0700

> +	spin_lock_irqsave(&netpoll_txq.lock, flags);
> +	for (skb = (struct sk_buff *)netpoll_txq.next;
> +	     skb != (struct sk_buff *)&netpoll_txq; skb = next) {
> +		next = skb->next;
> +		if (skb->dev == dev) {
> +			skb_unlink(skb, &netpoll_txq);
> +			kfree_skb(skb);
> +		}
>  	}
> +	spin_unlock_irqrestore(&netpoll_txq.lock, flags);

IRQ's are disabled, I think we can't call kfree_skb() in such a
context.

That's why zap_completion_queue() has all of these funny
skb->destructor checks and such, all of this stuff potentially runs in
IRQ context.
