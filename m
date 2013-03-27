From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH net-next 2/3] net: core: introduce skb_probe_transport_header()
Date: Wed, 27 Mar 2013 17:11:21 +0800
Message-ID: <1364375482-7439-2-git-send-email-jasowang@redhat.com>
References: <1364375482-7439-1-git-send-email-jasowang@redhat.com>
Cc: mst@redhat.com, Jason Wang <jasowang@redhat.com>,
	Eric Dumazet <edumazet@google.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37976 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751094Ab3C0JUw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Mar 2013 05:20:52 -0400
In-Reply-To: <1364375482-7439-1-git-send-email-jasowang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sometimes, we need probe and set the transport header for packets (e.g from
untrusted source). This patch introduces a new helper
skb_probe_transport_header() which tries to probe and set the l4 header through
skb_flow_dissect(), if not just set the transport header to the hint passed by
caller.

Cc: Eric Dumazet <edumazet@google.com>
Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 include/linux/skbuff.h |   14 ++++++++++++++
 1 files changed, 14 insertions(+), 0 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 4974121..fa88b96 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -32,6 +32,7 @@
 #include <linux/hrtimer.h>
 #include <linux/dma-mapping.h>
 #include <linux/netdev_features.h>
+#include <net/flow_keys.h>
 
 /* Don't change this without changing skb_csum_unnecessary! */
 #define CHECKSUM_NONE 0
@@ -1559,6 +1560,19 @@ static inline void skb_set_transport_header(struct sk_buff *skb,
 	skb->transport_header += offset;
 }
 
+static inline void skb_probe_transport_header(struct sk_buff *skb,
+					      const int offset_hint)
+{
+	struct flow_keys keys;
+
+	if (skb_transport_header_was_set(skb))
+		return;
+	else if (skb_flow_dissect(skb, &keys))
+		skb_set_transport_header(skb, keys.thoff);
+	else
+		skb_set_transport_header(skb, offset_hint);
+}
+
 static inline unsigned char *skb_network_header(const struct sk_buff *skb)
 {
 	return skb->head + skb->network_header;
-- 
1.7.1
