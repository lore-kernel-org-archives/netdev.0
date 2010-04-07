From: Manfred Rudigier <Manfred.Rudigier@omicron.at>
Subject: [RFC PATCH net-next 3/4] gianfar: Added raw hardware receive time
 stamp generation
Date: Wed, 7 Apr 2010 11:46:38 +0200
Message-ID: <95DC1AA8EC908B48939B72CF375AA5E311A9F4E1@alice.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "'netdev@vger.kernel.org'" <netdev@vger.kernel.org>,
	"'linuxppc-dev@lists.ozlabs.org'" <linuxppc-dev@lists.ozlabs.org>
To: "'sandeep.kumar@freescale.com'" <sandeep.kumar@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.omicron.at ([212.183.10.25]:60232 "EHLO ns.omicron.at"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757818Ab0DGKYR convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Apr 2010 06:24:17 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch configures the eTSEC to insert time stamps into all received
packets as padding alignment bytes. During the clean_rx_ring operation
these raw time stamps are extracted and copied into the
skb_shared_hwtstamps struct of the skb if required.

Signed-off-by: Manfred Rudigier <manfred.rudigier@omicron.at>
---
 drivers/net/gianfar.c |   30 +++++++++++++++++++++++++-----
 drivers/net/gianfar.h |    1 +
 2 files changed, 26 insertions(+), 5 deletions(-)

diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 41e7726..9119879 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -378,6 +378,13 @@ static void gfar_init_mac(struct net_device *ndev)
 		rctrl |= RCTRL_PADDING(priv->padding);
 	}
 
+	/* Insert receive time stamps into padding alignment bytes */
+	if (priv->device_flags & FSL_GIANFAR_DEV_HAS_TIMER) {
+		rctrl &= ~RCTRL_PAL_MASK;
+		rctrl |= RCTRL_PRSDEP_INIT | RCTRL_TS_ENABLE | RCTRL_PADDING(8);
+		priv->padding = 8;
+	}
+
 	/* keep vlan related bits if it's enabled */
 	if (priv->vlgrp) {
 		rctrl |= RCTRL_VLEX | RCTRL_PRSDEP_INIT;
@@ -502,7 +509,8 @@ void unlock_tx_qs(struct gfar_private *priv)
 /* Returns 1 if incoming frames use an FCB */
 static inline int gfar_uses_fcb(struct gfar_private *priv)
 {
-	return priv->vlgrp || priv->rx_csum_enable;
+	return priv->vlgrp || priv->rx_csum_enable ||
+		(priv->device_flags & FSL_GIANFAR_DEV_HAS_TIMER);
 }
 
 static void free_tx_pointers(struct gfar_private *priv)
@@ -808,7 +816,8 @@ static int gfar_hwtstamp_ioctl(struct net_device *netdev,
 		if (!(priv->device_flags & FSL_GIANFAR_DEV_HAS_TIMER))
 			return -ERANGE;
 		priv->hwts_rx_en = 1;
-		return -ERANGE;
+		config.rx_filter = HWTSTAMP_FILTER_ALL;
+		break;
 	}
 
 	return copy_to_user(ifr->ifr_data, &config, sizeof(config)) ?
@@ -1028,7 +1037,8 @@ static int gfar_probe(struct of_device *ofdev,
 	else
 		priv->padding = 0;
 
-	if (dev->features & NETIF_F_IP_CSUM)
+	if (dev->features & NETIF_F_IP_CSUM ||
+			priv->device_flags & FSL_GIANFAR_DEV_HAS_TIMER)
 		dev->hard_header_len += GMAC_FCB_LEN;
 
 	/* Program the isrg regs only if number of grps > 1 */
@@ -2520,6 +2530,17 @@ static int gfar_process_frame(struct net_device *dev, struct sk_buff *skb,
 		skb_pull(skb, amount_pull);
 	}
 
+	/* Get receive timestamp from the skb */
+	if (priv->hwts_rx_en) {
+		struct skb_shared_hwtstamps *shhwtstamps = skb_hwtstamps(skb);
+		u64 *ns = (u64 *) skb->data;
+		memset(shhwtstamps, 0, sizeof(*shhwtstamps));
+		shhwtstamps->hwtstamp = ns_to_ktime(*ns);
+	}
+
+	if (priv->padding)
+		skb_pull(skb, priv->padding);
+
 	if (priv->rx_csum_enable)
 		gfar_rx_checksum(skb, fcb);
 
@@ -2556,8 +2577,7 @@ int gfar_clean_rx_ring(struct gfar_priv_rx_q *rx_queue, int rx_work_limit)
 	bdp = rx_queue->cur_rx;
 	base = rx_queue->rx_bd_base;
 
-	amount_pull = (gfar_uses_fcb(priv) ? GMAC_FCB_LEN : 0) +
-		priv->padding;
+	amount_pull = (gfar_uses_fcb(priv) ? GMAC_FCB_LEN : 0);
 
 	while (!((bdp->status & RXBD_EMPTY) || (--rx_work_limit < 0))) {
 		struct sk_buff *newskb;
diff --git a/drivers/net/gianfar.h b/drivers/net/gianfar.h
index 380ea48..cba2756 100644
--- a/drivers/net/gianfar.h
+++ b/drivers/net/gianfar.h
@@ -262,6 +262,7 @@ extern const char gfar_driver_version[];
 
 #define next_bd(bdp, base, ring_size) skip_bd(bdp, 1, base, ring_size)
 
+#define RCTRL_TS_ENABLE 	0x01000000
 #define RCTRL_PAL_MASK		0x001f0000
 #define RCTRL_VLEX		0x00002000
 #define RCTRL_FILREN		0x00001000
-- 
1.6.3.3
