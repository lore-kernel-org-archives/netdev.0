From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 8/9] jme: Don't show UDP Checksum error if
 HW misjudged
Date: Sun, 13 Feb 2011 20:43:00 -0800 (PST)
Message-ID: <20110213.204300.186319004.davem@davemloft.net>
References: <1297657662-30289-1-git-send-email-cooldavid@cooldavid.org>
	<1297657662-30289-8-git-send-email-cooldavid@cooldavid.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, arieslee@jmicron.com,
	devinchiu@jmicron.com, ethanhsiao@jmicron.com
To: cooldavid@cooldavid.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42303
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754163Ab1BNEmY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Feb 2011 23:42:24 -0500
In-Reply-To: <1297657662-30289-8-git-send-email-cooldavid@cooldavid.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Guo-Fu Tseng" <cooldavid@cooldavid.org>
Date: Mon, 14 Feb 2011 12:27:41 +0800

> @@ -956,8 +956,27 @@ jme_disable_rx_engine(struct jme_adapter *jme)
>  	jme_mac_rxclk_off(jme);
>  }
>  
> +static u16
> +jme_udpsum(struct sk_buff *skb)
> +{
> +	u16 csum = 0xFFFFu;
> +
> +	if (skb->protocol != htons(ETH_P_IP))
> +		return csum;
> +	skb_set_network_header(skb, ETH_HLEN);
> +	if (ip_hdr(skb)->protocol != IPPROTO_UDP)
> +		return csum;
> +	skb_set_transport_header(skb,
> +			ETH_HLEN + (ip_hdr(skb)->ihl << 2));
> +	csum = udp_hdr(skb)->check;
> +	skb_reset_transport_header(skb);
> +	skb_reset_network_header(skb);
> +
> +	return csum;
> +}

You need to validate the packet length in all of these packet header
accesses, otherwise you're potentially looking at garbage.

