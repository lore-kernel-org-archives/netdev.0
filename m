From: valentina.giusti@bmw-carit.de
Subject: [PATCH 1/2] netfilter_queue: enable UID/GID socket info retrieval
Date: Wed, 18 Dec 2013 19:04:03 +0100
Message-ID: <1387389844-5263-2-git-send-email-valentina.giusti@bmw-carit.de>
References: <1387389844-5263-1-git-send-email-valentina.giusti@bmw-carit.de>
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com, tgraf@redhat.com,
	jpa@google.com, pablo@netfilter.org, davem@davemloft.net,
	daniel.wagner@bmw-carit.de,
	Valentina Giusti <valentina.giusti@bmw-carit.de>
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1387389844-5263-1-git-send-email-valentina.giusti@bmw-carit.de>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Valentina Giusti <valentina.giusti@bmw-carit.de>

Thanks to commits 41063e9 (ipv4: Early TCP socket demux) and 421b388 (udp: 
ipv4: Add udp early demux) it is now possible to get UID and GID socket info
also for incoming TCP and UDP connections. Having this info available, it
is convenient to let NFQUEUE retrieve it in order to improve and refine the
traffic analysis in userspace.

Signed-off-by: Valentina Giusti <valentina.giusti@bmw-carit.de>
---
 include/uapi/linux/netfilter/nfnetlink_queue.h |    2 ++
 net/netfilter/nfnetlink_queue_core.c           |   23 ++++++++++++++++++++++-
 2 files changed, 24 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/netfilter/nfnetlink_queue.h b/include/uapi/linux/netfilter/nfnetlink_queue.h
index 0132bad..46ebbc4 100644
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
diff --git a/net/netfilter/nfnetlink_queue_core.c b/net/netfilter/nfnetlink_queue_core.c
index 21258cf..7257ddb 100644
--- a/net/netfilter/nfnetlink_queue_core.c
+++ b/net/netfilter/nfnetlink_queue_core.c
@@ -328,7 +328,9 @@ nfqnl_build_packet_message(struct net *net, struct nfqnl_instance *queue,
 		+ nla_total_size(sizeof(u_int32_t))	/* mark */
 		+ nla_total_size(sizeof(struct nfqnl_msg_packet_hw))
 		+ nla_total_size(sizeof(u_int32_t))	/* skbinfo */
-		+ nla_total_size(sizeof(u_int32_t));	/* cap_len */
+		+ nla_total_size(sizeof(u_int32_t))	/* cap_len */
+		+ nla_total_size(sizeof(u_int32_t))	/* uid */
+		+ nla_total_size(sizeof(u_int32_t));	/* gid */
 
 	if (entskb->tstamp.tv64)
 		size += nla_total_size(sizeof(struct nfqnl_msg_packet_timestamp));
@@ -484,6 +486,25 @@ nfqnl_build_packet_message(struct net *net, struct nfqnl_instance *queue,
 			goto nla_put_failure;
 	}
 
+	if (entskb->sk) {
+		struct sock *sk = entskb->sk;
+		if (sk && sk->sk_state != TCP_TIME_WAIT) {
+			read_lock_bh(&sk->sk_callback_lock);
+			if (sk->sk_socket && sk->sk_socket->file) {
+				struct file *file = sk->sk_socket->file;
+				const struct cred *cred = file->f_cred;
+				if (nla_put_u32(skb, NFQA_UID,
+				    htonl(cred->fsuid)))
+					goto nla_put_failure;
+				if (nla_put_u32(skb, NFQA_GID,
+				    htonl(cred->fsgid)))
+					goto nla_put_failure;
+				read_unlock_bh(&sk->sk_callback_lock);
+			} else
+				read_unlock_bh(&sk->sk_callback_lock);
+		}
+	}
+
 	if (ct && nfqnl_ct_put(skb, ct, ctinfo) < 0)
 		goto nla_put_failure;
 
-- 
1.7.10.4

