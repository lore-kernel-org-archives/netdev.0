From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 02/12] nfp: provide ethtool_drvinfo on representors
Date: Fri, 18 Aug 2017 15:48:12 -0700
Message-ID: <20170818224822.8409-3-jakub.kicinski@netronome.com>
References: <20170818224822.8409-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f48.google.com ([74.125.83.48]:34119 "EHLO
        mail-pg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751054AbdHRWtZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2017 18:49:25 -0400
Received: by mail-pg0-f48.google.com with SMTP id n4so8837441pgn.1
        for <netdev@vger.kernel.org>; Fri, 18 Aug 2017 15:49:25 -0700 (PDT)
In-Reply-To: <20170818224822.8409-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Extend representors' ethtool ops to show basic info like firmware
version, driver version, and driver name.

While at it don't set drvinfo.n_stats and drvinfo.regdump_len,
core will invoke appropriate handlers to get those.

A helper is added to turn a netdev into nfp_app for convenience.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Simon Horman <simon.horman@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_app.c       | 20 ++++++++++
 drivers/net/ethernet/netronome/nfp/nfp_app.h       |  2 +
 .../net/ethernet/netronome/nfp/nfp_net_ethtool.c   | 44 ++++++++++++++++------
 3 files changed, 54 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_app.c b/drivers/net/ethernet/netronome/nfp/nfp_app.c
index c704c022574f..505e63f47419 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_app.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_app.c
@@ -38,6 +38,7 @@
 #include "nfpcore/nfp_nffw.h"
 #include "nfp_app.h"
 #include "nfp_main.h"
+#include "nfp_net.h"
 #include "nfp_net_repr.h"
 
 static const struct nfp_app_type *apps[] = {
@@ -48,6 +49,25 @@ static const struct nfp_app_type *apps[] = {
 #endif
 };
 
+struct nfp_app *nfp_app_from_netdev(struct net_device *netdev)
+{
+	if (nfp_netdev_is_nfp_net(netdev)) {
+		struct nfp_net *nn = netdev_priv(netdev);
+
+		return nn->app;
+	}
+
+	if (nfp_netdev_is_nfp_repr(netdev)) {
+		struct nfp_repr *repr = netdev_priv(netdev);
+
+		return repr->app;
+	}
+
+	WARN(1, "Unknown netdev type for nfp_app\n");
+
+	return NULL;
+}
+
 const char *nfp_app_mip_name(struct nfp_app *app)
 {
 	if (!app || !app->pf->mip)
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_app.h b/drivers/net/ethernet/netronome/nfp/nfp_app.h
index f34e8778fae2..c13b9bbe7e62 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_app.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_app.h
@@ -293,6 +293,8 @@ static inline struct net_device *nfp_app_repr_get(struct nfp_app *app, u32 id)
 	return app->type->repr_get(app, id);
 }
 
+struct nfp_app *nfp_app_from_netdev(struct net_device *netdev);
+
 struct nfp_reprs *
 nfp_app_reprs_set(struct nfp_app *app, enum nfp_repr_type type,
 		  struct nfp_reprs *reprs);
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c b/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c
index 3edc5d62ad5b..3c34c8b27dcf 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c
@@ -147,34 +147,53 @@ static void nfp_net_get_nspinfo(struct nfp_app *app, char *version)
 	if (IS_ERR(nsp))
 		return;
 
-	snprintf(version, ETHTOOL_FWVERS_LEN, "sp:%hu.%hu",
+	snprintf(version, ETHTOOL_FWVERS_LEN, "%hu.%hu",
 		 nfp_nsp_get_abi_ver_major(nsp),
 		 nfp_nsp_get_abi_ver_minor(nsp));
 
 	nfp_nsp_close(nsp);
 }
 
-static void nfp_net_get_drvinfo(struct net_device *netdev,
-				struct ethtool_drvinfo *drvinfo)
+static void
+nfp_get_drvinfo(struct nfp_app *app, struct pci_dev *pdev,
+		const char *vnic_version, struct ethtool_drvinfo *drvinfo)
 {
 	char nsp_version[ETHTOOL_FWVERS_LEN] = {};
-	struct nfp_net *nn = netdev_priv(netdev);
 
-	strlcpy(drvinfo->driver, nn->pdev->driver->name,
-		sizeof(drvinfo->driver));
+	strlcpy(drvinfo->driver, pdev->driver->name, sizeof(drvinfo->driver));
 	strlcpy(drvinfo->version, nfp_driver_version, sizeof(drvinfo->version));
 
-	nfp_net_get_nspinfo(nn->app, nsp_version);
+	nfp_net_get_nspinfo(app, nsp_version);
 	snprintf(drvinfo->fw_version, sizeof(drvinfo->fw_version),
-		 "%d.%d.%d.%d %s %s %s",
+		 "%s %s %s %s", vnic_version, nsp_version,
+		 nfp_app_mip_name(app), nfp_app_name(app));
+}
+
+static void
+nfp_net_get_drvinfo(struct net_device *netdev, struct ethtool_drvinfo *drvinfo)
+{
+	char vnic_version[ETHTOOL_FWVERS_LEN] = {};
+	struct nfp_net *nn = netdev_priv(netdev);
+
+	snprintf(vnic_version, sizeof(vnic_version), "%d.%d.%d.%d",
 		 nn->fw_ver.resv, nn->fw_ver.class,
-		 nn->fw_ver.major, nn->fw_ver.minor, nsp_version,
-		 nfp_app_mip_name(nn->app), nfp_app_name(nn->app));
+		 nn->fw_ver.major, nn->fw_ver.minor);
 	strlcpy(drvinfo->bus_info, pci_name(nn->pdev),
 		sizeof(drvinfo->bus_info));
 
-	drvinfo->n_stats = NN_ET_STATS_LEN;
-	drvinfo->regdump_len = NFP_NET_CFG_BAR_SZ;
+	nfp_get_drvinfo(nn->app, nn->pdev, vnic_version, drvinfo);
+}
+
+static void
+nfp_app_get_drvinfo(struct net_device *netdev, struct ethtool_drvinfo *drvinfo)
+{
+	struct nfp_app *app;
+
+	app = nfp_app_from_netdev(netdev);
+	if (!app)
+		return;
+
+	nfp_get_drvinfo(app, app->pdev, "*", drvinfo);
 }
 
 /**
@@ -940,6 +959,7 @@ static const struct ethtool_ops nfp_net_ethtool_ops = {
 };
 
 const struct ethtool_ops nfp_port_ethtool_ops = {
+	.get_drvinfo		= nfp_app_get_drvinfo,
 	.get_link		= ethtool_op_get_link,
 };
 
-- 
2.11.0
