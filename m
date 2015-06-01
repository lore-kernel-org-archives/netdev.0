From: Shradha Shah <sshah@solarflare.com>
Subject: [PATCH net-next v2 03/14] sfc: Implement ndo_gets_phys_port_id()
 for EF10 VFs
Date: Mon, 1 Jun 2015 14:01:00 +0100
Message-ID: <556C578C.9020201@solarflare.com>
References: <556C5704.4060901@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo01.seg.att.com ([209.65.160.76]:62726 "EHLO
	nbfkord-smmo01.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753193AbbFANCh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jun 2015 09:02:37 -0400
In-Reply-To: <556C5704.4060901@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Shradha Shah <sshah@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10.c       | 11 +++++++++++
 drivers/net/ethernet/sfc/ef10_sriov.c | 14 ++++++++++++++
 drivers/net/ethernet/sfc/ef10_sriov.h |  3 +++
 drivers/net/ethernet/sfc/efx.c        |  1 +
 drivers/net/ethernet/sfc/net_driver.h |  2 ++
 drivers/net/ethernet/sfc/nic.h        |  1 +
 drivers/net/ethernet/sfc/sriov.c      | 11 +++++++++++
 drivers/net/ethernet/sfc/sriov.h      |  2 ++
 8 files changed, 45 insertions(+)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index 389a45d..714e7cf 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -405,6 +405,16 @@ static int efx_ef10_probe(struct efx_nic *efx)
 
 	efx_ptp_probe(efx, NULL);
 
+#ifdef CONFIG_SFC_SRIOV
+	if ((efx->pci_dev->physfn) && (!efx->pci_dev->is_physfn)) {
+		struct pci_dev *pci_dev_pf = efx->pci_dev->physfn;
+		struct efx_nic *efx_pf = pci_get_drvdata(pci_dev_pf);
+
+		efx_pf->type->get_mac_address(efx_pf, nic_data->port_id);
+	} else
+#endif
+		ether_addr_copy(nic_data->port_id, efx->net_dev->perm_addr);
+
 	return 0;
 
 fail5:
@@ -4139,6 +4149,7 @@ const struct efx_nic_type efx_hunt_a0_vf_nic_type = {
 	.vswitching_probe = efx_ef10_vswitching_probe_vf,
 	.vswitching_restore = efx_ef10_vswitching_restore_vf,
 	.vswitching_remove = efx_ef10_vswitching_remove_vf,
+	.sriov_get_phys_port_id = efx_ef10_sriov_get_phys_port_id,
 #endif
 	.get_mac_address = efx_ef10_get_mac_address_vf,
 	.set_mac_address = efx_ef10_set_mac_address,
diff --git a/drivers/net/ethernet/sfc/ef10_sriov.c b/drivers/net/ethernet/sfc/ef10_sriov.c
index 3969b1b..cd52454 100644
--- a/drivers/net/ethernet/sfc/ef10_sriov.c
+++ b/drivers/net/ethernet/sfc/ef10_sriov.c
@@ -736,3 +736,17 @@ int efx_ef10_sriov_get_vf_config(struct efx_nic *efx, int vf_i,
 
 	return 0;
 }
+
+int efx_ef10_sriov_get_phys_port_id(struct efx_nic *efx,
+				    struct netdev_phys_item_id *ppid)
+{
+	struct efx_ef10_nic_data *nic_data = efx->nic_data;
+
+	if (!is_valid_ether_addr(nic_data->port_id))
+		return -EOPNOTSUPP;
+
+	ppid->id_len = ETH_ALEN;
+	memcpy(ppid->id, nic_data->port_id, ppid->id_len);
+
+	return 0;
+}
diff --git a/drivers/net/ethernet/sfc/ef10_sriov.h b/drivers/net/ethernet/sfc/ef10_sriov.h
index b985576..ffc92a5 100644
--- a/drivers/net/ethernet/sfc/ef10_sriov.h
+++ b/drivers/net/ethernet/sfc/ef10_sriov.h
@@ -54,6 +54,9 @@ int efx_ef10_sriov_get_vf_config(struct efx_nic *efx, int vf_i,
 int efx_ef10_sriov_set_vf_link_state(struct efx_nic *efx, int vf_i,
 				     int link_state);
 
+int efx_ef10_sriov_get_phys_port_id(struct efx_nic *efx,
+				    struct netdev_phys_item_id *ppid);
+
 int efx_ef10_vswitching_probe_pf(struct efx_nic *efx);
 int efx_ef10_vswitching_probe_vf(struct efx_nic *efx);
 int efx_ef10_vswitching_restore_pf(struct efx_nic *efx);
diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index 9eafa39..fe3481c 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -2282,6 +2282,7 @@ static const struct net_device_ops efx_netdev_ops = {
 	.ndo_set_vf_spoofchk	= efx_sriov_set_vf_spoofchk,
 	.ndo_get_vf_config	= efx_sriov_get_vf_config,
 	.ndo_set_vf_link_state  = efx_sriov_set_vf_link_state,
+	.ndo_get_phys_port_id   = efx_sriov_get_phys_port_id,
 #endif
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller = efx_netpoll,
diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
index a468a22..d72f522 100644
--- a/drivers/net/ethernet/sfc/net_driver.h
+++ b/drivers/net/ethernet/sfc/net_driver.h
@@ -1350,6 +1350,8 @@ struct efx_nic_type {
 				   struct ifla_vf_info *ivi);
 	int (*sriov_set_vf_link_state)(struct efx_nic *efx, int vf_i,
 				       int link_state);
+	int (*sriov_get_phys_port_id)(struct efx_nic *efx,
+				      struct netdev_phys_item_id *ppid);
 	int (*vswitching_probe)(struct efx_nic *efx);
 	int (*vswitching_restore)(struct efx_nic *efx);
 	void (*vswitching_remove)(struct efx_nic *efx);
diff --git a/drivers/net/ethernet/sfc/nic.h b/drivers/net/ethernet/sfc/nic.h
index db8562e..e146e30 100644
--- a/drivers/net/ethernet/sfc/nic.h
+++ b/drivers/net/ethernet/sfc/nic.h
@@ -524,6 +524,7 @@ struct efx_ef10_nic_data {
 	unsigned int vport_id;
 	bool must_probe_vswitching;
 	unsigned int pf_index;
+	u8 port_id[ETH_ALEN];
 #ifdef CONFIG_SFC_SRIOV
 	unsigned int vf_index;
 	struct ef10_vf *vf;
diff --git a/drivers/net/ethernet/sfc/sriov.c b/drivers/net/ethernet/sfc/sriov.c
index 6c5edbd..816c446 100644
--- a/drivers/net/ethernet/sfc/sriov.c
+++ b/drivers/net/ethernet/sfc/sriov.c
@@ -70,3 +70,14 @@ int efx_sriov_set_vf_link_state(struct net_device *net_dev, int vf_i,
 	else
 		return -EOPNOTSUPP;
 }
+
+int efx_sriov_get_phys_port_id(struct net_device *net_dev,
+			       struct netdev_phys_item_id *ppid)
+{
+	struct efx_nic *efx = netdev_priv(net_dev);
+
+	if (efx->type->sriov_get_phys_port_id)
+		return efx->type->sriov_get_phys_port_id(efx, ppid);
+	else
+		return -EOPNOTSUPP;
+}
diff --git a/drivers/net/ethernet/sfc/sriov.h b/drivers/net/ethernet/sfc/sriov.h
index 3be15a5..400df52 100644
--- a/drivers/net/ethernet/sfc/sriov.h
+++ b/drivers/net/ethernet/sfc/sriov.h
@@ -23,6 +23,8 @@ int efx_sriov_get_vf_config(struct net_device *net_dev, int vf_i,
 			    struct ifla_vf_info *ivi);
 int efx_sriov_set_vf_link_state(struct net_device *net_dev, int vf_i,
 				int link_state);
+int efx_sriov_get_phys_port_id(struct net_device *net_dev,
+			       struct netdev_phys_item_id *ppid);
 
 #endif /* CONFIG_SFC_SRIOV */
 
