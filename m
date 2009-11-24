From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 16/17] sfc: Combine high-level header files
Date: Tue, 24 Nov 2009 02:07:30 +0000
Message-ID: <1259028451.14645.35.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:34909 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757798AbZKXCH1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2009 21:07:27 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

All files that include ethtool.h, rx.h or tx.h are also including
efx.h, and there is no good reason to separate out the few
declarations they contain.  Therefore fold them into efx.h.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.c      |    3 ---
 drivers/net/sfc/efx.h      |   27 +++++++++++++++++++++++++--
 drivers/net/sfc/ethtool.c  |    1 -
 drivers/net/sfc/ethtool.h  |   27 ---------------------------
 drivers/net/sfc/rx.c       |    1 -
 drivers/net/sfc/rx.h       |   26 --------------------------
 drivers/net/sfc/selftest.c |    1 -
 drivers/net/sfc/tx.c       |    1 -
 drivers/net/sfc/tx.h       |   25 -------------------------
 9 files changed, 25 insertions(+), 87 deletions(-)
 delete mode 100644 drivers/net/sfc/ethtool.h
 delete mode 100644 drivers/net/sfc/rx.h
 delete mode 100644 drivers/net/sfc/tx.h

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index ea31141..cb78995 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -21,9 +21,6 @@
 #include <linux/ethtool.h>
 #include <linux/topology.h>
 #include "net_driver.h"
-#include "ethtool.h"
-#include "tx.h"
-#include "rx.h"
 #include "efx.h"
 #include "mdio_10g.h"
 #include "falcon.h"
diff --git a/drivers/net/sfc/efx.h b/drivers/net/sfc/efx.h
index 9d83322..3497b03 100644
--- a/drivers/net/sfc/efx.h
+++ b/drivers/net/sfc/efx.h
@@ -23,8 +23,15 @@
 #define EFX_MEM_BAR 2
 
 /* TX */
-extern netdev_tx_t efx_enqueue_skb(struct efx_tx_queue *tx_queue,
-				   struct sk_buff *skb);
+extern int efx_probe_tx_queue(struct efx_tx_queue *tx_queue);
+extern void efx_remove_tx_queue(struct efx_tx_queue *tx_queue);
+extern void efx_init_tx_queue(struct efx_tx_queue *tx_queue);
+extern void efx_fini_tx_queue(struct efx_tx_queue *tx_queue);
+extern void efx_release_tx_buffers(struct efx_tx_queue *tx_queue);
+extern netdev_tx_t
+efx_hard_start_xmit(struct sk_buff *skb, struct net_device *net_dev);
+extern netdev_tx_t
+efx_enqueue_skb(struct efx_tx_queue *tx_queue, struct sk_buff *skb);
 extern void efx_xmit_done(struct efx_tx_queue *tx_queue, unsigned int index);
 extern void efx_stop_queue(struct efx_nic *efx);
 extern void efx_wake_queue(struct efx_nic *efx);
@@ -32,6 +39,15 @@ extern void efx_wake_queue(struct efx_nic *efx);
 #define EFX_TXQ_MASK (EFX_TXQ_SIZE - 1)
 
 /* RX */
+extern int efx_probe_rx_queue(struct efx_rx_queue *rx_queue);
+extern void efx_remove_rx_queue(struct efx_rx_queue *rx_queue);
+extern void efx_init_rx_queue(struct efx_rx_queue *rx_queue);
+extern void efx_fini_rx_queue(struct efx_rx_queue *rx_queue);
+extern void efx_rx_strategy(struct efx_channel *channel);
+extern void efx_fast_push_rx_descriptors(struct efx_rx_queue *rx_queue);
+extern void efx_rx_work(struct work_struct *data);
+extern void __efx_rx_packet(struct efx_channel *channel,
+			    struct efx_rx_buffer *rx_buf, bool checksummed);
 extern void efx_rx_packet(struct efx_rx_queue *rx_queue, unsigned int index,
 			  unsigned int len, bool checksummed, bool discard);
 extern void efx_schedule_slow_fill(struct efx_rx_queue *rx_queue, int delay);
@@ -50,6 +66,13 @@ extern void efx_stats_enable(struct efx_nic *efx);
 extern void efx_reconfigure_port(struct efx_nic *efx);
 extern void __efx_reconfigure_port(struct efx_nic *efx);
 
+/* Ethtool support */
+extern int efx_ethtool_get_settings(struct net_device *net_dev,
+				    struct ethtool_cmd *ecmd);
+extern int efx_ethtool_set_settings(struct net_device *net_dev,
+				    struct ethtool_cmd *ecmd);
+extern const struct ethtool_ops efx_ethtool_ops;
+
 /* Reset handling */
 extern void efx_reset_down(struct efx_nic *efx, enum reset_type method,
 			   struct ethtool_cmd *ecmd);
diff --git a/drivers/net/sfc/ethtool.c b/drivers/net/sfc/ethtool.c
index eb12f20..e8afd78 100644
--- a/drivers/net/sfc/ethtool.c
+++ b/drivers/net/sfc/ethtool.c
@@ -16,7 +16,6 @@
 #include "workarounds.h"
 #include "selftest.h"
 #include "efx.h"
-#include "ethtool.h"
 #include "falcon.h"
 #include "spi.h"
 #include "mdio_10g.h"
diff --git a/drivers/net/sfc/ethtool.h b/drivers/net/sfc/ethtool.h
deleted file mode 100644
index 295ead4..0000000
--- a/drivers/net/sfc/ethtool.h
+++ /dev/null
@@ -1,27 +0,0 @@
-/****************************************************************************
- * Driver for Solarflare Solarstorm network controllers and boards
- * Copyright 2005 Fen Systems Ltd.
- * Copyright 2006 Solarflare Communications Inc.
- *
- * This program is free software; you can redistribute it and/or modify it
- * under the terms of the GNU General Public License version 2 as published
- * by the Free Software Foundation, incorporated herein by reference.
- */
-
-#ifndef EFX_ETHTOOL_H
-#define EFX_ETHTOOL_H
-
-#include "net_driver.h"
-
-/*
- * Ethtool support
- */
-
-extern int efx_ethtool_get_settings(struct net_device *net_dev,
-				    struct ethtool_cmd *ecmd);
-extern int efx_ethtool_set_settings(struct net_device *net_dev,
-				    struct ethtool_cmd *ecmd);
-
-extern const struct ethtool_ops efx_ethtool_ops;
-
-#endif /* EFX_ETHTOOL_H */
diff --git a/drivers/net/sfc/rx.c b/drivers/net/sfc/rx.c
index 9f22d15..accf055 100644
--- a/drivers/net/sfc/rx.c
+++ b/drivers/net/sfc/rx.c
@@ -16,7 +16,6 @@
 #include <net/ip.h>
 #include <net/checksum.h>
 #include "net_driver.h"
-#include "rx.h"
 #include "efx.h"
 #include "falcon.h"
 #include "selftest.h"
diff --git a/drivers/net/sfc/rx.h b/drivers/net/sfc/rx.h
deleted file mode 100644
index 42ee755..0000000
--- a/drivers/net/sfc/rx.h
+++ /dev/null
@@ -1,26 +0,0 @@
-/****************************************************************************
- * Driver for Solarflare Solarstorm network controllers and boards
- * Copyright 2006 Solarflare Communications Inc.
- *
- * This program is free software; you can redistribute it and/or modify it
- * under the terms of the GNU General Public License version 2 as published
- * by the Free Software Foundation, incorporated herein by reference.
- */
-
-#ifndef EFX_RX_H
-#define EFX_RX_H
-
-#include "net_driver.h"
-
-int efx_probe_rx_queue(struct efx_rx_queue *rx_queue);
-void efx_remove_rx_queue(struct efx_rx_queue *rx_queue);
-void efx_init_rx_queue(struct efx_rx_queue *rx_queue);
-void efx_fini_rx_queue(struct efx_rx_queue *rx_queue);
-
-void efx_rx_strategy(struct efx_channel *channel);
-void efx_fast_push_rx_descriptors(struct efx_rx_queue *rx_queue);
-void efx_rx_work(struct work_struct *data);
-void __efx_rx_packet(struct efx_channel *channel,
-		     struct efx_rx_buffer *rx_buf, bool checksummed);
-
-#endif /* EFX_RX_H */
diff --git a/drivers/net/sfc/selftest.c b/drivers/net/sfc/selftest.c
index eab8c2e..afac1cc 100644
--- a/drivers/net/sfc/selftest.c
+++ b/drivers/net/sfc/selftest.c
@@ -20,7 +20,6 @@
 #include <linux/rtnetlink.h>
 #include <asm/io.h>
 #include "net_driver.h"
-#include "ethtool.h"
 #include "efx.h"
 #include "falcon.h"
 #include "selftest.h"
diff --git a/drivers/net/sfc/tx.c b/drivers/net/sfc/tx.c
index a5e541d..c54fa30 100644
--- a/drivers/net/sfc/tx.c
+++ b/drivers/net/sfc/tx.c
@@ -15,7 +15,6 @@
 #include <linux/if_ether.h>
 #include <linux/highmem.h>
 #include "net_driver.h"
-#include "tx.h"
 #include "efx.h"
 #include "falcon.h"
 #include "workarounds.h"
diff --git a/drivers/net/sfc/tx.h b/drivers/net/sfc/tx.h
deleted file mode 100644
index e367896..0000000
--- a/drivers/net/sfc/tx.h
+++ /dev/null
@@ -1,25 +0,0 @@
-/****************************************************************************
- * Driver for Solarflare Solarstorm network controllers and boards
- * Copyright 2006 Fen Systems Ltd.
- * Copyright 2006-2008 Solarflare Communications Inc.
- *
- * This program is free software; you can redistribute it and/or modify it
- * under the terms of the GNU General Public License version 2 as published
- * by the Free Software Foundation, incorporated herein by reference.
- */
-
-#ifndef EFX_TX_H
-#define EFX_TX_H
-
-#include "net_driver.h"
-
-int efx_probe_tx_queue(struct efx_tx_queue *tx_queue);
-void efx_remove_tx_queue(struct efx_tx_queue *tx_queue);
-void efx_init_tx_queue(struct efx_tx_queue *tx_queue);
-void efx_fini_tx_queue(struct efx_tx_queue *tx_queue);
-
-netdev_tx_t efx_hard_start_xmit(struct sk_buff *skb,
-				      struct net_device *net_dev);
-void efx_release_tx_buffers(struct efx_tx_queue *tx_queue);
-
-#endif /* EFX_TX_H */

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

