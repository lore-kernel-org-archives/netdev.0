From: Tom Herbert <tom@quantonium.net>
Subject: [PATCH v5 net-next 10/12] gtp: Experimental encapsulation of IPv6 packets
Date: Wed, 18 Oct 2017 13:10:16 -0700
Message-ID: <20171018201018.5692-11-tom@quantonium.net>
References: <20171018201018.5692-1-tom@quantonium.net>
Cc: pablo@netfilter.org, laforge@gnumonks.org, aschultz@tpip.net,
        netdev@vger.kernel.org, rohit@quantonium.net,
        Tom Herbert <tom@quantonium.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:52298 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751730AbdJRULV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2017 16:11:21 -0400
Received: by mail-pf0-f193.google.com with SMTP id e64so4747205pfk.9
        for <netdev@vger.kernel.org>; Wed, 18 Oct 2017 13:11:21 -0700 (PDT)
In-Reply-To: <20171018201018.5692-1-tom@quantonium.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow IPv6 mobile subscriber packets. This entails adding an IPv6 mobile
subscriber address to pdp context and IPv6 specific variants to find pdp
contexts by address.

Note that this is experimental support of IPv6, more work is
necessary to make this compliant with 3GPP standard.

Signed-off-by: Tom Herbert <tom@quantonium.net>
---
 drivers/net/Kconfig      |  12 +-
 drivers/net/gtp.c        | 324 +++++++++++++++++++++++++++++++++++++++--------
 include/uapi/linux/gtp.h |   1 +
 3 files changed, 280 insertions(+), 57 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 720c2af0bb88..1af34cc4cd7e 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -226,7 +226,17 @@ config GTP
 	  3GPP TS 29.060 standards.
 
 	  To compile this drivers as a module, choose M here: the module
-	  wil be called gtp.
+	  will be called gtp.
+
+config GTP_IPV6_EXPERIMENTAL
+	bool "GTP IPv6 datapath (EXPERIMENTAL)"
+	default n
+	depends on GTP
+	---help---
+	  This is an experimental implementation that allows encapsulating
+	  IPv6 over GTP and using GTP over IPv6 for testing and development
+	  purpose. This is not a standards conformant implementation for
+	  IPv6 and GTP. More work is needed reach that level.
 
 config MACSEC
 	tristate "IEEE 802.1AE MAC-level encryption (MACsec)"
diff --git a/drivers/net/gtp.c b/drivers/net/gtp.c
index 44844eba8df2..919ec6e14973 100644
--- a/drivers/net/gtp.c
+++ b/drivers/net/gtp.c
@@ -36,6 +36,8 @@
 #include <net/netns/generic.h>
 #include <net/gtp.h>
 
+#define GTP_IPV6 IS_ENABLED(CONFIG_GTP_IPV6_EXPERIMENTAL)
+
 /* An active session for the subscriber. */
 struct pdp_ctx {
 	struct hlist_node	hlist_tid;
@@ -55,9 +57,17 @@ struct pdp_ctx {
 	u8			gtp_version;
 	u8			hlen;
 	__be16			gtp_port;
-	u16			af;
 
-	struct in_addr		ms_addr_ip4;
+	u16			ms_af;
+#if GTP_IPV6
+	union {
+		struct in_addr	ms_addr_ip4;
+		struct in6_addr	ms_addr_ip6;
+	};
+#else
+	struct in_addr	ms_addr_ip4;
+#endif
+
 	struct in_addr		peer_addr_ip4;
 
 	struct sock		*sk;
@@ -81,7 +91,11 @@ struct gtp_dev {
 	unsigned int		role;
 	unsigned int		hash_size;
 	struct hlist_head	*tid_hash;
-	struct hlist_head	*addr_hash;
+
+	struct hlist_head	*addr4_hash;
+#if GTP_IPV6
+	struct hlist_head	*addr6_hash;
+#endif
 
 	struct gro_cells	gro_cells;
 };
@@ -99,6 +113,7 @@ static void pdp_context_delete(struct pdp_ctx *pctx);
 static inline u32 gtp0_hashfn(u64 tid)
 {
 	u32 *tid32 = (u32 *) &tid;
+
 	return jhash_2words(tid32[0], tid32[1], gtp_h_initval);
 }
 
@@ -107,11 +122,6 @@ static inline u32 gtp1u_hashfn(u32 tid)
 	return jhash_1word(tid, gtp_h_initval);
 }
 
-static inline u32 ipv4_hashfn(__be32 ip)
-{
-	return jhash_1word((__force u32)ip, gtp_h_initval);
-}
-
 /* Resolve a PDP context structure based on the 64bit TID. */
 static struct pdp_ctx *gtp0_pdp_find(struct gtp_dev *gtp, u64 tid)
 {
@@ -144,16 +154,21 @@ static struct pdp_ctx *gtp1_pdp_find(struct gtp_dev *gtp, u32 tid)
 	return NULL;
 }
 
+static inline u32 gtp_ipv4_hashfn(__be32 ip)
+{
+	return jhash_1word((__force u32)ip, gtp_h_initval);
+}
+
 /* Resolve a PDP context based on IPv4 address of MS. */
 static struct pdp_ctx *ipv4_pdp_find(struct gtp_dev *gtp, __be32 ms_addr)
 {
 	struct hlist_head *head;
 	struct pdp_ctx *pdp;
 
-	head = &gtp->addr_hash[ipv4_hashfn(ms_addr) % gtp->hash_size];
+	head = &gtp->addr4_hash[gtp_ipv4_hashfn(ms_addr) % gtp->hash_size];
 
 	hlist_for_each_entry_rcu(pdp, head, hlist_addr) {
-		if (pdp->af == AF_INET &&
+		if (pdp->ms_af == AF_INET &&
 		    pdp->ms_addr_ip4.s_addr == ms_addr)
 			return pdp;
 	}
@@ -177,33 +192,109 @@ static bool gtp_check_ms_ipv4(struct sk_buff *skb, struct pdp_ctx *pctx,
 		return iph->saddr == pctx->ms_addr_ip4.s_addr;
 }
 
+#if GTP_IPV6
+
+static inline u32 gtp_ipv6_hashfn(const struct in6_addr *a)
+{
+	return __ipv6_addr_jhash(a, gtp_h_initval);
+}
+
+/* Resolve a PDP context based on IPv6 address of MS. */
+static struct pdp_ctx *ipv6_pdp_find(struct gtp_dev *gtp,
+				     const struct in6_addr *ms_addr)
+{
+	struct hlist_head *head;
+	struct pdp_ctx *pdp;
+
+	head = &gtp->addr6_hash[gtp_ipv6_hashfn(ms_addr) % gtp->hash_size];
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
+#endif
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
+#if GTP_IPV6
+	case 6:
+		return gtp_check_ms_ipv6(skb, pctx, hdrlen, role);
+#endif
 	}
+
 	return false;
 }
 
+static u16 ipver_to_eth(struct iphdr *iph)
+{
+	switch (iph->version) {
+	case 4:
+		return htons(ETH_P_IP);
+#if GTP_IPV6
+	case 6:
+		return htons(ETH_P_IPV6);
+#endif
+	default:
+		return 0;
+	}
+}
+
 static int gtp_rx(struct pdp_ctx *pctx, struct sk_buff *skb,
-			unsigned int hdrlen, unsigned int role)
+		  unsigned int hdrlen, unsigned int role)
 {
 	struct gtp_dev *gtp = netdev_priv(pctx->dev);
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
@@ -241,7 +332,8 @@ static int gtp0_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
 	if (!gtp)
 		goto pass;
 
-	if (!pskb_may_pull(skb, hdrlen))
+	/* Pull through IP header since gtp_rx looks at IP version */
+	if (!pskb_may_pull(skb, hdrlen + sizeof(struct iphdr)))
 		goto drop;
 
 	gtp0 = (struct gtp0_header *)(skb->data + sizeof(struct udphdr));
@@ -287,7 +379,8 @@ static int gtp1u_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
 	if (!gtp)
 		goto pass;
 
-	if (!pskb_may_pull(skb, hdrlen))
+	/* Pull through IP header since gtp_rx looks at IP version */
+	if (!pskb_may_pull(skb, hdrlen + sizeof(struct iphdr)))
 		goto drop;
 
 	gtp1 = (struct gtp1_header *)(skb->data + sizeof(struct udphdr));
@@ -309,8 +402,10 @@ static int gtp1u_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
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
@@ -391,7 +486,8 @@ static inline void gtp0_push_header(struct sk_buff *skb, struct pdp_ctx *pctx)
 	gtp0->flags	= 0x1e; /* v0, GTP-non-prime. */
 	gtp0->type	= GTP_TPDU;
 	gtp0->length	= htons(payload_len);
-	gtp0->seq	= htons((atomic_inc_return(&pctx->tx_seq) - 1) % 0xffff);
+	gtp0->seq	= htons((atomic_inc_return(&pctx->tx_seq) - 1) %
+				0xffff);
 	gtp0->flow	= htons(pctx->u.v0.flow);
 	gtp0->number	= 0xff;
 	gtp0->spare[0]	= gtp0->spare[1] = gtp0->spare[2] = 0xff;
@@ -523,6 +619,25 @@ static netdev_tx_t gtp_dev_xmit(struct sk_buff *skb, struct net_device *dev)
 
 		break;
 	}
+#if GTP_IPV6
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
+#endif
 	default:
 		err = -EOPNOTSUPP;
 		goto tx_err;
@@ -692,23 +807,38 @@ static int gtp_hashtable_new(struct gtp_dev *gtp, int hsize)
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
+#if GTP_IPV6
+	gtp->addr6_hash = kmalloc_array(hsize, sizeof(*gtp->addr6_hash),
+					GFP_KERNEL);
+	if (!gtp->addr6_hash)
+		goto err;
+#endif
 
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
+#if GTP_IPV6
+		INIT_HLIST_HEAD(&gtp->addr6_hash[i]);
+#endif
 		INIT_HLIST_HEAD(&gtp->tid_hash[i]);
 	}
 	return 0;
-err1:
-	kfree(gtp->addr_hash);
+err:
+	kfree(gtp->addr4_hash);
+#if GTP_IPV6
+	kfree(gtp->addr6_hash);
+#endif
 	return -ENOMEM;
 }
 
@@ -722,7 +852,10 @@ static void gtp_hashtable_free(struct gtp_dev *gtp)
 			pdp_context_delete(pctx);
 
 	synchronize_rcu();
-	kfree(gtp->addr_hash);
+	kfree(gtp->addr4_hash);
+#if GTP_IPV6
+	kfree(gtp->addr6_hash);
+#endif
 	kfree(gtp->tid_hash);
 }
 
@@ -844,16 +977,13 @@ static struct gtp_dev *gtp_find_dev(struct net *src_net, struct nlattr *nla[])
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
@@ -882,33 +1012,59 @@ static void ipv4_pdp_fill(struct pdp_ctx *pctx, struct genl_info *info)
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
+#if GTP_IPV6
+	struct in6_addr ms6_addr;
+#endif
+	__be32 ms_addr = 0;
+	int ms_af;
 	int err;
 
-	ms_addr = nla_get_be32(info->attrs[GTPA_MS_ADDRESS]);
-	hash_ms = ipv4_hashfn(ms_addr) % gtp->hash_size;
+#if GTP_IPV6
+	/* Caller ensures we have either v4 or v6 mobile subscriber address */
+	if (info->attrs[GTPA_MS_ADDRESS]) {
+		/* IPv4 mobile subscriber */
 
-	hlist_for_each_entry_rcu(pctx, &gtp->addr_hash[hash_ms], hlist_addr) {
-		if (pctx->ms_addr_ip4.s_addr == ms_addr) {
-			found = true;
-			break;
-		}
+		ms_addr = nla_get_in_addr(info->attrs[GTPA_MS_ADDRESS]);
+		hash_ms = gtp_ipv4_hashfn(ms_addr) % gtp->hash_size;
+		addr_list = &gtp->addr4_hash[hash_ms];
+		ms_af = AF_INET;
+
+		pctx = ipv4_pdp_find(gtp, ms_addr);
+	} else {
+		/* IPv6 mobile subscriber */
+
+		ms6_addr = nla_get_in6_addr(info->attrs[GTPA_MS6_ADDRESS]);
+		hash_ms = gtp_ipv6_hashfn(&ms6_addr) % gtp->hash_size;
+		addr_list = &gtp->addr6_hash[hash_ms];
+		ms_af = AF_INET6;
+
+		pctx = ipv6_pdp_find(gtp, &ms6_addr);
 	}
+#else
+	/* IPv4 mobile subscriber */
 
-	if (found) {
+	ms_addr = nla_get_in_addr(info->attrs[GTPA_MS_ADDRESS]);
+	hash_ms = gtp_ipv4_hashfn(ms_addr) % gtp->hash_size;
+	addr_list = &gtp->addr4_hash[hash_ms];
+	ms_af = AF_INET;
+
+	pctx = ipv4_pdp_find(gtp, ms_addr);
+#endif
+
+	if (pctx) {
 		if (info->nlhdr->nlmsg_flags & NLM_F_EXCL)
 			return -EEXIST;
 		if (info->nlhdr->nlmsg_flags & NLM_F_REPLACE)
 			return -EOPNOTSUPP;
 
-		ipv4_pdp_fill(pctx, info);
+		pdp_fill(pctx, info);
 
 		if (pctx->gtp_version == GTP_V0)
 			netdev_dbg(dev, "GTPv0-U: update tunnel id = %llx (pdp %p)\n",
@@ -934,7 +1090,20 @@ static int ipv4_pdp_add(struct gtp_dev *gtp, struct sock *sk,
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
+#if GTP_IPV6
+	case AF_INET6:
+		pctx->ms_addr_ip6 = ms6_addr;
+		break;
+#endif
+	}
+
+	pdp_fill(pctx, info);
 	atomic_set(&pctx->tx_seq, 0);
 
 	switch (pctx->gtp_version) {
@@ -951,7 +1120,7 @@ static int ipv4_pdp_add(struct gtp_dev *gtp, struct sock *sk,
 		break;
 	}
 
-	hlist_add_head_rcu(&pctx->hlist_addr, &gtp->addr_hash[hash_ms]);
+	hlist_add_head_rcu(&pctx->hlist_addr, addr_list);
 	hlist_add_head_rcu(&pctx->hlist_tid, &gtp->tid_hash[hash_tid]);
 
 	switch (pctx->gtp_version) {
@@ -993,11 +1162,25 @@ static int gtp_genl_new_pdp(struct sk_buff *skb, struct genl_info *info)
 	int err;
 
 	if (!info->attrs[GTPA_VERSION] ||
-	    !info->attrs[GTPA_LINK] ||
-	    !info->attrs[GTPA_PEER_ADDRESS] ||
-	    !info->attrs[GTPA_MS_ADDRESS])
+	   !info->attrs[GTPA_LINK] ||
+	   !info->attrs[GTPA_PEER_ADDRESS])
 		return -EINVAL;
 
+#if GTP_IPV6
+	if (!(!!info->attrs[GTPA_MS_ADDRESS] ^
+	      !!info->attrs[GTPA_MS6_ADDRESS])) {
+		/* Either v4 or v6 mobile subscriber address must be set */
+
+		return -EINVAL;
+	}
+#else
+	if (!info->attrs[GTPA_MS_ADDRESS]) {
+		/* v4 mobile subscriber address must be set */
+
+		return -EINVAL;
+	}
+#endif
+
 	version = nla_get_u32(info->attrs[GTPA_VERSION]);
 
 	switch (version) {
@@ -1036,7 +1219,7 @@ static int gtp_genl_new_pdp(struct sk_buff *skb, struct genl_info *info)
 		goto out_unlock;
 	}
 
-	err = ipv4_pdp_add(gtp, sk, info);
+	err = gtp_pdp_add(gtp, sk, info);
 
 out_unlock:
 	rcu_read_unlock();
@@ -1056,6 +1239,13 @@ static struct pdp_ctx *gtp_find_pdp_by_link(struct net *net,
 		__be32 ip = nla_get_be32(nla[GTPA_MS_ADDRESS]);
 
 		return ipv4_pdp_find(gtp, ip);
+#if GTP_IPV6
+	} else if (nla[GTPA_MS6_ADDRESS]) {
+		struct in6_addr ip6 =
+		    nla_get_in6_addr(nla[GTPA_MS6_ADDRESS]);
+
+		return ipv6_pdp_find(gtp, &ip6);
+#endif
 	} else if (nla[GTPA_VERSION]) {
 		u32 gtp_version = nla_get_u32(nla[GTPA_VERSION]);
 
@@ -1126,9 +1316,27 @@ static int gtp_genl_fill_info(struct sk_buff *skb, u32 snd_portid, u32 snd_seq,
 		goto nlmsg_failure;
 
 	if (nla_put_u32(skb, GTPA_VERSION, pctx->gtp_version) ||
-	    nla_put_be32(skb, GTPA_PEER_ADDRESS, pctx->peer_addr_ip4.s_addr) ||
-	    nla_put_be32(skb, GTPA_MS_ADDRESS, pctx->ms_addr_ip4.s_addr))
+	    nla_put_be32(skb, GTPA_PEER_ADDRESS, pctx->peer_addr_ip4.s_addr))
+		goto nla_put_failure;
+
+	switch (pctx->ms_af) {
+	case AF_INET:
+		if (nla_put_be32(skb, GTPA_MS_ADDRESS,
+				 pctx->ms_addr_ip4.s_addr))
+			goto nla_put_failure;
+
+		break;
+#if GTP_IPV6
+	case AF_INET6:
+		if (nla_put_in6_addr(skb, GTPA_MS6_ADDRESS,
+				     &pctx->ms_addr_ip6))
+			goto nla_put_failure;
+
+		break;
+#endif
+	default:
 		goto nla_put_failure;
+	}
 
 	switch (pctx->gtp_version) {
 	case GTP_V0:
@@ -1239,6 +1447,10 @@ static struct nla_policy gtp_genl_policy[GTPA_MAX + 1] = {
 	[GTPA_TID]		= { .type = NLA_U64, },
 	[GTPA_PEER_ADDRESS]	= { .type = NLA_U32, },
 	[GTPA_MS_ADDRESS]	= { .type = NLA_U32, },
+#if GTP_IPV6
+	[GTPA_MS6_ADDRESS]	= { .len = FIELD_SIZEOF(struct ipv6hdr,
+							daddr) },
+#endif
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
