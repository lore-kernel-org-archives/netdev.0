From: Jiannan Ouyang <ouyangj-b10kYP2dOMg@public.gmane.org>
Subject: [PATCH net-next v1 1/3] gtp: refactor to support
	flow-based gtp encap and decap
Date: Wed, 12 Jul 2017 17:44:53 -0700
Message-ID: <20170713004455.3946570-2-ouyangj@fb.com>
References: <20170713004455.3946570-1-ouyangj@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: laforge-TgoAw6mPHtdg9hUCZPvPmw@public.gmane.org, pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org
To: <osmocom-net-gprs-qjLDD68F18N4m7O/Vxda39i2O/JbrIOy@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
Return-path: <ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <20170713004455.3946570-1-ouyangj-b10kYP2dOMg@public.gmane.org>
List-Unsubscribe: <https://mail.openvswitch.org/mailman/options/ovs-dev>,
	<mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://mail.openvswitch.org/pipermail/ovs-dev/>
List-Post: <mailto:ovs-dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <https://mail.openvswitch.org/mailman/listinfo/ovs-dev>,
	<mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

If flow-based encap/decap is enabled, a separate code path is created for both
packet RX and TX. PDP contexts are not used in flow-based mode since
all metadata is maintained in metadata_dst:

- for RX, pdp lookup and ms check are bypassed, while metadata_dst is
  constructed and attached to the skb.

- for TX, pdp lookup is bypassed. Packets are encapsulated following
  instructions specified in metadata_dst.

Signed-off-by: Jiannan Ouyang <ouyangj-b10kYP2dOMg@public.gmane.org>
---
 drivers/net/gtp.c | 162 ++++++++++++++++++++++++++++++++++--------------------
 1 file changed, 102 insertions(+), 60 deletions(-)

diff --git a/drivers/net/gtp.c b/drivers/net/gtp.c
index 1542e83..5a7b504 100644
--- a/drivers/net/gtp.c
+++ b/drivers/net/gtp.c
@@ -25,6 +25,7 @@
 #include <linux/file.h>
 #include <linux/gtp.h>
 
+#include <net/dst_metadata.h>
 #include <net/net_namespace.h>
 #include <net/protocol.h>
 #include <net/ip.h>
@@ -36,6 +37,8 @@
 #include <net/netns/generic.h>
 #include <net/gtp.h>
 
+#define GTP_PDP_HASHSIZE 1024
+
 /* An active session for the subscriber. */
 struct pdp_ctx {
 	struct hlist_node	hlist_tid;
@@ -59,7 +62,7 @@ struct pdp_ctx {
 	struct in_addr		peer_addr_ip4;
 
 	struct sock		*sk;
-	struct net_device       *dev;
+	struct net_device	*dev;
 
 	atomic_t		tx_seq;
 	struct rcu_head		rcu_head;
@@ -73,11 +76,15 @@ struct gtp_dev {
 	struct sock		*sk1u;
 
 	struct net_device	*dev;
+	struct net		*net;
 
 	unsigned int		role;
 	unsigned int		hash_size;
 	struct hlist_head	*tid_hash;
 	struct hlist_head	*addr_hash;
+
+	unsigned int		collect_md;
+	struct ip_tunnel_info	info;
 };
 
 static unsigned int gtp_net_id __read_mostly;
@@ -184,22 +191,23 @@ static bool gtp_check_ms(struct sk_buff *skb, struct pdp_ctx *pctx,
 	return false;
 }
 
-static int gtp_rx(struct pdp_ctx *pctx, struct sk_buff *skb,
-			unsigned int hdrlen, unsigned int role)
+static int gtp_rx(struct gtp_dev *gtp, struct sk_buff *skb,
+		  unsigned int hdrlen, struct sock *sk,
+		  struct metadata_dst *tun_dst)
 {
 	struct pcpu_sw_netstats *stats;
 
-	if (!gtp_check_ms(skb, pctx, hdrlen, role)) {
-		netdev_dbg(pctx->dev, "No PDP ctx for this MS\n");
-		return 1;
-	}
-
 	/* Get rid of the GTP + UDP headers. */
 	if (iptunnel_pull_header(skb, hdrlen, skb->protocol,
-				 !net_eq(sock_net(pctx->sk), dev_net(pctx->dev))))
+				 !net_eq(sock_net(sk), dev_net(gtp->dev))))
 		return -1;
 
-	netdev_dbg(pctx->dev, "forwarding packet from GGSN to uplink\n");
+	netdev_dbg(gtp->dev, "forwarding packet from GGSN to uplink\n");
+
+	if (tun_dst) {
+		skb_dst_set(skb, (struct dst_entry *)tun_dst);
+		netdev_dbg(gtp->dev, "attaching metadata_dst to skb\n");
+	}
 
 	/* Now that the UDP and the GTP header have been removed, set up the
 	 * new network header. This is required by the upper layer to
@@ -207,15 +215,16 @@ static int gtp_rx(struct pdp_ctx *pctx, struct sk_buff *skb,
 	 */
 	skb_reset_network_header(skb);
 
-	skb->dev = pctx->dev;
+	skb->dev = gtp->dev;
 
-	stats = this_cpu_ptr(pctx->dev->tstats);
+	stats = this_cpu_ptr(gtp->dev->tstats);
 	u64_stats_update_begin(&stats->syncp);
 	stats->rx_packets++;
 	stats->rx_bytes += skb->len;
 	u64_stats_update_end(&stats->syncp);
 
 	netif_rx(skb);
+
 	return 0;
 }
 
@@ -244,7 +253,12 @@ static int gtp0_udp_encap_recv(struct gtp_dev *gtp, struct sk_buff *skb)
 		return 1;
 	}
 
-	return gtp_rx(pctx, skb, hdrlen, gtp->role);
+	if (!gtp_check_ms(skb, pctx, hdrlen, gtp->role)) {
+		netdev_dbg(gtp->dev, "No PDP ctx for this MS\n");
+		return 1;
+	}
+
+	return gtp_rx(gtp, skb, hdrlen, pctx->sk, NULL);
 }
 
 static int gtp1u_udp_encap_recv(struct gtp_dev *gtp, struct sk_buff *skb)
@@ -253,6 +267,7 @@ static int gtp1u_udp_encap_recv(struct gtp_dev *gtp, struct sk_buff *skb)
 			      sizeof(struct gtp1_header);
 	struct gtp1_header *gtp1;
 	struct pdp_ctx *pctx;
+	struct metadata_dst *tun_dst = NULL;
 
 	if (!pskb_may_pull(skb, hdrlen))
 		return -1;
@@ -280,13 +295,24 @@ static int gtp1u_udp_encap_recv(struct gtp_dev *gtp, struct sk_buff *skb)
 
 	gtp1 = (struct gtp1_header *)(skb->data + sizeof(struct udphdr));
 
-	pctx = gtp1_pdp_find(gtp, ntohl(gtp1->tid));
-	if (!pctx) {
-		netdev_dbg(gtp->dev, "No PDP ctx to decap skb=%p\n", skb);
-		return 1;
+	if (ip_tunnel_collect_metadata() || gtp->collect_md) {
+		tun_dst = udp_tun_rx_dst(skb, gtp->sk1u->sk_family, TUNNEL_KEY,
+					 key32_to_tunnel_id(gtp1->tid), 0);
+	} else {
+		pctx = gtp1_pdp_find(gtp, ntohl(gtp1->tid));
+		if (!pctx) {
+			netdev_dbg(gtp->dev, "No PDP ctx to decap skb=%p\n",
+				   skb);
+			return 1;
+		}
+
+		if (!gtp_check_ms(skb, pctx, hdrlen, gtp->role)) {
+			netdev_dbg(gtp->dev, "No PDP ctx for this MS\n");
+			return 1;
+		}
 	}
 
-	return gtp_rx(pctx, skb, hdrlen, gtp->role);
+	return gtp_rx(gtp, skb, hdrlen, gtp->sk1u, tun_dst);
 }
 
 static void gtp_encap_destroy(struct sock *sk)
@@ -410,7 +436,7 @@ static inline void gtp0_push_header(struct sk_buff *skb, struct pdp_ctx *pctx)
 	gtp0->tid	= cpu_to_be64(pctx->u.v0.tid);
 }
 
-static inline void gtp1_push_header(struct sk_buff *skb, struct pdp_ctx *pctx)
+static inline void gtp1_push_header(struct sk_buff *skb, __be32 tid)
 {
 	int payload_len = skb->len;
 	struct gtp1_header *gtp1;
@@ -426,7 +452,7 @@ static inline void gtp1_push_header(struct sk_buff *skb, struct pdp_ctx *pctx)
 	gtp1->flags	= 0x30; /* v1, GTP-non-prime. */
 	gtp1->type	= GTP_TPDU;
 	gtp1->length	= htons(payload_len);
-	gtp1->tid	= htonl(pctx->u.v1.o_tei);
+	gtp1->tid	= tid;
 
 	/* TODO: Suppport for extension header, sequence number and N-PDU.
 	 *	 Update the length field if any of them is available.
@@ -438,34 +464,17 @@ struct gtp_pktinfo {
 	struct iphdr		*iph;
 	struct flowi4		fl4;
 	struct rtable		*rt;
-	struct pdp_ctx		*pctx;
 	struct net_device	*dev;
 	__be16			gtph_port;
 };
 
-static void gtp_push_header(struct sk_buff *skb, struct gtp_pktinfo *pktinfo)
-{
-	switch (pktinfo->pctx->gtp_version) {
-	case GTP_V0:
-		pktinfo->gtph_port = htons(GTP0_PORT);
-		gtp0_push_header(skb, pktinfo->pctx);
-		break;
-	case GTP_V1:
-		pktinfo->gtph_port = htons(GTP1U_PORT);
-		gtp1_push_header(skb, pktinfo->pctx);
-		break;
-	}
-}
-
 static inline void gtp_set_pktinfo_ipv4(struct gtp_pktinfo *pktinfo,
 					struct sock *sk, struct iphdr *iph,
-					struct pdp_ctx *pctx, struct rtable *rt,
-					struct flowi4 *fl4,
+					struct rtable *rt, struct flowi4 *fl4,
 					struct net_device *dev)
 {
 	pktinfo->sk	= sk;
 	pktinfo->iph	= iph;
-	pktinfo->pctx	= pctx;
 	pktinfo->rt	= rt;
 	pktinfo->fl4	= *fl4;
 	pktinfo->dev	= dev;
@@ -479,36 +488,58 @@ static int gtp_build_skb_ip4(struct sk_buff *skb, struct net_device *dev,
 	struct rtable *rt;
 	struct flowi4 fl4;
 	struct iphdr *iph;
+	struct ip_tunnel_info *info = NULL;
+	struct sock *sk = NULL;
 	__be16 df;
+	__be32 tun_id;
+	__be32 daddr;
+	u8 gtp_version;
 	int mtu;
 
-	/* Read the IP destination address and resolve the PDP context.
-	 * Prepend PDP header with TEI/TID from PDP ctx.
-	 */
 	iph = ip_hdr(skb);
-	if (gtp->role == GTP_ROLE_SGSN)
-		pctx = ipv4_pdp_find(gtp, iph->saddr);
-	else
-		pctx = ipv4_pdp_find(gtp, iph->daddr);
-
-	if (!pctx) {
-		netdev_dbg(dev, "no PDP ctx found for %pI4, skip\n",
-			   &iph->daddr);
-		return -ENOENT;
+
+	// flow-based GTP1U encap
+	info = skb_tunnel_info(skb);
+	if (gtp->collect_md && info && ntohs(info->key.tp_dst) == GTP1U_PORT) {
+		pctx = NULL;
+		gtp_version = GTP_V1;
+		tun_id = tunnel_id_to_key32(info->key.tun_id);
+		daddr = info->key.u.ipv4.dst;
+		sk = gtp->sk1u;
+
+		netdev_dbg(dev, "flow-based GTP1U encap: tunnel id %d\n",
+			   be32_to_cpu(tun_id));
+	} else {
+		/* Read the IP destination address and resolve the PDP context.
+		 * Prepend PDP header with TEI/TID from PDP ctx.
+		 */
+		if (gtp->role == GTP_ROLE_SGSN)
+			pctx = ipv4_pdp_find(gtp, iph->saddr);
+		else
+			pctx = ipv4_pdp_find(gtp, iph->daddr);
+
+		if (!pctx) {
+			netdev_dbg(dev, "no PDP ctx found for %pI4, skip\n",
+				   &iph->daddr);
+			return -ENOENT;
+		}
+		netdev_dbg(dev, "found PDP context %p\n", pctx);
+
+		gtp_version = pctx->gtp_version;
+		tun_id	= htonl(pctx->u.v1.o_tei);
+		daddr = pctx->peer_addr_ip4.s_addr;
+		sk = pctx->sk;
 	}
-	netdev_dbg(dev, "found PDP context %p\n", pctx);
 
-	rt = ip4_route_output_gtp(&fl4, pctx->sk, pctx->peer_addr_ip4.s_addr);
+	rt = ip4_route_output_gtp(&fl4, sk, daddr);
 	if (IS_ERR(rt)) {
-		netdev_dbg(dev, "no route to SSGN %pI4\n",
-			   &pctx->peer_addr_ip4.s_addr);
+		netdev_dbg(dev, "no route to SSGN %pI4\n", &daddr);
 		dev->stats.tx_carrier_errors++;
 		goto err;
 	}
 
 	if (rt->dst.dev == dev) {
-		netdev_dbg(dev, "circular route to SSGN %pI4\n",
-			   &pctx->peer_addr_ip4.s_addr);
+		netdev_dbg(dev, "circular route to SSGN %pI4\n", &daddr);
 		dev->stats.collisions++;
 		goto err_rt;
 	}
@@ -520,7 +551,7 @@ static int gtp_build_skb_ip4(struct sk_buff *skb, struct net_device *dev,
 	if (df) {
 		mtu = dst_mtu(&rt->dst) - dev->hard_header_len -
 			sizeof(struct iphdr) - sizeof(struct udphdr);
-		switch (pctx->gtp_version) {
+		switch (gtp_version) {
 		case GTP_V0:
 			mtu -= sizeof(struct gtp0_header);
 			break;
@@ -543,8 +574,18 @@ static int gtp_build_skb_ip4(struct sk_buff *skb, struct net_device *dev,
 		goto err_rt;
 	}
 
-	gtp_set_pktinfo_ipv4(pktinfo, pctx->sk, iph, pctx, rt, &fl4, dev);
-	gtp_push_header(skb, pktinfo);
+	gtp_set_pktinfo_ipv4(pktinfo, sk, iph, rt, &fl4, dev);
+
+	switch (gtp_version) {
+	case GTP_V0:
+		pktinfo->gtph_port = htons(GTP0_PORT);
+		gtp0_push_header(skb, pctx);
+		break;
+	case GTP_V1:
+		pktinfo->gtph_port = htons(GTP1U_PORT);
+		gtp1_push_header(skb, tun_id);
+		break;
+	}
 
 	return 0;
 err_rt:
@@ -647,13 +688,14 @@ static int gtp_newlink(struct net *src_net, struct net_device *dev,
 		return -EINVAL;
 
 	gtp = netdev_priv(dev);
+	gtp->net = src_net;
 
 	err = gtp_encap_enable(gtp, data);
 	if (err < 0)
 		return err;
 
 	if (!data[IFLA_GTP_PDP_HASHSIZE])
-		hashsize = 1024;
+		hashsize = GTP_PDP_HASHSIZE;
 	else
 		hashsize = nla_get_u32(data[IFLA_GTP_PDP_HASHSIZE]);
 
-- 
2.9.3
