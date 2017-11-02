From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 1/8] nfp: flower: app should use struct nfp_repr
Date: Thu,  2 Nov 2017 01:31:29 -0700
Message-ID: <20171102083136.2096-2-jakub.kicinski@netronome.com>
References: <20171102083136.2096-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com, John Hurley <john.hurley@netronome.com>,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:53247 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755390AbdKBIcX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Nov 2017 04:32:23 -0400
Received: by mail-pf0-f193.google.com with SMTP id e64so4043487pfk.9
        for <netdev@vger.kernel.org>; Thu, 02 Nov 2017 01:32:22 -0700 (PDT)
In-Reply-To: <20171102083136.2096-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Hurley <john.hurley@netronome.com>

Ensure priv netdev data in flower app is cast to nfp_repr and not nfp_net
as in other apps.

Fixes: 363fc53b8b58 ("nfp: flower: Convert ndo_setup_tc offloads to block callbacks")
Signed-off-by: John Hurley <john.hurley@netronome.com>
Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/flower/offload.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/flower/offload.c b/drivers/net/ethernet/netronome/nfp/flower/offload.c
index 7c6cab176293..95c2b9284857 100644
--- a/drivers/net/ethernet/netronome/nfp/flower/offload.c
+++ b/drivers/net/ethernet/netronome/nfp/flower/offload.c
@@ -468,14 +468,14 @@ nfp_flower_repr_offload(struct nfp_app *app, struct net_device *netdev,
 static int nfp_flower_setup_tc_block_cb(enum tc_setup_type type,
 					void *type_data, void *cb_priv)
 {
-	struct nfp_net *nn = cb_priv;
+	struct nfp_repr *repr = cb_priv;
 
-	if (!tc_can_offload(nn->dp.netdev))
+	if (!tc_can_offload(repr->netdev))
 		return -EOPNOTSUPP;
 
 	switch (type) {
 	case TC_SETUP_CLSFLOWER:
-		return nfp_flower_repr_offload(nn->app, nn->port->netdev,
+		return nfp_flower_repr_offload(repr->app, repr->netdev,
 					       type_data);
 	default:
 		return -EOPNOTSUPP;
@@ -485,7 +485,7 @@ static int nfp_flower_setup_tc_block_cb(enum tc_setup_type type,
 static int nfp_flower_setup_tc_block(struct net_device *netdev,
 				     struct tc_block_offload *f)
 {
-	struct nfp_net *nn = netdev_priv(netdev);
+	struct nfp_repr *repr = netdev_priv(netdev);
 
 	if (f->binder_type != TCF_BLOCK_BINDER_TYPE_CLSACT_INGRESS)
 		return -EOPNOTSUPP;
@@ -494,11 +494,11 @@ static int nfp_flower_setup_tc_block(struct net_device *netdev,
 	case TC_BLOCK_BIND:
 		return tcf_block_cb_register(f->block,
 					     nfp_flower_setup_tc_block_cb,
-					     nn, nn);
+					     repr, repr);
 	case TC_BLOCK_UNBIND:
 		tcf_block_cb_unregister(f->block,
 					nfp_flower_setup_tc_block_cb,
-					nn);
+					repr);
 		return 0;
 	default:
 		return -EOPNOTSUPP;
-- 
2.14.1
