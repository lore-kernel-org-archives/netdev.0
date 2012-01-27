From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 16/32] sfc: Consistently test DEBUG macro, not
 EFX_ENABLE_DEBUG
Date: Fri, 27 Jan 2012 20:46:55 +0000
Message-ID: <1327697215.2503.23.camel@bwh-desktop>
References: <1327696858.2503.7.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:63652 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752031Ab2A0Uq7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2012 15:46:59 -0500
In-Reply-To: <1327696858.2503.7.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The netif_dbg() macro is defined in <linux/netdevice.h>.  If the DEBUG
macro is defined, it logs a message at 'debug' level, otherwise it
does nothing.

In net_driver.h we define DEBUG if EFX_ENABLE_DEBUG is defined, but
this is too late for those source files that already got a
definition of netif_dbg() by including <linux/netdevice.h>

Get rid of EFX_ENABLE_DEBUG, and only define and test DEBUG.

In mtd.c, we do not use DEBUG as a condition flag but are forced to
use the DEBUG macro-function from <linux/mtd/mtd.h>.  Undefine DEBUG
before including it.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/mtd.c        |    1 +
 drivers/net/ethernet/sfc/net_driver.h |    6 +-----
 drivers/net/ethernet/sfc/nic.c        |    2 +-
 drivers/net/ethernet/sfc/selftest.c   |    2 +-
 4 files changed, 4 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/sfc/mtd.c b/drivers/net/ethernet/sfc/mtd.c
index 7f61cd3..b702862 100644
--- a/drivers/net/ethernet/sfc/mtd.c
+++ b/drivers/net/ethernet/sfc/mtd.c
@@ -10,6 +10,7 @@
 
 #include <linux/bitops.h>
 #include <linux/module.h>
+#undef DEBUG /* <linux/mtd/mtd.h> has its own use for DEBUG */
 #include <linux/mtd/mtd.h>
 #include <linux/delay.h>
 #include <linux/slab.h>
diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
index a88e95f..4cbd997 100644
--- a/drivers/net/ethernet/sfc/net_driver.h
+++ b/drivers/net/ethernet/sfc/net_driver.h
@@ -13,10 +13,6 @@
 #ifndef EFX_NET_DRIVER_H
 #define EFX_NET_DRIVER_H
 
-#if defined(EFX_ENABLE_DEBUG) && !defined(DEBUG)
-#define DEBUG
-#endif
-
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/ethtool.h>
@@ -42,7 +38,7 @@
 
 #define EFX_DRIVER_VERSION	"3.1"
 
-#ifdef EFX_ENABLE_DEBUG
+#ifdef DEBUG
 #define EFX_BUG_ON_PARANOID(x) BUG_ON(x)
 #define EFX_WARN_ON_PARANOID(x) WARN_ON(x)
 #else
diff --git a/drivers/net/ethernet/sfc/nic.c b/drivers/net/ethernet/sfc/nic.c
index b1df2f3..bf07bd0 100644
--- a/drivers/net/ethernet/sfc/nic.c
+++ b/drivers/net/ethernet/sfc/nic.c
@@ -801,7 +801,7 @@ static void efx_handle_rx_not_ok(struct efx_rx_queue *rx_queue,
 	 * error message.  FRM_TRUNC indicates RXDP dropped the packet due
 	 * to a FIFO overflow.
 	 */
-#ifdef EFX_ENABLE_DEBUG
+#ifdef DEBUG
 	if (rx_ev_other_err && net_ratelimit()) {
 		netif_dbg(efx, rx_err, efx->net_dev,
 			  " RX queue %d unexpected RX event "
diff --git a/drivers/net/ethernet/sfc/selftest.c b/drivers/net/ethernet/sfc/selftest.c
index 9df2a79..7718287 100644
--- a/drivers/net/ethernet/sfc/selftest.c
+++ b/drivers/net/ethernet/sfc/selftest.c
@@ -315,7 +315,7 @@ void efx_loopback_rx_packet(struct efx_nic *efx,
 	return;
 
  err:
-#ifdef EFX_ENABLE_DEBUG
+#ifdef DEBUG
 	if (atomic_read(&state->rx_bad) == 0) {
 		netif_err(efx, drv, efx->net_dev, "received packet:\n");
 		print_hex_dump(KERN_ERR, "", DUMP_PREFIX_OFFSET, 0x10, 1,
-- 
1.7.7.5



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
