From: pablo@netfilter.org
Subject: [PATCH 16/16] netfilter: nfnetlink_queue: add NFQA_CAP_LEN attribute
Date: Mon, 24 Sep 2012 21:19:28 +0200
Message-ID: <1348514369-3272-17-git-send-email-pablo@netfilter.org>
References: <1348514369-3272-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:58150 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932124Ab2IXTVL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Sep 2012 15:21:11 -0400
In-Reply-To: <1348514369-3272-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>

This patch adds the NFQA_CAP_LEN attribute that allows us to know
what is the real packet size from user-space (even if we decided
to retrieve just a few bytes from the packet instead of all of it).

Security software that inspects packets should always check for
this new attribute to make sure that it is inspecting the entire
packet.

This also helps to provide a workaround for the problem described
in: http://marc.info/?l=netfilter-devel&m=134519473212536&w=2

Original idea from Florian Westphal.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/netfilter/nfnetlink_queue.h |    1 +
 net/netfilter/nfnetlink_queue_core.c      |    9 +++++++--
 2 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/include/linux/netfilter/nfnetlink_queue.h b/include/linux/netfilter/nfnetlink_queue.h
index 3b1c136..70ec8c2 100644
--- a/include/linux/netfilter/nfnetlink_queue.h
+++ b/include/linux/netfilter/nfnetlink_queue.h
@@ -44,6 +44,7 @@ enum nfqnl_attr_type {
 	NFQA_PAYLOAD,			/* opaque data payload */
 	NFQA_CT,			/* nf_conntrack_netlink.h */
 	NFQA_CT_INFO,			/* enum ip_conntrack_info */
+	NFQA_CAP_LEN,			/* __u32 length of captured packet */
 
 	__NFQA_MAX
 };
diff --git a/net/netfilter/nfnetlink_queue_core.c b/net/netfilter/nfnetlink_queue_core.c
index 3e4ddcb7..e12d44e 100644
--- a/net/netfilter/nfnetlink_queue_core.c
+++ b/net/netfilter/nfnetlink_queue_core.c
@@ -225,7 +225,7 @@ nfqnl_build_packet_message(struct nfqnl_instance *queue,
 {
 	sk_buff_data_t old_tail;
 	size_t size;
-	size_t data_len = 0;
+	size_t data_len = 0, cap_len = 0;
 	struct sk_buff *skb;
 	struct nlattr *nla;
 	struct nfqnl_msg_packet_hdr *pmsg;
@@ -247,7 +247,8 @@ nfqnl_build_packet_message(struct nfqnl_instance *queue,
 #endif
 		+ nla_total_size(sizeof(u_int32_t))	/* mark */
 		+ nla_total_size(sizeof(struct nfqnl_msg_packet_hw))
-		+ nla_total_size(sizeof(struct nfqnl_msg_packet_timestamp));
+		+ nla_total_size(sizeof(struct nfqnl_msg_packet_timestamp)
+		+ nla_total_size(sizeof(u_int32_t)));	/* cap_len */
 
 	outdev = entry->outdev;
 
@@ -266,6 +267,7 @@ nfqnl_build_packet_message(struct nfqnl_instance *queue,
 			data_len = entskb->len;
 
 		size += nla_total_size(data_len);
+		cap_len = entskb->len;
 		break;
 	}
 
@@ -402,6 +404,9 @@ nfqnl_build_packet_message(struct nfqnl_instance *queue,
 	if (ct && nfqnl_ct_put(skb, ct, ctinfo) < 0)
 		goto nla_put_failure;
 
+	if (cap_len > 0 && nla_put_be32(skb, NFQA_CAP_LEN, htonl(cap_len)))
+		goto nla_put_failure;
+
 	nlh->nlmsg_len = skb->tail - old_tail;
 	return skb;
 
-- 
1.7.10.4
