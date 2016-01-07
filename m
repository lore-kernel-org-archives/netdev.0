From: Thadeu Lima de Souza Cascardo <cascardo@redhat.com>
Subject: [PATCH v2] net: prevent corruption of skb when using skb_gso_segment
Date: Thu,  7 Jan 2016 19:16:37 -0200
Message-ID: <1452201397-28790-1-git-send-email-cascardo@redhat.com>
References: <20160107193126.GE23789@breakpoint.cc>
Cc: fw@strlen.de, cascardo@redhat.com, koct9i@gmail.com,
	xiyou.wangcong@gmail.com, davem@davemloft.net, edumazet@google.com,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160107193126.GE23789@breakpoint.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

skb_gso_segment uses skb->cb, which may be owned by the caller. This may
cause IPCB(skb)->opt.optlen to be overwritten, which will make
ip_fragment overwrite skb data and possibly skb_shinfo with IPOPT_NOOP,
thus causing a crash.

This patch saves skb->cb before calling skb_gso_segment for those users
that have anything to save, then restore it for each GSO segment.

Signed-off-by: Thadeu Lima de Souza Cascardo <cascardo@redhat.com>
---
 net/ipv4/ip_output.c            | 3 +++
 net/netfilter/nfnetlink_queue.c | 7 +++++++
 net/xfrm/xfrm_output.c          | 6 ++++++
 3 files changed, 16 insertions(+)

diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 4233cbe..37b41f6 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -226,6 +226,7 @@ static int ip_finish_output_gso(struct net *net, struct sock *sk,
 	netdev_features_t features;
 	struct sk_buff *segs;
 	int ret = 0;
+	struct inet_skb_parm ipcb;
 
 	/* common case: locally created skb or seglen is <= mtu */
 	if (((IPCB(skb)->flags & IPSKB_FORWARDED) == 0) ||
@@ -239,6 +240,7 @@ static int ip_finish_output_gso(struct net *net, struct sock *sk,
 	 * 2) skb arrived via virtio-net, we thus get TSO/GSO skbs directly
 	 * from host network stack.
 	 */
+	ipcb = *IPCB(skb);
 	features = netif_skb_features(skb);
 	segs = skb_gso_segment(skb, features & ~NETIF_F_GSO_MASK);
 	if (IS_ERR_OR_NULL(segs)) {
@@ -253,6 +255,7 @@ static int ip_finish_output_gso(struct net *net, struct sock *sk,
 		int err;
 
 		segs->next = NULL;
+		*IPCB(segs) = ipcb;
 		err = ip_fragment(net, sk, segs, mtu, ip_finish_output2);
 
 		if (err && ret == 0)
diff --git a/net/netfilter/nfnetlink_queue.c b/net/netfilter/nfnetlink_queue.c
index 861c661..426f61d 100644
--- a/net/netfilter/nfnetlink_queue.c
+++ b/net/netfilter/nfnetlink_queue.c
@@ -34,6 +34,7 @@
 #include <net/tcp_states.h>
 #include <net/netfilter/nf_queue.h>
 #include <net/netns/generic.h>
+#include <net/ip.h>
 
 #include <linux/atomic.h>
 
@@ -678,6 +679,10 @@ nfqnl_enqueue_packet(struct nf_queue_entry *entry, unsigned int queuenum)
 	int err = -ENOBUFS;
 	struct net *net = entry->state.net;
 	struct nfnl_queue_net *q = nfnl_queue_pernet(net);
+	union {
+		struct inet_skb_parm h4;
+		struct inet6_skb_parm h6;
+	} header;
 
 	/* rcu_read_lock()ed by nf_hook_slow() */
 	queue = instance_lookup(q, queuenum);
@@ -702,6 +707,7 @@ nfqnl_enqueue_packet(struct nf_queue_entry *entry, unsigned int queuenum)
 		return __nfqnl_enqueue_packet(net, queue, entry);
 
 	nf_bridge_adjust_skb_data(skb);
+	memcpy(&header, skb->cb, sizeof(header));
 	segs = skb_gso_segment(skb, 0);
 	/* Does not use PTR_ERR to limit the number of error codes that can be
 	 * returned by nf_queue.  For instance, callers rely on -ESRCH to
@@ -713,6 +719,7 @@ nfqnl_enqueue_packet(struct nf_queue_entry *entry, unsigned int queuenum)
 	err = 0;
 	do {
 		struct sk_buff *nskb = segs->next;
+		memcpy(segs->cb, &header, sizeof(header));
 		if (err == 0)
 			err = __nfqnl_enqueue_packet_gso(net, queue,
 							segs, entry);
diff --git a/net/xfrm/xfrm_output.c b/net/xfrm/xfrm_output.c
index cc3676e..27384b2 100644
--- a/net/xfrm/xfrm_output.c
+++ b/net/xfrm/xfrm_output.c
@@ -166,7 +166,12 @@ static int xfrm_output2(struct net *net, struct sock *sk, struct sk_buff *skb)
 static int xfrm_output_gso(struct net *net, struct sock *sk, struct sk_buff *skb)
 {
 	struct sk_buff *segs;
+	union {
+		struct inet_skb_parm h4;
+		struct inet6_skb_parm h6;
+	} header;
 
+	memcpy(&header, skb->cb, sizeof(header));
 	segs = skb_gso_segment(skb, 0);
 	kfree_skb(skb);
 	if (IS_ERR(segs))
@@ -179,6 +184,7 @@ static int xfrm_output_gso(struct net *net, struct sock *sk, struct sk_buff *skb
 		int err;
 
 		segs->next = NULL;
+		memcpy(segs->cb, &header, sizeof(header));
 		err = xfrm_output2(net, sk, segs);
 
 		if (unlikely(err)) {
-- 
2.5.0
