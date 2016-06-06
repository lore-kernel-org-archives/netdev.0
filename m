From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net 2/2] net: cls_u32: be more strict about skip-sw flag
Date: Mon,  6 Jun 2016 16:16:48 +0100
Message-ID: <1465226208-32097-3-git-send-email-jakub.kicinski@netronome.com>
References: <1465226208-32097-1-git-send-email-jakub.kicinski@netronome.com>
Cc: john.r.fastabend@intel.com, sridhar.samudrala@intel.com,
	Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f46.google.com ([74.125.82.46]:38737 "EHLO
	mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751783AbcFFPTJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2016 11:19:09 -0400
Received: by mail-wm0-f46.google.com with SMTP id m124so76955756wme.1
        for <netdev@vger.kernel.org>; Mon, 06 Jun 2016 08:19:08 -0700 (PDT)
In-Reply-To: <1465226208-32097-1-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Return an error if user requested skip-sw and the underlaying
hardware cannot handle tc offloads (or offloads are disabled).

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 net/sched/cls_u32.c | 21 +++++++++++----------
 1 file changed, 11 insertions(+), 10 deletions(-)

diff --git a/net/sched/cls_u32.c b/net/sched/cls_u32.c
index b17e090f2fe1..fe05449537a3 100644
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
-- 
1.9.1
