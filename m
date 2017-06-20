From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH net-next v2 02/12] nfp: devlink add support for getting eswitch mode
Date: Tue, 20 Jun 2017 23:36:10 +0200
Message-ID: <1497994580-6271-3-git-send-email-simon.horman@netronome.com>
References: <1497994580-6271-1-git-send-email-simon.horman@netronome.com>
Cc: netdev@vger.kernel.org, oss-drivers@netronome.com,
        Or Gerlitz <gerlitz.or@gmail.com>,
        Simon Horman <simon.horman@netronome.com>
To: David Miller <davem@davemloft.net>,
        Jakub Kicinski <jakub.kicinski@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f175.google.com ([209.85.216.175]:33368 "EHLO
        mail-qt0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752477AbdFTVgp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Jun 2017 17:36:45 -0400
Received: by mail-qt0-f175.google.com with SMTP id u12so143973008qth.0
        for <netdev@vger.kernel.org>; Tue, 20 Jun 2017 14:36:45 -0700 (PDT)
In-Reply-To: <1497994580-6271-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jakub Kicinski <jakub.kicinski@netronome.com>

Add app callback for reporting eswitch mode.  Non-SRIOV apps
should not implement this callback, nfp_app code will then
respond with -EOPNOTSUPP.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Signed-off-by: Simon Horman <simon.horman@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_app.h     | 15 +++++++++++++++
 drivers/net/ethernet/netronome/nfp/nfp_devlink.c | 18 ++++++++++++++++++
 2 files changed, 33 insertions(+)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_app.h b/drivers/net/ethernet/netronome/nfp/nfp_app.h
index f5e373fa8c3b..0fee14ffa081 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_app.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_app.h
@@ -34,6 +34,8 @@
 #ifndef _NFP_APP_H
 #define _NFP_APP_H 1
 
+#include <net/devlink.h>
+
 struct bpf_prog;
 struct net_device;
 struct pci_dev;
@@ -70,6 +72,7 @@ extern const struct nfp_app_type app_bpf;
  * @setup_tc:	setup TC ndo
  * @tc_busy:	TC HW offload busy (rules loaded)
  * @xdp_offload:    offload an XDP program
+ * @eswitch_mode_get:    get SR-IOV eswitch mode
  */
 struct nfp_app_type {
 	enum nfp_app_id id;
@@ -95,6 +98,8 @@ struct nfp_app_type {
 	bool (*tc_busy)(struct nfp_app *app, struct nfp_net *nn);
 	int (*xdp_offload)(struct nfp_app *app, struct nfp_net *nn,
 			   struct bpf_prog *prog);
+
+	enum devlink_eswitch_mode (*eswitch_mode_get)(struct nfp_app *app);
 };
 
 /**
@@ -216,6 +221,16 @@ static inline void nfp_app_ctrl_rx(struct nfp_app *app, struct sk_buff *skb)
 	app->type->ctrl_msg_rx(app, skb);
 }
 
+static inline int nfp_app_eswitch_mode_get(struct nfp_app *app, u16 *mode)
+{
+	if (!app->type->eswitch_mode_get)
+		return -EOPNOTSUPP;
+
+	*mode = app->type->eswitch_mode_get(app);
+
+	return 0;
+}
+
 const char *nfp_app_mip_name(struct nfp_app *app);
 struct sk_buff *nfp_app_ctrl_msg_alloc(struct nfp_app *app, unsigned int size);
 
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_devlink.c b/drivers/net/ethernet/netronome/nfp/nfp_devlink.c
index 2609a0f28e81..6c9f29c2e975 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_devlink.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_devlink.c
@@ -149,9 +149,27 @@ nfp_devlink_port_unsplit(struct devlink *devlink, unsigned int port_index)
 	return ret;
 }
 
+static int nfp_devlink_eswitch_mode_get(struct devlink *devlink, u16 *mode)
+{
+	struct nfp_pf *pf = devlink_priv(devlink);
+	int ret;
+
+	mutex_lock(&pf->lock);
+	if (!pf->app) {
+		ret = -EBUSY;
+		goto out;
+	}
+	ret = nfp_app_eswitch_mode_get(pf->app, mode);
+out:
+	mutex_unlock(&pf->lock);
+
+	return ret;
+}
+
 const struct devlink_ops nfp_devlink_ops = {
 	.port_split		= nfp_devlink_port_split,
 	.port_unsplit		= nfp_devlink_port_unsplit,
+	.eswitch_mode_get	= nfp_devlink_eswitch_mode_get,
 };
 
 int nfp_devlink_port_register(struct nfp_app *app, struct nfp_port *port)
-- 
2.1.4
