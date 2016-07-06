From: Masashi Honma <masashi.honma@gmail.com>
Subject: [RFC 2/7] netfilter: Add allocation flag to nfnetlink_unicast()
Date: Wed,  6 Jul 2016 09:28:31 +0900
Message-ID: <1467764916-4983-3-git-send-email-masashi.honma@gmail.com>
References: <1467764916-4983-1-git-send-email-masashi.honma@gmail.com>
Cc: davem@davemloft.net, johannes@sipsolutions.net,
	pablo@netfilter.org, kaber@trash.net, kadlec@blackhole.kfki.hu,
	dledford@redhat.com, sean.hefty@intel.com,
	hal.rosenstock@gmail.com, paul@paul-moore.com, eparis@redhat.com,
	zbr@ioremap.net, pshelar@nicira.com, ccaulfie@redhat.com,
	teigland@redhat.com, bsingharora@gmail.com,
	Masashi Honma <masashi.honma@gmail.com>
To: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	linux-wireless@vger.kernel.org, linux-rdma@vger.kernel.org,
	linux-audit@redhat.com, cluster-devel@redhat.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1467764916-4983-1-git-send-email-masashi.honma@gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Masashi Honma <masashi.honma@gmail.com>
---
 include/linux/netfilter/nfnetlink.h | 2 +-
 net/netfilter/nfnetlink.c           | 4 ++--
 net/netfilter/nfnetlink_log.c       | 4 ++--
 net/netfilter/nfnetlink_queue.c     | 3 ++-
 4 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/include/linux/netfilter/nfnetlink.h b/include/linux/netfilter/nfnetlink.h
index 1d82dd5..a1c7808 100644
--- a/include/linux/netfilter/nfnetlink.h
+++ b/include/linux/netfilter/nfnetlink.h
@@ -38,7 +38,7 @@ int nfnetlink_send(struct sk_buff *skb, struct net *net, u32 portid,
 		   unsigned int group, int echo, gfp_t flags);
 int nfnetlink_set_err(struct net *net, u32 portid, u32 group, int error);
 int nfnetlink_unicast(struct sk_buff *skb, struct net *net, u32 portid,
-		      int flags);
+		      int flags, gfp_t allocation);
 
 void nfnl_lock(__u8 subsys_id);
 void nfnl_unlock(__u8 subsys_id);
diff --git a/net/netfilter/nfnetlink.c b/net/netfilter/nfnetlink.c
index f6193e7..b0910c7 100644
--- a/net/netfilter/nfnetlink.c
+++ b/net/netfilter/nfnetlink.c
@@ -141,9 +141,9 @@ int nfnetlink_set_err(struct net *net, u32 portid, u32 group, int error)
 EXPORT_SYMBOL_GPL(nfnetlink_set_err);
 
 int nfnetlink_unicast(struct sk_buff *skb, struct net *net, u32 portid,
-		      int flags)
+		      int flags, gfp_t allocation)
 {
-	return netlink_unicast(net->nfnl, skb, portid, flags, 0);
+	return netlink_unicast(net->nfnl, skb, portid, flags, allocation);
 }
 EXPORT_SYMBOL_GPL(nfnetlink_unicast);
 
diff --git a/net/netfilter/nfnetlink_log.c b/net/netfilter/nfnetlink_log.c
index 11f81c8..c834306 100644
--- a/net/netfilter/nfnetlink_log.c
+++ b/net/netfilter/nfnetlink_log.c
@@ -357,8 +357,8 @@ __nfulnl_send(struct nfulnl_instance *inst)
 			goto out;
 		}
 	}
-	nfnetlink_unicast(inst->skb, inst->net, inst->peer_portid,
-			  MSG_DONTWAIT);
+	nfnetlink_unicast(inst->skb, inst->net, inst->peer_portid, MSG_DONTWAIT,
+			  gfp_any());
 out:
 	inst->qlen = 0;
 	inst->skb = NULL;
diff --git a/net/netfilter/nfnetlink_queue.c b/net/netfilter/nfnetlink_queue.c
index 5d36a09..8d7b6ff 100644
--- a/net/netfilter/nfnetlink_queue.c
+++ b/net/netfilter/nfnetlink_queue.c
@@ -638,7 +638,8 @@ __nfqnl_enqueue_packet(struct net *net, struct nfqnl_instance *queue,
 	*packet_id_ptr = htonl(entry->id);
 
 	/* nfnetlink_unicast will either free the nskb or add it to a socket */
-	err = nfnetlink_unicast(nskb, net, queue->peer_portid, MSG_DONTWAIT);
+	err = nfnetlink_unicast(nskb, net, queue->peer_portid, MSG_DONTWAIT,
+				GFP_ATOMIC);
 	if (err < 0) {
 		if (queue->flags & NFQA_CFG_F_FAIL_OPEN) {
 			failopen = 1;
-- 
2.7.4

