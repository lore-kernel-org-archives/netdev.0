From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH] netfilter: CONNMARK: support save the mark of the master connection
Date: Thu, 27 Jan 2011 17:38:44 +0800
Message-ID: <1296121124-7016-1-git-send-email-xiaosuo@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:37171 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753889Ab1A0Jje (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Jan 2011 04:39:34 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In some cases(Policy routing), it is expected that all the sub-connections
share the same mark with their master.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
---
 include/linux/netfilter/xt_connmark.h |    3 ++-
 net/netfilter/xt_connmark.c           |   15 +++++++++++++++
 2 files changed, 17 insertions(+), 1 deletion(-)
diff --git a/include/linux/netfilter/xt_connmark.h b/include/linux/netfilter/xt_connmark.h
index efc17a8..4b513f8 100644
--- a/include/linux/netfilter/xt_connmark.h
+++ b/include/linux/netfilter/xt_connmark.h
@@ -15,7 +15,8 @@
 enum {
 	XT_CONNMARK_SET = 0,
 	XT_CONNMARK_SAVE,
-	XT_CONNMARK_RESTORE
+	XT_CONNMARK_RESTORE,
+	XT_CONNMARK_SAVE_MASTER,
 };
 
 struct xt_connmark_tginfo1 {
diff --git a/net/netfilter/xt_connmark.c b/net/netfilter/xt_connmark.c
index 7278145..4207bb6 100644
--- a/net/netfilter/xt_connmark.c
+++ b/net/netfilter/xt_connmark.c
@@ -69,6 +69,21 @@ connmark_tg(struct sk_buff *skb, const struct xt_action_param *par)
 		          (ct->mark & info->ctmask);
 		skb->mark = newmark;
 		break;
+	case XT_CONNMARK_SAVE_MASTER:
+		if (ct->master) {
+			struct nf_conn *master;
+
+			master = ct->master;
+			while (master->master)
+				master = master->master;
+			newmark = (ct->mark & ~info->ctmask) ^
+				  (master->mark & info->nfmask);
+			if (ct->mark != newmark) {
+				ct->mark = newmark;
+				nf_conntrack_event_cache(IPCT_MARK, ct);
+			}
+		}
+		break;
 	}
 
 	return XT_CONTINUE;
