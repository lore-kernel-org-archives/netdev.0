From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 1/2] Renesas Ethernet AVB driver proper
Date: Tue, 19 May 2015 14:30:54 -0400 (EDT)
Message-ID: <20150519.143054.852529603260516108.davem@davemloft.net>
References: <1563041.H01PyFE9Xk@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: robh+dt@kernel.org, pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, devicetree@vger.kernel.org,
	galak@codeaurora.org, netdev@vger.kernel.org,
	richardcochran@gmail.com, linux-sh@vger.kernel.org,
	mitsuhiro.kimura.kc@renesas.com
To: sergei.shtylyov@cogentembedded.com
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <1563041.H01PyFE9Xk@wasted.cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Sun, 17 May 2015 23:52:42 +0300

> +/* Packet transmit function for Ethernet AVB */
> +static netdev_tx_t ravb_start_xmit(struct sk_buff *skb, struct net_device *ndev)
> +{
 ...
> +	spin_lock_irqsave(&priv->lock, flags);
> +	if (priv->cur_tx[q] - priv->dirty_tx[q] > priv->num_tx_ring[q]) {
> +		if (!ravb_tx_free(ndev, q)) {
> +			netif_warn(priv, tx_queued, ndev, "TX FD exhausted.\n");
> +			netif_stop_queue(ndev);
> +			spin_unlock_irqrestore(&priv->lock, flags);
> +			return NETDEV_TX_BUSY;
> +		}

This is not an acceptable way to manage your transmit queue state.

When your transmit queue fills up and you cannot accept the next
arbitrary packet into your TX queue, you must stop the queue
before returning from this function.

Therefore, only error conditions should cause NETDEV_TX_BUSY to
ever be returned from this routine.

I know what argument you are going to make to me in response to this
email.  You are going to tell me that you have these two queues, one
for tstamp packets and one for the rest, and therefore that model of
TX queue management can't be made to work.

That's not acceptable.

Instead, you should classify packets to the different queues using
->ndo_select_queue() and therefore have multiple TX queues, which you
can management the "fullness" of independantly.
