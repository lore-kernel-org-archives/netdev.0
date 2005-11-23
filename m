From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 06/13]: [IPV4/6]: Netfilter IPsec input hooks
Date: Wed, 23 Nov 2005 19:38:24 +0900 (JST)
Message-ID: <20051123.193824.38162996.yoshfuji@linux-ipv6.org>
References: <4381F4C7.9070903@trash.net> <43826F77.7040502@miyazawa.org>
	<438270F2.3000603@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	davem@davemloft.net, kozakai@linux-ipv6.org, kazunori@miyazawa.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: kaber@trash.net
In-Reply-To: <438270F2.3000603@trash.net>
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

Hello.

In article <438270F2.3000603@trash.net> (at Tue, 22 Nov 2005 02:14:26 +0100), Patrick McHardy <kaber@trash.net> says:

> The easiest way would be to store nhoff somewhere in the skb and
> use it to continue at the next header. But I still hope there is
> a way without keeping data in the skb.

We've coded up this.

Though we have still another issue (call chain issue) to resolve,
we're getting closer to the goal.
i.e. we should continue the loop for common case.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Signed-off-by: Yasuyuki Kozawai <yasuyuki.kozakai@toshiba.co.jp>

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 8c5d600..1101851 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -272,6 +272,9 @@ struct sk_buff {
 	void			(*destructor)(struct sk_buff *skb);
 #ifdef CONFIG_NETFILTER
 	__u32			nfmark;
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+	unsigned int		nf_nhoff;
+#endif
 	struct nf_conntrack	*nfct;
 #if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
 	struct sk_buff		*nfct_reasm;
diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 44b979a..0531d0a 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -463,6 +463,8 @@ extern int			ip6_dst_lookup(struct sock 
 extern int			ip6_output(struct sk_buff *skb);
 extern int			ip6_forward(struct sk_buff *skb);
 extern int			ip6_input(struct sk_buff *skb);
+extern int			ip6_input_finish2(struct sk_buff *skb,
+						  unsigned int nhoff);
 extern int			ip6_mc_input(struct sk_buff *skb);
 
 /*
diff --git a/net/ipv6/ip6_input.c b/net/ipv6/ip6_input.c
index e84b3cd..cd0606a 100644
--- a/net/ipv6/ip6_input.c
+++ b/net/ipv6/ip6_input.c
@@ -134,31 +134,13 @@ out:
  *	Deliver the packet to the host
  */
 
-
-static inline int ip6_input_finish(struct sk_buff *skb)
+int ip6_input_finish2(struct sk_buff *skb, unsigned int nhoff)
 {
 	struct inet6_protocol *ipprot;
 	struct sock *raw_sk;
-	unsigned int nhoff;
-	int nexthdr;
+	unsigned int nexthdr;
 	u8 hash;
 
-	skb->h.raw = skb->nh.raw + sizeof(struct ipv6hdr);
-
-	/*
-	 *	Parse extension headers
-	 */
-
-	nexthdr = skb->nh.ipv6h->nexthdr;
-	nhoff = offsetof(struct ipv6hdr, nexthdr);
-
-	/* Skip hop-by-hop options, they are already parsed. */
-	if (nexthdr == NEXTHDR_HOP) {
-		nhoff = sizeof(struct ipv6hdr);
-		nexthdr = skb->h.raw[0];
-		skb->h.raw += (skb->h.raw[1]+1)<<3;
-	}
-
 	rcu_read_lock();
 resubmit:
 	if (!pskb_pull(skb, skb->h.raw - skb->data))
@@ -221,6 +203,26 @@ discard:
 	return 0;
 }
 
+static inline int ip6_input_finish(struct sk_buff *skb)
+{
+	unsigned int nhoff;
+
+	skb->h.raw = skb->nh.raw + sizeof(struct ipv6hdr);
+
+	/*
+	 *	Parse extension headers
+	 */
+
+	nhoff = offsetof(struct ipv6hdr, nexthdr);
+
+	/* Skip hop-by-hop options, they are already parsed. */
+	if (skb->nh.ipv6h->nexthdr == NEXTHDR_HOP) {
+		nhoff = sizeof(struct ipv6hdr);
+		skb->h.raw += (skb->h.raw[1]+1)<<3;
+	}
+
+	return ip6_input_finish2(skb, nhoff);
+}
 
 int ip6_input(struct sk_buff *skb)
 {
diff --git a/net/ipv6/ipv6_syms.c b/net/ipv6/ipv6_syms.c
index 1648278..6051783 100644
--- a/net/ipv6/ipv6_syms.c
+++ b/net/ipv6/ipv6_syms.c
@@ -15,6 +15,7 @@ EXPORT_SYMBOL(ndisc_mc_map);
 EXPORT_SYMBOL(register_inet6addr_notifier);
 EXPORT_SYMBOL(unregister_inet6addr_notifier);
 EXPORT_SYMBOL(ip6_route_output);
+EXPORT_SYMBOL(ip6_input_finish2);
 EXPORT_SYMBOL(addrconf_lock);
 EXPORT_SYMBOL(ipv6_setsockopt);
 EXPORT_SYMBOL(ipv6_getsockopt);
diff --git a/net/ipv6/xfrm6_input.c b/net/ipv6/xfrm6_input.c
index 9987416..2e3b28d 100644
--- a/net/ipv6/xfrm6_input.c
+++ b/net/ipv6/xfrm6_input.c
@@ -9,6 +9,7 @@
  *		IPv6 support
  */
 
+#include <linux/config.h>
 #include <linux/module.h>
 #include <linux/string.h>
 #include <linux/netfilter.h>
@@ -17,6 +18,7 @@
 #include <net/inet_ecn.h>
 #include <net/ip.h>
 #include <net/ipv6.h>
+#include <net/ip6_route.h>
 #include <net/xfrm.h>
 
 static inline void ipip6_ecn_decapsulate(struct sk_buff *skb)
@@ -28,6 +30,25 @@ static inline void ipip6_ecn_decapsulate
 		IP6_ECN_set_ce(inner_iph);
 }
 
+#ifdef CONFIG_NETFILTER
+static inline int xfrm6_rcv_spi_finish2(struct sk_buff *skb)
+{
+	__skb_pull(skb, skb->h.raw - skb->nh.raw);
+	return ip6_input_finish2(skb, skb->nf_nhoff);
+}
+
+static inline int xfrm6_rcv_spi_finish(struct sk_buff *skb)
+{
+	if (skb->dst == NULL) {
+		ip6_route_input(skb);
+		return dst_input(skb);
+	}
+
+	return NF_HOOK(PF_INET6, NF_IP6_LOCAL_IN, skb, skb->dev, NULL,
+		       xfrm6_rcv_spi_finish2);
+}
+#endif
+
 int xfrm6_rcv_spi(struct sk_buff **pskb, unsigned int *nhoffp, u32 spi)
 {
 	struct sk_buff *skb = *pskb;
@@ -136,9 +157,10 @@ int xfrm6_rcv_spi(struct sk_buff **pskb,
 #ifdef CONFIG_NETFILTER
 		skb->nh.ipv6h->payload_len = htons(skb->len);
 		__skb_push(skb, skb->data - skb->nh.raw);
+		skb->nf_nhoff = nhoff;
 
 		NF_HOOK(PF_INET6, NF_IP6_PRE_ROUTING, skb, skb->dev, NULL,
-		        ip6_rcv_finish);
+		        xfrm6_rcv_spi_finish);
 		return -1;
 #else
 		return 1;

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
