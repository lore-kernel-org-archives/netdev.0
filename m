From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net 1/2] sfc: Disable soft interrupt handling during
 efx_device_detach_sync()
Date: Wed, 6 Mar 2013 19:28:45 +0000
Message-ID: <1362598125.3126.12.camel@bwh-desktop.uk.solarflarecom.com>
References: <1362597261.3126.11.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>,
	<scrum-linux@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:55962 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751703Ab3CFT3A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Mar 2013 14:29:00 -0500
In-Reply-To: <1362597261.3126.11.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

efx_device_detach_sync() locks all TX queues before marking the device
detached and thus disabling further TX scheduling.  But it can still
be interrupted by TX completions which then result in TX scheduling in
soft interrupt context.  This will deadlock when it tries to acquire
a TX queue lock that efx_device_detach_sync() already acquired.

To avoid deadlock, we must use netif_tx_{,un}lock_bh().

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/efx.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/sfc/efx.h b/drivers/net/ethernet/sfc/efx.h
index 50247df..d2f790d 100644
--- a/drivers/net/ethernet/sfc/efx.h
+++ b/drivers/net/ethernet/sfc/efx.h
@@ -171,9 +171,9 @@ static inline void efx_device_detach_sync(struct efx_nic *efx)
 	 * TX scheduler is stopped when we're done and before
 	 * netif_device_present() becomes false.
 	 */
-	netif_tx_lock(dev);
+	netif_tx_lock_bh(dev);
 	netif_device_detach(dev);
-	netif_tx_unlock(dev);
+	netif_tx_unlock_bh(dev);
 }
 
 #endif /* EFX_EFX_H */
-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
