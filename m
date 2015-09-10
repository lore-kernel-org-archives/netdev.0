From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net] netlink, mmap: transform mmap skb into full skb on taps
Date: Thu, 10 Sep 2015 20:05:46 +0200
Message-ID: <d8546f5fdd1e84659e0f184275b36fcd565fe59c.1441887916.git.daniel@iogearbox.net>
Cc: chamaken@gmail.com, fw@strlen.de, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:55446 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752521AbbIJSFv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Sep 2015 14:05:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ken-ichirou reported that running netlink in mmap mode for receive in
combination with nlmon will throw a NULL pointer dereference in
__kfree_skb() on nlmon_xmit(), in my case I can also trigger an "unable
to handle kernel paging request". The problem is the skb_clone() in
__netlink_deliver_tap_skb() for skbs that are mmaped.

I.e. the cloned skb doesn't have a destructor, whereas the mmap netlink
skb has it pointed to netlink_skb_destructor(), set in the handler
netlink_ring_setup_skb(). There, skb->head is being set to NULL, so
that in such cases, __kfree_skb() doesn't perform a skb_release_data()
via skb_release_all(), where skb->head is possibly being freed through
kfree(head) into slab allocator, although netlink mmap skb->head points
to the mmap buffer. Similarly, the same has to be done also for large
netlink skbs where the data area is vmalloced. Therefore, as discussed,
make a copy for these rather rare cases for now. This fixes the issue
on my and Ken-ichirou's test-cases.

Reference: http://thread.gmane.org/gmane.linux.network/371129
Fixes: bcbde0d449ed ("net: netlink: virtual tap device management")
Reported-by: Ken-ichirou MATSUZAWA <chamaken@gmail.com>
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Tested-by: Ken-ichirou MATSUZAWA <chamaken@gmail.com>
---
 ( This was the last one I had in my queue. )

 net/netlink/af_netlink.c | 30 +++++++++++++++++++++++-------
 net/netlink/af_netlink.h |  9 +++++++++
 2 files changed, 32 insertions(+), 7 deletions(-)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 7f86d3b..4cad99d 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -125,6 +125,24 @@ static inline u32 netlink_group_mask(u32 group)
 	return group ? 1 << (group - 1) : 0;
 }
 
+static struct sk_buff *netlink_to_full_skb(const struct sk_buff *skb,
+					   gfp_t gfp_mask)
+{
+	unsigned int len = skb_end_offset(skb);
+	struct sk_buff *new;
+
+	new = alloc_skb(len, gfp_mask);
+	if (new == NULL)
+		return NULL;
+
+	NETLINK_CB(new).portid = NETLINK_CB(skb).portid;
+	NETLINK_CB(new).dst_group = NETLINK_CB(skb).dst_group;
+	NETLINK_CB(new).creds = NETLINK_CB(skb).creds;
+
+	memcpy(skb_put(new, len), skb->data, len);
+	return new;
+}
+
 int netlink_add_tap(struct netlink_tap *nt)
 {
 	if (unlikely(nt->dev->type != ARPHRD_NETLINK))
@@ -206,7 +224,11 @@ static int __netlink_deliver_tap_skb(struct sk_buff *skb,
 	int ret = -ENOMEM;
 
 	dev_hold(dev);
-	nskb = skb_clone(skb, GFP_ATOMIC);
+
+	if (netlink_skb_is_mmaped(skb) || is_vmalloc_addr(skb->head))
+		nskb = netlink_to_full_skb(skb, GFP_ATOMIC);
+	else
+		nskb = skb_clone(skb, GFP_ATOMIC);
 	if (nskb) {
 		nskb->dev = dev;
 		nskb->protocol = htons((u16) sk->sk_protocol);
@@ -279,11 +301,6 @@ static void netlink_rcv_wake(struct sock *sk)
 }
 
 #ifdef CONFIG_NETLINK_MMAP
-static bool netlink_skb_is_mmaped(const struct sk_buff *skb)
-{
-	return NETLINK_CB(skb).flags & NETLINK_SKB_MMAPED;
-}
-
 static bool netlink_rx_is_mmaped(struct sock *sk)
 {
 	return nlk_sk(sk)->rx_ring.pg_vec != NULL;
@@ -846,7 +863,6 @@ static void netlink_ring_set_copied(struct sock *sk, struct sk_buff *skb)
 }
 
 #else /* CONFIG_NETLINK_MMAP */
-#define netlink_skb_is_mmaped(skb)	false
 #define netlink_rx_is_mmaped(sk)	false
 #define netlink_tx_is_mmaped(sk)	false
 #define netlink_mmap			sock_no_mmap
diff --git a/net/netlink/af_netlink.h b/net/netlink/af_netlink.h
index 8900840..df9a060 100644
--- a/net/netlink/af_netlink.h
+++ b/net/netlink/af_netlink.h
@@ -59,6 +59,15 @@ static inline struct netlink_sock *nlk_sk(struct sock *sk)
 	return container_of(sk, struct netlink_sock, sk);
 }
 
+static inline bool netlink_skb_is_mmaped(const struct sk_buff *skb)
+{
+#ifdef CONFIG_NETLINK_MMAP
+	return NETLINK_CB(skb).flags & NETLINK_SKB_MMAPED;
+#else
+	return false;
+#endif /* CONFIG_NETLINK_MMAP */
+}
+
 struct netlink_table {
 	struct rhashtable	hash;
 	struct hlist_head	mc_list;
-- 
1.9.3
