From: David Miller <davem@davemloft.net>
Subject: [PATCH 1/4] netfilter: Add nf_hook_state initializer function.
Date: Sun, 05 Apr 2015 22:18:54 -0400 (EDT)
Message-ID: <20150405.221854.118353659007886815.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, pablo@netfilter.org,
	hannes@stressinduktion.org, jiri@resnulli.us
To: netdev@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


This way we can consolidate where we setup new nf_hook_state objects,
to make sure the entire thing is initialized.

The only other place an nf_hook_object is instantiated is nf_queue,
wherein a structure copy is used.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/linux/netfilter.h | 26 ++++++++++++++++++--------
 1 file changed, 18 insertions(+), 8 deletions(-)

diff --git a/include/linux/netfilter.h b/include/linux/netfilter.h
index c480c43..b8c88f3 100644
--- a/include/linux/netfilter.h
+++ b/include/linux/netfilter.h
@@ -54,6 +54,21 @@ struct nf_hook_state {
 	int (*okfn)(struct sk_buff *);
 };
 
+static inline void nf_hook_state_init(struct nf_hook_state *p,
+				      unsigned int hook,
+				      int thresh, u_int8_t pf,
+				      struct net_device *indev,
+				      struct net_device *outdev,
+				      int (*okfn)(struct sk_buff *))
+{
+	p->hook = hook;
+	p->thresh = thresh;
+	p->pf = pf;
+	p->in = indev;
+	p->out = outdev;
+	p->okfn = okfn;
+}
+
 typedef unsigned int nf_hookfn(const struct nf_hook_ops *ops,
 			       struct sk_buff *skb,
 			       const struct nf_hook_state *state);
@@ -142,15 +157,10 @@ static inline int nf_hook_thresh(u_int8_t pf, unsigned int hook,
 				 int (*okfn)(struct sk_buff *), int thresh)
 {
 	if (nf_hooks_active(pf, hook)) {
-		struct nf_hook_state state = {
-			.hook = hook,
-			.thresh = thresh,
-			.pf = pf,
-			.in = indev,
-			.out = outdev,
-			.okfn = okfn
-		};
+		struct nf_hook_state state;
 
+		nf_hook_state_init(&state, hook, thresh, pf,
+				   indev, outdev, okfn);
 		return nf_hook_slow(skb, &state);
 	}
 	return 1;
-- 
2.1.0

