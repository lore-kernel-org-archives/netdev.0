From: David Ahern <dsahern@gmail.com>
Subject: [PATCH v2 net-next 8/9] net: mpls: Make nla_get_via in af_mpls.c
Date: Sat, 27 May 2017 16:19:32 -0600
Message-ID: <20170527221933.57644-9-dsahern@gmail.com>
References: <20170527221933.57644-1-dsahern@gmail.com>
Cc: roopa@cumulusnetworks.com, David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:35442 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750825AbdE0WTv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 27 May 2017 18:19:51 -0400
Received: by mail-pf0-f194.google.com with SMTP id u26so8199849pfd.2
        for <netdev@vger.kernel.org>; Sat, 27 May 2017 15:19:51 -0700 (PDT)
In-Reply-To: <20170527221933.57644-1-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

nla_get_via is only used in af_mpls.c. Remove declaration from internal.h
and move up in af_mpls.c before first use. Code move only; no
functional change intended.

Signed-off-by: David Ahern <dsahern@gmail.com>
---
 net/mpls/af_mpls.c  | 96 ++++++++++++++++++++++++++---------------------------
 net/mpls/internal.h |  2 --
 2 files changed, 48 insertions(+), 50 deletions(-)

diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
index 0133d1ad9032..a953fcf169ba 100644
--- a/net/mpls/af_mpls.c
+++ b/net/mpls/af_mpls.c
@@ -684,6 +684,54 @@ static int mpls_nh_assign_dev(struct net *net, struct mpls_route *rt,
 	return err;
 }
 
+static int nla_get_via(const struct nlattr *nla, u8 *via_alen, u8 *via_table,
+		       u8 via_addr[], struct netlink_ext_ack *extack)
+{
+	struct rtvia *via = nla_data(nla);
+	int err = -EINVAL;
+	int alen;
+
+	if (nla_len(nla) < offsetof(struct rtvia, rtvia_addr)) {
+		NL_SET_ERR_MSG_ATTR(extack, nla,
+				    "Invalid attribute length for RTA_VIA");
+		goto errout;
+	}
+	alen = nla_len(nla) -
+			offsetof(struct rtvia, rtvia_addr);
+	if (alen > MAX_VIA_ALEN) {
+		NL_SET_ERR_MSG_ATTR(extack, nla,
+				    "Invalid address length for RTA_VIA");
+		goto errout;
+	}
+
+	/* Validate the address family */
+	switch (via->rtvia_family) {
+	case AF_PACKET:
+		*via_table = NEIGH_LINK_TABLE;
+		break;
+	case AF_INET:
+		*via_table = NEIGH_ARP_TABLE;
+		if (alen != 4)
+			goto errout;
+		break;
+	case AF_INET6:
+		*via_table = NEIGH_ND_TABLE;
+		if (alen != 16)
+			goto errout;
+		break;
+	default:
+		/* Unsupported address family */
+		goto errout;
+	}
+
+	memcpy(via_addr, via->rtvia_addr, alen);
+	*via_alen = alen;
+	err = 0;
+
+errout:
+	return err;
+}
+
 static int mpls_nh_build_from_cfg(struct mpls_route_config *cfg,
 				  struct mpls_route *rt)
 {
@@ -1641,54 +1689,6 @@ int nla_get_labels(const struct nlattr *nla, u8 max_labels, u8 *labels,
 }
 EXPORT_SYMBOL_GPL(nla_get_labels);
 
-int nla_get_via(const struct nlattr *nla, u8 *via_alen, u8 *via_table,
-		u8 via_addr[], struct netlink_ext_ack *extack)
-{
-	struct rtvia *via = nla_data(nla);
-	int err = -EINVAL;
-	int alen;
-
-	if (nla_len(nla) < offsetof(struct rtvia, rtvia_addr)) {
-		NL_SET_ERR_MSG_ATTR(extack, nla,
-				    "Invalid attribute length for RTA_VIA");
-		goto errout;
-	}
-	alen = nla_len(nla) -
-			offsetof(struct rtvia, rtvia_addr);
-	if (alen > MAX_VIA_ALEN) {
-		NL_SET_ERR_MSG_ATTR(extack, nla,
-				    "Invalid address length for RTA_VIA");
-		goto errout;
-	}
-
-	/* Validate the address family */
-	switch (via->rtvia_family) {
-	case AF_PACKET:
-		*via_table = NEIGH_LINK_TABLE;
-		break;
-	case AF_INET:
-		*via_table = NEIGH_ARP_TABLE;
-		if (alen != 4)
-			goto errout;
-		break;
-	case AF_INET6:
-		*via_table = NEIGH_ND_TABLE;
-		if (alen != 16)
-			goto errout;
-		break;
-	default:
-		/* Unsupported address family */
-		goto errout;
-	}
-
-	memcpy(via_addr, via->rtvia_addr, alen);
-	*via_alen = alen;
-	err = 0;
-
-errout:
-	return err;
-}
-
 static int rtm_to_route_config(struct sk_buff *skb,
 			       struct nlmsghdr *nlh,
 			       struct mpls_route_config *cfg,
diff --git a/net/mpls/internal.h b/net/mpls/internal.h
index a015a6a1143b..cf65aec2e551 100644
--- a/net/mpls/internal.h
+++ b/net/mpls/internal.h
@@ -204,8 +204,6 @@ int nla_put_labels(struct sk_buff *skb, int attrtype,  u8 labels,
 		   const u32 label[]);
 int nla_get_labels(const struct nlattr *nla, u8 max_labels, u8 *labels,
 		   u32 label[], struct netlink_ext_ack *extack);
-int nla_get_via(const struct nlattr *nla, u8 *via_alen, u8 *via_table,
-		u8 via[], struct netlink_ext_ack *extack);
 bool mpls_output_possible(const struct net_device *dev);
 unsigned int mpls_dev_mtu(const struct net_device *dev);
 bool mpls_pkt_too_big(const struct sk_buff *skb, unsigned int mtu);
-- 
2.11.0 (Apple Git-81)
