From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 05/14] nfp: add nfp_app cleanup callback and make flower use it
Date: Tue, 27 Jun 2017 00:50:19 -0700
Message-ID: <20170627075028.4009-6-jakub.kicinski@netronome.com>
References: <20170627075028.4009-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:34736 "EHLO
        mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752533AbdF0HvL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Jun 2017 03:51:11 -0400
Received: by mail-pf0-f172.google.com with SMTP id s66so12614417pfs.1
        for <netdev@vger.kernel.org>; Tue, 27 Jun 2017 00:51:10 -0700 (PDT)
In-Reply-To: <20170627075028.4009-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a cleanup callback for undoing what app init callback did.
Make flower allocate its private structure on init and free
it from the new callback.

While at it remember to set the app pointer to NULL on the
error path to avoid any races while probe path unwinds.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Simon Horman <simon.horman@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/flower/main.c  | 24 +++++++++++------------
 drivers/net/ethernet/netronome/nfp/nfp_app.h      | 10 +++++++++-
 drivers/net/ethernet/netronome/nfp/nfp_net_main.c |  6 +++++-
 3 files changed, 26 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/flower/main.c b/drivers/net/ethernet/netronome/nfp/flower/main.c
index 8e5ca6b4bb33..54d42a7f0d75 100644
--- a/drivers/net/ethernet/netronome/nfp/flower/main.c
+++ b/drivers/net/ethernet/netronome/nfp/flower/main.c
@@ -296,26 +296,16 @@ static int nfp_flower_start(struct nfp_app *app)
 					   NFP_REPR_TYPE_PF, 1);
 }
 
-static void nfp_flower_vnic_clean(struct nfp_app *app, struct nfp_net *nn)
-{
-	kfree(app->priv);
-	app->priv = NULL;
-}
-
 static int nfp_flower_vnic_init(struct nfp_app *app, struct nfp_net *nn,
 				unsigned int id)
 {
-	struct nfp_flower_priv *priv;
+	struct nfp_flower_priv *priv = app->priv;
 
 	if (id > 0) {
 		nfp_warn(app->cpp, "FlowerNIC doesn't support more than one data vNIC\n");
 		goto err_invalid_port;
 	}
 
-	priv = kzalloc(sizeof(*priv), GFP_KERNEL);
-	if (!priv)
-		return -ENOMEM;
-	app->priv = priv;
 	priv->nn = nn;
 
 	eth_hw_addr_random(nn->dp.netdev);
@@ -347,9 +337,19 @@ static int nfp_flower_init(struct nfp_app *app)
 		return -EINVAL;
 	}
 
+	app->priv = kzalloc(sizeof(struct nfp_flower_priv), GFP_KERNEL);
+	if (!app->priv)
+		return -ENOMEM;
+
 	return 0;
 }
 
+static void nfp_flower_clean(struct nfp_app *app)
+{
+	kfree(app->priv);
+	app->priv = NULL;
+}
+
 const struct nfp_app_type app_flower = {
 	.id		= NFP_APP_FLOWER_NIC,
 	.name		= "flower",
@@ -358,9 +358,9 @@ const struct nfp_app_type app_flower = {
 	.extra_cap	= nfp_flower_extra_cap,
 
 	.init		= nfp_flower_init,
+	.clean		= nfp_flower_clean,
 
 	.vnic_init	= nfp_flower_vnic_init,
-	.vnic_clean	= nfp_flower_vnic_clean,
 
 	.start		= nfp_flower_start,
 	.stop		= nfp_flower_stop,
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_app.h b/drivers/net/ethernet/netronome/nfp/nfp_app.h
index ae2d02753d1a..2fb503a817d2 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_app.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_app.h
@@ -66,7 +66,8 @@ extern const struct nfp_app_type app_flower;
  * @ctrl_has_meta:  control messages have prepend of type:5/port:CTRL
  *
  * Callbacks
- * @init:	perform basic app checks
+ * @init:	perform basic app checks and init
+ * @clean:	clean app state
  * @extra_cap:	extra capabilities string
  * @vnic_init:	init vNICs (assign port types, etc.)
  * @vnic_clean:	clean up app's vNIC state
@@ -88,6 +89,7 @@ struct nfp_app_type {
 	bool ctrl_has_meta;
 
 	int (*init)(struct nfp_app *app);
+	void (*clean)(struct nfp_app *app);
 
 	const char *(*extra_cap)(struct nfp_app *app, struct nfp_net *nn);
 
@@ -144,6 +146,12 @@ static inline int nfp_app_init(struct nfp_app *app)
 	return app->type->init(app);
 }
 
+static inline void nfp_app_clean(struct nfp_app *app)
+{
+	if (app->type->clean)
+		app->type->clean(app);
+}
+
 static inline int nfp_app_vnic_init(struct nfp_app *app, struct nfp_net *nn,
 				    unsigned int id)
 {
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_main.c b/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
index 93d6ea183956..49c4910fbcc6 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
@@ -414,7 +414,7 @@ nfp_net_pf_app_init(struct nfp_pf *pf, u8 __iomem *qc_bar, unsigned int stride)
 	if (IS_ERR(ctrl_bar)) {
 		nfp_err(pf->cpp, "Failed to find data vNIC memory symbol\n");
 		err = PTR_ERR(ctrl_bar);
-		goto err_free;
+		goto err_app_clean;
 	}
 
 	pf->ctrl_vnic =	nfp_net_pf_alloc_vnic(pf, false, ctrl_bar, qc_bar,
@@ -428,8 +428,11 @@ nfp_net_pf_app_init(struct nfp_pf *pf, u8 __iomem *qc_bar, unsigned int stride)
 
 err_unmap:
 	nfp_cpp_area_release_free(pf->ctrl_vnic_bar);
+err_app_clean:
+	nfp_app_clean(pf->app);
 err_free:
 	nfp_app_free(pf->app);
+	pf->app = NULL;
 	return err;
 }
 
@@ -439,6 +442,7 @@ static void nfp_net_pf_app_clean(struct nfp_pf *pf)
 		nfp_net_pf_free_vnic(pf, pf->ctrl_vnic);
 		nfp_cpp_area_release_free(pf->ctrl_vnic_bar);
 	}
+	nfp_app_clean(pf->app);
 	nfp_app_free(pf->app);
 	pf->app = NULL;
 }
-- 
2.11.0
