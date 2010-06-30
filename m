From: Anton Vorontsov <avorontsov@mvista.com>
Subject: [PATCH v2 2/3] gianfar: Implement workaround for eTSEC76 erratum
Date: Wed, 30 Jun 2010 20:39:13 +0400
Message-ID: <20100630163913.GB23337@oksana.dev.rtsoft.ru>
References: <20100630163804.GA636@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Manfred Rudigier <manfred.rudigier@omicron.at>,
	Sandeep Gopalpet <Sandeep.Kumar@freescale.com>,
	Andy Fleming <afleming@freescale.com>, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from imap.ru.mvista.com ([213.79.90.228]:24711 "EHLO
	buildserver.ru.mvista.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756703Ab0F3QjP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jun 2010 12:39:15 -0400
Content-Disposition: inline
In-Reply-To: <20100630163804.GA636@oksana.dev.rtsoft.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

MPC8313ECE says:

"For TOE=1 huge or jumbo frames, the data required to generate the
 checksum may exceed the 2500-byte threshold beyond which the controller
 constrains itself to one memory fetch every 256 eTSEC system clocks.

 This throttling threshold is supposed to trigger only when the
 controller has sufficient data to keep transmit active for the duration
 of the memory fetches. The state machine handling this threshold,
 however, fails to take large TOE frames into account. As a result,
 TOE=1 frames larger than 2500 bytes often see excess delays before start
 of transmission."

This patch implements the workaround as suggested by the errata
document, i.e.:

"Limit TOE=1 frames to less than 2500 bytes to avoid excess delays due to
 memory throttling.
 When using packets larger than 2700 bytes, it is recommended to turn TOE
 off."

To be sure, we limit the TOE frames to 2500 bytes, and do software
checksumming instead.

Signed-off-by: Anton Vorontsov <avorontsov@mvista.com>
---
 drivers/net/gianfar.c |   19 +++++++++++++++++++
 drivers/net/gianfar.h |    1 +
 2 files changed, 20 insertions(+), 0 deletions(-)

diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 9abcb39..8ba2973 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -942,6 +942,11 @@ static void gfar_detect_errata(struct gfar_private *priv)
 			(pvr == 0x80861010 && (mod & 0xfff9) == 0x80c0))
 		priv->errata |= GFAR_ERRATA_74;
 
+	/* MPC8313 and MPC837x all rev */
+	if ((pvr == 0x80850010 && mod == 0x80b0) ||
+			(pvr == 0x80861010 && (mod & 0xfff9) == 0x80c0))
+		priv->errata |= GFAR_ERRATA_76;
+
 	if (priv->errata)
 		dev_info(dev, "enabled errata workarounds, flags: 0x%x\n",
 			 priv->errata);
@@ -2011,6 +2016,20 @@ static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	unsigned int nr_frags, nr_txbds, length;
 	union skb_shared_tx *shtx;
 
+	/*
+	 * TOE=1 frames larger than 2500 bytes may see excess delays
+	 * before start of transmission.
+	 */
+	if (unlikely(gfar_has_errata(priv, GFAR_ERRATA_76) &&
+			skb->ip_summed == CHECKSUM_PARTIAL &&
+			skb->len > 2500)) {
+		int ret;
+
+		ret = skb_checksum_help(skb);
+		if (ret)
+			return ret;
+	}
+
 	rq = skb->queue_mapping;
 	tx_queue = priv->tx_queue[rq];
 	txq = netdev_get_tx_queue(dev, rq);
diff --git a/drivers/net/gianfar.h b/drivers/net/gianfar.h
index 0a0483c..c414374 100644
--- a/drivers/net/gianfar.h
+++ b/drivers/net/gianfar.h
@@ -1027,6 +1027,7 @@ struct gfar_priv_grp {
 
 enum gfar_errata {
 	GFAR_ERRATA_74		= 0x01,
+	GFAR_ERRATA_76		= 0x02,
 };
 
 /* Struct stolen almost completely (and shamelessly) from the FCC enet source
-- 
1.7.0.5

