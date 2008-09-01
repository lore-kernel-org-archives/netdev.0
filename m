From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 32/52] sfc: Enable TSO for 802.1q VLAN devices
Date: Mon, 1 Sep 2008 12:48:23 +0100
Message-ID: <20080901114823.GZ7908@solarflare.com>
References: <20080901111621.GT7908@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost01.mail.zen.net.uk ([212.23.3.140]:58207 "EHLO
	smarthost01.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758899AbYIALs0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Sep 2008 07:48:26 -0400
Content-Disposition: inline
In-Reply-To: <20080901111621.GT7908@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.c |    2 +-
 drivers/net/sfc/tx.c  |   25 +++++++++++++++++++------
 2 files changed, 20 insertions(+), 7 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index be9382f..5a0494a 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -2079,7 +2079,7 @@ static int __devinit efx_pci_probe(struct pci_dev *pci_dev,
 		net_dev->features |= NETIF_F_LRO;
 	/* Mask for features that also apply to VLAN devices */
 	net_dev->vlan_features |= (NETIF_F_ALL_CSUM | NETIF_F_SG |
-				   NETIF_F_HIGHDMA);
+				   NETIF_F_HIGHDMA | NETIF_F_TSO);
 	efx = netdev_priv(net_dev);
 	pci_set_drvdata(pci_dev, efx);
 	rc = efx_init_struct(efx, type, pci_dev, net_dev);
diff --git a/drivers/net/sfc/tx.c b/drivers/net/sfc/tx.c
index 0e9889c..a3a3edd 100644
--- a/drivers/net/sfc/tx.c
+++ b/drivers/net/sfc/tx.c
@@ -105,7 +105,7 @@ struct efx_tso_header {
 };
 
 static int efx_enqueue_skb_tso(struct efx_tx_queue *tx_queue,
-			       const struct sk_buff *skb);
+			       struct sk_buff *skb);
 static void efx_fini_tso(struct efx_tx_queue *tx_queue);
 static void efx_tsoh_heap_free(struct efx_tx_queue *tx_queue,
 			       struct efx_tso_header *tsoh);
@@ -139,7 +139,7 @@ static void efx_tsoh_free(struct efx_tx_queue *tx_queue,
  * You must hold netif_tx_lock() to call this function.
  */
 static int efx_enqueue_skb(struct efx_tx_queue *tx_queue,
-			   const struct sk_buff *skb)
+			   struct sk_buff *skb)
 {
 	struct efx_nic *efx = tx_queue->efx;
 	struct pci_dev *pci_dev = efx->pci_dev;
@@ -578,11 +578,24 @@ struct tso_state {
  * Verify that our various assumptions about sk_buffs and the conditions
  * under which TSO will be attempted hold true.
  */
-static void efx_tso_check_safe(const struct sk_buff *skb)
+static void efx_tso_check_safe(struct sk_buff *skb)
 {
-	EFX_BUG_ON_PARANOID(skb->protocol != htons(ETH_P_IP));
+	__be16 protocol = skb->protocol;
+
 	EFX_BUG_ON_PARANOID(((struct ethhdr *)skb->data)->h_proto !=
-			    skb->protocol);
+			    protocol);
+	if (protocol == htons(ETH_P_8021Q)) {
+		/* Find the encapsulated protocol; reset network header
+		 * and transport header based on that. */
+		struct vlan_ethhdr *veh = (struct vlan_ethhdr *)skb->data;
+		protocol = veh->h_vlan_encapsulated_proto;
+		skb_set_network_header(skb, sizeof(*veh));
+		if (protocol == htons(ETH_P_IP))
+			skb_set_transport_header(skb, sizeof(*veh) +
+						 4 * ip_hdr(skb)->ihl);
+	}
+
+	EFX_BUG_ON_PARANOID(protocol != htons(ETH_P_IP));
 	EFX_BUG_ON_PARANOID(ip_hdr(skb)->protocol != IPPROTO_TCP);
 	EFX_BUG_ON_PARANOID((PTR_DIFF(tcp_hdr(skb), skb->data)
 			     + (tcp_hdr(skb)->doff << 2u)) >
@@ -1020,7 +1033,7 @@ static int tso_start_new_packet(struct efx_tx_queue *tx_queue,
  * %NETDEV_TX_OK or %NETDEV_TX_BUSY.
  */
 static int efx_enqueue_skb_tso(struct efx_tx_queue *tx_queue,
-			       const struct sk_buff *skb)
+			       struct sk_buff *skb)
 {
 	struct efx_nic *efx = tx_queue->efx;
 	int frag_i, rc, rc2 = NETDEV_TX_OK;
-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

