From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 2/6] nfp: flower: base lifetime of representors on existence of lower vNIC
Date: Sat,  2 Sep 2017 18:26:01 -0700
Message-ID: <20170903012605.7435-3-jakub.kicinski@netronome.com>
References: <20170903012605.7435-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:32882 "EHLO
        mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752954AbdICB0P (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 2 Sep 2017 21:26:15 -0400
Received: by mail-pf0-f173.google.com with SMTP id n73so9572482pfj.0
        for <netdev@vger.kernel.org>; Sat, 02 Sep 2017 18:26:15 -0700 (PDT)
In-Reply-To: <20170903012605.7435-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Create representors after lower vNIC is registered and destroy
them before it is destroyed.  Move the code out of start/stop
callbacks directly into vnic_init/clean callbacks.  Make sure
SR-IOV callbacks don't try to create representors when lower
device does not exist.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Simon Horman <simon.horman@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/flower/main.c | 66 +++++++++++++++---------
 1 file changed, 43 insertions(+), 23 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/flower/main.c b/drivers/net/ethernet/netronome/nfp/flower/main.c
index db59858c0f19..91fe03617106 100644
--- a/drivers/net/ethernet/netronome/nfp/flower/main.c
+++ b/drivers/net/ethernet/netronome/nfp/flower/main.c
@@ -127,6 +127,11 @@ nfp_flower_repr_netdev_stop(struct nfp_app *app, struct nfp_repr *repr)
 
 static void nfp_flower_sriov_disable(struct nfp_app *app)
 {
+	struct nfp_flower_priv *priv = app->priv;
+
+	if (!priv->nn)
+		return;
+
 	nfp_reprs_clean_and_free_by_type(app, NFP_REPR_TYPE_VF);
 }
 
@@ -203,18 +208,16 @@ nfp_flower_spawn_vnic_reprs(struct nfp_app *app,
 
 static int nfp_flower_sriov_enable(struct nfp_app *app, int num_vfs)
 {
+	struct nfp_flower_priv *priv = app->priv;
+
+	if (!priv->nn)
+		return 0;
+
 	return nfp_flower_spawn_vnic_reprs(app,
 					   NFP_FLOWER_CMSG_PORT_VNIC_TYPE_VF,
 					   NFP_REPR_TYPE_VF, num_vfs);
 }
 
-static void nfp_flower_stop(struct nfp_app *app)
-{
-	nfp_reprs_clean_and_free_by_type(app, NFP_REPR_TYPE_PF);
-	nfp_reprs_clean_and_free_by_type(app, NFP_REPR_TYPE_PHYS_PORT);
-
-}
-
 static int
 nfp_flower_spawn_phy_reprs(struct nfp_app *app, struct nfp_flower_priv *priv)
 {
@@ -300,19 +303,6 @@ nfp_flower_spawn_phy_reprs(struct nfp_app *app, struct nfp_flower_priv *priv)
 	return err;
 }
 
-static int nfp_flower_start(struct nfp_app *app)
-{
-	int err;
-
-	err = nfp_flower_spawn_phy_reprs(app, app->priv);
-	if (err)
-		return err;
-
-	return nfp_flower_spawn_vnic_reprs(app,
-					   NFP_FLOWER_CMSG_PORT_VNIC_TYPE_PF,
-					   NFP_REPR_TYPE_PF, 1);
-}
-
 static int nfp_flower_vnic_alloc(struct nfp_app *app, struct nfp_net *nn,
 				 unsigned int id)
 {
@@ -335,16 +325,49 @@ static void nfp_flower_vnic_clean(struct nfp_app *app, struct nfp_net *nn)
 {
 	struct nfp_flower_priv *priv = app->priv;
 
+	if (app->pf->num_vfs)
+		nfp_reprs_clean_and_free_by_type(app, NFP_REPR_TYPE_VF);
+	nfp_reprs_clean_and_free_by_type(app, NFP_REPR_TYPE_PF);
+	nfp_reprs_clean_and_free_by_type(app, NFP_REPR_TYPE_PHYS_PORT);
+
 	priv->nn = NULL;
 }
 
 static int nfp_flower_vnic_init(struct nfp_app *app, struct nfp_net *nn)
 {
 	struct nfp_flower_priv *priv = app->priv;
+	int err;
 
 	priv->nn = nn;
 
+	err = nfp_flower_spawn_phy_reprs(app, app->priv);
+	if (err)
+		goto err_clear_nn;
+
+	err = nfp_flower_spawn_vnic_reprs(app,
+					  NFP_FLOWER_CMSG_PORT_VNIC_TYPE_PF,
+					  NFP_REPR_TYPE_PF, 1);
+	if (err)
+		goto err_destroy_reprs_phy;
+
+	if (app->pf->num_vfs) {
+		err = nfp_flower_spawn_vnic_reprs(app,
+						  NFP_FLOWER_CMSG_PORT_VNIC_TYPE_VF,
+						  NFP_REPR_TYPE_VF,
+						  app->pf->num_vfs);
+		if (err)
+			goto err_destroy_reprs_pf;
+	}
+
 	return 0;
+
+err_destroy_reprs_pf:
+	nfp_reprs_clean_and_free_by_type(app, NFP_REPR_TYPE_PF);
+err_destroy_reprs_phy:
+	nfp_reprs_clean_and_free_by_type(app, NFP_REPR_TYPE_PHYS_PORT);
+err_clear_nn:
+	priv->nn = NULL;
+	return err;
 }
 
 static int nfp_flower_init(struct nfp_app *app)
@@ -430,9 +453,6 @@ const struct nfp_app_type app_flower = {
 	.repr_open	= nfp_flower_repr_netdev_open,
 	.repr_stop	= nfp_flower_repr_netdev_stop,
 
-	.start		= nfp_flower_start,
-	.stop		= nfp_flower_stop,
-
 	.ctrl_msg_rx	= nfp_flower_cmsg_rx,
 
 	.sriov_enable	= nfp_flower_sriov_enable,
-- 
2.14.1
