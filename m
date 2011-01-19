From: kaber@trash.net
Subject: [PATCH 73/79] netfilter: nfnetlink_queue: do not free skb on error
Date: Wed, 19 Jan 2011 20:15:13 +0100
Message-ID: <1295464519-21763-74-git-send-email-kaber@trash.net>
References: <1295464519-21763-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1295464519-21763-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Westphal <fw@strlen.de>

Move free responsibility from nf_queue to caller.
This enables more flexible error handling; we can now accept the skb
instead of freeing it.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/netfilter/core.c     |    7 +++++--
 net/netfilter/nf_queue.c |   17 ++++++++++-------
 2 files changed, 15 insertions(+), 9 deletions(-)

diff --git a/net/netfilter/core.c b/net/netfilter/core.c
index 91d66d2f..0c5b796 100644
--- a/net/netfilter/core.c
+++ b/net/netfilter/core.c
@@ -181,8 +181,11 @@ next_hook:
 	} else if ((verdict & NF_VERDICT_MASK) == NF_QUEUE) {
 		ret = nf_queue(skb, elem, pf, hook, indev, outdev, okfn,
 			       verdict >> NF_VERDICT_BITS);
-		if (ret == -ECANCELED)
-			goto next_hook;
+		if (ret < 0) {
+			if (ret == -ECANCELED)
+				goto next_hook;
+			kfree_skb(skb);
+		}
 		ret = 0;
 	}
 	rcu_read_unlock();
diff --git a/net/netfilter/nf_queue.c b/net/netfilter/nf_queue.c
index ad25c7e..5c4b730 100644
--- a/net/netfilter/nf_queue.c
+++ b/net/netfilter/nf_queue.c
@@ -163,9 +163,8 @@ static int __nf_queue(struct sk_buff *skb,
 
 	/* If it's going away, ignore hook. */
 	if (!try_module_get(entry->elem->owner)) {
-		rcu_read_unlock();
-		kfree(entry);
-		return -ECANCELED;
+		status = -ECANCELED;
+		goto err_unlock;
 	}
 	/* Bump dev refs so they don't vanish while packet is out */
 	if (indev)
@@ -198,7 +197,6 @@ static int __nf_queue(struct sk_buff *skb,
 err_unlock:
 	rcu_read_unlock();
 err:
-	kfree_skb(skb);
 	kfree(entry);
 	return status;
 }
@@ -229,7 +227,6 @@ int nf_queue(struct sk_buff *skb,
 	}
 
 	segs = skb_gso_segment(skb, 0);
-	kfree_skb(skb);
 	/* Does not use PTR_ERR to limit the number of error codes that can be
 	 * returned by nf_queue.  For instance, callers rely on -ECANCELED to mean
 	 * 'ignore this hook'.
@@ -253,8 +250,11 @@ int nf_queue(struct sk_buff *skb,
 		segs = nskb;
 	} while (segs);
 
+	/* also free orig skb if only some segments were queued */
 	if (unlikely(err && queued))
 		err = 0;
+	if (err == 0)
+		kfree_skb(skb);
 	return err;
 }
 
@@ -300,8 +300,11 @@ void nf_reinject(struct nf_queue_entry *entry, unsigned int verdict)
 		err = __nf_queue(skb, elem, entry->pf, entry->hook,
 				 entry->indev, entry->outdev, entry->okfn,
 				 verdict >> NF_VERDICT_BITS);
-		if (err == -ECANCELED)
-			goto next_hook;
+		if (err < 0) {
+			if (err == -ECANCELED)
+				goto next_hook;
+			kfree_skb(skb);
+		}
 		break;
 	case NF_STOLEN:
 	default:
-- 
1.7.2.3

