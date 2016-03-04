From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 5/7] bpf: support for access to tunnel options
Date: Fri,  4 Mar 2016 15:15:06 +0100
Message-ID: <994b2a504c80406e2492326f0ae496234c9327be.1457099834.git.daniel@iogearbox.net>
References: <cover.1457099834.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, tgraf@suug.ch,
	netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:39200 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751852AbcCDOPe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Mar 2016 09:15:34 -0500
In-Reply-To: <cover.1457099834.git.daniel@iogearbox.net>
In-Reply-To: <cover.1457099834.git.daniel@iogearbox.net>
References: <cover.1457099834.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After eBPF being able to programmatically access/manage tunnel key meta
data via commit d3aa45ce6b94 ("bpf: add helpers to access tunnel metadata")
and more recently also for IPv6 through c6c33454072f ("bpf: support ipv6
for bpf_skb_{set,get}_tunnel_key"), this work adds two complementary
helpers to generically access their auxiliary tunnel options.

Geneve and vxlan support this facility. For geneve, TLVs can be pushed,
and for the vxlan case its GBP extension. I.e. setting tunnel key for geneve
case only makes sense, if we can also read/write TLVs into it. In the GBP
case, it provides the flexibility to easily map the group policy ID in
combination with other helpers or maps.

I chose to model this as two separate helpers, bpf_skb_{set,get}_tunnel_opt(),
for a couple of reasons. bpf_skb_{set,get}_tunnel_key() is already rather
complex by itself, and there may be cases for tunnel key backends where
tunnel options are not always needed. If we would have integrated this
into bpf_skb_{set,get}_tunnel_key() nevertheless, we are very limited with
remaining helper arguments, so keeping compatibility on structs in case of
passing in a flat buffer gets more cumbersome. Separating both also allows
for more flexibility and future extensibility, f.e. options could be fed
directly from a map, etc.

Moreover, change geneve's xmit path to test only for info->options_len
instead of TUNNEL_GENEVE_OPT flag. This makes it more consistent with vxlan's
xmit path and allows for avoiding to specify a protocol flag in the API on
xmit, so it can be protocol agnostic. Having info->options_len is enough
information that is needed. Tested with vxlan and geneve.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 drivers/net/geneve.c     |  4 +--
 include/uapi/linux/bpf.h | 11 +++++++
 net/core/filter.c        | 83 ++++++++++++++++++++++++++++++++++++++++++++----
 3 files changed, 90 insertions(+), 8 deletions(-)

diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
index bc5da35..36db4cf 100644
--- a/drivers/net/geneve.c
+++ b/drivers/net/geneve.c
@@ -940,7 +940,7 @@ static netdev_tx_t geneve_xmit_skb(struct sk_buff *skb, struct net_device *dev,
 		u8 vni[3];
 
 		tunnel_id_to_vni(key->tun_id, vni);
-		if (key->tun_flags & TUNNEL_GENEVE_OPT)
+		if (info->options_len)
 			opts = ip_tunnel_info_opts(info);
 
 		if (key->tun_flags & TUNNEL_CSUM)
@@ -1027,7 +1027,7 @@ static netdev_tx_t geneve6_xmit_skb(struct sk_buff *skb, struct net_device *dev,
 		u8 vni[3];
 
 		tunnel_id_to_vni(key->tun_id, vni);
-		if (key->tun_flags & TUNNEL_GENEVE_OPT)
+		if (info->options_len)
 			opts = ip_tunnel_info_opts(info);
 
 		if (key->tun_flags & TUNNEL_CSUM)
diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 06287bb..6b2ebd2 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -298,6 +298,17 @@ enum bpf_func_id {
 	 * Return: csum result
 	 */
 	BPF_FUNC_csum_diff,
+
+	/**
+	 * bpf_skb_[gs]et_tunnel_opt(skb, opt, size)
+	 * retrieve or populate tunnel options metadata
+	 * @skb: pointer to skb
+	 * @opt: pointer to raw tunnel option data
+	 * @size: size of @opt
+	 * Return: 0 on success for set, option size for get
+	 */
+	BPF_FUNC_skb_get_tunnel_opt,
+	BPF_FUNC_skb_set_tunnel_opt,
 	__BPF_FUNC_MAX_ID,
 };
 
diff --git a/net/core/filter.c b/net/core/filter.c
index 6c9d155..012a10c 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -1809,6 +1809,32 @@ static const struct bpf_func_proto bpf_skb_get_tunnel_key_proto = {
 	.arg4_type	= ARG_ANYTHING,
 };
 
+static u64 bpf_skb_get_tunnel_opt(u64 r1, u64 r2, u64 size, u64 r4, u64 r5)
+{
+	struct sk_buff *skb = (struct sk_buff *) (long) r1;
+	u8 *to = (u8 *) (long) r2;
+	const struct ip_tunnel_info *info = skb_tunnel_info(skb);
+
+	if (unlikely(!info ||
+		     !(info->key.tun_flags & TUNNEL_OPTIONS_PRESENT)))
+		return -ENOENT;
+	if (unlikely(size < info->options_len))
+		return -ENOMEM;
+
+	ip_tunnel_info_opts_get(to, info);
+
+	return info->options_len;
+}
+
+static const struct bpf_func_proto bpf_skb_get_tunnel_opt_proto = {
+	.func		= bpf_skb_get_tunnel_opt,
+	.gpl_only	= false,
+	.ret_type	= RET_INTEGER,
+	.arg1_type	= ARG_PTR_TO_CTX,
+	.arg2_type	= ARG_PTR_TO_STACK,
+	.arg3_type	= ARG_CONST_STACK_SIZE,
+};
+
 static struct metadata_dst __percpu *md_dst;
 
 static u64 bpf_skb_set_tunnel_key(u64 r1, u64 r2, u64 size, u64 flags, u64 r5)
@@ -1875,17 +1901,58 @@ static const struct bpf_func_proto bpf_skb_set_tunnel_key_proto = {
 	.arg4_type	= ARG_ANYTHING,
 };
 
-static const struct bpf_func_proto *bpf_get_skb_set_tunnel_key_proto(void)
+#define BPF_TUNLEN_MAX	255
+
+static u64 bpf_skb_set_tunnel_opt(u64 r1, u64 r2, u64 size, u64 r4, u64 r5)
+{
+	struct sk_buff *skb = (struct sk_buff *) (long) r1;
+	u8 *from = (u8 *) (long) r2;
+	struct ip_tunnel_info *info = skb_tunnel_info(skb);
+	const struct metadata_dst *md = this_cpu_ptr(md_dst);
+
+	if (unlikely(info != &md->u.tun_info || (size & (sizeof(u32) - 1))))
+		return -EINVAL;
+	if (unlikely(size > BPF_TUNLEN_MAX))
+		return -ENOMEM;
+
+	ip_tunnel_info_opts_set(info, from, size);
+
+	return 0;
+}
+
+static const struct bpf_func_proto bpf_skb_set_tunnel_opt_proto = {
+	.func		= bpf_skb_set_tunnel_opt,
+	.gpl_only	= false,
+	.ret_type	= RET_INTEGER,
+	.arg1_type	= ARG_PTR_TO_CTX,
+	.arg2_type	= ARG_PTR_TO_STACK,
+	.arg3_type	= ARG_CONST_STACK_SIZE,
+};
+
+static const struct bpf_func_proto *
+bpf_get_skb_set_tunnel_proto(enum bpf_func_id which)
 {
 	if (!md_dst) {
-		/* race is not possible, since it's called from
-		 * verifier that is holding verifier mutex
+		BUILD_BUG_ON(FIELD_SIZEOF(struct ip_tunnel_info,
+					  options_len) != 1);
+
+		/* Race is not possible, since it's called from verifier
+		 * that is holding verifier mutex.
 		 */
-		md_dst = metadata_dst_alloc_percpu(0, GFP_KERNEL);
+		md_dst = metadata_dst_alloc_percpu(BPF_TUNLEN_MAX,
+						   GFP_KERNEL);
 		if (!md_dst)
 			return NULL;
 	}
-	return &bpf_skb_set_tunnel_key_proto;
+
+	switch (which) {
+	case BPF_FUNC_skb_set_tunnel_key:
+		return &bpf_skb_set_tunnel_key_proto;
+	case BPF_FUNC_skb_set_tunnel_opt:
+		return &bpf_skb_set_tunnel_opt_proto;
+	default:
+		return NULL;
+	}
 }
 
 static const struct bpf_func_proto *
@@ -1939,7 +2006,11 @@ tc_cls_act_func_proto(enum bpf_func_id func_id)
 	case BPF_FUNC_skb_get_tunnel_key:
 		return &bpf_skb_get_tunnel_key_proto;
 	case BPF_FUNC_skb_set_tunnel_key:
-		return bpf_get_skb_set_tunnel_key_proto();
+		return bpf_get_skb_set_tunnel_proto(func_id);
+	case BPF_FUNC_skb_get_tunnel_opt:
+		return &bpf_skb_get_tunnel_opt_proto;
+	case BPF_FUNC_skb_set_tunnel_opt:
+		return bpf_get_skb_set_tunnel_proto(func_id);
 	case BPF_FUNC_redirect:
 		return &bpf_redirect_proto;
 	case BPF_FUNC_get_route_realm:
-- 
1.9.3
