From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [PKT_SCHED]: Add stateless NAT
Date: Fri, 28 Sep 2007 13:16:43 +0400
Message-ID: <20070928091643.GA16484@2ka.mipt.ru>
References: <20070927132037.GA17056@gondor.apana.org.au> <20070927132941.GB25353@2ka.mipt.ru> <46FBB296.8020901@trash.net> <20070927.125239.129764503.davem@davemloft.net> <20070928081918.GB2304@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kaber@trash.net, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, hadi@cyberus.ca
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:49904 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760818AbXI1JRc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Sep 2007 05:17:32 -0400
Content-Disposition: inline
In-Reply-To: <20070928081918.GB2304@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 28, 2007 at 12:19:19PM +0400, Evgeniy Polyakov (johnpol@2ka.mipt.ru) wrote:
> > I still think the nf_*() prefixes should all go and the extern
> > prototypes should go into an independant header file.
> > 
> > These are not netfilter routines, they are "INET" helpers.
> > 
> > And we should make similar treatment for all of the ipv6
> > packet parser helper functions that ipv6 netfilter needs.
> 
> Should netfilter still have own nf_ prefixed functions which will just
> call the same ones without prefix from inet header?

Kind of.

diff --git a/include/linux/netfilter.h b/include/linux/netfilter.h
index 1dd075e..befdb82 100644
--- a/include/linux/netfilter.h
+++ b/include/linux/netfilter.h
@@ -291,9 +291,7 @@ extern int skb_make_writable(struct sk_buff **pskb, unsigned int writable_len);
 
 static inline void nf_csum_replace4(__sum16 *sum, __be32 from, __be32 to)
 {
-	__be32 diff[] = { ~from, to };
-
-	*sum = csum_fold(csum_partial((char *)diff, sizeof(diff), ~csum_unfold(*sum)));
+	csum_replace(sum, from, to);
 }
 
 static inline void nf_csum_replace2(__sum16 *sum, __be16 from, __be16 to)
@@ -301,13 +299,17 @@ static inline void nf_csum_replace2(__sum16 *sum, __be16 from, __be16 to)
 	nf_csum_replace4(sum, (__force __be32)from, (__force __be32)to);
 }
 
-extern void nf_proto_csum_replace4(__sum16 *sum, struct sk_buff *skb,
-				      __be32 from, __be32 to, int pseudohdr);
+static inline void nf_proto_csum_replace4(__sum16 *sum, struct sk_buff *skb,
+			    __be32 from, __be32 to, int pseudohdr)
+{
+	proto_csum_replace(sum, skb, (__force __be32)from,
+				(__force __be32)to, pseudohdr);
+}
 
 static inline void nf_proto_csum_replace2(__sum16 *sum, struct sk_buff *skb,
 				      __be16 from, __be16 to, int pseudohdr)
 {
-	nf_proto_csum_replace4(sum, skb, (__force __be32)from,
+	proto_csum_replace(sum, skb, (__force __be32)from,
 				(__force __be32)to, pseudohdr);
 }
 
diff --git a/include/linux/netfilter_ipv6.h b/include/linux/netfilter_ipv6.h
index 66ca8e3..e0561ea 100644
--- a/include/linux/netfilter_ipv6.h
+++ b/include/linux/netfilter_ipv6.h
@@ -72,8 +72,11 @@ enum nf_ip6_hook_priorities {
 
 #ifdef CONFIG_NETFILTER
 extern int ip6_route_me_harder(struct sk_buff *skb);
-extern __sum16 nf_ip6_checksum(struct sk_buff *skb, unsigned int hook,
-				    unsigned int dataoff, u_int8_t protocol);
+static inline __sum16 nf_ip6_checksum(struct sk_buff *skb, unsigned int hook,
+				    unsigned int dataoff, u_int8_t protocol)
+{
+	return ip6_checksum(skb, hook, dataoff, protocol);
+}
 
 extern int ipv6_netfilter_init(void);
 extern void ipv6_netfilter_fini(void);
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index a656cec..95ad5af 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1788,5 +1788,11 @@ static inline void skb_forward_csum(struct sk_buff *skb)
 		skb->ip_summed = CHECKSUM_NONE;
 }
 
+extern void proto_csum_replace(__sum16 *sum, struct sk_buff *skb,
+				      __be32 from, __be32 to, int pseudohdr);
+
+extern __sum16 ip6_checksum(struct sk_buff *skb, unsigned int hook,
+			     unsigned int dataoff, u_int8_t protocol);
+
 #endif	/* __KERNEL__ */
 #endif	/* _LINUX_SKBUFF_H */
diff --git a/include/net/checksum.h b/include/net/checksum.h
index 1242461..8602189 100644
--- a/include/net/checksum.h
+++ b/include/net/checksum.h
@@ -93,4 +93,12 @@ static inline __wsum csum_unfold(__sum16 n)
 }
 
 #define CSUM_MANGLED_0 ((__force __sum16)0xffff)
+
+static inline void csum_replace(__sum16 *sum, __be32 from, __be32 to)
+{
+	__be32 diff[] = { ~from, to };
+
+	*sum = csum_fold(csum_partial((char *)diff, sizeof(diff), ~csum_unfold(*sum)));
+}
+
 #endif
diff --git a/net/core/utils.c b/net/core/utils.c
index 0bf17da..17576c8 100644
--- a/net/core/utils.c
+++ b/net/core/utils.c
@@ -293,3 +293,54 @@ out:
 }
 
 EXPORT_SYMBOL(in6_pton);
+
+void proto_csum_replace(__sum16 *sum, struct sk_buff *skb,
+			    __be32 from, __be32 to, int pseudohdr)
+{
+	__be32 diff[] = { ~from, to };
+	if (skb->ip_summed != CHECKSUM_PARTIAL) {
+		*sum = csum_fold(csum_partial(diff, sizeof(diff),
+				~csum_unfold(*sum)));
+		if (skb->ip_summed == CHECKSUM_COMPLETE && pseudohdr)
+			skb->csum = ~csum_partial(diff, sizeof(diff),
+						~skb->csum);
+	} else if (pseudohdr)
+		*sum = ~csum_fold(csum_partial(diff, sizeof(diff),
+				csum_unfold(*sum)));
+}
+EXPORT_SYMBOL(proto_csum_replace);
+
+__sum16 ip6_checksum(struct sk_buff *skb, unsigned int hook,
+			     unsigned int dataoff, u_int8_t protocol)
+{
+	struct ipv6hdr *ip6h = ipv6_hdr(skb);
+	__sum16 csum = 0;
+
+	switch (skb->ip_summed) {
+	case CHECKSUM_COMPLETE:
+		if (hook != NF_IP6_PRE_ROUTING && hook != NF_IP6_LOCAL_IN)
+			break;
+		if (!csum_ipv6_magic(&ip6h->saddr, &ip6h->daddr,
+				     skb->len - dataoff, protocol,
+				     csum_sub(skb->csum,
+					      skb_checksum(skb, 0,
+							   dataoff, 0)))) {
+			skb->ip_summed = CHECKSUM_UNNECESSARY;
+			break;
+		}
+		/* fall through */
+	case CHECKSUM_NONE:
+		skb->csum = ~csum_unfold(
+				csum_ipv6_magic(&ip6h->saddr, &ip6h->daddr,
+					     skb->len - dataoff,
+					     protocol,
+					     csum_sub(0,
+						      skb_checksum(skb, 0,
+								   dataoff, 0))));
+		csum = __skb_checksum_complete(skb);
+	}
+	return csum;
+}
+
+EXPORT_SYMBOL(ip6_checksum);
+
diff --git a/net/ipv6/netfilter.c b/net/ipv6/netfilter.c
index 38b1496..be43559 100644
--- a/net/ipv6/netfilter.c
+++ b/net/ipv6/netfilter.c
@@ -81,40 +81,6 @@ static int nf_ip6_reroute(struct sk_buff **pskb, const struct nf_info *info)
 	return 0;
 }
 
-__sum16 nf_ip6_checksum(struct sk_buff *skb, unsigned int hook,
-			     unsigned int dataoff, u_int8_t protocol)
-{
-	struct ipv6hdr *ip6h = ipv6_hdr(skb);
-	__sum16 csum = 0;
-
-	switch (skb->ip_summed) {
-	case CHECKSUM_COMPLETE:
-		if (hook != NF_IP6_PRE_ROUTING && hook != NF_IP6_LOCAL_IN)
-			break;
-		if (!csum_ipv6_magic(&ip6h->saddr, &ip6h->daddr,
-				     skb->len - dataoff, protocol,
-				     csum_sub(skb->csum,
-					      skb_checksum(skb, 0,
-							   dataoff, 0)))) {
-			skb->ip_summed = CHECKSUM_UNNECESSARY;
-			break;
-		}
-		/* fall through */
-	case CHECKSUM_NONE:
-		skb->csum = ~csum_unfold(
-				csum_ipv6_magic(&ip6h->saddr, &ip6h->daddr,
-					     skb->len - dataoff,
-					     protocol,
-					     csum_sub(0,
-						      skb_checksum(skb, 0,
-								   dataoff, 0))));
-		csum = __skb_checksum_complete(skb);
-	}
-	return csum;
-}
-
-EXPORT_SYMBOL(nf_ip6_checksum);
-
 static struct nf_afinfo nf_ip6_afinfo = {
 	.family		= AF_INET6,
 	.checksum	= nf_ip6_checksum,
diff --git a/net/netfilter/core.c b/net/netfilter/core.c
index 381a77c..9ffbbe2 100644
--- a/net/netfilter/core.c
+++ b/net/netfilter/core.c
@@ -226,22 +226,6 @@ copy_skb:
 }
 EXPORT_SYMBOL(skb_make_writable);
 
-void nf_proto_csum_replace4(__sum16 *sum, struct sk_buff *skb,
-			    __be32 from, __be32 to, int pseudohdr)
-{
-	__be32 diff[] = { ~from, to };
-	if (skb->ip_summed != CHECKSUM_PARTIAL) {
-		*sum = csum_fold(csum_partial(diff, sizeof(diff),
-				~csum_unfold(*sum)));
-		if (skb->ip_summed == CHECKSUM_COMPLETE && pseudohdr)
-			skb->csum = ~csum_partial(diff, sizeof(diff),
-						~skb->csum);
-	} else if (pseudohdr)
-		*sum = ~csum_fold(csum_partial(diff, sizeof(diff),
-				csum_unfold(*sum)));
-}
-EXPORT_SYMBOL(nf_proto_csum_replace4);
-
 #if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
 /* This does not belong here, but locally generated errors need it if connection
    tracking in use: without this, connection may not be in hash table, and hence

-- 
	Evgeniy Polyakov
