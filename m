From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 14/18] netfilter: nf_queue: move device refcount bump to extra function
Date: Sat, 27 Apr 2013 20:58:19 +0200
Message-ID: <1367089103-8394-15-git-send-email-pablo@netfilter.org>
References: <1367089103-8394-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1367089103-8394-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Westphal <fw@strlen.de>

required by future patch that will need to duplicate the
nf_queue_entry, bumping refcounts of the copy.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_queue.c |   49 ++++++++++++++++++++++++++--------------------
 1 file changed, 28 insertions(+), 21 deletions(-)

diff --git a/net/netfilter/nf_queue.c b/net/netfilter/nf_queue.c
index 5ccf01e..1d91e77 100644
--- a/net/netfilter/nf_queue.c
+++ b/net/netfilter/nf_queue.c
@@ -66,6 +66,33 @@ static void nf_queue_entry_release_refs(struct nf_queue_entry *entry)
 	module_put(entry->elem->owner);
 }
 
+/* Bump dev refs so they don't vanish while packet is out */
+static bool nf_queue_entry_get_refs(struct nf_queue_entry *entry)
+{
+	if (!try_module_get(entry->elem->owner))
+		return false;
+
+	if (entry->indev)
+		dev_hold(entry->indev);
+	if (entry->outdev)
+		dev_hold(entry->outdev);
+#ifdef CONFIG_BRIDGE_NETFILTER
+	if (entry->skb->nf_bridge) {
+		struct nf_bridge_info *nf_bridge = entry->skb->nf_bridge;
+		struct net_device *physdev;
+
+		physdev = nf_bridge->physindev;
+		if (physdev)
+			dev_hold(physdev);
+		physdev = nf_bridge->physoutdev;
+		if (physdev)
+			dev_hold(physdev);
+	}
+#endif
+
+	return true;
+}
+
 /*
  * Any packet that leaves via this function must come back
  * through nf_reinject().
@@ -80,10 +107,6 @@ static int __nf_queue(struct sk_buff *skb,
 {
 	int status = -ENOENT;
 	struct nf_queue_entry *entry = NULL;
-#ifdef CONFIG_BRIDGE_NETFILTER
-	struct net_device *physindev;
-	struct net_device *physoutdev;
-#endif
 	const struct nf_afinfo *afinfo;
 	const struct nf_queue_handler *qh;
 
@@ -116,26 +139,10 @@ static int __nf_queue(struct sk_buff *skb,
 		.okfn	= okfn,
 	};
 
-	/* If it's going away, ignore hook. */
-	if (!try_module_get(entry->elem->owner)) {
+	if (!nf_queue_entry_get_refs(entry)) {
 		status = -ECANCELED;
 		goto err_unlock;
 	}
-	/* Bump dev refs so they don't vanish while packet is out */
-	if (indev)
-		dev_hold(indev);
-	if (outdev)
-		dev_hold(outdev);
-#ifdef CONFIG_BRIDGE_NETFILTER
-	if (skb->nf_bridge) {
-		physindev = skb->nf_bridge->physindev;
-		if (physindev)
-			dev_hold(physindev);
-		physoutdev = skb->nf_bridge->physoutdev;
-		if (physoutdev)
-			dev_hold(physoutdev);
-	}
-#endif
 	skb_dst_force(skb);
 	afinfo->saveroute(skb, entry);
 	status = qh->outfn(entry, queuenum);
-- 
1.7.10.4

