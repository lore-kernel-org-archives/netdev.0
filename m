From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next] drivers/net/ethernet/micrel/ks8851_mll:
 Implement basic statistics
Date: Tue, 29 Jan 2013 10:42:19 -0800
Message-ID: <1359484939.15135.19.camel@joe-AO722>
References: <FD9AD8C5375B924CABC56D982DB3A802079D382B@EXMB1.micrel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Doong, Ping" <Ping.Doong@Micrel.Com>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>
To: "Choi, David" <David.Choi@Micrel.Com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:49084 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752032Ab3A2SmV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Jan 2013 13:42:21 -0500
In-Reply-To: <FD9AD8C5375B924CABC56D982DB3A802079D382B@EXMB1.micrel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-01-29 at 18:24 +0000, Choi, David wrote:
> From: David J. Choi <david.choi@micrel.com>

Hello David.

When you resubmit a patch, please use a different
header for each resubmission.

This email subject line should have been

	[PATCH V3] ks8851_mll: Implement basic statistics

Also, don't use the complete path in the subject.
Read Documentation/SubmittingPatches Section 1, #15.

Please use git format-patch and git-send-email.

Please use a changelog describing what changes
you've made for each version.  The changelog is
generally placed after the --- separator that
git format-email produces.

More comments interspersed.

> +++ net-next/drivers/net/ethernet/micrel/ks8851_mll.c	2013-01-29 10:06:09.000000000 -0800
> @@ -793,19 +793,35 @@ static void ks_rcv(struct ks_net *ks, st
>  	frame_hdr = ks->frame_head_info;
>  	while (ks->frame_cnt--) {
>  		skb = netdev_alloc_skb(netdev, frame_hdr->len + 16);
> -		if (likely(skb && (frame_hdr->sts & RXFSHR_RXFV) &&
> -			(frame_hdr->len < RX_BUF_SIZE) && frame_hdr->len)) {
> +		if (unlikely(!skb)) {
> +			/* discard the packet from the device */
> +			ks_wrreg16(ks, KS_RXQCR, ks->rc_rxqcr | RXQCR_RRXEF);
> +			netdev->stats.rx_dropped++;
> +		} else if (likely((frame_hdr->sts & RXFSHR_RXFV) &&
> +				frame_hdr->len > 0 &&
> +				frame_hdr->len <= RX_BUF_SIZE)) {

OK, <= here

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
> -			if (skb)
> -				dev_kfree_skb_irq(skb);
> +			/* discard the packet from the device */
> +			ks_wrreg16(ks, KS_RXQCR, ks->rc_rxqcr | RXQCR_RRXEF);
> +			netdev->stats.rx_dropped++;
> +			if (frame_hdr->len >= RX_BUF_SIZE || !frame_hdr->len)

but >= here and !frame_hdr->len not frame_hdr-len == 0
Please be consistent.

> +				netdev->stats.rx_length_errors++;
> +			if (!(frame_hdr->sts & RXFSHR_RXFV))
> +				netdev->stats.rx_frame_errors++;
> +
> +			dev_kfree_skb_irq(skb);
>  		}
>  		frame_hdr++;
>  	}

It seems that a 0 length frame or an over length
frame is pretty unlikely and those should probably
be tested and accounted for before the
netdev_alloc_skb is done so that what seems an
unnecessary alloc/free is avoided.
