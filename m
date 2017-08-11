From: Samuel Mendoza-Jonas <sam@mendozajonas.com>
Subject: [PATCH 3/3] net/ncsi: Configure VLAN tag filter
Date: Fri, 11 Aug 2017 16:16:48 +1000
Message-ID: <20170811061648.19661-4-sam@mendozajonas.com>
References: <20170811061648.19661-1-sam@mendozajonas.com>
Cc: Samuel Mendoza-Jonas <sam@mendozajonas.com>,
        Joel Stanley <joel@jms.id.au>,
        Benjamin Herrenschmidt <benh@kernel.crashing.org>,
        Gavin Shan <gwshan@linux.vnet.ibm.com>, ratagupt@in.ibm.com
To: "David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        OpenBMC Maillist <openbmc@lists.ozlabs.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170811061648.19661-1-sam@mendozajonas.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make use of the ndo_vlan_rx_{add,kill}_vid callbacks to have the NCSI
stack process new VLAN tags and configure the channel VLAN filter
appropriately.
Several VLAN tags can be set and a "Set VLAN Filter" packet must be sent
for each one, meaning the ncsi_dev_state_config_svf state must be
repeated. An internal list of VLAN tags is maintained, and compared
against the current channel's ncsi_channel_filter in order to keep track
within the state. VLAN filters are removed in a similar manner, with the
introduction of the ncsi_dev_state_config_clear_vids state. The maximum
number of VLAN tag filters is determined by the "Get Capabilities"
response from the channel.

Signed-off-by: Samuel Mendoza-Jonas <sam@mendozajonas.com>
---
 drivers/net/ethernet/faraday/ftgmac100.c |   2 +
 include/net/ncsi.h                       |   2 +
 net/ncsi/internal.h                      |  11 ++
 net/ncsi/ncsi-manage.c                   | 295 ++++++++++++++++++++++++++++++-
 net/ncsi/ncsi-rsp.c                      |   9 +-
 5 files changed, 315 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/faraday/ftgmac100.c b/drivers/net/ethernet/faraday/ftgmac100.c
index 7c4d772287c7..5a3661317026 100644
--- a/drivers/net/ethernet/faraday/ftgmac100.c
+++ b/drivers/net/ethernet/faraday/ftgmac100.c
@@ -1623,6 +1623,8 @@ static const struct net_device_ops ftgmac100_netdev_ops = {
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= ftgmac100_poll_controller,
 #endif
+	.ndo_vlan_rx_add_vid	= ncsi_vlan_rx_add_vid,
+	.ndo_vlan_rx_kill_vid	= ncsi_vlan_rx_kill_vid,
 };
 
 static int ftgmac100_setup_mdio(struct net_device *netdev)
diff --git a/include/net/ncsi.h b/include/net/ncsi.h
index 68680baac0fd..1f96af46df49 100644
--- a/include/net/ncsi.h
+++ b/include/net/ncsi.h
@@ -28,6 +28,8 @@ struct ncsi_dev {
 };
 
 #ifdef CONFIG_NET_NCSI
+int ncsi_vlan_rx_add_vid(struct net_device *dev, __be16 proto, u16 vid);
+int ncsi_vlan_rx_kill_vid(struct net_device *dev, __be16 proto, u16 vid);
 struct ncsi_dev *ncsi_register_dev(struct net_device *dev,
 				   void (*notifier)(struct ncsi_dev *nd));
 int ncsi_start_dev(struct ncsi_dev *nd);
diff --git a/net/ncsi/internal.h b/net/ncsi/internal.h
index 1308a56f2591..af3d636534ef 100644
--- a/net/ncsi/internal.h
+++ b/net/ncsi/internal.h
@@ -180,6 +180,7 @@ struct ncsi_channel {
 #define NCSI_CHANNEL_INACTIVE		1
 #define NCSI_CHANNEL_ACTIVE		2
 #define NCSI_CHANNEL_INVISIBLE		3
+	bool                        reconfigure_needed;
 	spinlock_t                  lock;	/* Protect filters etc */
 	struct ncsi_package         *package;
 	struct ncsi_channel_version version;
@@ -235,6 +236,9 @@ enum {
 	ncsi_dev_state_probe_dp,
 	ncsi_dev_state_config_sp	= 0x0301,
 	ncsi_dev_state_config_cis,
+	ncsi_dev_state_config_clear_vids,
+	ncsi_dev_state_config_svf,
+	ncsi_dev_state_config_ev,
 	ncsi_dev_state_config_sma,
 	ncsi_dev_state_config_ebf,
 #if IS_ENABLED(CONFIG_IPV6)
@@ -253,6 +257,12 @@ enum {
 	ncsi_dev_state_suspend_done
 };
 
+struct vlan_vid {
+	struct list_head list;
+	__be16 proto;
+	u16 vid;
+};
+
 struct ncsi_dev_priv {
 	struct ncsi_dev     ndev;            /* Associated NCSI device     */
 	unsigned int        flags;           /* NCSI device flags          */
@@ -276,6 +286,7 @@ struct ncsi_dev_priv {
 	struct work_struct  work;            /* For channel management     */
 	struct packet_type  ptype;           /* NCSI packet Rx handler     */
 	struct list_head    node;            /* Form NCSI device list      */
+	struct list_head    vlan_vids;       /* List of active VLAN IDs */
 };
 
 struct ncsi_cmd_arg {
diff --git a/net/ncsi/ncsi-manage.c b/net/ncsi/ncsi-manage.c
index a3bd5fa8ad09..3cbd4328f142 100644
--- a/net/ncsi/ncsi-manage.c
+++ b/net/ncsi/ncsi-manage.c
@@ -38,6 +38,22 @@ static inline int ncsi_filter_size(int table)
 	return sizes[table];
 }
 
+u32 *ncsi_get_filter(struct ncsi_channel *nc, int table, int index)
+{
+	struct ncsi_channel_filter *ncf;
+	int size;
+
+	ncf = nc->filters[table];
+	if (!ncf)
+		return NULL;
+
+	size = ncsi_filter_size(table);
+	if (size < 0)
+		return NULL;
+
+	return ncf->data + size * index;
+}
+
 int ncsi_find_filter(struct ncsi_channel *nc, int table, void *data)
 {
 	struct ncsi_channel_filter *ncf;
@@ -58,7 +74,7 @@ int ncsi_find_filter(struct ncsi_channel *nc, int table, void *data)
 	index = -1;
 	while ((index = find_next_bit(bitmap, ncf->total, index + 1))
 	       < ncf->total) {
-		if (!memcmp(ncf->data + size * index, data, size)) {
+		if (!data || !memcmp(ncf->data + size * index, data, size)) {
 			spin_unlock_irqrestore(&nc->lock, flags);
 			return index;
 		}
@@ -639,6 +655,83 @@ static void ncsi_suspend_channel(struct ncsi_dev_priv *ndp)
 	nd->state = ncsi_dev_state_functional;
 }
 
+/* Check the VLAN filter bitmap for a set filter, and construct a
+ * "Set VLAN Filter - Disable" packet if found.
+ */
+static int clear_one_vid(struct ncsi_dev_priv *ndp, struct ncsi_channel *nc,
+			 struct ncsi_cmd_arg *nca)
+{
+	int index;
+	u16 vid;
+
+	index = ncsi_find_filter(nc, NCSI_FILTER_VLAN, NULL);
+	if (index < 0) {
+		/* Filter table empty */
+		return -1;
+	}
+
+	vid = *(u16 *)ncsi_get_filter(nc, NCSI_FILTER_VLAN, index);
+	netdev_printk(KERN_DEBUG, ndp->ndev.dev,
+		      "ncsi: removed vlan tag %u at index %d\n",
+		      vid, index + 1);
+	ncsi_remove_filter(nc, NCSI_FILTER_VLAN, index);
+
+	nca->type = NCSI_PKT_CMD_SVF;
+	nca->words[1] = vid;
+	/* HW filter index starts at 1 */
+	nca->bytes[6] = index + 1;
+	nca->bytes[7] = 0x00;
+	return 0;
+}
+
+/* Find an outstanding VLAN tag and constuct a "Set VLAN Filter - Enable"
+ * packet.
+ */
+static int set_one_vid(struct ncsi_dev_priv *ndp, struct ncsi_channel *nc,
+		       struct ncsi_cmd_arg *nca)
+{
+	struct vlan_vid *vlan = NULL;
+	int index = 0;
+
+	list_for_each_entry_rcu(vlan, &ndp->vlan_vids, list) {
+		index = ncsi_find_filter(nc, NCSI_FILTER_VLAN, &vlan->vid);
+		if (index < 0) {
+			/* New tag to add */
+			netdev_printk(KERN_DEBUG, ndp->ndev.dev,
+				      "ncsi: new vlan id to set: %u\n",
+				      vlan->vid);
+			break;
+		}
+		netdev_printk(KERN_DEBUG, ndp->ndev.dev,
+			      "vid %u already at filter pos %d\n",
+			      vlan->vid, index);
+	}
+
+	if (!vlan || index >= 0) {
+		netdev_printk(KERN_DEBUG, ndp->ndev.dev,
+			      "no vlan ids left to set\n");
+		return -1;
+	}
+
+	index = ncsi_add_filter(nc, NCSI_FILTER_VLAN, &vlan->vid);
+	if (index < 0) {
+		netdev_err(ndp->ndev.dev,
+			   "Failed to add new VLAN tag, error %d\n", index);
+		return -1;
+	}
+
+	netdev_printk(KERN_DEBUG, ndp->ndev.dev,
+		      "ncsi: set vid %u in packet, index %u\n",
+		      vlan->vid, index + 1);
+	nca->type = NCSI_PKT_CMD_SVF;
+	nca->words[1] = vlan->vid;
+	/* HW filter index starts at 1 */
+	nca->bytes[6] = index + 1;
+	nca->bytes[7] = 0x01;
+
+	return 0;
+}
+
 static void ncsi_configure_channel(struct ncsi_dev_priv *ndp)
 {
 	struct ncsi_dev *nd = &ndp->ndev;
@@ -683,8 +776,11 @@ static void ncsi_configure_channel(struct ncsi_dev_priv *ndp)
 		if (ret)
 			goto error;
 
-		nd->state = ncsi_dev_state_config_sma;
+		nd->state = ncsi_dev_state_config_clear_vids;
 		break;
+	case ncsi_dev_state_config_clear_vids:
+	case ncsi_dev_state_config_svf:
+	case ncsi_dev_state_config_ev:
 	case ncsi_dev_state_config_sma:
 	case ncsi_dev_state_config_ebf:
 #if IS_ENABLED(CONFIG_IPV6)
@@ -699,11 +795,40 @@ static void ncsi_configure_channel(struct ncsi_dev_priv *ndp)
 		nca.package = np->id;
 		nca.channel = nc->id;
 
+		/* Clear any active filters on the channel before setting */
+		if (nd->state == ncsi_dev_state_config_clear_vids) {
+			ret = clear_one_vid(ndp, nc, &nca);
+			if (ret) {
+				nd->state = ncsi_dev_state_config_svf;
+				schedule_work(&ndp->work);
+				break;
+			}
+			/* Repeat */
+			nd->state = ncsi_dev_state_config_clear_vids;
+		/* Add known VLAN tags to the filter */
+		} else if (nd->state == ncsi_dev_state_config_svf) {
+			ret = set_one_vid(ndp, nc, &nca);
+			if (ret) {
+				nd->state = ncsi_dev_state_config_ev;
+				schedule_work(&ndp->work);
+				break;
+			}
+			/* Repeat */
+			nd->state = ncsi_dev_state_config_svf;
+		/* Enable/Disable the VLAN filter */
+		} else if (nd->state == ncsi_dev_state_config_ev) {
+			if (list_empty(&ndp->vlan_vids)) {
+				nca.type = NCSI_PKT_CMD_DV;
+			} else {
+				nca.type = NCSI_PKT_CMD_EV;
+				nca.bytes[3] = NCSI_CAP_VLAN_NO;
+			}
+			nd->state = ncsi_dev_state_config_sma;
+		} else if (nd->state == ncsi_dev_state_config_sma) {
 		/* Use first entry in unicast filter table. Note that
 		 * the MAC filter table starts from entry 1 instead of
 		 * 0.
 		 */
-		if (nd->state == ncsi_dev_state_config_sma) {
 			nca.type = NCSI_PKT_CMD_SMA;
 			for (index = 0; index < 6; index++)
 				nca.bytes[index] = dev->dev_addr[index];
@@ -751,6 +876,26 @@ static void ncsi_configure_channel(struct ncsi_dev_priv *ndp)
 		break;
 	case ncsi_dev_state_config_done:
 		spin_lock_irqsave(&nc->lock, flags);
+		if (nc->reconfigure_needed) {
+			/* This channel's configuration has been updated
+			 * part-way during the config state - start the
+			 * channel configuration over
+			 */
+			nc->reconfigure_needed = false;
+			nc->state = NCSI_CHANNEL_INVISIBLE;
+			spin_unlock_irqrestore(&nc->lock, flags);
+
+			spin_lock_irqsave(&ndp->lock, flags);
+			nc->state = NCSI_CHANNEL_INACTIVE;
+			list_add_tail_rcu(&nc->link, &ndp->channel_queue);
+			spin_unlock_irqrestore(&ndp->lock, flags);
+
+			netdev_printk(KERN_DEBUG, dev,
+				      "Dirty NCSI channel state reset\n");
+			ncsi_process_next_channel(ndp);
+			break;
+		}
+
 		if (nc->modes[NCSI_MODE_LINK].data[2] & 0x1) {
 			hot_nc = nc;
 			nc->state = NCSI_CHANNEL_ACTIVE;
@@ -1191,6 +1336,149 @@ static struct notifier_block ncsi_inet6addr_notifier = {
 };
 #endif /* CONFIG_IPV6 */
 
+static int ncsi_kick_channels(struct ncsi_dev_priv *ndp)
+{
+	struct ncsi_dev *nd = &ndp->ndev;
+	struct ncsi_channel *nc;
+	struct ncsi_package *np;
+	unsigned long flags;
+	unsigned int n = 0;
+
+	NCSI_FOR_EACH_PACKAGE(ndp, np) {
+		NCSI_FOR_EACH_CHANNEL(np, nc) {
+			spin_lock_irqsave(&nc->lock, flags);
+
+			/* Channels may be busy, mark dirty instead of
+			 * kicking if;
+			 * a) not ACTIVE (configured)
+			 * b) in the channel_queue (to be configured)
+			 * c) it's ndev is in the config state
+			 */
+			if (nc->state != NCSI_CHANNEL_ACTIVE) {
+				if ((ndp->ndev.state & 0xff00) ==
+						ncsi_dev_state_config ||
+						!list_empty(&nc->link)) {
+					netdev_printk(KERN_DEBUG, nd->dev,
+						      "ncsi: channel %p marked dirty\n",
+						      nc);
+					nc->reconfigure_needed = true;
+				}
+				spin_unlock_irqrestore(&nc->lock, flags);
+				continue;
+			}
+
+			spin_unlock_irqrestore(&nc->lock, flags);
+
+			ncsi_stop_channel_monitor(nc);
+			spin_lock_irqsave(&nc->lock, flags);
+			nc->state = NCSI_CHANNEL_INVISIBLE;
+			spin_unlock_irqrestore(&nc->lock, flags);
+
+			spin_lock_irqsave(&ndp->lock, flags);
+			nc->state = NCSI_CHANNEL_INACTIVE;
+			list_add_tail_rcu(&nc->link, &ndp->channel_queue);
+			spin_unlock_irqrestore(&ndp->lock, flags);
+
+			netdev_printk(KERN_DEBUG, nd->dev,
+				      "ncsi: kicked channel %p\n", nc);
+			n++;
+		}
+	}
+
+	return n;
+}
+
+int ncsi_vlan_rx_add_vid(struct net_device *dev, __be16 proto, u16 vid)
+{
+	struct ncsi_channel_filter *ncf;
+	struct ncsi_dev_priv *ndp;
+	unsigned int n_vids = 0;
+	struct vlan_vid *vlan;
+	struct ncsi_dev *nd;
+	bool found = false;
+
+	if (vid == 0)
+		return 0;
+
+	nd = ncsi_find_dev(dev);
+	if (!nd) {
+		netdev_warn(dev, "ncsi: No net_device?\n");
+		return 0;
+	}
+
+	ndp = TO_NCSI_DEV_PRIV(nd);
+	ncf = ndp->hot_channel->filters[NCSI_FILTER_VLAN];
+
+	/* Add the VLAN id to our internal list */
+	list_for_each_entry_rcu(vlan, &ndp->vlan_vids, list) {
+		n_vids++;
+		if (vlan->vid == vid) {
+			netdev_printk(KERN_DEBUG, dev,
+				      "vid %u already registered\n", vid);
+			return 0;
+		}
+	}
+
+	if (n_vids >= ncf->total) {
+		netdev_info(dev,
+			    "NCSI Channel supports up to %u VLAN tags but %u are already set\n",
+			    ncf->total, n_vids);
+		return -EINVAL;
+	}
+
+	vlan = kzalloc(sizeof(*vlan), GFP_KERNEL);
+	if (!vlan)
+		return -ENOMEM;
+
+	vlan->proto = proto;
+	vlan->vid = vid;
+	list_add_rcu(&vlan->list, &ndp->vlan_vids);
+
+	netdev_printk(KERN_DEBUG, dev, "Added new vid %u\n", vid);
+
+	found = ncsi_kick_channels(ndp) != 0;
+
+	return found ? ncsi_process_next_channel(ndp) : 0;
+}
+
+int ncsi_vlan_rx_kill_vid(struct net_device *dev, __be16 proto, u16 vid)
+{
+	struct vlan_vid *vlan, *tmp;
+	struct ncsi_dev_priv *ndp;
+	struct ncsi_dev *nd;
+	bool found = false;
+
+	if (vid == 0)
+		return 0;
+
+	nd = ncsi_find_dev(dev);
+	if (!nd) {
+		netdev_warn(dev, "ncsi: no net_device?\n");
+		return 0;
+	}
+
+	ndp = TO_NCSI_DEV_PRIV(nd);
+
+	/* Remove the VLAN id from our internal list */
+	list_for_each_entry_safe(vlan, tmp, &ndp->vlan_vids, list)
+		if (vlan->vid == vid) {
+			netdev_printk(KERN_DEBUG, dev,
+				      "vid %u found, removing\n", vid);
+			list_del_rcu(&vlan->list);
+			found = true;
+			kfree(vlan);
+		}
+
+	if (!found) {
+		netdev_err(dev, "ncsi: vid %u wasn't registered!\n", vid);
+		return -EINVAL;
+	}
+
+	found = ncsi_kick_channels(ndp) != 0;
+
+	return found ? ncsi_process_next_channel(ndp) : 0;
+}
+
 struct ncsi_dev *ncsi_register_dev(struct net_device *dev,
 				   void (*handler)(struct ncsi_dev *ndev))
 {
@@ -1215,6 +1503,7 @@ struct ncsi_dev *ncsi_register_dev(struct net_device *dev,
 	nd->handler = handler;
 	ndp->pending_req_num = 0;
 	INIT_LIST_HEAD(&ndp->channel_queue);
+	INIT_LIST_HEAD(&ndp->vlan_vids);
 	INIT_WORK(&ndp->work, ncsi_dev_work);
 
 	/* Initialize private NCSI device */
diff --git a/net/ncsi/ncsi-rsp.c b/net/ncsi/ncsi-rsp.c
index c1a191d790e2..265b9a892d41 100644
--- a/net/ncsi/ncsi-rsp.c
+++ b/net/ncsi/ncsi-rsp.c
@@ -694,7 +694,14 @@ static int ncsi_rsp_handler_gc(struct ncsi_request *nr)
 
 		ncf->index = i;
 		ncf->total = cnt;
-		ncf->bitmap = 0x0ul;
+		if (i == NCSI_FILTER_VLAN) {
+			/* Set VLAN filters active so they are cleared in
+			 * first configuration state
+			 */
+			ncf->bitmap = U64_MAX;
+		} else {
+			ncf->bitmap = 0x0ul;
+		}
 		nc->filters[i] = ncf;
 	}
 
-- 
2.14.0
