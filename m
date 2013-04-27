From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 17/18] netfilter: nfnetlink_queue: avoid expensive gso segmentation and checksum fixup
Date: Sat, 27 Apr 2013 20:58:22 +0200
Message-ID: <1367089103-8394-18-git-send-email-pablo@netfilter.org>
References: <1367089103-8394-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:42599 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756144Ab3D0S65 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 27 Apr 2013 14:58:57 -0400
In-Reply-To: <1367089103-8394-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

Userspace can now indicate that it can cope with larger-than-mtu sized
packets and packets that have invalid ipv4/tcp checksums.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/uapi/linux/netfilter/nfnetlink_queue.h |    3 ++-
 net/netfilter/nfnetlink_queue_core.c           |    5 +++--
 2 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/include/uapi/linux/netfilter/nfnetlink_queue.h b/include/uapi/linux/netfilter/nfnetlink_queue.h
index 0069da3..a2308ae 100644
--- a/include/uapi/linux/netfilter/nfnetlink_queue.h
+++ b/include/uapi/linux/netfilter/nfnetlink_queue.h
@@ -97,7 +97,8 @@ enum nfqnl_attr_config {
 /* Flags for NFQA_CFG_FLAGS */
 #define NFQA_CFG_F_FAIL_OPEN			(1 << 0)
 #define NFQA_CFG_F_CONNTRACK			(1 << 1)
-#define NFQA_CFG_F_MAX				(1 << 2)
+#define NFQA_CFG_F_GSO				(1 << 2)
+#define NFQA_CFG_F_MAX				(1 << 3)
 
 /* flags for NFQA_SKB_INFO */
 /* packet appears to have wrong checksums, but they are ok */
diff --git a/net/netfilter/nfnetlink_queue_core.c b/net/netfilter/nfnetlink_queue_core.c
index d052cd6..2e0e835 100644
--- a/net/netfilter/nfnetlink_queue_core.c
+++ b/net/netfilter/nfnetlink_queue_core.c
@@ -327,7 +327,8 @@ nfqnl_build_packet_message(struct nfqnl_instance *queue,
 		break;
 
 	case NFQNL_COPY_PACKET:
-		if (entskb->ip_summed == CHECKSUM_PARTIAL &&
+		if (!(queue->flags & NFQA_CFG_F_GSO) &&
+		    entskb->ip_summed == CHECKSUM_PARTIAL &&
 		    skb_checksum_help(entskb))
 			return NULL;
 
@@ -636,7 +637,7 @@ nfqnl_enqueue_packet(struct nf_queue_entry *entry, unsigned int queuenum)
 	if (queue->copy_mode == NFQNL_COPY_NONE)
 		return -EINVAL;
 
-	if (!skb_is_gso(entry->skb))
+	if ((queue->flags & NFQA_CFG_F_GSO) || !skb_is_gso(entry->skb))
 		return __nfqnl_enqueue_packet(net, queue, entry);
 
 	skb = entry->skb;
-- 
1.7.10.4
