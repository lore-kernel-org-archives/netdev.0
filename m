From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] Renesas Ethernet AVB driver
Date: Wed, 22 Apr 2015 11:36:54 -0400 (EDT)
Message-ID: <20150422.113654.1169277303695917496.davem@davemloft.net>
References: <552C4554.2070608@gmail.com>
	<552D8898.3060905@cogentembedded.com>
	<SIXPR06MB03142A49C392C39922DC2BDA3EE0@SIXPR06MB031.apcprd06.prod.outlook.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sergei.shtylyov@cogentembedded.com, f.fainelli@gmail.com,
	robh+dt@kernel.org, pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, devicetree@vger.kernel.org,
	galak@codeaurora.org, netdev@vger.kernel.org,
	richardcochran@gmail.com, linux-sh@vger.kernel.org,
	masaru.nagai.vx@renesas.com
To: mitsuhiro.kimura.kc@renesas.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33251 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964995AbbDVPhB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Apr 2015 11:37:01 -0400
In-Reply-To: <SIXPR06MB03142A49C392C39922DC2BDA3EE0@SIXPR06MB031.apcprd06.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: MITSUHIRO KIMURA <mitsuhiro.kimura.kc@renesas.com>
Date: Wed, 22 Apr 2015 05:04:13 +0000

> Hello Sergei.
> 
>  (2015/04/15 6:37:28), Sergei Shtylyov wrote:
>> >> +		if (!ravb_tx_free(ndev, q)) {
>> >> +			netif_warn(priv, tx_queued, ndev, "TX FD exhausted.\n");
>> >> +			netif_stop_queue(ndev);
>> >> +			spin_unlock_irqrestore(&priv->lock, flags);
>> >> +			return NETDEV_TX_BUSY;
>> >> +		}
>> >> +	}
>> >> +	entry = priv->cur_tx[q] % priv->num_tx_ring[q];
>> >> +	priv->cur_tx[q]++;
>> >> +	spin_unlock_irqrestore(&priv->lock, flags);
>> >> +
>> >> +	if (skb_put_padto(skb, ETH_ZLEN))
>> >> +		return NETDEV_TX_OK;
>> >> +
>> >> +	priv->tx_skb[q][entry] = skb;
>> >> +	buffer = PTR_ALIGN(priv->tx_buffers[q][entry], RAVB_ALIGN);
>> >> +	memcpy(buffer, skb->data, skb->len);
>> 
>> > ~1500 bytes memcpy(), not good...
>> 
>>     I'm looking in the manual and not finding the hard requirement to have the
>> buffer address aligned to 128 bytes (RAVB_ALIGN), sigh... Kimura-san?
> 
> There are the hardware requirement that the frame data must be aligned with
> a 32-bit boundary in the URAM, see section 45A.3.3.1 Data Representation
> in the manual.
> I think that the original skb->data is almost aligned with 2 bytes boundary
> by NET_IP_ALING, so we copied original skb->data to the local aligned buffer.
> 
> In addition, see section 45A.3.3.12 Tips for Optimizing Performance in Handling
> Descriptors, it mentioned that frame data is accessed in blocks up to 128 bytes
> and the number of 128 byte borders (addresses H'xxx00 and H'xxx80) and frame data
> inside should be minimized.
> So we set RAVB_ALIGN to 128 bytes.

There is no way that copying is going to be faster than finding an adequate way
to transmit directly out of the SKB memory.

In this day and age there is simply no excuse for something like this, you will
have to find a way.
