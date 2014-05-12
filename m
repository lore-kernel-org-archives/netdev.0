From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next v4 2/2] net: systemport: pad packets to a
 minimum of 64 bytes
Date: Mon, 12 May 2014 12:45:32 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D0F7116C2@AcuExch.aculab.com>
References: <1399666599-19398-1-git-send-email-f.fainelli@gmail.com>
 <1399666599-19398-3-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>
To: 'Florian Fainelli' <f.fainelli@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:59965 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752026AbaELMpr convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 May 2014 08:45:47 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 03437-05 for <netdev@vger.kernel.org>;
 Mon, 12 May 2014 13:45:35 +0100 (BST)
In-Reply-To: <1399666599-19398-3-git-send-email-f.fainelli@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli
> The switch fabric which is used behind the Broadcom SYSTEMPORT Ethernet
> controller will discard any incoming packet that is not 64 bytes or
> more. Since the UniMAC hardware transmits up to the specified size, just
> make sure that we properly pad the end of the packet with zeroes using
> skb_padto() and set a minimum packet length of 64 bytes.

Surely the above should just be:
    "Pad transmit packets to the minimum length (64 bytes)."
All ethernet packets should be padded to 64 bytes (including the CRC).

...
> @@ -848,10 +849,22 @@ static netdev_tx_t bcm_sysport_xmit(struct sk_buff *skb,
>  		}
>  	}
> 
> -	mapping = dma_map_single(kdev, skb->data, skb->len, DMA_TO_DEVICE);
> +	/* The Ethernet switch we are interfaced with needs packets to be at
> +	 * least 64 bytes otherwise they will be discarded when they enter
> +	 * the switch port logic. The UniMAC hardware transmits up to the
> +	 * specified length.
> +	 */
> +	if (skb_padto(skb, 64)) {

Shouldn't that be 60?
I presume there is an appropriate constant defined for it as well.

> +		ret = NETDEV_TX_OK;
> +		goto out;
> +	}
> +
> +	skb_len = skb->len < 64 ? 64 : skb->len;
> +
> +	mapping = dma_map_single(kdev, skb->data, skb_len, DMA_TO_DEVICE);
>  	if (dma_mapping_error(kdev, mapping)) {
>  		netif_err(priv, tx_err, dev, "DMA map failed at %p (len=%d)\n",
> -				skb->data, skb->len);
> +				skb->data, skb_len);
>  		ret = NETDEV_TX_OK;
>  		goto out;
>  	}
...

	david
