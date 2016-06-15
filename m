From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH net-next 04/17] sfc: Assert filter_sem write locked when
 required
Date: Wed, 15 Jun 2016 17:43:43 +0100
Message-ID: <f6f3499f-e0d9-76e9-b9cd-f1d8c4d4699d@solarflare.com>
References: <4daf4ef4-7a8b-4a16-c640-04275298abad@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: <linux-net-drivers@solarflare.com>, <netdev@vger.kernel.org>,
	<davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo02.seg.att.com ([209.65.160.78]:5172 "EHLO
	nbfkord-smmo02.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752704AbcFOQu2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jun 2016 12:50:28 -0400
In-Reply-To: <4daf4ef4-7a8b-4a16-c640-04275298abad@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Based on a patch by Andrew Rybchenko <Andrew.Rybchenko@oktetlabs.ru>

Signed-off-by: Edward Cree <ecree@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10.c | 16 +++++++++++++++-
 drivers/net/ethernet/sfc/efx.h  |  9 +++++++++
 2 files changed, 24 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index ebe3549..66cc963 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -3735,6 +3735,12 @@ static int efx_ef10_filter_table_probe(struct efx_nic *efx)
 	size_t outlen;
 	int rc;
 
+	if (!efx_rwsem_assert_write_locked(&efx->filter_sem))
+		return -EINVAL;
+
+	if (efx->filter_state) /* already probed */
+		return 0;
+
 	table = kzalloc(sizeof(*table), GFP_KERNEL);
 	if (!table)
 		return -ENOMEM;
@@ -3846,7 +3852,6 @@ static void efx_ef10_filter_table_restore(struct efx_nic *efx)
 		nic_data->must_restore_filters = false;
 }
 
-/* Caller must hold efx->filter_sem for write */
 static void efx_ef10_filter_table_remove(struct efx_nic *efx)
 {
 	struct efx_ef10_filter_table *table = efx->filter_state;
@@ -3856,6 +3861,15 @@ static void efx_ef10_filter_table_remove(struct efx_nic *efx)
 	int rc;
 
 	efx->filter_state = NULL;
+	/* If we were called without locking, then it's not safe to free
+	 * the table as others might be using it.  So we just WARN, leak
+	 * the memory, and potentially get an inconsistent filter table
+	 * state.
+	 * This should never actually happen.
+	 */
+	if (!efx_rwsem_assert_write_locked(&efx->filter_sem))
+		return;
+
 	if (!table)
 		return;
 
diff --git a/drivers/net/ethernet/sfc/efx.h b/drivers/net/ethernet/sfc/efx.h
index 5e3f93f..c3ae739 100644
--- a/drivers/net/ethernet/sfc/efx.h
+++ b/drivers/net/ethernet/sfc/efx.h
@@ -274,4 +274,13 @@ static inline void efx_device_detach_sync(struct efx_nic *efx)
 	netif_tx_unlock_bh(dev);
 }
 
+static inline bool efx_rwsem_assert_write_locked(struct rw_semaphore *sem)
+{
+	if (WARN_ON(down_read_trylock(sem))) {
+		up_read(sem);
+		return false;
+	}
+	return true;
+}
+
 #endif /* EFX_EFX_H */
