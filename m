From: Richard Weinberger <richard@nod.at>
Subject: [PATCH 3/3] x_tables: Factor out 16bit aligment ifname_compare()
Date: Sun, 11 Jan 2015 21:52:51 +0100
Message-ID: <1421009571-5279-4-git-send-email-richard@nod.at>
References: <1421009571-5279-1-git-send-email-richard@nod.at>
Cc: coreteam@netfilter.org, netfilter-devel@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	bhutchings@solarflare.com, john.fastabend@gmail.com,
	herbert@gondor.apana.org.au, vyasevic@redhat.com, jiri@resnulli.us,
	vfalico@gmail.com, therbert@google.com, edumazet@google.com,
	yoshfuji@linux-ipv6.org, jmorris@namei.org, kuznet@ms2.inr.ac.ru,
	kadlec@blackhole.kfki.hu, kaber@trash.net, pablo@netfilter.org,
	kay@vrfy.org, stephen@networkplumber.org,
	Richard Weinberger <richard@nod.at>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1421009571-5279-1-git-send-email-richard@nod.at>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

arp_tables.c has a 16bit aligment ifname_compare(), factor
it out to use it for all tables.

Signed-off-by: Richard Weinberger <richard@nod.at>
---
 include/linux/netfilter/x_tables.h | 25 ++++++++++++++++++-------
 net/ipv4/netfilter/arp_tables.c    | 37 ++-----------------------------------
 2 files changed, 20 insertions(+), 42 deletions(-)

diff --git a/include/linux/netfilter/x_tables.h b/include/linux/netfilter/x_tables.h
index 15bda23..26dddc1 100644
--- a/include/linux/netfilter/x_tables.h
+++ b/include/linux/netfilter/x_tables.h
@@ -331,14 +331,15 @@ static inline void xt_write_recseq_end(unsigned int addend)
 /*
  * This helper is performance critical and must be inlined
  */
-static inline unsigned long ifname_compare_aligned(const char *_a,
-						   const char *_b,
-						   const char *_mask)
+static inline unsigned long ifname_compare(const char *_a,
+					   const char *_b,
+					   const char *_mask)
 {
+	unsigned long ret;
+#ifdef CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS
 	const unsigned long *a = (const unsigned long *)_a;
 	const unsigned long *b = (const unsigned long *)_b;
 	const unsigned long *mask = (const unsigned long *)_mask;
-	unsigned long ret;
 
 	ret = (a[0] ^ b[0]) & mask[0];
 	if (IFNAMSIZ > sizeof(unsigned long))
@@ -348,11 +349,21 @@ static inline unsigned long ifname_compare_aligned(const char *_a,
 	if (IFNAMSIZ > 3 * sizeof(unsigned long))
 		ret |= (a[3] ^ b[3]) & mask[3];
 	BUILD_BUG_ON(IFNAMSIZ > 4 * sizeof(unsigned long));
+#else
+	const u16 *a = (const u16 *)_a;
+	const u16 *b = (const u16 *)_b;
+	const u16 *mask = (const u16 *)_mask;
+	int i;
+
+	ret = 0;
+	for (i = 0; i < IFNAMSIZ/sizeof(u16); i++)
+		ret |= (a[i] ^ b[i]) & mask[i];
+#endif
 	return ret;
 }
 
 /*
- * A wrapper around ifname_compare_aligned() to match against dev->name and
+ * A wrapper around ifname_compare() to match against dev->name and
  * dev->ifalias.
  */
 static inline unsigned long ifname_compare_all(const struct net_device *dev,
@@ -364,9 +375,9 @@ static inline unsigned long ifname_compare_all(const struct net_device *dev,
 	if (!dev)
 		goto out;
 
-	res = ifname_compare_aligned(dev->name, name, mask);
+	res = ifname_compare(dev->name, name, mask);
 	if (unlikely(dev->ifalias && res))
-		res = ifname_compare_aligned(dev->ifalias, name, mask);
+		res = ifname_compare(dev->ifalias, name, mask);
 
 out:
 	return res;
diff --git a/net/ipv4/netfilter/arp_tables.c b/net/ipv4/netfilter/arp_tables.c
index 457d4ed..c978691 100644
--- a/net/ipv4/netfilter/arp_tables.c
+++ b/net/ipv4/netfilter/arp_tables.c
@@ -76,39 +76,6 @@ static inline int arp_devaddr_compare(const struct arpt_devaddr_info *ap,
 	return ret != 0;
 }
 
-/*
- * Unfortunately, _b and _mask are not aligned to an int (or long int)
- * Some arches dont care, unrolling the loop is a win on them.
- * For other arches, we only have a 16bit alignement.
- */
-static unsigned long ifname_compare(const struct net_device *dev,
-				    const char *_b, const char *_mask)
-{
-#ifdef CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS
-	unsigned long ret = ifname_compare_all(dev, _b, _mask);
-#else
-	unsigned long ret = 0;
-	const u16 *a = (const u16 *)dev->name;
-	const u16 *b = (const u16 *)_b;
-	const u16 *mask = (const u16 *)_mask;
-	int i;
-
-	for (i = 0; i < IFNAMSIZ/sizeof(u16); i++)
-		ret |= (a[i] ^ b[i]) & mask[i];
-
-	if (likely(!(dev->ifalias && ret)))
-		goto out;
-
-	ret = 0;
-	a = (const u16 *)dev->ifalias;
-	for (i = 0; i < IFNAMSIZ/sizeof(u16); i++)
-		ret |= (a[i] ^ b[i]) & mask[i];
-
-out:
-#endif
-	return ret;
-}
-
 /* Returns whether packet matches rule or not. */
 static inline int arp_packet_match(const struct arphdr *arphdr,
 				   struct net_device *dev,
@@ -192,7 +159,7 @@ static inline int arp_packet_match(const struct arphdr *arphdr,
 	}
 
 	/* Look for ifname matches.  */
-	ret = ifname_compare(indev, arpinfo->iniface, arpinfo->iniface_mask);
+	ret = ifname_compare_all(indev, arpinfo->iniface, arpinfo->iniface_mask);
 
 	if (FWINV(ret != 0, ARPT_INV_VIA_IN)) {
 		dprintf("VIA in mismatch (%s vs %s).%s\n",
@@ -201,7 +168,7 @@ static inline int arp_packet_match(const struct arphdr *arphdr,
 		return 0;
 	}
 
-	ret = ifname_compare(outdev, arpinfo->outiface, arpinfo->outiface_mask);
+	ret = ifname_compare_all(outdev, arpinfo->outiface, arpinfo->outiface_mask);
 
 	if (FWINV(ret != 0, ARPT_INV_VIA_OUT)) {
 		dprintf("VIA out mismatch (%s vs %s).%s\n",
-- 
1.8.4.5
