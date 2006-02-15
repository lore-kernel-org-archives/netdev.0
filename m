From: Patrick McHardy <kaber@trash.net>
Subject: [XFRM]: Fix SNAT-related crash in xfrm4_output_finish
Date: Wed, 15 Feb 2006 18:25:31 +0100
Message-ID: <43F3640B.6070809@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------070408010307080400050904"
Cc: Kernel Netdev Mailing List <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: "David S. Miller" <davem@davemloft.net>
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

This is a multi-part message in MIME format.
--------------070408010307080400050904
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

This patch fixes the crash in xfrm4_output_finish reported by
multiple people.



--------------070408010307080400050904
Content-Type: text/x-patch;
 name="01.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="01.diff"

[XFRM]: Fix SNAT-related crash in xfrm4_output_finish

When a packet matching an IPsec policy is SNATed so it doesn't match any
policy anymore it looses its xfrm bundle, which makes xfrm4_output_finish
crash because of a NULL pointer dereference.

This patch directs these packets to the original output path instead. Since
the packets have already passed the POST_ROUTING hook, but need to start at
the beginning of the original output path which includes another
POST_ROUTING invocation, a flag is added to the IPCB to indicate that the
packet was rerouted and doesn't need to pass the POST_ROUTING hook again.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit a31ab06c99e45232b742803677e88363cda2fb85
tree 020e91264409d418d615599a5880df68ca640432
parent ede836cd3164896d741dff1a8d7c1dc0b9b1fdf6
author Patrick McHardy <kaber@trash.net> Wed, 15 Feb 2006 17:30:44 +0100
committer Patrick McHardy <kaber@trash.net> Wed, 15 Feb 2006 17:30:44 +0100

 include/linux/netfilter.h |   19 +++++++++++++++----
 include/net/ip.h          |    1 +
 include/net/xfrm.h        |    1 -
 net/ipv4/ip_gre.c         |    3 ++-
 net/ipv4/ip_output.c      |   16 ++++++++++------
 net/ipv4/ipip.c           |    3 ++-
 net/ipv4/xfrm4_output.c   |   13 ++++++++++---
 7 files changed, 40 insertions(+), 16 deletions(-)

diff --git a/include/linux/netfilter.h b/include/linux/netfilter.h
index 4cf6088..5deacda 100644
--- a/include/linux/netfilter.h
+++ b/include/linux/netfilter.h
@@ -184,8 +184,11 @@ static inline int nf_hook_thresh(int pf,
 				 struct sk_buff **pskb,
 				 struct net_device *indev,
 				 struct net_device *outdev,
-				 int (*okfn)(struct sk_buff *), int thresh)
+				 int (*okfn)(struct sk_buff *), int thresh,
+				 int cond)
 {
+	if (!cond)
+		return 1;
 #ifndef CONFIG_NETFILTER_DEBUG
 	if (list_empty(&nf_hooks[pf][hook]))
 		return 1;
@@ -197,7 +200,7 @@ static inline int nf_hook(int pf, unsign
 			  struct net_device *indev, struct net_device *outdev,
 			  int (*okfn)(struct sk_buff *))
 {
-	return nf_hook_thresh(pf, hook, pskb, indev, outdev, okfn, INT_MIN);
+	return nf_hook_thresh(pf, hook, pskb, indev, outdev, okfn, INT_MIN, 1);
 }
                    
 /* Activate hook; either okfn or kfree_skb called, unless a hook
@@ -224,7 +227,13 @@ static inline int nf_hook(int pf, unsign
 
 #define NF_HOOK_THRESH(pf, hook, skb, indev, outdev, okfn, thresh)	       \
 ({int __ret;								       \
-if ((__ret=nf_hook_thresh(pf, hook, &(skb), indev, outdev, okfn, thresh)) == 1)\
+if ((__ret=nf_hook_thresh(pf, hook, &(skb), indev, outdev, okfn, thresh, 1)) == 1)\
+	__ret = (okfn)(skb);						       \
+__ret;})
+
+#define NF_HOOK_COND(pf, hook, skb, indev, outdev, okfn, cond)		       \
+({int __ret;								       \
+if ((__ret=nf_hook_thresh(pf, hook, &(skb), indev, outdev, okfn, INT_MIN, cond)) == 1)\
 	__ret = (okfn)(skb);						       \
 __ret;})
 
@@ -295,11 +304,13 @@ extern struct proc_dir_entry *proc_net_n
 
 #else /* !CONFIG_NETFILTER */
 #define NF_HOOK(pf, hook, skb, indev, outdev, okfn) (okfn)(skb)
+#define NF_HOOK_COND(pf, hook, skb, indev, outdev, okfn, cond) (okfn)(skb)
 static inline int nf_hook_thresh(int pf, unsigned int hook,
 				 struct sk_buff **pskb,
 				 struct net_device *indev,
 				 struct net_device *outdev,
-				 int (*okfn)(struct sk_buff *), int thresh)
+				 int (*okfn)(struct sk_buff *), int thresh,
+				 int cond)
 {
 	return okfn(*pskb);
 }
diff --git a/include/net/ip.h b/include/net/ip.h
index 8de0697..fab3d5b 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -41,6 +41,7 @@ struct inet_skb_parm
 #define IPSKB_XFRM_TUNNEL_SIZE	2
 #define IPSKB_XFRM_TRANSFORMED	4
 #define IPSKB_FRAG_COMPLETE	8
+#define IPSKB_REROUTED		16
 };
 
 struct ipcm_cookie
diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index d09ca0e..d6111a2 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -866,7 +866,6 @@ extern int xfrm_state_mtu(struct xfrm_st
 extern int xfrm_init_state(struct xfrm_state *x);
 extern int xfrm4_rcv(struct sk_buff *skb);
 extern int xfrm4_output(struct sk_buff *skb);
-extern int xfrm4_output_finish(struct sk_buff *skb);
 extern int xfrm4_tunnel_register(struct xfrm_tunnel *handler);
 extern int xfrm4_tunnel_deregister(struct xfrm_tunnel *handler);
 extern int xfrm6_rcv_spi(struct sk_buff **pskb, u32 spi);
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index abe2392..9981dcd 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -830,7 +830,8 @@ static int ipgre_tunnel_xmit(struct sk_b
 	skb->h.raw = skb->nh.raw;
 	skb->nh.raw = skb_push(skb, gre_hlen);
 	memset(&(IPCB(skb)->opt), 0, sizeof(IPCB(skb)->opt));
-	IPCB(skb)->flags &= ~(IPSKB_XFRM_TUNNEL_SIZE|IPSKB_XFRM_TRANSFORMED);
+	IPCB(skb)->flags &= ~(IPSKB_XFRM_TUNNEL_SIZE | IPSKB_XFRM_TRANSFORMED |
+			      IPSKB_REROUTED);
 	dst_release(skb->dst);
 	skb->dst = &rt->u.dst;
 
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 3324fbf..57d290d 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -207,8 +207,10 @@ static inline int ip_finish_output(struc
 {
 #if defined(CONFIG_NETFILTER) && defined(CONFIG_XFRM)
 	/* Policy lookup after SNAT yielded a new policy */
-	if (skb->dst->xfrm != NULL)
-		return xfrm4_output_finish(skb);
+	if (skb->dst->xfrm != NULL) {
+		IPCB(skb)->flags |= IPSKB_REROUTED;
+		return dst_output(skb);
+	}
 #endif
 	if (skb->len > dst_mtu(skb->dst) &&
 	    !(skb_shinfo(skb)->ufo_size || skb_shinfo(skb)->tso_size))
@@ -271,8 +273,9 @@ int ip_mc_output(struct sk_buff *skb)
 				newskb->dev, ip_dev_loopback_xmit);
 	}
 
-	return NF_HOOK(PF_INET, NF_IP_POST_ROUTING, skb, NULL, skb->dev,
-		       ip_finish_output);
+	return NF_HOOK_COND(PF_INET, NF_IP_POST_ROUTING, skb, NULL, skb->dev,
+			    ip_finish_output,
+			    !(IPCB(skb)->flags & IPSKB_REROUTED));
 }
 
 int ip_output(struct sk_buff *skb)
@@ -284,8 +287,9 @@ int ip_output(struct sk_buff *skb)
 	skb->dev = dev;
 	skb->protocol = htons(ETH_P_IP);
 
-	return NF_HOOK(PF_INET, NF_IP_POST_ROUTING, skb, NULL, dev,
-		       ip_finish_output);
+	return NF_HOOK_COND(PF_INET, NF_IP_POST_ROUTING, skb, NULL, dev,
+		            ip_finish_output,
+			    !(IPCB(skb)->flags & IPSKB_REROUTED));
 }
 
 int ip_queue_xmit(struct sk_buff *skb, int ipfragok)
diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index e5cbe72..03d1374 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -622,7 +622,8 @@ static int ipip_tunnel_xmit(struct sk_bu
 	skb->h.raw = skb->nh.raw;
 	skb->nh.raw = skb_push(skb, sizeof(struct iphdr));
 	memset(&(IPCB(skb)->opt), 0, sizeof(IPCB(skb)->opt));
-	IPCB(skb)->flags &= ~(IPSKB_XFRM_TUNNEL_SIZE|IPSKB_XFRM_TRANSFORMED);
+	IPCB(skb)->flags &= ~(IPSKB_XFRM_TUNNEL_SIZE | IPSKB_XFRM_TRANSFORMED |
+			      IPSKB_REROUTED);
 	dst_release(skb->dst);
 	skb->dst = &rt->u.dst;
 
diff --git a/net/ipv4/xfrm4_output.c b/net/ipv4/xfrm4_output.c
index d4df0dd..32ad229 100644
--- a/net/ipv4/xfrm4_output.c
+++ b/net/ipv4/xfrm4_output.c
@@ -152,10 +152,16 @@ error_nolock:
 	goto out_exit;
 }
 
-int xfrm4_output_finish(struct sk_buff *skb)
+static int xfrm4_output_finish(struct sk_buff *skb)
 {
 	int err;
 
+#ifdef CONFIG_NETFILTER
+	if (!skb->dst->xfrm) {
+		IPCB(skb)->flags |= IPSKB_REROUTED;
+		return dst_output(skb);
+	}
+#endif
 	while (likely((err = xfrm4_output_one(skb)) == 0)) {
 		nf_reset(skb);
 
@@ -178,6 +184,7 @@ int xfrm4_output_finish(struct sk_buff *
 
 int xfrm4_output(struct sk_buff *skb)
 {
-	return NF_HOOK(PF_INET, NF_IP_POST_ROUTING, skb, NULL, skb->dst->dev,
-		       xfrm4_output_finish);
+	return NF_HOOK_COND(PF_INET, NF_IP_POST_ROUTING, skb, NULL, skb->dst->dev,
+			    xfrm4_output_finish,
+			    !(IPCB(skb)->flags & IPSKB_REROUTED));
 }

--------------070408010307080400050904--
