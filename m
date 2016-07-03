From: Gavin Shan <gwshan@linux.vnet.ibm.com>
Subject: [PATCH net-next 04/10] net/ncsi: Package and channel management
Date: Sun,  3 Jul 2016 15:32:27 +1000
Message-ID: <1467523953-18998-5-git-send-email-gwshan@linux.vnet.ibm.com>
References: <1467523953-18998-1-git-send-email-gwshan@linux.vnet.ibm.com>
Cc: davem@davemloft.net, benh@kernel.crashing.org, joel@jms.id.au,
	weixue@trustnetic.com, Gavin Shan <gwshan@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:14270 "EHLO
	mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750944AbcGCFcq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Jul 2016 01:32:46 -0400
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u635TL6s016387
	for <netdev@vger.kernel.org>; Sun, 3 Jul 2016 01:32:45 -0400
Received: from e23smtp02.au.ibm.com (e23smtp02.au.ibm.com [202.81.31.144])
	by mx0b-001b2d01.pphosted.com with ESMTP id 23x6hvjuje-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Sun, 03 Jul 2016 01:32:44 -0400
Received: from localhost
	by e23smtp02.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <gwshan@linux.vnet.ibm.com>;
	Sun, 3 Jul 2016 15:32:41 +1000
Received: from d23relay08.au.ibm.com (d23relay08.au.ibm.com [9.185.71.33])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 1B98F3578052
	for <netdev@vger.kernel.org>; Sun,  3 Jul 2016 15:32:39 +1000 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay08.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u635Wd5t8585632
	for <netdev@vger.kernel.org>; Sun, 3 Jul 2016 15:32:39 +1000
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u635Wcwq012280
	for <netdev@vger.kernel.org>; Sun, 3 Jul 2016 15:32:38 +1000
In-Reply-To: <1467523953-18998-1-git-send-email-gwshan@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The available NCSI packages and channels are probed with help of
NCSI command/response packets. One package and channel should be
selected as active one by which the MC (Management Controller)
can communicate with the far end and external network. The currently
active channel should be disabled and another available channel should
be selected as active one when AEN (Asychronous Event Notification)
packets received.

This introduces state machine and corresponding functions for above
purposes. ncsi_start_dev() should be called after ncsi_register_dev()
in network device driver. It probes all available NCSI packages and
channels and selects the active one to provide service. ncsi_config_dev()
and ncsi_suspend_dev() are going to be used when AEN (Asychronous
Event Notification) packets are received.

Signed-off-by: Gavin Shan <gwshan@linux.vnet.ibm.com>
Acked-by: Joel Stanley <joel@jms.id.au>
---
 include/net/ncsi.h     |   6 +
 net/ncsi/internal.h    |  34 ++++
 net/ncsi/ncsi-manage.c | 471 +++++++++++++++++++++++++++++++++++++++++++++++++
 net/ncsi/ncsi-rsp.c    |   6 +
 4 files changed, 517 insertions(+)

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
index 508836a..e322f9e 100644
--- a/net/ncsi/internal.h
+++ b/net/ncsi/internal.h
@@ -205,9 +205,38 @@ struct ncsi_req {
 	bool                 timer_enabled;	/* Timer was started   */
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
 	struct ncsi_dev     ndev;		/* NCSI device              */
 	int                 flags;		/* NCSI device flags        */
+#define NCSI_DEV_FLAG_PROBED	0x1
+#define NCSI_DEV_FLAG_RESHUFFLE	0x2
 	struct ncsi_package *active_package;	/* Active NCSI package      */
 	struct ncsi_channel *active_channel;	/* Active NCSI channel      */
 	atomic_t            package_num;	/* Number of packages       */
@@ -216,6 +245,9 @@ struct ncsi_dev_priv {
 	spinlock_t          req_lock;		/* Protect request table    */
 	struct ncsi_req     reqs[256];		/* Request table            */
 	int                 last_req_idx;	/* Last used request ID     */
+	int                 pending_reqs;	/* Pending command number   */
+	struct work_struct  work;		/* For channel management   */
+	struct packet_type  ptype;		/* NCSI packet Rx handler   */
 	struct list_head    node;
 };
 
@@ -265,6 +297,8 @@ void ncsi_find_package_and_channel(struct ncsi_dev_priv *ndp,
 struct ncsi_req *ncsi_alloc_req(struct ncsi_dev_priv *ndp);
 void ncsi_free_req(struct ncsi_req *nr, bool check, bool timeout);
 struct ncsi_dev *ncsi_find_dev(struct net_device *dev);
+int ncsi_config_dev(struct ncsi_dev *nd);
+int ncsi_suspend_dev(struct ncsi_dev *nd);
 
 /* Packet handlers */
 u32 ncsi_calculate_checksum(unsigned char *data, int len);
diff --git a/net/ncsi/ncsi-manage.c b/net/ncsi/ncsi-manage.c
index b36e93d..7c9c8ac 100644
--- a/net/ncsi/ncsi-manage.c
+++ b/net/ncsi/ncsi-manage.c
@@ -19,6 +19,7 @@
 #include <net/sock.h>
 
 #include "internal.h"
+#include "ncsi-pkt.h"
 
 LIST_HEAD(ncsi_dev_list);
 DEFINE_SPINLOCK(ncsi_dev_lock);
@@ -329,6 +330,9 @@ void ncsi_free_req(struct ncsi_req *nr, bool check, bool timeout)
 	nr->used = false;
 	spin_unlock_irqrestore(&ndp->req_lock, flags);
 
+	if (check && cmd && --ndp->pending_reqs == 0)
+		schedule_work(&ndp->work);
+
 	/* Release command and response */
 	consume_skb(cmd);
 	consume_skb(rsp);
@@ -367,6 +371,413 @@ static void ncsi_req_timeout(unsigned long data)
 	ncsi_free_req(nr, true, true);
 }
 
+static void ncsi_dev_config(struct ncsi_dev_priv *ndp)
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
+	switch (nd->state) {
+	case ncsi_dev_state_config:
+	case ncsi_dev_state_config_sp:
+		ndp->pending_reqs = 1;
+
+		/* Select the specific package */
+		nca.type = NCSI_PKT_CMD_SP;
+		nca.bytes[0] = 1;
+		nca.package = np->id;
+		nca.channel = 0x1f;
+		ret = ncsi_xmit_cmd(&nca);
+		if (ret)
+			goto error;
+
+		nd->state = ncsi_dev_state_config_cis;
+		break;
+	case ncsi_dev_state_config_cis:
+		ndp->pending_reqs = 1;
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
+	case ncsi_dev_state_config_ecnt:
+	case ncsi_dev_state_config_ec:
+	case ncsi_dev_state_config_ae:
+	case ncsi_dev_state_config_gls:
+		ndp->pending_reqs = 1;
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
+		} else if (nd->state == ncsi_dev_state_config_ecnt) {
+			nca.type = NCSI_PKT_CMD_ECNT;
+			nd->state = ncsi_dev_state_config_ec;
+		} else if (nd->state == ncsi_dev_state_config_ec) {
+			nca.type = NCSI_PKT_CMD_EC;
+			nd->state = ncsi_dev_state_config_ae;
+		} else if (nd->state == ncsi_dev_state_config_ae) {
+			nca.type = NCSI_PKT_CMD_AE;
+			nca.bytes[0] = 0;
+			nca.dwords[1] = 0x7;
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
+		nd->state = ncsi_dev_state_functional;
+		nd->link_up = 0;
+		if (nc->modes[NCSI_MODE_LINK].data[2] & 0x1)
+			nd->link_up = 1;
+
+		nd->handler(nd);
+		ndp->flags &= ~NCSI_DEV_FLAG_RESHUFFLE;
+
+		break;
+	default:
+		pr_warn("NCSI: Wrong NCSI dev state 0x%x in config\n",
+			nd->state);
+	}
+
+	return;
+
+error:
+	nd->state = ncsi_dev_state_functional;
+	nd->link_up = 0;
+	ndp->flags &= ~NCSI_DEV_FLAG_RESHUFFLE;
+	nd->handler(nd);
+}
+
+static void ncsi_choose_active_channel(struct ncsi_dev_priv *ndp)
+{
+	struct ncsi_dev *nd;
+	struct ncsi_package *np;
+	struct ncsi_channel *nc;
+	struct ncsi_channel_mode *ncm;
+
+	nd = &ndp->ndev;
+	ndp->active_package = NULL;
+	ndp->active_channel = NULL;
+	NCSI_FOR_EACH_PACKAGE(ndp, np) {
+		NCSI_FOR_EACH_CHANNEL(np, nc) {
+			if (!ndp->active_channel) {
+				ndp->active_package = np;
+				ndp->active_channel = nc;
+			}
+
+			ncm = &nc->modes[NCSI_MODE_LINK];
+			if (ncm->data[2] & 0x1) {
+				ndp->active_package = np;
+				ndp->active_channel = nc;
+				goto configure;
+			}
+		}
+	}
+
+configure:
+	if (!ndp->active_channel) {
+		nd->state = ncsi_dev_state_functional;
+		nd->link_up = 0;
+		nd->handler(nd);
+	} else {
+		nd->state = ncsi_dev_state_config;
+		ncsi_dev_config(ndp);
+	}
+}
+
+static void ncsi_dev_probe(struct ncsi_dev_priv *ndp)
+{
+	struct ncsi_dev *nd = &ndp->ndev;
+	struct ncsi_package *np;
+	struct ncsi_channel *nc;
+	struct ncsi_cmd_arg nca;
+	unsigned char index;
+	int ret;
+
+	nca.ndp = ndp;
+	switch (nd->state) {
+	case ncsi_dev_state_probe:
+		nd->state = ncsi_dev_state_probe_deselect;
+		/* Fall through */
+	case ncsi_dev_state_probe_deselect:
+		ndp->pending_reqs = 8;
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
+		ndp->pending_reqs = 16;
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
+			ndp->flags |= NCSI_DEV_FLAG_PROBED;
+			ncsi_choose_active_channel(ndp);
+			return;
+		}
+
+		/* Select the active package */
+		ndp->pending_reqs = 1;
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
+		ndp->pending_reqs = 32;
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
+		ndp->pending_reqs = atomic_read(&np->channel_num);
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
+		ndp->pending_reqs = 1;
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
+		pr_warn("NCSI: Wrong NCSI dev state 0x%0x in enumeration\n",
+			nd->state);
+	}
+
+	return;
+error:
+	nd->state = ncsi_dev_state_functional;
+	nd->link_up = 0;
+	nd->handler(nd);
+}
+
+static void ncsi_dev_suspend(struct ncsi_dev_priv *ndp)
+{
+	struct ncsi_dev *nd = &ndp->ndev;
+	struct ncsi_package *np;
+	struct ncsi_channel *nc;
+	struct ncsi_cmd_arg nca;
+	int ret;
+
+	nca.ndp = ndp;
+	switch (nd->state) {
+	case ncsi_dev_state_suspend:
+		/* If there're no active channel, we're done */
+		if (!ndp->active_channel) {
+			nd->state = ncsi_dev_state_functional;
+
+			if (ndp->flags & NCSI_DEV_FLAG_RESHUFFLE) {
+				ndp->flags &= ~NCSI_DEV_FLAG_RESHUFFLE;
+				ncsi_choose_active_channel(ndp);
+			}
+
+			return;
+		}
+
+		nd->state = ncsi_dev_state_suspend_select;
+		/* Fall through */
+	case ncsi_dev_state_suspend_select:
+	case ncsi_dev_state_suspend_dcnt:
+	case ncsi_dev_state_suspend_dc:
+	case ncsi_dev_state_suspend_deselect:
+		ndp->pending_reqs = 1;
+
+		np = ndp->active_package;
+		nc = ndp->active_channel;
+		nca.package = np->id;
+		if (nd->state == ncsi_dev_state_suspend_select) {
+			nca.type = NCSI_PKT_CMD_SP;
+			nca.channel = 0x1f;
+			nca.bytes[0] = 1;
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
+		nd->state = ncsi_dev_state_functional;
+
+		if (ndp->flags & NCSI_DEV_FLAG_RESHUFFLE) {
+			ndp->flags &= ~NCSI_DEV_FLAG_RESHUFFLE;
+			ncsi_choose_active_channel(ndp);
+		}
+
+		break;
+	default:
+		pr_warn("NCSI: Wrong NCSI dev state 0x%x in suspend\n",
+			nd->state);
+	}
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
+		ncsi_dev_probe(ndp);
+		break;
+	case ncsi_dev_state_suspend:
+		ncsi_dev_suspend(ndp);
+		break;
+	case ncsi_dev_state_config:
+		ncsi_dev_config(ndp);
+		break;
+	default:
+		pr_warn("NCSI: Wrong NCSI dev state 0x%x in workqueue\n",
+			nd->state);
+	}
+}
+
 struct ncsi_dev *ncsi_register_dev(struct net_device *dev,
 				   void (*handler)(struct ncsi_dev *ndev))
 {
@@ -401,19 +812,79 @@ struct ncsi_dev *ncsi_register_dev(struct net_device *dev,
 			    (unsigned long)&ndp->reqs[idx]);
 	}
 
+	ndp->pending_reqs = 0;
+	INIT_WORK(&ndp->work, ncsi_dev_work);
+
 	spin_lock(&ncsi_dev_lock);
 	list_add_tail_rcu(&ndp->node, &ncsi_dev_list);
 	spin_unlock(&ncsi_dev_lock);
 
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
+
+	if (nd->state != ncsi_dev_state_registered &&
+	    nd->state != ncsi_dev_state_functional)
+		return -ENOTTY;
+
+	if (!(ndp->flags & NCSI_DEV_FLAG_PROBED)) {
+		nd->state = ncsi_dev_state_probe;
+		schedule_work(&ndp->work);
+		return 0;
+	}
+
+	/* Choose active package and channel */
+	ncsi_choose_active_channel(ndp);
+	if (!ndp->active_channel)
+		return -ENXIO;
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(ncsi_start_dev);
+
+int ncsi_config_dev(struct ncsi_dev *nd)
+{
+	struct ncsi_dev_priv *ndp = TO_NCSI_DEV_PRIV(nd);
+
+	if (nd->state != ncsi_dev_state_functional)
+		return -ENOTTY;
+
+	nd->state = ncsi_dev_state_config;
+	schedule_work(&ndp->work);
+
+	return 0;
+}
+
+int ncsi_suspend_dev(struct ncsi_dev *nd)
+{
+	struct ncsi_dev_priv *ndp = TO_NCSI_DEV_PRIV(nd);
+
+	if (nd->state != ncsi_dev_state_functional)
+		return -ENOTTY;
+
+	nd->state = ncsi_dev_state_suspend;
+	schedule_work(&ndp->work);
+
+	return 0;
+}
+
 void ncsi_unregister_dev(struct ncsi_dev *nd)
 {
 	struct ncsi_dev_priv *ndp = TO_NCSI_DEV_PRIV(nd);
 	struct ncsi_package *np, *tmp;
 
+	dev_remove_pack(&ndp->ptype);
+
 	spin_lock(&ndp->package_lock);
 	list_for_each_entry_safe(np, tmp, &ndp->packages, node)
 		ncsi_remove_package(np);
diff --git a/net/ncsi/ncsi-rsp.c b/net/ncsi/ncsi-rsp.c
index 20a45dc..5b81217 100644
--- a/net/ncsi/ncsi-rsp.c
+++ b/net/ncsi/ncsi-rsp.c
@@ -69,6 +69,9 @@ static int ncsi_rsp_handler_cis(struct ncsi_req *nr)
 	rsp = (struct ncsi_rsp_pkt *)skb_network_header(nr->rsp);
 	ncsi_find_package_and_channel(ndp, rsp->rsp.common.channel, &np, &nc);
 	if (!nc) {
+		if (ndp->flags & NCSI_DEV_FLAG_PROBED)
+			return -ENXIO;
+
 		id = NCSI_CHANNEL_INDEX(rsp->rsp.common.channel);
 		nc = ncsi_add_channel(np, id);
 	} else if (nc->state == ncsi_channel_state_deselected_initial) {
@@ -95,6 +98,9 @@ static int ncsi_rsp_handler_sp(struct ncsi_req *nr)
 	ncsi_find_package_and_channel(ndp, rsp->rsp.common.channel,
 				      &np, NULL);
 	if (!np) {
+		if (ndp->flags & NCSI_DEV_FLAG_PROBED)
+			return -ENXIO;
+
 		id = NCSI_PACKAGE_INDEX(rsp->rsp.common.channel);
 		np = ncsi_add_package(ndp, id);
 		if (!np)
-- 
2.1.0
