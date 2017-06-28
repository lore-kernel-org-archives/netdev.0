From: Elena Reshetova <elena.reshetova@intel.com>
Subject: [PATCH 04/17] net: convert nf_bridge_info.use from
	atomic_t to refcount_t
Date: Wed, 28 Jun 2017 14:54:53 +0300
Message-ID: <1498650906-12907-5-git-send-email-elena.reshetova@intel.com>
References: <1498650906-12907-1-git-send-email-elena.reshetova@intel.com>
Cc: keescook@chromium.org, peterz@infradead.org,
	bridge@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
	jmorris@namei.org, Hans Liljestrand <ishkamiel@gmail.com>,
	kuznet@ms2.inr.ac.ru, kaber@trash.net,
	Elena Reshetova <elena.reshetova@intel.com>,
	David Windsor <dwindsor@gmail.com>
To: netdev@vger.kernel.org
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1498650906-12907-1-git-send-email-elena.reshetova@intel.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

refcount_t type and corresponding API should be
used instead of atomic_t when the variable is used as
a reference counter. This allows to avoid accidental
refcounter overflows that might lead to use-after-free
situations.

Signed-off-by: Elena Reshetova <elena.reshetova@intel.com>
Signed-off-by: Hans Liljestrand <ishkamiel@gmail.com>
Signed-off-by: Kees Cook <keescook@chromium.org>
Signed-off-by: David Windsor <dwindsor@gmail.com>
---
 include/linux/skbuff.h               | 6 +++---
 include/net/netfilter/br_netfilter.h | 2 +-
 net/bridge/br_netfilter_hooks.c      | 4 ++--
 3 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index a098d95..8a26c02 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -250,7 +250,7 @@ struct nf_conntrack {
 
 #if IS_ENABLED(CONFIG_BRIDGE_NETFILTER)
 struct nf_bridge_info {
-	atomic_t		use;
+	refcount_t		use;
 	enum {
 		BRNF_PROTO_UNCHANGED,
 		BRNF_PROTO_8021Q,
@@ -3593,13 +3593,13 @@ static inline void nf_conntrack_get(struct nf_conntrack *nfct)
 #if IS_ENABLED(CONFIG_BRIDGE_NETFILTER)
 static inline void nf_bridge_put(struct nf_bridge_info *nf_bridge)
 {
-	if (nf_bridge && atomic_dec_and_test(&nf_bridge->use))
+	if (nf_bridge && refcount_dec_and_test(&nf_bridge->use))
 		kfree(nf_bridge);
 }
 static inline void nf_bridge_get(struct nf_bridge_info *nf_bridge)
 {
 	if (nf_bridge)
-		atomic_inc(&nf_bridge->use);
+		refcount_inc(&nf_bridge->use);
 }
 #endif /* CONFIG_BRIDGE_NETFILTER */
 static inline void nf_reset(struct sk_buff *skb)
diff --git a/include/net/netfilter/br_netfilter.h b/include/net/netfilter/br_netfilter.h
index 0b0c35c..925524e 100644
--- a/include/net/netfilter/br_netfilter.h
+++ b/include/net/netfilter/br_netfilter.h
@@ -8,7 +8,7 @@ static inline struct nf_bridge_info *nf_bridge_alloc(struct sk_buff *skb)
 	skb->nf_bridge = kzalloc(sizeof(struct nf_bridge_info), GFP_ATOMIC);
 
 	if (likely(skb->nf_bridge))
-		atomic_set(&(skb->nf_bridge->use), 1);
+		refcount_set(&(skb->nf_bridge->use), 1);
 
 	return skb->nf_bridge;
 }
diff --git a/net/bridge/br_netfilter_hooks.c b/net/bridge/br_netfilter_hooks.c
index 067cf03..2261e51 100644
--- a/net/bridge/br_netfilter_hooks.c
+++ b/net/bridge/br_netfilter_hooks.c
@@ -149,12 +149,12 @@ static inline struct nf_bridge_info *nf_bridge_unshare(struct sk_buff *skb)
 {
 	struct nf_bridge_info *nf_bridge = skb->nf_bridge;
 
-	if (atomic_read(&nf_bridge->use) > 1) {
+	if (refcount_read(&nf_bridge->use) > 1) {
 		struct nf_bridge_info *tmp = nf_bridge_alloc(skb);
 
 		if (tmp) {
 			memcpy(tmp, nf_bridge, sizeof(struct nf_bridge_info));
-			atomic_set(&tmp->use, 1);
+			refcount_set(&tmp->use, 1);
 		}
 		nf_bridge_put(nf_bridge);
 		nf_bridge = tmp;
-- 
2.7.4
