From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH net-next 6/6] sfc: configure UDP tunnel offload ports
Date: Wed, 8 Feb 2017 16:52:10 +0000
Message-ID: <27ebf6a0-e913-c167-5d39-b2d4be6ea23e@solarflare.com>
References: <b4d116f2-8298-60c4-7f33-f53d9f39a9cd@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: <linux-net-drivers@solarflare.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo02.seg.att.com ([209.65.160.78]:51701 "EHLO
        nbfkord-smmo02.seg.att.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753246AbdBHQzh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 11:55:37 -0500
In-Reply-To: <b4d116f2-8298-60c4-7f33-f53d9f39a9cd@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Cooper <jcooper@solarflare.com>

Implement ndo_udp_tunnel_{add,del} to update the NIC's list of VXLAN and
 GENEVE UDP ports.  Also reset the port list to empty on driver load and
 on driver unload, with appropriate flag set on the unload case.
These port numbers are used for RX inner checksum offload, and in future
 will also be used for TX inner checksum offload and encapsulated TSO.

Signed-off-by: Edward Cree <ecree@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10.c       | 289 ++++++++++++++++++++++++++++++++++
 drivers/net/ethernet/sfc/efx.c        |  72 +++++++++
 drivers/net/ethernet/sfc/mcdi.c       |   8 +-
 drivers/net/ethernet/sfc/mcdi.h       |   1 +
 drivers/net/ethernet/sfc/net_driver.h |  19 +++
 drivers/net/ethernet/sfc/nic.h        |   7 +
 drivers/net/ethernet/sfc/siena.c      |   2 +
 7 files changed, 397 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index c738b11..6bba2d2 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -132,6 +132,7 @@ static int efx_ef10_filter_add_vlan(struct efx_nic *efx, u16 vid);
 static void efx_ef10_filter_del_vlan_internal(struct efx_nic *efx,
 					      struct efx_ef10_filter_vlan *vlan);
 static void efx_ef10_filter_del_vlan(struct efx_nic *efx, u16 vid);
+static int efx_ef10_set_udp_tnl_ports(struct efx_nic *efx, bool unloading);
 
 static int efx_ef10_get_warm_boot_count(struct efx_nic *efx)
 {
@@ -624,6 +625,8 @@ static int efx_ef10_probe(struct efx_nic *efx)
 	if (rc)
 		goto fail2;
 
+	mutex_init(&nic_data->udp_tunnels_lock);
+
 	/* Reset (most) configuration for this function */
 	rc = efx_mcdi_reset(efx, RESET_TYPE_ALL);
 	if (rc)
@@ -712,6 +715,14 @@ static int efx_ef10_probe(struct efx_nic *efx)
 fail4:
 	device_remove_file(&efx->pci_dev->dev, &dev_attr_link_control_flag);
 fail3:
+	efx_mcdi_detach(efx);
+
+	mutex_lock(&nic_data->udp_tunnels_lock);
+	memset(nic_data->udp_tunnels, 0, sizeof(nic_data->udp_tunnels));
+	(void)efx_ef10_set_udp_tnl_ports(efx, true);
+	mutex_unlock(&nic_data->udp_tunnels_lock);
+	mutex_destroy(&nic_data->udp_tunnels_lock);
+
 	efx_mcdi_fini(efx);
 fail2:
 	efx_nic_free_buffer(efx, &nic_data->mcdi_buf);
@@ -981,6 +992,15 @@ static void efx_ef10_remove(struct efx_nic *efx)
 	device_remove_file(&efx->pci_dev->dev, &dev_attr_primary_flag);
 	device_remove_file(&efx->pci_dev->dev, &dev_attr_link_control_flag);
 
+	efx_mcdi_detach(efx);
+
+	memset(nic_data->udp_tunnels, 0, sizeof(nic_data->udp_tunnels));
+	mutex_lock(&nic_data->udp_tunnels_lock);
+	(void)efx_ef10_set_udp_tnl_ports(efx, true);
+	mutex_unlock(&nic_data->udp_tunnels_lock);
+
+	mutex_destroy(&nic_data->udp_tunnels_lock);
+
 	efx_mcdi_fini(efx);
 	efx_nic_free_buffer(efx, &nic_data->mcdi_buf);
 	kfree(nic_data);
@@ -6066,6 +6086,271 @@ static int efx_ef10_vlan_rx_kill_vid(struct efx_nic *efx, __be16 proto, u16 vid)
 	return efx_ef10_del_vlan(efx, vid);
 }
 
+/* We rely on the MCDI wiping out our TX rings if it made any changes to the
+ * ports table, ensuring that any TSO descriptors that were made on a now-
+ * removed tunnel port will be blown away and won't break things when we try
+ * to transmit them using the new ports table.
+ */
+static int efx_ef10_set_udp_tnl_ports(struct efx_nic *efx, bool unloading)
+{
+	struct efx_ef10_nic_data *nic_data = efx->nic_data;
+	MCDI_DECLARE_BUF(inbuf, MC_CMD_SET_TUNNEL_ENCAP_UDP_PORTS_IN_LENMAX);
+	MCDI_DECLARE_BUF(outbuf, MC_CMD_SET_TUNNEL_ENCAP_UDP_PORTS_OUT_LEN);
+	bool will_reset = false;
+	size_t num_entries = 0;
+	size_t inlen, outlen;
+	size_t i;
+	int rc;
+	efx_dword_t flags_and_num_entries;
+
+	WARN_ON(!mutex_is_locked(&nic_data->udp_tunnels_lock));
+
+	nic_data->udp_tunnels_dirty = false;
+
+	if (!(nic_data->datapath_caps &
+	    (1 << MC_CMD_GET_CAPABILITIES_OUT_VXLAN_NVGRE_LBN))) {
+		netif_device_attach(efx->net_dev);
+		return 0;
+	}
+
+	BUILD_BUG_ON(ARRAY_SIZE(nic_data->udp_tunnels) >
+		     MC_CMD_SET_TUNNEL_ENCAP_UDP_PORTS_IN_ENTRIES_MAXNUM);
+
+	for (i = 0; i < ARRAY_SIZE(nic_data->udp_tunnels); ++i) {
+		if (nic_data->udp_tunnels[i].count &&
+		    nic_data->udp_tunnels[i].port) {
+			efx_dword_t entry;
+
+			EFX_POPULATE_DWORD_2(entry,
+				TUNNEL_ENCAP_UDP_PORT_ENTRY_UDP_PORT,
+					ntohs(nic_data->udp_tunnels[i].port),
+				TUNNEL_ENCAP_UDP_PORT_ENTRY_PROTOCOL,
+					nic_data->udp_tunnels[i].type);
+			*_MCDI_ARRAY_DWORD(inbuf,
+				SET_TUNNEL_ENCAP_UDP_PORTS_IN_ENTRIES,
+				num_entries++) = entry;
+		}
+	}
+
+	BUILD_BUG_ON((MC_CMD_SET_TUNNEL_ENCAP_UDP_PORTS_IN_NUM_ENTRIES_OFST -
+		      MC_CMD_SET_TUNNEL_ENCAP_UDP_PORTS_IN_FLAGS_OFST) * 8 !=
+		     EFX_WORD_1_LBN);
+	BUILD_BUG_ON(MC_CMD_SET_TUNNEL_ENCAP_UDP_PORTS_IN_NUM_ENTRIES_LEN * 8 !=
+		     EFX_WORD_1_WIDTH);
+	EFX_POPULATE_DWORD_2(flags_and_num_entries,
+			     MC_CMD_SET_TUNNEL_ENCAP_UDP_PORTS_IN_UNLOADING,
+				!!unloading,
+			     EFX_WORD_1, num_entries);
+	*_MCDI_DWORD(inbuf, SET_TUNNEL_ENCAP_UDP_PORTS_IN_FLAGS) =
+		flags_and_num_entries;
+
+	inlen = MC_CMD_SET_TUNNEL_ENCAP_UDP_PORTS_IN_LEN(num_entries);
+
+	rc = efx_mcdi_rpc_quiet(efx, MC_CMD_SET_TUNNEL_ENCAP_UDP_PORTS,
+				inbuf, inlen, outbuf, sizeof(outbuf), &outlen);
+	if (rc == -EIO) {
+		/* Most likely the MC rebooted due to another function also
+		 * setting its tunnel port list. Mark the tunnel port list as
+		 * dirty, so it will be pushed upon coming up from the reboot.
+		 */
+		nic_data->udp_tunnels_dirty = true;
+		return 0;
+	}
+
+	if (rc) {
+		/* expected not available on unprivileged functions */
+		if (rc != -EPERM)
+			netif_warn(efx, drv, efx->net_dev,
+				   "Unable to set UDP tunnel ports; rc=%d.\n", rc);
+	} else if (MCDI_DWORD(outbuf, SET_TUNNEL_ENCAP_UDP_PORTS_OUT_FLAGS) &
+		   (1 << MC_CMD_SET_TUNNEL_ENCAP_UDP_PORTS_OUT_RESETTING_LBN)) {
+		netif_info(efx, drv, efx->net_dev,
+			   "Rebooting MC due to UDP tunnel port list change\n");
+		will_reset = true;
+		if (unloading)
+			/* Delay for the MC reset to complete. This will make
+			 * unloading other functions a bit smoother. This is a
+			 * race, but the other unload will work whichever way
+			 * it goes, this just avoids an unnecessary error
+			 * message.
+			 */
+			msleep(100);
+	}
+	if (!will_reset && !unloading) {
+		/* The caller will have detached, relying on the MC reset to
+		 * trigger a re-attach.  Since there won't be an MC reset, we
+		 * have to do the attach ourselves.
+		 */
+		netif_device_attach(efx->net_dev);
+	}
+
+	return rc;
+}
+
+static int efx_ef10_udp_tnl_push_ports(struct efx_nic *efx)
+{
+	struct efx_ef10_nic_data *nic_data = efx->nic_data;
+	int rc = 0;
+
+	mutex_lock(&nic_data->udp_tunnels_lock);
+	if (nic_data->udp_tunnels_dirty) {
+		/* Make sure all TX are stopped while we modify the table, else
+		 * we might race against an efx_features_check().
+		 */
+		efx_device_detach_sync(efx);
+		rc = efx_ef10_set_udp_tnl_ports(efx, false);
+	}
+	mutex_unlock(&nic_data->udp_tunnels_lock);
+	return rc;
+}
+
+static struct efx_udp_tunnel *__efx_ef10_udp_tnl_lookup_port(struct efx_nic *efx,
+							     __be16 port)
+{
+	struct efx_ef10_nic_data *nic_data = efx->nic_data;
+	size_t i;
+
+	for (i = 0; i < ARRAY_SIZE(nic_data->udp_tunnels); ++i) {
+		if (!nic_data->udp_tunnels[i].count)
+			continue;
+		if (nic_data->udp_tunnels[i].port == port)
+			return &nic_data->udp_tunnels[i];
+	}
+	return NULL;
+}
+
+static int efx_ef10_udp_tnl_add_port(struct efx_nic *efx,
+				     struct efx_udp_tunnel tnl)
+{
+	struct efx_ef10_nic_data *nic_data = efx->nic_data;
+	struct efx_udp_tunnel *match;
+	char typebuf[8];
+	size_t i;
+	int rc;
+
+	if (!(nic_data->datapath_caps &
+	      (1 << MC_CMD_GET_CAPABILITIES_OUT_VXLAN_NVGRE_LBN)))
+		return 0;
+
+	efx_get_udp_tunnel_type_name(tnl.type, typebuf, sizeof(typebuf));
+	netif_dbg(efx, drv, efx->net_dev, "Adding UDP tunnel (%s) port %d\n",
+		  typebuf, ntohs(tnl.port));
+
+	mutex_lock(&nic_data->udp_tunnels_lock);
+	/* Make sure all TX are stopped while we add to the table, else we
+	 * might race against an efx_features_check().
+	 */
+	efx_device_detach_sync(efx);
+
+	match = __efx_ef10_udp_tnl_lookup_port(efx, tnl.port);
+	if (match != NULL) {
+		if (match->type == tnl.type) {
+			netif_dbg(efx, drv, efx->net_dev,
+				  "Referencing existing tunnel entry\n");
+			match->count++;
+			/* No need to cause an MCDI update */
+			rc = 0;
+			goto unlock_out;
+		}
+		efx_get_udp_tunnel_type_name(match->type,
+					     typebuf, sizeof(typebuf));
+		netif_dbg(efx, drv, efx->net_dev,
+			  "UDP port %d is already in use by %s\n",
+			  ntohs(tnl.port), typebuf);
+		rc = -EEXIST;
+		goto unlock_out;
+	}
+
+	for (i = 0; i < ARRAY_SIZE(nic_data->udp_tunnels); ++i)
+		if (!nic_data->udp_tunnels[i].count) {
+			nic_data->udp_tunnels[i] = tnl;
+			nic_data->udp_tunnels[i].count = 1;
+			rc = efx_ef10_set_udp_tnl_ports(efx, false);
+			goto unlock_out;
+		}
+
+	netif_dbg(efx, drv, efx->net_dev,
+		  "Unable to add UDP tunnel (%s) port %d; insufficient resources.\n",
+		  typebuf, ntohs(tnl.port));
+
+	rc = -ENOMEM;
+
+unlock_out:
+	mutex_unlock(&nic_data->udp_tunnels_lock);
+	return rc;
+}
+
+/* Called under the TX lock with the TX queue running, hence no-one can be
+ * in the middle of updating the UDP tunnels table.  However, they could
+ * have tried and failed the MCDI, in which case they'll have set the dirty
+ * flag before dropping their locks.
+ */
+static bool efx_ef10_udp_tnl_has_port(struct efx_nic *efx, __be16 port)
+{
+	struct efx_ef10_nic_data *nic_data = efx->nic_data;
+
+	if (!(nic_data->datapath_caps &
+	      (1 << MC_CMD_GET_CAPABILITIES_OUT_VXLAN_NVGRE_LBN)))
+		return false;
+
+	if (nic_data->udp_tunnels_dirty)
+		/* SW table may not match HW state, so just assume we can't
+		 * use any UDP tunnel offloads.
+		 */
+		return false;
+
+	return __efx_ef10_udp_tnl_lookup_port(efx, port) != NULL;
+}
+
+static int efx_ef10_udp_tnl_del_port(struct efx_nic *efx,
+				     struct efx_udp_tunnel tnl)
+{
+	struct efx_ef10_nic_data *nic_data = efx->nic_data;
+	struct efx_udp_tunnel *match;
+	char typebuf[8];
+	int rc;
+
+	if (!(nic_data->datapath_caps &
+	      (1 << MC_CMD_GET_CAPABILITIES_OUT_VXLAN_NVGRE_LBN)))
+		return 0;
+
+	efx_get_udp_tunnel_type_name(tnl.type, typebuf, sizeof(typebuf));
+	netif_dbg(efx, drv, efx->net_dev, "Removing UDP tunnel (%s) port %d\n",
+		  typebuf, ntohs(tnl.port));
+
+	mutex_lock(&nic_data->udp_tunnels_lock);
+	/* Make sure all TX are stopped while we remove from the table, else we
+	 * might race against an efx_features_check().
+	 */
+	efx_device_detach_sync(efx);
+
+	match = __efx_ef10_udp_tnl_lookup_port(efx, tnl.port);
+	if (match != NULL) {
+		if (match->type == tnl.type) {
+			if (--match->count) {
+				/* Port is still in use, so nothing to do */
+				netif_dbg(efx, drv, efx->net_dev,
+					  "UDP tunnel port %d remains active\n",
+					  ntohs(tnl.port));
+				rc = 0;
+				goto out_unlock;
+			}
+			rc = efx_ef10_set_udp_tnl_ports(efx, false);
+			goto out_unlock;
+		}
+		efx_get_udp_tunnel_type_name(match->type,
+					     typebuf, sizeof(typebuf));
+		netif_warn(efx, drv, efx->net_dev,
+			   "UDP port %d is actually in use by %s, not removing\n",
+			   ntohs(tnl.port), typebuf);
+	}
+	rc = -ENOENT;
+
+out_unlock:
+	mutex_unlock(&nic_data->udp_tunnels_lock);
+	return rc;
+}
+
 #define EF10_OFFLOAD_FEATURES		\
 	(NETIF_F_IP_CSUM |		\
 	 NETIF_F_HW_VLAN_CTAG_FILTER |	\
@@ -6269,6 +6554,10 @@ const struct efx_nic_type efx_hunt_a0_nic_type = {
 	.ptp_set_ts_config = efx_ef10_ptp_set_ts_config,
 	.vlan_rx_add_vid = efx_ef10_vlan_rx_add_vid,
 	.vlan_rx_kill_vid = efx_ef10_vlan_rx_kill_vid,
+	.udp_tnl_push_ports = efx_ef10_udp_tnl_push_ports,
+	.udp_tnl_add_port = efx_ef10_udp_tnl_add_port,
+	.udp_tnl_has_port = efx_ef10_udp_tnl_has_port,
+	.udp_tnl_del_port = efx_ef10_udp_tnl_del_port,
 #ifdef CONFIG_SFC_SRIOV
 	.sriov_configure = efx_ef10_sriov_configure,
 	.sriov_init = efx_ef10_sriov_init,
diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index baab0a2..cb8e2c3 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -23,12 +23,15 @@
 #include <linux/aer.h>
 #include <linux/interrupt.h>
 #include "net_driver.h"
+#include <net/gre.h>
+#include <net/udp_tunnel.h>
 #include "efx.h"
 #include "nic.h"
 #include "selftest.h"
 #include "sriov.h"
 
 #include "mcdi.h"
+#include "mcdi_pcol.h"
 #include "workarounds.h"
 
 /**************************************************************************
@@ -88,6 +91,21 @@ const char *const efx_reset_type_names[] = {
 	[RESET_TYPE_MCDI_TIMEOUT]	= "MCDI_TIMEOUT (FLR)",
 };
 
+/* UDP tunnel type names */
+static const char *const efx_udp_tunnel_type_names[] = {
+	[TUNNEL_ENCAP_UDP_PORT_ENTRY_VXLAN] = "vxlan",
+	[TUNNEL_ENCAP_UDP_PORT_ENTRY_GENEVE] = "geneve",
+};
+
+void efx_get_udp_tunnel_type_name(u16 type, char *buf, size_t buflen)
+{
+	if (type < ARRAY_SIZE(efx_udp_tunnel_type_names) &&
+	    efx_udp_tunnel_type_names[type] != NULL)
+		snprintf(buf, buflen, "%s", efx_udp_tunnel_type_names[type]);
+	else
+		snprintf(buf, buflen, "type %d", type);
+}
+
 /* Reset workqueue. If any NIC has a hardware failure then a reset will be
  * queued onto this work queue. This is not a per-nic work queue, because
  * efx_reset_work() acquires the rtnl lock, so resets are naturally serialised.
@@ -2336,6 +2354,52 @@ static int efx_vlan_rx_kill_vid(struct net_device *net_dev, __be16 proto, u16 vi
 		return -EOPNOTSUPP;
 }
 
+static int efx_udp_tunnel_type_map(enum udp_parsable_tunnel_type in)
+{
+	switch (in) {
+	case UDP_TUNNEL_TYPE_VXLAN:
+		return TUNNEL_ENCAP_UDP_PORT_ENTRY_VXLAN;
+	case UDP_TUNNEL_TYPE_GENEVE:
+		return TUNNEL_ENCAP_UDP_PORT_ENTRY_GENEVE;
+	default:
+		return -1;
+	}
+}
+
+static void efx_udp_tunnel_add(struct net_device *dev, struct udp_tunnel_info *ti)
+{
+	struct efx_nic *efx = netdev_priv(dev);
+	struct efx_udp_tunnel tnl;
+	int efx_tunnel_type;
+
+	efx_tunnel_type = efx_udp_tunnel_type_map(ti->type);
+	if (efx_tunnel_type < 0)
+		return;
+
+	tnl.type = (u16)efx_tunnel_type;
+	tnl.port = ti->port;
+
+	if (efx->type->udp_tnl_add_port)
+		(void)efx->type->udp_tnl_add_port(efx, tnl);
+}
+
+static void efx_udp_tunnel_del(struct net_device *dev, struct udp_tunnel_info *ti)
+{
+	struct efx_nic *efx = netdev_priv(dev);
+	struct efx_udp_tunnel tnl;
+	int efx_tunnel_type;
+
+	efx_tunnel_type = efx_udp_tunnel_type_map(ti->type);
+	if (efx_tunnel_type < 0)
+		return;
+
+	tnl.type = (u16)efx_tunnel_type;
+	tnl.port = ti->port;
+
+	if (efx->type->udp_tnl_add_port)
+		(void)efx->type->udp_tnl_del_port(efx, tnl);
+}
+
 static const struct net_device_ops efx_netdev_ops = {
 	.ndo_open		= efx_net_open,
 	.ndo_stop		= efx_net_stop,
@@ -2366,6 +2430,8 @@ static const struct net_device_ops efx_netdev_ops = {
 #ifdef CONFIG_RFS_ACCEL
 	.ndo_rx_flow_steer	= efx_filter_rfs,
 #endif
+	.ndo_udp_tunnel_add	= efx_udp_tunnel_add,
+	.ndo_udp_tunnel_del	= efx_udp_tunnel_del,
 };
 
 static void efx_update_name(struct efx_nic *efx)
@@ -2605,6 +2671,9 @@ int efx_reset_up(struct efx_nic *efx, enum reset_type method, bool ok)
 
 	efx_start_all(efx);
 
+	if (efx->type->udp_tnl_push_ports)
+		efx->type->udp_tnl_push_ports(efx);
+
 	return 0;
 
 fail:
@@ -3261,6 +3330,9 @@ static int efx_pci_probe(struct pci_dev *pci_dev,
 			     "PCIE error reporting unavailable (%d).\n",
 			     rc);
 
+	if (efx->type->udp_tnl_push_ports)
+		efx->type->udp_tnl_push_ports(efx);
+
 	return 0;
 
  fail3:
diff --git a/drivers/net/ethernet/sfc/mcdi.c b/drivers/net/ethernet/sfc/mcdi.c
index fae647d..b942245 100644
--- a/drivers/net/ethernet/sfc/mcdi.c
+++ b/drivers/net/ethernet/sfc/mcdi.c
@@ -128,7 +128,7 @@ int efx_mcdi_init(struct efx_nic *efx)
 	return rc;
 }
 
-void efx_mcdi_fini(struct efx_nic *efx)
+void efx_mcdi_detach(struct efx_nic *efx)
 {
 	if (!efx->mcdi)
 		return;
@@ -137,6 +137,12 @@ void efx_mcdi_fini(struct efx_nic *efx)
 
 	/* Relinquish the device (back to the BMC, if this is a LOM) */
 	efx_mcdi_drv_attach(efx, false, NULL);
+}
+
+void efx_mcdi_fini(struct efx_nic *efx)
+{
+	if (!efx->mcdi)
+		return;
 
 #ifdef CONFIG_SFC_MCDI_LOGGING
 	free_page((unsigned long)efx->mcdi->iface.logging_buffer);
diff --git a/drivers/net/ethernet/sfc/mcdi.h b/drivers/net/ethernet/sfc/mcdi.h
index 4472107..154ef41 100644
--- a/drivers/net/ethernet/sfc/mcdi.h
+++ b/drivers/net/ethernet/sfc/mcdi.h
@@ -142,6 +142,7 @@ static inline struct efx_mcdi_mon *efx_mcdi_mon(struct efx_nic *efx)
 #endif
 
 int efx_mcdi_init(struct efx_nic *efx);
+void efx_mcdi_detach(struct efx_nic *efx);
 void efx_mcdi_fini(struct efx_nic *efx);
 
 int efx_mcdi_rpc(struct efx_nic *efx, unsigned cmd, const efx_dword_t *inbuf,
diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
index e64e933..5cb8112 100644
--- a/drivers/net/ethernet/sfc/net_driver.h
+++ b/drivers/net/ethernet/sfc/net_driver.h
@@ -554,6 +554,8 @@ extern const unsigned int efx_reset_type_max;
 #define RESET_TYPE(type) \
 	STRING_TABLE_LOOKUP(type, efx_reset_type)
 
+void efx_get_udp_tunnel_type_name(u16 type, char *buf, size_t buflen);
+
 enum efx_int_mode {
 	/* Be careful if altering to correct macro below */
 	EFX_INT_MODE_MSIX = 0,
@@ -993,6 +995,15 @@ struct efx_mtd_partition {
 	char name[IFNAMSIZ + 20];
 };
 
+struct efx_udp_tunnel {
+	u16 type; /* TUNNEL_ENCAP_UDP_PORT_ENTRY_foo, see mcdi_pcol.h */
+	__be16 port;
+	/* Count of repeated adds of the same port.  Used only inside the list,
+	 * not in request arguments.
+	 */
+	u16 count;
+};
+
 /**
  * struct efx_nic_type - Efx device type definition
  * @mem_bar: Get the memory BAR
@@ -1113,6 +1124,10 @@ struct efx_mtd_partition {
  * @set_mac_address: Set the MAC address of the device
  * @tso_versions: Returns mask of firmware-assisted TSO versions supported.
  *	If %NULL, then device does not support any TSO version.
+ * @udp_tnl_push_ports: Push the list of UDP tunnel ports to the NIC if required.
+ * @udp_tnl_add_port: Add a UDP tunnel port
+ * @udp_tnl_has_port: Check if a port has been added as UDP tunnel
+ * @udp_tnl_del_port: Remove a UDP tunnel port
  * @revision: Hardware architecture revision
  * @txd_ptr_tbl_base: TX descriptor ring base address
  * @rxd_ptr_tbl_base: RX descriptor ring base address
@@ -1272,6 +1287,10 @@ struct efx_nic_type {
 	int (*get_mac_address)(struct efx_nic *efx, unsigned char *perm_addr);
 	int (*set_mac_address)(struct efx_nic *efx);
 	u32 (*tso_versions)(struct efx_nic *efx);
+	int (*udp_tnl_push_ports)(struct efx_nic *efx);
+	int (*udp_tnl_add_port)(struct efx_nic *efx, struct efx_udp_tunnel tnl);
+	bool (*udp_tnl_has_port)(struct efx_nic *efx, __be16 port);
+	int (*udp_tnl_del_port)(struct efx_nic *efx, struct efx_udp_tunnel tnl);
 
 	int revision;
 	unsigned int txd_ptr_tbl_base;
diff --git a/drivers/net/ethernet/sfc/nic.h b/drivers/net/ethernet/sfc/nic.h
index 85cf131..7b916aa 100644
--- a/drivers/net/ethernet/sfc/nic.h
+++ b/drivers/net/ethernet/sfc/nic.h
@@ -369,6 +369,10 @@ enum {
  * @vport_mac: The MAC address on the vport, only for PFs; VFs will be zero
  * @vlan_list: List of VLANs added over the interface. Serialised by vlan_lock.
  * @vlan_lock: Lock to serialize access to vlan_list.
+ * @udp_tunnels: UDP tunnel port numbers and types.
+ * @udp_tunnels_dirty: flag indicating a reboot occurred while pushing
+ *	@udp_tunnels to hardware and thus the push must be re-done.
+ * @udp_tunnels_lock: Serialises writes to @udp_tunnels and @udp_tunnels_dirty.
  */
 struct efx_ef10_nic_data {
 	struct efx_buffer mcdi_buf;
@@ -405,6 +409,9 @@ struct efx_ef10_nic_data {
 	u8 vport_mac[ETH_ALEN];
 	struct list_head vlan_list;
 	struct mutex vlan_lock;
+	struct efx_udp_tunnel udp_tunnels[16];
+	bool udp_tunnels_dirty;
+	struct mutex udp_tunnels_lock;
 };
 
 int efx_init_sriov(void);
diff --git a/drivers/net/ethernet/sfc/siena.c b/drivers/net/ethernet/sfc/siena.c
index af7cd85..b1d36df 100644
--- a/drivers/net/ethernet/sfc/siena.c
+++ b/drivers/net/ethernet/sfc/siena.c
@@ -326,6 +326,7 @@ static int siena_probe_nic(struct efx_nic *efx)
 	efx_nic_free_buffer(efx, &efx->irq_status);
 fail4:
 fail3:
+	efx_mcdi_detach(efx);
 	efx_mcdi_fini(efx);
 fail1:
 	kfree(efx->nic_data);
@@ -450,6 +451,7 @@ static void siena_remove_nic(struct efx_nic *efx)
 
 	efx_mcdi_reset(efx, RESET_TYPE_ALL);
 
+	efx_mcdi_detach(efx);
 	efx_mcdi_fini(efx);
 
 	/* Tear down the private nic state */
