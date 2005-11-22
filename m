From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 05/13]: [IPV4/6]: Netfilter IPsec output hooks
Date: Tue, 22 Nov 2005 23:13:58 +1100
Message-ID: <20051122121358.GA9057@gondor.apana.org.au>
References: <20051120163128.16666.38111.sendpatchset@localhost.localdomain>
	<20051120163134.16666.9265.sendpatchset@localhost.localdomain>
	<20051122044046.GA29166@gondor.apana.org.au>
	<4382A44F.9000105@trash.net>
	<20051122103038.GA31532@gondor.apana.org.au>
	<20051122103139.GA4632@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	davem@davemloft.net
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <20051122103139.GA4632@gondor.apana.org.au>
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

On Tue, Nov 22, 2005 at 09:31:39PM +1100, herbert wrote:
> 
> Unfortunately it looks like gcc 3.3.5 at least is too dumb to optimise
> it away.  I think we'll need a better strategy.

OK, the idea is still the same: Move the loop from dst_output into
xfrm4_output/xfrm6_output since they're the only ones who need to it.

In order to avoid the tail call issue, I've added the inline function
nf_hook which is nf_hook_slow plus the empty list check.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/include/linux/netfilter.h b/include/linux/netfilter.h
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
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -224,16 +224,7 @@ static inline void dst_set_expires(struc
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
@@ -138,7 +140,7 @@ int xfrm4_output(struct sk_buff *skb)
 		x = dst->xfrm;
 	} while (x && !x->props.mode);
 
-	err = NET_XMIT_BYPASS;
+	err = 0;
 
 out_exit:
 	return err;
@@ -148,3 +150,34 @@ error_nolock:
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
+		err = 0;
+		if (!skb->dst->xfrm)
+			break;
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
@@ -137,7 +139,7 @@ int xfrm6_output(struct sk_buff *skb)
 		x = dst->xfrm;
 	} while (x && !x->props.mode);
 
-	err = NET_XMIT_BYPASS;
+	err = 0;
 
 out_exit:
 	return err;
@@ -147,3 +149,34 @@ error_nolock:
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
+		err = 0;
+		if (!skb->dst->xfrm)
+			break;
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
