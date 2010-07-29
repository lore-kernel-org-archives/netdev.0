From: Sriramakrishnan <srk@ti.com>
Subject: [PATCH 2/3] TI DaVinci EMAC: Fix asymmetric handling of packets in NAPI Poll function.
Date: Thu, 29 Jul 2010 18:03:59 +0530
Message-ID: <1280406840-27393-2-git-send-email-srk@ti.com>
References: <1280406840-27393-1-git-send-email-srk@ti.com>
Cc: nsekhar@ti.com, anantgole@ti.com, Sriramakrishnan <srk@ti.com>
To: netdev@vger.kernel.org,
	davinci-linux-open-source@linux.davincidsp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from bear.ext.ti.com ([192.94.94.41]:59874 "EHLO bear.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754186Ab0G2MeI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Jul 2010 08:34:08 -0400
Received: from dbdp31.itg.ti.com ([172.24.170.98])
	by bear.ext.ti.com (8.13.7/8.13.7) with ESMTP id o6TCY52r004605
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Thu, 29 Jul 2010 07:34:07 -0500
In-Reply-To: <1280406840-27393-1-git-send-email-srk@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The current implementation of NAPI poll function in the driver does not service
Rx packets, error condition even if a single Tx packet gets serviced in
the napi poll call. This behavior severely affects performance for specific use
cases. This patch modifies the poll function implementation to service tx/rx
packets in an identical manner.

Signed-off-by: Sriramakrishnan <srk@ti.com>
---
 drivers/net/davinci_emac.c |   21 ++++++++-------------
 1 files changed, 8 insertions(+), 13 deletions(-)

diff --git a/drivers/net/davinci_emac.c b/drivers/net/davinci_emac.c
index bc1b270..4ee9af6 100644
--- a/drivers/net/davinci_emac.c
+++ b/drivers/net/davinci_emac.c
@@ -2266,7 +2266,7 @@ static int emac_poll(struct napi_struct *napi, int budget)
 	struct net_device *ndev = priv->ndev;
 	struct device *emac_dev = &ndev->dev;
 	u32 status = 0;
-	u32 num_pkts = 0;
+	u32 num_tx_pkts = 0, num_rx_pkts = 0;
 
 	/* Check interrupt vectors and call packet processing */
 	status = emac_read(EMAC_MACINVECTOR);
@@ -2277,27 +2277,19 @@ static int emac_poll(struct napi_struct *napi, int budget)
 		mask = EMAC_DM646X_MAC_IN_VECTOR_TX_INT_VEC;
 
 	if (status & mask) {
-		num_pkts = emac_tx_bdproc(priv, EMAC_DEF_TX_CH,
+		num_tx_pkts = emac_tx_bdproc(priv, EMAC_DEF_TX_CH,
 					  EMAC_DEF_TX_MAX_SERVICE);
 	} /* TX processing */
 
-	if (num_pkts)
-		return budget;
-
 	mask = EMAC_DM644X_MAC_IN_VECTOR_RX_INT_VEC;
 
 	if (priv->version == EMAC_VERSION_2)
 		mask = EMAC_DM646X_MAC_IN_VECTOR_RX_INT_VEC;
 
 	if (status & mask) {
-		num_pkts = emac_rx_bdproc(priv, EMAC_DEF_RX_CH, budget);
+		num_rx_pkts = emac_rx_bdproc(priv, EMAC_DEF_RX_CH, budget);
 	} /* RX processing */
 
-	if (num_pkts < budget) {
-		napi_complete(napi);
-		emac_int_enable(priv);
-	}
-
 	mask = EMAC_DM644X_MAC_IN_VECTOR_HOST_INT;
 	if (priv->version == EMAC_VERSION_2)
 		mask = EMAC_DM646X_MAC_IN_VECTOR_HOST_INT;
@@ -2328,9 +2320,12 @@ static int emac_poll(struct napi_struct *napi, int budget)
 				dev_err(emac_dev, "RX Host error %s on ch=%d\n",
 					&emac_rxhost_errcodes[cause][0], ch);
 		}
-	} /* Host error processing */
+	} else if (num_rx_pkts < budget) {
+		napi_complete(napi);
+		emac_int_enable(priv);
+	}
 
-	return num_pkts;
+	return num_rx_pkts;
 }
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
-- 
1.6.2.4

