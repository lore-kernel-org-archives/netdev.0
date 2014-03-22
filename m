From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 3/3] net: hisilicon: new hip04 ethernet driver
Date: Sat, 22 Mar 2014 09:08:18 +0100
Message-ID: <4830403.iGU9jDN0hr@wuerfel>
References: <1395414570-25515-1-git-send-email-zhangfei.gao@linaro.org> <4230433.d0bAGX3bJV@wuerfel> <532CE4EB.6010305@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: "David S. Miller" <davem@davemloft.net>, linux@arm.linux.org.uk,
	f.fainelli@gmail.com, mark.rutland@arm.com,
	sergei.shtylyov@cogentembedded.com,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	devicetree@vger.kernel.org
To: zhangfei <zhangfei.gao@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.24]:59281 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750795AbaCVIIh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Mar 2014 04:08:37 -0400
In-Reply-To: <532CE4EB.6010305@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Saturday 22 March 2014 09:18:35 zhangfei wrote:
> >> +static void hip04_tx_reclaim(struct net_device *ndev, bool force)
> >> +{
> >> +	struct hip04_priv *priv = netdev_priv(ndev);
> >> +	unsigned tx_head = priv->tx_head;
> >> +	unsigned tx_tail = priv->tx_tail;
> >> +	struct tx_desc *desc = &priv->tx_desc[priv->tx_tail];
> >> +
> >> +	while (tx_tail != tx_head) {
> >> +		if (desc->send_addr != 0) {
> >> +			if (force)
> >> +				desc->send_addr = 0;
> >> +			else
> >> +				break;
> >> +		}
> >> +		if (priv->tx_phys[tx_tail]) {
> >> +			dma_unmap_single(&ndev->dev, priv->tx_phys[tx_tail],
> >> +				priv->tx_skb[tx_tail]->len, DMA_TO_DEVICE);
> >> +			priv->tx_phys[tx_tail] = 0;
> >> +		}
> >> +		dev_kfree_skb_irq(priv->tx_skb[tx_tail]);
> >> +		priv->tx_skb[tx_tail] = NULL;
> >> +		tx_tail = TX_NEXT(tx_tail);
> >> +		priv->tx_count--;
> >> +	}
> >> +	priv->tx_tail = tx_tail;
> >> +}
> >
> > You call this function from start_xmit(), which may be too early, causing the
> > dma_unmap_single() and dev_kfree_skb_irq() functions to be called while the
> > device is still accessing the data. This is bad.
> 
> There is a protection.
> Only after xmit done, desc->send_addr = 0, which is cleared by hardware.

Ok, I see.

> > You have to ensure that you only ever clean up tx buffers that have been
> > successfully transmitted. Also, you should use an interrupt to notify you
> > of this in case there is no further xmit packet. Otherwise you may have
> > a user space program waiting indefinitely for a single packet to get sent
> > on a socket.
> >
> > It's ok to also call the cleanup from start_xmit, but calling it from the
> > poll() function or another appropriate place is required.
> 
> There is no transmit done interrupt, so relying on every xmit to reclaim 
> finished buffer.
> I thought it would be enough, since there are TX_DESC_NUM descs.
> It is a good idea also put reclaim in poll, then will add spin lock etc.

It may be simpler to call napi_schedule() when you want to do tx descriptor
cleanup and have the function always be called in one place. If you do this
carefully, you can probably avoid most of the locking.

> >> +	priv->id = of_alias_get_id(node, "ethernet");
> >> +	if (priv->id < 0) {
> >> +		dev_warn(d, "no ethernet alias\n");
> >> +		ret = -EINVAL;
> >> +		goto init_fail;
> >> +	}
> >
> > Apparently you try to rely on the alias to refer to a specific piece
> > of hardware, which is not correct. The alias is meant to be selectable
> > to match e.g. the numbering written on the external connector, which
> > is totally independent of the internal hardware.
> 
> Thanks for clarifying alisa.
> The id will be used for start channel in ppe, RX_DESC_NUM * priv->id;
> Is it suitable directly use id in the dts, or other name such as start-chan?

Yes, I think it's best to just pass the id the same way as the channel
number.

	Arnd
