From: "George Spelvin" <linux@horizon.com>
Subject: Re: [RFC] tulip: Support for byte queue limits
Date: 12 Jul 2013 14:01:16 -0400
Message-ID: <20130712180116.21176.qmail@science.horizon.com>
References: <CAP6odjhsL8QPKwurP_H88M3kAoBW-z_jGHtEhL0Tj7AfZNutHA@mail.gmail.com>
Cc: eric.dumazet@gmail.com, grundler@parisc-linux.org,
	netdev@vger.kernel.org
To: grantgrundler@gmail.com, linux@horizon.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from science.horizon.com ([71.41.210.146]:25056 "HELO
	science.horizon.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S965004Ab3GLSBR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Jul 2013 14:01:17 -0400
In-Reply-To: <CAP6odjhsL8QPKwurP_H88M3kAoBW-z_jGHtEhL0Tj7AfZNutHA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Hi George,
> While you are right that functionally it doesn't matter, my preference
> would be to have nothing between the wmb() and iowrite() that kicks
> off the TX. This marginally helps kick off the TX process consistently
> slightly sooner. On modern HW, probably irrelevant, but not on the HW
> these chips are used on.

I'll revise it.  It just made sense to me to put it next to the other
bookkeeping line of tp->cur_tx++.  Should I move them both below the
iowrite()?  As in:

--- a/drivers/net/ethernet/dec/tulip/tulip_core.c
+++ b/drivers/net/ethernet/dec/tulip/tulip_core.c
@@ -702,11 +702,11 @@ tulip_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	tp->tx_ring[entry].status = cpu_to_le32(DescOwned);
 	wmb();
 
-	tp->cur_tx++;
-
 	/* Trigger an immediate transmit demand. */
 	iowrite32(0, tp->base_addr + CSR1);
 
+	tp->cur_tx++;
+	netdev_sent_queue(dev, skb->len);
 	spin_unlock_irqrestore(&tp->lock, flags);
 
 	return NETDEV_TX_OK;

> Lastly, given I haven't powered up a system in two years which has
> tulip, any one want to take over maintainer for tulip driver?
> It's basically obsolete with a few rare patches like this one coming in.

I'm not up to it myself, sorry.
