From: Rahul Lakkireddy <rahul.lakkireddy@chelsio.com>
Subject: [PATCH net-next 3/3] cxgb4: add support for tx max rate limiting
Date: Mon, 22 Aug 2016 16:29:08 +0530
Message-ID: <17f2504e69ee3682f8b7d2b980cc236f52831bd3.1471848005.git.rahul.lakkireddy@chelsio.com>
References: <cover.1471848004.git.rahul.lakkireddy@chelsio.com>
Cc: davem@davemloft.net, hariprasad@chelsio.com, leedom@chelsio.com,
        nirranjan@chelsio.com, indranil@chelsio.com,
        Rahul Lakkireddy <rahul.lakkireddy@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:46088 "EHLO
        stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1752247AbcHVLB6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 Aug 2016 07:01:58 -0400
In-Reply-To: <cover.1471848004.git.rahul.lakkireddy@chelsio.com>
In-Reply-To: <cover.1471848004.git.rahul.lakkireddy@chelsio.com>
References: <cover.1471848004.git.rahul.lakkireddy@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Implement set_tx_maxrate NDO to perform per queue tx rate limiting.

Signed-off-by: Rahul Lakkireddy <rahul.lakkireddy@chelsio.com>
Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h      | 20 ++++++
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c | 82 +++++++++++++++++++++++++
 drivers/net/ethernet/chelsio/cxgb4/sched.h      |  3 +
 3 files changed, 105 insertions(+)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
index eb30612..f988c60 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
@@ -881,6 +881,26 @@ struct ch_sched_params {
 	} u;
 };
 
+enum {
+	SCHED_CLASS_TYPE_PACKET = 0,    /* class type */
+};
+
+enum {
+	SCHED_CLASS_LEVEL_CL_RL = 0,    /* class rate limiter */
+};
+
+enum {
+	SCHED_CLASS_MODE_CLASS = 0,     /* per-class scheduling */
+};
+
+enum {
+	SCHED_CLASS_RATEUNIT_BITS = 0,  /* bit rate scheduling */
+};
+
+enum {
+	SCHED_CLASS_RATEMODE_ABS = 1,   /* Kb/s */
+};
+
 /* Support for "sched_queue" command to allow one or more NIC TX Queues
  * to be bound to a TX Scheduling Class.
  */
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 2e341bf..be5c942 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -3140,6 +3140,87 @@ static void cxgb_netpoll(struct net_device *dev)
 }
 #endif
 
+static int cxgb_set_tx_maxrate(struct net_device *dev, int index, u32 rate)
+{
+	struct port_info *pi = netdev_priv(dev);
+	struct adapter *adap = pi->adapter;
+	struct sched_class *e;
+	struct ch_sched_params p;
+	struct ch_sched_queue qe;
+	u32 req_rate;
+	int err = 0;
+
+	if (!can_sched(dev))
+		return -ENOTSUPP;
+
+	if (index < 0 || index > pi->nqsets - 1)
+		return -EINVAL;
+
+	if (!(adap->flags & FULL_INIT_DONE)) {
+		dev_err(adap->pdev_dev,
+			"Failed to rate limit on queue %d. Link Down?\n",
+			index);
+		return -EINVAL;
+	}
+
+	/* Convert from Mbps to Kbps */
+	req_rate = rate << 10;
+
+	/* Max rate is 10 Gbps */
+	if (req_rate >= SCHED_MAX_RATE_KBPS) {
+		dev_err(adap->pdev_dev,
+			"Invalid rate %u Mbps, Max rate is %u Gbps\n",
+			rate, SCHED_MAX_RATE_KBPS);
+		return -ERANGE;
+	}
+
+	/* First unbind the queue from any existing class */
+	memset(&qe, 0, sizeof(qe));
+	qe.queue = index;
+	qe.class = SCHED_CLS_NONE;
+
+	err = cxgb4_sched_class_unbind(dev, (void *)(&qe), SCHED_QUEUE);
+	if (err) {
+		dev_err(adap->pdev_dev,
+			"Unbinding Queue %d on port %d fail. Err: %d\n",
+			index, pi->port_id, err);
+		return err;
+	}
+
+	/* Queue already unbound */
+	if (!req_rate)
+		return 0;
+
+	/* Fetch any available unused or matching scheduling class */
+	memset(&p, 0, sizeof(p));
+	p.type = SCHED_CLASS_TYPE_PACKET;
+	p.u.params.level    = SCHED_CLASS_LEVEL_CL_RL;
+	p.u.params.mode     = SCHED_CLASS_MODE_CLASS;
+	p.u.params.rateunit = SCHED_CLASS_RATEUNIT_BITS;
+	p.u.params.ratemode = SCHED_CLASS_RATEMODE_ABS;
+	p.u.params.channel  = pi->tx_chan;
+	p.u.params.class    = SCHED_CLS_NONE;
+	p.u.params.minrate  = 0;
+	p.u.params.maxrate  = req_rate;
+	p.u.params.weight   = 0;
+	p.u.params.pktsize  = dev->mtu;
+
+	e = cxgb4_sched_class_alloc(dev, &p);
+	if (!e)
+		return -ENOMEM;
+
+	/* Bind the queue to a scheduling class */
+	memset(&qe, 0, sizeof(qe));
+	qe.queue = index;
+	qe.class = e->idx;
+
+	err = cxgb4_sched_class_bind(dev, (void *)(&qe), SCHED_QUEUE);
+	if (err)
+		dev_err(adap->pdev_dev,
+			"Queue rate limiting failed. Err: %d\n", err);
+	return err;
+}
+
 static const struct net_device_ops cxgb4_netdev_ops = {
 	.ndo_open             = cxgb_open,
 	.ndo_stop             = cxgb_close,
@@ -3162,6 +3243,7 @@ static const struct net_device_ops cxgb4_netdev_ops = {
 #ifdef CONFIG_NET_RX_BUSY_POLL
 	.ndo_busy_poll        = cxgb_busy_poll,
 #endif
+	.ndo_set_tx_maxrate   = cxgb_set_tx_maxrate,
 };
 
 static const struct net_device_ops cxgb4_mgmt_netdev_ops = {
diff --git a/drivers/net/ethernet/chelsio/cxgb4/sched.h b/drivers/net/ethernet/chelsio/cxgb4/sched.h
index ac415eb..77b2b3f 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/sched.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/sched.h
@@ -42,6 +42,9 @@
 
 #define FW_SCHED_CLS_NONE 0xffffffff
 
+/* Max rate that can be set to a scheduling class is 10 Gbps */
+#define SCHED_MAX_RATE_KBPS 10000000U
+
 enum {
 	SCHED_STATE_ACTIVE,
 	SCHED_STATE_UNUSED,
-- 
2.5.3
