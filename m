From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-2.6 1/9] sfc: Wait at most 10ms for the MC to finish
 reading out MAC statistics
Date: Fri, 23 Apr 2010 23:23:59 +0100
Message-ID: <1272061439.5520.14.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:46060 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750835Ab0DWWYF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Apr 2010 18:24:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Hodgson <shodgson@solarflare.com>

The original code would wait indefinitely if MAC stats DMA failed.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/siena.c |   13 +++++++++++--
 1 files changed, 11 insertions(+), 2 deletions(-)

diff --git a/drivers/net/sfc/siena.c b/drivers/net/sfc/siena.c
index 38dcc42..e0c46f5 100644
--- a/drivers/net/sfc/siena.c
+++ b/drivers/net/sfc/siena.c
@@ -456,8 +456,17 @@ static int siena_try_update_nic_stats(struct efx_nic *efx)
 
 static void siena_update_nic_stats(struct efx_nic *efx)
 {
-	while (siena_try_update_nic_stats(efx) == -EAGAIN)
-		cpu_relax();
+	int retry;
+
+	/* If we're unlucky enough to read statistics wduring the DMA, wait
+	 * up to 10ms for it to finish (typically takes <500us) */
+	for (retry = 0; retry < 100; ++retry) {
+		if (siena_try_update_nic_stats(efx) == 0)
+			return;
+		udelay(100);
+	}
+
+	/* Use the old values instead */
 }
 
 static void siena_start_nic_stats(struct efx_nic *efx)
-- 
1.6.2.5


-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

