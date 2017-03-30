From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next v2 3/6] net: mpls: change mpls_route layout
Date: Thu, 30 Mar 2017 09:18:21 -0700
Message-ID: <1490890704-8075-4-git-send-email-dsa@cumulusnetworks.com>
References: <1490890704-8075-1-git-send-email-dsa@cumulusnetworks.com>
Cc: roopa@cumulusnetworks.com, rshearma@brocade.com,
        ebiederm@xmission.com, David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f43.google.com ([74.125.83.43]:32849 "EHLO
        mail-pg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933356AbdC3QSe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 30 Mar 2017 12:18:34 -0400
Received: by mail-pg0-f43.google.com with SMTP id x125so44442977pgb.0
        for <netdev@vger.kernel.org>; Thu, 30 Mar 2017 09:18:33 -0700 (PDT)
In-Reply-To: <1490890704-8075-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move labels to the end of mpls_nh as a 0-sized array and within mpls_route
move the via for a nexthop after the mpls_nh. The new layout becomes:

   +----------------------+
   | mpls_route           |
   +----------------------+
   | mpls_nh 0            |
   +----------------------+
   | alignment padding    |   4 bytes for odd number of labels; 0 for even
   +----------------------+
   | via[rt_max_alen] 0   |
   +----------------------+
   | alignment padding    |   via's aligned on sizeof(unsigned long)
   +----------------------+
   | ...                  |
   +----------------------+
   | mpls_nh n-1          |
   +----------------------+
   | via[rt_max_alen] n-1 |
   +----------------------+

Memory allocated for nexthop + via is constant across all nexthops and
their via. It is based on the maximum number of labels across all nexthops
and the maximum via length. The size is saved in the mpls_route as
rt_nh_size. Accessing a nexthop becomes rt->rt_nh + index * rt->rt_nh_size.

The offset of the via address from a nexthop is saved as rt_via_offset
so that given an mpls_nh pointer the via for that hop is simply
nh + rt->rt_via_offset.

With prior code, memory allocated per mpls_route with 1 nexthop:
     via is an ethernet address - 64 bytes
     via is an ipv4 address     - 64
     via is an ipv6 address     - 72

With this patch set, memory allocated per mpls_route with 1 nexthop and
1 or 2 labels:
     via is an ethernet address - 56 bytes
     via is an ipv4 address     - 56
     via is an ipv6 address     - 64

The 8-byte reduction is due to the previous patch; the change introduced
by this patch has no impact on the size of allocations for 1 or 2 labels.

Performance impact of this change was examined using network namespaces
with veth pairs connecting namespaces. ns0 inserts the packet to the
label-switched path using an lwt route with encap mpls. ns1 adds 1 or 2
labels depending on test, ns2 (and ns3 for 2-label test) pops the label
and forwards. ns3 (or ns4) for a 2-label is the destination. Similar
series of namespaces used for 2-nexthop test.

Intent is to measure changes to latency (overhead in manipulating the
packet) in the forwarding path. Tests used netperf with UDP_RR.

IPv4:                     current   patches
   1 label, 1 nexthop      29908     30115
   2 label, 1 nexthop      29071     29612
   1 label, 2 nexthop      29582     29776
   2 label, 2 nexthop      29086     29149

IPv6:                     current   patches
   1 label, 1 nexthop      24502     24960
   2 label, 1 nexthop      24041     24407
   1 label, 2 nexthop      23795     23899
   2 label, 2 nexthop      23074     22959

In short, the change has no effect to a modest increase in performance.
This is expected since this patch does not really have an impact on routes
with 1 or 2 labels (the current limit) and 1 or 2 nexthops.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
v2
- and u8 and u16 reserved variables to explicitly note holes in mpls_nh
  and mpls_route

 net/mpls/af_mpls.c  | 37 +++++++++++++++++++++----------------
 net/mpls/internal.h | 45 ++++++++++++++++++++++++++++++---------------
 2 files changed, 51 insertions(+), 31 deletions(-)

diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
index 665dec84f001..1863b94133e4 100644
--- a/net/mpls/af_mpls.c
+++ b/net/mpls/af_mpls.c
@@ -24,6 +24,8 @@
 #include <net/nexthop.h>
 #include "internal.h"
 
+#define MAX_NEW_LABELS 2
+
 /* Maximum number of labels to look ahead at when selecting a path of
  * a multipath route
  */
@@ -60,10 +62,7 @@ EXPORT_SYMBOL_GPL(mpls_output_possible);
 
 static u8 *__mpls_nh_via(struct mpls_route *rt, struct mpls_nh *nh)
 {
-	u8 *nh0_via = PTR_ALIGN((u8 *)&rt->rt_nh[rt->rt_nhn], VIA_ALEN_ALIGN);
-	int nh_index = nh - rt->rt_nh;
-
-	return nh0_via + rt->rt_max_alen * nh_index;
+	return (u8 *)nh + rt->rt_via_offset;
 }
 
 static const u8 *mpls_nh_via(const struct mpls_route *rt,
@@ -189,6 +188,11 @@ static u32 mpls_multipath_hash(struct mpls_route *rt, struct sk_buff *skb)
 	return hash;
 }
 
+static struct mpls_nh *mpls_get_nexthop(struct mpls_route *rt, u8 index)
+{
+	return (struct mpls_nh *)((u8 *)rt->rt_nh + index * rt->rt_nh_size);
+}
+
 /* number of alive nexthops (rt->rt_nhn_alive) and the flags for
  * a next hop (nh->nh_flags) are modified by netdev event handlers.
  * Since those fields can change at any moment, use READ_ONCE to
@@ -206,7 +210,7 @@ static struct mpls_nh *mpls_select_multipath(struct mpls_route *rt,
 	 * one path
 	 */
 	if (rt->rt_nhn == 1)
-		goto out;
+		return rt->rt_nh;
 
 	alive = READ_ONCE(rt->rt_nhn_alive);
 	if (alive == 0)
@@ -227,7 +231,7 @@ static struct mpls_nh *mpls_select_multipath(struct mpls_route *rt,
 	} endfor_nexthops(rt);
 
 out:
-	return &rt->rt_nh[nh_index];
+	return mpls_get_nexthop(rt, nh_index);
 }
 
 static bool mpls_egress(struct net *net, struct mpls_route *rt,
@@ -466,19 +470,20 @@ struct mpls_route_config {
 	int			rc_mp_len;
 };
 
-static struct mpls_route *mpls_rt_alloc(u8 num_nh, u8 max_alen)
+/* all nexthops within a route have the same size based on max
+ * number of labels and max via length for a hop
+ */
+static struct mpls_route *mpls_rt_alloc(u8 num_nh, u8 max_alen, u8 max_labels)
 {
-	u8 max_alen_aligned = ALIGN(max_alen, VIA_ALEN_ALIGN);
+	u8 nh_size = MPLS_NH_SIZE(max_labels, max_alen);
 	struct mpls_route *rt;
 
-	rt = kzalloc(ALIGN(sizeof(*rt) + num_nh * sizeof(*rt->rt_nh),
-			   VIA_ALEN_ALIGN) +
-		     num_nh * max_alen_aligned,
-		     GFP_KERNEL);
+	rt = kzalloc(sizeof(*rt) + num_nh * nh_size, GFP_KERNEL);
 	if (rt) {
 		rt->rt_nhn = num_nh;
 		rt->rt_nhn_alive = num_nh;
-		rt->rt_max_alen = max_alen_aligned;
+		rt->rt_nh_size = nh_size;
+		rt->rt_via_offset = MPLS_NH_VIA_OFF(max_labels);
 	}
 
 	return rt;
@@ -892,7 +897,7 @@ static int mpls_route_add(struct mpls_route_config *cfg)
 		goto errout;
 
 	err = -ENOMEM;
-	rt = mpls_rt_alloc(nhs, max_via_alen);
+	rt = mpls_rt_alloc(nhs, max_via_alen, MAX_NEW_LABELS);
 	if (!rt)
 		goto errout;
 
@@ -1964,7 +1969,7 @@ static int resize_platform_label_table(struct net *net, size_t limit)
 	/* In case the predefined labels need to be populated */
 	if (limit > MPLS_LABEL_IPV4NULL) {
 		struct net_device *lo = net->loopback_dev;
-		rt0 = mpls_rt_alloc(1, lo->addr_len);
+		rt0 = mpls_rt_alloc(1, lo->addr_len, MAX_NEW_LABELS);
 		if (!rt0)
 			goto nort0;
 		RCU_INIT_POINTER(rt0->rt_nh->nh_dev, lo);
@@ -1978,7 +1983,7 @@ static int resize_platform_label_table(struct net *net, size_t limit)
 	}
 	if (limit > MPLS_LABEL_IPV6NULL) {
 		struct net_device *lo = net->loopback_dev;
-		rt2 = mpls_rt_alloc(1, lo->addr_len);
+		rt2 = mpls_rt_alloc(1, lo->addr_len, MAX_NEW_LABELS);
 		if (!rt2)
 			goto nort2;
 		RCU_INIT_POINTER(rt2->rt_nh->nh_dev, lo);
diff --git a/net/mpls/internal.h b/net/mpls/internal.h
index 2ac97433c3b7..cc324c022049 100644
--- a/net/mpls/internal.h
+++ b/net/mpls/internal.h
@@ -64,7 +64,6 @@ struct mpls_dev {
 struct sk_buff;
 
 #define LABEL_NOT_SPECIFIED (1 << 20)
-#define MAX_NEW_LABELS 2
 
 /* This maximum ha length copied from the definition of struct neighbour */
 #define VIA_ALEN_ALIGN sizeof(unsigned long)
@@ -88,12 +87,26 @@ struct mpls_nh { /* next hop label forwarding entry */
 	 * modified handling netdev events with rtnl lock held
 	 */
 	unsigned int		nh_flags;
-	u32			nh_label[MAX_NEW_LABELS];
 	u8			nh_labels;
 	u8			nh_via_alen;
 	u8			nh_via_table;
+	u8			nh_reserved1;
+
+	u32			nh_label[0];
 };
 
+/* offset of via from beginning of mpls_nh */
+#define MPLS_NH_VIA_OFF(num_labels) \
+		ALIGN(sizeof(struct mpls_nh) + (num_labels) * sizeof(u32), \
+		      VIA_ALEN_ALIGN)
+
+/* all nexthops within a route have the same size based on the
+ * max number of labels and max via length across all nexthops
+ */
+#define MPLS_NH_SIZE(num_labels, max_via_alen)		\
+		(MPLS_NH_VIA_OFF((num_labels)) +	\
+		ALIGN((max_via_alen), VIA_ALEN_ALIGN))
+
 enum mpls_ttl_propagation {
 	MPLS_TTL_PROP_DEFAULT,
 	MPLS_TTL_PROP_ENABLED,
@@ -108,16 +121,16 @@ enum mpls_ttl_propagation {
  * +----------------------+
  * | mpls_nh 0            |
  * +----------------------+
- * | ...                  |
- * +----------------------+
- * | mpls_nh n-1          |
- * +----------------------+
- * | alignment padding    |
+ * | alignment padding    |   4 bytes for odd number of labels
  * +----------------------+
  * | via[rt_max_alen] 0   |
  * +----------------------+
+ * | alignment padding    |   via's aligned on sizeof(unsigned long)
+ * +----------------------+
  * | ...                  |
  * +----------------------+
+ * | mpls_nh n-1          |
+ * +----------------------+
  * | via[rt_max_alen] n-1 |
  * +----------------------+
  */
@@ -128,26 +141,28 @@ struct mpls_route { /* next hop label forwarding entry */
 	u8			rt_max_alen;
 	u8			rt_ttl_propagate;
 	u8			rt_nhn;
-
 	/* rt_nhn_alive is accessed under RCU in the packet path; it
 	 * is modified handling netdev events with rtnl lock held
 	 */
 	u8			rt_nhn_alive;
-	u16			rt_reserved1;
+	u8			rt_nh_size;
+	u8			rt_via_offset;
+	u8			rt_reserved1;
 	struct mpls_nh		rt_nh[0];
 };
 
 #define for_nexthops(rt) {						\
-	int nhsel; struct mpls_nh *nh;			\
-	for (nhsel = 0, nh = (rt)->rt_nh;				\
+	int nhsel; struct mpls_nh *nh;  u8 *__nh;			\
+	for (nhsel = 0, nh = (rt)->rt_nh, __nh = (u8 *)((rt)->rt_nh);	\
 	     nhsel < (rt)->rt_nhn;					\
-	     nh++, nhsel++)
+	     __nh += rt->rt_nh_size, nh = (struct mpls_nh *)__nh, nhsel++)
 
 #define change_nexthops(rt) {						\
-	int nhsel; struct mpls_nh *nh;				\
-	for (nhsel = 0,	nh = (struct mpls_nh *)((rt)->rt_nh);	\
+	int nhsel; struct mpls_nh *nh; u8 *__nh;			\
+	for (nhsel = 0, nh = (struct mpls_nh *)((rt)->rt_nh),		\
+			__nh = (u8 *)((rt)->rt_nh);			\
 	     nhsel < (rt)->rt_nhn;					\
-	     nh++, nhsel++)
+	     __nh += rt->rt_nh_size, nh = (struct mpls_nh *)__nh, nhsel++)
 
 #define endfor_nexthops(rt) }
 
-- 
2.1.4
