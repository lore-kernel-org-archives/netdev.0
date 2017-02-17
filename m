From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH net-next 3/3] sfc: do not device_attach if a reset is pending
Date: Fri, 17 Feb 2017 15:50:43 +0000
Message-ID: <65ea33f2-0fd6-3831-41c4-fd797a628d3a@solarflare.com>
References: <f49743cd-3227-4d30-9d6d-bd2f8400df62@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: <linux-net-drivers@solarflare.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo02.seg.att.com ([209.65.160.78]:1139 "EHLO
        nbfkord-smmo02.seg.att.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S934537AbdBQPu6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 17 Feb 2017 10:50:58 -0500
In-Reply-To: <f49743cd-3227-4d30-9d6d-bd2f8400df62@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter Dunning <pdunning@solarflare.com>

efx_start_all can return without initialising queues as a reset is pending.
 This means that when netif_device_attach is called, the kernel can start
 sending traffic without having an initialised TX queue to send to.
This patch avoids this by not calling netif_device_attach if there is a
 pending reset.

Fixes: e283546c0465 ("sfc:On MCDI timeout, issue an FLR (and mark MCDI to fail-fast)")
Signed-off-by: Edward Cree <ecree@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10.c       |  8 ++++----
 drivers/net/ethernet/sfc/ef10_sriov.c |  4 ++--
 drivers/net/ethernet/sfc/efx.c        | 10 ++++++----
 drivers/net/ethernet/sfc/efx.h        |  6 ++++++
 drivers/net/ethernet/sfc/selftest.c   |  2 +-
 5 files changed, 19 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index ec976ff..92e1c6d 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -5389,7 +5389,7 @@ static int efx_ef10_vport_set_mac_address(struct efx_nic *efx)
 	if (rc2)
 		goto reset_nic;
 
-	netif_device_attach(efx->net_dev);
+	efx_device_attach_if_not_resetting(efx);
 
 	return rc;
 
@@ -5675,7 +5675,7 @@ static int efx_ef10_set_mac_address(struct efx_nic *efx)
 
 	if (was_enabled)
 		efx_net_open(efx->net_dev);
-	netif_device_attach(efx->net_dev);
+	efx_device_attach_if_not_resetting(efx);
 
 #ifdef CONFIG_SFC_SRIOV
 	if (efx->pci_dev->is_virtfn && efx->pci_dev->physfn) {
@@ -6127,7 +6127,7 @@ static int efx_ef10_set_udp_tnl_ports(struct efx_nic *efx, bool unloading)
 
 	if (!(nic_data->datapath_caps &
 	    (1 << MC_CMD_GET_CAPABILITIES_OUT_VXLAN_NVGRE_LBN))) {
-		netif_device_attach(efx->net_dev);
+		efx_device_attach_if_not_resetting(efx);
 		return 0;
 	}
 
@@ -6199,7 +6199,7 @@ static int efx_ef10_set_udp_tnl_ports(struct efx_nic *efx, bool unloading)
 		 * trigger a re-attach.  Since there won't be an MC reset, we
 		 * have to do the attach ourselves.
 		 */
-		netif_device_attach(efx->net_dev);
+		efx_device_attach_if_not_resetting(efx);
 	}
 
 	return rc;
diff --git a/drivers/net/ethernet/sfc/ef10_sriov.c b/drivers/net/ethernet/sfc/ef10_sriov.c
index ed4b142..b7e4345 100644
--- a/drivers/net/ethernet/sfc/ef10_sriov.c
+++ b/drivers/net/ethernet/sfc/ef10_sriov.c
@@ -549,7 +549,7 @@ int efx_ef10_sriov_set_vf_mac(struct efx_nic *efx, int vf_i, u8 *mac)
 		vf->efx->type->filter_table_probe(vf->efx);
 		up_write(&vf->efx->filter_sem);
 		efx_net_open(vf->efx->net_dev);
-		netif_device_attach(vf->efx->net_dev);
+		efx_device_attach_if_not_resetting(vf->efx);
 	}
 
 	return 0;
@@ -667,7 +667,7 @@ int efx_ef10_sriov_set_vf_vlan(struct efx_nic *efx, int vf_i, u16 vlan,
 		if (rc2)
 			goto reset_nic;
 
-		netif_device_attach(vf->efx->net_dev);
+		efx_device_attach_if_not_resetting(vf->efx);
 	}
 	return rc;
 
diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index 8c4c273..334bcc6 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -876,7 +876,7 @@ efx_realloc_channels(struct efx_nic *efx, u32 rxq_entries, u32 txq_entries)
 		efx_schedule_reset(efx, RESET_TYPE_DISABLE);
 	} else {
 		efx_start_all(efx);
-		netif_device_attach(efx->net_dev);
+		efx_device_attach_if_not_resetting(efx);
 	}
 	return rc;
 
@@ -2182,6 +2182,8 @@ int efx_net_open(struct net_device *net_dev)
 	efx_link_status_changed(efx);
 
 	efx_start_all(efx);
+	if (efx->state == STATE_DISABLED || efx->reset_pending)
+		netif_device_detach(efx->net_dev);
 	efx_selftest_async_start(efx);
 	return 0;
 }
@@ -2248,7 +2250,7 @@ static int efx_change_mtu(struct net_device *net_dev, int new_mtu)
 	mutex_unlock(&efx->mac_lock);
 
 	efx_start_all(efx);
-	netif_device_attach(efx->net_dev);
+	efx_device_attach_if_not_resetting(efx);
 	return 0;
 }
 
@@ -2744,7 +2746,7 @@ int efx_reset(struct efx_nic *efx, enum reset_type method)
 		efx->state = STATE_DISABLED;
 	} else {
 		netif_dbg(efx, drv, efx->net_dev, "reset complete\n");
-		netif_device_attach(efx->net_dev);
+		efx_device_attach_if_not_resetting(efx);
 	}
 	return rc;
 }
@@ -3417,7 +3419,7 @@ static int efx_pm_thaw(struct device *dev)
 
 		efx_start_all(efx);
 
-		netif_device_attach(efx->net_dev);
+		efx_device_attach_if_not_resetting(efx);
 
 		efx->state = STATE_READY;
 
diff --git a/drivers/net/ethernet/sfc/efx.h b/drivers/net/ethernet/sfc/efx.h
index 342ae16..ee146624 100644
--- a/drivers/net/ethernet/sfc/efx.h
+++ b/drivers/net/ethernet/sfc/efx.h
@@ -276,6 +276,12 @@ static inline void efx_device_detach_sync(struct efx_nic *efx)
 	netif_tx_unlock_bh(dev);
 }
 
+static inline void efx_device_attach_if_not_resetting(struct efx_nic *efx)
+{
+	if ((efx->state != STATE_DISABLED) && !efx->reset_pending)
+		netif_device_attach(efx->net_dev);
+}
+
 static inline bool efx_rwsem_assert_write_locked(struct rw_semaphore *sem)
 {
 	if (WARN_ON(down_read_trylock(sem))) {
diff --git a/drivers/net/ethernet/sfc/selftest.c b/drivers/net/ethernet/sfc/selftest.c
index cd38b44..dab286a 100644
--- a/drivers/net/ethernet/sfc/selftest.c
+++ b/drivers/net/ethernet/sfc/selftest.c
@@ -768,7 +768,7 @@ int efx_selftest(struct efx_nic *efx, struct efx_self_tests *tests,
 	__efx_reconfigure_port(efx);
 	mutex_unlock(&efx->mac_lock);
 
-	netif_device_attach(efx->net_dev);
+	efx_device_attach_if_not_resetting(efx);
 
 	return rc_test;
 }
