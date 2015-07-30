From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH net-next] bpf: add helpers to access tunnel metadata
Date: Thu, 30 Jul 2015 15:36:57 -0700
Message-ID: <1438295817-27295-1-git-send-email-ast@plumgrid.com>
Cc: Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:35096 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750744AbbG3WhJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jul 2015 18:37:09 -0400
Received: by pabkd10 with SMTP id kd10so29872892pab.2
        for <netdev@vger.kernel.org>; Thu, 30 Jul 2015 15:37:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Introduce helpers to let eBPF programs attached to TC manipulate tunnel metadata:
bpf_skb_[gs]et_tunnel_key(skb, key, size, flags)
skb: pointer to skb
key: pointer to 'struct bpf_tunnel_key'
size: size of 'struct bpf_tunnel_key'
flags: room for future extensions

First eBPF program that uses these helpers will allocate per_cpu
metadata_dst structures that will be used on TX.
On RX metadata_dst is allocated by tunnel driver.

Typical usage for TX:
struct bpf_tunnel_key tkey;
... populate tkey ...
bpf_skb_set_tunnel_key(skb, &tkey, sizeof(tkey), 0);
bpf_clone_redirect(skb, vxlan_dev_ifindex, 0);

RX:
struct bpf_tunnel_key tkey = {};
bpf_skb_get_tunnel_key(skb, &tkey, sizeof(tkey), 0);
... lookup or redirect based on tkey ...

'struct bpf_tunnel_key' will be extended in the future by adding
elements to the end and the 'size' argument will indicate which fields
are populated, thereby keeping backwards compatibility.
The 'flags' argument may be used as well when the 'size' is not enough or
to indicate completely different layout of bpf_tunnel_key.

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---

Here are two examples how these helpers are used to implement different
styles of distributed bridge:

- traditional vxlan style with multicast in the fabric:
https://github.com/iovisor/bcc/blob/master/examples/distributed_bridge/tunnel.c

- full mesh of point to point tunnels without multicast:
https://github.com/iovisor/bcc/blob/master/examples/distributed_bridge/tunnel_mesh.c

In both cases single vxlan netdev per host is used in flow mode and multiple
linux bridges on different hosts are stitched together via bpf programs to
form a distributed bridge.
bpf programs redirect packets from vxlan netdev to bridges and back using
 different lookup logic.

 include/net/dst_metadata.h |    1 +
 include/uapi/linux/bpf.h   |   17 ++++++++++
 net/core/dst.c             |   35 ++++++++++++++++----
 net/core/filter.c          |   77 ++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 124 insertions(+), 6 deletions(-)

diff --git a/include/net/dst_metadata.h b/include/net/dst_metadata.h
index 7b0306894663..075f523ff23f 100644
--- a/include/net/dst_metadata.h
+++ b/include/net/dst_metadata.h
@@ -51,5 +51,6 @@ static inline bool skb_valid_dst(const struct sk_buff *skb)
 }
 
 struct metadata_dst *metadata_dst_alloc(u8 optslen, gfp_t flags);
+struct metadata_dst __percpu *metadata_dst_alloc_percpu(u8 optslen, gfp_t flags);
 
 #endif /* __NET_DST_METADATA_H */
diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 2f6c83d714e9..bc0d27d3fbdd 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -258,6 +258,18 @@ enum bpf_func_id {
 	BPF_FUNC_get_cgroup_classid,
 	BPF_FUNC_skb_vlan_push, /* bpf_skb_vlan_push(skb, vlan_proto, vlan_tci) */
 	BPF_FUNC_skb_vlan_pop,  /* bpf_skb_vlan_pop(skb) */
+
+	/**
+	 * bpf_skb_[gs]et_tunnel_key(skb, key, size, flags)
+	 * retrieve or populate tunnel metadata
+	 * @skb: pointer to skb
+	 * @key: pointer to 'struct bpf_tunnel_key'
+	 * @size: size of 'struct bpf_tunnel_key'
+	 * @flags: room for future extensions
+	 * Retrun: 0 on success
+	 */
+	BPF_FUNC_skb_get_tunnel_key,
+	BPF_FUNC_skb_set_tunnel_key,
 	__BPF_FUNC_MAX_ID,
 };
 
@@ -280,4 +292,9 @@ struct __sk_buff {
 	__u32 cb[5];
 };
 
+struct bpf_tunnel_key {
+	__u32 tunnel_id;
+	__u32 remote_ipv4;
+};
+
 #endif /* _UAPI__LINUX_BPF_H__ */
diff --git a/net/core/dst.c b/net/core/dst.c
index 76a617f6d60a..f8694d1b8702 100644
--- a/net/core/dst.c
+++ b/net/core/dst.c
@@ -362,15 +362,10 @@ static int dst_md_discard(struct sk_buff *skb)
 	return 0;
 }
 
-struct metadata_dst *metadata_dst_alloc(u8 optslen, gfp_t flags)
+static void __metadata_dst_init(struct metadata_dst *md_dst, u8 optslen)
 {
-	struct metadata_dst *md_dst;
 	struct dst_entry *dst;
 
-	md_dst = kmalloc(sizeof(*md_dst) + optslen, flags);
-	if (!md_dst)
-		return ERR_PTR(-ENOMEM);
-
 	dst = &md_dst->dst;
 	dst_init(dst, &md_dst_ops, NULL, 1, DST_OBSOLETE_NONE,
 		 DST_METADATA | DST_NOCACHE | DST_NOCOUNT);
@@ -380,11 +375,39 @@ struct metadata_dst *metadata_dst_alloc(u8 optslen, gfp_t flags)
 
 	memset(dst + 1, 0, sizeof(*md_dst) + optslen - sizeof(*dst));
 	md_dst->opts_len = optslen;
+}
+
+struct metadata_dst *metadata_dst_alloc(u8 optslen, gfp_t flags)
+{
+	struct metadata_dst *md_dst;
+
+	md_dst = kmalloc(sizeof(*md_dst) + optslen, flags);
+	if (!md_dst)
+		return NULL;
+
+	__metadata_dst_init(md_dst, optslen);
 
 	return md_dst;
 }
 EXPORT_SYMBOL_GPL(metadata_dst_alloc);
 
+struct metadata_dst __percpu *metadata_dst_alloc_percpu(u8 optslen, gfp_t flags)
+{
+	int cpu;
+	struct metadata_dst __percpu *md_dst;
+
+	md_dst = __alloc_percpu_gfp(sizeof(struct metadata_dst) + optslen,
+				    __alignof__(struct metadata_dst), flags);
+	if (!md_dst)
+		return NULL;
+
+	for_each_possible_cpu(cpu)
+		__metadata_dst_init(per_cpu_ptr(md_dst, cpu), optslen);
+
+	return md_dst;
+}
+EXPORT_SYMBOL_GPL(metadata_dst_alloc_percpu);
+
 /* Dirty hack. We did it in 2.2 (in __dst_free),
  * we have _very_ good reasons not to repeat
  * this mistake in 2.3, but we have no choice
diff --git a/net/core/filter.c b/net/core/filter.c
index 786722a9c6f2..1b72264ff2ee 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -48,6 +48,7 @@
 #include <linux/bpf.h>
 #include <net/sch_generic.h>
 #include <net/cls_cgroup.h>
+#include <net/dst_metadata.h>
 
 /**
  *	sk_filter - run a packet through a socket filter
@@ -1483,6 +1484,78 @@ bool bpf_helper_changes_skb_data(void *func)
 	return false;
 }
 
+static u64 bpf_skb_get_tunnel_key(u64 r1, u64 r2, u64 size, u64 flags, u64 r5)
+{
+	struct sk_buff *skb = (struct sk_buff *) (long) r1;
+	struct bpf_tunnel_key *to = (struct bpf_tunnel_key *) (long) r2;
+	struct ip_tunnel_info *info = skb_tunnel_info(skb, AF_INET);
+
+	if (unlikely(size != sizeof(struct bpf_tunnel_key) || flags || !info))
+		return -EINVAL;
+
+	to->tunnel_id = be64_to_cpu(info->key.tun_id);
+	to->remote_ipv4 = be32_to_cpu(info->key.ipv4_src);
+
+	return 0;
+}
+
+const struct bpf_func_proto bpf_skb_get_tunnel_key_proto = {
+	.func		= bpf_skb_get_tunnel_key,
+	.gpl_only	= false,
+	.ret_type	= RET_INTEGER,
+	.arg1_type	= ARG_PTR_TO_CTX,
+	.arg2_type	= ARG_PTR_TO_STACK,
+	.arg3_type	= ARG_CONST_STACK_SIZE,
+	.arg4_type	= ARG_ANYTHING,
+};
+
+static struct metadata_dst __percpu *md_dst;
+
+static u64 bpf_skb_set_tunnel_key(u64 r1, u64 r2, u64 size, u64 flags, u64 r5)
+{
+	struct sk_buff *skb = (struct sk_buff *) (long) r1;
+	struct bpf_tunnel_key *from = (struct bpf_tunnel_key *) (long) r2;
+	struct metadata_dst *md = this_cpu_ptr(md_dst);
+	struct ip_tunnel_info *info;
+
+	if (unlikely(size != sizeof(struct bpf_tunnel_key) || flags))
+		return -EINVAL;
+
+	skb_dst_drop(skb);
+	dst_hold((struct dst_entry *) md);
+	skb_dst_set(skb, (struct dst_entry *) md);
+
+	info = &md->u.tun_info;
+	info->mode = IP_TUNNEL_INFO_TX;
+	info->key.tun_id = cpu_to_be64(from->tunnel_id);
+	info->key.ipv4_dst = cpu_to_be32(from->remote_ipv4);
+
+	return 0;
+}
+
+const struct bpf_func_proto bpf_skb_set_tunnel_key_proto = {
+	.func		= bpf_skb_set_tunnel_key,
+	.gpl_only	= false,
+	.ret_type	= RET_INTEGER,
+	.arg1_type	= ARG_PTR_TO_CTX,
+	.arg2_type	= ARG_PTR_TO_STACK,
+	.arg3_type	= ARG_CONST_STACK_SIZE,
+	.arg4_type	= ARG_ANYTHING,
+};
+
+static const struct bpf_func_proto *bpf_get_skb_set_tunnel_key_proto(void)
+{
+	if (!md_dst) {
+		/* race is not possible, since it's called from
+		 * verifier that is holding verifier mutex
+		 */
+		md_dst = metadata_dst_alloc_percpu(0, GFP_KERNEL);
+		if (!md_dst)
+			return NULL;
+	}
+	return &bpf_skb_set_tunnel_key_proto;
+}
+
 static const struct bpf_func_proto *
 sk_filter_func_proto(enum bpf_func_id func_id)
 {
@@ -1526,6 +1599,10 @@ tc_cls_act_func_proto(enum bpf_func_id func_id)
 		return &bpf_skb_vlan_push_proto;
 	case BPF_FUNC_skb_vlan_pop:
 		return &bpf_skb_vlan_pop_proto;
+	case BPF_FUNC_skb_get_tunnel_key:
+		return &bpf_skb_get_tunnel_key_proto;
+	case BPF_FUNC_skb_set_tunnel_key:
+		return bpf_get_skb_set_tunnel_key_proto();
 	default:
 		return sk_filter_func_proto(func_id);
 	}
-- 
1.7.9.5
