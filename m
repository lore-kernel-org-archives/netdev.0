From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH 3/3] gianfar: fix endianness for hardware timestamp
Date: Mon, 22 Feb 2016 09:48:03 +0100
Message-ID: <20160222084801.GC2138@netboy>
References: <1456123773-1016-1-git-send-email-yangbo.lu@nxp.com>
 <1456123773-1016-4-git-send-email-yangbo.lu@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Claudiu Manoil <claudiu.manoil@freescale.com>
To: Yangbo Lu <yangbo.lu@nxp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f44.google.com ([74.125.82.44]:37225 "EHLO
	mail-wm0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751797AbcBVIsH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Feb 2016 03:48:07 -0500
Received: by mail-wm0-f44.google.com with SMTP id g62so152705635wme.0
        for <netdev@vger.kernel.org>; Mon, 22 Feb 2016 00:48:07 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1456123773-1016-4-git-send-email-yangbo.lu@nxp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 22, 2016 at 02:49:33PM +0800, Yangbo Lu wrote:
> @@ -2708,6 +2708,7 @@ static void gfar_clean_tx_ring(struct gfar_priv_tx_q *tx_queue)
>  			struct skb_shared_hwtstamps shhwtstamps;
>  			u64 *ns = (u64 *)(((uintptr_t)skb->data + 0x10) &
>  					  ~0x7UL);
> +			*ns = be64_to_cpu(*ns);
>  
>  			memset(&shhwtstamps, 0, sizeof(shhwtstamps));
>  			shhwtstamps.hwtstamp = ns_to_ktime(*ns);

There is no point in modifying the buffer data in place.

Instead, do this:

			memset(&shhwtstamps, 0, sizeof(shhwtstamps));
			shhwtstamps.hwtstamp = ns_to_ktime(be64_to_cpu(*ns));

or this:

			u64 ns, *ptr = (u64 *)(((uintptr_t)skb->data + 0x10) &
					       ~0x7UL);
			ns = be64_to_cpu(*ptr);

			memset(&shhwtstamps, 0, sizeof(shhwtstamps));
			shhwtstamps.hwtstamp = ns_to_ktime(ns);

> @@ -3037,6 +3038,7 @@ static void gfar_process_frame(struct net_device *ndev, struct sk_buff *skb)
>  	if (priv->hwts_rx_en) {
>  		struct skb_shared_hwtstamps *shhwtstamps = skb_hwtstamps(skb);
>  		u64 *ns = (u64 *) skb->data;
> +		*ns = be64_to_cpu(*ns);
>  
>  		memset(shhwtstamps, 0, sizeof(*shhwtstamps));
>  		shhwtstamps->hwtstamp = ns_to_ktime(*ns);

Same here.

Thanks,
Richard
