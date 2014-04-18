From: "Luis R. Rodriguez" <mcgrof-3uybbJdB1yH774rrrx3eTA@public.gmane.org>
Subject: [PATCH 1/3] 6lowpan: add helper to get 6lowpan
	namespace
Date: Thu, 17 Apr 2014 18:22:54 -0700
Message-ID: <1397784176-15809-2-git-send-email-mcgrof@do-not-panic.com>
References: <1397784176-15809-1-git-send-email-mcgrof@do-not-panic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, backports-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: alex.bluesman.smirnov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <1397784176-15809-1-git-send-email-mcgrof-3uybbJdB1yH774rrrx3eTA@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

From: "Luis R. Rodriguez" <mcgrof-IBi9RG/b67k@public.gmane.org>

This will simplify the new reassembly backport
with no code changes being required.

CC: Alexander Smirnov <alex.bluesman.smirnov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Dmitry Eremin-Solenikov <dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Cc: David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Signed-off-by: Luis R. Rodriguez <mcgrof-IBi9RG/b67k@public.gmane.org>
---
 include/net/net_namespace.h | 15 +++++++++++++++
 net/ieee802154/reassembly.c | 46 +++++++++++++++++++++++++++++----------------
 2 files changed, 45 insertions(+), 16 deletions(-)

diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
index 5f9eb26..bc4118e 100644
--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -373,6 +373,21 @@ static inline void rt_genid_bump_ipv6(struct net *net)
 }
 #endif
 
+#if IS_ENABLED(CONFIG_IEEE802154_6LOWPAN)
+static inline struct netns_ieee802154_lowpan *
+net_ieee802154_lowpan(struct net *net)
+{
+	return &net->ieee802154_lowpan;
+}
+#else
+static inline struct netns_ieee802154_lowpan *
+net_ieee802154_lowpan(struct net *net)
+{
+	return NULL;
+}
+#endif
+
+
 /* For callers who don't really care about whether it's IPv4 or IPv6 */
 static inline void rt_genid_bump_all(struct net *net)
 {
diff --git a/net/ieee802154/reassembly.c b/net/ieee802154/reassembly.c
index ef2d543..132b65b 100644
--- a/net/ieee802154/reassembly.c
+++ b/net/ieee802154/reassembly.c
@@ -120,6 +120,8 @@ fq_find(struct net *net, const struct lowpan_frag_info *frag_info,
 	struct inet_frag_queue *q;
 	struct lowpan_create_arg arg;
 	unsigned int hash;
+	struct netns_ieee802154_lowpan *ieee802154_lowpan =
+		net_ieee802154_lowpan(net);
 
 	arg.tag = frag_info->d_tag;
 	arg.d_size = frag_info->d_size;
@@ -129,7 +131,7 @@ fq_find(struct net *net, const struct lowpan_frag_info *frag_info,
 	read_lock(&lowpan_frags.lock);
 	hash = lowpan_hash_frag(frag_info->d_tag, frag_info->d_size, src, dst);
 
-	q = inet_frag_find(&net->ieee802154_lowpan.frags,
+	q = inet_frag_find(&ieee802154_lowpan->frags,
 			   &lowpan_frags, &arg, hash);
 	if (IS_ERR_OR_NULL(q)) {
 		inet_frag_maybe_warn_overflow(q, pr_fmt());
@@ -357,6 +359,8 @@ int lowpan_frag_rcv(struct sk_buff *skb, const u8 frag_type)
 	struct net *net = dev_net(skb->dev);
 	struct lowpan_frag_info *frag_info = lowpan_cb(skb);
 	struct ieee802154_addr source, dest;
+	struct netns_ieee802154_lowpan *ieee802154_lowpan =
+		net_ieee802154_lowpan(net);
 	int err;
 
 	source = mac_cb(skb)->source;
@@ -366,10 +370,10 @@ int lowpan_frag_rcv(struct sk_buff *skb, const u8 frag_type)
 	if (err < 0)
 		goto err;
 
-	if (frag_info->d_size > net->ieee802154_lowpan.max_dsize)
+	if (frag_info->d_size > ieee802154_lowpan->max_dsize)
 		goto err;
 
-	inet_frag_evictor(&net->ieee802154_lowpan.frags, &lowpan_frags, false);
+	inet_frag_evictor(&ieee802154_lowpan->frags, &lowpan_frags, false);
 
 	fq = fq_find(net, frag_info, &source, &dest);
 	if (fq != NULL) {
@@ -436,6 +440,8 @@ static int __net_init lowpan_frags_ns_sysctl_register(struct net *net)
 {
 	struct ctl_table *table;
 	struct ctl_table_header *hdr;
+	struct netns_ieee802154_lowpan *ieee802154_lowpan =
+		net_ieee802154_lowpan(net);
 
 	table = lowpan_frags_ns_ctl_table;
 	if (!net_eq(net, &init_net)) {
@@ -444,10 +450,10 @@ static int __net_init lowpan_frags_ns_sysctl_register(struct net *net)
 		if (table == NULL)
 			goto err_alloc;
 
-		table[0].data = &net->ieee802154_lowpan.frags.high_thresh;
-		table[1].data = &net->ieee802154_lowpan.frags.low_thresh;
-		table[2].data = &net->ieee802154_lowpan.frags.timeout;
-		table[3].data = &net->ieee802154_lowpan.max_dsize;
+		table[0].data = &ieee802154_lowpan->frags.high_thresh;
+		table[1].data = &ieee802154_lowpan->frags.low_thresh;
+		table[2].data = &ieee802154_lowpan->frags.timeout;
+		table[3].data = &ieee802154_lowpan->max_dsize;
 
 		/* Don't export sysctls to unprivileged users */
 		if (net->user_ns != &init_user_ns)
@@ -458,7 +464,7 @@ static int __net_init lowpan_frags_ns_sysctl_register(struct net *net)
 	if (hdr == NULL)
 		goto err_reg;
 
-	net->ieee802154_lowpan.sysctl.frags_hdr = hdr;
+	ieee802154_lowpan->sysctl.frags_hdr = hdr;
 	return 0;
 
 err_reg:
@@ -471,9 +477,11 @@ err_alloc:
 static void __net_exit lowpan_frags_ns_sysctl_unregister(struct net *net)
 {
 	struct ctl_table *table;
+	struct netns_ieee802154_lowpan *ieee802154_lowpan =
+		net_ieee802154_lowpan(net);
 
-	table = net->ieee802154_lowpan.sysctl.frags_hdr->ctl_table_arg;
-	unregister_net_sysctl_table(net->ieee802154_lowpan.sysctl.frags_hdr);
+	table = ieee802154_lowpan->sysctl.frags_hdr->ctl_table_arg;
+	unregister_net_sysctl_table(ieee802154_lowpan->sysctl.frags_hdr);
 	if (!net_eq(net, &init_net))
 		kfree(table);
 }
@@ -514,20 +522,26 @@ static inline void lowpan_frags_sysctl_unregister(void)
 
 static int __net_init lowpan_frags_init_net(struct net *net)
 {
-	net->ieee802154_lowpan.frags.high_thresh = IPV6_FRAG_HIGH_THRESH;
-	net->ieee802154_lowpan.frags.low_thresh = IPV6_FRAG_LOW_THRESH;
-	net->ieee802154_lowpan.frags.timeout = IPV6_FRAG_TIMEOUT;
-	net->ieee802154_lowpan.max_dsize = 0xFFFF;
+	struct netns_ieee802154_lowpan *ieee802154_lowpan =
+		net_ieee802154_lowpan(net);
 
-	inet_frags_init_net(&net->ieee802154_lowpan.frags);
+	ieee802154_lowpan->frags.high_thresh = IPV6_FRAG_HIGH_THRESH;
+	ieee802154_lowpan->frags.low_thresh = IPV6_FRAG_LOW_THRESH;
+	ieee802154_lowpan->frags.timeout = IPV6_FRAG_TIMEOUT;
+	ieee802154_lowpan->max_dsize = 0xFFFF;
+
+	inet_frags_init_net(&ieee802154_lowpan->frags);
 
 	return lowpan_frags_ns_sysctl_register(net);
 }
 
 static void __net_exit lowpan_frags_exit_net(struct net *net)
 {
+	struct netns_ieee802154_lowpan *ieee802154_lowpan =
+		net_ieee802154_lowpan(net);
+
 	lowpan_frags_ns_sysctl_unregister(net);
-	inet_frags_exit_net(&net->ieee802154_lowpan.frags, &lowpan_frags);
+	inet_frags_exit_net(&ieee802154_lowpan->frags, &lowpan_frags);
 }
 
 static struct pernet_operations lowpan_frags_ops = {
-- 
1.9.1


------------------------------------------------------------------------------
Learn Graph Databases - Download FREE O'Reilly Book
"Graph Databases" is the definitive new guide to graph databases and their
applications. Written by three acclaimed leaders in the field,
this first edition is now available. Download your free book today!
http://p.sf.net/sfu/NeoTech
