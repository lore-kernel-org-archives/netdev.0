From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH net-next 02/17] sfc: Move last mc_promisc flag to EF10 filter
 table state
Date: Wed, 15 Jun 2016 17:43:00 +0100
Message-ID: <625c77b8-22d1-9540-dce6-bb3ef5f0261c@solarflare.com>
References: <4daf4ef4-7a8b-4a16-c640-04275298abad@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: <linux-net-drivers@solarflare.com>, <netdev@vger.kernel.org>,
	<davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo02.seg.att.com ([209.65.160.78]:61562 "EHLO
	nbfkord-smmo02.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752206AbcFOQu2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jun 2016 12:50:28 -0400
In-Reply-To: <4daf4ef4-7a8b-4a16-c640-04275298abad@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Rybchenko <Andrew.Rybchenko@oktetlabs.ru>

It is used for EF10 only and logically belongs to EF10 filter table state.
It is OK that it is reset to false on filter table recreation since all
filters are removed on destruction.

Signed-off-by: Edward Cree <ecree@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10.c       | 7 +++++--
 drivers/net/ethernet/sfc/net_driver.h | 2 --
 2 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index 89c88ca..ebe3549 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -83,6 +83,8 @@ struct efx_ef10_filter_table {
 	u16 ucdef_id;
 	u16 bcast_id;
 	u16 mcdef_id;
+/* Whether in multicast promiscuous mode when last changed */
+	bool mc_promisc_last;
 };
 
 /* An arbitrary search limit for the software hash table */
@@ -3778,6 +3780,7 @@ static int efx_ef10_filter_table_probe(struct efx_nic *efx)
 	table->ucdef_id = EFX_EF10_FILTER_ID_INVALID;
 	table->bcast_id = EFX_EF10_FILTER_ID_INVALID;
 	table->mcdef_id = EFX_EF10_FILTER_ID_INVALID;
+	table->mc_promisc_last = false;
 
 	efx->filter_state = table;
 	init_waitqueue_head(&table->waitq);
@@ -4243,7 +4246,7 @@ static void efx_ef10_filter_sync_rx_mode(struct efx_nic *efx)
 	/* If changing promiscuous state with cascaded multicast filters, remove
 	 * old filters first, so that packets are dropped rather than duplicated
 	 */
-	if (nic_data->workaround_26807 && efx->mc_promisc != mc_promisc)
+	if (nic_data->workaround_26807 && table->mc_promisc_last != mc_promisc)
 		efx_ef10_filter_remove_old(efx);
 	if (mc_promisc) {
 		if (nic_data->workaround_26807) {
@@ -4278,7 +4281,7 @@ static void efx_ef10_filter_sync_rx_mode(struct efx_nic *efx)
 	}
 
 	efx_ef10_filter_remove_old(efx);
-	efx->mc_promisc = mc_promisc;
+	table->mc_promisc_last = mc_promisc;
 }
 
 static int efx_ef10_set_mac_address(struct efx_nic *efx)
diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
index d13ddf9..77cd23c 100644
--- a/drivers/net/ethernet/sfc/net_driver.h
+++ b/drivers/net/ethernet/sfc/net_driver.h
@@ -916,7 +916,6 @@ struct vfdi_status;
  * @stats_lock: Statistics update lock. Must be held when calling
  *	efx_nic_type::{update,start,stop}_stats.
  * @n_rx_noskb_drops: Count of RX packets dropped due to failure to allocate an skb
- * @mc_promisc: Whether in multicast promiscuous mode when last changed
  *
  * This is stored in the private area of the &struct net_device.
  */
@@ -1065,7 +1064,6 @@ struct efx_nic {
 	int last_irq_cpu;
 	spinlock_t stats_lock;
 	atomic_t n_rx_noskb_drops;
-	bool mc_promisc;
 };
 
 static inline int efx_dev_registered(struct efx_nic *efx)
