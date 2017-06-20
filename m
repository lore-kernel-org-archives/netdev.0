From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH net-next 12/12] nfp: add VF and PF representors to flower app
Date: Tue, 20 Jun 2017 07:51:50 +0200
Message-ID: <1497937910-32059-13-git-send-email-simon.horman@netronome.com>
References: <1497937910-32059-1-git-send-email-simon.horman@netronome.com>
Cc: netdev@vger.kernel.org, oss-drivers@netronome.com,
        Simon Horman <simon.horman@netronome.com>
To: David Miller <davem@davemloft.net>,
        Jakub Kicinski <jakub.kicinski@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f171.google.com ([209.85.216.171]:33344 "EHLO
        mail-qt0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751928AbdFTFwh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Jun 2017 01:52:37 -0400
Received: by mail-qt0-f171.google.com with SMTP id u12so126244985qth.0
        for <netdev@vger.kernel.org>; Mon, 19 Jun 2017 22:52:36 -0700 (PDT)
In-Reply-To: <1497937910-32059-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Initialise VF and PF representors in flower app.

Based in part on work by Benjamin LaHaise, Bert van Leeuwen and
Jakub Kicinski.

Signed-off-by: Simon Horman <simon.horman@netronome.com>
Reviewed-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/flower/main.c | 86 +++++++++++++++++++++++-
 1 file changed, 84 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/flower/main.c b/drivers/net/ethernet/netronome/nfp/flower/main.c
index 01864840a21b..b30f1c4ffd3a 100644
--- a/drivers/net/ethernet/netronome/nfp/flower/main.c
+++ b/drivers/net/ethernet/netronome/nfp/flower/main.c
@@ -149,15 +149,81 @@ static const struct net_device_ops nfp_flower_repr_netdev_ops = {
 	.ndo_get_offload_stats	= nfp_repr_get_offload_stats,
 };
 
+static void nfp_flower_sriov_disable(struct nfp_app *app)
+{
+	nfp_reprs_clean_and_free_by_type(app, NFP_REPR_TYPE_VF);
+}
+
+static int
+nfp_flower_spawn_vnic_reprs(struct nfp_app *app,
+			    enum nfp_flower_cmsg_port_vnic_type vnic_type,
+			    enum nfp_repr_type repr_type, unsigned int cnt)
+{
+	u8 nfp_pcie = nfp_cppcore_pcie_unit(app->pf->cpp);
+	struct nfp_flower_priv *priv = app->priv;
+	struct nfp_reprs *reprs, *old_reprs;
+	const u8 queue = 0;
+	int i, err;
+
+	reprs = nfp_reprs_alloc(cnt);
+	if (!reprs)
+		return -ENOMEM;
+
+	for (i = 0; i < cnt; i++) {
+		u32 port_id;
+
+		reprs->reprs[i] = nfp_repr_alloc(app);
+		if (!reprs->reprs[i]) {
+			err = -ENOMEM;
+			goto err_reprs_clean;
+		}
+
+		SET_NETDEV_DEV(reprs->reprs[i], &priv->nn->pdev->dev);
+		eth_hw_addr_inherit(reprs->reprs[i], priv->nn->dp.netdev);
+
+		port_id = nfp_flower_cmsg_pcie_port(nfp_pcie, vnic_type,
+						    i, queue);
+		err = nfp_repr_init(app, reprs->reprs[i],
+				    &nfp_flower_repr_netdev_ops,
+				    port_id, NULL, priv->nn->dp.netdev);
+		if (err)
+			goto err_reprs_clean;
+
+		nfp_info(app->cpp, "%s%d Representor(%s) created\n",
+			 repr_type == NFP_REPR_TYPE_PF ? "PF" : "VF", i,
+			 reprs->reprs[i]->name);
+	}
+
+	old_reprs = nfp_app_reprs_set(app, repr_type, reprs);
+	if (IS_ERR(old_reprs)) {
+		err = PTR_ERR(old_reprs);
+		goto err_reprs_clean;
+	}
+
+	return 0;
+err_reprs_clean:
+	nfp_reprs_clean_and_free(reprs);
+	return err;
+}
+
+static int nfp_flower_sriov_enable(struct nfp_app *app, int num_vfs)
+{
+	return nfp_flower_spawn_vnic_reprs(app,
+					   NFP_FLOWER_CMSG_PORT_VNIC_TYPE_VF,
+					   NFP_REPR_TYPE_VF, num_vfs);
+}
+
 static void nfp_flower_stop(struct nfp_app *app)
 {
+	nfp_reprs_clean_and_free_by_type(app, NFP_REPR_TYPE_PF);
 	nfp_reprs_clean_and_free_by_type(app, NFP_REPR_TYPE_PHYS_PORT);
+
 }
 
-static int nfp_flower_start(struct nfp_app *app)
+static int
+nfp_flower_spawn_phy_reprs(struct nfp_app *app, struct nfp_flower_priv *priv)
 {
 	struct nfp_eth_table *eth_tbl = app->pf->eth_tbl;
-	struct nfp_flower_priv *priv = app->priv;
 	struct nfp_reprs *reprs, *old_reprs;
 	unsigned int i;
 	int err;
@@ -218,6 +284,19 @@ static int nfp_flower_start(struct nfp_app *app)
 	return err;
 }
 
+static int nfp_flower_start(struct nfp_app *app)
+{
+	int err;
+
+	err = nfp_flower_spawn_phy_reprs(app, app->priv);
+	if (err)
+		return err;
+
+	return nfp_flower_spawn_vnic_reprs(app,
+					   NFP_FLOWER_CMSG_PORT_VNIC_TYPE_PF,
+					   NFP_REPR_TYPE_PF, 1);
+}
+
 static void nfp_flower_vnic_clean(struct nfp_app *app, struct nfp_net *nn)
 {
 	kfree(app->priv);
@@ -289,6 +368,9 @@ const struct nfp_app_type app_flower = {
 
 	.ctrl_msg_rx	= nfp_flower_cmsg_rx,
 
+	.sriov_enable	= nfp_flower_sriov_enable,
+	.sriov_disable	= nfp_flower_sriov_disable,
+
 	.eswitch_mode_get  = eswitch_mode_get,
 	.repr_get	= nfp_flower_repr_get,
 };
-- 
2.1.4
