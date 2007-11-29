From: Patrick McHardy <kaber@trash.net>
Subject: [NET 01/02]: Move netfilter checksum helpers to net/core/utils.c
Date: Thu, 29 Nov 2007 10:57:35 +0100 (MET)
Message-ID: <20071129095735.11756.65348.sendpatchset@localhost.localdomain>
References: <20071129095733.11756.86966.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20071129095733.11756.86966.sendpatchset@localhost.localdomain>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[NET]: Move netfilter checksum helpers to net/core/utils.c

This allows to get rid of the CONFIG_NETFILTER dependency of NET_ACT_NAT.
This patch redefines the old names to keep the noise low, the next patch
converts all users.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 01879e49c8b53ea8cfb28f275db18ee7cbe54304
tree 3a62d0d28d01b8d3a32b1927ccf854c4af7dc1dc
parent c748e53090d0511fdecb9a91cd3619bd2d7a39f6
author Patrick McHardy <kaber@trash.net> Thu, 29 Nov 2007 10:43:11 +0100
committer Patrick McHardy <kaber@trash.net> Thu, 29 Nov 2007 10:43:11 +0100

 include/linux/netfilter.h |   25 ++++---------------------
 include/net/checksum.h    |   25 +++++++++++++++++++++++++
 net/core/utils.c          |   16 ++++++++++++++++
 net/netfilter/core.c      |   16 ----------------
 4 files changed, 45 insertions(+), 37 deletions(-)

diff --git a/include/linux/netfilter.h b/include/linux/netfilter.h
index 25fc122..e2bf6d2 100644
--- a/include/linux/netfilter.h
+++ b/include/linux/netfilter.h
@@ -298,27 +298,10 @@ extern void nf_invalidate_cache(int pf);
    Returns true or false. */
 extern int skb_make_writable(struct sk_buff *skb, unsigned int writable_len);
 
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
+#define nf_csum_replace4	csum_replace4
+#define nf_csum_replace2	csum_replace2
+#define nf_proto_csum_replace4	inet_proto_csum_replace4
+#define nf_proto_csum_replace2	inet_proto_csum_replace2
 
 struct nf_afinfo {
 	unsigned short	family;
diff --git a/include/net/checksum.h b/include/net/checksum.h
index 1242461..07602b7 100644
--- a/include/net/checksum.h
+++ b/include/net/checksum.h
@@ -93,4 +93,29 @@ static inline __wsum csum_unfold(__sum16 n)
 }
 
 #define CSUM_MANGLED_0 ((__force __sum16)0xffff)
+
+static inline void csum_replace4(__sum16 *sum, __be32 from, __be32 to)
+{
+	__be32 diff[] = { ~from, to };
+
+	*sum = csum_fold(csum_partial((char *)diff, sizeof(diff), ~csum_unfold(*sum)));
+}
+
+static inline void csum_replace2(__sum16 *sum, __be16 from, __be16 to)
+{
+	csum_replace4(sum, (__force __be32)from, (__force __be32)to);
+}
+
+struct sk_buff;
+extern void inet_proto_csum_replace4(__sum16 *sum, struct sk_buff *skb,
+				     __be32 from, __be32 to, int pseudohdr);
+
+static inline void inet_proto_csum_replace2(__sum16 *sum, struct sk_buff *skb,
+					    __be16 from, __be16 to,
+					    int pseudohdr)
+{
+	inet_proto_csum_replace4(sum, skb, (__force __be32)from,
+				 (__force __be32)to, pseudohdr);
+}
+
 #endif
diff --git a/net/core/utils.c b/net/core/utils.c
index 0bf17da..34459c4 100644
--- a/net/core/utils.c
+++ b/net/core/utils.c
@@ -293,3 +293,19 @@ out:
 }
 
 EXPORT_SYMBOL(in6_pton);
+
+void inet_proto_csum_replace4(__sum16 *sum, struct sk_buff *skb,
+			      __be32 from, __be32 to, int pseudohdr)
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
+EXPORT_SYMBOL(inet_proto_csum_replace4);
diff --git a/net/netfilter/core.c b/net/netfilter/core.c
index bed9ba0..631d269 100644
--- a/net/netfilter/core.c
+++ b/net/netfilter/core.c
@@ -217,22 +217,6 @@ int skb_make_writable(struct sk_buff *skb, unsigned int writable_len)
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
