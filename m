From: Harald Welte <laforge@netfilter.org>
Subject: Re: [PATCH 1/1] gtp: support SGSN-side tunnels
Date: Wed, 15 Mar 2017 20:10:38 +0100
Message-ID: <20170315191038.nco2icu6e545rzlu@nataraja>
References: <20170203091231.10142-1-jonas@southpole.se>
 <20170315163916.gins7lzzqhwkvfrc@nataraja>
 <20170315172348.GA30592@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jonas Bonn <jonas@southpole.se>, netdev@vger.kernel.org,
        osmocom-net-gprs@lists.osmocom.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ganesha.gnumonks.org ([213.95.27.120]:55462 "EHLO
        ganesha.gnumonks.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751183AbdCOTQA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Mar 2017 15:16:00 -0400
Content-Disposition: inline
In-Reply-To: <20170315172348.GA30592@salvia>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Pablo,

On Wed, Mar 15, 2017 at 06:23:48PM +0100, Pablo Neira Ayuso wrote:
> On Wed, Mar 15, 2017 at 05:39:16PM +0100, Harald Welte wrote:
> > 
> > I would definitely like to see this move forward, particularly in order
> > to test the GGSN-side code.
> 
> Agreed.

I've modified the patch slightly, see below (compile-tested, but not
otherwise tested yet).  Basically rename the flags attribute to 'role',
expand the commit log and removed unrelated cosmetic changes.

I've also prepared a corresponding change to libgtpnl into the
laforge/sgsn-rol branch, see
http://git.osmocom.org/libgtpnl/commit/?h=laforge/sgsn-role

This is not yet tested in any way, but I'm planning to add some
associated support to the command line tools and then give it some
testing (both against the kernel GTP in GGSN mode, as well as an
independent userspace GTP implementation).

> It would be good if we provide a way to configure GTP via iproute2 for
> testing purposes.

I don't really care about which tool is used, as long as it is easily
available [and FOSS, of course].

> We would need to create some dummy socket from
> kernel too though so we don't need any userspace daemon for this
> testing mode.

I don't really like that latter idea. It sounds too much like a hack to
me.  But then, I don't have enough phantasy right now ti imagine how an
actual implementation would look like.

To me, it is perfectly fine to run a simple, small utility in userspace
even for testing.

Regards,
	Harald

>From 63920950f9498069993def78e178bde85c174e0c Mon Sep 17 00:00:00 2001
From: Jonas Bonn <jonas@southpole.se>
Date: Wed, 15 Mar 2017 17:52:28 +0100
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

diff --git a/drivers/net/gtp.c b/drivers/net/gtp.c
index 99d3df788ce8..9aef4217f6e1 100644
--- a/drivers/net/gtp.c
+++ b/drivers/net/gtp.c
@@ -71,6 +71,7 @@ struct gtp_dev {
 
 	struct net_device	*dev;
 
+	enum ifla_gtp_role	role;
 	unsigned int		hash_size;
 	struct hlist_head	*tid_hash;
 	struct hlist_head	*addr_hash;
@@ -149,8 +150,8 @@ static struct pdp_ctx *ipv4_pdp_find(struct gtp_dev *gtp, __be32 ms_addr)
 	return NULL;
 }
 
-static bool gtp_check_src_ms_ipv4(struct sk_buff *skb, struct pdp_ctx *pctx,
-				  unsigned int hdrlen)
+static bool gtp_check_ms_ipv4(struct sk_buff *skb, struct pdp_ctx *pctx,
+				  unsigned int hdrlen, enum ifla_gtp_role role)
 {
 	struct iphdr *iph;
 
@@ -159,18 +160,21 @@ static bool gtp_check_src_ms_ipv4(struct sk_buff *skb, struct pdp_ctx *pctx,
 
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
@@ -204,7 +208,7 @@ static int gtp0_udp_encap_recv(struct gtp_dev *gtp, struct sk_buff *skb,
 		goto out_rcu;
 	}
 
-	if (!gtp_check_src_ms(skb, pctx, hdrlen)) {
+	if (!gtp_check_ms(skb, pctx, hdrlen, gtp->role)) {
 		netdev_dbg(gtp->dev, "No PDP ctx for this MS\n");
 		ret = -1;
 		goto out_rcu;
@@ -261,7 +265,7 @@ static int gtp1u_udp_encap_recv(struct gtp_dev *gtp, struct sk_buff *skb,
 		goto out_rcu;
 	}
 
-	if (!gtp_check_src_ms(skb, pctx, hdrlen)) {
+	if (!gtp_check_ms(skb, pctx, hdrlen, gtp->role)) {
 		netdev_dbg(gtp->dev, "No PDP ctx for this MS\n");
 		ret = -1;
 		goto out_rcu;
@@ -490,7 +494,11 @@ static int gtp_build_skb_ip4(struct sk_buff *skb, struct net_device *dev,
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
@@ -665,12 +673,26 @@ static int gtp_newlink(struct net *src_net, struct net_device *dev,
 	int hashsize, err, fd0, fd1;
 	struct gtp_dev *gtp;
 	struct gtp_net *gn;
+	unsigned int role;
+
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
 
 	if (!data[IFLA_GTP_FD0] || !data[IFLA_GTP_FD1])
 		return -EINVAL;
 
 	gtp = netdev_priv(dev);
 
+	gtp->role = role;
+
 	fd0 = nla_get_u32(data[IFLA_GTP_FD0]);
 	fd1 = nla_get_u32(data[IFLA_GTP_FD1]);
 
@@ -722,6 +744,7 @@ static const struct nla_policy gtp_policy[IFLA_GTP_MAX + 1] = {
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
index 6b13e591abc9..de7bea223749 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -536,11 +536,18 @@ enum {
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
