From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [PKT_SCHED]: Add stateless NAT
Date: Thu, 27 Sep 2007 17:10:08 +0400
Message-ID: <20070927131008.GA15997@2ka.mipt.ru>
References: <20070927073446.GA14643@gondor.apana.org.au> <20070927092512.GD29329@2ka.mipt.ru> <20070927093358.GA15357@gondor.apana.org.au> <20070927100753.GA22323@2ka.mipt.ru> <20070927102916.GA15749@gondor.apana.org.au> <20070927124120.GA8897@2ka.mipt.ru> <20070927124515.GA16706@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	jamal <hadi@cyberus.ca>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:35020 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754118AbXI0NLD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Sep 2007 09:11:03 -0400
Content-Disposition: inline
In-Reply-To: <20070927124515.GA16706@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 27, 2007 at 08:45:15PM +0800, Herbert Xu (herbert@gondor.apana.org.au) wrote:
> On Thu, Sep 27, 2007 at 04:41:21PM +0400, Evgeniy Polyakov wrote:
> >
> > I've attached simple patch which moves checksum helpers out of
> > CONFIG_NETFILTER option but still in the same linux/netfilter.h header.
> > This should be enough for removing 'select NETFILTER' in your patch.
> 
> Close but no cigar :)

:) take 2.

diff --git a/include/linux/netfilter.h b/include/linux/netfilter.h
index 1dd075e..5313739 100644
--- a/include/linux/netfilter.h
+++ b/include/linux/netfilter.h
@@ -40,6 +40,41 @@
 #endif
 
 #ifdef __KERNEL__
+
+static inline void nf_csum_replace4(__sum16 *sum, __be32 from, __be32 to)
+{
+	__be32 diff[] = { ~from, to };
+
+	*sum = csum_fold(csum_partial((char *)diff, sizeof(diff), ~csum_unfold(*sum)));
+}
+
+static inline void nf_csum_replace2(__sum16 *sum, __be16 from, __be16 to)
+{
+	nf_csum_replace4(sum, (__force __be32)from, (__force __be32)to);
+}
+
+static inline void nf_proto_csum_replace4(__sum16 *sum, struct sk_buff *skb,
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
+
+static inline void nf_proto_csum_replace2(__sum16 *sum, struct sk_buff *skb,
+				      __be16 from, __be16 to, int pseudohdr)
+{
+	nf_proto_csum_replace4(sum, skb, (__force __be32)from,
+				(__force __be32)to, pseudohdr);
+}
+
 #ifdef CONFIG_NETFILTER
 
 extern void netfilter_init(void);
@@ -289,28 +324,6 @@ extern void nf_invalidate_cache(int pf);
    Returns true or false. */
 extern int skb_make_writable(struct sk_buff **pskb, unsigned int writable_len);
 
-static inline void nf_csum_replace4(__sum16 *sum, __be32 from, __be32 to)
-{
-	__be32 diff[] = { ~from, to };
-
-	*sum = csum_fold(csum_partial((char *)diff, sizeof(diff), ~csum_unfold(*sum)));
-}
-
-static inline void nf_csum_replace2(__sum16 *sum, __be16 from, __be16 to)
-{
-	nf_csum_replace4(sum, (__force __be32)from, (__force __be32)to);
-}
-
-extern void nf_proto_csum_replace4(__sum16 *sum, struct sk_buff *skb,
-				      __be32 from, __be32 to, int pseudohdr);
-
-static inline void nf_proto_csum_replace2(__sum16 *sum, struct sk_buff *skb,
-				      __be16 from, __be16 to, int pseudohdr)
-{
-	nf_proto_csum_replace4(sum, skb, (__force __be32)from,
-				(__force __be32)to, pseudohdr);
-}
-
 struct nf_afinfo {
 	unsigned short	family;
 	__sum16		(*checksum)(struct sk_buff *skb, unsigned int hook,
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
