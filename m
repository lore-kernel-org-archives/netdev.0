From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 6/6] bpf: add bpf_skb_change_type helper
Date: Tue, 28 Jun 2016 12:18:28 +0200
Message-ID: <00e9e29271e4dd7e6198a7babb4ba730ee64f830.1467106475.git.daniel@iogearbox.net>
References: <cover.1467106474.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, tgraf@suug.ch,
	netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:54345 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752453AbcF1Krz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jun 2016 06:47:55 -0400
In-Reply-To: <cover.1467106474.git.daniel@iogearbox.net>
In-Reply-To: <cover.1467106474.git.daniel@iogearbox.net>
References: <cover.1467106474.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This work adds a helper for changing skb->pkt_type in a controlled way.
We only allow a subset of possible values and can extend that in future
should other use cases come up. Doing this as a helper has the advantage
that errors can be handeled gracefully and thus helper kept extensible.

It's a write counterpart to pkt_type member we can already read from
struct __sk_buff context. Major use case is to change incoming skbs to
PACKET_HOST in a programmatic way instead of having to recirculate via
redirect(..., BPF_F_INGRESS), for example.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 include/uapi/linux/bpf.h |  9 +++++++++
 net/core/filter.c        | 24 ++++++++++++++++++++++++
 2 files changed, 33 insertions(+)

diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 66cd738..be6ac12 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -327,6 +327,15 @@ enum bpf_func_id {
 	 */
 	BPF_FUNC_skb_change_proto,
 
+	/**
+	 * bpf_skb_change_type(skb, type)
+	 * Change packet type of skb.
+	 * @skb: pointer to skb
+	 * @type: new skb->pkt_type type
+	 * Return: 0 on success or negative error
+	 */
+	BPF_FUNC_skb_change_type,
+
 	__BPF_FUNC_MAX_ID,
 };
 
diff --git a/net/core/filter.c b/net/core/filter.c
index d983e76..76f9a49 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -1979,6 +1979,28 @@ static const struct bpf_func_proto bpf_skb_change_proto_proto = {
 	.arg3_type	= ARG_ANYTHING,
 };
 
+static u64 bpf_skb_change_type(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
+{
+	struct sk_buff *skb = (struct sk_buff *) (long) r1;
+	u32 pkt_type = r2;
+
+	/* We only allow a restricted subset to be changed for now. */
+	if (unlikely(skb->pkt_type > PACKET_OTHERHOST ||
+		     pkt_type > PACKET_OTHERHOST))
+		return -EINVAL;
+
+	skb->pkt_type = pkt_type;
+	return 0;
+}
+
+static const struct bpf_func_proto bpf_skb_change_type_proto = {
+	.func		= bpf_skb_change_type,
+	.gpl_only	= false,
+	.ret_type	= RET_INTEGER,
+	.arg1_type	= ARG_PTR_TO_CTX,
+	.arg2_type	= ARG_ANYTHING,
+};
+
 bool bpf_helper_changes_skb_data(void *func)
 {
 	if (func == bpf_skb_vlan_push)
@@ -2278,6 +2300,8 @@ tc_cls_act_func_proto(enum bpf_func_id func_id)
 		return &bpf_skb_vlan_pop_proto;
 	case BPF_FUNC_skb_change_proto:
 		return &bpf_skb_change_proto_proto;
+	case BPF_FUNC_skb_change_type:
+		return &bpf_skb_change_type_proto;
 	case BPF_FUNC_skb_get_tunnel_key:
 		return &bpf_skb_get_tunnel_key_proto;
 	case BPF_FUNC_skb_set_tunnel_key:
-- 
1.9.3
