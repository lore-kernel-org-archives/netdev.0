From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: [PATCH net] net: avoid skb_warn_bad_offload false positives on UFO
Date: Tue,  8 Aug 2017 14:22:55 -0400
Message-ID: <20170808182255.88431-1-willemdebruijn.kernel@gmail.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
        xiangxia.m.yue@gmail.com, Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f194.google.com ([209.85.220.194]:37078 "EHLO
        mail-qk0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752137AbdHHSW7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 8 Aug 2017 14:22:59 -0400
Received: by mail-qk0-f194.google.com with SMTP id x77so3751440qka.4
        for <netdev@vger.kernel.org>; Tue, 08 Aug 2017 11:22:59 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

skb_warn_bad_offload triggers a warning when an skb enters the GSO
stack at __skb_gso_segment that does not have CHECKSUM_PARTIAL
checksum offload set.

Commit b2504a5dbef3 ("net: reduce skb_warn_bad_offload() noise")
observed that SKB_GSO_DODGY producers can trigger the check and
that passing those packets through the GSO handlers will fix it
up. But, the software UFO handler will set ip_summed to
CHECKSUM_NONE.

When __skb_gso_segment is called from the receive path, this
triggers the warning again.

Make UFO set CHECKSUM_UNNECESSARY instead of CHECKSUM_NONE. On
Tx these two are equivalent. On Rx, this better matches the
skb state (checksum computed), as CHECKSUM_NONE here means no
checksum computed.

See also this thread for context:
http://patchwork.ozlabs.org/patch/799015/

Fixes: b2504a5dbef3 ("net: reduce skb_warn_bad_offload() noise")
Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 net/core/dev.c         | 2 +-
 net/ipv4/udp_offload.c | 2 +-
 net/ipv6/udp_offload.c | 2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 8515f8fe0460..ce15a06d5558 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2739,7 +2739,7 @@ static inline bool skb_needs_check(struct sk_buff *skb, bool tx_path)
 {
 	if (tx_path)
 		return skb->ip_summed != CHECKSUM_PARTIAL &&
-		       skb->ip_summed != CHECKSUM_NONE;
+		       skb->ip_summed != CHECKSUM_UNNECESSARY;
 
 	return skb->ip_summed == CHECKSUM_NONE;
 }
diff --git a/net/ipv4/udp_offload.c b/net/ipv4/udp_offload.c
index 781250151d40..0932c85b42af 100644
--- a/net/ipv4/udp_offload.c
+++ b/net/ipv4/udp_offload.c
@@ -235,7 +235,7 @@ static struct sk_buff *udp4_ufo_fragment(struct sk_buff *skb,
 	if (uh->check == 0)
 		uh->check = CSUM_MANGLED_0;
 
-	skb->ip_summed = CHECKSUM_NONE;
+	skb->ip_summed = CHECKSUM_UNNECESSARY;
 
 	/* If there is no outer header we can fake a checksum offload
 	 * due to the fact that we have already done the checksum in
diff --git a/net/ipv6/udp_offload.c b/net/ipv6/udp_offload.c
index a2267f80febb..e7d378c032cb 100644
--- a/net/ipv6/udp_offload.c
+++ b/net/ipv6/udp_offload.c
@@ -72,7 +72,7 @@ static struct sk_buff *udp6_ufo_fragment(struct sk_buff *skb,
 		if (uh->check == 0)
 			uh->check = CSUM_MANGLED_0;
 
-		skb->ip_summed = CHECKSUM_NONE;
+		skb->ip_summed = CHECKSUM_UNNECESSARY;
 
 		/* If there is no outer header we can fake a checksum offload
 		 * due to the fact that we have already done the checksum in
-- 
2.14.0.rc1.383.gd1ce394fe2-goog
