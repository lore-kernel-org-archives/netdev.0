From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net 2/2] net: cls_u32: be more strict about skip-sw flag for knodes
Date: Wed,  8 Jun 2016 20:11:04 +0100
Message-ID: <1465413064-32196-3-git-send-email-jakub.kicinski@netronome.com>
References: <1465413064-32196-1-git-send-email-jakub.kicinski@netronome.com>
Cc: john.r.fastabend@intel.com, sridhar.samudrala@intel.com,
	Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f42.google.com ([74.125.82.42]:38528 "EHLO
	mail-wm0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932727AbcFHTL4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jun 2016 15:11:56 -0400
Received: by mail-wm0-f42.google.com with SMTP id m124so30247832wme.1
        for <netdev@vger.kernel.org>; Wed, 08 Jun 2016 12:11:55 -0700 (PDT)
In-Reply-To: <1465413064-32196-1-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Return an error if user requested skip-sw and the underlaying
hardware cannot handle tc offloads (or offloads are disabled).
This patch fixes the knode handling.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 net/sched/cls_u32.c | 37 +++++++++++++++++++------------------
 1 file changed, 19 insertions(+), 18 deletions(-)

diff --git a/net/sched/cls_u32.c b/net/sched/cls_u32.c
index 54ab32a8ff4c..ffe593efe930 100644
--- a/net/sched/cls_u32.c
+++ b/net/sched/cls_u32.c
@@ -508,27 +508,28 @@ static int u32_replace_hw_knode(struct tcf_proto *tp,
 	offload.type = TC_SETUP_CLSU32;
 	offload.cls_u32 = &u32_offload;
 
-	if (tc_should_offload(dev, tp, flags)) {
-		offload.cls_u32->command = TC_CLSU32_REPLACE_KNODE;
-		offload.cls_u32->knode.handle = n->handle;
-		offload.cls_u32->knode.fshift = n->fshift;
+	if (!tc_should_offload(dev, tp, flags))
+		return tc_skip_sw(flags) ? -EINVAL : 0;
+
+	offload.cls_u32->command = TC_CLSU32_REPLACE_KNODE;
+	offload.cls_u32->knode.handle = n->handle;
+	offload.cls_u32->knode.fshift = n->fshift;
 #ifdef CONFIG_CLS_U32_MARK
-		offload.cls_u32->knode.val = n->val;
-		offload.cls_u32->knode.mask = n->mask;
+	offload.cls_u32->knode.val = n->val;
+	offload.cls_u32->knode.mask = n->mask;
 #else
-		offload.cls_u32->knode.val = 0;
-		offload.cls_u32->knode.mask = 0;
+	offload.cls_u32->knode.val = 0;
+	offload.cls_u32->knode.mask = 0;
 #endif
-		offload.cls_u32->knode.sel = &n->sel;
-		offload.cls_u32->knode.exts = &n->exts;
-		if (n->ht_down)
-			offload.cls_u32->knode.link_handle = n->ht_down->handle;
-
-		err = dev->netdev_ops->ndo_setup_tc(dev, tp->q->handle,
-						    tp->protocol, &offload);
-		if (tc_skip_sw(flags))
-			return err;
-	}
+	offload.cls_u32->knode.sel = &n->sel;
+	offload.cls_u32->knode.exts = &n->exts;
+	if (n->ht_down)
+		offload.cls_u32->knode.link_handle = n->ht_down->handle;
+
+	err = dev->netdev_ops->ndo_setup_tc(dev, tp->q->handle,
+					    tp->protocol, &offload);
+	if (tc_skip_sw(flags))
+		return err;
 
 	return 0;
 }
-- 
1.9.1
