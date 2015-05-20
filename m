From: Shradha Shah <sshah@solarflare.com>
Subject: [PATCH net-next v3 05/16] sfc: save old MAC address in case sriov_mac_address_changed
 fails
Date: Wed, 20 May 2015 11:09:30 +0100
Message-ID: <555C5D5A.7070305@solarflare.com>
References: <555C5C91.4000004@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo03.seg.att.com ([209.65.160.84]:32333 "EHLO
	nbfkord-smmo03.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752451AbbETKJm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2015 06:09:42 -0400
In-Reply-To: <555C5C91.4000004@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Otherwise the PF and VF can disagree on the VF's MAC address and
this leads to strange behaviour, up to and including kernel panics.

Signed-off-by: Shradha Shah <sshah@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10_sriov.h  |  5 ++++-
 drivers/net/ethernet/sfc/efx.c         | 13 +++++++++++--
 drivers/net/ethernet/sfc/net_driver.h  |  2 +-
 drivers/net/ethernet/sfc/siena_sriov.c |  6 ++++--
 drivers/net/ethernet/sfc/siena_sriov.h |  2 +-
 5 files changed, 21 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ef10_sriov.h b/drivers/net/ethernet/sfc/ef10_sriov.h
index 86bac7eb..8b67163 100644
--- a/drivers/net/ethernet/sfc/ef10_sriov.h
+++ b/drivers/net/ethernet/sfc/ef10_sriov.h
@@ -31,7 +31,10 @@ static inline bool efx_ef10_sriov_wanted(struct efx_nic *efx)
 
 int efx_ef10_sriov_configure(struct efx_nic *efx, int num_vfs);
 int efx_ef10_sriov_init(struct efx_nic *efx);
-static inline void efx_ef10_sriov_mac_address_changed(struct efx_nic *efx) {}
+static inline int efx_ef10_sriov_mac_address_changed(struct efx_nic *efx)
+{
+	return -EOPNOTSUPP;
+}
 static inline void efx_ef10_sriov_reset(struct efx_nic *efx) {}
 void efx_ef10_sriov_fini(struct efx_nic *efx);
 static inline void efx_ef10_sriov_flr(struct efx_nic *efx, unsigned vf_i) {}
diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index 0f127a0..864c337 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -2196,6 +2196,8 @@ static int efx_set_mac_address(struct net_device *net_dev, void *data)
 	struct efx_nic *efx = netdev_priv(net_dev);
 	struct sockaddr *addr = data;
 	u8 *new_addr = addr->sa_data;
+	u8 old_addr[6];
+	int rc;
 
 	if (!is_valid_ether_addr(new_addr)) {
 		netif_err(efx, drv, efx->net_dev,
@@ -2204,9 +2206,16 @@ static int efx_set_mac_address(struct net_device *net_dev, void *data)
 		return -EADDRNOTAVAIL;
 	}
 
+	/* save old address */
+	ether_addr_copy(old_addr, net_dev->dev_addr);
 	ether_addr_copy(net_dev->dev_addr, new_addr);
-	if (efx->type->sriov_mac_address_changed)
-		efx->type->sriov_mac_address_changed(efx);
+	if (efx->type->sriov_mac_address_changed) {
+		rc = efx->type->sriov_mac_address_changed(efx);
+		if (rc) {
+			ether_addr_copy(net_dev->dev_addr, old_addr);
+			return rc;
+		}
+	}
 
 	/* Reconfigure the MAC */
 	mutex_lock(&efx->mac_lock);
diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
index 031a338..55a5f48 100644
--- a/drivers/net/ethernet/sfc/net_driver.h
+++ b/drivers/net/ethernet/sfc/net_driver.h
@@ -1334,7 +1334,7 @@ struct efx_nic_type {
 	int (*sriov_configure)(struct efx_nic *efx, int num_vfs);
 	int (*sriov_init)(struct efx_nic *efx);
 	void (*sriov_fini)(struct efx_nic *efx);
-	void (*sriov_mac_address_changed)(struct efx_nic *efx);
+	int (*sriov_mac_address_changed)(struct efx_nic *efx);
 	bool (*sriov_wanted)(struct efx_nic *efx);
 	void (*sriov_reset)(struct efx_nic *efx);
 	void (*sriov_flr)(struct efx_nic *efx, unsigned vf_i);
diff --git a/drivers/net/ethernet/sfc/siena_sriov.c b/drivers/net/ethernet/sfc/siena_sriov.c
index caf701a..9d1c1aa 100644
--- a/drivers/net/ethernet/sfc/siena_sriov.c
+++ b/drivers/net/ethernet/sfc/siena_sriov.c
@@ -1474,16 +1474,18 @@ void efx_siena_sriov_flr(struct efx_nic *efx, unsigned vf_i)
 	vf->evq0_count = 0;
 }
 
-void efx_siena_sriov_mac_address_changed(struct efx_nic *efx)
+int efx_siena_sriov_mac_address_changed(struct efx_nic *efx)
 {
 	struct siena_nic_data *nic_data = efx->nic_data;
 	struct vfdi_status *vfdi_status = nic_data->vfdi_status.addr;
 
 	if (!efx->vf_init_count)
-		return;
+		return 0;
 	ether_addr_copy(vfdi_status->peers[0].mac_addr,
 			efx->net_dev->dev_addr);
 	queue_work(vfdi_workqueue, &nic_data->peer_work);
+
+	return 0;
 }
 
 void efx_siena_sriov_tx_flush_done(struct efx_nic *efx, efx_qword_t *event)
diff --git a/drivers/net/ethernet/sfc/siena_sriov.h b/drivers/net/ethernet/sfc/siena_sriov.h
index 64e3e01..d88d4da 100644
--- a/drivers/net/ethernet/sfc/siena_sriov.h
+++ b/drivers/net/ethernet/sfc/siena_sriov.h
@@ -44,7 +44,7 @@
 int efx_siena_sriov_configure(struct efx_nic *efx, int num_vfs);
 int efx_siena_sriov_init(struct efx_nic *efx);
 void efx_siena_sriov_fini(struct efx_nic *efx);
-void efx_siena_sriov_mac_address_changed(struct efx_nic *efx);
+int efx_siena_sriov_mac_address_changed(struct efx_nic *efx);
 bool efx_siena_sriov_wanted(struct efx_nic *efx);
 void efx_siena_sriov_reset(struct efx_nic *efx);
 void efx_siena_sriov_flr(struct efx_nic *efx, unsigned flr);
