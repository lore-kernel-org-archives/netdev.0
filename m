From: kaber@trash.net
Subject: [PATCH 37/84] netfilter: ipv4: use NFPROTO values for NF_HOOK invocation
Date: Mon, 10 May 2010 22:18:08 +0200
Message-ID: <1273522735-24672-38-git-send-email-kaber@trash.net>
References: <1273522735-24672-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1273522735-24672-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jan Engelhardt <jengelh@medozas.de>

The semantic patch that was used:
// <smpl>
@@
@@
(NF_HOOK
|NF_HOOK_COND
|nf_hook
)(
-PF_INET,
+NFPROTO_IPV4,
 ...)
// </smpl>

Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
---
 net/ipv4/ip_forward.c   |    4 ++--
 net/ipv4/ip_input.c     |    4 ++--
 net/ipv4/ip_output.c    |   18 +++++++++---------
 net/ipv4/ipmr.c         |    2 +-
 net/ipv4/raw.c          |    4 ++--
 net/ipv4/xfrm4_input.c  |    2 +-
 net/ipv4/xfrm4_output.c |    2 +-
 7 files changed, 18 insertions(+), 18 deletions(-)

diff --git a/net/ipv4/ip_forward.c b/net/ipv4/ip_forward.c
index a2991bc..9f2cd47 100644
--- a/net/ipv4/ip_forward.c
+++ b/net/ipv4/ip_forward.c
@@ -111,8 +111,8 @@ int ip_forward(struct sk_buff *skb)
 
 	skb->priority = rt_tos2priority(iph->tos);
 
-	return NF_HOOK(PF_INET, NF_INET_FORWARD, skb, skb->dev, rt->u.dst.dev,
-		       ip_forward_finish);
+	return NF_HOOK(NFPROTO_IPV4, NF_INET_FORWARD, skb, skb->dev,
+		       rt->u.dst.dev, ip_forward_finish);
 
 sr_failed:
 	/*
diff --git a/net/ipv4/ip_input.c b/net/ipv4/ip_input.c
index c29de98..091b5c7 100644
--- a/net/ipv4/ip_input.c
+++ b/net/ipv4/ip_input.c
@@ -265,7 +265,7 @@ int ip_local_deliver(struct sk_buff *skb)
 			return 0;
 	}
 
-	return NF_HOOK(PF_INET, NF_INET_LOCAL_IN, skb, skb->dev, NULL,
+	return NF_HOOK(NFPROTO_IPV4, NF_INET_LOCAL_IN, skb, skb->dev, NULL,
 		       ip_local_deliver_finish);
 }
 
@@ -443,7 +443,7 @@ int ip_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt,
 	/* Must drop socket now because of tproxy. */
 	skb_orphan(skb);
 
-	return NF_HOOK(PF_INET, NF_INET_PRE_ROUTING, skb, dev, NULL,
+	return NF_HOOK(NFPROTO_IPV4, NF_INET_PRE_ROUTING, skb, dev, NULL,
 		       ip_rcv_finish);
 
 inhdr_error:
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 3451799..f09135e 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -95,8 +95,8 @@ int __ip_local_out(struct sk_buff *skb)
 
 	iph->tot_len = htons(skb->len);
 	ip_send_check(iph);
-	return nf_hook(PF_INET, NF_INET_LOCAL_OUT, skb, NULL, skb_dst(skb)->dev,
-		       dst_output);
+	return nf_hook(NFPROTO_IPV4, NF_INET_LOCAL_OUT, skb, NULL,
+		       skb_dst(skb)->dev, dst_output);
 }
 
 int ip_local_out(struct sk_buff *skb)
@@ -271,8 +271,8 @@ int ip_mc_output(struct sk_buff *skb)
 		   ) {
 			struct sk_buff *newskb = skb_clone(skb, GFP_ATOMIC);
 			if (newskb)
-				NF_HOOK(PF_INET, NF_INET_POST_ROUTING, newskb,
-					NULL, newskb->dev,
+				NF_HOOK(NFPROTO_IPV4, NF_INET_POST_ROUTING,
+					newskb, NULL, newskb->dev,
 					ip_dev_loopback_xmit);
 		}
 
@@ -287,12 +287,12 @@ int ip_mc_output(struct sk_buff *skb)
 	if (rt->rt_flags&RTCF_BROADCAST) {
 		struct sk_buff *newskb = skb_clone(skb, GFP_ATOMIC);
 		if (newskb)
-			NF_HOOK(PF_INET, NF_INET_POST_ROUTING, newskb, NULL,
-				newskb->dev, ip_dev_loopback_xmit);
+			NF_HOOK(NFPROTO_IPV4, NF_INET_POST_ROUTING, newskb,
+				NULL, newskb->dev, ip_dev_loopback_xmit);
 	}
 
-	return NF_HOOK_COND(PF_INET, NF_INET_POST_ROUTING, skb, NULL, skb->dev,
-			    ip_finish_output,
+	return NF_HOOK_COND(NFPROTO_IPV4, NF_INET_POST_ROUTING, skb, NULL,
+			    skb->dev, ip_finish_output,
 			    !(IPCB(skb)->flags & IPSKB_REROUTED));
 }
 
@@ -305,7 +305,7 @@ int ip_output(struct sk_buff *skb)
 	skb->dev = dev;
 	skb->protocol = htons(ETH_P_IP);
 
-	return NF_HOOK_COND(PF_INET, NF_INET_POST_ROUTING, skb, NULL, dev,
+	return NF_HOOK_COND(NFPROTO_IPV4, NF_INET_POST_ROUTING, skb, NULL, dev,
 			    ip_finish_output,
 			    !(IPCB(skb)->flags & IPSKB_REROUTED));
 }
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 8582e12..1d42f61 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -1319,7 +1319,7 @@ static void ipmr_queue_xmit(struct sk_buff *skb, struct mfc_cache *c, int vifi)
 	 * not mrouter) cannot join to more than one interface - it will
 	 * result in receiving multiple packets.
 	 */
-	NF_HOOK(PF_INET, NF_INET_FORWARD, skb, skb->dev, dev,
+	NF_HOOK(NFPROTO_IPV4, NF_INET_FORWARD, skb, skb->dev, dev,
 		ipmr_forward_finish);
 	return;
 
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index ce154b4..34d9adb 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -382,8 +382,8 @@ static int raw_send_hdrinc(struct sock *sk, void *from, size_t length,
 		icmp_out_count(net, ((struct icmphdr *)
 			skb_transport_header(skb))->type);
 
-	err = NF_HOOK(PF_INET, NF_INET_LOCAL_OUT, skb, NULL, rt->u.dst.dev,
-		      dst_output);
+	err = NF_HOOK(NFPROTO_IPV4, NF_INET_LOCAL_OUT, skb, NULL,
+		      rt->u.dst.dev, dst_output);
 	if (err > 0)
 		err = net_xmit_errno(err);
 	if (err)
diff --git a/net/ipv4/xfrm4_input.c b/net/ipv4/xfrm4_input.c
index f9f922a..c3969e0 100644
--- a/net/ipv4/xfrm4_input.c
+++ b/net/ipv4/xfrm4_input.c
@@ -60,7 +60,7 @@ int xfrm4_transport_finish(struct sk_buff *skb, int async)
 	iph->tot_len = htons(skb->len);
 	ip_send_check(iph);
 
-	NF_HOOK(PF_INET, NF_INET_PRE_ROUTING, skb, skb->dev, NULL,
+	NF_HOOK(NFPROTO_IPV4, NF_INET_PRE_ROUTING, skb, skb->dev, NULL,
 		xfrm4_rcv_encap_finish);
 	return 0;
 }
diff --git a/net/ipv4/xfrm4_output.c b/net/ipv4/xfrm4_output.c
index c908bd9..571aa96 100644
--- a/net/ipv4/xfrm4_output.c
+++ b/net/ipv4/xfrm4_output.c
@@ -86,7 +86,7 @@ static int xfrm4_output_finish(struct sk_buff *skb)
 
 int xfrm4_output(struct sk_buff *skb)
 {
-	return NF_HOOK_COND(PF_INET, NF_INET_POST_ROUTING, skb,
+	return NF_HOOK_COND(NFPROTO_IPV4, NF_INET_POST_ROUTING, skb,
 			    NULL, skb_dst(skb)->dev, xfrm4_output_finish,
 			    !(IPCB(skb)->flags & IPSKB_REROUTED));
 }
-- 
1.7.0.4

