From: Patrick McHardy <kaber@trash.net>
Subject: [RFC, PATCH 2/5]: netfilter+ipsec - output hooks
Date: Thu, 18 Mar 2004 17:31:40 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4059CEEC.7070009@trash.net>
References: <20040308110331.GA20719@gondor.apana.org.au>	<404C874D.4000907@trash.net> <20040308115858.75cdddca.davem@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090502070304060205040206"
Cc: herbert@gondor.apana.org.au, netdev@oss.sgi.com,
        netfilter-devel@lists.netfilter.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040308115858.75cdddca.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------090502070304060205040206
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

This patch adds new output-hooks. Packets with dst->xfrm != NULL
traverse the POST_ROUTING hook before dst_output is called. The
transformers mark the packets in the control buffer with a new flag
IPSKB_XFRM_TRANSFORMED, these packets then traverse the LOCAL_OUT
hook when they hit ip_output.



--------------090502070304060205040206
Content-Type: text/x-patch;
 name="02-output-hooks.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="02-output-hooks.diff"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/03/18 14:59:24+01:00 kaber@trash.net 
#   [NETFILTER}: Pass packets to POST_ROUTING hook before encryption and LOCAL_OUT afterwards
# 
# net/ipv4/xfrm4_tunnel.c
#   2004/03/18 14:59:14+01:00 kaber@trash.net +1 -0
#   [NETFILTER}: Pass packets to POST_ROUTING hook before encryption and LOCAL_OUT afterwards
# 
# net/ipv4/ipcomp.c
#   2004/03/18 14:59:14+01:00 kaber@trash.net +1 -0
#   [NETFILTER}: Pass packets to POST_ROUTING hook before encryption and LOCAL_OUT afterwards
# 
# net/ipv4/ip_output.c
#   2004/03/18 14:59:14+01:00 kaber@trash.net +20 -4
#   [NETFILTER}: Pass packets to POST_ROUTING hook before encryption and LOCAL_OUT afterwards
# 
# net/ipv4/ip_forward.c
#   2004/03/18 14:59:14+01:00 kaber@trash.net +2 -1
#   [NETFILTER}: Pass packets to POST_ROUTING hook before encryption and LOCAL_OUT afterwards
# 
# net/ipv4/esp4.c
#   2004/03/18 14:59:14+01:00 kaber@trash.net +1 -0
#   [NETFILTER}: Pass packets to POST_ROUTING hook before encryption and LOCAL_OUT afterwards
# 
# net/ipv4/ah4.c
#   2004/03/18 14:59:14+01:00 kaber@trash.net +1 -0
#   [NETFILTER}: Pass packets to POST_ROUTING hook before encryption and LOCAL_OUT afterwards
# 
# include/net/ip.h
#   2004/03/18 14:59:14+01:00 kaber@trash.net +1 -0
#   [NETFILTER}: Pass packets to POST_ROUTING hook before encryption and LOCAL_OUT afterwards
# 
# include/linux/netfilter.h
#   2004/03/18 14:59:14+01:00 kaber@trash.net +9 -4
#   [NETFILTER}: Pass packets to POST_ROUTING hook before encryption and LOCAL_OUT afterwards
# 
diff -Nru a/include/linux/netfilter.h b/include/linux/netfilter.h
--- a/include/linux/netfilter.h	Thu Mar 18 16:45:22 2004
+++ b/include/linux/netfilter.h	Thu Mar 18 16:45:22 2004
@@ -119,12 +119,14 @@
 /* This is gross, but inline doesn't cut it for avoiding the function
    call in fast path: gcc doesn't inline (needs value tracking?). --RR */
 #ifdef CONFIG_NETFILTER_DEBUG
-#define NF_HOOK(pf, hook, skb, indev, outdev, okfn)			\
- nf_hook_slow((pf), (hook), (skb), (indev), (outdev), (okfn), INT_MIN)
+#define NF_HOOK_COND(pf, hook, skb, indev, outdev, okfn, cond)		\
+(!(cond)									\
+ ? (okfn)(skb) 								\
+ : nf_hook_slow((pf), (hook), (skb), (indev), (outdev), (okfn), INT_MIN))
 #define NF_HOOK_THRESH nf_hook_slow
 #else
-#define NF_HOOK(pf, hook, skb, indev, outdev, okfn)			\
-(list_empty(&nf_hooks[(pf)][(hook)])					\
+#define NF_HOOK_COND(pf, hook, skb, indev, outdev, okfn, cond)		\
+(!(cond) || list_empty(&nf_hooks[(pf)][(hook)])				\
  ? (okfn)(skb)								\
  : nf_hook_slow((pf), (hook), (skb), (indev), (outdev), (okfn), INT_MIN))
 #define NF_HOOK_THRESH(pf, hook, skb, indev, outdev, okfn, thresh)	\
@@ -132,6 +134,8 @@
  ? (okfn)(skb)								\
  : nf_hook_slow((pf), (hook), (skb), (indev), (outdev), (okfn), (thresh)))
 #endif
+#define NF_HOOK(pf, hook, skb, indev, outdev, okfn)			\
+ NF_HOOK_COND((pf), (hook), (skb), (indev), (outdev), (okfn), 1)
 
 int nf_hook_slow(int pf, unsigned int hook, struct sk_buff *skb,
 		 struct net_device *indev, struct net_device *outdev,
@@ -164,6 +168,7 @@
 
 #else /* !CONFIG_NETFILTER */
 #define NF_HOOK(pf, hook, skb, indev, outdev, okfn) (okfn)(skb)
+#define NF_HOOK_COND NF_HOOK
 #endif /*CONFIG_NETFILTER*/
 
 #endif /*__KERNEL__*/
diff -Nru a/include/net/ip.h b/include/net/ip.h
--- a/include/net/ip.h	Thu Mar 18 16:45:22 2004
+++ b/include/net/ip.h	Thu Mar 18 16:45:22 2004
@@ -48,6 +48,7 @@
 #define IPSKB_TRANSLATED	2
 #define IPSKB_FORWARDED		4
 #define IPSKB_XFRM_TUNNEL_SIZE	8
+#define IPSKB_XFRM_TRANSFORMED	16
 };
 
 struct ipcm_cookie
diff -Nru a/net/ipv4/ah4.c b/net/ipv4/ah4.c
--- a/net/ipv4/ah4.c	Thu Mar 18 16:45:22 2004
+++ b/net/ipv4/ah4.c	Thu Mar 18 16:45:22 2004
@@ -145,6 +145,7 @@
 		err = -EHOSTUNREACH;
 		goto error_nolock;
 	}
+	IPCB(skb)->flags |= IPSKB_XFRM_TRANSFORMED;
 	return NET_XMIT_BYPASS;
 
 error:
diff -Nru a/net/ipv4/esp4.c b/net/ipv4/esp4.c
--- a/net/ipv4/esp4.c	Thu Mar 18 16:45:22 2004
+++ b/net/ipv4/esp4.c	Thu Mar 18 16:45:22 2004
@@ -199,6 +199,7 @@
 		err = -EHOSTUNREACH;
 		goto error_nolock;
 	}
+	IPCB(skb)->flags |= IPSKB_XFRM_TRANSFORMED;
 	return NET_XMIT_BYPASS;
 
 error:
diff -Nru a/net/ipv4/ip_forward.c b/net/ipv4/ip_forward.c
--- a/net/ipv4/ip_forward.c	Thu Mar 18 16:45:22 2004
+++ b/net/ipv4/ip_forward.c	Thu Mar 18 16:45:22 2004
@@ -51,7 +51,8 @@
 	if (unlikely(opt->optlen))
 		ip_forward_options(skb);
 
-	return dst_output(skb);
+	return NF_HOOK_COND(PF_INET, NF_IP_POST_ROUTING, skb, NULL,
+	                    skb->dst->dev, dst_output, skb->dst->xfrm != NULL);
 }
 
 int ip_forward(struct sk_buff *skb)
diff -Nru a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
--- a/net/ipv4/ip_output.c	Thu Mar 18 16:45:22 2004
+++ b/net/ipv4/ip_output.c	Thu Mar 18 16:45:22 2004
@@ -123,6 +123,12 @@
 	return ttl;
 }
 
+static inline int ip_dst_output(struct sk_buff *skb)
+{
+	return NF_HOOK_COND(PF_INET, NF_IP_POST_ROUTING, skb, NULL,
+	                    skb->dst->dev, dst_output, skb->dst->xfrm != NULL);
+}
+
 /* 
  *		Add an ip header to a skbuff and send it out.
  *
@@ -165,7 +171,7 @@
 
 	/* Send it out. */
 	return NF_HOOK(PF_INET, NF_IP_LOCAL_OUT, skb, NULL, rt->u.dst.dev,
-		       dst_output);
+		       ip_dst_output);
 }
 
 static inline int ip_finish_output2(struct sk_buff *skb)
@@ -283,7 +289,7 @@
 		return ip_finish_output(skb);
 }
 
-int ip_output(struct sk_buff *skb)
+static inline int ip_output2(struct sk_buff *skb)
 {
 	IP_INC_STATS(IpOutRequests);
 
@@ -294,6 +300,16 @@
 		return ip_finish_output(skb);
 }
 
+int ip_output(struct sk_buff *skb)
+{
+	int transformed = IPCB(skb)->flags & IPSKB_XFRM_TRANSFORMED;
+
+	if (transformed)
+		nf_reset(skb);
+	return NF_HOOK_COND(PF_INET, NF_IP_LOCAL_OUT, skb, NULL,
+	                    skb->dst->dev, ip_output2, transformed);
+}
+
 int ip_queue_xmit(struct sk_buff *skb, int ipfragok)
 {
 	struct sock *sk = skb->sk;
@@ -387,7 +403,7 @@
 	skb->priority = sk->sk_priority;
 
 	return NF_HOOK(PF_INET, NF_IP_LOCAL_OUT, skb, NULL, rt->u.dst.dev,
-		       dst_output);
+		       ip_dst_output);
 
 no_route:
 	IP_INC_STATS(IpOutNoRoutes);
@@ -1177,7 +1193,7 @@
 
 	/* Netfilter gets whole the not fragmented skb. */
 	err = NF_HOOK(PF_INET, NF_IP_LOCAL_OUT, skb, NULL, 
-		      skb->dst->dev, dst_output);
+		      skb->dst->dev, ip_dst_output);
 	if (err) {
 		if (err > 0)
 			err = inet->recverr ? net_xmit_errno(err) : 0;
diff -Nru a/net/ipv4/ipcomp.c b/net/ipv4/ipcomp.c
--- a/net/ipv4/ipcomp.c	Thu Mar 18 16:45:22 2004
+++ b/net/ipv4/ipcomp.c	Thu Mar 18 16:45:22 2004
@@ -231,6 +231,7 @@
 		err = -EHOSTUNREACH;
 		goto error_nolock;
 	}
+	IPCB(skb)->flags |= IPSKB_XFRM_TRANSFORMED;
 	err = NET_XMIT_BYPASS;
 
 out_exit:
diff -Nru a/net/ipv4/xfrm4_tunnel.c b/net/ipv4/xfrm4_tunnel.c
--- a/net/ipv4/xfrm4_tunnel.c	Thu Mar 18 16:45:22 2004
+++ b/net/ipv4/xfrm4_tunnel.c	Thu Mar 18 16:45:22 2004
@@ -76,6 +76,7 @@
 		err = -EHOSTUNREACH;
 		goto error_nolock;
 	}
+	IPCB(skb)->flags |= IPSKB_XFRM_TRANSFORMED;
 	return NET_XMIT_BYPASS;
 
 error_nolock:


--------------090502070304060205040206--
