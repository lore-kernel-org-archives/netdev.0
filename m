From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 5/5] nfp: report application FW build name in ethtool -i
Date: Thu,  8 Jun 2017 20:56:14 -0700
Message-ID: <20170609035614.12691-6-jakub.kicinski@netronome.com>
References: <20170609035614.12691-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f43.google.com ([74.125.83.43]:34583 "EHLO
        mail-pg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751571AbdFID6N (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2017 23:58:13 -0400
Received: by mail-pg0-f43.google.com with SMTP id v18so22359860pgb.1
        for <netdev@vger.kernel.org>; Thu, 08 Jun 2017 20:58:08 -0700 (PDT)
In-Reply-To: <20170609035614.12691-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make sure application FW build name is NULL-terminated and
print it as a part of ethtool's firmware version string.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_app.c          | 8 ++++++++
 drivers/net/ethernet/netronome/nfp/nfp_app.h          | 1 +
 drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c  | 4 ++--
 drivers/net/ethernet/netronome/nfp/nfpcore/nfp_mip.c  | 7 +++++++
 drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nffw.h | 1 +
 5 files changed, 19 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_app.c b/drivers/net/ethernet/netronome/nfp/nfp_app.c
index de07517da1bd..396b93f54823 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_app.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_app.c
@@ -35,6 +35,7 @@
 #include <linux/slab.h>
 
 #include "nfpcore/nfp_cpp.h"
+#include "nfpcore/nfp_nffw.h"
 #include "nfp_app.h"
 #include "nfp_main.h"
 
@@ -43,6 +44,13 @@ static const struct nfp_app_type *apps[] = {
 	&app_bpf,
 };
 
+const char *nfp_app_mip_name(struct nfp_app *app)
+{
+	if (!app || !app->pf->mip)
+		return "";
+	return nfp_mip_name(app->pf->mip);
+}
+
 struct sk_buff *nfp_app_ctrl_msg_alloc(struct nfp_app *app, unsigned int size)
 {
 	struct sk_buff *skb;
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_app.h b/drivers/net/ethernet/netronome/nfp/nfp_app.h
index 3fbf68f8577c..f5e373fa8c3b 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_app.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_app.h
@@ -216,6 +216,7 @@ static inline void nfp_app_ctrl_rx(struct nfp_app *app, struct sk_buff *skb)
 	app->type->ctrl_msg_rx(app, skb);
 }
 
+const char *nfp_app_mip_name(struct nfp_app *app);
 struct sk_buff *nfp_app_ctrl_msg_alloc(struct nfp_app *app, unsigned int size);
 
 struct nfp_app *nfp_app_alloc(struct nfp_pf *pf, enum nfp_app_id id);
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c b/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c
index 83664ca25213..6e31355c3567 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c
@@ -166,10 +166,10 @@ static void nfp_net_get_drvinfo(struct net_device *netdev,
 
 	nfp_net_get_nspinfo(nn->app, nsp_version);
 	snprintf(drvinfo->fw_version, sizeof(drvinfo->fw_version),
-		 "%d.%d.%d.%d %s %s",
+		 "%d.%d.%d.%d %s %s %s",
 		 nn->fw_ver.resv, nn->fw_ver.class,
 		 nn->fw_ver.major, nn->fw_ver.minor, nsp_version,
-		 nfp_app_name(nn->app));
+		 nfp_app_mip_name(nn->app), nfp_app_name(nn->app));
 	strlcpy(drvinfo->bus_info, pci_name(nn->pdev),
 		sizeof(drvinfo->bus_info));
 
diff --git a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_mip.c b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_mip.c
index 3d15dd03647e..5f193fe2d69e 100644
--- a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_mip.c
+++ b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_mip.c
@@ -141,6 +141,8 @@ const struct nfp_mip *nfp_mip_open(struct nfp_cpp *cpp)
 		return NULL;
 	}
 
+	mip->name[sizeof(mip->name) - 1] = 0;
+
 	return mip;
 }
 
@@ -149,6 +151,11 @@ void nfp_mip_close(const struct nfp_mip *mip)
 	kfree(mip);
 }
 
+const char *nfp_mip_name(const struct nfp_mip *mip)
+{
+	return mip->name;
+}
+
 /**
  * nfp_mip_symtab() - Get the address and size of the MIP symbol table
  * @mip:	MIP handle
diff --git a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nffw.h b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nffw.h
index c7266baec0eb..d27d29782a12 100644
--- a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nffw.h
+++ b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nffw.h
@@ -55,6 +55,7 @@ struct nfp_mip;
 const struct nfp_mip *nfp_mip_open(struct nfp_cpp *cpp);
 void nfp_mip_close(const struct nfp_mip *mip);
 
+const char *nfp_mip_name(const struct nfp_mip *mip);
 void nfp_mip_symtab(const struct nfp_mip *mip, u32 *addr, u32 *size);
 void nfp_mip_strtab(const struct nfp_mip *mip, u32 *addr, u32 *size);
 
-- 
2.11.0
