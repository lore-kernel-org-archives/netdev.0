From: David Miller <davem@davemloft.net>
Subject: [PATCH 2/4] netfilter: Add socket pointer to nf_hook_state.
Date: Sun, 05 Apr 2015 22:19:00 -0400 (EDT)
Message-ID: <20150405.221900.509352617772097714.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, pablo@netfilter.org,
	hannes@stressinduktion.org, jiri@resnulli.us
To: netdev@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


It is currently always set to NULL, but nf_queue is adjusted to be
prepared for it being set to a real socket by taking and releasing a
reference to that socket when necessary.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/linux/netfilter.h | 7 ++++++-
 net/netfilter/nf_queue.c  | 4 ++++
 2 files changed, 10 insertions(+), 1 deletion(-)

diff --git a/include/linux/netfilter.h b/include/linux/netfilter.h
index b8c88f3..f8f58fa 100644
--- a/include/linux/netfilter.h
+++ b/include/linux/netfilter.h
@@ -45,12 +45,15 @@ struct sk_buff;
 
 struct nf_hook_ops;
 
+struct sock;
+
 struct nf_hook_state {
 	unsigned int hook;
 	int thresh;
 	u_int8_t pf;
 	struct net_device *in;
 	struct net_device *out;
+	struct sock *sk;
 	int (*okfn)(struct sk_buff *);
 };
 
@@ -59,6 +62,7 @@ static inline void nf_hook_state_init(struct nf_hook_state *p,
 				      int thresh, u_int8_t pf,
 				      struct net_device *indev,
 				      struct net_device *outdev,
+				      struct sock *sk,
 				      int (*okfn)(struct sk_buff *))
 {
 	p->hook = hook;
@@ -66,6 +70,7 @@ static inline void nf_hook_state_init(struct nf_hook_state *p,
 	p->pf = pf;
 	p->in = indev;
 	p->out = outdev;
+	p->sk = sk;
 	p->okfn = okfn;
 }
 
@@ -160,7 +165,7 @@ static inline int nf_hook_thresh(u_int8_t pf, unsigned int hook,
 		struct nf_hook_state state;
 
 		nf_hook_state_init(&state, hook, thresh, pf,
-				   indev, outdev, okfn);
+				   indev, outdev, NULL, okfn);
 		return nf_hook_slow(skb, &state);
 	}
 	return 1;
diff --git a/net/netfilter/nf_queue.c b/net/netfilter/nf_queue.c
index d3cd37e..c4a7066 100644
--- a/net/netfilter/nf_queue.c
+++ b/net/netfilter/nf_queue.c
@@ -54,6 +54,8 @@ void nf_queue_entry_release_refs(struct nf_queue_entry *entry)
 		dev_put(state->in);
 	if (state->out)
 		dev_put(state->out);
+	if (state->sk)
+		sock_put(state->sk);
 #if IS_ENABLED(CONFIG_BRIDGE_NETFILTER)
 	if (entry->skb->nf_bridge) {
 		struct nf_bridge_info *nf_bridge = entry->skb->nf_bridge;
@@ -81,6 +83,8 @@ bool nf_queue_entry_get_refs(struct nf_queue_entry *entry)
 		dev_hold(state->in);
 	if (state->out)
 		dev_hold(state->out);
+	if (state->sk)
+		sock_hold(state->sk);
 #if IS_ENABLED(CONFIG_BRIDGE_NETFILTER)
 	if (entry->skb->nf_bridge) {
 		struct nf_bridge_info *nf_bridge = entry->skb->nf_bridge;
-- 
2.1.0

