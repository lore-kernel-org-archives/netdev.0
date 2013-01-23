From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next] drivers/net/ethernet/micrel/ks8851_mll:
 Implement basic statistics
Date: Wed, 23 Jan 2013 11:09:54 -0800
Message-ID: <1358968194.2107.37.camel@joe-AO722>
References: <FD9AD8C5375B924CABC56D982DB3A802079D33CE@EXMB1.micrel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Doong, Ping" <Ping.Doong@Micrel.Com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>
To: "Choi, David" <David.Choi@Micrel.Com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:37591 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751729Ab3AWTJ6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Jan 2013 14:09:58 -0500
In-Reply-To: <FD9AD8C5375B924CABC56D982DB3A802079D33CE@EXMB1.micrel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-01-23 at 18:46 +0000, Choi, David wrote:
> +++ net-next/drivers/net/ethernet/micrel/ks8851_mll.c	2013-01-23 10:31:24.000000000 -0800
> @@ -793,17 +793,35 @@ static void ks_rcv(struct ks_net *ks, st
>  	frame_hdr = ks->frame_head_info;
>  	while (ks->frame_cnt--) {
>  		skb = netdev_alloc_skb(netdev, frame_hdr->len + 16);
> -		if (likely(skb && (frame_hdr->sts & RXFSHR_RXFV) &&
> +		if (unlikely(!skb)) {
> +			/* discard the packet from the device */
> +			ks_wrreg16(ks, KS_RXQCR, ks->rc_rxqcr | RXQCR_RRXEF);
> +			netdev->stats.rx_dropped++;
> +		}
> +
> +		else if (likely((frame_hdr->sts & RXFSHR_RXFV) &&

Couple of trivial comments:

it' be nicer if the close brace and else
was on the same line

		} else if (likely(...

>  			(frame_hdr->len < RX_BUF_SIZE) && frame_hdr->len)) {
>  			skb_reserve(skb, 2);
>  			/* read data block including CRC 4 bytes */
>  			ks_read_qmu(ks, (u16 *)skb->data, frame_hdr->len);
> -			skb_put(skb, frame_hdr->len);
> +
> +			/* exclude the size of CRC */
> +			skb_put(skb, frame_hdr->len - 4);
>  			skb->protocol = eth_type_trans(skb, netdev);
>  			netif_rx(skb);
> +			netdev->stats.rx_packets++;
> +
> +			/* crc field */
> +			netdev->stats.rx_bytes += frame_hdr->len - 4;
>  		} else {
> -			pr_err("%s: err:skb alloc\n", __func__);
> -			ks_wrreg16(ks, KS_RXQCR, (ks->rc_rxqcr | RXQCR_RRXEF));
> +			/* discard the packet from the device */
> +			ks_wrreg16(ks, KS_RXQCR, ks->rc_rxqcr | RXQCR_RRXEF);
> +			netdev->stats.rx_dropped++;
> +			if (frame_hdr->len >= RX_BUF_SIZE || !frame_hdr->len)
> +				netdev->stats.rx_length_errors++;
> +			if (!(frame_hdr->sts & RXFSHR_RXFV))
> +				netdev->stats.rx_frame_errors++;
> +
>  			if (skb)
>  				dev_kfree_skb_irq(skb);

You don't need to test skb here anymore.
