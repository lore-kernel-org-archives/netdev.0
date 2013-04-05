From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH] netfilter: don't reset nf_trace in nf_reset()
Date: Fri,  5 Apr 2013 20:42:05 +0200
Message-ID: <1365187325-25147-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	gaofeng@cn.fujitsu.com
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:37655 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1162434Ab3DESmJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Apr 2013 14:42:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 130549fe added code to reset nf_trace in nf_reset(). This is wrong
and unnecessary.

nf_reset() is used in the following cases:

- when passing packets up the the socket layer, at which point we want to
  release all netfilter references that might keep modules pinned while
  the packet is queued. nf_trace doesn't matter anymore at this point.

- when encapsulating or decapsulating IPsec packets. We want to continue
  tracing these packets after IPsec processing.

- when passing packets through virtual network devices. Only devices on
  that encapsulate in IPv4/v6 matter since otherwise nf_trace is not
  used anymore. Its not entirely clear whether those packets should
  be traced after that, however we've always done that.

- when passing packets through virtual network devices that make the
  packet cross network namespace boundaries. This is the only cases
  where we clearly want to reset nf_trace and is also what the
  original patch intended to fix.

Add a new function nf_reset_trace() and use it in dev_forward_skb() to
fix this properly.

Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 include/linux/skbuff.h | 4 ++++
 net/core/dev.c         | 1 +
 2 files changed, 5 insertions(+)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 72b3967..b8292d8 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2641,6 +2641,10 @@ static inline void nf_reset(struct sk_buff *skb)
 	nf_bridge_put(skb->nf_bridge);
 	skb->nf_bridge = NULL;
 #endif
+}
+
+static inline void nf_reset_trace(struct sk_buff *skb)
+{
 #if IS_ENABLED(CONFIG_NETFILTER_XT_TARGET_TRACE)
 	skb->nf_trace = 0;
 #endif
diff --git a/net/core/dev.c b/net/core/dev.c
index 13e6447..e7d68ed 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1639,6 +1639,7 @@ int dev_forward_skb(struct net_device *dev, struct sk_buff *skb)
 	skb->mark = 0;
 	secpath_reset(skb);
 	nf_reset(skb);
+	nf_reset_trace(skb);
 	return netif_rx(skb);
 }
 EXPORT_SYMBOL_GPL(dev_forward_skb);
-- 
1.8.1.4
