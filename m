From: valentina.giusti@bmw-carit.de
Subject: [PATCH v2 1/2] netfilter_queue: enable UID/GID socket info retrieval
Date: Thu, 19 Dec 2013 12:03:26 +0100
Message-ID: <1387451007-14363-2-git-send-email-valentina.giusti@bmw-carit.de>
References: <1387451007-14363-1-git-send-email-valentina.giusti@bmw-carit.de>
Cc: netdev@vger.kernel.org, fw@strlen.de, eric.dumazet@gmail.com,
	tgraf@redhat.com, jpa@google.com, pablo@netfilter.org,
	davem@davemloft.net, daniel.wagner@bmw-carit.de,
	Valentina Giusti <valentina.giusti@oss.bmw-carit.de>
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.bmw-carit.de ([62.245.222.98]:51256 "EHLO
	linuxmail.bmw-carit.de" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751926Ab3LSLD3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Dec 2013 06:03:29 -0500
In-Reply-To: <1387451007-14363-1-git-send-email-valentina.giusti@bmw-carit.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Valentina Giusti <valentina.giusti@oss.bmw-carit.de>

Thanks to commits 41063e9 (ipv4: Early TCP socket demux) and 421b388 (udp: ipv4:
Add udp early demux) it is now possible to parse UID and GID socket info
also for incoming TCP and UDP connections. Having this info available, it
is convenient to let NFQUEUE parse it in order to improve and refine the
traffic analysis in userspace.

Signed-off-by: Valentina Giusti <valentina.giusti@bmw-carit.de>
---
 include/uapi/linux/netfilter/nfnetlink_queue.h |  5 ++++-
 net/netfilter/nfnetlink_queue_core.c           | 31 ++++++++++++++++++++++++++
 2 files changed, 35 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/netfilter/nfnetlink_queue.h b/include/uapi/linux/netfilter/nfnetlink_queue.h
index 0132bad..8dd819e 100644
--- a/include/uapi/linux/netfilter/nfnetlink_queue.h
+++ b/include/uapi/linux/netfilter/nfnetlink_queue.h
@@ -47,6 +47,8 @@ enum nfqnl_attr_type {
 	NFQA_CAP_LEN,			/* __u32 length of captured packet */
 	NFQA_SKB_INFO,			/* __u32 skb meta information */
 	NFQA_EXP,			/* nf_conntrack_netlink.h */
+	NFQA_UID,			/* __u32 sk uid */
+	NFQA_GID,			/* __u32 sk gid */
 
 	__NFQA_MAX
 };
@@ -99,7 +101,8 @@ enum nfqnl_attr_config {
 #define NFQA_CFG_F_FAIL_OPEN			(1 << 0)
 #define NFQA_CFG_F_CONNTRACK			(1 << 1)
 #define NFQA_CFG_F_GSO				(1 << 2)
-#define NFQA_CFG_F_MAX				(1 << 3)
+#define NFQA_CFG_F_UID_GID			(1 << 3)
+#define NFQA_CFG_F_MAX				(1 << 4)
 
 /* flags for NFQA_SKB_INFO */
 /* packet appears to have wrong checksums, but they are ok */
diff --git a/net/netfilter/nfnetlink_queue_core.c b/net/netfilter/nfnetlink_queue_core.c
index 21258cf..2cdef07 100644
--- a/net/netfilter/nfnetlink_queue_core.c
+++ b/net/netfilter/nfnetlink_queue_core.c
@@ -297,6 +297,29 @@ nfqnl_put_packet_info(struct sk_buff *nlskb, struct sk_buff *packet,
 	return flags ? nla_put_be32(nlskb, NFQA_SKB_INFO, htonl(flags)) : 0;
 }
 
+static int nfqnl_put_sk_uidgid(struct sk_buff *skb, struct sock *sk)
+{
+	const struct cred *cred;
+
+	if (sk && sk->sk_state != TCP_TIME_WAIT) {
+		read_lock_bh(&sk->sk_callback_lock);
+		if (sk->sk_socket && sk->sk_socket->file) {
+			cred = sk->sk_socket->file->f_cred;
+			if (nla_put_u32(skb, NFQA_UID, htonl(cred->fsuid)))
+				goto nla_put_failure;
+			if (nla_put_u32(skb, NFQA_GID, htonl(cred->fsgid)))
+				goto nla_put_failure;
+		}
+		read_unlock_bh(&sk->sk_callback_lock);
+	}
+
+	return 0;
+
+nla_put_failure:
+	read_unlock_bh(&sk->sk_callback_lock);
+	return -1;
+}
+
 static struct sk_buff *
 nfqnl_build_packet_message(struct net *net, struct nfqnl_instance *queue,
 			   struct nf_queue_entry *entry,
@@ -372,6 +395,10 @@ nfqnl_build_packet_message(struct net *net, struct nfqnl_instance *queue,
 	if (queue->flags & NFQA_CFG_F_CONNTRACK)
 		ct = nfqnl_ct_get(entskb, &size, &ctinfo);
 
+	if (queue->flags & NFQA_CFG_F_UID_GID)
+		size +=  (nla_total_size(sizeof(u_int32_t))	/* uid */
+			+ nla_total_size(sizeof(u_int32_t)));	/* gid */
+
 	skb = nfnetlink_alloc_skb(net, size, queue->peer_portid,
 				  GFP_ATOMIC);
 	if (!skb)
@@ -484,6 +511,10 @@ nfqnl_build_packet_message(struct net *net, struct nfqnl_instance *queue,
 			goto nla_put_failure;
 	}
 
+	if ((queue->flags & NFQA_CFG_F_UID_GID) && entskb->sk)
+		if (nfqnl_put_sk_uidgid(skb, entskb->sk))
+			goto nla_put_failure;
+
 	if (ct && nfqnl_ct_put(skb, ct, ctinfo) < 0)
 		goto nla_put_failure;
 
-- 
1.8.5.1
