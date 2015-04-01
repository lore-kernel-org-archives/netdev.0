From: Florian Westphal <fw@strlen.de>
Subject: [PATCH nf-next 07/14] netfilter: bridge: add helpers for fetching physin/outdev
Date: Wed,  1 Apr 2015 22:36:33 +0200
Message-ID: <1427920600-20366-8-git-send-email-fw@strlen.de>
References: <1427920600-20366-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1427920600-20366-1-git-send-email-fw@strlen.de>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

right now we store this in the nf_bridge_info struct, accessible
via skb->nf_bridge.  This patch prepares removal of this pointer from skb:

Instead of using skb->nf_bridge->x, we use helpers to obtain the in/out
device (or ifindexes).

Followup patches to netfilter will then allow nf_bridge_info to be
obtained by a call into the br_netfilter core, rather than keeping a
pointer to it in sk_buff.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 include/linux/netfilter_bridge.h           | 23 ++++++++++++++++++++-
 net/ipv4/netfilter/nf_reject_ipv4.c        |  4 +++-
 net/ipv6/netfilter/nf_reject_ipv6.c        |  4 +++-
 net/netfilter/ipset/ip_set_hash_netiface.c | 32 ++++++++++++++++++++++--------
 net/netfilter/nf_log_common.c              |  5 +++--
 net/netfilter/nf_queue.c                   | 18 +++++++++--------
 net/netfilter/nfnetlink_log.c              | 17 ++++++++++++----
 net/netfilter/nfnetlink_queue_core.c       | 28 +++++++++++++++++---------
 8 files changed, 97 insertions(+), 34 deletions(-)

diff --git a/include/linux/netfilter_bridge.h b/include/linux/netfilter_bridge.h
index 66245b5..61251e4 100644
--- a/include/linux/netfilter_bridge.h
+++ b/include/linux/netfilter_bridge.h
@@ -2,7 +2,7 @@
 #define __LINUX_BRIDGE_NETFILTER_H
 
 #include <uapi/linux/netfilter_bridge.h>
-
+#include <linux/skbuff.h>
 
 enum nf_br_hook_priorities {
 	NF_BR_PRI_FIRST = INT_MIN,
@@ -30,6 +30,27 @@ static inline void br_drop_fake_rtable(struct sk_buff *skb)
 		skb_dst_drop(skb);
 }
 
+static inline int nf_bridge_get_physinif(const struct sk_buff *skb)
+{
+	return skb->nf_bridge ? skb->nf_bridge->physindev->ifindex : 0;
+}
+
+static inline int nf_bridge_get_physoutif(const struct sk_buff *skb)
+{
+	return skb->nf_bridge ? skb->nf_bridge->physoutdev->ifindex : 0;
+}
+
+static inline struct net_device *
+nf_bridge_get_physindev(const struct sk_buff *skb)
+{
+	return skb->nf_bridge ? skb->nf_bridge->physindev : NULL;
+}
+
+static inline struct net_device *
+nf_bridge_get_physoutdev(const struct sk_buff *skb)
+{
+	return skb->nf_bridge ? skb->nf_bridge->physoutdev : NULL;
+}
 #else
 #define br_drop_fake_rtable(skb)	        do { } while (0)
 #endif /* CONFIG_BRIDGE_NETFILTER */
diff --git a/net/ipv4/netfilter/nf_reject_ipv4.c b/net/ipv4/netfilter/nf_reject_ipv4.c
index c5b794d..3262e41 100644
--- a/net/ipv4/netfilter/nf_reject_ipv4.c
+++ b/net/ipv4/netfilter/nf_reject_ipv4.c
@@ -13,6 +13,7 @@
 #include <net/dst.h>
 #include <net/netfilter/ipv4/nf_reject.h>
 #include <linux/netfilter_ipv4.h>
+#include <linux/netfilter_bridge.h>
 #include <net/netfilter/ipv4/nf_reject.h>
 
 const struct tcphdr *nf_reject_ip_tcphdr_get(struct sk_buff *oldskb,
@@ -146,7 +147,8 @@ void nf_send_reset(struct sk_buff *oldskb, int hook)
 	 */
 	if (oldskb->nf_bridge) {
 		struct ethhdr *oeth = eth_hdr(oldskb);
-		nskb->dev = oldskb->nf_bridge->physindev;
+
+		nskb->dev = nf_bridge_get_physindev(oldskb);
 		niph->tot_len = htons(nskb->len);
 		ip_send_check(niph);
 		if (dev_hard_header(nskb, nskb->dev, ntohs(nskb->protocol),
diff --git a/net/ipv6/netfilter/nf_reject_ipv6.c b/net/ipv6/netfilter/nf_reject_ipv6.c
index 3afdce0..94b4c6d 100644
--- a/net/ipv6/netfilter/nf_reject_ipv6.c
+++ b/net/ipv6/netfilter/nf_reject_ipv6.c
@@ -13,6 +13,7 @@
 #include <net/ip6_checksum.h>
 #include <net/netfilter/ipv6/nf_reject.h>
 #include <linux/netfilter_ipv6.h>
+#include <linux/netfilter_bridge.h>
 #include <net/netfilter/ipv6/nf_reject.h>
 
 const struct tcphdr *nf_reject_ip6_tcphdr_get(struct sk_buff *oldskb,
@@ -195,7 +196,8 @@ void nf_send_reset6(struct net *net, struct sk_buff *oldskb, int hook)
 	 */
 	if (oldskb->nf_bridge) {
 		struct ethhdr *oeth = eth_hdr(oldskb);
-		nskb->dev = oldskb->nf_bridge->physindev;
+
+		nskb->dev = nf_bridge_get_physindev(oldskb);
 		nskb->protocol = htons(ETH_P_IPV6);
 		ip6h->payload_len = htons(sizeof(struct tcphdr));
 		if (dev_hard_header(nskb, nskb->dev, ntohs(nskb->protocol),
diff --git a/net/netfilter/ipset/ip_set_hash_netiface.c b/net/netfilter/ipset/ip_set_hash_netiface.c
index 758b002..380ef51 100644
--- a/net/netfilter/ipset/ip_set_hash_netiface.c
+++ b/net/netfilter/ipset/ip_set_hash_netiface.c
@@ -19,6 +19,7 @@
 #include <net/netlink.h>
 
 #include <linux/netfilter.h>
+#include <linux/netfilter_bridge.h>
 #include <linux/netfilter/ipset/pfxlen.h>
 #include <linux/netfilter/ipset/ip_set.h>
 #include <linux/netfilter/ipset/ip_set_hash.h>
@@ -211,6 +212,22 @@ hash_netiface4_data_next(struct hash_netiface4_elem *next,
 #define HKEY_DATALEN	sizeof(struct hash_netiface4_elem_hashed)
 #include "ip_set_hash_gen.h"
 
+#if IS_ENABLED(CONFIG_BRIDGE_NETFILTER)
+static const char *get_physindev_name(const struct sk_buff *skb)
+{
+	struct net_device *dev = nf_bridge_get_physindev(skb);
+
+	return dev ? dev->name : NULL;
+}
+
+static const char *get_phyoutdev_name(const struct sk_buff *skb)
+{
+	struct net_device *dev = nf_bridge_get_physoutdev(skb);
+
+	return dev ? dev->name : NULL;
+}
+#endif
+
 static int
 hash_netiface4_kadt(struct ip_set *set, const struct sk_buff *skb,
 		    const struct xt_action_param *par,
@@ -234,16 +251,15 @@ hash_netiface4_kadt(struct ip_set *set, const struct sk_buff *skb,
 	e.ip &= ip_set_netmask(e.cidr);
 
 #define IFACE(dir)	(par->dir ? par->dir->name : NULL)
-#define PHYSDEV(dir)	(nf_bridge->dir ? nf_bridge->dir->name : NULL)
 #define SRCDIR		(opt->flags & IPSET_DIM_TWO_SRC)
 
 	if (opt->cmdflags & IPSET_FLAG_PHYSDEV) {
 #if IS_ENABLED(CONFIG_BRIDGE_NETFILTER)
-		const struct nf_bridge_info *nf_bridge = skb->nf_bridge;
+		e.iface = SRCDIR ? get_physindev_name(skb) :
+				   get_phyoutdev_name(skb);
 
-		if (!nf_bridge)
+		if (!e.iface)
 			return -EINVAL;
-		e.iface = SRCDIR ? PHYSDEV(physindev) : PHYSDEV(physoutdev);
 		e.physdev = 1;
 #else
 		e.iface = NULL;
@@ -476,11 +492,11 @@ hash_netiface6_kadt(struct ip_set *set, const struct sk_buff *skb,
 
 	if (opt->cmdflags & IPSET_FLAG_PHYSDEV) {
 #if IS_ENABLED(CONFIG_BRIDGE_NETFILTER)
-		const struct nf_bridge_info *nf_bridge = skb->nf_bridge;
-
-		if (!nf_bridge)
+		e.iface = SRCDIR ? get_physindev_name(skb) :
+				   get_phyoutdev_name(skb);
+		if (!e.iface)
 			return -EINVAL;
-		e.iface = SRCDIR ? PHYSDEV(physindev) : PHYSDEV(physoutdev);
+
 		e.physdev = 1;
 #else
 		e.iface = NULL;
diff --git a/net/netfilter/nf_log_common.c b/net/netfilter/nf_log_common.c
index 2631876..a5aa596 100644
--- a/net/netfilter/nf_log_common.c
+++ b/net/netfilter/nf_log_common.c
@@ -17,6 +17,7 @@
 #include <net/route.h>
 
 #include <linux/netfilter.h>
+#include <linux/netfilter_bridge.h>
 #include <linux/netfilter/xt_LOG.h>
 #include <net/netfilter/nf_log.h>
 
@@ -163,10 +164,10 @@ nf_log_dump_packet_common(struct nf_log_buf *m, u_int8_t pf,
 		const struct net_device *physindev;
 		const struct net_device *physoutdev;
 
-		physindev = skb->nf_bridge->physindev;
+		physindev = nf_bridge_get_physindev(skb);
 		if (physindev && in != physindev)
 			nf_log_buf_add(m, "PHYSIN=%s ", physindev->name);
-		physoutdev = skb->nf_bridge->physoutdev;
+		physoutdev = nf_bridge_get_physoutdev(skb);
 		if (physoutdev && out != physoutdev)
 			nf_log_buf_add(m, "PHYSOUT=%s ", physoutdev->name);
 	}
diff --git a/net/netfilter/nf_queue.c b/net/netfilter/nf_queue.c
index 4c8b68e..fb045b4 100644
--- a/net/netfilter/nf_queue.c
+++ b/net/netfilter/nf_queue.c
@@ -10,6 +10,7 @@
 #include <linux/proc_fs.h>
 #include <linux/skbuff.h>
 #include <linux/netfilter.h>
+#include <linux/netfilter_bridge.h>
 #include <linux/seq_file.h>
 #include <linux/rcupdate.h>
 #include <net/protocol.h>
@@ -54,12 +55,14 @@ void nf_queue_entry_release_refs(struct nf_queue_entry *entry)
 		dev_put(entry->outdev);
 #if IS_ENABLED(CONFIG_BRIDGE_NETFILTER)
 	if (entry->skb->nf_bridge) {
-		struct nf_bridge_info *nf_bridge = entry->skb->nf_bridge;
+		struct net_device *physdev;
 
-		if (nf_bridge->physindev)
-			dev_put(nf_bridge->physindev);
-		if (nf_bridge->physoutdev)
-			dev_put(nf_bridge->physoutdev);
+		physdev = nf_bridge_get_physindev(entry->skb);
+		if (physdev)
+			dev_put(physdev);
+		physdev = nf_bridge_get_physoutdev(entry->skb);
+		if (physdev)
+			dev_put(physdev);
 	}
 #endif
 	/* Drop reference to owner of hook which queued us. */
@@ -79,13 +82,12 @@ bool nf_queue_entry_get_refs(struct nf_queue_entry *entry)
 		dev_hold(entry->outdev);
 #if IS_ENABLED(CONFIG_BRIDGE_NETFILTER)
 	if (entry->skb->nf_bridge) {
-		struct nf_bridge_info *nf_bridge = entry->skb->nf_bridge;
 		struct net_device *physdev;
 
-		physdev = nf_bridge->physindev;
+		physdev = nf_bridge_get_physindev(entry->skb);
 		if (physdev)
 			dev_hold(physdev);
-		physdev = nf_bridge->physoutdev;
+		physdev = nf_bridge_get_physoutdev(entry->skb);
 		if (physdev)
 			dev_hold(physdev);
 	}
diff --git a/net/netfilter/nfnetlink_log.c b/net/netfilter/nfnetlink_log.c
index 957b83a..51afea4 100644
--- a/net/netfilter/nfnetlink_log.c
+++ b/net/netfilter/nfnetlink_log.c
@@ -23,6 +23,7 @@
 #include <linux/ipv6.h>
 #include <linux/netdevice.h>
 #include <linux/netfilter.h>
+#include <linux/netfilter_bridge.h>
 #include <net/netlink.h>
 #include <linux/netfilter/nfnetlink.h>
 #include <linux/netfilter/nfnetlink_log.h>
@@ -448,14 +449,18 @@ __build_packet_message(struct nfnl_log_net *log,
 					 htonl(br_port_get_rcu(indev)->br->dev->ifindex)))
 				goto nla_put_failure;
 		} else {
+			struct net_device *physindev;
+
 			/* Case 2: indev is bridge group, we need to look for
 			 * physical device (when called from ipv4) */
 			if (nla_put_be32(inst->skb, NFULA_IFINDEX_INDEV,
 					 htonl(indev->ifindex)))
 				goto nla_put_failure;
-			if (skb->nf_bridge && skb->nf_bridge->physindev &&
+
+			physindev = nf_bridge_get_physindev(skb);
+			if (physindev &&
 			    nla_put_be32(inst->skb, NFULA_IFINDEX_PHYSINDEV,
-					 htonl(skb->nf_bridge->physindev->ifindex)))
+					 htonl(physindev->ifindex)))
 				goto nla_put_failure;
 		}
 #endif
@@ -479,14 +484,18 @@ __build_packet_message(struct nfnl_log_net *log,
 					 htonl(br_port_get_rcu(outdev)->br->dev->ifindex)))
 				goto nla_put_failure;
 		} else {
+			struct net_device *physoutdev;
+
 			/* Case 2: indev is a bridge group, we need to look
 			 * for physical device (when called from ipv4) */
 			if (nla_put_be32(inst->skb, NFULA_IFINDEX_OUTDEV,
 					 htonl(outdev->ifindex)))
 				goto nla_put_failure;
-			if (skb->nf_bridge && skb->nf_bridge->physoutdev &&
+
+			physoutdev = nf_bridge_get_physoutdev(skb);
+			if (physoutdev &&
 			    nla_put_be32(inst->skb, NFULA_IFINDEX_PHYSOUTDEV,
-					 htonl(skb->nf_bridge->physoutdev->ifindex)))
+					 htonl(physoutdev->ifindex)))
 				goto nla_put_failure;
 		}
 #endif
diff --git a/net/netfilter/nfnetlink_queue_core.c b/net/netfilter/nfnetlink_queue_core.c
index 86ee8b0..94e1aaf 100644
--- a/net/netfilter/nfnetlink_queue_core.c
+++ b/net/netfilter/nfnetlink_queue_core.c
@@ -25,6 +25,7 @@
 #include <linux/proc_fs.h>
 #include <linux/netfilter_ipv4.h>
 #include <linux/netfilter_ipv6.h>
+#include <linux/netfilter_bridge.h>
 #include <linux/netfilter/nfnetlink.h>
 #include <linux/netfilter/nfnetlink_queue.h>
 #include <linux/list.h>
@@ -396,14 +397,18 @@ nfqnl_build_packet_message(struct net *net, struct nfqnl_instance *queue,
 					 htonl(br_port_get_rcu(indev)->br->dev->ifindex)))
 				goto nla_put_failure;
 		} else {
+			int physinif;
+
 			/* Case 2: indev is bridge group, we need to look for
 			 * physical device (when called from ipv4) */
 			if (nla_put_be32(skb, NFQA_IFINDEX_INDEV,
 					 htonl(indev->ifindex)))
 				goto nla_put_failure;
-			if (entskb->nf_bridge && entskb->nf_bridge->physindev &&
+
+			physinif = nf_bridge_get_physinif(entskb);
+			if (physinif &&
 			    nla_put_be32(skb, NFQA_IFINDEX_PHYSINDEV,
-					 htonl(entskb->nf_bridge->physindev->ifindex)))
+					 htonl(physinif)))
 				goto nla_put_failure;
 		}
 #endif
@@ -426,14 +431,18 @@ nfqnl_build_packet_message(struct net *net, struct nfqnl_instance *queue,
 					 htonl(br_port_get_rcu(outdev)->br->dev->ifindex)))
 				goto nla_put_failure;
 		} else {
+			int physoutif;
+
 			/* Case 2: outdev is bridge group, we need to look for
 			 * physical output device (when called from ipv4) */
 			if (nla_put_be32(skb, NFQA_IFINDEX_OUTDEV,
 					 htonl(outdev->ifindex)))
 				goto nla_put_failure;
-			if (entskb->nf_bridge && entskb->nf_bridge->physoutdev &&
+
+			physoutif = nf_bridge_get_physoutif(entskb);
+			if (physoutif &&
 			    nla_put_be32(skb, NFQA_IFINDEX_PHYSOUTDEV,
-					 htonl(entskb->nf_bridge->physoutdev->ifindex)))
+					 htonl(physoutif)))
 				goto nla_put_failure;
 		}
 #endif
@@ -765,11 +774,12 @@ dev_cmp(struct nf_queue_entry *entry, unsigned long ifindex)
 			return 1;
 #if IS_ENABLED(CONFIG_BRIDGE_NETFILTER)
 	if (entry->skb->nf_bridge) {
-		if (entry->skb->nf_bridge->physindev &&
-		    entry->skb->nf_bridge->physindev->ifindex == ifindex)
-			return 1;
-		if (entry->skb->nf_bridge->physoutdev &&
-		    entry->skb->nf_bridge->physoutdev->ifindex == ifindex)
+		int physinif, physoutif;
+
+		physinif = nf_bridge_get_physinif(entry->skb);
+		physoutif = nf_bridge_get_physoutif(entry->skb);
+
+		if (physinif == ifindex || physoutif == ifindex)
 			return 1;
 	}
 #endif
-- 
2.0.5

