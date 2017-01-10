From: Sridhar Samudrala <sridhar.samudrala@intel.com>
Subject: [next-queue v3 PATCH 4/7] net: store port/representator id in metadata_dst
Date: Mon,  9 Jan 2017 16:59:47 -0800
Message-ID: <1484009990-3018-5-git-send-email-sridhar.samudrala@intel.com>
References: <1484009990-3018-1-git-send-email-sridhar.samudrala@intel.com>
To: alexander.h.duyck@intel.com, john.r.fastabend@intel.com,
        anjali.singhai@intel.com, jakub.kicinski@netronome.com,
        davem@davemloft.net, scott.d.peterson@intel.com,
        gerlitz.or@gmail.com, jiri@resnulli.us,
        intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:34309 "EHLO mga04.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S942621AbdAJBAA (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 9 Jan 2017 20:00:00 -0500
In-Reply-To: <1484009990-3018-1-git-send-email-sridhar.samudrala@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Switches and modern SR-IOV enabled NICs may multiplex traffic from Port
representators and control messages over single set of hardware queues.
Control messages and muxed traffic may need ordered delivery.

Those requirements make it hard to comfortably use TC infrastructure today
unless we have a way of attaching metadata to skbs at the upper device.
Because single set of queues is used for many netdevs stopping TC/sched queues
of all of them reliably is impossible and lower device has to retreat to
returning NETDEV_TX_BUSY and usually has to take extra locks on the fastpath.

This patch attempts to enable port/representative devs to attach metadata to
skbs which carry port id.  This way representatives can be queueless and all
queuing can be performed at the lower netdev in the usual way.

Traffic arriving on the port/representative interfaces will be have metadata
attached and will subsequently be queued to the lower device for transmission.
The lower device should recognize the metadata and translate it to HW specific
format which is most likely either a special header inserted before the network
headers or descriptor/metadata fields.

Metadata is associated with the lower device by storing the netdev pointer along
with port id so that if TC decides to redirect or mirror the new netdev will not
try to interpret it.

This is mostly for SR-IOV devices since switches don't have lower netdevs today.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Signed-off-by: Sridhar Samudrala <sridhar.samudrala@intel.com>
---
 include/net/dst_metadata.h     | 41 ++++++++++++++++++++++++++++++++---------
 net/core/dst.c                 | 15 ++++++++++-----
 net/core/filter.c              |  1 +
 net/ipv4/ip_tunnel_core.c      |  6 ++++--
 net/openvswitch/flow_netlink.c |  4 +++-
 5 files changed, 50 insertions(+), 17 deletions(-)

diff --git a/include/net/dst_metadata.h b/include/net/dst_metadata.h
index 701fc81..a803129 100644
--- a/include/net/dst_metadata.h
+++ b/include/net/dst_metadata.h
@@ -5,10 +5,22 @@
 #include <net/ip_tunnels.h>
 #include <net/dst.h>
 
+enum metadata_type {
+	METADATA_IP_TUNNEL,
+	METADATA_HW_PORT_MUX,
+};
+
+struct hw_port_info {
+	struct net_device *lower_dev;
+	u32 port_id;
+};
+
 struct metadata_dst {
 	struct dst_entry		dst;
+	enum metadata_type		type;
 	union {
 		struct ip_tunnel_info	tun_info;
+		struct hw_port_info	port_info;
 	} u;
 };
 
@@ -27,7 +39,7 @@ static inline struct ip_tunnel_info *skb_tunnel_info(struct sk_buff *skb)
 	struct metadata_dst *md_dst = skb_metadata_dst(skb);
 	struct dst_entry *dst;
 
-	if (md_dst)
+	if (md_dst && md_dst->type == METADATA_IP_TUNNEL)
 		return &md_dst->u.tun_info;
 
 	dst = skb_dst(skb);
@@ -55,22 +67,33 @@ static inline int skb_metadata_dst_cmp(const struct sk_buff *skb_a,
 	a = (const struct metadata_dst *) skb_dst(skb_a);
 	b = (const struct metadata_dst *) skb_dst(skb_b);
 
-	if (!a != !b || a->u.tun_info.options_len != b->u.tun_info.options_len)
+	if (!a != !b || a->type != b->type)
 		return 1;
 
-	return memcmp(&a->u.tun_info, &b->u.tun_info,
-		      sizeof(a->u.tun_info) + a->u.tun_info.options_len);
+	switch (a->type) {
+	case METADATA_HW_PORT_MUX:
+		return memcmp(&a->u.port_info, &b->u.port_info,
+			      sizeof(a->u.port_info));
+	case METADATA_IP_TUNNEL:
+		return memcmp(&a->u.tun_info, &b->u.tun_info,
+			      sizeof(a->u.tun_info) +
+					 a->u.tun_info.options_len);
+	default:
+		return 1;
+	}
 }
 
 void metadata_dst_free(struct metadata_dst *);
-struct metadata_dst *metadata_dst_alloc(u8 optslen, gfp_t flags);
-struct metadata_dst __percpu *metadata_dst_alloc_percpu(u8 optslen, gfp_t flags);
+struct metadata_dst *metadata_dst_alloc(u8 optslen, enum metadata_type type,
+					gfp_t flags);
+struct metadata_dst __percpu *
+metadata_dst_alloc_percpu(u8 optslen, enum metadata_type type, gfp_t flags);
 
 static inline struct metadata_dst *tun_rx_dst(int md_size)
 {
 	struct metadata_dst *tun_dst;
 
-	tun_dst = metadata_dst_alloc(md_size, GFP_ATOMIC);
+	tun_dst = metadata_dst_alloc(md_size, METADATA_IP_TUNNEL, GFP_ATOMIC);
 	if (!tun_dst)
 		return NULL;
 
@@ -85,11 +108,11 @@ static inline struct metadata_dst *tun_dst_unclone(struct sk_buff *skb)
 	int md_size;
 	struct metadata_dst *new_md;
 
-	if (!md_dst)
+	if (!md_dst || md_dst->type != METADATA_IP_TUNNEL)
 		return ERR_PTR(-EINVAL);
 
 	md_size = md_dst->u.tun_info.options_len;
-	new_md = metadata_dst_alloc(md_size, GFP_ATOMIC);
+	new_md = metadata_dst_alloc(md_size, METADATA_IP_TUNNEL, GFP_ATOMIC);
 	if (!new_md)
 		return ERR_PTR(-ENOMEM);
 
diff --git a/net/core/dst.c b/net/core/dst.c
index b5cbbe0..62dd4e4 100644
--- a/net/core/dst.c
+++ b/net/core/dst.c
@@ -367,7 +367,9 @@ static int dst_md_discard(struct sk_buff *skb)
 	return 0;
 }
 
-static void __metadata_dst_init(struct metadata_dst *md_dst, u8 optslen)
+static void __metadata_dst_init(struct metadata_dst *md_dst,
+				enum metadata_type type, u8 optslen)
+
 {
 	struct dst_entry *dst;
 
@@ -379,9 +381,11 @@ static void __metadata_dst_init(struct metadata_dst *md_dst, u8 optslen)
 	dst->output = dst_md_discard_out;
 
 	memset(dst + 1, 0, sizeof(*md_dst) + optslen - sizeof(*dst));
+	md_dst->type = type;
 }
 
-struct metadata_dst *metadata_dst_alloc(u8 optslen, gfp_t flags)
+struct metadata_dst *metadata_dst_alloc(u8 optslen, enum metadata_type type,
+					gfp_t flags)
 {
 	struct metadata_dst *md_dst;
 
@@ -389,7 +393,7 @@ struct metadata_dst *metadata_dst_alloc(u8 optslen, gfp_t flags)
 	if (!md_dst)
 		return NULL;
 
-	__metadata_dst_init(md_dst, optslen);
+	__metadata_dst_init(md_dst, type, optslen);
 
 	return md_dst;
 }
@@ -403,7 +407,8 @@ void metadata_dst_free(struct metadata_dst *md_dst)
 	kfree(md_dst);
 }
 
-struct metadata_dst __percpu *metadata_dst_alloc_percpu(u8 optslen, gfp_t flags)
+struct metadata_dst __percpu *
+metadata_dst_alloc_percpu(u8 optslen, enum metadata_type type, gfp_t flags)
 {
 	int cpu;
 	struct metadata_dst __percpu *md_dst;
@@ -414,7 +419,7 @@ struct metadata_dst __percpu *metadata_dst_alloc_percpu(u8 optslen, gfp_t flags)
 		return NULL;
 
 	for_each_possible_cpu(cpu)
-		__metadata_dst_init(per_cpu_ptr(md_dst, cpu), optslen);
+		__metadata_dst_init(per_cpu_ptr(md_dst, cpu), type, optslen);
 
 	return md_dst;
 }
diff --git a/net/core/filter.c b/net/core/filter.c
index 1969b3f..617ca0c 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -2521,6 +2521,7 @@ bpf_get_skb_set_tunnel_proto(enum bpf_func_id which)
 		 * that is holding verifier mutex.
 		 */
 		md_dst = metadata_dst_alloc_percpu(IP_TUNNEL_OPTS_MAX,
+						   METADATA_IP_TUNNEL,
 						   GFP_KERNEL);
 		if (!md_dst)
 			return NULL;
diff --git a/net/ipv4/ip_tunnel_core.c b/net/ipv4/ip_tunnel_core.c
index fed3d29..6b2dccd 100644
--- a/net/ipv4/ip_tunnel_core.c
+++ b/net/ipv4/ip_tunnel_core.c
@@ -134,10 +134,12 @@ struct metadata_dst *iptunnel_metadata_reply(struct metadata_dst *md,
 	struct metadata_dst *res;
 	struct ip_tunnel_info *dst, *src;
 
-	if (!md || md->u.tun_info.mode & IP_TUNNEL_INFO_TX)
+	if (!md || md->type != METADATA_IP_TUNNEL ||
+	    md->u.tun_info.mode & IP_TUNNEL_INFO_TX)
+
 		return NULL;
 
-	res = metadata_dst_alloc(0, flags);
+	res = metadata_dst_alloc(0, METADATA_IP_TUNNEL, flags);
 	if (!res)
 		return NULL;
 
diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
index c87d359..164b4f1 100644
--- a/net/openvswitch/flow_netlink.c
+++ b/net/openvswitch/flow_netlink.c
@@ -2105,7 +2105,9 @@ static int validate_and_copy_set_tun(const struct nlattr *attr,
 	if (start < 0)
 		return start;
 
-	tun_dst = metadata_dst_alloc(key.tun_opts_len, GFP_KERNEL);
+	tun_dst = metadata_dst_alloc(key.tun_opts_len, METADATA_IP_TUNNEL,
+				     GFP_KERNEL);
+
 	if (!tun_dst)
 		return -ENOMEM;
 
-- 
2.5.5
