From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH net-next 11/17] sfc: Take mac_lock before calling
 efx_ef10_filter_table_probe
Date: Wed, 15 Jun 2016 17:48:49 +0100
Message-ID: <e49ae0e2-abe5-73f5-93e7-1f2b6386ded2@solarflare.com>
References: <4daf4ef4-7a8b-4a16-c640-04275298abad@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: <linux-net-drivers@solarflare.com>, <netdev@vger.kernel.org>,
	<davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo03.seg.att.com ([209.65.160.84]:59201 "EHLO
	nbfkord-smmo03.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753256AbcFOQug (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jun 2016 12:50:36 -0400
In-Reply-To: <4daf4ef4-7a8b-4a16-c640-04275298abad@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Martin Habets <mhabets@solarflare.com>

When trying to enslave an SFC interface to a bond the following BUG_ON was
hit:

 kernel BUG [in ef10.c]!
 CPU: 0 PID: 4383 Comm: ifenslave Tainted: G
...
 Call Trace:
  efx_ef10_filter_add_vlan+0x121/0x180 [sfc]
  efx_ef10_filter_table_probe+0x2a2/0x4f0 [sfc]
  efx_ef10_set_mac_address+0x370/0x6d0 [sfc]
  efx_set_mac_address+0x7d/0x120 [sfc]
  dev_set_mac_address+0x43/0xa0
  bond_enslave+0x337/0xea0 [bonding]
This comes from function efx_ef10_filter_vlan_sync_rx_mode.

To solve the bug we ensure the mac_lock is taken before calling
efx_ef10_filter_add_vlan. But to avoid a priority inversion mac_lock must
be taken before filter_sem.
To satisfy these requirements we end up taking mac_lock in
efx_ef10_vport_set_mac_address, efx_ef10_set_mac_address,
efx_ef10_sriov_set_vf_vlan and efx_probe_filters.

Signed-off-by: Edward Cree <ecree@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10.c       | 4 ++++
 drivers/net/ethernet/sfc/ef10_sriov.c | 7 +++++--
 drivers/net/ethernet/sfc/efx.c        | 2 ++
 3 files changed, 11 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index a3c00ff..add9f46 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -4666,6 +4666,8 @@ static int efx_ef10_set_mac_address(struct efx_nic *efx)
 
 	efx_device_detach_sync(efx);
 	efx_net_stop(efx->net_dev);
+
+	mutex_lock(&efx->mac_lock);
 	down_write(&efx->filter_sem);
 	efx_ef10_filter_table_remove(efx);
 
@@ -4678,6 +4680,8 @@ static int efx_ef10_set_mac_address(struct efx_nic *efx)
 
 	efx_ef10_filter_table_probe(efx);
 	up_write(&efx->filter_sem);
+	mutex_unlock(&efx->mac_lock);
+
 	if (was_enabled)
 		efx_net_open(efx->net_dev);
 	netif_device_attach(efx->net_dev);
diff --git a/drivers/net/ethernet/sfc/ef10_sriov.c b/drivers/net/ethernet/sfc/ef10_sriov.c
index 3c17f27..a76610a 100644
--- a/drivers/net/ethernet/sfc/ef10_sriov.c
+++ b/drivers/net/ethernet/sfc/ef10_sriov.c
@@ -554,6 +554,7 @@ int efx_ef10_sriov_set_vf_vlan(struct efx_nic *efx, int vf_i, u16 vlan,
 		efx_device_detach_sync(vf->efx);
 		efx_net_stop(vf->efx->net_dev);
 
+		mutex_lock(&vf->efx->mac_lock);
 		down_write(&vf->efx->filter_sem);
 		vf->efx->type->filter_table_remove(vf->efx);
 
@@ -630,6 +631,7 @@ restore_filters:
 			goto reset_nic_up_write;
 
 		up_write(&vf->efx->filter_sem);
+		mutex_unlock(&vf->efx->mac_lock);
 
 		up_write(&vf->efx->filter_sem);
 
@@ -642,9 +644,10 @@ restore_filters:
 	return rc;
 
 reset_nic_up_write:
-	if (vf->efx)
+	if (vf->efx) {
 		up_write(&vf->efx->filter_sem);
-
+		mutex_unlock(&vf->efx->mac_lock);
+	}
 reset_nic:
 	if (vf->efx) {
 		netif_err(efx, drv, efx->net_dev,
diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index 902bcf2..130ee17 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -1729,6 +1729,7 @@ static int efx_probe_filters(struct efx_nic *efx)
 
 	spin_lock_init(&efx->filter_lock);
 	init_rwsem(&efx->filter_sem);
+	mutex_lock(&efx->mac_lock);
 	down_write(&efx->filter_sem);
 	rc = efx->type->filter_table_probe(efx);
 	if (rc)
@@ -1767,6 +1768,7 @@ static int efx_probe_filters(struct efx_nic *efx)
 #endif
 out_unlock:
 	up_write(&efx->filter_sem);
+	mutex_unlock(&efx->mac_lock);
 	return rc;
 }
 
