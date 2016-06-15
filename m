From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH net-next 15/17] sfc: Disable VLAN filtering by default if not
 strictly required
Date: Wed, 15 Jun 2016 17:51:36 +0100
Message-ID: <8895ce4a-8d2d-e3b1-11b6-e7c9d042cd50@solarflare.com>
References: <4daf4ef4-7a8b-4a16-c640-04275298abad@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: <linux-net-drivers@solarflare.com>, <netdev@vger.kernel.org>,
	<davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo02.seg.att.com ([209.65.160.78]:5396 "EHLO
	nbfkord-smmo02.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751269AbcFOQvz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jun 2016 12:51:55 -0400
In-Reply-To: <4daf4ef4-7a8b-4a16-c640-04275298abad@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Rybchenko <Andrew.Rybchenko@oktetlabs.ru>

If should be done after net_dev->hw_features initialization, to keep the
feature there to be able to enable it later using ethtool.

VLAN filtering is enforced and fixed if vPort requires usage of VLAN
filters to receive tagged traffic.

Signed-off-by: Edward Cree <ecree@solarflare.com>
---
 drivers/net/ethernet/sfc/efx.c | 10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index 130ee17..14b821b 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -3202,8 +3202,16 @@ static int efx_pci_probe(struct pci_dev *pci_dev,
 	net_dev->vlan_features |= (NETIF_F_HW_CSUM | NETIF_F_SG |
 				   NETIF_F_HIGHDMA | NETIF_F_ALL_TSO |
 				   NETIF_F_RXCSUM);
-	net_dev->features |= efx->fixed_features;
+
 	net_dev->hw_features = net_dev->features & ~efx->fixed_features;
+
+	/* Disable VLAN filtering by default.  It may be enforced if
+	 * the feature is fixed (i.e. VLAN filters are required to
+	 * receive VLAN tagged packets due to vPort restrictions).
+	 */
+	net_dev->features &= ~NETIF_F_HW_VLAN_CTAG_FILTER;
+	net_dev->features |= efx->fixed_features;
+
 	pci_set_drvdata(pci_dev, efx);
 	SET_NETDEV_DEV(net_dev, &pci_dev->dev);
 	rc = efx_init_struct(efx, pci_dev, net_dev);
