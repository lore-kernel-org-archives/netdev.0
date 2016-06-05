From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 01/12] net: mediatek: fix DQL support
Date: Sun, 05 Jun 2016 00:32:42 -0700 (PDT)
Message-ID: <20160605.003242.796780762112643713.davem@davemloft.net>
References: <1465108385-38286-1-git-send-email-john@phrozen.org>
	<1465108385-38286-2-git-send-email-john@phrozen.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nbd@nbd.name, keyhaede@gmail.com, netdev@vger.kernel.org,
	linux-mediatek@lists.infradead.org, linux-kernel@vger.kernel.org
To: john@phrozen.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1465108385-38286-2-git-send-email-john@phrozen.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: John Crispin <john@phrozen.org>
Date: Sun,  5 Jun 2016 08:32:54 +0200

> @@ -625,7 +625,16 @@ static int mtk_tx_map(struct sk_buff *skb, struct net_device *dev,
>  	WRITE_ONCE(itxd->txd3, (TX_DMA_SWC | TX_DMA_PLEN0(skb_headlen(skb)) |
>  				(!nr_frags * TX_DMA_LS0)));
>  
> -	netdev_sent_queue(dev, skb->len);
> +	/* we have a single DMA ring so BQL needs to be updated for all devices
> +	 * sitting on this ring
> +	 */
> +	for (i = 0; i < MTK_MAC_COUNT; i++) {
> +		if (!eth->netdev[i])
> +			continue;
> +
> +		netdev_sent_queue(eth->netdev[i], skb->len);
> +	}
> +
>  	skb_tx_timestamp(skb);

Sorry, this is very far from working.

You cannot asynchronously touch the DQL state of another netdevice.

You have to hold the TX lock of a queue while changing it's DQL state,
otherwise you'll corrupt the state.

This "loop over all possible devices on this DMA ring" is pretty
expensive for the problem you're trying to solve.

You'll have to find another way to fix this bug, which BTW I'm not too
clear about.  The commit message doesn't explain sufficiently what the
actual problem is.  "not deterministic" doesn't give enough details.
