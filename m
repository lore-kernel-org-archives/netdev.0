From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 4/5] ISDN-Gigaset: Release memory in gigaset_initcs() after an
 allocation failure
Date: Mon, 26 Sep 2016 17:43:22 +0200
Message-ID: <6409b3b0-3b7a-1139-f040-7b1a61611187@users.sourceforge.net>
References: <566ABCD9.1060404@users.sourceforge.net>
 <6d4bbb77-914f-19b8-a1a9-2731d1158612@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org,
        Julia Lawall <julia.lawall@lip6.fr>
To: gigaset307x-common@lists.sourceforge.net, netdev@vger.kernel.org,
        Karsten Keil <isdn@linux-pingi.de>,
        Paul Bolle <pebolle@tiscali.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.web.de ([217.72.192.78]:50801 "EHLO mout.web.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1034022AbcIZPnn (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 26 Sep 2016 11:43:43 -0400
In-Reply-To: <6d4bbb77-914f-19b8-a1a9-2731d1158612@users.sourceforge.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Mon, 26 Sep 2016 16:30:50 +0200

Memory was not released (as it would be expected) when one call
of further resource reservations failed.

* Split a condition check for memory allocation failures so that
  each pointer from these function calls will be checked immediately.

  See also background information:
  Topic "CWE-754: Improper check for unusual or exceptional conditions"
  Link: https://cwe.mitre.org/data/definitions/754.html

* Adjust jump targets according to the Linux coding style convention.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/isdn/gigaset/common.c | 20 ++++++++++++--------
 1 file changed, 12 insertions(+), 8 deletions(-)

diff --git a/drivers/isdn/gigaset/common.c b/drivers/isdn/gigaset/common.c
index c05a2a4..2e9382f 100644
--- a/drivers/isdn/gigaset/common.c
+++ b/drivers/isdn/gigaset/common.c
@@ -710,10 +710,13 @@ struct cardstate *gigaset_initcs(struct gigaset_driver *drv, int channels,
 	cs->mode = M_UNKNOWN;
 	cs->mstate = MS_UNINITIALIZED;
 	cs->bcs = kmalloc_array(channels, sizeof(*cs->bcs), GFP_KERNEL);
+	if (!cs->bcs)
+		goto report_failure;
+
 	cs->inbuf = kmalloc(sizeof(*cs->inbuf), GFP_KERNEL);
-	if (!cs->bcs || !cs->inbuf) {
-		goto error;
-	}
+	if (!cs->inbuf)
+		goto free_bcs;
+
 	++cs->cs_init;
 
 	gig_dbg(DEBUG_INIT, "setting up at_state");
@@ -737,14 +740,14 @@ struct cardstate *gigaset_initcs(struct gigaset_driver *drv, int channels,
 	gig_dbg(DEBUG_INIT, "setting up iif");
 	if (gigaset_isdn_regdev(cs, modulename) < 0) {
 		pr_err("error registering ISDN device\n");
-		goto error;
+		goto free_bcs;
 	}
 
 	make_valid(cs, VALID_ID);
 	++cs->cs_init;
 	gig_dbg(DEBUG_INIT, "setting up hw");
 	if (cs->ops->initcshw(cs) < 0)
-		goto error;
+		goto free_bcs;
 
 	++cs->cs_init;
 
@@ -759,7 +762,7 @@ struct cardstate *gigaset_initcs(struct gigaset_driver *drv, int channels,
 		gig_dbg(DEBUG_INIT, "setting up bcs[%d]", i);
 		if (gigaset_initbcs(cs->bcs + i, cs, i) < 0) {
 			pr_err("could not allocate channel %d data\n", i);
-			goto error;
+			goto free_bcs;
 		}
 	}
 
@@ -772,8 +775,9 @@ struct cardstate *gigaset_initcs(struct gigaset_driver *drv, int channels,
 
 	gig_dbg(DEBUG_INIT, "cs initialized");
 	return cs;
-
-error:
+free_bcs:
+	kfree(cs->bcs);
+report_failure:
 	gig_dbg(DEBUG_INIT, "failed");
 	gigaset_freecs(cs);
 	return NULL;
-- 
2.10.0
