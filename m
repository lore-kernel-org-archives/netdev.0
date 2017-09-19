From: Tom Herbert <tom@quantonium.net>
Subject: [PATCH net-next 07/14] gtp: Support encapsulation of IPv6 packets
Date: Mon, 18 Sep 2017 17:38:57 -0700
Message-ID: <20170919003904.5124-8-tom@quantonium.net>
References: <20170919003904.5124-1-tom@quantonium.net>
Cc: netdev@vger.kernel.org, pablo@netfilter.org, laforge@gnumonks.org,
        rohit@quantonium.net, Tom Herbert <tom@quantonium.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f50.google.com ([74.125.83.50]:46857 "EHLO
        mail-pg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751451AbdISAjt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 18 Sep 2017 20:39:49 -0400
Received: by mail-pg0-f50.google.com with SMTP id i130so1093412pgc.3
        for <netdev@vger.kernel.org>; Mon, 18 Sep 2017 17:39:49 -0700 (PDT)
In-Reply-To: <20170919003904.5124-1-tom@quantonium.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow IPv6 mobile subscriber packets. This entails adding an IPv6 mobile
subscriber address to pdp context and IPv6 specific variants to find pdp
contexts by address.

Signed-off-by: Tom Herbert <tom@quantonium.net>
---
 drivers/net/gtp.c        | 259 +++++++++++++++++++++++++++++++++++++----------
 include/uapi/linux/gtp.h |   1 +
 2 files changed, 209 insertions(+), 51 deletions(-)

diff --git a/drivers/net/gtp.c b/drivers/net/gtp.c
index a928279c382c..62c0c968efa6 100644
--- a/drivers/net/gtp.c
+++ b/drivers/net/gtp.c
@@ -54,9 +54,13 @@ struct pdp_ctx {
 	} u;
 	u8			gtp_version;
 	__be16			gtp_port;
-	u16			af;
 
-	struct in_addr		ms_addr_ip4;
+	u16			ms_af;
+	union {
+		struct in_addr	ms_addr_ip4;
+		struct in6_addr	ms_addr_ip6;
+	};
+
 	struct in_addr		peer_addr_ip4;
 
 	struct sock		*sk;
@@ -80,7 +84,9 @@ struct gtp_dev {
 	unsigned int		role;
 	unsigned int		hash_size;
 	struct hlist_head	*tid_hash;
-	struct hlist_head	*addr_hash;
+
+	struct hlist_head	*addr4_hash;
+	struct hlist_head	*addr6_hash;
 
 	struct gro_cells	gro_cells;
 };
@@ -98,6 +104,7 @@ static void pdp_context_delete(struct pdp_ctx *pctx);
 static inline u32 gtp0_hashfn(u64 tid)
 {
 	u32 *tid32 = (u32 *) &tid;
+
 	return jhash_2words(tid32[0], tid32[1], gtp_h_initval);
 }
 
@@ -111,6 +118,11 @@ static inline u32 ipv4_hashfn(__be32 ip)
 	return jhash_1word((__force u32)ip, gtp_h_initval);
 }
 
+static inline u32 ipv6_hashfn(const struct in6_addr *a)
+{
+	return __ipv6_addr_jhash(a, gtp_h_initval);
+}
+
 /* Resolve a PDP context structure based on the 64bit TID. */
 static struct pdp_ctx *gtp0_pdp_find(struct gtp_dev *gtp, u64 tid)
 {
@@ -149,10 +161,10 @@ static struct pdp_ctx *ipv4_pdp_find(struct gtp_dev *gtp, __be32 ms_addr)
 	struct hlist_head *head;
 	struct pdp_ctx *pdp;
 
-	head = &gtp->addr_hash[ipv4_hashfn(ms_addr) % gtp->hash_size];
+	head = &gtp->addr4_hash[ipv4_hashfn(ms_addr) % gtp->hash_size];
 
 	hlist_for_each_entry_rcu(pdp, head, hlist_addr) {
-		if (pdp->af == AF_INET &&
+		if (pdp->ms_af == AF_INET &&
 		    pdp->ms_addr_ip4.s_addr == ms_addr)
 			return pdp;
 	}
@@ -176,32 +188,95 @@ static bool gtp_check_ms_ipv4(struct sk_buff *skb, struct pdp_ctx *pctx,
 		return iph->saddr == pctx->ms_addr_ip4.s_addr;
 }
 
+/* Resolve a PDP context based on IPv6 address of MS. */
+static struct pdp_ctx *ipv6_pdp_find(struct gtp_dev *gtp,
+				     const struct in6_addr *ms_addr)
+{
+	struct hlist_head *head;
+	struct pdp_ctx *pdp;
+
+	head = &gtp->addr6_hash[ipv6_hashfn(ms_addr) % gtp->hash_size];
+
+	hlist_for_each_entry_rcu(pdp, head, hlist_addr) {
+		if (pdp->ms_af == AF_INET6 &&
+		    ipv6_addr_equal(&pdp->ms_addr_ip6, ms_addr))
+			return pdp;
+	}
+
+	return NULL;
+}
+
+static bool gtp_check_ms_ipv6(struct sk_buff *skb, struct pdp_ctx *pctx,
+			      unsigned int hdrlen, unsigned int role)
+{
+	struct ipv6hdr *ipv6h;
+
+	if (!pskb_may_pull(skb, hdrlen + sizeof(struct ipv6hdr)))
+		return false;
+
+	ipv6h = (struct ipv6hdr *)(skb->data + hdrlen);
+
+	if (role == GTP_ROLE_SGSN)
+		return ipv6_addr_equal(&ipv6h->daddr, &pctx->ms_addr_ip6);
+	else
+		return ipv6_addr_equal(&ipv6h->saddr, &pctx->ms_addr_ip6);
+}
+
 /* Check if the inner IP address in this packet is assigned to any
  * existing mobile subscriber.
  */
 static bool gtp_check_ms(struct sk_buff *skb, struct pdp_ctx *pctx,
 			     unsigned int hdrlen, unsigned int role)
 {
-	switch (ntohs(skb->protocol)) {
-	case ETH_P_IP:
+	struct iphdr *iph;
+
+	/* Minimally there needs to be an IPv4 header */
+	if (!pskb_may_pull(skb, hdrlen + sizeof(struct iphdr)))
+		return false;
+
+	iph = (struct iphdr *)(skb->data + hdrlen);
+
+	switch (iph->version) {
+	case 4:
 		return gtp_check_ms_ipv4(skb, pctx, hdrlen, role);
+	case 6:
+		return gtp_check_ms_ipv6(skb, pctx, hdrlen, role);
 	}
+
 	return false;
 }
 
+static u16 ipver_to_eth(struct iphdr *iph)
+{
+	switch (iph->version) {
+	case 4:
+		return htons(ETH_P_IP);
+	case 6:
+		return htons(ETH_P_IPV6);
+	default:
+		return 0;
+	}
+}
+
 static int gtp_rx(struct pdp_ctx *pctx, struct sk_buff *skb,
-			unsigned int hdrlen, unsigned int role)
+		  unsigned int hdrlen, unsigned int role)
 {
 	struct pcpu_sw_netstats *stats;
+	u16 inner_protocol;
 
 	if (!gtp_check_ms(skb, pctx, hdrlen, role)) {
 		netdev_dbg(pctx->dev, "No PDP ctx for this MS\n");
 		return 1;
 	}
 
+	inner_protocol = ipver_to_eth((struct iphdr *)(skb->data + hdrlen));
+	if (!inner_protocol)
+		return -1;
+
 	/* Get rid of the GTP + UDP headers. */
-	if (iptunnel_pull_header(skb, hdrlen, skb->protocol,
-				 !net_eq(sock_net(pctx->sk), dev_net(pctx->dev))))
+	if (iptunnel_pull_header(skb, hdrlen, inner_protocol,
+				 !net_eq(sock_net(pctx->sk),
+					 dev_net(pctx->dev))))
 		return -1;
 
 	netdev_dbg(pctx->dev, "forwarding packet from GGSN to uplink\n");
@@ -239,7 +314,8 @@ static int gtp0_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
 	if (!gtp)
 		goto pass;
 
-	if (!pskb_may_pull(skb, hdrlen))
+	/* Pull through IP header since gtp_rx looks at IP version */
+	if (!pskb_may_pull(skb, hdrlen + sizeof(struct iphdr)))
 		goto drop;
 
 	gtp0 = (struct gtp0_header *)(skb->data + sizeof(struct udphdr));
@@ -285,7 +361,8 @@ static int gtp1u_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
 	if (!gtp)
 		goto pass;
 
-	if (!pskb_may_pull(skb, hdrlen))
+	/* Pull through IP header since gtp_rx looks at IP version */
+	if (!pskb_may_pull(skb, hdrlen + sizeof(struct iphdr)))
 		goto drop;
 
 	gtp1 = (struct gtp1_header *)(skb->data + sizeof(struct udphdr));
@@ -307,8 +384,10 @@ static int gtp1u_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
 	if (gtp1->flags & GTP1_F_MASK)
 		hdrlen += 4;
 
-	/* Make sure the header is larger enough, including extensions. */
-	if (!pskb_may_pull(skb, hdrlen))
+	/* Make sure the header is larger enough, including extensions and
+	 * also an IP header since gtp_rx looks at IP version
+	 */
+	if (!pskb_may_pull(skb, hdrlen + sizeof(struct iphdr)))
 		goto drop;
 
 	gtp1 = (struct gtp1_header *)(skb->data + sizeof(struct udphdr));
@@ -389,7 +468,8 @@ static inline void gtp0_push_header(struct sk_buff *skb, struct pdp_ctx *pctx)
 	gtp0->flags	= 0x1e; /* v0, GTP-non-prime. */
 	gtp0->type	= GTP_TPDU;
 	gtp0->length	= htons(payload_len);
-	gtp0->seq	= htons((atomic_inc_return(&pctx->tx_seq) - 1) % 0xffff);
+	gtp0->seq	= htons((atomic_inc_return(&pctx->tx_seq) - 1) %
+				0xffff);
 	gtp0->flow	= htons(pctx->u.v0.flow);
 	gtp0->number	= 0xff;
 	gtp0->spare[0]	= gtp0->spare[1] = gtp0->spare[2] = 0xff;
@@ -507,6 +587,23 @@ static netdev_tx_t gtp_dev_xmit(struct sk_buff *skb, struct net_device *dev)
 
 		break;
 	}
+	case ETH_P_IPV6: {
+		struct ipv6hdr *ipv6h = ipv6_hdr(skb);
+
+		if (gtp->role == GTP_ROLE_SGSN)
+			pctx = ipv6_pdp_find(gtp, &ipv6h->saddr);
+		else
+			pctx = ipv6_pdp_find(gtp, &ipv6h->daddr);
+
+		if (!pctx) {
+			netdev_dbg(dev, "no PDP ctx found for %pI6, skip\n",
+				   &ipv6h->daddr);
+			err = -ENOENT;
+			goto tx_err;
+		}
+
+		break;
+	}
 	default:
 		err = -EOPNOTSUPP;
 		goto tx_err;
@@ -674,23 +771,32 @@ static int gtp_hashtable_new(struct gtp_dev *gtp, int hsize)
 {
 	int i;
 
-	gtp->addr_hash = kmalloc(sizeof(struct hlist_head) * hsize, GFP_KERNEL);
-	if (gtp->addr_hash == NULL)
-		return -ENOMEM;
+	gtp->addr4_hash = kmalloc_array(hsize, sizeof(*gtp->addr4_hash),
+					GFP_KERNEL);
+	if (!gtp->addr4_hash)
+		goto err;
+
+	gtp->addr6_hash = kmalloc_array(hsize, sizeof(*gtp->addr6_hash),
+					GFP_KERNEL);
+	if (!gtp->addr6_hash)
+		goto err;
 
-	gtp->tid_hash = kmalloc(sizeof(struct hlist_head) * hsize, GFP_KERNEL);
-	if (gtp->tid_hash == NULL)
-		goto err1;
+	gtp->tid_hash = kmalloc_array(hsize, sizeof(struct hlist_head),
+				      GFP_KERNEL);
+	if (!gtp->tid_hash)
+		goto err;
 
 	gtp->hash_size = hsize;
 
 	for (i = 0; i < hsize; i++) {
-		INIT_HLIST_HEAD(&gtp->addr_hash[i]);
+		INIT_HLIST_HEAD(&gtp->addr4_hash[i]);
+		INIT_HLIST_HEAD(&gtp->addr6_hash[i]);
 		INIT_HLIST_HEAD(&gtp->tid_hash[i]);
 	}
 	return 0;
-err1:
-	kfree(gtp->addr_hash);
+err:
+	kfree(gtp->addr4_hash);
+	kfree(gtp->addr6_hash);
 	return -ENOMEM;
 }
 
@@ -704,7 +810,8 @@ static void gtp_hashtable_free(struct gtp_dev *gtp)
 			pdp_context_delete(pctx);
 
 	synchronize_rcu();
-	kfree(gtp->addr_hash);
+	kfree(gtp->addr4_hash);
+	kfree(gtp->addr6_hash);
 	kfree(gtp->tid_hash);
 }
 
@@ -826,16 +933,13 @@ static struct gtp_dev *gtp_find_dev(struct net *src_net, struct nlattr *nla[])
 	return gtp;
 }
 
-static void ipv4_pdp_fill(struct pdp_ctx *pctx, struct genl_info *info)
+static void pdp_fill(struct pdp_ctx *pctx, struct genl_info *info)
 {
 	__be16 default_port = 0;
 
 	pctx->gtp_version = nla_get_u32(info->attrs[GTPA_VERSION]);
-	pctx->af = AF_INET;
 	pctx->peer_addr_ip4.s_addr =
 		nla_get_be32(info->attrs[GTPA_PEER_ADDRESS]);
-	pctx->ms_addr_ip4.s_addr =
-		nla_get_be32(info->attrs[GTPA_MS_ADDRESS]);
 
 	switch (pctx->gtp_version) {
 	case GTP_V0:
@@ -862,33 +966,46 @@ static void ipv4_pdp_fill(struct pdp_ctx *pctx, struct genl_info *info)
 		pctx->gtp_port = default_port;
 }
 
-static int ipv4_pdp_add(struct gtp_dev *gtp, struct sock *sk,
-			struct genl_info *info)
+static int gtp_pdp_add(struct gtp_dev *gtp, struct sock *sk,
+		       struct genl_info *info)
 {
 	struct net_device *dev = gtp->dev;
+	struct hlist_head *addr_list;
+	struct pdp_ctx *pctx = NULL;
 	u32 hash_ms, hash_tid = 0;
-	struct pdp_ctx *pctx;
-	bool found = false;
-	__be32 ms_addr;
+	struct in6_addr ms6_addr;
+	__be32 ms_addr = 0;
+	int ms_af;
 	int err;
 
-	ms_addr = nla_get_be32(info->attrs[GTPA_MS_ADDRESS]);
-	hash_ms = ipv4_hashfn(ms_addr) % gtp->hash_size;
+	/* Caller ensures we have either v4 or v6 mobile subscriber address */
+	if (info->attrs[GTPA_MS_ADDRESS]) {
+		/* IPv4 mobile subscriber */
 
-	hlist_for_each_entry_rcu(pctx, &gtp->addr_hash[hash_ms], hlist_addr) {
-		if (pctx->ms_addr_ip4.s_addr == ms_addr) {
-			found = true;
-			break;
-		}
+		ms_addr = nla_get_in_addr(info->attrs[GTPA_MS_ADDRESS]);
+		hash_ms = ipv4_hashfn(ms_addr) % gtp->hash_size;
+		addr_list = &gtp->addr4_hash[hash_ms];
+		ms_af = AF_INET;
+
+		pctx = ipv4_pdp_find(gtp, ms_addr);
+	} else {
+		/* IPv6 mobile subscriber */
+
+		ms6_addr = nla_get_in6_addr(info->attrs[GTPA_MS6_ADDRESS]);
+		hash_ms = ipv6_hashfn(&ms6_addr) % gtp->hash_size;
+		addr_list = &gtp->addr6_hash[hash_ms];
+		ms_af = AF_INET6;
+
+		pctx = ipv6_pdp_find(gtp, &ms6_addr);
 	}
 
-	if (found) {
+	if (pctx) {
 		if (info->nlhdr->nlmsg_flags & NLM_F_EXCL)
 			return -EEXIST;
 		if (info->nlhdr->nlmsg_flags & NLM_F_REPLACE)
 			return -EOPNOTSUPP;
 
-		ipv4_pdp_fill(pctx, info);
+		pdp_fill(pctx, info);
 
 		if (pctx->gtp_version == GTP_V0)
 			netdev_dbg(dev, "GTPv0-U: update tunnel id = %llx (pdp %p)\n",
@@ -914,7 +1031,18 @@ static int ipv4_pdp_add(struct gtp_dev *gtp, struct sock *sk,
 	sock_hold(sk);
 	pctx->sk = sk;
 	pctx->dev = gtp->dev;
-	ipv4_pdp_fill(pctx, info);
+	pctx->ms_af = ms_af;
+
+	switch (ms_af) {
+	case AF_INET:
+		pctx->ms_addr_ip4.s_addr = ms_addr;
+		break;
+	case AF_INET6:
+		pctx->ms_addr_ip6 = ms6_addr;
+		break;
+	}
+
+	pdp_fill(pctx, info);
 	atomic_set(&pctx->tx_seq, 0);
 
 	switch (pctx->gtp_version) {
@@ -931,7 +1059,7 @@ static int ipv4_pdp_add(struct gtp_dev *gtp, struct sock *sk,
 		break;
 	}
 
-	hlist_add_head_rcu(&pctx->hlist_addr, &gtp->addr_hash[hash_ms]);
+	hlist_add_head_rcu(&pctx->hlist_addr, addr_list);
 	hlist_add_head_rcu(&pctx->hlist_tid, &gtp->tid_hash[hash_tid]);
 
 	switch (pctx->gtp_version) {
@@ -973,11 +1101,17 @@ static int gtp_genl_new_pdp(struct sk_buff *skb, struct genl_info *info)
 	int err;
 
 	if (!info->attrs[GTPA_VERSION] ||
-	    !info->attrs[GTPA_LINK] ||
-	    !info->attrs[GTPA_PEER_ADDRESS] ||
-	    !info->attrs[GTPA_MS_ADDRESS])
+	   !info->attrs[GTPA_LINK] ||
+	   !info->attrs[GTPA_PEER_ADDRESS])
 		return -EINVAL;
 
+	if (!(!!info->attrs[GTPA_MS_ADDRESS] ^
+	      !!info->attrs[GTPA_MS6_ADDRESS])) {
+		/* Either v4 or v6 mobile subscriber address must be set */
+
+		return -EINVAL;
+	}
+
 	version = nla_get_u32(info->attrs[GTPA_VERSION]);
 
 	switch (version) {
@@ -1016,7 +1150,7 @@ static int gtp_genl_new_pdp(struct sk_buff *skb, struct genl_info *info)
 		goto out_unlock;
 	}
 
-	err = ipv4_pdp_add(gtp, sk, info);
+	err = gtp_pdp_add(gtp, sk, info);
 
 out_unlock:
 	rcu_read_unlock();
@@ -1036,6 +1170,11 @@ static struct pdp_ctx *gtp_find_pdp_by_link(struct net *net,
 		__be32 ip = nla_get_be32(nla[GTPA_MS_ADDRESS]);
 
 		return ipv4_pdp_find(gtp, ip);
+	} else if (nla[GTPA_MS6_ADDRESS]) {
+		struct in6_addr ip6 =
+		    nla_get_in6_addr(nla[GTPA_MS6_ADDRESS]);
+
+		return ipv6_pdp_find(gtp, &ip6);
 	} else if (nla[GTPA_VERSION]) {
 		u32 gtp_version = nla_get_u32(nla[GTPA_VERSION]);
 
@@ -1106,10 +1245,26 @@ static int gtp_genl_fill_info(struct sk_buff *skb, u32 snd_portid, u32 snd_seq,
 		goto nlmsg_failure;
 
 	if (nla_put_u32(skb, GTPA_VERSION, pctx->gtp_version) ||
-	    nla_put_be32(skb, GTPA_PEER_ADDRESS, pctx->peer_addr_ip4.s_addr) ||
-	    nla_put_be32(skb, GTPA_MS_ADDRESS, pctx->ms_addr_ip4.s_addr))
+	    nla_put_be32(skb, GTPA_PEER_ADDRESS, pctx->peer_addr_ip4.s_addr))
 		goto nla_put_failure;
 
+	switch (pctx->ms_af) {
+	case AF_INET:
+		if (nla_put_be32(skb, GTPA_MS_ADDRESS,
+				 pctx->ms_addr_ip4.s_addr))
+			goto nla_put_failure;
+
+		break;
+	case AF_INET6:
+		if (nla_put_in6_addr(skb, GTPA_MS6_ADDRESS,
+				     &pctx->ms_addr_ip6))
+			goto nla_put_failure;
+
+		break;
+	default:
+		goto nla_put_failure;
+	}
+
 	switch (pctx->gtp_version) {
 	case GTP_V0:
 		if (nla_put_u64_64bit(skb, GTPA_TID, pctx->u.v0.tid, GTPA_PAD) ||
@@ -1219,6 +1374,8 @@ static struct nla_policy gtp_genl_policy[GTPA_MAX + 1] = {
 	[GTPA_TID]		= { .type = NLA_U64, },
 	[GTPA_PEER_ADDRESS]	= { .type = NLA_U32, },
 	[GTPA_MS_ADDRESS]	= { .type = NLA_U32, },
+	[GTPA_MS6_ADDRESS]	= { .len = FIELD_SIZEOF(struct ipv6hdr,
+							daddr) },
 	[GTPA_FLOW]		= { .type = NLA_U16, },
 	[GTPA_NET_NS_FD]	= { .type = NLA_U32, },
 	[GTPA_I_TEI]		= { .type = NLA_U32, },
diff --git a/include/uapi/linux/gtp.h b/include/uapi/linux/gtp.h
index b2283a5c6d7f..ae4e632c0360 100644
--- a/include/uapi/linux/gtp.h
+++ b/include/uapi/linux/gtp.h
@@ -28,6 +28,7 @@ enum gtp_attrs {
 	GTPA_O_TEI,	/* for GTPv1 only */
 	GTPA_PAD,
 	GTPA_PORT,
+	GTPA_MS6_ADDRESS,
 	__GTPA_MAX,
 };
 #define GTPA_MAX (__GTPA_MAX + 1)
-- 
2.11.0
