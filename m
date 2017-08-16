From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH net-next 1/2] nfp: process control messages in workqueue in flower app
Date: Wed, 16 Aug 2017 09:37:43 +0200
Message-ID: <1502869064-25842-2-git-send-email-simon.horman@netronome.com>
References: <1502869064-25842-1-git-send-email-simon.horman@netronome.com>
Cc: netdev@vger.kernel.org, oss-drivers@netronome.com,
        Simon Horman <simon.horman@netronome.com>
To: David Miller <davem@davemloft.net>,
        Jakub Kicinski <jakub.kicinski@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f44.google.com ([74.125.82.44]:38288 "EHLO
        mail-wm0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751068AbdHPHh4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2017 03:37:56 -0400
Received: by mail-wm0-f44.google.com with SMTP id f15so26640399wmg.1
        for <netdev@vger.kernel.org>; Wed, 16 Aug 2017 00:37:55 -0700 (PDT)
In-Reply-To: <1502869064-25842-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Processing of control messages is not time-critical and future processing
of some messages will require taking the RTNL which is not possible
in a BH handler. It seems simplest to move all control message processing
to a workqueue.

Signed-off-by: Simon Horman <simon.horman@netronome.com>
Reviewed-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/flower/cmsg.c | 24 +++++++++++++++++++++++-
 drivers/net/ethernet/netronome/nfp/flower/cmsg.h |  1 +
 drivers/net/ethernet/netronome/nfp/flower/main.c | 14 ++++++++++++--
 drivers/net/ethernet/netronome/nfp/flower/main.h |  5 +++++
 4 files changed, 41 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/flower/cmsg.c b/drivers/net/ethernet/netronome/nfp/flower/cmsg.c
index aa46b23cdfb1..6c8c22491fe7 100644
--- a/drivers/net/ethernet/netronome/nfp/flower/cmsg.c
+++ b/drivers/net/ethernet/netronome/nfp/flower/cmsg.c
@@ -34,10 +34,12 @@
 #include <linux/bitfield.h>
 #include <linux/netdevice.h>
 #include <linux/skbuff.h>
+#include <linux/workqueue.h>
 #include <net/dst_metadata.h>
 
 #include "main.h"
 #include "../nfpcore/nfp_cpp.h"
+#include "../nfp_net.h"
 #include "../nfp_net_repr.h"
 #include "./cmsg.h"
 
@@ -155,7 +157,8 @@ nfp_flower_cmsg_portmod_rx(struct nfp_app *app, struct sk_buff *skb)
 	rcu_read_unlock();
 }
 
-void nfp_flower_cmsg_rx(struct nfp_app *app, struct sk_buff *skb)
+static void
+nfp_flower_cmsg_process_one_rx(struct nfp_app *app, struct sk_buff *skb)
 {
 	struct nfp_flower_cmsg_hdr *cmsg_hdr;
 	enum nfp_flower_cmsg_type_port type;
@@ -184,3 +187,22 @@ void nfp_flower_cmsg_rx(struct nfp_app *app, struct sk_buff *skb)
 out:
 	dev_kfree_skb_any(skb);
 }
+
+void nfp_flower_cmsg_process_rx(struct work_struct *work)
+{
+	struct nfp_flower_priv *priv;
+	struct sk_buff *skb;
+
+	priv = container_of(work, struct nfp_flower_priv, cmsg_work);
+
+	while ((skb = skb_dequeue(&priv->cmsg_skbs)))
+		nfp_flower_cmsg_process_one_rx(priv->nn->app, skb);
+}
+
+void nfp_flower_cmsg_rx(struct nfp_app *app, struct sk_buff *skb)
+{
+	struct nfp_flower_priv *priv = app->priv;
+
+	skb_queue_tail(&priv->cmsg_skbs, skb);
+	schedule_work(&priv->cmsg_work);
+}
diff --git a/drivers/net/ethernet/netronome/nfp/flower/cmsg.h b/drivers/net/ethernet/netronome/nfp/flower/cmsg.h
index aa92a8711a02..a2ec60344236 100644
--- a/drivers/net/ethernet/netronome/nfp/flower/cmsg.h
+++ b/drivers/net/ethernet/netronome/nfp/flower/cmsg.h
@@ -330,6 +330,7 @@ nfp_flower_cmsg_mac_repr_add(struct sk_buff *skb, unsigned int idx,
 			     unsigned int nbi, unsigned int nbi_port,
 			     unsigned int phys_port);
 int nfp_flower_cmsg_portmod(struct nfp_repr *repr, bool carrier_ok);
+void nfp_flower_cmsg_process_rx(struct work_struct *work);
 void nfp_flower_cmsg_rx(struct nfp_app *app, struct sk_buff *skb);
 struct sk_buff *
 nfp_flower_cmsg_alloc(struct nfp_app *app, unsigned int size,
diff --git a/drivers/net/ethernet/netronome/nfp/flower/main.c b/drivers/net/ethernet/netronome/nfp/flower/main.c
index b905454b30ca..3088e959f2a3 100644
--- a/drivers/net/ethernet/netronome/nfp/flower/main.c
+++ b/drivers/net/ethernet/netronome/nfp/flower/main.c
@@ -332,6 +332,7 @@ static int nfp_flower_vnic_init(struct nfp_app *app, struct nfp_net *nn,
 static int nfp_flower_init(struct nfp_app *app)
 {
 	const struct nfp_pf *pf = app->pf;
+	struct nfp_flower_priv *app_priv;
 	u64 version;
 	int err;
 
@@ -362,10 +363,14 @@ static int nfp_flower_init(struct nfp_app *app)
 		return -EINVAL;
 	}
 
-	app->priv = vzalloc(sizeof(struct nfp_flower_priv));
-	if (!app->priv)
+	app_priv = vzalloc(sizeof(struct nfp_flower_priv));
+	if (!app_priv)
 		return -ENOMEM;
 
+	app->priv = app_priv;
+	skb_queue_head_init(&app_priv->cmsg_skbs);
+	INIT_WORK(&app_priv->cmsg_work, nfp_flower_cmsg_process_rx);
+
 	err = nfp_flower_metadata_init(app);
 	if (err)
 		goto err_free_app_priv;
@@ -379,6 +384,11 @@ static int nfp_flower_init(struct nfp_app *app)
 
 static void nfp_flower_clean(struct nfp_app *app)
 {
+	struct nfp_flower_priv *app_priv = app->priv;
+
+	skb_queue_purge(&app_priv->cmsg_skbs);
+	flush_work(&app_priv->cmsg_work);
+
 	nfp_flower_metadata_cleanup(app);
 	vfree(app->priv);
 	app->priv = NULL;
diff --git a/drivers/net/ethernet/netronome/nfp/flower/main.h b/drivers/net/ethernet/netronome/nfp/flower/main.h
index 71e4f4f4e9ba..b7043ca9b9fc 100644
--- a/drivers/net/ethernet/netronome/nfp/flower/main.h
+++ b/drivers/net/ethernet/netronome/nfp/flower/main.h
@@ -39,6 +39,7 @@
 #include <linux/time64.h>
 #include <linux/types.h>
 #include <net/pkt_cls.h>
+#include <linux/workqueue.h>
 
 struct net_device;
 struct nfp_app;
@@ -78,6 +79,8 @@ struct nfp_fl_stats_id {
  * @mask_ids:		List of free mask ids
  * @mask_table:		Hash table used to store masks
  * @flow_table:		Hash table used to store flower rules
+ * @cmsg_work:		Workqueue for control messages processing
+ * @cmsg_skbs:		List of skbs for control message processing
  */
 struct nfp_flower_priv {
 	struct nfp_net *nn;
@@ -87,6 +90,8 @@ struct nfp_flower_priv {
 	struct nfp_fl_mask_id mask_ids;
 	DECLARE_HASHTABLE(mask_table, NFP_FLOWER_MASK_HASH_BITS);
 	DECLARE_HASHTABLE(flow_table, NFP_FLOWER_HASH_BITS);
+	struct work_struct cmsg_work;
+	struct sk_buff_head cmsg_skbs;
 };
 
 struct nfp_fl_key_ls {
-- 
2.1.4
