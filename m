From: Dan Carpenter <error27@gmail.com>
Subject: [patch] caif: checking the wrong variable
Date: Sat, 15 Jan 2011 16:06:39 +0300
Message-ID: <20110115130639.GA2721@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Sjur Braendeland <sjur.brandeland@stericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:39644 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752968Ab1AONGx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Jan 2011 08:06:53 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the original code we check if (servl == NULL) twice.  The first time
should print the message that cfmuxl_remove_uplayer() failed and set
"ret" correctly, but instead it just returns success.  The second check
should be checking the value of "ret" instead of "servl".

Signed-off-by: Dan Carpenter <error27@gmail.com>

diff --git a/net/caif/cfcnfg.c b/net/caif/cfcnfg.c
index 21ede14..c665de7 100644
--- a/net/caif/cfcnfg.c
+++ b/net/caif/cfcnfg.c
@@ -191,6 +191,7 @@ int cfcnfg_disconn_adapt_layer(struct cfcnfg *cnfg, struct cflayer *adap_layer)
 	struct cflayer *servl = NULL;
 	struct cfcnfg_phyinfo *phyinfo = NULL;
 	u8 phyid = 0;
+
 	caif_assert(adap_layer != NULL);
 	channel_id = adap_layer->id;
 	if (adap_layer->dn == NULL || channel_id == 0) {
@@ -199,16 +200,16 @@ int cfcnfg_disconn_adapt_layer(struct cfcnfg *cnfg, struct cflayer *adap_layer)
 		goto end;
 	}
 	servl = cfmuxl_remove_uplayer(cnfg->mux, channel_id);
-	if (servl == NULL)
-		goto end;
-	layer_set_up(servl, NULL);
-	ret = cfctrl_linkdown_req(cnfg->ctrl, channel_id, adap_layer);
 	if (servl == NULL) {
 		pr_err("PROTOCOL ERROR - Error removing service_layer Channel_Id(%d)",
 		       channel_id);
 		ret = -EINVAL;
 		goto end;
 	}
+	layer_set_up(servl, NULL);
+	ret = cfctrl_linkdown_req(cnfg->ctrl, channel_id, adap_layer);
+	if (ret)
+		goto end;
 	caif_assert(channel_id == servl->id);
 	if (adap_layer->dn != NULL) {
 		phyid = cfsrvl_getphyid(adap_layer->dn);
