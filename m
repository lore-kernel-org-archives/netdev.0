From: Bert Kenward <bkenward@solarflare.com>
Subject: [PATCH net] sfc: limit the number of receive queues
Date: Wed, 12 Apr 2017 17:06:52 +0100
Message-ID: <08aae3d8-7ff9-a0f0-8432-2b7b1e026611@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>,
        Solarflare Linux Maintainers <linux-net-drivers@solarflare.com>
To: Dave Miller <davem@davemloft.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from connect-us.pphosted.com ([67.231.154.164]:36275 "EHLO
        dispatch1-us1.ppe-hosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753333AbdDLQNh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Apr 2017 12:13:37 -0400
Received: from dispatch1-us1.ppe-hosted.com (localhost.localdomain [127.0.0.1])
        by dispatch1-us1.ppe-hosted.com (Proofpoint Essentials ESMTP Server) with ESMTP id 62675144862
        for <netdev@vger.kernel.org>; Wed, 12 Apr 2017 16:07:06 +0000 (UTC)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The number of rx queues is determined by the rss_cpus parameter
or the cpu topology. If that is higher than EFX_MAX_RX_QUEUES the
driver can corrupt state.

Fixes: 8ceee660aacb ("New driver "sfc" for Solarstorm SFC4000 controller.")
Signed-off-by: Bert Kenward <bkenward@solarflare.com>
---
 drivers/net/ethernet/sfc/efx.c        | 7 +++++++
 drivers/net/ethernet/sfc/falcon/efx.c | 7 +++++++
 2 files changed, 14 insertions(+)

diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index 50d28261b6b9..b9cb697b2818 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -1371,6 +1371,13 @@ static unsigned int efx_wanted_parallelism(struct efx_nic *efx)
 		free_cpumask_var(thread_mask);
 	}
 
+	if (count > EFX_MAX_RX_QUEUES) {
+		netif_cond_dbg(efx, probe, efx->net_dev, !rss_cpus, warn,
+			       "Reducing number of rx queues from %u to %u.\n",
+			       count, EFX_MAX_RX_QUEUES);
+		count = EFX_MAX_RX_QUEUES;
+	}
+
 	/* If RSS is requested for the PF *and* VFs then we can't write RSS
 	 * table entries that are inaccessible to VFs
 	 */
diff --git a/drivers/net/ethernet/sfc/falcon/efx.c b/drivers/net/ethernet/sfc/falcon/efx.c
index f5e5cd1659a1..29614da91cbf 100644
--- a/drivers/net/ethernet/sfc/falcon/efx.c
+++ b/drivers/net/ethernet/sfc/falcon/efx.c
@@ -1354,6 +1354,13 @@ static unsigned int ef4_wanted_parallelism(struct ef4_nic *efx)
 		free_cpumask_var(thread_mask);
 	}
 
+	if (count > EF4_MAX_RX_QUEUES) {
+		netif_cond_dbg(efx, probe, efx->net_dev, !rss_cpus, warn,
+			       "Reducing number of rx queues from %u to %u.\n",
+			       count, EF4_MAX_RX_QUEUES);
+		count = EF4_MAX_RX_QUEUES;
+	}
+
 	return count;
 }
 
-- 
2.7.4
