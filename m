From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH net-next 12/22] dst: Metadata destinations
Date: Fri, 17 Jul 2015 14:55:31 +0200
Message-ID: <3c8071815f514b07ee1b918f03f04b369349662a.1437137396.git.tgraf@suug.ch>
References: <cover.1437137396.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org, dev@openvswitch.org
To: roopa@cumulusnetworks.com, rshearma@brocade.com,
	ebiederm@xmission.com, hannes@stressinduktion.org,
	pshelar@nicira.com, jesse@nicira.com, davem@davemloft.net,
	daniel@iogearbox.net, tom@herbertland.com, edumazet@google.com,
	jiri@resnulli.us, marcelo.leitner@gmail.com,
	stephen@networkplumber.org, jpettit@nicira.com, kaber@trash.net,
	simon.horman@netronome.com, joestringer@nicira.com, ja@ssi.bg,
	ast@plumgrid.com, weichunc@plumgrid.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:49557 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757993AbbGQM4A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jul 2015 08:56:00 -0400
In-Reply-To: <cover.1437137396.git.tgraf@suug.ch>
In-Reply-To: <cover.1437137396.git.tgraf@suug.ch>
References: <cover.1437137396.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Introduces a new dst_metadata which enables to carry per packet metadata
between forwarding and processing elements via the skb->dst pointer.

The structure is set up to be a union. Thus, each separate type of
metadata requires its own dst instance. If demand arises to carry
multiple types of metadata concurrently, metadata dst entries can be
made stackable.

The metadata dst entry is refcnt'ed as expected for now but a non
reference counted use is possible if the reference is forced before
queueing the skb.

In order to allow allocating dsts with variable length, the existing
dst_alloc() is split into a dst_alloc() and dst_init() function. The
existing dst_init() function to initialize the subsystem is being
renamed to dst_subsys_init() to make it clear what is what.

The check before ip_route_input() is changed to ignore metadata dsts
and drop the dst inside the routing function thus allowing to interpret
metadata in a later commit.

Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 include/net/dst.h          |  6 +++-
 include/net/dst_metadata.h | 32 ++++++++++++++++++
 net/core/dev.c             |  2 +-
 net/core/dst.c             | 84 ++++++++++++++++++++++++++++++++++++++--------
 net/ipv4/ip_input.c        |  3 +-
 net/ipv4/route.c           |  2 ++
 6 files changed, 112 insertions(+), 17 deletions(-)
 create mode 100644 include/net/dst_metadata.h

diff --git a/include/net/dst.h b/include/net/dst.h
index 2bc73f8a..2578811 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -57,6 +57,7 @@ struct dst_entry {
 #define DST_FAKE_RTABLE		0x0040
 #define DST_XFRM_TUNNEL		0x0080
 #define DST_XFRM_QUEUE		0x0100
+#define DST_METADATA		0x0200
 
 	unsigned short		pending_confirm;
 
@@ -356,6 +357,9 @@ static inline int dst_discard(struct sk_buff *skb)
 }
 void *dst_alloc(struct dst_ops *ops, struct net_device *dev, int initial_ref,
 		int initial_obsolete, unsigned short flags);
+void dst_init(struct dst_entry *dst, struct dst_ops *ops,
+	      struct net_device *dev, int initial_ref, int initial_obsolete,
+	      unsigned short flags);
 void __dst_free(struct dst_entry *dst);
 struct dst_entry *dst_destroy(struct dst_entry *dst);
 
@@ -457,7 +461,7 @@ static inline struct dst_entry *dst_check(struct dst_entry *dst, u32 cookie)
 	return dst;
 }
 
-void dst_init(void);
+void dst_subsys_init(void);
 
 /* Flags for xfrm_lookup flags argument. */
 enum {
diff --git a/include/net/dst_metadata.h b/include/net/dst_metadata.h
new file mode 100644
index 0000000..4f7694f
--- /dev/null
+++ b/include/net/dst_metadata.h
@@ -0,0 +1,32 @@
+#ifndef __NET_DST_METADATA_H
+#define __NET_DST_METADATA_H 1
+
+#include <linux/skbuff.h>
+#include <net/ip_tunnels.h>
+#include <net/dst.h>
+
+struct metadata_dst {
+	struct dst_entry		dst;
+	size_t				opts_len;
+};
+
+static inline struct metadata_dst *skb_metadata_dst(struct sk_buff *skb)
+{
+	struct metadata_dst *md_dst = (struct metadata_dst *) skb_dst(skb);
+
+	if (md_dst && md_dst->dst.flags & DST_METADATA)
+		return md_dst;
+
+	return NULL;
+}
+
+static inline bool skb_valid_dst(const struct sk_buff *skb)
+{
+	struct dst_entry *dst = skb_dst(skb);
+
+	return dst && !(dst->flags & DST_METADATA);
+}
+
+struct metadata_dst *metadata_dst_alloc(u8 optslen, gfp_t flags);
+
+#endif /* __NET_DST_METADATA_H */
diff --git a/net/core/dev.c b/net/core/dev.c
index 8810b6b..61e3dcb 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -7659,7 +7659,7 @@ static int __init net_dev_init(void)
 	open_softirq(NET_RX_SOFTIRQ, net_rx_action);
 
 	hotcpu_notifier(dev_cpu_callback, 0);
-	dst_init();
+	dst_subsys_init();
 	rc = 0;
 out:
 	return rc;
diff --git a/net/core/dst.c b/net/core/dst.c
index e956ce6..917364f 100644
--- a/net/core/dst.c
+++ b/net/core/dst.c
@@ -22,6 +22,7 @@
 #include <linux/prefetch.h>
 
 #include <net/dst.h>
+#include <net/dst_metadata.h>
 
 /*
  * Theory of operations:
@@ -158,19 +159,10 @@ const u32 dst_default_metrics[RTAX_MAX + 1] = {
 	[RTAX_MAX] = 0xdeadbeef,
 };
 
-
-void *dst_alloc(struct dst_ops *ops, struct net_device *dev,
-		int initial_ref, int initial_obsolete, unsigned short flags)
+void dst_init(struct dst_entry *dst, struct dst_ops *ops,
+	      struct net_device *dev, int initial_ref, int initial_obsolete,
+	      unsigned short flags)
 {
-	struct dst_entry *dst;
-
-	if (ops->gc && dst_entries_get_fast(ops) > ops->gc_thresh) {
-		if (ops->gc(ops))
-			return NULL;
-	}
-	dst = kmem_cache_alloc(ops->kmem_cachep, GFP_ATOMIC);
-	if (!dst)
-		return NULL;
 	dst->child = NULL;
 	dst->dev = dev;
 	if (dev)
@@ -200,6 +192,25 @@ void *dst_alloc(struct dst_ops *ops, struct net_device *dev,
 	dst->next = NULL;
 	if (!(flags & DST_NOCOUNT))
 		dst_entries_add(ops, 1);
+}
+EXPORT_SYMBOL(dst_init);
+
+void *dst_alloc(struct dst_ops *ops, struct net_device *dev,
+		int initial_ref, int initial_obsolete, unsigned short flags)
+{
+	struct dst_entry *dst;
+
+	if (ops->gc && dst_entries_get_fast(ops) > ops->gc_thresh) {
+		if (ops->gc(ops))
+			return NULL;
+	}
+
+	dst = kmem_cache_alloc(ops->kmem_cachep, GFP_ATOMIC);
+	if (!dst)
+		return NULL;
+
+	dst_init(dst, ops, dev, initial_ref, initial_obsolete, flags);
+
 	return dst;
 }
 EXPORT_SYMBOL(dst_alloc);
@@ -248,7 +259,11 @@ again:
 		dst->ops->destroy(dst);
 	if (dst->dev)
 		dev_put(dst->dev);
-	kmem_cache_free(dst->ops->kmem_cachep, dst);
+
+	if (dst->flags & DST_METADATA)
+		kfree(dst);
+	else
+		kmem_cache_free(dst->ops->kmem_cachep, dst);
 
 	dst = child;
 	if (dst) {
@@ -327,6 +342,47 @@ void __dst_destroy_metrics_generic(struct dst_entry *dst, unsigned long old)
 }
 EXPORT_SYMBOL(__dst_destroy_metrics_generic);
 
+static struct dst_ops md_dst_ops = {
+	.family =		AF_UNSPEC,
+};
+
+static int dst_md_discard_sk(struct sock *sk, struct sk_buff *skb)
+{
+	WARN_ONCE(1, "Attempting to call output on metadata dst\n");
+	kfree_skb(skb);
+	return 0;
+}
+
+static int dst_md_discard(struct sk_buff *skb)
+{
+	WARN_ONCE(1, "Attempting to call input on metadata dst\n");
+	kfree_skb(skb);
+	return 0;
+}
+
+struct metadata_dst *metadata_dst_alloc(u8 optslen, gfp_t flags)
+{
+	struct metadata_dst *md_dst;
+	struct dst_entry *dst;
+
+	md_dst = kmalloc(sizeof(*md_dst) + optslen, flags);
+	if (!md_dst)
+		return ERR_PTR(-ENOMEM);
+
+	dst = &md_dst->dst;
+	dst_init(dst, &md_dst_ops, NULL, 1, DST_OBSOLETE_NONE,
+		 DST_METADATA | DST_NOCACHE | DST_NOCOUNT);
+
+	dst->input = dst_md_discard;
+	dst->output = dst_md_discard_sk;
+
+	memset(dst + 1, 0, sizeof(*md_dst) + optslen - sizeof(*dst));
+	md_dst->opts_len = optslen;
+
+	return md_dst;
+}
+EXPORT_SYMBOL_GPL(metadata_dst_alloc);
+
 /* Dirty hack. We did it in 2.2 (in __dst_free),
  * we have _very_ good reasons not to repeat
  * this mistake in 2.3, but we have no choice
@@ -391,7 +447,7 @@ static struct notifier_block dst_dev_notifier = {
 	.priority = -10, /* must be called after other network notifiers */
 };
 
-void __init dst_init(void)
+void __init dst_subsys_init(void)
 {
 	register_netdevice_notifier(&dst_dev_notifier);
 }
diff --git a/net/ipv4/ip_input.c b/net/ipv4/ip_input.c
index 2db4c87..f4fc8a7 100644
--- a/net/ipv4/ip_input.c
+++ b/net/ipv4/ip_input.c
@@ -146,6 +146,7 @@
 #include <net/xfrm.h>
 #include <linux/mroute.h>
 #include <linux/netlink.h>
+#include <net/dst_metadata.h>
 
 /*
  *	Process Router Attention IP option (RFC 2113)
@@ -331,7 +332,7 @@ static int ip_rcv_finish(struct sock *sk, struct sk_buff *skb)
 	 *	Initialise the virtual path cache for the packet. It describes
 	 *	how the packet travels inside Linux networking.
 	 */
-	if (!skb_dst(skb)) {
+	if (!skb_valid_dst(skb)) {
 		int err = ip_route_input_noref(skb, iph->daddr, iph->saddr,
 					       iph->tos, skb->dev);
 		if (unlikely(err)) {
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index cd3157c..4c8e84e 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1690,6 +1690,8 @@ static int ip_route_input_slow(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 	   by fib_lookup.
 	 */
 
+	skb_dst_drop(skb);
+
 	if (ipv4_is_multicast(saddr) || ipv4_is_lbcast(saddr))
 		goto martian_source;
 
-- 
2.4.3
