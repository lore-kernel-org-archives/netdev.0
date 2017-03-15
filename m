From: Harald Welte <laforge@netfilter.org>
Subject: Re: [PATCH 1/1] gtp: support SGSN-side tunnels
Date: Wed, 15 Mar 2017 20:27:47 +0100
Message-ID: <20170315192747.3oj2ro23qkbhe6iy@nataraja>
References: <20170203091231.10142-1-jonas@southpole.se>
 <20170315163916.gins7lzzqhwkvfrc@nataraja>
 <20170315172348.GA30592@salvia>
 <20170315191038.nco2icu6e545rzlu@nataraja>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jonas Bonn <jonas@southpole.se>, netdev@vger.kernel.org,
        osmocom-net-gprs@lists.osmocom.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ganesha.gnumonks.org ([213.95.27.120]:55556 "EHLO
        ganesha.gnumonks.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750774AbdCOT14 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Mar 2017 15:27:56 -0400
Content-Disposition: inline
In-Reply-To: <20170315191038.nco2icu6e545rzlu@nataraja>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 15, 2017 at 08:10:38PM +0100, Harald Welte wrote:
> I've modified the patch slightly, see below (compile-tested, but not
> otherwise tested yet).  Basically rename the flags attribute to 'role',
> expand the commit log and removed unrelated cosmetic changes.

I also have a version against current net-next/master, in case anyone is interested..

>From 3274a3303d1ec997392a07a92666d57b13997658 Mon Sep 17 00:00:00 2001
From: Jonas Bonn <jonas@southpole.se>
Date: Wed, 15 Mar 2017 20:24:28 +0100
Subject: [PATCH] gtp: support SGSN-side tunnels

The GTP-tunnel driver is explicitly GGSN-side as it searches for PDP
contexts based on the incoming packets _destination_ address.  For
real-world use cases, this is sufficient, as the other side of a GTP
tunnel is not in fact implemented by GTP, but by the protocol stacking
of a mobile station / user equipment on the radio interface (like PDCP,
SNDCP).

However, if we want to simulate the mobile station, radio access network
and SGSN (for example to test the GGSN side implementation), then we
want to be identifying PDP contexts based on _source_ address.

This patch adds a "role" attribute at GTP-link creation time to specify
whether we behave like the GGSN or SGSN role of the tunnel; this
attribute is then used to determine which part of the IP packet to use
in determining the PDP context.

Signed-off-by: Jonas Bonn <jonas@southpole.se>
Signed-off-by: Harald Welte <laforge@gnumonks.org>
---
 drivers/net/gtp.c            | 46 +++++++++++++++++++++++++++++++++-----------
 include/uapi/linux/gtp.h     |  2 +-
 include/uapi/linux/if_link.h |  7 +++++++
 3 files changed, 43 insertions(+), 12 deletions(-)

diff --git a/drivers/net/gtp.c b/drivers/net/gtp.c
index 3e1854f34420..3ab593b9be85 100644
--- a/drivers/net/gtp.c
+++ b/drivers/net/gtp.c
@@ -74,6 +74,7 @@ struct gtp_dev {
 
 	struct net_device	*dev;
 
+	enum ifla_gtp_role	role;
 	unsigned int		hash_size;
 	struct hlist_head	*tid_hash;
 	struct hlist_head	*addr_hash;
@@ -154,8 +155,8 @@ static struct pdp_ctx *ipv4_pdp_find(struct gtp_dev *gtp, __be32 ms_addr)
 	return NULL;
 }
 
-static bool gtp_check_src_ms_ipv4(struct sk_buff *skb, struct pdp_ctx *pctx,
-				  unsigned int hdrlen)
+static bool gtp_check_ms_ipv4(struct sk_buff *skb, struct pdp_ctx *pctx,
+				  unsigned int hdrlen, enum ifla_gtp_role role)
 {
 	struct iphdr *iph;
 
@@ -164,27 +165,31 @@ static bool gtp_check_src_ms_ipv4(struct sk_buff *skb, struct pdp_ctx *pctx,
 
 	iph = (struct iphdr *)(skb->data + hdrlen);
 
-	return iph->saddr == pctx->ms_addr_ip4.s_addr;
+	if (role == GTP_ROLE_SGSN)
+		return iph->daddr == pctx->ms_addr_ip4.s_addr;
+	else
+		return iph->saddr == pctx->ms_addr_ip4.s_addr;
 }
 
 /* Check if the inner IP source address in this packet is assigned to any
  * existing mobile subscriber.
  */
-static bool gtp_check_src_ms(struct sk_buff *skb, struct pdp_ctx *pctx,
-			     unsigned int hdrlen)
+static bool gtp_check_ms(struct sk_buff *skb, struct pdp_ctx *pctx,
+			     unsigned int hdrlen, enum ifla_gtp_role role)
 {
 	switch (ntohs(skb->protocol)) {
 	case ETH_P_IP:
-		return gtp_check_src_ms_ipv4(skb, pctx, hdrlen);
+		return gtp_check_ms_ipv4(skb, pctx, hdrlen, role);
 	}
 	return false;
 }
 
-static int gtp_rx(struct pdp_ctx *pctx, struct sk_buff *skb, unsigned int hdrlen)
+static int gtp_rx(struct pdp_ctx *pctx, struct sk_buff *skb, unsigned int hdrlen,
+		  enum ifla_gtp_role role)
 {
 	struct pcpu_sw_netstats *stats;
 
-	if (!gtp_check_src_ms(skb, pctx, hdrlen)) {
+	if (!gtp_check_ms(skb, pctx, hdrlen, role)) {
 		netdev_dbg(pctx->dev, "No PDP ctx for this MS\n");
 		return 1;
 	}
@@ -239,7 +244,7 @@ static int gtp0_udp_encap_recv(struct gtp_dev *gtp, struct sk_buff *skb)
 		return 1;
 	}
 
-	return gtp_rx(pctx, skb, hdrlen);
+	return gtp_rx(pctx, skb, hdrlen, gtp->role);
 }
 
 static int gtp1u_udp_encap_recv(struct gtp_dev *gtp, struct sk_buff *skb)
@@ -281,7 +286,7 @@ static int gtp1u_udp_encap_recv(struct gtp_dev *gtp, struct sk_buff *skb)
 		return 1;
 	}
 
-	return gtp_rx(pctx, skb, hdrlen);
+	return gtp_rx(pctx, skb, hdrlen, gtp->role);
 }
 
 static void gtp_encap_destroy(struct sock *sk)
@@ -481,7 +486,11 @@ static int gtp_build_skb_ip4(struct sk_buff *skb, struct net_device *dev,
 	 * Prepend PDP header with TEI/TID from PDP ctx.
 	 */
 	iph = ip_hdr(skb);
-	pctx = ipv4_pdp_find(gtp, iph->daddr);
+	if (gtp->role == GTP_ROLE_SGSN)
+		pctx = ipv4_pdp_find(gtp, iph->saddr);
+	else
+		pctx = ipv4_pdp_find(gtp, iph->daddr);
+
 	if (!pctx) {
 		netdev_dbg(dev, "no PDP ctx found for %pI4, skip\n",
 			   &iph->daddr);
@@ -631,13 +640,27 @@ static int gtp_newlink(struct net *src_net, struct net_device *dev,
 {
 	struct gtp_dev *gtp;
 	struct gtp_net *gn;
+	unsigned int role;
 	int hashsize, err;
 
+	/* The default role is GGSN, and for backwards compatibility
+	 * reasons, the lack of a IFLA_GTP_ROLE IE means that we're
+	 * operating in GGSN role. */
+	if (data[IFLA_GTP_ROLE]) {
+		role = nla_get_u32(data[IFLA_GTP_ROLE]);
+		if (role != GTP_ROLE_GGSN &&
+		    role != GTP_ROLE_SGSN)
+			return -EINVAL;
+	} else
+		role = GTP_ROLE_GGSN;
+
 	if (!data[IFLA_GTP_FD0] && !data[IFLA_GTP_FD1])
 		return -EINVAL;
 
 	gtp = netdev_priv(dev);
 
+	gtp->role = role;
+
 	err = gtp_encap_enable(gtp, data);
 	if (err < 0)
 		return err;
@@ -685,6 +708,7 @@ static const struct nla_policy gtp_policy[IFLA_GTP_MAX + 1] = {
 	[IFLA_GTP_FD0]			= { .type = NLA_U32 },
 	[IFLA_GTP_FD1]			= { .type = NLA_U32 },
 	[IFLA_GTP_PDP_HASHSIZE]		= { .type = NLA_U32 },
+	[IFLA_GTP_ROLE]			= { .type = NLA_U32 },
 };
 
 static int gtp_validate(struct nlattr *tb[], struct nlattr *data[])
diff --git a/include/uapi/linux/gtp.h b/include/uapi/linux/gtp.h
index 72a04a0e8cce..79037cca6b51 100644
--- a/include/uapi/linux/gtp.h
+++ b/include/uapi/linux/gtp.h
@@ -19,7 +19,7 @@ enum gtp_attrs {
 	GTPA_LINK,
 	GTPA_VERSION,
 	GTPA_TID,	/* for GTPv0 only */
-	GTPA_SGSN_ADDRESS,
+	GTPA_SGSN_ADDRESS, /* Remote GSN, either SGSN or GGSN */
 	GTPA_MS_ADDRESS,
 	GTPA_FLOW,
 	GTPA_NET_NS_FD,
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index 320fc1e747ee..8b405afb2376 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -538,11 +538,18 @@ enum {
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
2.11.0

-- 
- Harald Welte <laforge@netfilter.org>                 http://netfilter.org/
============================================================================
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie
