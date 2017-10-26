From: Ye Yin <hustcat@gmail.com>
Subject: [PATCH] netfilter/ipvs: clear ipvs_property flag when SKB net namespace changed
Date: Thu, 26 Oct 2017 16:57:05 +0800
Message-ID: <1509008225-19614-1-git-send-email-hustcat@gmail.com>
Cc: willemb@google.com, edumazet@google.com, johannes.berg@intel.com,
        dcaratti@redhat.com, pabeni@redhat.com, f.fainelli@gmail.com,
        fw@strlen.de, soheil@google.com, dwindsor@gmail.com,
        elena.reshetova@intel.com, tom@quantonium.net, Jason@zx2c4.com,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        Ye Yin <hustcat@gmail.com>, Wei Zhou <chouryzhou@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:54733 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751009AbdJZI5W (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2017 04:57:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When run ipvs in two different network namespace at the same host, and one
ipvs transport network traffic to the other network namespace ipvs.
'ipvs_property' flag will make the second ipvs take no effect. So we should
clear 'ipvs_property' when SKB network namespace changed.

Signed-off-by: Ye Yin <hustcat@gmail.com>
Signed-off-by: Wei Zhou <chouryzhou@gmail.com>
---
 include/linux/skbuff.h | 7 +++++++
 net/core/skbuff.c      | 1 +
 2 files changed, 8 insertions(+)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 72299ef..d448a48 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -3770,6 +3770,13 @@ static inline void nf_reset_trace(struct sk_buff *skb)
 #endif
 }
 
+static inline void ipvs_reset(struct sk_buff *skb)
+{
+#if IS_ENABLED(CONFIG_IP_VS)
+	skb->ipvs_property = 0;
+#endif
+}
+
 /* Note: This doesn't put any conntrack and bridge info in dst. */
 static inline void __nf_copy(struct sk_buff *dst, const struct sk_buff *src,
 			     bool copy)
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 2465607..e140ba4 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -4864,6 +4864,7 @@ void skb_scrub_packet(struct sk_buff *skb, bool xnet)
 	if (!xnet)
 		return;
 
+	ipvs_reset(skb);
 	skb_orphan(skb);
 	skb->mark = 0;
 }
-- 
1.7.12.4
