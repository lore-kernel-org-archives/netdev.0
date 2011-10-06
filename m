From: John Fastabend <john.r.fastabend@intel.com>
Subject: [PATCH] fcoe: add DCB notifiers to set skb priority
Date: Thu, 06 Oct 2011 11:56:14 -0700
Message-ID: <20111006185614.2868.6375.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org,
	gospo@redhat.com, davem@davemloft.net
To: devel@open-fcoe.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:16644 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759049Ab1JFTFP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Oct 2011 15:05:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use DCB notifiers to set the skb priority to allow packets
to be steered and tagged correctly over DCB enabled drivers
that setup traffic classes.

This allows queue_mapping() routines to be removed in these
drivers that were previously inspecting the ethertype of
every skb to mark FCoE/FIP frames.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---

 drivers/scsi/fcoe/fcoe.c      |  115 +++++++++++++++++++++++++++++++++++++++++
 drivers/scsi/fcoe/fcoe_ctlr.c |    4 +
 include/scsi/libfcoe.h        |    3 +
 3 files changed, 122 insertions(+), 0 deletions(-)

diff --git a/drivers/scsi/fcoe/fcoe.c b/drivers/scsi/fcoe/fcoe.c
index 430b2cd..73d3459 100644
--- a/drivers/scsi/fcoe/fcoe.c
+++ b/drivers/scsi/fcoe/fcoe.c
@@ -32,6 +32,8 @@
 #include <linux/sysfs.h>
 #include <linux/ctype.h>
 #include <linux/workqueue.h>
+#include <net/dcbnl.h>
+#include <net/dcbevent.h>
 #include <scsi/scsi_tcq.h>
 #include <scsi/scsicam.h>
 #include <scsi/scsi_transport.h>
@@ -102,6 +104,8 @@ static int fcoe_ddp_done(struct fc_lport *, u16);
 static int fcoe_ddp_target(struct fc_lport *, u16, struct scatterlist *,
 			   unsigned int);
 static int fcoe_cpu_callback(struct notifier_block *, unsigned long, void *);
+static int fcoe_dcb_app_notification(struct notifier_block *notifier,
+				     ulong event, void *ptr);
 
 static bool fcoe_match(struct net_device *netdev);
 static int fcoe_create(struct net_device *netdev, enum fip_state fip_mode);
@@ -130,6 +134,11 @@ static struct notifier_block fcoe_cpu_notifier = {
 	.notifier_call = fcoe_cpu_callback,
 };
 
+/* notification function for DCB events */
+static struct notifier_block dcb_notifier = {
+	.notifier_call = fcoe_dcb_app_notification,
+};
+
 static struct scsi_transport_template *fcoe_nport_scsi_transport;
 static struct scsi_transport_template *fcoe_vport_scsi_transport;
 
@@ -1541,6 +1550,8 @@ int fcoe_xmit(struct fc_lport *lport, struct fc_frame *fp)
 	skb_reset_network_header(skb);
 	skb->mac_len = elen;
 	skb->protocol = htons(ETH_P_FCOE);
+	skb->priority = port->priority;
+
 	if (fcoe->netdev->priv_flags & IFF_802_1Q_VLAN &&
 	    fcoe->realdev->features & NETIF_F_HW_VLAN_TX) {
 		skb->vlan_tci = VLAN_TAG_PRESENT |
@@ -1765,6 +1776,7 @@ int fcoe_percpu_receive_thread(void *arg)
  */
 static void fcoe_dev_setup(void)
 {
+	register_dcbevent_notifier(&dcb_notifier);
 	register_netdevice_notifier(&fcoe_notifier);
 }
 
@@ -1773,9 +1785,69 @@ static void fcoe_dev_setup(void)
  */
 static void fcoe_dev_cleanup(void)
 {
+	unregister_dcbevent_notifier(&dcb_notifier);
 	unregister_netdevice_notifier(&fcoe_notifier);
 }
 
+static struct fcoe_interface *
+fcoe_hostlist_lookup_realdev_port(struct net_device *netdev)
+{
+	struct fcoe_interface *fcoe;
+	struct net_device *real_dev;
+
+	list_for_each_entry(fcoe, &fcoe_hostlist, list) {
+		if (fcoe->netdev->priv_flags & IFF_802_1Q_VLAN)
+			real_dev = vlan_dev_real_dev(fcoe->netdev);
+		else
+			real_dev = fcoe->netdev;
+
+		if (netdev == real_dev)
+			return fcoe;
+	}
+	return NULL;
+}
+
+static int fcoe_dcb_app_notification(struct notifier_block *notifier,
+				     ulong event, void *ptr)
+{
+	struct dcb_app_type *entry = ptr;
+	struct fcoe_interface *fcoe;
+	struct net_device *netdev;
+	struct fcoe_port *port;
+	int prio;
+
+	if (entry->app.selector != DCB_APP_IDTYPE_ETHTYPE)
+		return NOTIFY_OK;
+
+	netdev = dev_get_by_index(&init_net, entry->ifindex);
+	if (!netdev)
+		return NOTIFY_OK;
+
+	fcoe = fcoe_hostlist_lookup_realdev_port(netdev);
+	dev_put(netdev);
+	if (!fcoe)
+		return NOTIFY_OK;
+
+	if (entry->dcbx & DCB_CAP_DCBX_VER_CEE)
+		prio = ffs(entry->app.priority) - 1;
+	else
+		prio = entry->app.priority;
+
+	if (prio < 0)
+		return NOTIFY_OK;
+
+	if (entry->app.protocol == ETH_P_FIP ||
+	    entry->app.protocol == ETH_P_FCOE)
+		fcoe->ctlr.priority = prio;
+
+	if (entry->app.protocol == ETH_P_FCOE) {
+		port = lport_priv(fcoe->ctlr.lp);
+		port->priority = prio;
+	}
+
+	return NOTIFY_OK;
+}
+
 /**
  * fcoe_device_notification() - Handler for net device events
  * @notifier: The context of the notification
@@ -1984,6 +2056,46 @@ static bool fcoe_match(struct net_device *netdev)
 }
 
 /**
+ * fcoe_dcb_create() - Initialize DCB attributes and hooks
+ * @netdev: The net_device object of the L2 link that should be queried
+ * @port: The fcoe_port to bind FCoE APP priority with
+ * @
+ */
+static void fcoe_dcb_create(struct fcoe_interface *fcoe)
+{
+#ifdef CONFIG_DCB
+	int dcbx;
+	u8 fup, up;
+	struct net_device *netdev = fcoe->realdev;
+	struct fcoe_port *port = lport_priv(fcoe->ctlr.lp);
+	struct dcb_app app = {
+				.priority = 0,
+				.protocol = ETH_P_FCOE
+			     };
+
+	/* setup DCB priority attributes. */
+	if (netdev && netdev->dcbnl_ops && netdev->dcbnl_ops->getdcbx) {
+		dcbx = netdev->dcbnl_ops->getdcbx(netdev);
+
+		if (dcbx & DCB_CAP_DCBX_VER_IEEE) {
+			app.selector = IEEE_8021QAZ_APP_SEL_ETHERTYPE;
+			up = dcb_ieee_getapp_mask(netdev, &app);
+			app.protocol = ETH_P_FIP;
+			fup = dcb_ieee_getapp_mask(netdev, &app);
+		} else {
+			app.selector = DCB_APP_IDTYPE_ETHTYPE;
+			up = dcb_getapp(netdev, &app);
+			app.protocol = ETH_P_FIP;
+			fup = dcb_getapp(netdev, &app);
+		}
+
+		port->priority = ffs(up) ? ffs(up) - 1 : 0;
+		fcoe->ctlr.priority = ffs(fup) ? ffs(fup) - 1 : port->priority;
+	}
+#endif
+}
+
+/**
  * fcoe_create() - Create a fcoe interface
  * @netdev  : The net_device object the Ethernet interface to create on
  * @fip_mode: The FIP mode for this creation
@@ -2026,6 +2138,9 @@ static int fcoe_create(struct net_device *netdev, enum fip_state fip_mode)
 	/* Make this the "master" N_Port */
 	fcoe->ctlr.lp = lport;
 
+	/* setup DCB priority attributes. */
+	fcoe_dcb_create(fcoe);
+
 	/* add to lports list */
 	fcoe_hostlist_add(lport);
 
diff --git a/drivers/scsi/fcoe/fcoe_ctlr.c b/drivers/scsi/fcoe/fcoe_ctlr.c
index c74c4b8..e7522dc 100644
--- a/drivers/scsi/fcoe/fcoe_ctlr.c
+++ b/drivers/scsi/fcoe/fcoe_ctlr.c
@@ -320,6 +320,7 @@ static void fcoe_ctlr_solicit(struct fcoe_ctlr *fip, struct fcoe_fcf *fcf)
 
 	skb_put(skb, sizeof(*sol));
 	skb->protocol = htons(ETH_P_FIP);
+	skb->priority = fip->priority;
 	skb_reset_mac_header(skb);
 	skb_reset_network_header(skb);
 	fip->send(fip, skb);
@@ -474,6 +475,7 @@ static void fcoe_ctlr_send_keep_alive(struct fcoe_ctlr *fip,
 	}
 	skb_put(skb, len);
 	skb->protocol = htons(ETH_P_FIP);
+	skb->priority = fip->priority;
 	skb_reset_mac_header(skb);
 	skb_reset_network_header(skb);
 	fip->send(fip, skb);
@@ -566,6 +568,7 @@ static int fcoe_ctlr_encaps(struct fcoe_ctlr *fip, struct fc_lport *lport,
 	cap->fip.fip_dl_len = htons(dlen / FIP_BPW);
 
 	skb->protocol = htons(ETH_P_FIP);
+	skb->priority = fip->priority;
 	skb_reset_mac_header(skb);
 	skb_reset_network_header(skb);
 	return 0;
@@ -1911,6 +1914,7 @@ static void fcoe_ctlr_vn_send(struct fcoe_ctlr *fip,
 
 	skb_put(skb, len);
 	skb->protocol = htons(ETH_P_FIP);
+	skb->priority = fip->priority;
 	skb_reset_mac_header(skb);
 	skb_reset_network_header(skb);
 
diff --git a/include/scsi/libfcoe.h b/include/scsi/libfcoe.h
index 8c1638b..6e4829d 100644
--- a/include/scsi/libfcoe.h
+++ b/include/scsi/libfcoe.h
@@ -147,6 +147,7 @@ struct fcoe_ctlr {
 	u8 map_dest;
 	u8 spma;
 	u8 probe_tries;
+	u8 priority;
 	u8 dest_addr[ETH_ALEN];
 	u8 ctl_src_addr[ETH_ALEN];
 
@@ -296,6 +297,7 @@ struct fcoe_percpu_s {
  * @lport:		       The associated local port
  * @fcoe_pending_queue:	       The pending Rx queue of skbs
  * @fcoe_pending_queue_active: Indicates if the pending queue is active
+ * @priority:		       Packet priority (DCB)
  * @max_queue_depth:	       Max queue depth of pending queue
  * @min_queue_depth:	       Min queue depth of pending queue
  * @timer:		       The queue timer
@@ -311,6 +313,7 @@ struct fcoe_port {
 	struct fc_lport	      *lport;
 	struct sk_buff_head   fcoe_pending_queue;
 	u8		      fcoe_pending_queue_active;
+	u8		      priority;
 	u32		      max_queue_depth;
 	u32		      min_queue_depth;
 	struct timer_list     timer;
