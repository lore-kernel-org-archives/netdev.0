From: Florian Westphal <fw@strlen.de>
Subject: [PATCH net-next 5/5] nfnetlink: Revert "nfnetlink: add support for memory mapped netlink"
Date: Thu, 18 Feb 2016 15:03:28 +0100
Message-ID: <1455804208-30512-6-git-send-email-fw@strlen.de>
References: <1455804208-30512-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:50171 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1426050AbcBRODz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Feb 2016 09:03:55 -0500
In-Reply-To: <1455804208-30512-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

reverts commit 3ab1f683bf8b ("nfnetlink: add support for memory mapped
netlink")'

Like previous commits in the series, remove wrappers that are not needed
after mmapped netlink removal.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 include/linux/netlink.h         | 10 ----------
 net/netfilter/nfnetlink_queue.c |  6 ++----
 net/netlink/af_netlink.c        | 20 ++++----------------
 3 files changed, 6 insertions(+), 30 deletions(-)

diff --git a/include/linux/netlink.h b/include/linux/netlink.h
index 0b41959..da14ab6 100644
--- a/include/linux/netlink.h
+++ b/include/linux/netlink.h
@@ -69,16 +69,6 @@ extern void __netlink_clear_multicast_users(struct sock *sk, unsigned int group)
 extern void netlink_ack(struct sk_buff *in_skb, struct nlmsghdr *nlh, int err);
 extern int netlink_has_listeners(struct sock *sk, unsigned int group);
 
-extern struct sk_buff *__netlink_alloc_skb(struct sock *ssk, unsigned int size,
-					   unsigned int ldiff, u32 dst_portid,
-					   gfp_t gfp_mask);
-static inline struct sk_buff *
-netlink_alloc_skb(struct sock *ssk, unsigned int size, u32 dst_portid,
-		  gfp_t gfp_mask)
-{
-	return __netlink_alloc_skb(ssk, size, 0, dst_portid, gfp_mask);
-}
-
 extern int netlink_unicast(struct sock *ssk, struct sk_buff *skb, __u32 portid, int nonblock);
 extern int netlink_broadcast(struct sock *ssk, struct sk_buff *skb, __u32 portid,
 			     __u32 group, gfp_t allocation);
diff --git a/net/netfilter/nfnetlink_queue.c b/net/netfilter/nfnetlink_queue.c
index 1d39365..7542999 100644
--- a/net/netfilter/nfnetlink_queue.c
+++ b/net/netfilter/nfnetlink_queue.c
@@ -301,7 +301,7 @@ nfqnl_build_packet_message(struct net *net, struct nfqnl_instance *queue,
 			   __be32 **packet_id_ptr)
 {
 	size_t size;
-	size_t data_len = 0, cap_len = 0, rem_len = 0;
+	size_t data_len = 0, cap_len = 0;
 	unsigned int hlen = 0;
 	struct sk_buff *skb;
 	struct nlattr *nla;
@@ -361,7 +361,6 @@ nfqnl_build_packet_message(struct net *net, struct nfqnl_instance *queue,
 		hlen = min_t(unsigned int, hlen, data_len);
 		size += sizeof(struct nlattr) + hlen;
 		cap_len = entskb->len;
-		rem_len = data_len - hlen;
 		break;
 	}
 
@@ -386,8 +385,7 @@ nfqnl_build_packet_message(struct net *net, struct nfqnl_instance *queue,
 			size += nla_total_size(seclen);
 	}
 
-	skb = __netlink_alloc_skb(net->nfnl, size, rem_len, queue->peer_portid,
-				  GFP_ATOMIC);
+	skb = alloc_skb(size, GFP_ATOMIC);
 	if (!skb) {
 		skb_tx_error(entskb);
 		return NULL;
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 85aa6ef..c841679 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -1248,14 +1248,6 @@ retry:
 }
 EXPORT_SYMBOL(netlink_unicast);
 
-struct sk_buff *__netlink_alloc_skb(struct sock *ssk, unsigned int size,
-				    unsigned int ldiff, u32 dst_portid,
-				    gfp_t gfp_mask)
-{
-	return alloc_skb(size, gfp_mask);
-}
-EXPORT_SYMBOL_GPL(__netlink_alloc_skb);
-
 int netlink_has_listeners(struct sock *sk, unsigned int group)
 {
 	int res = 0;
@@ -2082,15 +2074,12 @@ static int netlink_dump(struct sock *sk)
 
 	if (alloc_min_size < nlk->max_recvmsg_len) {
 		alloc_size = nlk->max_recvmsg_len;
-		skb = netlink_alloc_skb(sk, alloc_size, nlk->portid,
-					GFP_KERNEL |
-					__GFP_NOWARN |
-					__GFP_NORETRY);
+		skb = alloc_skb(alloc_size, GFP_KERNEL |
+					    __GFP_NOWARN | __GFP_NORETRY);
 	}
 	if (!skb) {
 		alloc_size = alloc_min_size;
-		skb = netlink_alloc_skb(sk, alloc_size, nlk->portid,
-					GFP_KERNEL);
+		skb = alloc_skb(alloc_size, GFP_KERNEL);
 	}
 	if (!skb)
 		goto errout_skb;
@@ -2230,8 +2219,7 @@ void netlink_ack(struct sk_buff *in_skb, struct nlmsghdr *nlh, int err)
 	if (!(nlk->flags & NETLINK_F_CAP_ACK) && err)
 		payload += nlmsg_len(nlh);
 
-	skb = netlink_alloc_skb(in_skb->sk, nlmsg_total_size(payload),
-				NETLINK_CB(in_skb).portid, GFP_KERNEL);
+	skb = nlmsg_new(payload, GFP_KERNEL);
 	if (!skb) {
 		struct sock *sk;
 
-- 
2.4.10
