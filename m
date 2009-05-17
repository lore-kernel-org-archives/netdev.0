From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 03/11] fcoe: consolidates netdev related config
	and cleanup for spma mode
Date: Sun, 17 May 2009 15:33:08 -0700
Message-ID: <20090517223308.14124.68495.stgit@localhost.localdomain>
References: <20090517223213.14124.61405.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-scsi@vger.kernel.org,
	Vasu Dev <vasu.dev@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <20090517223213.14124.61405.stgit@localhost.localdomain>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vasu Dev <vasu.dev@intel.com>

Currently fcoe_netdev_config adds netdev pkt handler for fcoe pkts,
fcoe_if_create adds netdev pkt handler for fip packets, a secondary
MAC address is added by fcoe_netdev_config and then later cleanup
for these netdev related config/adds is done only during
fcoe_if_destroy and no cleanup done on error during fcoe interface
creation after above netdev config calling in fcoe_if_create.

So this patch adds single func for above mentioned cleanup the
fcoe_netdev_cleanup and then calls this func on either fcoe interface
destroy or exiting from fcoe_if_create due to an error after fcoe/fip
related above netdev config is done.

Moved netdev pkt handler addition code blocks for fip pkts close to
similar code block for foce pkt in fcoe_netdev_config, so that added
fcoe_netdev_cleanup could be called on error from fcoe_netdev_config
to undo these both additions for fcoe/fip pkt handlers. This move
required reference to fcoe_fip_recv in fcoe_netdev_config, so moved
fip related functions fcoe_fip_recv, fcoe_fip_send and
fcoe_update_src_mac above fcoe_netdev_config.

This consolidation will enable spma mode support in next patch to
easily add or delete spma mode mac address beside fixing current
no cleanup issue during error.

Signed-off-by: Vasu Dev <vasu.dev@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/scsi/fcoe/fcoe.c |  173 +++++++++++++++++++++++++---------------------
 1 files changed, 94 insertions(+), 79 deletions(-)

diff --git a/drivers/scsi/fcoe/fcoe.c b/drivers/scsi/fcoe/fcoe.c
index 94e1e31..04f5005 100644
--- a/drivers/scsi/fcoe/fcoe.c
+++ b/drivers/scsi/fcoe/fcoe.c
@@ -136,6 +136,58 @@ static struct scsi_host_template fcoe_shost_template = {
 };
 
 /**
+ * fcoe_fip_recv - handle a received FIP frame.
+ * @skb: the receive skb
+ * @dev: associated &net_device
+ * @ptype: the &packet_type structure which was used to register this handler.
+ * @orig_dev: original receive &net_device, in case @dev is a bond.
+ *
+ * Returns: 0 for success
+ */
+static int fcoe_fip_recv(struct sk_buff *skb, struct net_device *dev,
+			 struct packet_type *ptype,
+			 struct net_device *orig_dev)
+{
+	struct fcoe_softc *fc;
+
+	fc = container_of(ptype, struct fcoe_softc, fip_packet_type);
+	fcoe_ctlr_recv(&fc->ctlr, skb);
+	return 0;
+}
+
+/**
+ * fcoe_fip_send() - send an Ethernet-encapsulated FIP frame.
+ * @fip: FCoE controller.
+ * @skb: FIP Packet.
+ */
+static void fcoe_fip_send(struct fcoe_ctlr *fip, struct sk_buff *skb)
+{
+	skb->dev = fcoe_from_ctlr(fip)->real_dev;
+	dev_queue_xmit(skb);
+}
+
+/**
+ * fcoe_update_src_mac() - Update Ethernet MAC filters.
+ * @fip: FCoE controller.
+ * @old: Unicast MAC address to delete if the MAC is non-zero.
+ * @new: Unicast MAC address to add.
+ *
+ * Remove any previously-set unicast MAC filter.
+ * Add secondary FCoE MAC address filter for our OUI.
+ */
+static void fcoe_update_src_mac(struct fcoe_ctlr *fip, u8 *old, u8 *new)
+{
+	struct fcoe_softc *fc;
+
+	fc = fcoe_from_ctlr(fip);
+	rtnl_lock();
+	if (!is_zero_ether_addr(old))
+		dev_unicast_delete(fc->real_dev, old, ETH_ALEN);
+	dev_unicast_add(fc->real_dev, new, ETH_ALEN);
+	rtnl_unlock();
+}
+
+/**
  * fcoe_lport_config() - sets up the fc_lport
  * @lp: ptr to the fc_lport
  * @shost: ptr to the parent scsi host
@@ -168,6 +220,29 @@ static int fcoe_lport_config(struct fc_lport *lp)
 }
 
 /**
+ * fcoe_netdev_cleanup() - clean up netdev configurations
+ * @fc: ptr to the fcoe_softc
+ */
+void fcoe_netdev_cleanup(struct fcoe_softc *fc)
+{
+	u8 flogi_maddr[ETH_ALEN];
+
+	/* Don't listen for Ethernet packets anymore */
+	dev_remove_pack(&fc->fcoe_packet_type);
+	dev_remove_pack(&fc->fip_packet_type);
+
+	/* Delete secondary MAC addresses */
+	rtnl_lock();
+	memcpy(flogi_maddr, (u8[6]) FC_FCOE_FLOGI_MAC, ETH_ALEN);
+	dev_unicast_delete(fc->real_dev, flogi_maddr, ETH_ALEN);
+	if (!is_zero_ether_addr(fc->ctlr.data_src_addr))
+		dev_unicast_delete(fc->real_dev,
+				   fc->ctlr.data_src_addr, ETH_ALEN);
+	dev_mc_delete(fc->real_dev, FIP_ALL_ENODE_MACS, ETH_ALEN, 0);
+	rtnl_unlock();
+}
+
+/**
  * fcoe_netdev_config() - Set up netdev for SW FCoE
  * @lp : ptr to the fc_lport
  * @netdev : ptr to the associated netdevice struct
@@ -267,6 +342,11 @@ static int fcoe_netdev_config(struct fc_lport *lp, struct net_device *netdev)
 	fc->fcoe_packet_type.dev = fc->real_dev;
 	dev_add_pack(&fc->fcoe_packet_type);
 
+	fc->fip_packet_type.func = fcoe_fip_recv;
+	fc->fip_packet_type.type = htons(ETH_P_FIP);
+	fc->fip_packet_type.dev = fc->real_dev;
+	dev_add_pack(&fc->fip_packet_type);
+
 	return 0;
 }
 
@@ -334,7 +414,6 @@ static int fcoe_if_destroy(struct net_device *netdev)
 {
 	struct fc_lport *lp = NULL;
 	struct fcoe_softc *fc;
-	u8 flogi_maddr[ETH_ALEN];
 
 	BUG_ON(!netdev);
 
@@ -353,9 +432,10 @@ static int fcoe_if_destroy(struct net_device *netdev)
 	/* Remove the instance from fcoe's list */
 	fcoe_hostlist_remove(lp);
 
-	/* Don't listen for Ethernet packets anymore */
-	dev_remove_pack(&fc->fcoe_packet_type);
-	dev_remove_pack(&fc->fip_packet_type);
+	/* clean up netdev configurations */
+	fcoe_netdev_cleanup(fc);
+
+	/* tear-down the FCoE controller */
 	fcoe_ctlr_destroy(&fc->ctlr);
 
 	/* Cleanup the fc_lport */
@@ -370,16 +450,6 @@ static int fcoe_if_destroy(struct net_device *netdev)
 	if (lp->emp)
 		fc_exch_mgr_free(lp->emp);
 
-	/* Delete secondary MAC addresses */
-	rtnl_lock();
-	memcpy(flogi_maddr, (u8[6]) FC_FCOE_FLOGI_MAC, ETH_ALEN);
-	dev_unicast_delete(fc->real_dev, flogi_maddr, ETH_ALEN);
-	if (!is_zero_ether_addr(fc->ctlr.data_src_addr))
-		dev_unicast_delete(fc->real_dev,
-				   fc->ctlr.data_src_addr, ETH_ALEN);
-	dev_mc_delete(fc->real_dev, FIP_ALL_ENODE_MACS, ETH_ALEN, 0);
-	rtnl_unlock();
-
 	/* Free the per-CPU revieve threads */
 	fcoe_percpu_clean(lp);
 
@@ -439,58 +509,6 @@ static struct libfc_function_template fcoe_libfc_fcn_templ = {
 };
 
 /**
- * fcoe_fip_recv - handle a received FIP frame.
- * @skb: the receive skb
- * @dev: associated &net_device
- * @ptype: the &packet_type structure which was used to register this handler.
- * @orig_dev: original receive &net_device, in case @dev is a bond.
- *
- * Returns: 0 for success
- */
-static int fcoe_fip_recv(struct sk_buff *skb, struct net_device *dev,
-			 struct packet_type *ptype,
-			 struct net_device *orig_dev)
-{
-	struct fcoe_softc *fc;
-
-	fc = container_of(ptype, struct fcoe_softc, fip_packet_type);
-	fcoe_ctlr_recv(&fc->ctlr, skb);
-	return 0;
-}
-
-/**
- * fcoe_fip_send() - send an Ethernet-encapsulated FIP frame.
- * @fip: FCoE controller.
- * @skb: FIP Packet.
- */
-static void fcoe_fip_send(struct fcoe_ctlr *fip, struct sk_buff *skb)
-{
-	skb->dev = fcoe_from_ctlr(fip)->real_dev;
-	dev_queue_xmit(skb);
-}
-
-/**
- * fcoe_update_src_mac() - Update Ethernet MAC filters.
- * @fip: FCoE controller.
- * @old: Unicast MAC address to delete if the MAC is non-zero.
- * @new: Unicast MAC address to add.
- *
- * Remove any previously-set unicast MAC filter.
- * Add secondary FCoE MAC address filter for our OUI.
- */
-static void fcoe_update_src_mac(struct fcoe_ctlr *fip, u8 *old, u8 *new)
-{
-	struct fcoe_softc *fc;
-
-	fc = fcoe_from_ctlr(fip);
-	rtnl_lock();
-	if (!is_zero_ether_addr(old))
-		dev_unicast_delete(fc->real_dev, old, ETH_ALEN);
-	dev_unicast_add(fc->real_dev, new, ETH_ALEN);
-	rtnl_unlock();
-}
-
-/**
  * fcoe_if_create() - this function creates the fcoe interface
  * @netdev: pointer the associated netdevice
  *
@@ -531,13 +549,6 @@ static int fcoe_if_create(struct net_device *netdev)
 		goto out_host_put;
 	}
 
-	/* configure lport network properties */
-	rc = fcoe_netdev_config(lp, netdev);
-	if (rc) {
-		FC_DBG("Could not configure netdev for lport\n");
-		goto out_host_put;
-	}
-
 	/*
 	 * Initialize FIP.
 	 */
@@ -545,23 +556,25 @@ static int fcoe_if_create(struct net_device *netdev)
 	fc->ctlr.send = fcoe_fip_send;
 	fc->ctlr.update_mac = fcoe_update_src_mac;
 
-	fc->fip_packet_type.func = fcoe_fip_recv;
-	fc->fip_packet_type.type = htons(ETH_P_FIP);
-	fc->fip_packet_type.dev = fc->real_dev;
-	dev_add_pack(&fc->fip_packet_type);
+	/* configure lport network properties */
+	rc = fcoe_netdev_config(lp, netdev);
+	if (rc) {
+		FC_DBG("Could not configure netdev for the interface\n");
+		goto out_netdev_cleanup;
+	}
 
 	/* configure lport scsi host properties */
 	rc = fcoe_shost_config(lp, shost, &netdev->dev);
 	if (rc) {
 		FC_DBG("Could not configure shost for lport\n");
-		goto out_host_put;
+		goto out_netdev_cleanup;
 	}
 
 	/* lport exch manager allocation */
 	rc = fcoe_em_config(lp);
 	if (rc) {
 		FC_DBG("Could not configure em for lport\n");
-		goto out_host_put;
+		goto out_netdev_cleanup;
 	}
 
 	/* Initialize the library */
@@ -587,6 +600,8 @@ static int fcoe_if_create(struct net_device *netdev)
 
 out_lp_destroy:
 	fc_exch_mgr_free(lp->emp); /* Free the EM */
+out_netdev_cleanup:
+	fcoe_netdev_cleanup(fc);
 out_host_put:
 	scsi_host_put(lp->host);
 	return rc;

