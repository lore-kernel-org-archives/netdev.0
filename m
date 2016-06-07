From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCHv3 net 2/3] net: cls_u32: be more strict about skip-sw flag
Date: Tue,  7 Jun 2016 23:17:02 +0100
Message-ID: <1465337823-16096-3-git-send-email-jakub.kicinski@netronome.com>
References: <1465226208-32097-1-git-send-email-jakub.kicinski@netronome.com>
 <1465337823-16096-1-git-send-email-jakub.kicinski@netronome.com>
Cc: john.r.fastabend@intel.com, sridhar.samudrala@intel.com,
	Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f46.google.com ([74.125.82.46]:38351 "EHLO
	mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756300AbcFGWRP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jun 2016 18:17:15 -0400
Received: by mail-wm0-f46.google.com with SMTP id m124so132762106wme.1
        for <netdev@vger.kernel.org>; Tue, 07 Jun 2016 15:17:15 -0700 (PDT)
In-Reply-To: <1465337823-16096-1-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Return an error if user requested skip-sw and the underlaying
hardware cannot handle tc offloads (or offloads are disabled).

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Dinan Gunawardena <dgunawardena@netronome.com>
Reviewed-by: Simon Horman <simon.horman@netronome.com>
---
v2:
  - handle both knode and hnodes
---
 net/sched/cls_u32.c | 58 +++++++++++++++++++++++++++--------------------------
 1 file changed, 30 insertions(+), 28 deletions(-)

diff --git a/net/sched/cls_u32.c b/net/sched/cls_u32.c
index b17e090f2fe1..0fc1d47885f8 100644
--- a/net/sched/cls_u32.c
+++ b/net/sched/cls_u32.c
@@ -457,20 +457,21 @@ static int u32_replace_hw_hnode(struct tcf_proto *tp,
 	struct tc_to_netdev offload;
 	int err;
 
+	if (!tc_should_offload(dev, flags))
+		return tc_skip_sw(flags) ? -EINVAL : 0;
+
 	offload.type = TC_SETUP_CLSU32;
 	offload.cls_u32 = &u32_offload;
 
-	if (tc_should_offload(dev, flags)) {
-		offload.cls_u32->command = TC_CLSU32_NEW_HNODE;
-		offload.cls_u32->hnode.divisor = h->divisor;
-		offload.cls_u32->hnode.handle = h->handle;
-		offload.cls_u32->hnode.prio = h->prio;
+	offload.cls_u32->command = TC_CLSU32_NEW_HNODE;
+	offload.cls_u32->hnode.divisor = h->divisor;
+	offload.cls_u32->hnode.handle = h->handle;
+	offload.cls_u32->hnode.prio = h->prio;
 
-		err = dev->netdev_ops->ndo_setup_tc(dev, tp->q->handle,
-						    tp->protocol, &offload);
-		if (tc_skip_sw(flags))
-			return err;
-	}
+	err = dev->netdev_ops->ndo_setup_tc(dev, tp->q->handle,
+					    tp->protocol, &offload);
+	if (tc_skip_sw(flags))
+		return err;
 
 	return 0;
 }
@@ -507,27 +508,28 @@ static int u32_replace_hw_knode(struct tcf_proto *tp,
 	offload.type = TC_SETUP_CLSU32;
 	offload.cls_u32 = &u32_offload;
 
-	if (tc_should_offload(dev, flags)) {
-		offload.cls_u32->command = TC_CLSU32_REPLACE_KNODE;
-		offload.cls_u32->knode.handle = n->handle;
-		offload.cls_u32->knode.fshift = n->fshift;
+	if (!tc_should_offload(dev, flags))
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
