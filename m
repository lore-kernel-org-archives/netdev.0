From: "David Woodhouse" <dwmw2@infradead.org>
Subject: Re: [PATCH net-next 3/3] r8169: support IPv6
Date: Fri, 2 Oct 2015 08:41:49 -0000
Message-ID: <68ac55cb202df8b295c27d251ab8e6fe.squirrel@twosheds.infradead.org>
References: <1394712342-15778-10-Taiwan-albertk@realtek.com>
    <1394712342-15778-13-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain;charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: romieu@fr.zoreil.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, nic_swsd@realtek.com
To: "Hayes Wang" <hayeswang@realtek.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394712342-15778-13-Taiwan-albertk@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> Support the IPv6 hw checksum for RTL8111C and later chips. Note
> that the hw has the limitation for the transport offset. The
> checksum must be calculated by sw, when the transport offset is
> out of the range which the hw accepts.


It would be better to implement this check in a .ndo_features_check
method, just clearing the appropriate CSUM/TSO features for the skbs for
which the hardware cannot cope. That way the stack fixes them up for you.


> +	if (skb_shinfo(skb)->gso_size) {
> +		netdev_features_t features = tp->dev->features;
> +		struct sk_buff *segs, *nskb;
> +
> +		features &= ~(NETIF_F_SG | NETIF_F_IPV6_CSUM | NETIF_F_TSO6);
> +		segs = skb_gso_segment(skb, features);
> +		if (IS_ERR(segs) || !segs)
> +			goto drop;
> +
> +		do {
> +			nskb = segs;
> +			segs = segs->next;
> +			nskb->next = NULL;
> +			rtl8169_start_xmit(nskb, tp->dev);
> +		} while (segs);
> +
> +		dev_kfree_skb(skb);

This loop in particular makes no attempt to avoid exceeding the available
space in your descriptor ring, and can drop packets and trigger the
warning at the start of your hard_start_xmit function.

-- 
dwmw2
