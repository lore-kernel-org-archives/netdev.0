From: Jonas Bonn <jonas@southpole.se>
Subject: [PATCH net-next v3 2/2] gtp: support SGSN-side tunnels
Date: Fri, 24 Mar 2017 10:33:58 +0100
Message-ID: <20170324093358.31374-3-jonas@southpole.se>
References: <20170324093358.31374-1-jonas@southpole.se>
Cc: Jonas Bonn <jonas@southpole.se>
To: pablo@netfilter.org, netdev@vger.kernel.org, laforge@gnumonks.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.southpole.se ([37.247.8.11]:49764 "EHLO mail.southpole.se"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751995AbdCXJex (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 24 Mar 2017 05:34:53 -0400
In-Reply-To: <20170324093358.31374-1-jonas@southpole.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The GTP-tunnel driver is explicitly GGSN-side as it searches for PDP
contexts based on the incoming packets _destination_ address.  If we
want to place ourselves on the SGSN side of the  tunnel, then we want
to be identifying PDP contexts based on _source_ address.

Let it be noted that in a "real" configuration this module would never
be used:  the SGSN normally does not see IP packets as input.  The
justification for this functionality is for PGW load-testing applications
where the input to the SGSN is locally generally IP traffic.

This patch adds a "role" argument at GTP-link creation time to specify
whether we are on the GGSN or SGSN side of the tunnel; this flag is then
used to determine which part of the IP packet to use in determining
the PDP context.

Signed-off-by: Jonas Bonn <jonas@southpole.se>
Acked-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 drivers/net/gtp.c            | 41 +++++++++++++++++++++++++++++++----------
 include/uapi/linux/if_link.h |  7 +++++++
 2 files changed, 38 insertions(+), 10 deletions(-)

diff --git a/drivers/net/gtp.c b/drivers/net/gtp.c
index 3806be6..b54d1a3 100644
--- a/drivers/net/gtp.c
+++ b/drivers/net/gtp.c
@@ -72,6 +72,7 @@ struct gtp_dev {
 	struct net		*net;
 	struct net_device	*dev;
 
+	unsigned int		role;
 	unsigned int		hash_size;
 	struct hlist_head	*tid_hash;
 	struct hlist_head	*addr_hash;
@@ -150,8 +151,8 @@ static struct pdp_ctx *ipv4_pdp_find(struct gtp_dev *gtp, __be32 ms_addr)
 	return NULL;
 }
 
-static bool gtp_check_src_ms_ipv4(struct sk_buff *skb, struct pdp_ctx *pctx,
-				  unsigned int hdrlen)
+static bool gtp_check_ms_ipv4(struct sk_buff *skb, struct pdp_ctx *pctx,
+				  unsigned int hdrlen, unsigned int role)
 {
 	struct iphdr *iph;
 
@@ -160,18 +161,22 @@ static bool gtp_check_src_ms_ipv4(struct sk_buff *skb, struct pdp_ctx *pctx,
 
 	iph = (struct iphdr *)(skb->data + hdrlen);
 
-	return iph->saddr == pctx->ms_addr_ip4.s_addr;
+	if (role == GTP_ROLE_SGSN) {
+		return iph->daddr == pctx->ms_addr_ip4.s_addr;
+	} else {
+		return iph->saddr == pctx->ms_addr_ip4.s_addr;
+	}
 }
 
-/* Check if the inner IP source address in this packet is assigned to any
+/* Check if the inner IP address in this packet is assigned to any
  * existing mobile subscriber.
  */
-static bool gtp_check_src_ms(struct sk_buff *skb, struct pdp_ctx *pctx,
-			     unsigned int hdrlen)
+static bool gtp_check_ms(struct sk_buff *skb, struct pdp_ctx *pctx,
+			     unsigned int hdrlen, unsigned int role)
 {
 	switch (ntohs(skb->protocol)) {
 	case ETH_P_IP:
-		return gtp_check_src_ms_ipv4(skb, pctx, hdrlen);
+		return gtp_check_ms_ipv4(skb, pctx, hdrlen, role);
 	}
 	return false;
 }
@@ -205,7 +210,7 @@ static int gtp0_udp_encap_recv(struct gtp_dev *gtp, struct sk_buff *skb,
 		goto out_rcu;
 	}
 
-	if (!gtp_check_src_ms(skb, pctx, hdrlen)) {
+	if (!gtp_check_ms(skb, pctx, hdrlen, gtp->role)) {
 		netdev_dbg(gtp->dev, "No PDP ctx for this MS\n");
 		ret = -1;
 		goto out_rcu;
@@ -262,7 +267,7 @@ static int gtp1u_udp_encap_recv(struct gtp_dev *gtp, struct sk_buff *skb,
 		goto out_rcu;
 	}
 
-	if (!gtp_check_src_ms(skb, pctx, hdrlen)) {
+	if (!gtp_check_ms(skb, pctx, hdrlen, gtp->role)) {
 		netdev_dbg(gtp->dev, "No PDP ctx for this MS\n");
 		ret = -1;
 		goto out_rcu;
@@ -491,7 +496,11 @@ static int gtp_build_skb_ip4(struct sk_buff *skb, struct net_device *dev,
 	 * Prepend PDP header with TEI/TID from PDP ctx.
 	 */
 	iph = ip_hdr(skb);
-	pctx = ipv4_pdp_find(gtp, iph->daddr);
+	if (gtp->role == GTP_ROLE_SGSN) {
+		pctx = ipv4_pdp_find(gtp, iph->saddr);
+	} else {
+		pctx = ipv4_pdp_find(gtp, iph->daddr);
+	}
 	if (!pctx) {
 		netdev_dbg(dev, "no PDP ctx found for %pI4, skip\n",
 			   &iph->daddr);
@@ -666,12 +675,23 @@ static int gtp_newlink(struct net *src_net, struct net_device *dev,
 	int hashsize, err, fd0, fd1;
 	struct gtp_dev *gtp;
 	struct gtp_net *gn;
+	unsigned int role;
+
+	if (data[IFLA_GTP_ROLE]) {
+		role = nla_get_u32(data[IFLA_GTP_ROLE]);
+		if (role > GTP_ROLE_SGSN)
+			return -EINVAL;
+	} else {
+		role = GTP_ROLE_GGSN;
+	}
 
 	if (!data[IFLA_GTP_FD0] || !data[IFLA_GTP_FD1])
 		return -EINVAL;
 
 	gtp = netdev_priv(dev);
 
+	gtp->role = role;
+
 	fd0 = nla_get_u32(data[IFLA_GTP_FD0]);
 	fd1 = nla_get_u32(data[IFLA_GTP_FD1]);
 
@@ -723,6 +743,7 @@ static const struct nla_policy gtp_policy[IFLA_GTP_MAX + 1] = {
 	[IFLA_GTP_FD0]			= { .type = NLA_U32 },
 	[IFLA_GTP_FD1]			= { .type = NLA_U32 },
 	[IFLA_GTP_PDP_HASHSIZE]		= { .type = NLA_U32 },
+	[IFLA_GTP_ROLE]			= { .type = NLA_U32 },
 };
 
 static int gtp_validate(struct nlattr *tb[], struct nlattr *data[])
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index ccde456..da62d8c 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -533,11 +533,18 @@ enum {
 #define IFLA_PPP_MAX (__IFLA_PPP_MAX - 1)
 
 /* GTP section */
+
+enum ifla_gtp_role {
+	GTP_ROLE_GGSN = 0,
+	GTP_ROLE_SGSN,
+};
+
 enum {
 	IFLA_GTP_UNSPEC,
 	IFLA_GTP_FD0,
 	IFLA_GTP_FD1,
 	IFLA_GTP_PDP_HASHSIZE,
+	IFLA_GTP_ROLE,
 	__IFLA_GTP_MAX,
 };
 #define IFLA_GTP_MAX (__IFLA_GTP_MAX - 1)
-- 
2.9.3
