From: Bert Kenward <bkenward@solarflare.com>
Subject: [PATCH net-next] sfc: check MTU against minimum threshold
Date: Tue, 6 Sep 2016 17:50:00 +0100
Message-ID: <09fc2c3f-744b-41e5-5801-96fa80cd6ad5@solarflare.com>
References: <20160902170742.GA17677@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>,
        Jarod Wilson <jarod@redhat.com>
To: Dave Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo02.seg.att.com ([209.65.160.78]:47940 "EHLO
        nbfkord-smmo02.seg.att.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S933172AbcIFQuS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Sep 2016 12:50:18 -0400
In-Reply-To: <20160902170742.GA17677@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reported-by: Ma Yuying <yuma@redhat.com>
Suggested-by: Jarod Wilson <jarod@redhat.com>
Signed-off-by: Bert Kenward <bkenward@solarflare.com>
---
 drivers/net/ethernet/sfc/efx.c        | 12 +++++++++++-
 drivers/net/ethernet/sfc/net_driver.h |  3 +++
 2 files changed, 14 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index f3826ae..3cf3557 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -2263,8 +2263,18 @@ static int efx_change_mtu(struct net_device *net_dev, int new_mtu)
 	rc = efx_check_disabled(efx);
 	if (rc)
 		return rc;
-	if (new_mtu > EFX_MAX_MTU)
+	if (new_mtu > EFX_MAX_MTU) {
+		netif_err(efx, drv, efx->net_dev,
+			  "Requested MTU of %d too big (max: %d)\n",
+			  new_mtu, EFX_MAX_MTU);
 		return -EINVAL;
+	}
+	if (new_mtu < EFX_MIN_MTU) {
+		netif_err(efx, drv, efx->net_dev,
+			  "Requested MTU of %d too small (min: %d)\n",
+			  new_mtu, EFX_MIN_MTU);
+		return -EINVAL;
+	}
 
 	netif_dbg(efx, drv, efx->net_dev, "changing MTU to %d\n", new_mtu);
 
diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
index 0a2504b..99d8c82 100644
--- a/drivers/net/ethernet/sfc/net_driver.h
+++ b/drivers/net/ethernet/sfc/net_driver.h
@@ -76,6 +76,9 @@
 /* Maximum possible MTU the driver supports */
 #define EFX_MAX_MTU (9 * 1024)
 
+/* Minimum MTU, from RFC791 (IP) */
+#define EFX_MIN_MTU 68
+
 /* Size of an RX scatter buffer.  Small enough to pack 2 into a 4K page,
  * and should be a multiple of the cache line size.
  */
-- 
2.7.4
