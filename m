From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 3/9] IB/ipoib: Add support for acting as VIF
Date: Tue, 10 Jul 2012 15:16:03 +0300
Message-ID: <1341922569-4118-4-git-send-email-ogerlitz@mellanox.com>
References: <1341922569-4118-1-git-send-email-ogerlitz@mellanox.com>
Cc: roland@kernel.org, netdev@vger.kernel.org, ali@mellanox.com,
	sean.hefty@intel.com, Erez Shitrit <erezsh@mellanox.co.il>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog119.obsmtp.com ([207.126.144.147]:46106 "HELO
	eu1sys200aog119.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1755323Ab2GJMQX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jul 2012 08:16:23 -0400
In-Reply-To: <1341922569-4118-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Erez Shitrit <erezsh@mellanox.co.il>

When IPoIB interface acts as a VIF for an eIPoIB interface, it uses
the skb cb storage area on the RX flow, to place information which
can be of use to the upper layer device.

One such usage example, is when an eIPoIB inteface needs to generate
a source mac for incoming Ethernet frames.

The IPoIB code checks the VIF private flag on the RX path, and accoriding
to the value of the flag prepares the skb CB data, etc.

Signed-off-by: Erez Shitrit <erezsh@mellanox.co.il>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/infiniband/ulp/ipoib/ipoib.h      |    6 +++
 drivers/infiniband/ulp/ipoib/ipoib_cm.c   |    9 +++++
 drivers/infiniband/ulp/ipoib/ipoib_ib.c   |    8 ++++-
 drivers/infiniband/ulp/ipoib/ipoib_main.c |   28 ++++++++++++++++
 include/rdma/e_ipoib.h                    |   51 +++++++++++++++++++++++++++++
 5 files changed, 101 insertions(+), 1 deletions(-)
 create mode 100644 include/rdma/e_ipoib.h

diff --git a/drivers/infiniband/ulp/ipoib/ipoib.h b/drivers/infiniband/ulp/ipoib/ipoib.h
index a57db27..1d28774 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib.h
+++ b/drivers/infiniband/ulp/ipoib/ipoib.h
@@ -52,6 +52,7 @@
 #include <rdma/ib_pack.h>
 #include <rdma/ib_sa.h>
 #include <linux/sched.h>
+#include <rdma/e_ipoib.h>
 
 /* constants */
 
@@ -209,6 +210,7 @@ struct ipoib_cm_rx {
 	unsigned long		jiffies;
 	enum ipoib_cm_state	state;
 	int			recv_count;
+	u32			qpn;
 };
 
 struct ipoib_cm_tx {
@@ -695,6 +697,10 @@ extern int ipoib_recvq_size;
 
 extern struct ib_sa_client ipoib_sa_client;
 
+
+inline void set_skb_oob_cb_data(struct sk_buff *skb, struct ib_wc *wc,
+				struct napi_struct *napi);
+
 #ifdef CONFIG_INFINIBAND_IPOIB_DEBUG
 extern int ipoib_debug_level;
 
diff --git a/drivers/infiniband/ulp/ipoib/ipoib_cm.c b/drivers/infiniband/ulp/ipoib/ipoib_cm.c
index 014504d..dca7952 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_cm.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_cm.c
@@ -440,6 +440,7 @@ static int ipoib_cm_req_handler(struct ib_cm_id *cm_id, struct ib_cm_event *even
 	struct net_device *dev = cm_id->context;
 	struct ipoib_dev_priv *priv = netdev_priv(dev);
 	struct ipoib_cm_rx *p;
+	struct ipoib_cm_data *data = event->private_data;
 	unsigned psn;
 	int ret;
 
@@ -452,6 +453,10 @@ static int ipoib_cm_req_handler(struct ib_cm_id *cm_id, struct ib_cm_event *even
 	cm_id->context = p;
 	p->state = IPOIB_CM_RX_LIVE;
 	p->jiffies = jiffies;
+
+	/* used to keep track of base qpn in CM mode */
+	p->qpn = be32_to_cpu(data->qpn);
+
 	INIT_LIST_HEAD(&p->list);
 
 	p->qp = ipoib_cm_create_rx_qp(dev, p);
@@ -669,6 +674,10 @@ copied:
 	skb->dev = dev;
 	/* XXX get correct PACKET_ type here */
 	skb->pkt_type = PACKET_HOST;
+	/* if handler is registered on top of ipoib, set skb oob data. */
+	if (skb->dev->priv_flags & IFF_EIPOIB_VIF)
+		set_skb_oob_cb_data(skb, wc, NULL);
+
 	netif_receive_skb(skb);
 
 repost:
diff --git a/drivers/infiniband/ulp/ipoib/ipoib_ib.c b/drivers/infiniband/ulp/ipoib/ipoib_ib.c
index 5c1bc99..da28799 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_ib.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_ib.c
@@ -300,7 +300,13 @@ static void ipoib_ib_handle_rx_wc(struct net_device *dev, struct ib_wc *wc)
 			likely(wc->wc_flags & IB_WC_IP_CSUM_OK))
 		skb->ip_summed = CHECKSUM_UNNECESSARY;
 
-	napi_gro_receive(&priv->napi, skb);
+	/* if handler is registered on top of ipoib, set skb oob data */
+	if (dev->priv_flags & IFF_EIPOIB_VIF) {
+		set_skb_oob_cb_data(skb, wc, &priv->napi);
+		/* the registered handler will take care of the skb */
+		netif_receive_skb(skb);
+	} else
+		napi_gro_receive(&priv->napi, skb);
 
 repost:
 	if (unlikely(ipoib_ib_post_receive(dev, wr_id)))
diff --git a/drivers/infiniband/ulp/ipoib/ipoib_main.c b/drivers/infiniband/ulp/ipoib/ipoib_main.c
index 704d068..1ccd42f 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_main.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_main.c
@@ -91,6 +91,31 @@ static struct ib_client ipoib_client = {
 	.remove = ipoib_remove_one
 };
 
+inline void set_skb_oob_cb_data(struct sk_buff *skb, struct ib_wc *wc,
+				struct napi_struct *napi)
+{
+	struct ipoib_cm_rx *p_cm_ctx = NULL;
+	union skb_cb_data *data = NULL;
+	struct ib_grh *grh = NULL;
+
+	p_cm_ctx = wc->qp->qp_context;
+	data = IPOIB_HANDLER_CB(skb);
+
+	data->rx.slid = wc->slid;
+	data->rx.sqpn = wc->src_qp;
+	data->rx.napi = napi;
+
+	/* if dqpn is mcast, fetch the dgid */
+	grh = (struct ib_grh *)(skb->data - IB_GRH_BYTES - IPOIB_ENCAP_LEN);
+
+	if ((wc->wc_flags & IB_WC_GRH) && grh)
+		memcpy(data->rx.dgid, grh->dgid.raw, 16);
+
+	/* in CM mode, use the "base" qpn as sqpn */
+	if (p_cm_ctx)
+		data->rx.sqpn = p_cm_ctx->qpn;
+}
+
 int ipoib_open(struct net_device *dev)
 {
 	struct ipoib_dev_priv *priv = netdev_priv(dev);
@@ -1277,6 +1302,9 @@ static struct net_device *ipoib_add_port(const char *format,
 		goto event_failed;
 	}
 
+	/* indicates pif port */
+	priv->dev->priv_flags |= IFF_EIPOIB_PIF;
+
 	result = register_netdev(priv->dev);
 	if (result) {
 		printk(KERN_WARNING "%s: couldn't register ipoib port %d; error %d\n",
diff --git a/include/rdma/e_ipoib.h b/include/rdma/e_ipoib.h
new file mode 100644
index 0000000..481514e
--- /dev/null
+++ b/include/rdma/e_ipoib.h
@@ -0,0 +1,51 @@
+/*
+ * Copyright (c) 2012 Mellanox Technologies. All rights reserved
+ *
+ * This software is available to you under a choice of one of two
+ * licenses.  You may choose to be licensed under the terms of the GNU
+ * General Public License (GPL) Version 2, available from the file
+ * COPYING in the main directory of this source tree, or the
+ * openfabric.org BSD license below:
+ *
+ *     Redistribution and use in source and binary forms, with or
+ *     without modification, are permitted provided that the following
+ *     conditions are met:
+ *
+ *      - Redistributions of source code must retain the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer.
+ *
+ *      - Redistributions in binary form must reproduce the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer in the documentation and/or other materials
+ *        provided with the distribution.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ */
+
+#ifndef _LINUX_ETH_IB_IPOIB_H
+#define _LINUX_ETH_IB_IPOIB_H
+#include <linux/skbuff.h>
+#include <linux/if_infiniband.h>
+#include <rdma/ib_verbs.h>
+
+/* must be <= 48 bytes */
+union skb_cb_data {
+	struct {
+		u32 sqpn;
+		u16 slid;
+		u8  dgid[16];
+		struct napi_struct *napi;
+	} rx;
+};
+
+#define IPOIB_HANDLER_CB(skb) ((union skb_cb_data *)(skb)->cb)
+
+#endif /* _LINUX_ETH_IB_IPOIB_H */
-- 
1.7.1
