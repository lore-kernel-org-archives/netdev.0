From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6] sfc: Implement NETIF_F_LOOPBACK
Date: Fri, 06 May 2011 01:12:31 +0100
Message-ID: <1304640751.2857.34.camel@bwh-desktop>
References: <1304559011-15983-1-git-send-email-maheshb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com,
	Mahesh Bandewar <maheshb@google.com>,
	=?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:15788 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752611Ab1EFAMf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 May 2011 20:12:35 -0400
In-Reply-To: <1304559011-15983-1-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We already have comprehensive support for loopback testing, so pick
the nearest mode and run with it.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
David, this depends on Mahesh's patch to define NETIF_F_LOOPBACK
<http://patchwork.ozlabs.org/patch/94190/>.  Although you've marked that
as RFC, I think it is ready to apply.

Ben.

 drivers/net/sfc/efx.c |   24 ++++++++++++++++++++++--
 1 files changed, 22 insertions(+), 2 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index 38a55e9..b7bfb49 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -1884,6 +1884,25 @@ static int efx_set_features(struct net_device *net_dev, u32 data)
 	if (net_dev->features & ~data & NETIF_F_NTUPLE)
 		efx_filter_clear_rx(efx, EFX_FILTER_PRI_MANUAL);
 
+	/* Toggle loopback if required */
+	if ((net_dev->features ^ data) & NETIF_F_LOOPBACK) {
+		enum efx_loopback_mode old_mode;
+		int rc;
+
+		mutex_lock(&efx->mac_lock);
+		old_mode = efx->loopback_mode;
+		if (data & NETIF_F_LOOPBACK)
+			efx->loopback_mode = __ffs(efx->loopback_modes);
+		else
+			efx->loopback_mode = LOOPBACK_NONE;
+		rc = __efx_reconfigure_port(efx);
+		if (rc)
+			efx->loopback_mode = old_mode;
+		mutex_unlock(&efx->mac_lock);
+		if (rc)
+			return rc;
+	}
+
 	return 0;
 }
 
@@ -2472,8 +2491,9 @@ static int __devinit efx_pci_probe(struct pci_dev *pci_dev,
 	net_dev->vlan_features |= (NETIF_F_ALL_CSUM | NETIF_F_SG |
 				   NETIF_F_HIGHDMA | NETIF_F_ALL_TSO |
 				   NETIF_F_RXCSUM);
-	/* All offloads can be toggled */
-	net_dev->hw_features = net_dev->features & ~NETIF_F_HIGHDMA;
+	/* All offloads can be toggled, and so can loopback */
+	net_dev->hw_features = ((net_dev->features & ~NETIF_F_HIGHDMA) |
+				NETIF_F_LOOPBACK);
 	efx = netdev_priv(net_dev);
 	pci_set_drvdata(pci_dev, efx);
 	SET_NETDEV_DEV(net_dev, &pci_dev->dev);
-- 
1.7.4


-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

