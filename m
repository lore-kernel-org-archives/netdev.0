From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 4/8] nfp: reorganize the app table
Date: Thu,  2 Nov 2017 01:31:32 -0700
Message-ID: <20171102083136.2096-5-jakub.kicinski@netronome.com>
References: <20171102083136.2096-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:47399 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755390AbdKBIcZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Nov 2017 04:32:25 -0400
Received: by mail-pg0-f65.google.com with SMTP id r25so4436967pgn.4
        for <netdev@vger.kernel.org>; Thu, 02 Nov 2017 01:32:25 -0700 (PDT)
In-Reply-To: <20171102083136.2096-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The app table is an unordered array right now.  We have to search
apps by ID.  It also makes it harder to fall back to core NIC if
advanced functions are not compiled into the kernel (e.g. eBPF).
Make the table keyed by app id.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Simon Horman <simon.horman@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_app.c | 16 ++++++----------
 1 file changed, 6 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_app.c b/drivers/net/ethernet/netronome/nfp/nfp_app.c
index 5d9e2eba5b49..085c5151c601 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_app.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_app.c
@@ -43,10 +43,10 @@
 #include "nfp_net_repr.h"
 
 static const struct nfp_app_type *apps[] = {
-	&app_nic,
-	&app_bpf,
+	[NFP_APP_CORE_NIC]	= &app_nic,
+	[NFP_APP_BPF_NIC]	= &app_bpf,
 #ifdef CONFIG_NFP_APP_FLOWER
-	&app_flower,
+	[NFP_APP_FLOWER_NIC]	= &app_flower,
 #endif
 };
 
@@ -116,17 +116,13 @@ nfp_app_reprs_set(struct nfp_app *app, enum nfp_repr_type type,
 struct nfp_app *nfp_app_alloc(struct nfp_pf *pf, enum nfp_app_id id)
 {
 	struct nfp_app *app;
-	unsigned int i;
 
-	for (i = 0; i < ARRAY_SIZE(apps); i++)
-		if (apps[i]->id == id)
-			break;
-	if (i == ARRAY_SIZE(apps)) {
+	if (id >= ARRAY_SIZE(apps) || !apps[id]) {
 		nfp_err(pf->cpp, "failed to find app with ID 0x%02hhx\n", id);
 		return ERR_PTR(-EINVAL);
 	}
 
-	if (WARN_ON(!apps[i]->name || !apps[i]->vnic_alloc))
+	if (WARN_ON(!apps[id]->name || !apps[id]->vnic_alloc))
 		return ERR_PTR(-EINVAL);
 
 	app = kzalloc(sizeof(*app), GFP_KERNEL);
@@ -136,7 +132,7 @@ struct nfp_app *nfp_app_alloc(struct nfp_pf *pf, enum nfp_app_id id)
 	app->pf = pf;
 	app->cpp = pf->cpp;
 	app->pdev = pf->pdev;
-	app->type = apps[i];
+	app->type = apps[id];
 
 	return app;
 }
-- 
2.14.1
