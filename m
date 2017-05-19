From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 09/13] nfp: move refresh tracking into the port structure
Date: Fri, 19 May 2017 15:01:51 -0700
Message-ID: <20170519220155.27857-10-jakub.kicinski@netronome.com>
References: <20170519220155.27857-1-jakub.kicinski@netronome.com>
Cc: kubakici@wp.pl, oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f52.google.com ([74.125.83.52]:32807 "EHLO
        mail-pg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932679AbdESWCd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 May 2017 18:02:33 -0400
Received: by mail-pg0-f52.google.com with SMTP id u187so43650109pgb.0
        for <netdev@vger.kernel.org>; Fri, 19 May 2017 15:02:28 -0700 (PDT)
In-Reply-To: <20170519220155.27857-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Track whether physical port's state have changed since last refresh
inside the nfp_port structure instead of the vNIC structure.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Simon Horman <simon.horman@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net.h         |  4 ----
 drivers/net/ethernet/netronome/nfp/nfp_net_common.c  | 16 ++--------------
 drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c | 10 +++++-----
 drivers/net/ethernet/netronome/nfp/nfp_net_main.c    | 10 ++++++++--
 drivers/net/ethernet/netronome/nfp/nfp_port.h        | 13 +++++++++++++
 5 files changed, 28 insertions(+), 25 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net.h b/drivers/net/ethernet/netronome/nfp/nfp_net.h
index 6a774ac54237..4d45ba2d355f 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net.h
@@ -543,7 +543,6 @@ struct nfp_net_dp {
  * @reconfig_sync_present:  Some thread is performing synchronous reconfig
  * @reconfig_timer:	Timer for async reading of reconfig results
  * @link_up:            Is the link up?
- * @link_changed:	Has link state changes since last port refresh?
  * @link_status_lock:	Protects @link_* and ensures atomicity with BAR reading
  * @rx_coalesce_usecs:      RX interrupt moderation usecs delay parameter
  * @rx_coalesce_max_frames: RX interrupt moderation frame count parameter
@@ -601,7 +600,6 @@ struct nfp_net {
 	u32 me_freq_mhz;
 
 	bool link_up;
-	bool link_changed;
 	spinlock_t link_status_lock;
 
 	spinlock_t reconfig_lock;
@@ -835,8 +833,6 @@ struct nfp_net_dp *nfp_net_clone_dp(struct nfp_net *nn);
 int nfp_net_ring_reconfig(struct nfp_net *nn, struct nfp_net_dp *new,
 			  struct netlink_ext_ack *extack);
 
-bool nfp_net_link_changed_read_clear(struct nfp_net *nn);
-
 #ifdef CONFIG_NFP_DEBUG
 void nfp_net_debugfs_create(void);
 void nfp_net_debugfs_destroy(void);
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index 25ec0371e280..f9d8f4311f15 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -392,19 +392,6 @@ static irqreturn_t nfp_net_irq_rxtx(int irq, void *data)
 	return IRQ_HANDLED;
 }
 
-bool nfp_net_link_changed_read_clear(struct nfp_net *nn)
-{
-	unsigned long flags;
-	bool ret;
-
-	spin_lock_irqsave(&nn->link_status_lock, flags);
-	ret = nn->link_changed;
-	nn->link_changed = false;
-	spin_unlock_irqrestore(&nn->link_status_lock, flags);
-
-	return ret;
-}
-
 /**
  * nfp_net_read_link_status() - Reread link status from control BAR
  * @nn:       NFP Network structure
@@ -424,7 +411,8 @@ static void nfp_net_read_link_status(struct nfp_net *nn)
 		goto out;
 
 	nn->link_up = link_up;
-	nn->link_changed = true;
+	if (nn->port)
+		set_bit(NFP_PORT_CHANGED, &nn->port->flags);
 
 	if (nn->link_up) {
 		netif_carrier_on(nn->dp.netdev);
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c b/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c
index e9c860a6dbb8..050629df5cff 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c
@@ -217,15 +217,11 @@ nfp_net_get_link_ksettings(struct net_device *netdev,
 	if (!netif_carrier_ok(netdev))
 		return 0;
 
-	if (!nfp_netdev_is_nfp_net(netdev))
-		return -EOPNOTSUPP;
-	nn = netdev_priv(netdev);
-
 	/* Use link speed from ETH table if available, otherwise try the BAR */
 	if (eth_port) {
 		int err;
 
-		if (nfp_net_link_changed_read_clear(nn)) {
+		if (test_bit(NFP_PORT_CHANGED, &port->flags)) {
 			err = nfp_net_refresh_eth_port(port);
 			if (err)
 				return err;
@@ -237,6 +233,10 @@ nfp_net_get_link_ksettings(struct net_device *netdev,
 		return 0;
 	}
 
+	if (!nfp_netdev_is_nfp_net(netdev))
+		return -EOPNOTSUPP;
+	nn = netdev_priv(netdev);
+
 	sts = nn_readl(nn, NFP_NET_CFG_STS);
 
 	ls = FIELD_GET(NFP_NET_CFG_STS_LINK_RATE, sts);
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_main.c b/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
index 7bed799dee83..0114071dc0fd 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
@@ -555,16 +555,19 @@ static void nfp_net_refresh_vnics(struct work_struct *work)
 	if (list_empty(&pf->vnics))
 		goto out;
 
+	/* Update state of all ports */
+	rtnl_lock();
 	list_for_each_entry(nn, &pf->vnics, vnic_list)
-		nfp_net_link_changed_read_clear(nn);
+		if (nn->port)
+			clear_bit(NFP_PORT_CHANGED, &nn->port->flags);
 
 	eth_table = nfp_eth_read_ports(pf->cpp);
 	if (!eth_table) {
+		rtnl_unlock();
 		nfp_err(pf->cpp, "Error refreshing port config!\n");
 		goto out;
 	}
 
-	rtnl_lock();
 	list_for_each_entry(nn, &pf->vnics, vnic_list) {
 		if (!__nfp_port_get_eth_port(nn->port))
 			continue;
@@ -575,6 +578,7 @@ static void nfp_net_refresh_vnics(struct work_struct *work)
 
 	kfree(eth_table);
 
+	/* Shoot off the ports which became invalid */
 	list_for_each_entry_safe(nn, next, &pf->vnics, vnic_list) {
 		if (!nn->port || nn->port->type != NFP_PORT_INVALID)
 			continue;
@@ -604,6 +608,8 @@ int nfp_net_refresh_eth_port(struct nfp_port *port)
 	struct nfp_eth_table *eth_table;
 	int ret;
 
+	clear_bit(NFP_PORT_CHANGED, &port->flags);
+
 	eth_table = nfp_eth_read_ports(cpp);
 	if (!eth_table) {
 		nfp_err(cpp, "Error refreshing port state table!\n");
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_port.h b/drivers/net/ethernet/netronome/nfp/nfp_port.h
index a23a2c02bc14..d674c8623a65 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_port.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_port.h
@@ -51,9 +51,20 @@ enum nfp_port_type {
 };
 
 /**
+ * enum nfp_port_flags - port flags (can be type-specific)
+ * @NFP_PORT_CHANGED:	port state has changed since last eth table refresh;
+ *			for NFP_PORT_PHYS_PORT, never set otherwise; must hold
+ *			rtnl_lock to clear
+ */
+enum nfp_port_flags {
+	NFP_PORT_CHANGED = 0,
+};
+
+/**
  * struct nfp_port - structure representing NFP port
  * @netdev:	backpointer to associated netdev
  * @type:	what port type does the entity represent
+ * @flags:	port flags
  * @app:	backpointer to the app structure
  * @eth_id:	for %NFP_PORT_PHYS_PORT port ID in NFP enumeration scheme
  * @eth_port:	for %NFP_PORT_PHYS_PORT translated ETH Table port entry
@@ -62,6 +73,8 @@ struct nfp_port {
 	struct net_device *netdev;
 	enum nfp_port_type type;
 
+	unsigned long flags;
+
 	struct nfp_app *app;
 
 	unsigned int eth_id;
-- 
2.11.0
