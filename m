From: Richard Weinberger <richard@nod.at>
Subject: [PATCH 2/3] x_tables: Use also dev->ifalias for interface matching
Date: Sun, 11 Jan 2015 21:52:50 +0100
Message-ID: <1421009571-5279-3-git-send-email-richard@nod.at>
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

Signed-off-by: Richard Weinberger <richard@nod.at>
---
 include/linux/netfilter/x_tables.h | 22 ++++++++++++++++++++++
 net/ipv4/netfilter/arp_tables.c    | 28 +++++++++++++++++-----------
 net/ipv4/netfilter/ip_tables.c     | 15 +++++----------
 net/ipv6/netfilter/ip6_tables.c    | 18 +++++++-----------
 net/netfilter/xt_physdev.c         |  9 ++-------
 5 files changed, 53 insertions(+), 39 deletions(-)

diff --git a/include/linux/netfilter/x_tables.h b/include/linux/netfilter/x_tables.h
index a3e215b..15bda23 100644
--- a/include/linux/netfilter/x_tables.h
+++ b/include/linux/netfilter/x_tables.h
@@ -351,6 +351,28 @@ static inline unsigned long ifname_compare_aligned(const char *_a,
 	return ret;
 }
 
+/*
+ * A wrapper around ifname_compare_aligned() to match against dev->name and
+ * dev->ifalias.
+ */
+static inline unsigned long ifname_compare_all(const struct net_device *dev,
+					       const char *name,
+					       const char *mask)
+{
+	unsigned long res = 0;
+
+	if (!dev)
+		goto out;
+
+	res = ifname_compare_aligned(dev->name, name, mask);
+	if (unlikely(dev->ifalias && res))
+		res = ifname_compare_aligned(dev->ifalias, name, mask);
+
+out:
+	return res;
+}
+
+
 struct nf_hook_ops *xt_hook_link(const struct xt_table *, nf_hookfn *);
 void xt_hook_unlink(const struct xt_table *, struct nf_hook_ops *);
 
diff --git a/net/ipv4/netfilter/arp_tables.c b/net/ipv4/netfilter/arp_tables.c
index f95b6f9..457d4ed 100644
--- a/net/ipv4/netfilter/arp_tables.c
+++ b/net/ipv4/netfilter/arp_tables.c
@@ -81,19 +81,30 @@ static inline int arp_devaddr_compare(const struct arpt_devaddr_info *ap,
  * Some arches dont care, unrolling the loop is a win on them.
  * For other arches, we only have a 16bit alignement.
  */
-static unsigned long ifname_compare(const char *_a, const char *_b, const char *_mask)
+static unsigned long ifname_compare(const struct net_device *dev,
+				    const char *_b, const char *_mask)
 {
 #ifdef CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS
-	unsigned long ret = ifname_compare_aligned(_a, _b, _mask);
+	unsigned long ret = ifname_compare_all(dev, _b, _mask);
 #else
 	unsigned long ret = 0;
-	const u16 *a = (const u16 *)_a;
+	const u16 *a = (const u16 *)dev->name;
 	const u16 *b = (const u16 *)_b;
 	const u16 *mask = (const u16 *)_mask;
 	int i;
 
 	for (i = 0; i < IFNAMSIZ/sizeof(u16); i++)
 		ret |= (a[i] ^ b[i]) & mask[i];
+
+	if (likely(!(dev->ifalias && ret)))
+		goto out;
+
+	ret = 0;
+	a = (const u16 *)dev->ifalias;
+	for (i = 0; i < IFNAMSIZ/sizeof(u16); i++)
+		ret |= (a[i] ^ b[i]) & mask[i];
+
+out:
 #endif
 	return ret;
 }
@@ -101,8 +112,8 @@ static unsigned long ifname_compare(const char *_a, const char *_b, const char *
 /* Returns whether packet matches rule or not. */
 static inline int arp_packet_match(const struct arphdr *arphdr,
 				   struct net_device *dev,
-				   const char *indev,
-				   const char *outdev,
+				   const struct net_device *indev,
+				   const struct net_device *outdev,
 				   const struct arpt_arp *arpinfo)
 {
 	const char *arpptr = (char *)(arphdr + 1);
@@ -252,11 +263,9 @@ unsigned int arpt_do_table(struct sk_buff *skb,
 			   const struct net_device *out,
 			   struct xt_table *table)
 {
-	static const char nulldevname[IFNAMSIZ] __attribute__((aligned(sizeof(long))));
 	unsigned int verdict = NF_DROP;
 	const struct arphdr *arp;
 	struct arpt_entry *e, *back;
-	const char *indev, *outdev;
 	void *table_base;
 	const struct xt_table_info *private;
 	struct xt_action_param acpar;
@@ -265,9 +274,6 @@ unsigned int arpt_do_table(struct sk_buff *skb,
 	if (!pskb_may_pull(skb, arp_hdr_len(skb->dev)))
 		return NF_DROP;
 
-	indev = in ? in->name : nulldevname;
-	outdev = out ? out->name : nulldevname;
-
 	local_bh_disable();
 	addend = xt_write_recseq_begin();
 	private = table->private;
@@ -291,7 +297,7 @@ unsigned int arpt_do_table(struct sk_buff *skb,
 	do {
 		const struct xt_entry_target *t;
 
-		if (!arp_packet_match(arp, skb->dev, indev, outdev, &e->arp)) {
+		if (!arp_packet_match(arp, skb->dev, in, out, &e->arp)) {
 			e = arpt_next_entry(e);
 			continue;
 		}
diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index 99e810f..87df9ef 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -73,8 +73,8 @@ EXPORT_SYMBOL_GPL(ipt_alloc_initial_table);
 /* Performance critical - called for every packet */
 static inline bool
 ip_packet_match(const struct iphdr *ip,
-		const char *indev,
-		const char *outdev,
+		const struct net_device *indev,
+		const struct net_device *outdev,
 		const struct ipt_ip *ipinfo,
 		int isfrag)
 {
@@ -97,7 +97,7 @@ ip_packet_match(const struct iphdr *ip,
 		return false;
 	}
 
-	ret = ifname_compare_aligned(indev, ipinfo->iniface, ipinfo->iniface_mask);
+	ret = ifname_compare_all(indev, ipinfo->iniface, ipinfo->iniface_mask);
 
 	if (FWINV(ret != 0, IPT_INV_VIA_IN)) {
 		dprintf("VIA in mismatch (%s vs %s).%s\n",
@@ -106,7 +106,7 @@ ip_packet_match(const struct iphdr *ip,
 		return false;
 	}
 
-	ret = ifname_compare_aligned(outdev, ipinfo->outiface, ipinfo->outiface_mask);
+	ret = ifname_compare_all(outdev, ipinfo->outiface, ipinfo->outiface_mask);
 
 	if (FWINV(ret != 0, IPT_INV_VIA_OUT)) {
 		dprintf("VIA out mismatch (%s vs %s).%s\n",
@@ -292,11 +292,9 @@ ipt_do_table(struct sk_buff *skb,
 	     const struct net_device *out,
 	     struct xt_table *table)
 {
-	static const char nulldevname[IFNAMSIZ] __attribute__((aligned(sizeof(long))));
 	const struct iphdr *ip;
 	/* Initializing verdict to NF_DROP keeps gcc happy. */
 	unsigned int verdict = NF_DROP;
-	const char *indev, *outdev;
 	const void *table_base;
 	struct ipt_entry *e, **jumpstack;
 	unsigned int *stackptr, origptr, cpu;
@@ -306,8 +304,6 @@ ipt_do_table(struct sk_buff *skb,
 
 	/* Initialization */
 	ip = ip_hdr(skb);
-	indev = in ? in->name : nulldevname;
-	outdev = out ? out->name : nulldevname;
 	/* We handle fragments by dealing with the first fragment as
 	 * if it was a normal packet.  All other fragments are treated
 	 * normally, except that they will NEVER match rules that ask
@@ -348,8 +344,7 @@ ipt_do_table(struct sk_buff *skb,
 		const struct xt_entry_match *ematch;
 
 		IP_NF_ASSERT(e);
-		if (!ip_packet_match(ip, indev, outdev,
-		    &e->ip, acpar.fragoff)) {
+		if (!ip_packet_match(ip, in, out, &e->ip, acpar.fragoff)) {
  no_match:
 			e = ipt_next_entry(e);
 			continue;
diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index e080fbb..9ed5d70 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -83,8 +83,8 @@ EXPORT_SYMBOL_GPL(ip6t_alloc_initial_table);
 /* Performance critical - called for every packet */
 static inline bool
 ip6_packet_match(const struct sk_buff *skb,
-		 const char *indev,
-		 const char *outdev,
+		 const struct net_device *indev,
+		 const struct net_device *outdev,
 		 const struct ip6t_ip6 *ip6info,
 		 unsigned int *protoff,
 		 int *fragoff, bool *hotdrop)
@@ -109,7 +109,7 @@ ip6_packet_match(const struct sk_buff *skb,
 		return false;
 	}
 
-	ret = ifname_compare_aligned(indev, ip6info->iniface, ip6info->iniface_mask);
+	ret = ifname_compare_all(indev, ip6info->iniface, ip6info->iniface_mask);
 
 	if (FWINV(ret != 0, IP6T_INV_VIA_IN)) {
 		dprintf("VIA in mismatch (%s vs %s).%s\n",
@@ -118,7 +118,7 @@ ip6_packet_match(const struct sk_buff *skb,
 		return false;
 	}
 
-	ret = ifname_compare_aligned(outdev, ip6info->outiface, ip6info->outiface_mask);
+	ret = ifname_compare_all(outdev, ip6info->outiface, ip6info->outiface_mask);
 
 	if (FWINV(ret != 0, IP6T_INV_VIA_OUT)) {
 		dprintf("VIA out mismatch (%s vs %s).%s\n",
@@ -318,10 +318,8 @@ ip6t_do_table(struct sk_buff *skb,
 	      const struct net_device *out,
 	      struct xt_table *table)
 {
-	static const char nulldevname[IFNAMSIZ] __attribute__((aligned(sizeof(long))));
 	/* Initializing verdict to NF_DROP keeps gcc happy. */
 	unsigned int verdict = NF_DROP;
-	const char *indev, *outdev;
 	const void *table_base;
 	struct ip6t_entry *e, **jumpstack;
 	unsigned int *stackptr, origptr, cpu;
@@ -329,10 +327,8 @@ ip6t_do_table(struct sk_buff *skb,
 	struct xt_action_param acpar;
 	unsigned int addend;
 
-	/* Initialization */
-	indev = in ? in->name : nulldevname;
-	outdev = out ? out->name : nulldevname;
-	/* We handle fragments by dealing with the first fragment as
+	/* Initialization:
+	 * We handle fragments by dealing with the first fragment as
 	 * if it was a normal packet.  All other fragments are treated
 	 * normally, except that they will NEVER match rules that ask
 	 * things we don't know, ie. tcp syn flag or ports).  If the
@@ -368,7 +364,7 @@ ip6t_do_table(struct sk_buff *skb,
 
 		IP_NF_ASSERT(e);
 		acpar.thoff = 0;
-		if (!ip6_packet_match(skb, indev, outdev, &e->ipv6,
+		if (!ip6_packet_match(skb, in, out, &e->ipv6,
 		    &acpar.thoff, &acpar.fragoff, &acpar.hotdrop)) {
  no_match:
 			e = ip6t_next_entry(e);
diff --git a/net/netfilter/xt_physdev.c b/net/netfilter/xt_physdev.c
index f440f57..8d2ee7d 100644
--- a/net/netfilter/xt_physdev.c
+++ b/net/netfilter/xt_physdev.c
@@ -25,10 +25,8 @@ MODULE_ALIAS("ip6t_physdev");
 static bool
 physdev_mt(const struct sk_buff *skb, struct xt_action_param *par)
 {
-	static const char nulldevname[IFNAMSIZ] __attribute__((aligned(sizeof(long))));
 	const struct xt_physdev_info *info = par->matchinfo;
 	unsigned long ret;
-	const char *indev, *outdev;
 	const struct nf_bridge_info *nf_bridge;
 
 	/* Not a bridged IP packet or no info available yet:
@@ -68,8 +66,7 @@ physdev_mt(const struct sk_buff *skb, struct xt_action_param *par)
 
 	if (!(info->bitmask & XT_PHYSDEV_OP_IN))
 		goto match_outdev;
-	indev = nf_bridge->physindev ? nf_bridge->physindev->name : nulldevname;
-	ret = ifname_compare_aligned(indev, info->physindev, info->in_mask);
+	ret = ifname_compare_all(nf_bridge->physindev, info->physindev, info->in_mask);
 
 	if (!ret ^ !(info->invert & XT_PHYSDEV_OP_IN))
 		return false;
@@ -77,9 +74,7 @@ physdev_mt(const struct sk_buff *skb, struct xt_action_param *par)
 match_outdev:
 	if (!(info->bitmask & XT_PHYSDEV_OP_OUT))
 		return true;
-	outdev = nf_bridge->physoutdev ?
-		 nf_bridge->physoutdev->name : nulldevname;
-	ret = ifname_compare_aligned(outdev, info->physoutdev, info->out_mask);
+	ret = ifname_compare_all(nf_bridge->physoutdev, info->physoutdev, info->out_mask);
 
 	return (!!ret ^ !(info->invert & XT_PHYSDEV_OP_OUT));
 }
-- 
1.8.4.5
