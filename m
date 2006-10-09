From: paul.moore@hp.com
Subject: [PATCH 05/11] secid reconciliation: Label locally generated IPv6 traffic
Date: Mon, 09 Oct 2006 15:42:28 -0400
Message-ID: <20061009195849.188298000@hp.com>
References: <20061009194223.402695000@hp.com>
Cc: vyekkirala@TrustedCS.com, jmorris@namei.org, sds@tycho.nsa.gov
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel6.hp.com ([156.153.255.205]:40607 "EHLO atlrel6.hp.com")
	by vger.kernel.org with ESMTP id S933018AbWJIT6v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Oct 2006 15:58:51 -0400
To: netdev@vger.kernel.org, selinux@tycho.nsa.gov
Content-Disposition: inline; filename=secid-5
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Venkat Yekkirala <vyekkirala@TrustedCS.com>

This labels the skb(s) for locally generated IPv6 traffic. This will
be used in pertinent flow control checks on the outbound later in the
LSM hook.

NOTE: Forwarded traffic is already labeled with the reconciled
secmark on the inbound.

Signed-off-by: Venkat Yekkirala <vyekkirala@TrustedCS.com>
---
 include/linux/skbuff.h           |   29 +++++++++++++++++++++++++++++
 net/ipv6/ip6_output.c            |    5 +++++
 net/ipv6/netfilter/ip6t_REJECT.c |    2 ++
 3 files changed, 36 insertions(+)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 85577a4..18967f2 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -29,6 +29,7 @@ #include <linux/net.h>
 #include <linux/textsearch.h>
 #include <net/checksum.h>
 #include <linux/dmaengine.h>
+#include <net/flow.h>
 
 #define HAVE_ALLOC_SKB		/* For the drivers to know */
 #define HAVE_ALIGNABLE_SKB	/* Ditto 8)		   */
@@ -1499,5 +1500,33 @@ static inline int skb_is_gso(const struc
 	return skb_shinfo(skb)->gso_size;
 }
 
+#ifdef CONFIG_SECURITY_NETWORK
+
+static inline void security_skb_classify_skb(struct sk_buff *from,
+					struct sk_buff *skb)
+{
+	skb->secmark = from->secmark;
+}
+
+static inline void security_flow_classify_skb(struct flowi *fl,
+					struct sk_buff *skb)
+{
+	skb->secmark = fl->secid;
+}
+
+#else
+
+static inline void security_skb_classify_skb(struct sk_buff *from,
+					struct sk_buff *skb)
+{
+}
+
+static inline void security_flow_classify_skb(struct flowi *fl,
+					struct sk_buff *skb)
+{
+}
+
+#endif /* CONFIG_SECURITY_NETWORK */
+
 #endif	/* __KERNEL__ */
 #endif	/* _LINUX_SKBUFF_H */
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 6671691..6648eb3 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -170,6 +170,8 @@ int ip6_xmit(struct sock *sk, struct sk_
 	int hlimit, tclass;
 	u32 mtu;
 
+	security_flow_classify_skb(fl, skb);
+
 	if (opt) {
 		int head_room;
 
@@ -1150,6 +1152,9 @@ alloc_new_skb:
 			}
 			if (skb == NULL)
 				goto error;
+
+			security_flow_classify_skb(fl, skb);
+
 			/*
 			 *	Fill in the control structures
 			 */
diff --git a/net/ipv6/netfilter/ip6t_REJECT.c b/net/ipv6/netfilter/ip6t_REJECT.c
index 311eae8..0508c30 100644
--- a/net/ipv6/netfilter/ip6t_REJECT.c
+++ b/net/ipv6/netfilter/ip6t_REJECT.c
@@ -128,6 +128,8 @@ static void send_reset(struct sk_buff *o
 	ipv6_addr_copy(&ip6h->saddr, &oip6h->daddr);
 	ipv6_addr_copy(&ip6h->daddr, &oip6h->saddr);
 
+	security_skb_classify_skb(oldskb, nskb);
+
 	tcph = (struct tcphdr *)skb_put(nskb, sizeof(struct tcphdr));
 	/* Truncate to length (no data) */
 	tcph->doff = sizeof(struct tcphdr)/4;

--
paul moore
linux security @ hp
