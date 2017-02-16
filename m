From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v7 2/2] qede: Add driver support for PTP
Date: Thu, 16 Feb 2017 04:23:34 -0800
Message-ID: <1487247814.1311.34.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1487147051-14350-1-git-send-email-Yuval.Mintz@cavium.com>
         <1487147051-14350-3-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        richardcochran@gmail.com, Sudarsana.Kalluru@cavium.com
To: Yuval Mintz <Yuval.Mintz@cavium.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:36195 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754681AbdBPMXf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Feb 2017 07:23:35 -0500
Received: by mail-pg0-f68.google.com with SMTP id 13so960867pgd.3
        for <netdev@vger.kernel.org>; Thu, 16 Feb 2017 04:23:35 -0800 (PST)
In-Reply-To: <1487147051-14350-3-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-02-15 at 10:24 +0200, Yuval Mintz wrote:
> From: Sudarsana Reddy Kalluru <Sudarsana.Kalluru@cavium.com>
> 
> This patch adds the driver support for,
>   - Registering the ptp clock functionality with the OS.
>   - Timestamping the Rx/Tx PTP packets.
>   - Ethtool callbacks related to PTP.



> +void qede_ptp_tx_ts(struct qede_dev *edev, struct sk_buff *skb)
> +{
> +	struct qede_ptp *ptp;
> +
> +	ptp = edev->ptp;
> +	if (!ptp)
> +		return;
> +
> +	if (unlikely(!(edev->flags & QEDE_TX_TIMESTAMPING_EN))) {
> +		DP_NOTICE(edev,
> +			  "Tx timestamping was not enabled, this packet will not be timestamped\n");
> +	} else if (unlikely(ptp->tx_skb)) {
> +		DP_NOTICE(edev,
> +			  "The device supports only a single outstanding packet to timestamp, this packet will not be timestamped\n");
> +	} else {
> +		skb_shinfo(skb)->tx_flags |= SKBTX_IN_PROGRESS;
> +		/* schedule check for Tx timestamp */
> +		ptp->tx_skb = skb_get(skb);
> +		schedule_work(&ptp->work);
> +	}
> +}


This is a multi queue device.

Therefore multiple cpus could call this function at the same time.

ptp->tx_skb needs some kind of SMP protection.



 
