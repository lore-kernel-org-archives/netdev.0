From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 05/10]: [IPV4/6]: Netfilter IPsec output hooks
Date: Fri, 11 Nov 2005 04:19:25 +0100
Message-ID: <43740DBD.1010704@trash.net>
Mime-Version: 1.0
Content-Type: text/x-patch;
 name="05.diff"
Content-Transfer-Encoding: 7bit
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Kernel Netdev Mailing List <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>
Content-Disposition: inline;
 filename="05.diff"
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

Add alternative ip_dst_output/ip6_dst_output functions to call
netfilter hooks between xfrm transforms. Packets visit
FORWARD/LOCAL_OUT->POST_ROUTING before encapsulation and
LOCAL_OUT->POST_ROUTING after each tunnel mode transform.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 193f15d5698b56a568f284a460ce38734ed84e24
tree f6032d5c28c630af1fc8a55f0e77eca749b4e87f
parent acfa963b047cbda6a8350f122da90f1e84bf4938
author Patrick McHardy <kaber@trash.net> Fri, 11 Nov 2005 02:15:08 +0100
committer Patrick McHardy <kaber@trash.net> Fri, 11 Nov 2005 02:15:08 +0100

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
