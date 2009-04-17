From: Haavard Skinnemoen <haavard.skinnemoen@atmel.com>
Subject: Re: [PATCH] macb: Kconfig net device compat fixup
Date: Fri, 17 Apr 2009 09:46:02 +0200
Message-ID: <20090417094602.51ec1b21@hskinnemoen-d830>
References: <1239953045.2837.58.camel@linux-51e8.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Ferre, Nicolas" <Nicolas.FERRE@atmel.com>, jgarzik@pobox.com,
	netdev@vger.kernel.org, linux-kernel <linux-kernel@vger.kernel.org>
To: Ben Nizette <bn@niasdigital.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.atmel.no ([80.232.32.139]:55652 "EHLO relay.atmel.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754634AbZDQHqk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Apr 2009 03:46:40 -0400
In-Reply-To: <1239953045.2837.58.camel@linux-51e8.site>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Nizette wrote:
> 
> The macb driver hasn't been updated to use net_device_ops and as such
> should select COMPAT_NET_DEV_OPS to avoid build breakage.

Hmmm...no other drivers do that...

> Of course really macb should be updated but in the mean time, this at
> least avoid randconfig problems.

It doesn't look all that difficult. Could you try the below instead?

Haavard

=============[cut here]=====================
From: Haavard Skinnemoen <haavard.skinnemoen@atmel.com>
Date: Fri, 17 Apr 2009 09:43:14 +0200
Subject: [PATCH] macb: convert to net_device_ops

Signed-off-by: Haavard Skinnemoen <haavard.skinnemoen@atmel.com>
---
 drivers/net/macb.c |   19 +++++++++++++------
 1 files changed, 13 insertions(+), 6 deletions(-)

diff --git a/drivers/net/macb.c b/drivers/net/macb.c
index d473540..5656e02 100644
--- a/drivers/net/macb.c
+++ b/drivers/net/macb.c
@@ -1084,6 +1084,18 @@ static int macb_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 	return phy_mii_ioctl(phydev, if_mii(rq), cmd);
 }
 
+static const struct net_device_ops macb_netdev_ops = {
+	.ndo_open		= macb_open,
+	.ndo_stop		= macb_close,
+	.ndo_start_xmit		= macb_start_xmit,
+	.ndo_get_stats		= macb_get_stats,
+	.ndo_set_multicast_list	= macb_set_rx_mode,
+	.ndo_do_ioctl		= macb_ioctl,
+	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_change_mtu		= eth_change_mtu,
+	.ndo_set_mac_address	= eth_mac_addr,
+};
+
 static int __init macb_probe(struct platform_device *pdev)
 {
 	struct eth_platform_data *pdata;
@@ -1159,12 +1171,7 @@ static int __init macb_probe(struct platform_device *pdev)
 		goto err_out_iounmap;
 	}
 
-	dev->open = macb_open;
-	dev->stop = macb_close;
-	dev->hard_start_xmit = macb_start_xmit;
-	dev->get_stats = macb_get_stats;
-	dev->set_multicast_list = macb_set_rx_mode;
-	dev->do_ioctl = macb_ioctl;
+	dev->netdev_ops = &macb_netdev_ops;
 	netif_napi_add(dev, &bp->napi, macb_poll, 64);
 	dev->ethtool_ops = &macb_ethtool_ops;
 
-- 
1.6.0.4

