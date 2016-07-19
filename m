From: Gavin Shan <gwshan@linux.vnet.ibm.com>
Subject: [PATCH net-next v3 04/10] net/ncsi: Package and channel management
Date: Tue, 19 Jul 2016 11:54:19 +1000
Message-ID: <1468893265-10635-5-git-send-email-gwshan@linux.vnet.ibm.com>
References: <1468893265-10635-1-git-send-email-gwshan@linux.vnet.ibm.com>
Cc: davem@davemloft.net, benh@kernel.crashing.org, joel@jms.id.au,
	gerlitz.or@gmail.com, weixue@trustnetic.com, yuvali@mellanox.com,
	alexei.starovoitov@gmail.com, f.fainelli@gmail.com,
	Gavin Shan <gwshan@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:2550 "EHLO
	mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752316AbcGSByh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2016 21:54:37 -0400
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u6J1sIl9039458
	for <netdev@vger.kernel.org>; Mon, 18 Jul 2016 21:54:36 -0400
Received: from e23smtp02.au.ibm.com (e23smtp02.au.ibm.com [202.81.31.144])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2495r7fyrs-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 18 Jul 2016 21:54:35 -0400
Received: from localhost
	by e23smtp02.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <gwshan@linux.vnet.ibm.com>;
	Tue, 19 Jul 2016 11:54:32 +1000
Received: from d23relay10.au.ibm.com (d23relay10.au.ibm.com [9.190.26.77])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 1C8693578057
	for <netdev@vger.kernel.org>; Tue, 19 Jul 2016 11:54:30 +1000 (EST)
Received: from d23av05.au.ibm.com (d23av05.au.ibm.com [9.190.234.119])
	by d23relay10.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u6J1sUGB9765110
	for <netdev@vger.kernel.org>; Tue, 19 Jul 2016 11:54:30 +1000
Received: from d23av05.au.ibm.com (localhost [127.0.0.1])
	by d23av05.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u6J1sShA028986
	for <netdev@vger.kernel.org>; Tue, 19 Jul 2016 11:54:29 +1000
In-Reply-To: <1468893265-10635-1-git-send-email-gwshan@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This manages NCSI packages and channels:

 * The available packages and channels are enumerated in the first
   time of calling ncsi_start_dev(). The channels' capabilities are
   probed in the meanwhile. The NCSI network topology won't change
   until the NCSI device is destroyed.
 * There in a queue in every NCSI device. The element in the queue,
   channel, is waiting for configuration (bringup) or suspending
   (teardown). The channel's state (inactive/active) indicates the
   futher action (configuration or suspending) will be applied on the
   channel. Another channel's state (invisible) means the requested
   action is being applied.
 * The hardware arbitration will be enabled if all available packages
   and channels support it. All available channels try to provide
   service when hardware arbitration is enabled. Otherwise, one channel
   is selected as the active one at once.
 * When channel is in active state, meaning it's providing service, a
   timer started to retrieve the channe's link status. If the channel's
   link status fails to be updated in the determined period, the channel
   is going to be reconfigured. It's the error handling implementation
   as defined in NCSI spec.

Signed-off-by: Gavin Shan <gwshan@linux.vnet.ibm.com>
Acked-by: Joel Stanley <joel@jms.id.au>
---
 include/net/ncsi.h     |   6 +
 net/ncsi/internal.h    |  50 ++++
 net/ncsi/ncsi-manage.c | 763 +++++++++++++++++++++++++++++++++++++++++++++++++
 net/ncsi/ncsi-rsp.c    |  15 +
 4 files changed, 834 insertions(+)

diff --git a/include/net/ncsi.h b/include/net/ncsi.h
index 70d14ee..1dbf42f 100644
--- a/include/net/ncsi.h
+++ b/include/net/ncsi.h
@@ -30,6 +30,7 @@ struct ncsi_dev {
 #ifdef CONFIG_NET_NCSI
 struct ncsi_dev *ncsi_register_dev(struct net_device *dev,
 				   void (*notifier)(struct ncsi_dev *nd));
+int ncsi_start_dev(struct ncsi_dev *nd);
 void ncsi_unregister_dev(struct ncsi_dev *nd);
 #else /* !CONFIG_NET_NCSI */
 static inline struct ncsi_dev *ncsi_register_dev(struct net_device *dev,
@@ -38,6 +39,11 @@ static inline struct ncsi_dev *ncsi_register_dev(struct net_device *dev,
 	return NULL;
 }
 
+static inline int ncsi_start_dev(struct ncsi_dev *nd)
+{
+	return -ENOTTY;
+}
+
 static inline void ncsi_unregister_dev(struct ncsi_dev *nd)
 {
 }
diff --git a/net/ncsi/internal.h b/net/ncsi/internal.h
index bd000c9..38fc95a 100644
--- a/net/ncsi/internal.h
+++ b/net/ncsi/internal.h
@@ -178,6 +178,7 @@ struct ncsi_channel {
 	int                         state;
 #define NCSI_CHANNEL_INACTIVE		1
 #define NCSI_CHANNEL_ACTIVE		2
+#define NCSI_CHANNEL_INVISIBLE		3
 	spinlock_t                  lock;	/* Protect filters etc */
 	struct ncsi_package         *package;
 	struct ncsi_channel_version version;
@@ -185,7 +186,11 @@ struct ncsi_channel {
 	struct ncsi_channel_mode    modes[NCSI_MODE_MAX];
 	struct ncsi_channel_filter  *filters[NCSI_FILTER_MAX];
 	struct ncsi_channel_stats   stats;
+	struct timer_list           timer;	/* Link monitor timer  */
+	bool                        enabled;	/* Timer is enabled    */
+	unsigned int                timeout;	/* Times of timeout    */
 	struct list_head            node;
+	struct list_head            link;
 };
 
 struct ncsi_package {
@@ -209,14 +214,56 @@ struct ncsi_request {
 	bool                 enabled; /* Time has been enabled or not    */
 };
 
+enum {
+	ncsi_dev_state_major		= 0xff00,
+	ncsi_dev_state_minor		= 0x00ff,
+	ncsi_dev_state_probe_deselect	= 0x0201,
+	ncsi_dev_state_probe_package,
+	ncsi_dev_state_probe_channel,
+	ncsi_dev_state_probe_cis,
+	ncsi_dev_state_probe_gvi,
+	ncsi_dev_state_probe_gc,
+	ncsi_dev_state_probe_gls,
+	ncsi_dev_state_probe_dp,
+	ncsi_dev_state_config_sp	= 0x0301,
+	ncsi_dev_state_config_cis,
+	ncsi_dev_state_config_sma,
+	ncsi_dev_state_config_ebf,
+#if IS_ENABLED(CONFIG_IPV6)
+	ncsi_dev_state_config_egmf,
+#endif
+	ncsi_dev_state_config_ecnt,
+	ncsi_dev_state_config_ec,
+	ncsi_dev_state_config_ae,
+	ncsi_dev_state_config_gls,
+	ncsi_dev_state_config_done,
+	ncsi_dev_state_suspend_select	= 0x0401,
+	ncsi_dev_state_suspend_dcnt,
+	ncsi_dev_state_suspend_dc,
+	ncsi_dev_state_suspend_deselect,
+	ncsi_dev_state_suspend_done
+};
+
 struct ncsi_dev_priv {
 	struct ncsi_dev     ndev;            /* Associated NCSI device     */
 	unsigned int        flags;           /* NCSI device flags          */
+#define NCSI_DEV_PROBED		1            /* Finalized NCSI topology    */
+#define NCSI_DEV_HWA		2            /* Enabled HW arbitration     */
+#define NCSI_DEV_RESHUFFLE	4
 	spinlock_t          lock;            /* Protect the NCSI device    */
+#if IS_ENABLED(CONFIG_IPV6)
+	unsigned int        inet6_addr_num;  /* Number of IPv6 addresses   */
+#endif
 	unsigned int        package_num;     /* Number of packages         */
 	struct list_head    packages;        /* List of packages           */
 	struct ncsi_request requests[256];   /* Request table              */
 	unsigned int        request_id;      /* Last used request ID       */
+	unsigned int        pending_req_num; /* Number of pending requests */
+	struct ncsi_package *active_package; /* Currently handled package  */
+	struct ncsi_channel *active_channel; /* Currently handled channel  */
+	struct list_head    channel_queue;   /* Config queue of channels   */
+	struct work_struct  work;            /* For channel management     */
+	struct packet_type  ptype;           /* NCSI packet Rx handler     */
 	struct list_head    node;            /* Form NCSI device list      */
 };
 
@@ -251,6 +298,8 @@ extern spinlock_t ncsi_dev_lock;
 int ncsi_find_filter(struct ncsi_channel *nc, int table, void *data);
 int ncsi_add_filter(struct ncsi_channel *nc, int table, void *data);
 int ncsi_remove_filter(struct ncsi_channel *nc, int table, int index);
+void ncsi_start_channel_monitor(struct ncsi_channel *nc);
+void ncsi_stop_channel_monitor(struct ncsi_channel *nc);
 struct ncsi_channel *ncsi_find_channel(struct ncsi_package *np,
 				       unsigned char id);
 struct ncsi_channel *ncsi_add_channel(struct ncsi_package *np,
@@ -267,6 +316,7 @@ void ncsi_find_package_and_channel(struct ncsi_dev_priv *ndp,
 struct ncsi_request *ncsi_alloc_request(struct ncsi_dev_priv *ndp, bool driven);
 void ncsi_free_request(struct ncsi_request *nr);
 struct ncsi_dev *ncsi_find_dev(struct net_device *dev);
+int ncsi_process_next_channel(struct ncsi_dev_priv *ndp);
 
 /* Packet handlers */
 u32 ncsi_calculate_checksum(unsigned char *data, int len);
diff --git a/net/ncsi/ncsi-manage.c b/net/ncsi/ncsi-manage.c
index 0e28ed8..d627a39 100644
--- a/net/ncsi/ncsi-manage.c
+++ b/net/ncsi/ncsi-manage.c
@@ -17,8 +17,12 @@
 #include <net/ncsi.h>
 #include <net/net_namespace.h>
 #include <net/sock.h>
+#include <net/addrconf.h>
+#include <net/ipv6.h>
+#include <net/if_inet6.h>
 
 #include "internal.h"
+#include "ncsi-pkt.h"
 
 LIST_HEAD(ncsi_dev_list);
 DEFINE_SPINLOCK(ncsi_dev_lock);
@@ -123,6 +127,120 @@ int ncsi_remove_filter(struct ncsi_channel *nc, int table, int index)
 	return 0;
 }
 
+static void ncsi_report_link(struct ncsi_dev_priv *ndp, bool force_down)
+{
+	struct ncsi_dev *nd = &ndp->ndev;
+	struct ncsi_package *np;
+	struct ncsi_channel *nc;
+
+	nd->state = ncsi_dev_state_functional;
+	if (force_down) {
+		nd->link_up = 0;
+		goto report;
+	}
+
+	nd->link_up = 0;
+	NCSI_FOR_EACH_PACKAGE(ndp, np) {
+		NCSI_FOR_EACH_CHANNEL(np, nc) {
+			if (!list_empty(&nc->link) ||
+			    nc->state != NCSI_CHANNEL_ACTIVE)
+				continue;
+
+			if (nc->modes[NCSI_MODE_LINK].data[2] & 0x1) {
+				nd->link_up = 1;
+				goto report;
+			}
+		}
+	}
+
+report:
+	nd->handler(nd);
+}
+
+static void ncsi_channel_monitor(unsigned long data)
+{
+	struct ncsi_channel *nc = (struct ncsi_channel *)data;
+	struct ncsi_package *np = nc->package;
+	struct ncsi_dev_priv *ndp = np->ndp;
+	struct ncsi_cmd_arg nca;
+	bool enabled;
+	unsigned int timeout;
+	unsigned long flags;
+	int ret;
+
+	spin_lock_irqsave(&nc->lock, flags);
+	timeout = nc->timeout;
+	enabled = nc->enabled;
+	spin_unlock_irqrestore(&nc->lock, flags);
+
+	if (!enabled || !list_empty(&nc->link))
+		return;
+	if (nc->state != NCSI_CHANNEL_INACTIVE &&
+	    nc->state != NCSI_CHANNEL_ACTIVE)
+		return;
+
+	if (!(timeout % 2)) {
+		nca.ndp = ndp;
+		nca.package = np->id;
+		nca.channel = nc->id;
+		nca.type = NCSI_PKT_CMD_GLS;
+		nca.driven = false;
+		ret = ncsi_xmit_cmd(&nca);
+		if (ret) {
+			netdev_err(ndp->ndev.dev, "Error %d sending GLS\n",
+				   ret);
+			return;
+		}
+	}
+
+	if (timeout + 1 >= 3) {
+		if (!(ndp->flags & NCSI_DEV_HWA) &&
+		    nc->state == NCSI_CHANNEL_ACTIVE)
+			ncsi_report_link(ndp, true);
+
+		spin_lock_irqsave(&ndp->lock, flags);
+		xchg(&nc->state, NCSI_CHANNEL_INACTIVE);
+		list_add_tail_rcu(&nc->link, &ndp->channel_queue);
+		spin_unlock_irqrestore(&ndp->lock, flags);
+		ncsi_process_next_channel(ndp);
+		return;
+	}
+
+	spin_lock_irqsave(&nc->lock, flags);
+	nc->timeout = timeout + 1;
+	nc->enabled = true;
+	spin_unlock_irqrestore(&nc->lock, flags);
+	mod_timer(&nc->timer, jiffies + HZ * (1 << (nc->timeout / 2)));
+}
+
+void ncsi_start_channel_monitor(struct ncsi_channel *nc)
+{
+	unsigned long flags;
+
+	spin_lock_irqsave(&nc->lock, flags);
+	WARN_ON_ONCE(nc->enabled);
+	nc->timeout = 0;
+	nc->enabled = true;
+	spin_unlock_irqrestore(&nc->lock, flags);
+
+	mod_timer(&nc->timer, jiffies + HZ * (1 << (nc->timeout / 2)));
+}
+
+void ncsi_stop_channel_monitor(struct ncsi_channel *nc)
+{
+	unsigned long flags;
+
+	spin_lock_irqsave(&nc->lock, flags);
+	if (!nc->enabled) {
+		spin_unlock_irqrestore(&nc->lock, flags);
+		return;
+	}
+	nc->enabled = false;
+	spin_unlock_irqrestore(&nc->lock, flags);
+
+	del_timer_sync(&nc->timer);
+}
+
 struct ncsi_channel *ncsi_find_channel(struct ncsi_package *np,
 				       unsigned char id)
 {
@@ -149,7 +267,10 @@ struct ncsi_channel *ncsi_add_channel(struct ncsi_package *np, unsigned char id)
 	nc->id = id;
 	nc->package = np;
 	nc->state = NCSI_CHANNEL_INACTIVE;
+	nc->enabled = false;
+	setup_timer(&nc->timer, ncsi_channel_monitor, (unsigned long)nc);
 	spin_lock_init(&nc->lock);
+	INIT_LIST_HEAD(&nc->link);
 	for (index = 0; index < NCSI_CAP_MAX; index++)
 		nc->caps[index].index = index;
 	for (index = 0; index < NCSI_MODE_MAX; index++)
@@ -190,6 +311,7 @@ static void ncsi_remove_channel(struct ncsi_channel *nc)
 
 	nc->state = NCSI_CHANNEL_INACTIVE;
 	spin_unlock_irqrestore(&nc->lock, flags);
+	ncsi_stop_channel_monitor(nc);
 
 	/* Remove and free channel */
 	spin_lock_irqsave(&np->lock, flags);
@@ -323,6 +445,7 @@ void ncsi_free_request(struct ncsi_request *nr)
 	struct ncsi_dev_priv *ndp = nr->ndp;
 	struct sk_buff *cmd, *rsp;
 	unsigned long flags;
+	bool driven;
 
 	if (nr->enabled) {
 		nr->enabled = false;
@@ -335,8 +458,12 @@ void ncsi_free_request(struct ncsi_request *nr)
 	nr->cmd = NULL;
 	nr->rsp = NULL;
 	nr->used = false;
+	driven = nr->driven;
 	spin_unlock_irqrestore(&ndp->lock, flags);
 
+	if (driven && cmd && --ndp->pending_req_num == 0)
+		schedule_work(&ndp->work);
+
 	/* Release command and response */
 	consume_skb(cmd);
 	consume_skb(rsp);
@@ -375,6 +502,587 @@ static void ncsi_request_timeout(unsigned long data)
 	ncsi_free_request(nr);
 }
 
+static void ncsi_suspend_channel(struct ncsi_dev_priv *ndp)
+{
+	struct ncsi_dev *nd = &ndp->ndev;
+	struct ncsi_package *np = ndp->active_package;
+	struct ncsi_channel *nc = ndp->active_channel;
+	struct ncsi_cmd_arg nca;
+	int ret;
+
+	nca.ndp = ndp;
+	nca.driven = true;
+	switch (nd->state) {
+	case ncsi_dev_state_suspend:
+		nd->state = ncsi_dev_state_suspend_select;
+		/* Fall through */
+	case ncsi_dev_state_suspend_select:
+	case ncsi_dev_state_suspend_dcnt:
+	case ncsi_dev_state_suspend_dc:
+	case ncsi_dev_state_suspend_deselect:
+		ndp->pending_req_num = 1;
+
+		np = ndp->active_package;
+		nc = ndp->active_channel;
+		nca.package = np->id;
+		if (nd->state == ncsi_dev_state_suspend_select) {
+			nca.type = NCSI_PKT_CMD_SP;
+			nca.channel = 0x1f;
+			if (ndp->flags & NCSI_DEV_HWA)
+				nca.bytes[0] = 0;
+			else
+				nca.bytes[0] = 1;
+			nd->state = ncsi_dev_state_suspend_dcnt;
+		} else if (nd->state == ncsi_dev_state_suspend_dcnt) {
+			nca.type = NCSI_PKT_CMD_DCNT;
+			nca.channel = nc->id;
+			nd->state = ncsi_dev_state_suspend_dc;
+		} else if (nd->state == ncsi_dev_state_suspend_dc) {
+			nca.type = NCSI_PKT_CMD_DC;
+			nca.channel = nc->id;
+			nca.bytes[0] = 1;
+			nd->state = ncsi_dev_state_suspend_deselect;
+		} else if (nd->state == ncsi_dev_state_suspend_deselect) {
+			nca.type = NCSI_PKT_CMD_DP;
+			nca.channel = 0x1f;
+			nd->state = ncsi_dev_state_suspend_done;
+		}
+
+		ret = ncsi_xmit_cmd(&nca);
+		if (ret) {
+			nd->state = ncsi_dev_state_functional;
+			return;
+		}
+
+		break;
+	case ncsi_dev_state_suspend_done:
+		xchg(&nc->state, NCSI_CHANNEL_INACTIVE);
+		ncsi_process_next_channel(ndp);
+
+		break;
+	default:
+		netdev_warn(nd->dev, "Wrong NCSI state 0x%x in suspend\n",
+			    nd->state);
+	}
+}
+
+static void ncsi_configure_channel(struct ncsi_dev_priv *ndp)
+{
+	struct ncsi_dev *nd = &ndp->ndev;
+	struct net_device *dev = nd->dev;
+	struct ncsi_package *np = ndp->active_package;
+	struct ncsi_channel *nc = ndp->active_channel;
+	struct ncsi_cmd_arg nca;
+	unsigned char index;
+	int ret;
+
+	nca.ndp = ndp;
+	nca.driven = true;
+	switch (nd->state) {
+	case ncsi_dev_state_config:
+	case ncsi_dev_state_config_sp:
+		ndp->pending_req_num = 1;
+
+		/* Select the specific package */
+		nca.type = NCSI_PKT_CMD_SP;
+		if (ndp->flags & NCSI_DEV_HWA)
+			nca.bytes[0] = 0;
+		else
+			nca.bytes[0] = 1;
+		nca.package = np->id;
+		nca.channel = 0x1f;
+		ret = ncsi_xmit_cmd(&nca);
+		if (ret)
+			goto error;
+
+		nd->state = ncsi_dev_state_config_cis;
+		break;
+	case ncsi_dev_state_config_cis:
+		ndp->pending_req_num = 1;
+
+		/* Clear initial state */
+		nca.type = NCSI_PKT_CMD_CIS;
+		nca.package = np->id;
+		nca.channel = nc->id;
+		ret = ncsi_xmit_cmd(&nca);
+		if (ret)
+			goto error;
+
+		nd->state = ncsi_dev_state_config_sma;
+		break;
+	case ncsi_dev_state_config_sma:
+	case ncsi_dev_state_config_ebf:
+#if IS_ENABLED(CONFIG_IPV6)
+	case ncsi_dev_state_config_egmf:
+#endif
+	case ncsi_dev_state_config_ecnt:
+	case ncsi_dev_state_config_ec:
+	case ncsi_dev_state_config_ae:
+	case ncsi_dev_state_config_gls:
+		ndp->pending_req_num = 1;
+
+		nca.package = np->id;
+		nca.channel = nc->id;
+
+		/* Use first entry in unicast filter table. Note that
+		 * the MAC filter table starts from entry 1 instead of
+		 * 0.
+		 */
+		if (nd->state == ncsi_dev_state_config_sma) {
+			nca.type = NCSI_PKT_CMD_SMA;
+			for (index = 0; index < 6; index++)
+				nca.bytes[index] = dev->dev_addr[index];
+			nca.bytes[6] = 0x1;
+			nca.bytes[7] = 0x1;
+			nd->state = ncsi_dev_state_config_ebf;
+		} else if (nd->state == ncsi_dev_state_config_ebf) {
+			nca.type = NCSI_PKT_CMD_EBF;
+			nca.dwords[0] = nc->caps[NCSI_CAP_BC].cap;
+			nd->state = ncsi_dev_state_config_ecnt;
+#if IS_ENABLED(CONFIG_IPV6)
+			if (ndp->inet6_addr_num > 0 &&
+			    (nc->caps[NCSI_CAP_GENERIC].cap &
+			     NCSI_CAP_GENERIC_MC))
+				nd->state = ncsi_dev_state_config_egmf;
+			else
+				nd->state = ncsi_dev_state_config_ecnt;
+		} else if (nd->state == ncsi_dev_state_config_egmf) {
+			nca.type = NCSI_PKT_CMD_EGMF;
+			nca.dwords[0] = nc->caps[NCSI_CAP_MC].cap;
+			nd->state = ncsi_dev_state_config_ecnt;
+#endif /* CONFIG_IPV6 */
+		} else if (nd->state == ncsi_dev_state_config_ecnt) {
+			nca.type = NCSI_PKT_CMD_ECNT;
+			nd->state = ncsi_dev_state_config_ec;
+		} else if (nd->state == ncsi_dev_state_config_ec) {
+			/* Enable AEN if it's supported */
+			nca.type = NCSI_PKT_CMD_EC;
+			nd->state = ncsi_dev_state_config_ae;
+			if (!(nc->caps[NCSI_CAP_AEN].cap & NCSI_CAP_AEN_MASK))
+				nd->state = ncsi_dev_state_config_gls;
+		} else if (nd->state == ncsi_dev_state_config_ae) {
+			nca.type = NCSI_PKT_CMD_AE;
+			nca.bytes[0] = 0;
+			nca.dwords[1] = nc->caps[NCSI_CAP_AEN].cap;
+			nd->state = ncsi_dev_state_config_gls;
+		} else if (nd->state == ncsi_dev_state_config_gls) {
+			nca.type = NCSI_PKT_CMD_GLS;
+			nd->state = ncsi_dev_state_config_done;
+		}
+
+		ret = ncsi_xmit_cmd(&nca);
+		if (ret)
+			goto error;
+		break;
+	case ncsi_dev_state_config_done:
+		if (nc->modes[NCSI_MODE_LINK].data[2] & 0x1)
+			xchg(&nc->state, NCSI_CHANNEL_ACTIVE);
+		else
+			xchg(&nc->state, NCSI_CHANNEL_INACTIVE);
+
+		ncsi_start_channel_monitor(nc);
+		ncsi_process_next_channel(ndp);
+		break;
+	default:
+		netdev_warn(dev, "Wrong NCSI state 0x%x in config\n",
+			    nd->state);
+	}
+
+	return;
+
+error:
+	ncsi_report_link(ndp, true);
+}
+
+static int ncsi_choose_active_channel(struct ncsi_dev_priv *ndp)
+{
+	struct ncsi_package *np;
+	struct ncsi_channel *nc, *found;
+	struct ncsi_channel_mode *ncm;
+	unsigned long flags;
+
+	/* The search is done once an inactive channel with up
+	 * link is found.
+	 */
+	found = NULL;
+	NCSI_FOR_EACH_PACKAGE(ndp, np) {
+		NCSI_FOR_EACH_CHANNEL(np, nc) {
+			if (!list_empty(&nc->link) ||
+			    nc->state != NCSI_CHANNEL_INACTIVE)
+				continue;
+
+			if (!found)
+				found = nc;
+
+			ncm = &nc->modes[NCSI_MODE_LINK];
+			if (ncm->data[2] & 0x1) {
+				found = nc;
+				goto out;
+			}
+		}
+	}
+
+	if (!found) {
+		ncsi_report_link(ndp, true);
+		return -ENODEV;
+	}
+
+out:
+	spin_lock_irqsave(&ndp->lock, flags);
+	list_add_tail_rcu(&found->link, &ndp->channel_queue);
+	spin_unlock_irqrestore(&ndp->lock, flags);
+
+	return ncsi_process_next_channel(ndp);
+}
+
+static bool ncsi_check_hwa(struct ncsi_dev_priv *ndp)
+{
+	struct ncsi_package *np;
+	struct ncsi_channel *nc;
+	unsigned int cap;
+
+	/* The hardware arbitration is disabled if any one channel
+	 * doesn't support explicitly.
+	 */
+	NCSI_FOR_EACH_PACKAGE(ndp, np) {
+		NCSI_FOR_EACH_CHANNEL(np, nc) {
+			cap = nc->caps[NCSI_CAP_GENERIC].cap;
+			if (!(cap & NCSI_CAP_GENERIC_HWA) ||
+			    (cap & NCSI_CAP_GENERIC_HWA_MASK) !=
+			    NCSI_CAP_GENERIC_HWA_SUPPORT) {
+				ndp->flags &= ~NCSI_DEV_HWA;
+				return false;
+			}
+		}
+	}
+
+	ndp->flags |= NCSI_DEV_HWA;
+	return true;
+}
+
+static int ncsi_enable_hwa(struct ncsi_dev_priv *ndp)
+{
+	struct ncsi_package *np;
+	struct ncsi_channel *nc;
+	unsigned long flags;
+
+	/* Move all available channels to processing queue */
+	spin_lock_irqsave(&ndp->lock, flags);
+	NCSI_FOR_EACH_PACKAGE(ndp, np) {
+		NCSI_FOR_EACH_CHANNEL(np, nc) {
+			WARN_ON_ONCE(nc->state != NCSI_CHANNEL_INACTIVE ||
+				     !list_empty(&nc->link));
+			ncsi_stop_channel_monitor(nc);
+			list_add_tail_rcu(&nc->link, &ndp->channel_queue);
+		}
+	}
+	spin_unlock_irqrestore(&ndp->lock, flags);
+
+	/* We can have no channels in extremely case */
+	if (list_empty(&ndp->channel_queue)) {
+		ncsi_report_link(ndp, false);
+		return -ENOENT;
+	}
+
+	return ncsi_process_next_channel(ndp);
+}
+
+static void ncsi_probe_channel(struct ncsi_dev_priv *ndp)
+{
+	struct ncsi_dev *nd = &ndp->ndev;
+	struct ncsi_package *np;
+	struct ncsi_channel *nc;
+	struct ncsi_cmd_arg nca;
+	unsigned char index;
+	int ret;
+
+	nca.ndp = ndp;
+	nca.driven = true;
+	switch (nd->state) {
+	case ncsi_dev_state_probe:
+		nd->state = ncsi_dev_state_probe_deselect;
+		/* Fall through */
+	case ncsi_dev_state_probe_deselect:
+		ndp->pending_req_num = 8;
+
+		/* Deselect all possible packages */
+		nca.type = NCSI_PKT_CMD_DP;
+		nca.channel = 0x1f;
+		for (index = 0; index < 8; index++) {
+			nca.package = index;
+			ret = ncsi_xmit_cmd(&nca);
+			if (ret)
+				goto error;
+		}
+
+		nd->state = ncsi_dev_state_probe_package;
+		break;
+	case ncsi_dev_state_probe_package:
+		ndp->pending_req_num = 16;
+
+		/* Select all possible packages */
+		nca.type = NCSI_PKT_CMD_SP;
+		nca.bytes[0] = 1;
+		nca.channel = 0x1f;
+		for (index = 0; index < 8; index++) {
+			nca.package = index;
+			ret = ncsi_xmit_cmd(&nca);
+			if (ret)
+				goto error;
+		}
+
+		/* Disable all possible packages */
+		nca.type = NCSI_PKT_CMD_DP;
+		for (index = 0; index < 8; index++) {
+			nca.package = index;
+			ret = ncsi_xmit_cmd(&nca);
+			if (ret)
+				goto error;
+		}
+
+		nd->state = ncsi_dev_state_probe_channel;
+		break;
+	case ncsi_dev_state_probe_channel:
+		if (!ndp->active_package)
+			ndp->active_package = list_first_or_null_rcu(
+				&ndp->packages, struct ncsi_package, node);
+		else if (list_is_last(&ndp->active_package->node,
+				      &ndp->packages))
+			ndp->active_package = NULL;
+		else
+			ndp->active_package = list_next_entry(
+				ndp->active_package, node);
+
+		/* All available packages and channels are enumerated. The
+		 * enumeration happens for once when the NCSI interface is
+		 * started. So we need continue to start the interface after
+		 * the enumeration.
+		 *
+		 * We have to choose an active channel before configuring it.
+		 * Note that we possibly don't have active channel in extreme
+		 * situation.
+		 */
+		if (!ndp->active_package) {
+			ndp->flags |= NCSI_DEV_PROBED;
+			if (ncsi_check_hwa(ndp))
+				ncsi_enable_hwa(ndp);
+			else
+				ncsi_choose_active_channel(ndp);
+			return;
+		}
+
+		/* Select the active package */
+		ndp->pending_req_num = 1;
+		nca.type = NCSI_PKT_CMD_SP;
+		nca.bytes[0] = 1;
+		nca.package = ndp->active_package->id;
+		nca.channel = 0x1f;
+		ret = ncsi_xmit_cmd(&nca);
+		if (ret)
+			goto error;
+
+		nd->state = ncsi_dev_state_probe_cis;
+		break;
+	case ncsi_dev_state_probe_cis:
+		ndp->pending_req_num = 32;
+
+		/* Clear initial state */
+		nca.type = NCSI_PKT_CMD_CIS;
+		nca.package = ndp->active_package->id;
+		for (index = 0; index < 0x20; index++) {
+			nca.channel = index;
+			ret = ncsi_xmit_cmd(&nca);
+			if (ret)
+				goto error;
+		}
+
+		nd->state = ncsi_dev_state_probe_gvi;
+		break;
+	case ncsi_dev_state_probe_gvi:
+	case ncsi_dev_state_probe_gc:
+	case ncsi_dev_state_probe_gls:
+		np = ndp->active_package;
+		ndp->pending_req_num = np->channel_num;
+
+		/* Retrieve version, capability or link status */
+		if (nd->state == ncsi_dev_state_probe_gvi)
+			nca.type = NCSI_PKT_CMD_GVI;
+		else if (nd->state == ncsi_dev_state_probe_gc)
+			nca.type = NCSI_PKT_CMD_GC;
+		else
+			nca.type = NCSI_PKT_CMD_GLS;
+
+		nca.package = np->id;
+		NCSI_FOR_EACH_CHANNEL(np, nc) {
+			nca.channel = nc->id;
+			ret = ncsi_xmit_cmd(&nca);
+			if (ret)
+				goto error;
+		}
+
+		if (nd->state == ncsi_dev_state_probe_gvi)
+			nd->state = ncsi_dev_state_probe_gc;
+		else if (nd->state == ncsi_dev_state_probe_gc)
+			nd->state = ncsi_dev_state_probe_gls;
+		else
+			nd->state = ncsi_dev_state_probe_dp;
+		break;
+	case ncsi_dev_state_probe_dp:
+		ndp->pending_req_num = 1;
+
+		/* Deselect the active package */
+		nca.type = NCSI_PKT_CMD_DP;
+		nca.package = ndp->active_package->id;
+		nca.channel = 0x1f;
+		ret = ncsi_xmit_cmd(&nca);
+		if (ret)
+			goto error;
+
+		/* Scan channels in next package */
+		nd->state = ncsi_dev_state_probe_channel;
+		break;
+	default:
+		netdev_warn(nd->dev, "Wrong NCSI state 0x%0x in enumeration\n",
+			    nd->state);
+	}
+
+	return;
+error:
+	ncsi_report_link(ndp, true);
+}
+
+static void ncsi_dev_work(struct work_struct *work)
+{
+	struct ncsi_dev_priv *ndp = container_of(work,
+			struct ncsi_dev_priv, work);
+	struct ncsi_dev *nd = &ndp->ndev;
+
+	switch (nd->state & ncsi_dev_state_major) {
+	case ncsi_dev_state_probe:
+		ncsi_probe_channel(ndp);
+		break;
+	case ncsi_dev_state_suspend:
+		ncsi_suspend_channel(ndp);
+		break;
+	case ncsi_dev_state_config:
+		ncsi_configure_channel(ndp);
+		break;
+	default:
+		netdev_warn(nd->dev, "Wrong NCSI state 0x%x in workqueue\n",
+			    nd->state);
+	}
+}
+
+int ncsi_process_next_channel(struct ncsi_dev_priv *ndp)
+{
+	struct ncsi_channel *nc;
+	int old_state;
+	unsigned long flags;
+
+	spin_lock_irqsave(&ndp->lock, flags);
+	nc = list_first_or_null_rcu(&ndp->channel_queue,
+				    struct ncsi_channel, link);
+	if (nc) {
+		old_state = xchg(&nc->state, NCSI_CHANNEL_INVISIBLE);
+		list_del_init(&nc->link);
+	}
+	spin_unlock_irqrestore(&ndp->lock, flags);
+
+	ndp->active_channel = nc;
+	ndp->active_package = nc ? nc->package : NULL;
+	if (!nc) {
+		if (ndp->flags & NCSI_DEV_RESHUFFLE) {
+			ndp->flags &= ~NCSI_DEV_RESHUFFLE;
+			return ncsi_choose_active_channel(ndp);
+		}
+
+		ncsi_report_link(ndp, false);
+		return -ENODEV;
+	}
+
+	switch (old_state) {
+	case NCSI_CHANNEL_INACTIVE:
+		ndp->ndev.state = ncsi_dev_state_config;
+		ncsi_configure_channel(ndp);
+		break;
+	case NCSI_CHANNEL_ACTIVE:
+		ndp->ndev.state = ncsi_dev_state_suspend;
+		ncsi_suspend_channel(ndp);
+		break;
+	default:
+		netdev_err(ndp->ndev.dev, "Invalid state 0x%x on %d:%d\n",
+			   nc->state, nc->package->id, nc->id);
+		ncsi_report_link(ndp, false);
+		return -EINVAL;
+	}
+
+	return 0;
+}
+
+#if IS_ENABLED(CONFIG_IPV6)
+static int ncsi_inet6addr_event(struct notifier_block *this,
+				unsigned long event, void *data)
+{
+	struct inet6_ifaddr *ifa = data;
+	struct net_device *dev = ifa->idev->dev;
+	struct ncsi_dev *nd = ncsi_find_dev(dev);
+	struct ncsi_dev_priv *ndp = nd ? TO_NCSI_DEV_PRIV(nd) : NULL;
+	struct ncsi_package *np;
+	struct ncsi_channel *nc;
+	struct ncsi_cmd_arg nca;
+	bool action;
+	int ret;
+
+	if (!ndp || (ipv6_addr_type(&ifa->addr) &
+	    (IPV6_ADDR_LINKLOCAL | IPV6_ADDR_LOOPBACK)))
+		return NOTIFY_OK;
+
+	switch (event) {
+	case NETDEV_UP:
+		action = (++ndp->inet6_addr_num) == 1;
+		nca.type = NCSI_PKT_CMD_EGMF;
+		break;
+	case NETDEV_DOWN:
+		action = (--ndp->inet6_addr_num == 0);
+		nca.type = NCSI_PKT_CMD_DGMF;
+		break;
+	default:
+		return NOTIFY_OK;
+	}
+
+	/* We might not have active channel or packages. The IPv6
+	 * required multicast will be enabled when active channel
+	 * or packages are chosen.
+	 */
+	np = ndp->active_package;
+	nc = ndp->active_channel;
+	if (!action || !np || !nc)
+		return NOTIFY_OK;
+
+	/* We needn't enable or disable it if the function isn't supported */
+	if (!(nc->caps[NCSI_CAP_GENERIC].cap & NCSI_CAP_GENERIC_MC))
+		return NOTIFY_OK;
+
+	nca.ndp = ndp;
+	nca.driven = false;
+	nca.package = np->id;
+	nca.channel = nc->id;
+	nca.dwords[0] = nc->caps[NCSI_CAP_MC].cap;
+	ret = ncsi_xmit_cmd(&nca);
+	if (ret) {
+		netdev_warn(dev, "Fail to %s global multicast filter (%d)\n",
+			    (event == NETDEV_UP) ? "enable" : "disable", ret);
+		return NOTIFY_DONE;
+	}
+
+	return NOTIFY_OK;
+}
+
+static struct notifier_block ncsi_inet6addr_notifier = {
+	.notifier_call = ncsi_inet6addr_event,
+};
+#endif /* CONFIG_IPV6 */
+
 struct ncsi_dev *ncsi_register_dev(struct net_device *dev,
 				   void (*handler)(struct ncsi_dev *ndev))
 {
@@ -397,6 +1105,9 @@ struct ncsi_dev *ncsi_register_dev(struct net_device *dev,
 	nd->state = ncsi_dev_state_registered;
 	nd->dev = dev;
 	nd->handler = handler;
+	ndp->pending_req_num = 0;
+	INIT_LIST_HEAD(&ndp->channel_queue);
+	INIT_WORK(&ndp->work, ncsi_dev_work);
 
 	/* Initialize private NCSI device */
 	spin_lock_init(&ndp->lock);
@@ -411,24 +1122,76 @@ struct ncsi_dev *ncsi_register_dev(struct net_device *dev,
 	}
 
 	spin_lock_irqsave(&ncsi_dev_lock, flags);
+#if IS_ENABLED(CONFIG_IPV6)
+	ndp->inet6_addr_num = 0;
+	if (list_empty(&ncsi_dev_list))
+		register_inet6addr_notifier(&ncsi_inet6addr_notifier);
+#endif
 	list_add_tail_rcu(&ndp->node, &ncsi_dev_list);
 	spin_unlock_irqrestore(&ncsi_dev_lock, flags);
 
+	/* Register NCSI packet Rx handler */
+	ndp->ptype.type = cpu_to_be16(ETH_P_NCSI);
+	ndp->ptype.func = ncsi_rcv_rsp;
+	ndp->ptype.dev = dev;
+	dev_add_pack(&ndp->ptype);
+
 	return nd;
 }
 EXPORT_SYMBOL_GPL(ncsi_register_dev);
 
+int ncsi_start_dev(struct ncsi_dev *nd)
+{
+	struct ncsi_dev_priv *ndp = TO_NCSI_DEV_PRIV(nd);
+	struct ncsi_package *np;
+	struct ncsi_channel *nc;
+	int old_state, ret;
+
+	if (nd->state != ncsi_dev_state_registered &&
+	    nd->state != ncsi_dev_state_functional)
+		return -ENOTTY;
+
+	if (!(ndp->flags & NCSI_DEV_PROBED)) {
+		nd->state = ncsi_dev_state_probe;
+		schedule_work(&ndp->work);
+		return 0;
+	}
+
+	/* Reset channel's state and start over */
+	NCSI_FOR_EACH_PACKAGE(ndp, np) {
+		NCSI_FOR_EACH_CHANNEL(np, nc) {
+			old_state = xchg(&nc->state, NCSI_CHANNEL_INACTIVE);
+			WARN_ON_ONCE(!list_empty(&nc->link) ||
+				     old_state == NCSI_CHANNEL_INVISIBLE);
+		}
+	}
+
+	if (ndp->flags & NCSI_DEV_HWA)
+		ret = ncsi_enable_hwa(ndp);
+	else
+		ret = ncsi_choose_active_channel(ndp);
+
+	return ret;
+}
+EXPORT_SYMBOL_GPL(ncsi_start_dev);
+
 void ncsi_unregister_dev(struct ncsi_dev *nd)
 {
 	struct ncsi_dev_priv *ndp = TO_NCSI_DEV_PRIV(nd);
 	struct ncsi_package *np, *tmp;
 	unsigned long flags;
 
+	dev_remove_pack(&ndp->ptype);
+
 	list_for_each_entry_safe(np, tmp, &ndp->packages, node)
 		ncsi_remove_package(np);
 
 	spin_lock_irqsave(&ncsi_dev_lock, flags);
 	list_del_rcu(&ndp->node);
+#if IS_ENABLED(CONFIG_IPV6)
+	if (list_empty(&ncsi_dev_list))
+		unregister_inet6addr_notifier(&ncsi_inet6addr_notifier);
+#endif
 	spin_unlock_irqrestore(&ncsi_dev_lock, flags);
 
 	kfree(ndp);
diff --git a/net/ncsi/ncsi-rsp.c b/net/ncsi/ncsi-rsp.c
index 6ec25cb..a21af88 100644
--- a/net/ncsi/ncsi-rsp.c
+++ b/net/ncsi/ncsi-rsp.c
@@ -69,6 +69,9 @@ static int ncsi_rsp_handler_cis(struct ncsi_request *nr)
 	rsp = (struct ncsi_rsp_pkt *)skb_network_header(nr->rsp);
 	ncsi_find_package_and_channel(ndp, rsp->rsp.common.channel, &np, &nc);
 	if (!nc) {
+		if (ndp->flags & NCSI_DEV_PROBED)
+			return -ENXIO;
+
 		id = NCSI_CHANNEL_INDEX(rsp->rsp.common.channel);
 		nc = ncsi_add_channel(np, id);
 	}
@@ -90,6 +93,9 @@ static int ncsi_rsp_handler_sp(struct ncsi_request *nr)
 	ncsi_find_package_and_channel(ndp, rsp->rsp.common.channel,
 				      &np, NULL);
 	if (!np) {
+		if (ndp->flags & NCSI_DEV_PROBED)
+			return -ENXIO;
+
 		id = NCSI_PACKAGE_INDEX(rsp->rsp.common.channel);
 		np = ncsi_add_package(ndp, id);
 		if (!np)
@@ -297,6 +303,7 @@ static int ncsi_rsp_handler_gls(struct ncsi_request *nr)
 	struct ncsi_dev_priv *ndp = nr->ndp;
 	struct ncsi_channel *nc;
 	struct ncsi_channel_mode *ncm;
+	unsigned long flags;
 
 	/* Find the package and channel */
 	rsp = (struct ncsi_rsp_gls_pkt *)skb_network_header(nr->rsp);
@@ -310,6 +317,14 @@ static int ncsi_rsp_handler_gls(struct ncsi_request *nr)
 	ncm->data[3] = ntohl(rsp->other);
 	ncm->data[4] = ntohl(rsp->oem_status);
 
+	if (nr->driven)
+		return 0;
+
+	/* Reset the channel monitor if it has been enabled */
+	spin_lock_irqsave(&nc->lock, flags);
+	nc->timeout = 0;
+	spin_unlock_irqrestore(&nc->lock, flags);
+
 	return 0;
 }
 
-- 
2.1.0
