From: Lin Ming <minggr@gmail.com>
Subject: [PATCH] bridge: don't flood multicast packets if no snooping entry
Date: Fri, 12 Oct 2012 09:17:23 +0800
Message-ID: <1350004643-3786-1-git-send-email-minggr@gmail.com>
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:48052 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752197Ab2JLBSj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Oct 2012 21:18:39 -0400
Received: by mail-pa0-f46.google.com with SMTP id hz1so2321126pad.19
        for <netdev@vger.kernel.org>; Thu, 11 Oct 2012 18:18:39 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lin Ming <mlin@ss.pku.edu.cn>

Currently, multicast packets will be flood even if there is no
mutlicast snooping entry attached to port.

With IGMP snooping enabled, we should stop sending multicast packets
if there is no member joined.

Signed-off-by: Lin Ming <mlin@ss.pku.edu.cn>
---
 net/bridge/br_input.c   |    2 ++
 net/bridge/br_private.h |    2 ++
 2 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
index 76f15fd..2821085 100644
--- a/net/bridge/br_input.c
+++ b/net/bridge/br_input.c
@@ -90,6 +90,8 @@ int br_handle_frame_finish(struct sk_buff *skb)
 			skb = NULL;
 			if (!skb2)
 				goto out;
+		} else if (!mdst && BR_INPUT_SKB_CB_NOT_IGMP(skb)) {
+			skb = NULL;
 		} else
 			skb2 = skb;
 
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 9b278c4..e2c894d 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -268,8 +268,10 @@ struct br_input_skb_cb {
 
 #ifdef CONFIG_BRIDGE_IGMP_SNOOPING
 # define BR_INPUT_SKB_CB_MROUTERS_ONLY(__skb)	(BR_INPUT_SKB_CB(__skb)->mrouters_only)
+# define BR_INPUT_SKB_CB_NOT_IGMP(__skb)	(!BR_INPUT_SKB_CB(__skb)->igmp)
 #else
 # define BR_INPUT_SKB_CB_MROUTERS_ONLY(__skb)	(0)
+# define BR_INPUT_SKB_CB_NOT_IGMP(__skb)	(0)
 #endif
 
 #define br_printk(level, br, format, args...)	\
-- 
1.7.2.5
