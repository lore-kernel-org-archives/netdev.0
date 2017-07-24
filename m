From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 10/10] bnxt_en: add support for port_attr_get and and get_phys_port_name
Date: Mon, 24 Jul 2017 12:34:29 -0400
Message-ID: <1500914069-15724-11-git-send-email-michael.chan@broadcom.com>
References: <1500914069-15724-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org, Sathya Perla <sathya.perla@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f176.google.com ([209.85.216.176]:34044 "EHLO
        mail-qt0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753950AbdGXQey (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Jul 2017 12:34:54 -0400
Received: by mail-qt0-f176.google.com with SMTP id s6so24153622qtc.1
        for <netdev@vger.kernel.org>; Mon, 24 Jul 2017 09:34:54 -0700 (PDT)
In-Reply-To: <1500914069-15724-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sathya Perla <sathya.perla@broadcom.com>

This patch adds support for the switchdev_port_attr_get() and
ndo_get_phys_port_name() methods for the PF and the VF-reps.
Using this support a user application can deduce that the PF
(when in the ESWITCH_SWDEV mode) and it's VF-reps form a switch.

Signed-off-by: Sathya Perla <sathya.perla@broadcom.com>
Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c     | 57 +++++++++++++++++++++++++++
 drivers/net/ethernet/broadcom/bnxt/bnxt.h     |  2 +
 drivers/net/ethernet/broadcom/bnxt/bnxt_vfr.c | 31 ++++++++++++++-
 3 files changed, 89 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index f262fe6..82cbe18 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -7546,6 +7546,61 @@ static int bnxt_bridge_setlink(struct net_device *dev, struct nlmsghdr *nlh,
 	return rc;
 }
 
+static int bnxt_get_phys_port_name(struct net_device *dev, char *buf,
+				   size_t len)
+{
+	struct bnxt *bp = netdev_priv(dev);
+	int rc;
+
+	/* The PF and it's VF-reps only support the switchdev framework */
+	if (!BNXT_PF(bp))
+		return -EOPNOTSUPP;
+
+	/* The switch-id that the pf belongs to is exported by
+	 * the switchdev ndo. This name is just to distinguish from the
+	 * vf-rep ports.
+	 */
+	rc = snprintf(buf, len, "pf%d", bp->pf.port_id);
+
+	if (rc >= len)
+		return -EOPNOTSUPP;
+	return 0;
+}
+
+int bnxt_port_attr_get(struct bnxt *bp, struct switchdev_attr *attr)
+{
+	if (bp->eswitch_mode != DEVLINK_ESWITCH_MODE_SWITCHDEV)
+		return -EOPNOTSUPP;
+
+	/* The PF and it's VF-reps only support the switchdev framework */
+	if (!BNXT_PF(bp))
+		return -EOPNOTSUPP;
+
+	switch (attr->id) {
+	case SWITCHDEV_ATTR_ID_PORT_PARENT_ID:
+		/* In SRIOV each PF-pool (PF + child VFs) serves as a
+		 * switching domain, the PF's perm mac-addr can be used
+		 * as the unique parent-id
+		 */
+		attr->u.ppid.id_len = ETH_ALEN;
+		ether_addr_copy(attr->u.ppid.id, bp->pf.mac_addr);
+		break;
+	default:
+		return -EOPNOTSUPP;
+	}
+	return 0;
+}
+
+static int bnxt_swdev_port_attr_get(struct net_device *dev,
+				    struct switchdev_attr *attr)
+{
+	return bnxt_port_attr_get(netdev_priv(dev), attr);
+}
+
+static const struct switchdev_ops bnxt_switchdev_ops = {
+	.switchdev_port_attr_get	= bnxt_swdev_port_attr_get
+};
+
 static const struct net_device_ops bnxt_netdev_ops = {
 	.ndo_open		= bnxt_open,
 	.ndo_start_xmit		= bnxt_start_xmit,
@@ -7579,6 +7634,7 @@ static int bnxt_bridge_setlink(struct net_device *dev, struct nlmsghdr *nlh,
 	.ndo_xdp		= bnxt_xdp,
 	.ndo_bridge_getlink	= bnxt_bridge_getlink,
 	.ndo_bridge_setlink	= bnxt_bridge_setlink,
+	.ndo_get_phys_port_name = bnxt_get_phys_port_name
 };
 
 static void bnxt_remove_one(struct pci_dev *pdev)
@@ -7838,6 +7894,7 @@ static int bnxt_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	dev->netdev_ops = &bnxt_netdev_ops;
 	dev->watchdog_timeo = BNXT_TX_TIMEOUT;
 	dev->ethtool_ops = &bnxt_ethtool_ops;
+	dev->switchdev_ops = &bnxt_switchdev_ops;
 	pci_set_drvdata(pdev, dev);
 
 	rc = bnxt_alloc_hwrm_resources(bp);
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.h b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
index 63756f0..2d84d57 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
@@ -21,6 +21,7 @@
 #include <linux/interrupt.h>
 #include <net/devlink.h>
 #include <net/dst_metadata.h>
+#include <net/switchdev.h>
 
 struct tx_bd {
 	__le32 tx_bd_len_flags_type;
@@ -1350,4 +1351,5 @@ int bnxt_reserve_rings(struct bnxt *bp, int tx, int rx, bool sh, int tcs,
 int bnxt_setup_mq_tc(struct net_device *dev, u8 tc);
 int bnxt_get_max_rings(struct bnxt *, int *, int *, bool);
 void bnxt_restore_pf_fw_resources(struct bnxt *bp);
+int bnxt_port_attr_get(struct bnxt *bp, struct switchdev_attr *attr);
 #endif
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_vfr.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_vfr.c
index 60bdb181..83478e9 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_vfr.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_vfr.c
@@ -135,6 +135,18 @@ void bnxt_vf_rep_rx(struct bnxt *bp, struct sk_buff *skb)
 	netif_receive_skb(skb);
 }
 
+static int bnxt_vf_rep_get_phys_port_name(struct net_device *dev, char *buf,
+					  size_t len)
+{
+	struct bnxt_vf_rep *vf_rep = netdev_priv(dev);
+	int rc;
+
+	rc = snprintf(buf, len, "vfr%d", vf_rep->vf_idx);
+	if (rc >= len)
+		return -EOPNOTSUPP;
+	return 0;
+}
+
 static void bnxt_vf_rep_get_drvinfo(struct net_device *dev,
 				    struct ethtool_drvinfo *info)
 {
@@ -142,6 +154,21 @@ static void bnxt_vf_rep_get_drvinfo(struct net_device *dev,
 	strlcpy(info->version, DRV_MODULE_VERSION, sizeof(info->version));
 }
 
+static int bnxt_vf_rep_port_attr_get(struct net_device *dev,
+				     struct switchdev_attr *attr)
+{
+	struct bnxt_vf_rep *vf_rep = netdev_priv(dev);
+
+	/* as only PORT_PARENT_ID is supported currently use common code
+	 * between PF and VF-rep for now.
+	 */
+	return bnxt_port_attr_get(vf_rep->bp, attr);
+}
+
+static const struct switchdev_ops bnxt_vf_rep_switchdev_ops = {
+	.switchdev_port_attr_get	= bnxt_vf_rep_port_attr_get
+};
+
 static const struct ethtool_ops bnxt_vf_rep_ethtool_ops = {
 	.get_drvinfo		= bnxt_vf_rep_get_drvinfo
 };
@@ -150,7 +177,8 @@ static void bnxt_vf_rep_get_drvinfo(struct net_device *dev,
 	.ndo_open		= bnxt_vf_rep_open,
 	.ndo_stop		= bnxt_vf_rep_close,
 	.ndo_start_xmit		= bnxt_vf_rep_xmit,
-	.ndo_get_stats64	= bnxt_vf_rep_get_stats64
+	.ndo_get_stats64	= bnxt_vf_rep_get_stats64,
+	.ndo_get_phys_port_name = bnxt_vf_rep_get_phys_port_name
 };
 
 /* Called when the parent PF interface is closed:
@@ -274,6 +302,7 @@ static void bnxt_vf_rep_netdev_init(struct bnxt *bp, struct bnxt_vf_rep *vf_rep,
 
 	dev->netdev_ops = &bnxt_vf_rep_netdev_ops;
 	dev->ethtool_ops = &bnxt_vf_rep_ethtool_ops;
+	dev->switchdev_ops = &bnxt_vf_rep_switchdev_ops;
 	/* Just inherit all the featues of the parent PF as the VF-R
 	 * uses the RX/TX rings of the parent PF
 	 */
-- 
1.8.3.1
