From: Patrick McHardy <kaber@trash.net>
Subject: [XFRM 01/10]: Netfilter IPsec output hooks
Date: Sat,  7 Jan 2006 02:09:32 +0100 (MET)
Message-ID: <20060107010856.8712.60346.sendpatchset@localhost.localdomain>
References: <20060107010855.8712.68786.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: David S. Miller <davem@davemloft.net>
In-Reply-To: <20060107010855.8712.68786.sendpatchset@localhost.localdomain>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

[XFRM]: Netfilter IPsec output hooks

Call netfilter hooks before IPsec transforms. Packets visit the
FORWARD/LOCAL_OUT and POST_ROUTING hook before the first encapsulation
and the LOCAL_OUT and POST_ROUTING hook before each following tunnel mode
transform.

Patch from Herbert Xu <herbert@gondor.apana.org.au>:

Move the loop from dst_output into xfrm4_output/xfrm6_output since they're
the only ones who need to it. xfrm{4,6}_output_one() processes the first SA
all subsequent transport mode SAs and is called in a loop that calls the
netfilter hooks between each two calls.

In order to avoid the tail call issue, I've added the inline function
nf_hook which is nf_hook_slow plus the empty list check.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit b426272e4885bc398c9c01e42486669cd832706f
tree 98334b7544c7d01f238bc5edef47b95cd86ad619
parent d99cf9d679a520d67f81d805b7cb91c68e1847f0
author Patrick McHardy <kaber@trash.net> Fri, 06 Jan 2006 21:11:59 +0100
committer Patrick McHardy <kaber@trash.net> Fri, 06 Jan 2006 21:11:59 +0100

 include/linux/netfilter.h |   61 +++++++++++++++++++++--------------
 include/net/dst.h         |   11 +-----
 net/ipv4/xfrm4_output.c   |   75 ++++++++++++++++++++++++++++++++-----------
 net/ipv6/xfrm6_output.c   |   79 +++++++++++++++++++++++++++++++++------------
 4 files changed, 152 insertions(+), 74 deletions(-)

diff --git a/include/linux/netfilter.h b/include/linux/netfilter.h
index be365e7..79bb977 100644
--- a/include/linux/netfilter.h
+++ b/include/linux/netfilter.h
@@ -168,6 +168,37 @@ void nf_log_packet(int pf,
 		   const struct net_device *out,
 		   struct nf_loginfo *li,
 		   const char *fmt, ...);
+
+int nf_hook_slow(int pf, unsigned int hook, struct sk_buff **pskb,
+		 struct net_device *indev, struct net_device *outdev,
+		 int (*okfn)(struct sk_buff *), int thresh);
+
+/**
+ *	nf_hook_thresh - call a netfilter hook
+ *	
+ *	Returns 1 if the hook has allowed the packet to pass.  The function
+ *	okfn must be invoked by the caller in this case.  Any other return
+ *	value indicates the packet has been consumed by the hook.
+ */
+static inline int nf_hook_thresh(int pf, unsigned int hook,
+				 struct sk_buff **pskb,
+				 struct net_device *indev,
+				 struct net_device *outdev,
+				 int (*okfn)(struct sk_buff *), int thresh)
+{
+#ifndef CONFIG_NETFILTER_DEBUG
+	if (list_empty(&nf_hooks[pf][hook]))
+		return 1;
+#endif
+	return nf_hook_slow(pf, hook, pskb, indev, outdev, okfn, thresh);
+}
+
+static inline int nf_hook(int pf, unsigned int hook, struct sk_buff **pskb,
+			  struct net_device *indev, struct net_device *outdev,
+			  int (*okfn)(struct sk_buff *))
+{
+	return nf_hook_thresh(pf, hook, pskb, indev, outdev, okfn, INT_MIN);
+}
                    
 /* Activate hook; either okfn or kfree_skb called, unless a hook
    returns NF_STOLEN (in which case, it's up to the hook to deal with
@@ -188,35 +219,17 @@ void nf_log_packet(int pf,
 
 /* This is gross, but inline doesn't cut it for avoiding the function
    call in fast path: gcc doesn't inline (needs value tracking?). --RR */
-#ifdef CONFIG_NETFILTER_DEBUG
-#define NF_HOOK(pf, hook, skb, indev, outdev, okfn)			       \
-({int __ret;								       \
-if ((__ret=nf_hook_slow(pf, hook, &(skb), indev, outdev, okfn, INT_MIN)) == 1) \
-	__ret = (okfn)(skb);						       \
-__ret;})
-#define NF_HOOK_THRESH(pf, hook, skb, indev, outdev, okfn, thresh)	       \
-({int __ret;								       \
-if ((__ret=nf_hook_slow(pf, hook, &(skb), indev, outdev, okfn, thresh)) == 1)  \
-	__ret = (okfn)(skb);						       \
-__ret;})
-#else
-#define NF_HOOK(pf, hook, skb, indev, outdev, okfn)			       \
-({int __ret;								       \
-if (list_empty(&nf_hooks[pf][hook]) ||					       \
-    (__ret=nf_hook_slow(pf, hook, &(skb), indev, outdev, okfn, INT_MIN)) == 1) \
-	__ret = (okfn)(skb);						       \
-__ret;})
+
+/* HX: It's slightly less gross now. */
+
 #define NF_HOOK_THRESH(pf, hook, skb, indev, outdev, okfn, thresh)	       \
 ({int __ret;								       \
-if (list_empty(&nf_hooks[pf][hook]) ||					       \
-    (__ret=nf_hook_slow(pf, hook, &(skb), indev, outdev, okfn, thresh)) == 1)  \
+if ((__ret=nf_hook_thresh(pf, hook, &(skb), indev, outdev, okfn, thresh)) == 1)\
 	__ret = (okfn)(skb);						       \
 __ret;})
-#endif
 
-int nf_hook_slow(int pf, unsigned int hook, struct sk_buff **pskb,
-		 struct net_device *indev, struct net_device *outdev,
-		 int (*okfn)(struct sk_buff *), int thresh);
+#define NF_HOOK(pf, hook, skb, indev, outdev, okfn) \
+	NF_HOOK_THRESH(pf, hook, skb, indev, outdev, okfn, INT_MIN)
 
 /* Call setsockopt() */
 int nf_setsockopt(struct sock *sk, int pf, int optval, char __user *opt, 
diff --git a/include/net/dst.h b/include/net/dst.h
index bee8b84..5161e89 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -225,16 +225,7 @@ static inline void dst_set_expires(struc
 /* Output packet to network from transport.  */
 static inline int dst_output(struct sk_buff *skb)
 {
-	int err;
-
-	for (;;) {
-		err = skb->dst->output(skb);
-
-		if (likely(err == 0))
-			return err;
-		if (unlikely(err != NET_XMIT_BYPASS))
-			return err;
-	}
+	return skb->dst->output(skb);
 }
 
 /* Input packet from network to transport.  */
diff --git a/net/ipv4/xfrm4_output.c b/net/ipv4/xfrm4_output.c
index 66620a9..51fabb8 100644
--- a/net/ipv4/xfrm4_output.c
+++ b/net/ipv4/xfrm4_output.c
@@ -8,8 +8,10 @@
  * 2 of the License, or (at your option) any later version.
  */
 
+#include <linux/compiler.h>
 #include <linux/skbuff.h>
 #include <linux/spinlock.h>
+#include <linux/netfilter_ipv4.h>
 #include <net/inet_ecn.h>
 #include <net/ip.h>
 #include <net/xfrm.h>
@@ -95,7 +97,7 @@ out:
 	return ret;
 }
 
-int xfrm4_output(struct sk_buff *skb)
+static int xfrm4_output_one(struct sk_buff *skb)
 {
 	struct dst_entry *dst = skb->dst;
 	struct xfrm_state *x = dst->xfrm;
@@ -113,27 +115,32 @@ int xfrm4_output(struct sk_buff *skb)
 			goto error_nolock;
 	}
 
-	spin_lock_bh(&x->lock);
-	err = xfrm_state_check(x, skb);
-	if (err)
-		goto error;
-
-	xfrm4_encap(skb);
-
-	err = x->type->output(x, skb);
-	if (err)
-		goto error;
+	do {
+		spin_lock_bh(&x->lock);
+		err = xfrm_state_check(x, skb);
+		if (err)
+			goto error;
 
-	x->curlft.bytes += skb->len;
-	x->curlft.packets++;
+		xfrm4_encap(skb);
 
-	spin_unlock_bh(&x->lock);
+		err = x->type->output(x, skb);
+		if (err)
+			goto error;
+
+		x->curlft.bytes += skb->len;
+		x->curlft.packets++;
+
+		spin_unlock_bh(&x->lock);
 	
-	if (!(skb->dst = dst_pop(dst))) {
-		err = -EHOSTUNREACH;
-		goto error_nolock;
-	}
-	err = NET_XMIT_BYPASS;
+		if (!(skb->dst = dst_pop(dst))) {
+			err = -EHOSTUNREACH;
+			goto error_nolock;
+		}
+		dst = skb->dst;
+		x = dst->xfrm;
+	} while (x && !x->props.mode);
+
+	err = 0;
 
 out_exit:
 	return err;
@@ -143,3 +150,33 @@ error_nolock:
 	kfree_skb(skb);
 	goto out_exit;
 }
+
+static int xfrm4_output_finish(struct sk_buff *skb)
+{
+	int err;
+
+	while (likely((err = xfrm4_output_one(skb)) == 0)) {
+		nf_reset(skb);
+
+		err = nf_hook(PF_INET, NF_IP_LOCAL_OUT, &skb, NULL,
+			      skb->dst->dev, dst_output);
+		if (unlikely(err != 1))
+			break;
+
+		if (!skb->dst->xfrm)
+			return dst_output(skb);
+
+		err = nf_hook(PF_INET, NF_IP_POST_ROUTING, &skb, NULL,
+			      skb->dst->dev, xfrm4_output_finish);
+		if (unlikely(err != 1))
+			break;
+	}
+
+	return err;
+}
+
+int xfrm4_output(struct sk_buff *skb)
+{
+	return NF_HOOK(PF_INET, NF_IP_POST_ROUTING, skb, NULL, skb->dst->dev,
+		       xfrm4_output_finish);
+}
diff --git a/net/ipv6/xfrm6_output.c b/net/ipv6/xfrm6_output.c
index 6b98677..fc0ea38 100644
--- a/net/ipv6/xfrm6_output.c
+++ b/net/ipv6/xfrm6_output.c
@@ -9,9 +9,11 @@
  * 2 of the License, or (at your option) any later version.
  */
 
+#include <linux/compiler.h>
 #include <linux/skbuff.h>
 #include <linux/spinlock.h>
 #include <linux/icmpv6.h>
+#include <linux/netfilter_ipv6.h>
 #include <net/dsfield.h>
 #include <net/inet_ecn.h>
 #include <net/ipv6.h>
@@ -92,7 +94,7 @@ static int xfrm6_tunnel_check_size(struc
 	return ret;
 }
 
-int xfrm6_output(struct sk_buff *skb)
+static int xfrm6_output_one(struct sk_buff *skb)
 {
 	struct dst_entry *dst = skb->dst;
 	struct xfrm_state *x = dst->xfrm;
@@ -110,29 +112,34 @@ int xfrm6_output(struct sk_buff *skb)
 			goto error_nolock;
 	}
 
-	spin_lock_bh(&x->lock);
-	err = xfrm_state_check(x, skb);
-	if (err)
-		goto error;
-
-	xfrm6_encap(skb);
-
-	err = x->type->output(x, skb);
-	if (err)
-		goto error;
+	do {
+		spin_lock_bh(&x->lock);
+		err = xfrm_state_check(x, skb);
+		if (err)
+			goto error;
 
-	x->curlft.bytes += skb->len;
-	x->curlft.packets++;
+		xfrm6_encap(skb);
 
-	spin_unlock_bh(&x->lock);
+		err = x->type->output(x, skb);
+		if (err)
+			goto error;
 
-	skb->nh.raw = skb->data;
-	
-	if (!(skb->dst = dst_pop(dst))) {
-		err = -EHOSTUNREACH;
-		goto error_nolock;
-	}
-	err = NET_XMIT_BYPASS;
+		x->curlft.bytes += skb->len;
+		x->curlft.packets++;
+
+		spin_unlock_bh(&x->lock);
+
+		skb->nh.raw = skb->data;
+		
+		if (!(skb->dst = dst_pop(dst))) {
+			err = -EHOSTUNREACH;
+			goto error_nolock;
+		}
+		dst = skb->dst;
+		x = dst->xfrm;
+	} while (x && !x->props.mode);
+
+	err = 0;
 
 out_exit:
 	return err;
@@ -142,3 +149,33 @@ error_nolock:
 	kfree_skb(skb);
 	goto out_exit;
 }
+
+static int xfrm6_output_finish(struct sk_buff *skb)
+{
+	int err;
+
+	while (likely((err = xfrm6_output_one(skb)) == 0)) {
+		nf_reset(skb);
+	
+		err = nf_hook(PF_INET6, NF_IP6_LOCAL_OUT, &skb, NULL,
+			      skb->dst->dev, dst_output);
+		if (unlikely(err != 1))
+			break;
+
+		if (!skb->dst->xfrm)
+			return dst_output(skb);
+
+		err = nf_hook(PF_INET6, NF_IP6_POST_ROUTING, &skb, NULL,
+			      skb->dst->dev, xfrm6_output_finish);
+		if (unlikely(err != 1))
+			break;
+	}
+
+	return err;
+}
+
+int xfrm6_output(struct sk_buff *skb)
+{
+	return NF_HOOK(PF_INET6, NF_IP6_POST_ROUTING, skb, NULL, skb->dst->dev,
+		       xfrm6_output_finish);
+}
