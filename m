From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 08/25] netfilter: physdev: physdev-is-out should not work with OUTPUT chain
Date: Sat, 23 Jul 2016 13:08:22 +0200
Message-ID: <1469272119-29942-9-git-send-email-pablo@netfilter.org>
References: <1469272119-29942-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:35902 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751427AbcGWLJT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 23 Jul 2016 07:09:19 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id 9FDBDE7DAE
	for <netdev@vger.kernel.org>; Sat, 23 Jul 2016 13:09:18 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 91CB7FEFBF
	for <netdev@vger.kernel.org>; Sat, 23 Jul 2016 13:09:18 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id A1E366DB36
	for <netdev@vger.kernel.org>; Sat, 23 Jul 2016 13:09:16 +0200 (CEST)
In-Reply-To: <1469272119-29942-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hangbin Liu <liuhangbin@gmail.com>

physdev_mt() will check skb->nf_bridge first, which was alloced in
br_nf_pre_routing. So if we want to use --physdev-out and physdev-is-out,
we need to match it in FORWARD or POSTROUTING chain. physdev_mt_check()
only checked physdev-out and missed physdev-is-out. Fix it and update the
debug message to make it clearer.

Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>
Reviewed-by: Marcelo R Leitner <marcelo.leitner@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/xt_physdev.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/netfilter/xt_physdev.c b/net/netfilter/xt_physdev.c
index 1caaccb..e5f1898 100644
--- a/net/netfilter/xt_physdev.c
+++ b/net/netfilter/xt_physdev.c
@@ -102,14 +102,14 @@ static int physdev_mt_check(const struct xt_mtchk_param *par)
 	if (!(info->bitmask & XT_PHYSDEV_OP_MASK) ||
 	    info->bitmask & ~XT_PHYSDEV_OP_MASK)
 		return -EINVAL;
-	if (info->bitmask & XT_PHYSDEV_OP_OUT &&
+	if (info->bitmask & (XT_PHYSDEV_OP_OUT | XT_PHYSDEV_OP_ISOUT) &&
 	    (!(info->bitmask & XT_PHYSDEV_OP_BRIDGED) ||
 	     info->invert & XT_PHYSDEV_OP_BRIDGED) &&
 	    par->hook_mask & ((1 << NF_INET_LOCAL_OUT) |
 	    (1 << NF_INET_FORWARD) | (1 << NF_INET_POST_ROUTING))) {
-		pr_info("using --physdev-out in the OUTPUT, FORWARD and "
-			"POSTROUTING chains for non-bridged traffic is not "
-			"supported anymore.\n");
+		pr_info("using --physdev-out and --physdev-is-out are only"
+			"supported in the FORWARD and POSTROUTING chains with"
+			"bridged traffic.\n");
 		if (par->hook_mask & (1 << NF_INET_LOCAL_OUT))
 			return -EINVAL;
 	}
-- 
2.1.4
