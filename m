From: Nelson Chang <nelson.chang@mediatek.com>
Subject: RE: [PATCH net-next 2/3] net: ethernet: mediatek: add ethtool
 functions to configure RX flows of HW LRO
Date: Wed, 14 Sep 2016 13:22:39 +0800
Message-ID: <1473830559.25065.10.camel@mtksdaap41>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: <nbd@openwrt.org>, <netdev@vger.kernel.org>,
        <linux-mediatek@lists.infradead.org>, <nelsonch.tw@gmail.com>
To: <f.fainelli@gmail.com>, <john@phrozen.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw02.mediatek.com ([210.61.82.184]:17353 "EHLO
        mailgw02.mediatek.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752470AbcINFWn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Sep 2016 01:22:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(resend)

Thanks Florian for the review!
I will add ndo_fix_features hook in v2 to prevent the case that a user
wants to turn off NETIF_F_LRO but RX flow is programmed.
If any programmed RX flow exists, NETIF_F_LRO cannot be turned off.

-----Original Message-----
From: Florian Fainelli [mailto:f.fainelli@gmail.com]
Sent: Wednesday, September 14, 2016 2:27 AM
To: Nelson Chang (張家祥); john@phrozen.org; davem@davemloft.net
Cc: nbd@openwrt.org; netdev@vger.kernel.org;
linux-mediatek@lists.infradead.org; nelsonch.tw@gmail.com
Subject: Re: [PATCH net-next 2/3] net: ethernet: mediatek: add ethtool
functions to configure RX flows of HW LRO

On 09/13/2016 06:54 AM, Nelson Chang wrote:
> The codes add ethtool functions to set RX flows for HW LRO. Because 
> the HW LRO hardware can only recognize the destination IP of TCP/IP
RX 
> flows, the ethtool command to add HW LRO flow is as below:
> ethtool -N [devname] flow-type tcp4 dst-ip [ip_addr] loc [0~1]
> 
> Otherwise, cause the hardware can set total four destination IPs,
each 
> GMAC (GMAC1/GMAC2) can set two IPs separately at most.
> 
> Signed-off-by: Nelson Chang <nelson.chang@mediatek.com>
> ---

> +
> +static int mtk_set_features(struct net_device *dev, netdev_features_t
> +features) {
> +	int err = 0;
> +
> +	if (!((dev->features ^ features) & NETIF_F_LRO))
> +		return 0;
> +
> +	if (!(features & NETIF_F_LRO))
> +		mtk_hwlro_netdev_disable(dev);

you may want to implement a fix_features ndo operations which makes sure
that NETIF_F_LRO is turned on in case a RX flow is programmed,
otherwise, it may be confusing to the user that a flow was programmed,
but no offload is happening.
