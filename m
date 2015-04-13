From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 08/21] netfilter: nf_tables: convert expressions to u32 register pointers
Date: Mon, 13 Apr 2015 21:29:47 +0200
Message-ID: <1428953401-4838-9-git-send-email-pablo@netfilter.org>
References: <1428953401-4838-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1428953401-4838-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>

Simple conversion to use u32 pointers to the beginning of the registers
to keep follow up patches smaller.

Signed-off-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/bridge/netfilter/nft_meta_bridge.c |    4 +--
 net/netfilter/nf_tables_core.c         |    8 ++---
 net/netfilter/nft_bitwise.c            |   10 +++---
 net/netfilter/nft_byteorder.c          |    8 ++---
 net/netfilter/nft_ct.c                 |   38 +++++++++++-----------
 net/netfilter/nft_exthdr.c             |    4 +--
 net/netfilter/nft_meta.c               |   54 +++++++++++++++-----------------
 net/netfilter/nft_payload.c            |    4 +--
 8 files changed, 63 insertions(+), 67 deletions(-)

diff --git a/net/bridge/netfilter/nft_meta_bridge.c b/net/bridge/netfilter/nft_meta_bridge.c
index f0dfa38..6184b15 100644
--- a/net/bridge/netfilter/nft_meta_bridge.c
+++ b/net/bridge/netfilter/nft_meta_bridge.c
@@ -24,7 +24,7 @@ static void nft_meta_bridge_get_eval(const struct nft_expr *expr,
 {
 	const struct nft_meta *priv = nft_expr_priv(expr);
 	const struct net_device *in = pkt->in, *out = pkt->out;
-	struct nft_data *dest = &regs->data[priv->dreg];
+	u32 *dest = &regs->data[priv->dreg].data[0];
 	const struct net_bridge_port *p;
 
 	switch (priv->key) {
@@ -40,7 +40,7 @@ static void nft_meta_bridge_get_eval(const struct nft_expr *expr,
 		goto out;
 	}
 
-	strncpy((char *)dest->data, p->br->dev->name, sizeof(dest->data));
+	strncpy((char *)dest, p->br->dev->name, IFNAMSIZ);
 	return;
 out:
 	return nft_meta_get_eval(expr, regs, pkt);
diff --git a/net/netfilter/nf_tables_core.c b/net/netfilter/nf_tables_core.c
index 667cdf0..5ef07d1 100644
--- a/net/netfilter/nf_tables_core.c
+++ b/net/netfilter/nf_tables_core.c
@@ -81,7 +81,7 @@ static bool nft_payload_fast_eval(const struct nft_expr *expr,
 {
 	const struct nft_payload *priv = nft_expr_priv(expr);
 	const struct sk_buff *skb = pkt->skb;
-	struct nft_data *dest = &regs->data[priv->dreg];
+	u32 *dest = &regs->data[priv->dreg].data[0];
 	unsigned char *ptr;
 
 	if (priv->base == NFT_PAYLOAD_NETWORK_HEADER)
@@ -95,11 +95,11 @@ static bool nft_payload_fast_eval(const struct nft_expr *expr,
 		return false;
 
 	if (priv->len == 2)
-		*(u16 *)dest->data = *(u16 *)ptr;
+		*(u16 *)dest = *(u16 *)ptr;
 	else if (priv->len == 4)
-		*(u32 *)dest->data = *(u32 *)ptr;
+		*(u32 *)dest = *(u32 *)ptr;
 	else
-		*(u8 *)dest->data = *(u8 *)ptr;
+		*(u8 *)dest = *(u8 *)ptr;
 	return true;
 }
 
diff --git a/net/netfilter/nft_bitwise.c b/net/netfilter/nft_bitwise.c
index 2b8f518..d55b545 100644
--- a/net/netfilter/nft_bitwise.c
+++ b/net/netfilter/nft_bitwise.c
@@ -30,14 +30,12 @@ static void nft_bitwise_eval(const struct nft_expr *expr,
 			     const struct nft_pktinfo *pkt)
 {
 	const struct nft_bitwise *priv = nft_expr_priv(expr);
-	const struct nft_data *src = &regs->data[priv->sreg];
-	struct nft_data *dst = &regs->data[priv->dreg];
+	const u32  *src = &regs->data[priv->sreg].data[0];
+	u32 *dst = &regs->data[priv->dreg].data[0];
 	unsigned int i;
 
-	for (i = 0; i < DIV_ROUND_UP(priv->len, 4); i++) {
-		dst->data[i] = (src->data[i] & priv->mask.data[i]) ^
-			       priv->xor.data[i];
-	}
+	for (i = 0; i < DIV_ROUND_UP(priv->len, 4); i++)
+		dst[i] = (src[i] & priv->mask.data[i]) ^ priv->xor.data[i];
 }
 
 static const struct nla_policy nft_bitwise_policy[NFTA_BITWISE_MAX + 1] = {
diff --git a/net/netfilter/nft_byteorder.c b/net/netfilter/nft_byteorder.c
index 48fbfa3..d6290db 100644
--- a/net/netfilter/nft_byteorder.c
+++ b/net/netfilter/nft_byteorder.c
@@ -30,13 +30,13 @@ static void nft_byteorder_eval(const struct nft_expr *expr,
 			       const struct nft_pktinfo *pkt)
 {
 	const struct nft_byteorder *priv = nft_expr_priv(expr);
-	struct nft_data *src = &regs->data[priv->sreg];
-	struct nft_data *dst = &regs->data[priv->dreg];
+	u32 *src = &regs->data[priv->sreg].data[0];
+	u32 *dst = &regs->data[priv->dreg].data[0];
 	union { u32 u32; u16 u16; } *s, *d;
 	unsigned int i;
 
-	s = (void *)src->data;
-	d = (void *)dst->data;
+	s = (void *)src;
+	d = (void *)dst;
 
 	switch (priv->size) {
 	case 4:
diff --git a/net/netfilter/nft_ct.c b/net/netfilter/nft_ct.c
index 077e06b..0166f28c 100644
--- a/net/netfilter/nft_ct.c
+++ b/net/netfilter/nft_ct.c
@@ -35,7 +35,7 @@ static void nft_ct_get_eval(const struct nft_expr *expr,
 			    const struct nft_pktinfo *pkt)
 {
 	const struct nft_ct *priv = nft_expr_priv(expr);
-	struct nft_data *dest = &regs->data[priv->dreg];
+	u32 *dest = &regs->data[priv->dreg].data[0];
 	enum ip_conntrack_info ctinfo;
 	const struct nf_conn *ct;
 	const struct nf_conn_help *help;
@@ -54,7 +54,7 @@ static void nft_ct_get_eval(const struct nft_expr *expr,
 			state = NF_CT_STATE_UNTRACKED_BIT;
 		else
 			state = NF_CT_STATE_BIT(ctinfo);
-		dest->data[0] = state;
+		*dest = state;
 		return;
 	default:
 		break;
@@ -65,26 +65,26 @@ static void nft_ct_get_eval(const struct nft_expr *expr,
 
 	switch (priv->key) {
 	case NFT_CT_DIRECTION:
-		dest->data[0] = CTINFO2DIR(ctinfo);
+		*dest = CTINFO2DIR(ctinfo);
 		return;
 	case NFT_CT_STATUS:
-		dest->data[0] = ct->status;
+		*dest = ct->status;
 		return;
 #ifdef CONFIG_NF_CONNTRACK_MARK
 	case NFT_CT_MARK:
-		dest->data[0] = ct->mark;
+		*dest = ct->mark;
 		return;
 #endif
 #ifdef CONFIG_NF_CONNTRACK_SECMARK
 	case NFT_CT_SECMARK:
-		dest->data[0] = ct->secmark;
+		*dest = ct->secmark;
 		return;
 #endif
 	case NFT_CT_EXPIRATION:
 		diff = (long)jiffies - (long)ct->timeout.expires;
 		if (diff < 0)
 			diff = 0;
-		dest->data[0] = jiffies_to_msecs(diff);
+		*dest = jiffies_to_msecs(diff);
 		return;
 	case NFT_CT_HELPER:
 		if (ct->master == NULL)
@@ -95,7 +95,7 @@ static void nft_ct_get_eval(const struct nft_expr *expr,
 		helper = rcu_dereference(help->helper);
 		if (helper == NULL)
 			goto err;
-		strncpy((char *)dest->data, helper->name, sizeof(dest->data));
+		strncpy((char *)dest, helper->name, NF_CT_HELPER_NAME_LEN);
 		return;
 #ifdef CONFIG_NF_CONNTRACK_LABELS
 	case NFT_CT_LABELS: {
@@ -103,15 +103,15 @@ static void nft_ct_get_eval(const struct nft_expr *expr,
 		unsigned int size;
 
 		if (!labels) {
-			memset(dest->data, 0, sizeof(dest->data));
+			memset(dest, 0, NF_CT_LABELS_MAX_SIZE);
 			return;
 		}
 
 		size = labels->words * sizeof(long);
-		memcpy(dest->data, labels->bits, size);
-		if (size < sizeof(dest->data))
-			memset(((char *) dest->data) + size, 0,
-			       sizeof(dest->data) - size);
+		memcpy(dest, labels->bits, size);
+		if (size < NF_CT_LABELS_MAX_SIZE)
+			memset(((char *) dest) + size, 0,
+			       NF_CT_LABELS_MAX_SIZE - size);
 		return;
 	}
 #endif
@@ -122,24 +122,24 @@ static void nft_ct_get_eval(const struct nft_expr *expr,
 	tuple = &ct->tuplehash[priv->dir].tuple;
 	switch (priv->key) {
 	case NFT_CT_L3PROTOCOL:
-		dest->data[0] = nf_ct_l3num(ct);
+		*dest = nf_ct_l3num(ct);
 		return;
 	case NFT_CT_SRC:
-		memcpy(dest->data, tuple->src.u3.all,
+		memcpy(dest, tuple->src.u3.all,
 		       nf_ct_l3num(ct) == NFPROTO_IPV4 ? 4 : 16);
 		return;
 	case NFT_CT_DST:
-		memcpy(dest->data, tuple->dst.u3.all,
+		memcpy(dest, tuple->dst.u3.all,
 		       nf_ct_l3num(ct) == NFPROTO_IPV4 ? 4 : 16);
 		return;
 	case NFT_CT_PROTOCOL:
-		dest->data[0] = nf_ct_protonum(ct);
+		*dest = nf_ct_protonum(ct);
 		return;
 	case NFT_CT_PROTO_SRC:
-		dest->data[0] = (__force __u16)tuple->src.u.all;
+		*dest = (__force __u16)tuple->src.u.all;
 		return;
 	case NFT_CT_PROTO_DST:
-		dest->data[0] = (__force __u16)tuple->dst.u.all;
+		*dest = (__force __u16)tuple->dst.u.all;
 		return;
 	default:
 		break;
diff --git a/net/netfilter/nft_exthdr.c b/net/netfilter/nft_exthdr.c
index 2480af7..a85db75 100644
--- a/net/netfilter/nft_exthdr.c
+++ b/net/netfilter/nft_exthdr.c
@@ -30,7 +30,7 @@ static void nft_exthdr_eval(const struct nft_expr *expr,
 			    const struct nft_pktinfo *pkt)
 {
 	struct nft_exthdr *priv = nft_expr_priv(expr);
-	struct nft_data *dest = &regs->data[priv->dreg];
+	u32 *dest = &regs->data[priv->dreg].data[0];
 	unsigned int offset = 0;
 	int err;
 
@@ -39,7 +39,7 @@ static void nft_exthdr_eval(const struct nft_expr *expr,
 		goto err;
 	offset += priv->offset;
 
-	if (skb_copy_bits(pkt->skb, offset, dest->data, priv->len) < 0)
+	if (skb_copy_bits(pkt->skb, offset, dest, priv->len) < 0)
 		goto err;
 	return;
 err:
diff --git a/net/netfilter/nft_meta.c b/net/netfilter/nft_meta.c
index 3f11c0b..a6da806 100644
--- a/net/netfilter/nft_meta.c
+++ b/net/netfilter/nft_meta.c
@@ -31,56 +31,56 @@ void nft_meta_get_eval(const struct nft_expr *expr,
 	const struct nft_meta *priv = nft_expr_priv(expr);
 	const struct sk_buff *skb = pkt->skb;
 	const struct net_device *in = pkt->in, *out = pkt->out;
-	struct nft_data *dest = &regs->data[priv->dreg];
+	u32 *dest = &regs->data[priv->dreg].data[0];
 
 	switch (priv->key) {
 	case NFT_META_LEN:
-		dest->data[0] = skb->len;
+		*dest = skb->len;
 		break;
 	case NFT_META_PROTOCOL:
-		*(__be16 *)dest->data = skb->protocol;
+		*(__be16 *)dest = skb->protocol;
 		break;
 	case NFT_META_NFPROTO:
-		dest->data[0] = pkt->ops->pf;
+		*dest = pkt->ops->pf;
 		break;
 	case NFT_META_L4PROTO:
-		dest->data[0] = pkt->tprot;
+		*dest = pkt->tprot;
 		break;
 	case NFT_META_PRIORITY:
-		dest->data[0] = skb->priority;
+		*dest = skb->priority;
 		break;
 	case NFT_META_MARK:
-		dest->data[0] = skb->mark;
+		*dest = skb->mark;
 		break;
 	case NFT_META_IIF:
 		if (in == NULL)
 			goto err;
-		dest->data[0] = in->ifindex;
+		*dest = in->ifindex;
 		break;
 	case NFT_META_OIF:
 		if (out == NULL)
 			goto err;
-		dest->data[0] = out->ifindex;
+		*dest = out->ifindex;
 		break;
 	case NFT_META_IIFNAME:
 		if (in == NULL)
 			goto err;
-		strncpy((char *)dest->data, in->name, sizeof(dest->data));
+		strncpy((char *)dest, in->name, IFNAMSIZ);
 		break;
 	case NFT_META_OIFNAME:
 		if (out == NULL)
 			goto err;
-		strncpy((char *)dest->data, out->name, sizeof(dest->data));
+		strncpy((char *)dest, out->name, IFNAMSIZ);
 		break;
 	case NFT_META_IIFTYPE:
 		if (in == NULL)
 			goto err;
-		*(u16 *)dest->data = in->type;
+		*(u16 *)dest = in->type;
 		break;
 	case NFT_META_OIFTYPE:
 		if (out == NULL)
 			goto err;
-		*(u16 *)dest->data = out->type;
+		*(u16 *)dest = out->type;
 		break;
 	case NFT_META_SKUID:
 		if (skb->sk == NULL || !sk_fullsock(skb->sk))
@@ -93,8 +93,7 @@ void nft_meta_get_eval(const struct nft_expr *expr,
 			goto err;
 		}
 
-		dest->data[0] =
-			from_kuid_munged(&init_user_ns,
+		*dest =	from_kuid_munged(&init_user_ns,
 				skb->sk->sk_socket->file->f_cred->fsuid);
 		read_unlock_bh(&skb->sk->sk_callback_lock);
 		break;
@@ -108,8 +107,7 @@ void nft_meta_get_eval(const struct nft_expr *expr,
 			read_unlock_bh(&skb->sk->sk_callback_lock);
 			goto err;
 		}
-		dest->data[0] =
-			from_kgid_munged(&init_user_ns,
+		*dest =	from_kgid_munged(&init_user_ns,
 				 skb->sk->sk_socket->file->f_cred->fsgid);
 		read_unlock_bh(&skb->sk->sk_callback_lock);
 		break;
@@ -119,33 +117,33 @@ void nft_meta_get_eval(const struct nft_expr *expr,
 
 		if (dst == NULL)
 			goto err;
-		dest->data[0] = dst->tclassid;
+		*dest = dst->tclassid;
 		break;
 	}
 #endif
 #ifdef CONFIG_NETWORK_SECMARK
 	case NFT_META_SECMARK:
-		dest->data[0] = skb->secmark;
+		*dest = skb->secmark;
 		break;
 #endif
 	case NFT_META_PKTTYPE:
 		if (skb->pkt_type != PACKET_LOOPBACK) {
-			dest->data[0] = skb->pkt_type;
+			*dest = skb->pkt_type;
 			break;
 		}
 
 		switch (pkt->ops->pf) {
 		case NFPROTO_IPV4:
 			if (ipv4_is_multicast(ip_hdr(skb)->daddr))
-				dest->data[0] = PACKET_MULTICAST;
+				*dest = PACKET_MULTICAST;
 			else
-				dest->data[0] = PACKET_BROADCAST;
+				*dest = PACKET_BROADCAST;
 			break;
 		case NFPROTO_IPV6:
 			if (ipv6_hdr(skb)->daddr.s6_addr[0] == 0xFF)
-				dest->data[0] = PACKET_MULTICAST;
+				*dest = PACKET_MULTICAST;
 			else
-				dest->data[0] = PACKET_BROADCAST;
+				*dest = PACKET_BROADCAST;
 			break;
 		default:
 			WARN_ON(1);
@@ -153,22 +151,22 @@ void nft_meta_get_eval(const struct nft_expr *expr,
 		}
 		break;
 	case NFT_META_CPU:
-		dest->data[0] = raw_smp_processor_id();
+		*dest = raw_smp_processor_id();
 		break;
 	case NFT_META_IIFGROUP:
 		if (in == NULL)
 			goto err;
-		dest->data[0] = in->group;
+		*dest = in->group;
 		break;
 	case NFT_META_OIFGROUP:
 		if (out == NULL)
 			goto err;
-		dest->data[0] = out->group;
+		*dest = out->group;
 		break;
 	case NFT_META_CGROUP:
 		if (skb->sk == NULL || !sk_fullsock(skb->sk))
 			goto err;
-		dest->data[0] = skb->sk->sk_classid;
+		*dest = skb->sk->sk_classid;
 		break;
 	default:
 		WARN_ON(1);
diff --git a/net/netfilter/nft_payload.c b/net/netfilter/nft_payload.c
index 14247c5..6bb0592 100644
--- a/net/netfilter/nft_payload.c
+++ b/net/netfilter/nft_payload.c
@@ -23,7 +23,7 @@ static void nft_payload_eval(const struct nft_expr *expr,
 {
 	const struct nft_payload *priv = nft_expr_priv(expr);
 	const struct sk_buff *skb = pkt->skb;
-	struct nft_data *dest = &regs->data[priv->dreg];
+	u32 *dest = &regs->data[priv->dreg].data[0];
 	int offset;
 
 	switch (priv->base) {
@@ -43,7 +43,7 @@ static void nft_payload_eval(const struct nft_expr *expr,
 	}
 	offset += priv->offset;
 
-	if (skb_copy_bits(skb, offset, dest->data, priv->len) < 0)
+	if (skb_copy_bits(skb, offset, dest, priv->len) < 0)
 		goto err;
 	return;
 err:
-- 
1.7.10.4

