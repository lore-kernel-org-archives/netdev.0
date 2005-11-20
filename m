From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 05/13]: [IPV4/6]: Netfilter IPsec output hooks
Date: Sun, 20 Nov 2005 17:31:34 +0100
Message-ID: <20051120163134.16666.9265.sendpatchset@localhost.localdomain>
References: <20051120163128.16666.38111.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: davem@davemloft.net
In-Reply-To: <20051120163128.16666.38111.sendpatchset@localhost.localdomain>
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

[IPV4/6]: Netfilter IPsec output hooks

Add alternative ip_dst_output/ip6_dst_output functions to call netfilter
hooks between xfrm transforms. Packets visit the FORWARD/LOCAL_OUT and
POST_ROUTING hook before encapsulation and the LOCAL_OUT and POST_ROUTING
hook after each tunnel mode transform.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit b847425c693f43a63137d18e36e5c8cf0187c175
tree a811e8c573150bc279a9df53958270f25cb531bc
parent 73f59ffcebcd0a08f6a405c8522074e8b5892b73
author Patrick McHardy <kaber@trash.net> Sat, 19 Nov 2005 21:49:58 +0100
committer Patrick McHardy <kaber@trash.net> Sat, 19 Nov 2005 21:49:58 +0100

 include/net/dst.h       |    5 +++++
 net/ipv4/netfilter.c    |   31 ++++++++++++++++++++++++++++++-
 net/ipv4/xfrm4_output.c |    1 +
 net/ipv6/netfilter.c    |   29 +++++++++++++++++++++++++++++
 net/ipv6/xfrm6_output.c |    1 +
 5 files changed, 66 insertions(+), 1 deletions(-)

diff --git a/include/net/dst.h b/include/net/dst.h
index 4886f25..7eadd0c 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -236,8 +236,13 @@ static inline int dst_output(struct sk_b
 	}
 }
 
+#if defined(CONFIG_XFRM) && defined(CONFIG_NETFILTER)
+extern int ip_dst_output(struct sk_buff *skb);
+extern int ip6_dst_output(struct sk_buff *skb);
+#else
 #define ip_dst_output	dst_output
 #define ip6_dst_output	dst_output
+#endif
 
 /* Input packet from network to transport.  */
 static inline int dst_input(struct sk_buff *skb)
diff --git a/net/ipv4/netfilter.c b/net/ipv4/netfilter.c
index ae0779d..b93e7cd 100644
--- a/net/ipv4/netfilter.c
+++ b/net/ipv4/netfilter.c
@@ -10,8 +10,9 @@
 #include <linux/tcp.h>
 #include <linux/udp.h>
 #include <linux/icmp.h>
-#include <net/route.h>
 #include <linux/ip.h>
+#include <net/route.h>
+#include <net/xfrm.h>
 
 /* route_me_harder function, used by iptable_nat, iptable_mangle + ip_queue */
 int ip_route_me_harder(struct sk_buff **pskb)
@@ -78,6 +79,34 @@ int ip_route_me_harder(struct sk_buff **
 }
 EXPORT_SYMBOL(ip_route_me_harder);
 
+#ifdef CONFIG_XFRM
+static inline int __ip_dst_output(struct sk_buff *skb)
+{
+	int err;
+
+	do {
+		err = skb->dst->output(skb);
+
+		if (likely(err == 0))
+			return err;
+		if (unlikely(err != NET_XMIT_BYPASS))
+			return err;
+	} while (skb->dst->xfrm && !skb->dst->xfrm->props.mode);
+
+	return NF_HOOK(PF_INET, NF_IP_LOCAL_OUT, skb, NULL, skb->dst->dev,
+	               ip_dst_output);
+}
+
+int ip_dst_output(struct sk_buff *skb)
+{
+	if (skb->dst->xfrm != NULL)
+		return NF_HOOK(PF_INET, NF_IP_POST_ROUTING, skb, NULL,
+		               skb->dst->dev, __ip_dst_output);
+	return dst_output(skb);
+}
+EXPORT_SYMBOL(ip_dst_output);
+#endif /* CONFIG_XFRM */
+
 /*
  * Extra routing may needed on local out, as the QUEUE target never
  * returns control to the table.
diff --git a/net/ipv4/xfrm4_output.c b/net/ipv4/xfrm4_output.c
index 66620a9..c135746 100644
--- a/net/ipv4/xfrm4_output.c
+++ b/net/ipv4/xfrm4_output.c
@@ -133,6 +133,7 @@ int xfrm4_output(struct sk_buff *skb)
 		err = -EHOSTUNREACH;
 		goto error_nolock;
 	}
+	nf_reset(skb);
 	err = NET_XMIT_BYPASS;
 
 out_exit:
diff --git a/net/ipv6/netfilter.c b/net/ipv6/netfilter.c
index f8626eb..06b275e 100644
--- a/net/ipv6/netfilter.c
+++ b/net/ipv6/netfilter.c
@@ -10,6 +10,7 @@
 #include <net/dst.h>
 #include <net/ipv6.h>
 #include <net/ip6_route.h>
+#include <net/xfrm.h>
 
 int ip6_route_me_harder(struct sk_buff *skb)
 {
@@ -41,6 +42,34 @@ int ip6_route_me_harder(struct sk_buff *
 }
 EXPORT_SYMBOL(ip6_route_me_harder);
 
+#ifdef CONFIG_XFRM
+static inline int __ip6_dst_output(struct sk_buff *skb)
+{
+	int err;
+	
+	do {
+		err = skb->dst->output(skb);
+
+		if (likely(err == 0))
+			return err;
+		if (unlikely(err != NET_XMIT_BYPASS))
+			return err;
+	} while (skb->dst->xfrm && !skb->dst->xfrm->props.mode);
+
+	return NF_HOOK(PF_INET6, NF_IP6_LOCAL_OUT, skb, NULL, skb->dst->dev,
+	               ip6_dst_output);
+}
+
+int ip6_dst_output(struct sk_buff *skb)
+{
+	if (skb->dst->xfrm != NULL)
+		return NF_HOOK(PF_INET6, NF_IP6_POST_ROUTING, skb, NULL,
+		               skb->dst->dev, __ip6_dst_output);
+	return dst_output(skb);
+}
+EXPORT_SYMBOL(ip6_dst_output);
+#endif /* CONFIG_XFRM */
+
 /*
  * Extra routing may needed on local out, as the QUEUE target never
  * returns control to the table.
diff --git a/net/ipv6/xfrm6_output.c b/net/ipv6/xfrm6_output.c
index 6b98677..a566d25 100644
--- a/net/ipv6/xfrm6_output.c
+++ b/net/ipv6/xfrm6_output.c
@@ -132,6 +132,7 @@ int xfrm6_output(struct sk_buff *skb)
 		err = -EHOSTUNREACH;
 		goto error_nolock;
 	}
+	nf_reset(skb);
 	err = NET_XMIT_BYPASS;
 
 out_exit:
