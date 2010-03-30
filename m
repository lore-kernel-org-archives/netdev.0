From: sjur.brandeland@stericsson.com
Subject: [PATCH net-next-2.6 v8 07/12] net-caif: add CAIF device registration
 functionality
Date: Wed, 31 Mar 2010 01:56:25 +0200
Message-ID: <1269993390-23830-8-git-send-email-sjur.brandeland@stericsson.com>
References: <1269993390-23830-1-git-send-email-sjur.brandeland@stericsson.com>
 <1269993390-23830-2-git-send-email-sjur.brandeland@stericsson.com>
 <1269993390-23830-3-git-send-email-sjur.brandeland@stericsson.com>
 <1269993390-23830-4-git-send-email-sjur.brandeland@stericsson.com>
 <1269993390-23830-5-git-send-email-sjur.brandeland@stericsson.com>
 <1269993390-23830-6-git-send-email-sjur.brandeland@stericsson.com>
 <1269993390-23830-7-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN
Content-Transfer-Encoding: 7BIT
Cc: daniel.martensson@stericsson.com, sjurbr@gmail.com,
	Sjur Braendeland <sjur.brandeland@stericsson.com>
To: davem@davemloft.net, netdev@vger.kernel.org, marcel@holtmann.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eterpe-smout.broadpark.no ([80.202.8.16]:63548 "EHLO
	eterpe-smout.broadpark.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756287Ab0C3X5M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Mar 2010 19:57:12 -0400
Received: from ignis-smin.broadpark.no ([unknown] [80.202.8.11])
 by eterpe-smout.broadpark.no
 (Sun Java(tm) System Messaging Server 7u3-12.01 64bit (built Oct 15 2009))
 with ESMTP id <0L0400CBFD6QAR20@eterpe-smout.broadpark.no> for
 netdev@vger.kernel.org; Wed, 31 Mar 2010 01:56:50 +0200 (CEST)
Received: from localhost.localdomain ([unknown] [84.49.77.207])
 by ignis-smin.broadpark.no
 (Sun Java(tm) System Messaging Server 7u3-12.01 64bit (built Oct 15 2009))
 with ESMTP id <0L04003KXD6FYY70@ignis-smin.broadpark.no> for
 netdev@vger.kernel.org; Wed, 31 Mar 2010 01:56:50 +0200 (CEST)
In-reply-to: <1269993390-23830-7-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sjur Braendeland <sjur.brandeland@stericsson.com>

Registration and deregistration of CAIF Link Layer.

Signed-off-by: Sjur Braendeland <sjur.brandeland@stericsson.com>
---
 net/caif/caif_config_util.c |   87 +++++++++
 net/caif/caif_dev.c         |  413 +++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 500 insertions(+), 0 deletions(-)

diff --git a/net/caif/caif_config_util.c b/net/caif/caif_config_util.c
new file mode 100644
index 0000000..6f36580
--- /dev/null
+++ b/net/caif/caif_config_util.c
@@ -0,0 +1,87 @@
+/*
+ * Copyright (C) ST-Ericsson AB 2010
+ * Author:	Sjur Brendeland sjur.brandeland@stericsson.com
+ * License terms: GNU General Public License (GPL) version 2
+ */
+
+#include <linux/module.h>
+#include <linux/spinlock.h>
+#include <net/caif/cfctrl.h>
+#include <net/caif/cfcnfg.h>
+#include <net/caif/caif_dev.h>
+
+int connect_req_to_link_param(struct cfcnfg *cnfg,
+				struct caif_connect_request *s,
+				struct cfctrl_link_param *l)
+{
+	struct dev_info *dev_info;
+	enum cfcnfg_phy_preference pref;
+	memset(l, 0, sizeof(*l));
+	l->priority = s->priority;
+
+	if (s->link_name[0] != '\0')
+		l->phyid = cfcnfg_get_named(cnfg, s->link_name);
+	else {
+		switch (s->link_selector) {
+		case CAIF_LINK_HIGH_BANDW:
+			pref = CFPHYPREF_HIGH_BW;
+			break;
+		case CAIF_LINK_LOW_LATENCY:
+			pref = CFPHYPREF_LOW_LAT;
+			break;
+		default:
+			return -EINVAL;
+		}
+		dev_info = cfcnfg_get_phyid(cnfg, pref);
+		if (dev_info == NULL)
+			return -ENODEV;
+		l->phyid = dev_info->id;
+	}
+	switch (s->protocol) {
+	case CAIFPROTO_AT:
+		l->linktype = CFCTRL_SRV_VEI;
+		if (s->sockaddr.u.at.type == CAIF_ATTYPE_PLAIN)
+			l->chtype = 0x02;
+		else
+			l->chtype = s->sockaddr.u.at.type;
+		l->endpoint = 0x00;
+		break;
+	case CAIFPROTO_DATAGRAM:
+		l->linktype = CFCTRL_SRV_DATAGRAM;
+		l->chtype = 0x00;
+		l->u.datagram.connid = s->sockaddr.u.dgm.connection_id;
+		break;
+	case CAIFPROTO_DATAGRAM_LOOP:
+		l->linktype = CFCTRL_SRV_DATAGRAM;
+		l->chtype = 0x03;
+		l->endpoint = 0x00;
+		l->u.datagram.connid = s->sockaddr.u.dgm.connection_id;
+		break;
+	case CAIFPROTO_RFM:
+		l->linktype = CFCTRL_SRV_RFM;
+		l->u.datagram.connid = s->sockaddr.u.rfm.connection_id;
+		strncpy(l->u.rfm.volume, s->sockaddr.u.rfm.volume,
+			sizeof(l->u.rfm.volume)-1);
+		l->u.rfm.volume[sizeof(l->u.rfm.volume)-1] = 0;
+		break;
+	case CAIFPROTO_UTIL:
+		l->linktype = CFCTRL_SRV_UTIL;
+		l->endpoint = 0x00;
+		l->chtype = 0x00;
+		strncpy(l->u.utility.name, s->sockaddr.u.util.service,
+			sizeof(l->u.utility.name)-1);
+		l->u.utility.name[sizeof(l->u.utility.name)-1] = 0;
+		caif_assert(sizeof(l->u.utility.name) > 10);
+		l->u.utility.paramlen = s->param.size;
+		if (l->u.utility.paramlen > sizeof(l->u.utility.params))
+			l->u.utility.paramlen = sizeof(l->u.utility.params);
+
+		memcpy(l->u.utility.params, s->param.data,
+		       l->u.utility.paramlen);
+
+		break;
+	default:
+		return -EINVAL;
+	}
+	return 0;
+}
diff --git a/net/caif/caif_dev.c b/net/caif/caif_dev.c
new file mode 100644
index 0000000..e84837e
--- /dev/null
+++ b/net/caif/caif_dev.c
@@ -0,0 +1,413 @@
+/*
+ * CAIF Interface registration.
+ * Copyright (C) ST-Ericsson AB 2010
+ * Author:	Sjur Brendeland/sjur.brandeland@stericsson.com
+ * License terms: GNU General Public License (GPL) version 2
+ *
+ * Borrowed heavily from file: pn_dev.c. Thanks to
+ *  Remi Denis-Courmont <remi.denis-courmont@nokia.com>
+ *  and Sakari Ailus <sakari.ailus@nokia.com>
+ */
+
+#include <linux/version.h>
+#include <linux/module.h>
+#include <linux/kernel.h>
+#include <linux/if_arp.h>
+#include <linux/net.h>
+#include <linux/netdevice.h>
+#include <linux/skbuff.h>
+#include <linux/sched.h>
+#include <linux/wait.h>
+#include <net/netns/generic.h>
+#include <net/net_namespace.h>
+#include <net/pkt_sched.h>
+#include <net/caif/caif_device.h>
+#include <net/caif/caif_dev.h>
+#include <net/caif/caif_layer.h>
+#include <net/caif/cfpkt.h>
+#include <net/caif/cfcnfg.h>
+
+MODULE_LICENSE("GPL");
+#define TIMEOUT (HZ*5)
+
+/* Used for local tracking of the CAIF net devices */
+struct caif_device_entry {
+	struct cflayer layer;
+	struct list_head list;
+	atomic_t in_use;
+	atomic_t state;
+	u16 phyid;
+	struct net_device *netdev;
+	wait_queue_head_t event;
+};
+
+struct caif_device_entry_list {
+	struct list_head list;
+	/* Protects simulanous deletes in list */
+	spinlock_t lock;
+};
+
+struct caif_net {
+	struct caif_device_entry_list caifdevs;
+};
+
+static int caif_net_id;
+static struct cfcnfg *cfg;
+
+static struct caif_device_entry_list *caif_device_list(struct net *net)
+{
+	struct caif_net *caifn;
+	BUG_ON(!net);
+	caifn = net_generic(net, caif_net_id);
+	BUG_ON(!caifn);
+	return &caifn->caifdevs;
+}
+
+/* Allocate new CAIF device. */
+static struct caif_device_entry *caif_device_alloc(struct net_device *dev)
+{
+	struct caif_device_entry_list *caifdevs;
+	struct caif_device_entry *caifd;
+	caifdevs = caif_device_list(dev_net(dev));
+	BUG_ON(!caifdevs);
+	caifd = kzalloc(sizeof(*caifd), GFP_ATOMIC);
+	if (!caifd)
+		return NULL;
+	caifd->netdev = dev;
+	list_add(&caifd->list, &caifdevs->list);
+	init_waitqueue_head(&caifd->event);
+	return caifd;
+}
+
+static struct caif_device_entry *caif_get(struct net_device *dev)
+{
+	struct caif_device_entry_list *caifdevs =
+	    caif_device_list(dev_net(dev));
+	struct caif_device_entry *caifd;
+	BUG_ON(!caifdevs);
+	list_for_each_entry(caifd, &caifdevs->list, list) {
+		if (caifd->netdev == dev)
+			return caifd;
+	}
+	return NULL;
+}
+
+static void caif_device_destroy(struct net_device *dev)
+{
+	struct caif_device_entry_list *caifdevs =
+	    caif_device_list(dev_net(dev));
+	struct caif_device_entry *caifd;
+	ASSERT_RTNL();
+	if (dev->type != ARPHRD_CAIF)
+		return;
+
+	spin_lock_bh(&caifdevs->lock);
+	caifd = caif_get(dev);
+	if (caifd == NULL) {
+		spin_unlock_bh(&caifdevs->lock);
+		return;
+	}
+
+	list_del(&caifd->list);
+	spin_unlock_bh(&caifdevs->lock);
+
+	kfree(caifd);
+	return;
+}
+
+static int transmit(struct cflayer *layer, struct cfpkt *pkt)
+{
+	struct caif_device_entry *caifd =
+	    container_of(layer, struct caif_device_entry, layer);
+	struct sk_buff *skb, *skb2;
+	int ret = -EINVAL;
+	skb = cfpkt_tonative(pkt);
+	skb->dev = caifd->netdev;
+	/*
+	 * Don't allow SKB to be destroyed upon error, but signal resend
+	 * notification to clients. We can't rely on the return value as
+	 * congestion (NET_XMIT_CN) sometimes drops the packet, sometimes don't.
+	 */
+	if (netif_queue_stopped(caifd->netdev))
+		return -EAGAIN;
+	skb2 = skb_get(skb);
+
+	ret = dev_queue_xmit(skb2);
+
+	if (!ret)
+		kfree_skb(skb);
+	else
+		return -EAGAIN;
+
+	return 0;
+}
+
+static int modemcmd(struct cflayer *layr, enum caif_modemcmd ctrl)
+{
+	struct caif_device_entry *caifd;
+	struct caif_dev_common *caifdev;
+	caifd = container_of(layr, struct caif_device_entry, layer);
+	caifdev = netdev_priv(caifd->netdev);
+	if (ctrl == _CAIF_MODEMCMD_PHYIF_USEFULL) {
+		atomic_set(&caifd->in_use, 1);
+		wake_up_interruptible(&caifd->event);
+
+	} else if (ctrl == _CAIF_MODEMCMD_PHYIF_USELESS) {
+		atomic_set(&caifd->in_use, 0);
+		wake_up_interruptible(&caifd->event);
+	}
+	return 0;
+}
+
+/*
+ * Stuff received packets to associated sockets.
+ * On error, returns non-zero and releases the skb.
+ */
+static int receive(struct sk_buff *skb, struct net_device *dev,
+		   struct packet_type *pkttype, struct net_device *orig_dev)
+{
+	struct net *net;
+	struct cfpkt *pkt;
+	struct caif_device_entry *caifd;
+	net = dev_net(dev);
+	pkt = cfpkt_fromnative(CAIF_DIR_IN, skb);
+	caifd = caif_get(dev);
+	if (!caifd || !caifd->layer.up || !caifd->layer.up->ctrlcmd)
+		return NET_RX_DROP;
+
+	if (caifd->layer.up->receive(caifd->layer.up, pkt))
+		return NET_RX_DROP;
+
+	return 0;
+}
+
+static struct packet_type caif_packet_type __read_mostly = {
+	.type = cpu_to_be16(ETH_P_CAIF),
+	.func = receive,
+};
+
+static void dev_flowctrl(struct net_device *dev, int on)
+{
+	struct caif_device_entry *caifd = caif_get(dev);
+	if (!caifd || !caifd->layer.up || !caifd->layer.up->ctrlcmd)
+		return;
+
+	caifd->layer.up->ctrlcmd(caifd->layer.up,
+				 on ?
+				 _CAIF_CTRLCMD_PHYIF_FLOW_ON_IND :
+				 _CAIF_CTRLCMD_PHYIF_FLOW_OFF_IND,
+				 caifd->layer.id);
+}
+
+/* notify Caif of device events */
+static int caif_device_notify(struct notifier_block *me, unsigned long what,
+			      void *arg)
+{
+	struct net_device *dev = arg;
+	struct caif_device_entry *caifd = NULL;
+	struct caif_dev_common *caifdev;
+	enum cfcnfg_phy_preference pref;
+	int res = -EINVAL;
+	enum cfcnfg_phy_type phy_type;
+
+	if (dev->type != ARPHRD_CAIF)
+		return 0;
+
+	switch (what) {
+	case NETDEV_REGISTER:
+		pr_info("CAIF: %s():register %s\n", __func__, dev->name);
+		caifd = caif_device_alloc(dev);
+		if (caifd == NULL)
+			break;
+		caifdev = netdev_priv(dev);
+		caifdev->flowctrl = dev_flowctrl;
+		atomic_set(&caifd->state, what);
+		res = 0;
+		break;
+
+	case NETDEV_UP:
+		pr_info("CAIF: %s(): up %s\n", __func__, dev->name);
+		caifd = caif_get(dev);
+		if (caifd == NULL)
+			break;
+		caifdev = netdev_priv(dev);
+		if (atomic_read(&caifd->state) == NETDEV_UP) {
+			pr_info("CAIF: %s():%s already up\n",
+				__func__, dev->name);
+			break;
+		}
+		atomic_set(&caifd->state, what);
+		caifd->layer.transmit = transmit;
+		caifd->layer.modemcmd = modemcmd;
+
+		if (caifdev->use_frag)
+			phy_type = CFPHYTYPE_FRAG;
+		else
+			phy_type = CFPHYTYPE_CAIF;
+
+		switch (caifdev->link_select) {
+		case CAIF_LINK_HIGH_BANDW:
+			pref = CFPHYPREF_LOW_LAT;
+			break;
+		case CAIF_LINK_LOW_LATENCY:
+			pref = CFPHYPREF_HIGH_BW;
+			break;
+		default:
+			pref = CFPHYPREF_HIGH_BW;
+			break;
+		}
+
+		cfcnfg_add_phy_layer(get_caif_conf(),
+				     phy_type,
+				     dev,
+				     &caifd->layer,
+				     &caifd->phyid,
+				     pref,
+				     caifdev->use_fcs,
+				     caifdev->use_stx);
+		strncpy(caifd->layer.name, dev->name,
+			sizeof(caifd->layer.name) - 1);
+		caifd->layer.name[sizeof(caifd->layer.name) - 1] = 0;
+		break;
+
+	case NETDEV_GOING_DOWN:
+		caifd = caif_get(dev);
+		if (caifd == NULL)
+			break;
+		pr_info("CAIF: %s():going down %s\n", __func__, dev->name);
+
+		if (atomic_read(&caifd->state) == NETDEV_GOING_DOWN ||
+			atomic_read(&caifd->state) == NETDEV_DOWN)
+			break;
+
+		atomic_set(&caifd->state, what);
+		if (!caifd || !caifd->layer.up || !caifd->layer.up->ctrlcmd)
+			return -EINVAL;
+		caifd->layer.up->ctrlcmd(caifd->layer.up,
+					 _CAIF_CTRLCMD_PHYIF_DOWN_IND,
+					 caifd->layer.id);
+		res = wait_event_interruptible_timeout(caifd->event,
+					atomic_read(&caifd->in_use) == 0,
+					TIMEOUT);
+		break;
+
+	case NETDEV_DOWN:
+		caifd = caif_get(dev);
+		if (caifd == NULL)
+			break;
+		pr_info("CAIF: %s(): down %s\n", __func__, dev->name);
+		if (atomic_read(&caifd->in_use))
+			pr_warning("CAIF: %s(): "
+				   "Unregistering an active CAIF device: %s\n",
+				   __func__, dev->name);
+		cfcnfg_del_phy_layer(get_caif_conf(), &caifd->layer);
+		atomic_set(&caifd->state, what);
+		break;
+
+	case NETDEV_UNREGISTER:
+		caifd = caif_get(dev);
+		pr_info("CAIF: %s(): unregister %s\n", __func__, dev->name);
+		atomic_set(&caifd->state, what);
+		caif_device_destroy(dev);
+		break;
+	}
+	return 0;
+}
+
+static struct notifier_block caif_device_notifier = {
+	.notifier_call = caif_device_notify,
+	.priority = 0,
+};
+
+
+struct cfcnfg *get_caif_conf(void)
+{
+	return cfg;
+}
+EXPORT_SYMBOL(get_caif_conf);
+
+int caif_connect_client(struct caif_connect_request *conn_req,
+			   struct cflayer *client_layer)
+{
+	struct cfctrl_link_param param;
+	if (connect_req_to_link_param(get_caif_conf(), conn_req, &param) == 0)
+		/* Hook up the adaptation layer. */
+		return cfcnfg_add_adaptation_layer(get_caif_conf(),
+						&param, client_layer);
+
+	return -EINVAL;
+
+	caif_assert(0);
+}
+EXPORT_SYMBOL(caif_connect_client);
+
+int caif_disconnect_client(struct cflayer *adap_layer)
+{
+	return cfcnfg_del_adapt_layer(get_caif_conf(), adap_layer);
+}
+EXPORT_SYMBOL(caif_disconnect_client);
+
+/* Per-namespace Caif devices handling */
+static int caif_init_net(struct net *net)
+{
+	struct caif_net *caifn = net_generic(net, caif_net_id);
+	INIT_LIST_HEAD(&caifn->caifdevs.list);
+	spin_lock_init(&caifn->caifdevs.lock);
+	return 0;
+}
+
+static void caif_exit_net(struct net *net)
+{
+	struct net_device *dev;
+	int res;
+	rtnl_lock();
+	for_each_netdev(net, dev) {
+		if (dev->type != ARPHRD_CAIF)
+			continue;
+		res = dev_close(dev);
+		caif_device_destroy(dev);
+	}
+	rtnl_unlock();
+}
+
+static struct pernet_operations caif_net_ops = {
+	.init = caif_init_net,
+	.exit = caif_exit_net,
+	.id   = &caif_net_id,
+	.size = sizeof(struct caif_net),
+};
+
+/* Initialize Caif devices list */
+static int __init caif_device_init(void)
+{
+	int result;
+	cfg = cfcnfg_create();
+	if (!cfg) {
+		pr_warning("CAIF: %s(): can't create cfcnfg.\n", __func__);
+		goto err_cfcnfg_create_failed;
+	}
+	result = register_pernet_device(&caif_net_ops);
+
+	if (result) {
+		kfree(cfg);
+		cfg = NULL;
+		return result;
+	}
+	dev_add_pack(&caif_packet_type);
+	register_netdevice_notifier(&caif_device_notifier);
+
+	return result;
+err_cfcnfg_create_failed:
+	return -ENODEV;
+}
+
+static void __exit caif_device_exit(void)
+{
+	dev_remove_pack(&caif_packet_type);
+	unregister_pernet_device(&caif_net_ops);
+	unregister_netdevice_notifier(&caif_device_notifier);
+	cfcnfg_remove(cfg);
+}
+
+module_init(caif_device_init);
+module_exit(caif_device_exit);
-- 
1.6.3.3

