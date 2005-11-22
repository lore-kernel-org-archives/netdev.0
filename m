From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 05/13]: [IPV4/6]: Netfilter IPsec output hooks
Date: Tue, 22 Nov 2005 21:30:38 +1100
Message-ID: <20051122103038.GA31532@gondor.apana.org.au>
References: <20051120163128.16666.38111.sendpatchset@localhost.localdomain>
	<20051120163134.16666.9265.sendpatchset@localhost.localdomain>
	<20051122044046.GA29166@gondor.apana.org.au>
	<4382A44F.9000105@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	davem@davemloft.net
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <4382A44F.9000105@trash.net>
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

On Tue, Nov 22, 2005 at 05:53:35AM +0100, Patrick McHardy wrote:
> 
> This looks nice, but placing the hooks at the end of the xfrm[46]
> functions doesn't work with queueing without recursively calling
> dst_output (as okfn) since we have to provide an okfn but also
> have to return ownership of the skb back to dst_output.

This patch (on top of the last one) is what we could do to eliminate
the need to return control to dst_output.  The only reason for
dst_output to exist is to handle compilers that can't optimise away
tail calls.  So if we are going to rely on the compiler to do away
with tail calls (ip_dst_output <-> __ip_dst_output), then we might
as well get rid of the loop in dst_output.

BTW, I killed the corresponding inline (which would have gone onto
xfrm[46]_output_finish) because the compiler should be able to
optimise it into a tail call.  If it doesn't, then we're in trouble
anyway since it won't be able to optimise away the call to dst_output.

> This is after POST_ROUTING :) POST_ROUTING is called before the
> transforms and LOCAL_OUT afterwards. But it could be moved to the
> ip/ip6_dst_output functions to avoid unnecessarily trying to reset
> the skb for transport mode transforms.

You're absolute right.  I somehow mistook LOCAL_OUT for POST_ROUTING :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
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
@@ -10,6 +10,7 @@
 
 #include <linux/skbuff.h>
 #include <linux/spinlock.h>
+#include <linux/netfilter_ipv4.h>
 #include <net/inet_ecn.h>
 #include <net/ip.h>
 #include <net/xfrm.h>
@@ -95,7 +96,7 @@ out:
 	return ret;
 }
 
-int xfrm4_output(struct sk_buff *skb)
+static int xfrm4_output_finish(struct sk_buff *skb)
 {
 	struct dst_entry *dst = skb->dst;
 	struct xfrm_state *x = dst->xfrm;
@@ -138,13 +139,20 @@ int xfrm4_output(struct sk_buff *skb)
 		x = dst->xfrm;
 	} while (x && !x->props.mode);
 
-	err = NET_XMIT_BYPASS;
+	nf_reset(skb);
+	
+	return NF_HOOK(PF_INET, NF_IP_LOCAL_OUT, skb, NULL, dst->dev,
+		       dst_output);
 
-out_exit:
-	return err;
 error:
 	spin_unlock_bh(&x->lock);
 error_nolock:
 	kfree_skb(skb);
-	goto out_exit;
+	return err;
+}
+
+int xfrm4_output(struct sk_buff *skb)
+{
+	return NF_HOOK(PF_INET, NF_IP_POST_ROUTING, skb, NULL, skb->dst->dev,
+		       xfrm4_output_finish);
 }
diff --git a/net/ipv6/xfrm6_output.c b/net/ipv6/xfrm6_output.c
--- a/net/ipv6/xfrm6_output.c
+++ b/net/ipv6/xfrm6_output.c
@@ -12,6 +12,7 @@
 #include <linux/skbuff.h>
 #include <linux/spinlock.h>
 #include <linux/icmpv6.h>
+#include <linux/netfilter_ipv6.h>
 #include <net/dsfield.h>
 #include <net/inet_ecn.h>
 #include <net/ipv6.h>
@@ -92,7 +93,7 @@ static int xfrm6_tunnel_check_size(struc
 	return ret;
 }
 
-int xfrm6_output(struct sk_buff *skb)
+static int xfrm6_output_finish(struct sk_buff *skb)
 {
 	struct dst_entry *dst = skb->dst;
 	struct xfrm_state *x = dst->xfrm;
@@ -137,13 +138,20 @@ int xfrm6_output(struct sk_buff *skb)
 		x = dst->xfrm;
 	} while (x && !x->props.mode);
 
-	err = NET_XMIT_BYPASS;
+	nf_reset(skb);
+	
+	return NF_HOOK(PF_INET6, NF_IP6_LOCAL_OUT, skb, NULL, dst->dev,
+		       dst_output);
 
-out_exit:
-	return err;
 error:
 	spin_unlock_bh(&x->lock);
 error_nolock:
 	kfree_skb(skb);
-	goto out_exit;
+	return err;
+}
+
+int xfrm6_output(struct sk_buff *skb)
+{
+	return NF_HOOK(PF_INET6, NF_IP6_POST_ROUTING, skb, NULL, skb->dst->dev,
+		       xfrm6_output_finish);
 }
