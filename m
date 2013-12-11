From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net 7/8] sfc: Refactor efx_mcdi_poll() by introducing
 efx_mcdi_poll_once()
Date: Wed, 11 Dec 2013 01:57:36 +0000
Message-ID: <1386727056.1516.245.camel@bwh-desktop.uk.level5networks.com>
References: <1386726714.1516.236.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:41042 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751030Ab3LKB5k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Dec 2013 20:57:40 -0500
In-Reply-To: <1386726714.1516.236.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Robert Stonehouse <rstonehouse@solarflare.com>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/mcdi.c | 23 +++++++++++++++++------
 1 file changed, 17 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/sfc/mcdi.c b/drivers/net/ethernet/sfc/mcdi.c
index 366c8e3e3784..9f26e46ee283 100644
--- a/drivers/net/ethernet/sfc/mcdi.c
+++ b/drivers/net/ethernet/sfc/mcdi.c
@@ -50,6 +50,7 @@ struct efx_mcdi_async_param {
 static void efx_mcdi_timeout_async(unsigned long context);
 static int efx_mcdi_drv_attach(struct efx_nic *efx, bool driver_operating,
 			       bool *was_attached_out);
+static bool efx_mcdi_poll_once(struct efx_nic *efx);
 
 static inline struct efx_mcdi_iface *efx_mcdi(struct efx_nic *efx)
 {
@@ -237,6 +238,21 @@ static void efx_mcdi_read_response_header(struct efx_nic *efx)
 	}
 }
 
+static bool efx_mcdi_poll_once(struct efx_nic *efx)
+{
+	struct efx_mcdi_iface *mcdi = efx_mcdi(efx);
+
+	rmb();
+	if (!efx->type->mcdi_poll_response(efx))
+		return false;
+
+	spin_lock_bh(&mcdi->iface_lock);
+	efx_mcdi_read_response_header(efx);
+	spin_unlock_bh(&mcdi->iface_lock);
+
+	return true;
+}
+
 static int efx_mcdi_poll(struct efx_nic *efx)
 {
 	struct efx_mcdi_iface *mcdi = efx_mcdi(efx);
@@ -272,18 +288,13 @@ static int efx_mcdi_poll(struct efx_nic *efx)
 
 		time = jiffies;
 
-		rmb();
-		if (efx->type->mcdi_poll_response(efx))
+		if (efx_mcdi_poll_once(efx))
 			break;
 
 		if (time_after(time, finish))
 			return -ETIMEDOUT;
 	}
 
-	spin_lock_bh(&mcdi->iface_lock);
-	efx_mcdi_read_response_header(efx);
-	spin_unlock_bh(&mcdi->iface_lock);
-
 	/* Return rc=0 like wait_event_timeout() */
 	return 0;
 }


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
