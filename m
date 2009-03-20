From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 1/5] sfc: Pad packets to 33 bytes to prevent TX packet
	parser lockup
Date: Fri, 20 Mar 2009 23:25:39 +0000
Message-ID: <1237591540.3217.6.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost03.mail.zen.net.uk ([212.23.3.142]:49701 "EHLO
	smarthost03.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1763086AbZCTXZr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2009 19:25:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The packet parser used in the TX data path for locating checksum
fields can lose synchronisation with the TX queue manager when
handling packets that look like IPv4 but are too short (17-32 bytes).
Work around this by padding to 33 bytes.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/tx.c          |    8 ++++++++
 drivers/net/sfc/workarounds.h |    2 ++
 2 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/drivers/net/sfc/tx.c b/drivers/net/sfc/tx.c
index b1e1907..d6681ed 100644
--- a/drivers/net/sfc/tx.c
+++ b/drivers/net/sfc/tx.c
@@ -162,6 +162,14 @@ static int efx_enqueue_skb(struct efx_tx_queue *tx_queue,
 	/* Get size of the initial fragment */
 	len = skb_headlen(skb);
 
+	/* Pad if necessary */
+	if (EFX_WORKAROUND_15592(efx) && skb->len <= 32) {
+		EFX_BUG_ON_PARANOID(skb->data_len);
+		len = 32 + 1;
+		if (skb_pad(skb, len - skb->len))
+			return NETDEV_TX_OK;
+	}
+
 	fill_level = tx_queue->insert_count - tx_queue->old_read_count;
 	q_space = efx->type->txd_ring_mask - 1 - fill_level;
 
diff --git a/drivers/net/sfc/workarounds.h b/drivers/net/sfc/workarounds.h
index 78de68f..c821c15 100644
--- a/drivers/net/sfc/workarounds.h
+++ b/drivers/net/sfc/workarounds.h
@@ -36,6 +36,8 @@
 #define EFX_WORKAROUND_11482 EFX_WORKAROUND_ALWAYS
 /* Flush events can take a very long time to appear */
 #define EFX_WORKAROUND_11557 EFX_WORKAROUND_ALWAYS
+/* Truncated IPv4 packets can confuse the TX packet parser */
+#define EFX_WORKAROUND_15592 EFX_WORKAROUND_ALWAYS
 
 /* Spurious parity errors in TSORT buffers */
 #define EFX_WORKAROUND_5129 EFX_WORKAROUND_FALCON_A

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

