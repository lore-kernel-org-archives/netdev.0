From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 5/9] nfp: report app name in ethtool -i
Date: Wed, 31 May 2017 08:06:47 -0700
Message-ID: <20170531150651.16873-6-jakub.kicinski@netronome.com>
References: <20170531150651.16873-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f54.google.com ([74.125.83.54]:34491 "EHLO
        mail-pg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751108AbdEaPLv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 May 2017 11:11:51 -0400
Received: by mail-pg0-f54.google.com with SMTP id u28so9280708pgn.1
        for <netdev@vger.kernel.org>; Wed, 31 May 2017 08:11:51 -0700 (PDT)
In-Reply-To: <20170531150651.16873-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Let the app print its name in ethtool -i output.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/bpf/main.c        | 1 +
 drivers/net/ethernet/netronome/nfp/nfp_app.c         | 2 +-
 drivers/net/ethernet/netronome/nfp/nfp_app.h         | 9 +++++++++
 drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c | 5 +++--
 drivers/net/ethernet/netronome/nfp/nic/main.c        | 1 +
 5 files changed, 15 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/bpf/main.c b/drivers/net/ethernet/netronome/nfp/bpf/main.c
index 63b4769c58c2..d91d72e22dc8 100644
--- a/drivers/net/ethernet/netronome/nfp/bpf/main.c
+++ b/drivers/net/ethernet/netronome/nfp/bpf/main.c
@@ -53,6 +53,7 @@ nfp_bpf_vnic_init(struct nfp_app *app, struct nfp_net *nn, unsigned int id)
 
 const struct nfp_app_type app_bpf = {
 	.id		= NFP_APP_BPF_NIC,
+	.name		= "ebpf",
 
 	.vnic_init	= nfp_bpf_vnic_init,
 };
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_app.c b/drivers/net/ethernet/netronome/nfp/nfp_app.c
index 30687d87ae51..cea2090cf063 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_app.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_app.c
@@ -55,7 +55,7 @@ struct nfp_app *nfp_app_alloc(struct nfp_pf *pf, enum nfp_app_id id)
 		return ERR_PTR(-EINVAL);
 	}
 
-	if (WARN_ON(!apps[i]->vnic_init))
+	if (WARN_ON(!apps[i]->name || !apps[i]->vnic_init))
 		return ERR_PTR(-EINVAL);
 
 	app = kzalloc(sizeof(*app), GFP_KERNEL);
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_app.h b/drivers/net/ethernet/netronome/nfp/nfp_app.h
index 98dd5773e7cc..b5426398f29e 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_app.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_app.h
@@ -51,6 +51,7 @@ extern const struct nfp_app_type app_bpf;
 /**
  * struct nfp_app_type - application definition
  * @id:		application ID
+ * @name:	application name
  *
  * Callbacks
  * @init:	perform basic app checks
@@ -58,6 +59,7 @@ extern const struct nfp_app_type app_bpf;
  */
 struct nfp_app_type {
 	enum nfp_app_id id;
+	const char *name;
 
 	int (*init)(struct nfp_app *app);
 
@@ -93,6 +95,13 @@ static inline int nfp_app_vnic_init(struct nfp_app *app, struct nfp_net *nn,
 	return app->type->vnic_init(app, nn, id);
 }
 
+static inline const char *nfp_app_name(struct nfp_app *app)
+{
+	if (!app)
+		return "";
+	return app->type->name;
+}
+
 struct nfp_app *nfp_app_alloc(struct nfp_pf *pf, enum nfp_app_id id);
 void nfp_app_free(struct nfp_app *app);
 
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c b/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c
index 84fdbc4b835b..83664ca25213 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c
@@ -166,9 +166,10 @@ static void nfp_net_get_drvinfo(struct net_device *netdev,
 
 	nfp_net_get_nspinfo(nn->app, nsp_version);
 	snprintf(drvinfo->fw_version, sizeof(drvinfo->fw_version),
-		 "%d.%d.%d.%d %s",
+		 "%d.%d.%d.%d %s %s",
 		 nn->fw_ver.resv, nn->fw_ver.class,
-		 nn->fw_ver.major, nn->fw_ver.minor, nsp_version);
+		 nn->fw_ver.major, nn->fw_ver.minor, nsp_version,
+		 nfp_app_name(nn->app));
 	strlcpy(drvinfo->bus_info, pci_name(nn->pdev),
 		sizeof(drvinfo->bus_info));
 
diff --git a/drivers/net/ethernet/netronome/nfp/nic/main.c b/drivers/net/ethernet/netronome/nfp/nic/main.c
index 6a5b30667248..520684242b7d 100644
--- a/drivers/net/ethernet/netronome/nfp/nic/main.c
+++ b/drivers/net/ethernet/netronome/nfp/nic/main.c
@@ -51,6 +51,7 @@ static int nfp_nic_init(struct nfp_app *app)
 
 const struct nfp_app_type app_nic = {
 	.id		= NFP_APP_CORE_NIC,
+	.name		= "nic",
 
 	.init		= nfp_nic_init,
 	.vnic_init	= nfp_app_nic_vnic_init,
-- 
2.11.0
