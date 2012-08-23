From: Michael Wang <wangyun@linux.vnet.ibm.com>
Subject: [PATCH 2/2] netfilter: pass 'nf_hook_ops' instead of 'list_head'
 to nf_queue()
Date: Thu, 23 Aug 2012 14:00:06 +0800
Message-ID: <5035C6E6.6040001@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, kaber@trash.net,
	pablo@netfilter.org
To: LKML <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	coreteam@netfilter.org, netfilter@vger.kernel.org,
	netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Michael Wang <wangyun@linux.vnet.ibm.com>

Since 'list_for_each_continue_rcu' has already been replaced by
'list_for_each_entry_continue_rcu', pass 'list_head' to nf_queue() as a
parameter can not benefit us any more.

This patch will replace 'list_head' with 'nf_hook_ops' as the parameter of
nf_queue() and __nf_queue() to save code.

Signed-off-by: Michael Wang <wangyun@linux.vnet.ibm.com>
---
 net/netfilter/core.c         |    4 ++--
 net/netfilter/nf_internals.h |    2 +-
 net/netfilter/nf_queue.c     |    8 ++++----
 3 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/net/netfilter/core.c b/net/netfilter/core.c
index b4cd2a2..8bf1eef 100644
--- a/net/netfilter/core.c
+++ b/net/netfilter/core.c
@@ -189,8 +189,8 @@ next_hook:
 		if (ret == 0)
 			ret = -EPERM;
 	} else if ((verdict & NF_VERDICT_MASK) == NF_QUEUE) {
-		int err = nf_queue(skb, &elem->list, pf, hook, indev, outdev,
-					okfn, verdict >> NF_VERDICT_QBITS);
+		int err = nf_queue(skb, elem, pf, hook, indev, outdev, okfn,
+						verdict >> NF_VERDICT_QBITS);
 		if (err < 0) {
 			if (err == -ECANCELED)
 				goto next_hook;
diff --git a/net/netfilter/nf_internals.h b/net/netfilter/nf_internals.h
index 2886231..3deec99 100644
--- a/net/netfilter/nf_internals.h
+++ b/net/netfilter/nf_internals.h
@@ -24,7 +24,7 @@ extern unsigned int nf_iterate(struct list_head *head,
 
 /* nf_queue.c */
 extern int nf_queue(struct sk_buff *skb,
-		    struct list_head *elem,
+		    struct nf_hook_ops *elem,
 		    u_int8_t pf, unsigned int hook,
 		    struct net_device *indev,
 		    struct net_device *outdev,
diff --git a/net/netfilter/nf_queue.c b/net/netfilter/nf_queue.c
index 29fe102..8d2cf9e 100644
--- a/net/netfilter/nf_queue.c
+++ b/net/netfilter/nf_queue.c
@@ -118,7 +118,7 @@ static void nf_queue_entry_release_refs(struct nf_queue_entry *entry)
  * through nf_reinject().
  */
 static int __nf_queue(struct sk_buff *skb,
-		      struct list_head *elem,
+		      struct nf_hook_ops *elem,
 		      u_int8_t pf, unsigned int hook,
 		      struct net_device *indev,
 		      struct net_device *outdev,
@@ -155,7 +155,7 @@ static int __nf_queue(struct sk_buff *skb,
 
 	*entry = (struct nf_queue_entry) {
 		.skb	= skb,
-		.elem	= list_entry(elem, struct nf_hook_ops, list),
+		.elem	= elem,
 		.pf	= pf,
 		.hook	= hook,
 		.indev	= indev,
@@ -225,7 +225,7 @@ static void nf_bridge_adjust_segmented_data(struct sk_buff *skb)
 #endif
 
 int nf_queue(struct sk_buff *skb,
-	     struct list_head *elem,
+	     struct nf_hook_ops *elem,
 	     u_int8_t pf, unsigned int hook,
 	     struct net_device *indev,
 	     struct net_device *outdev,
@@ -323,7 +323,7 @@ void nf_reinject(struct nf_queue_entry *entry, unsigned int verdict)
 		local_bh_enable();
 		break;
 	case NF_QUEUE:
-		err = __nf_queue(skb, &elem->list, entry->pf, entry->hook,
+		err = __nf_queue(skb, elem, entry->pf, entry->hook,
 				 entry->indev, entry->outdev, entry->okfn,
 				 verdict >> NF_VERDICT_QBITS);
 		if (err < 0) {
-- 
1.7.4.1

