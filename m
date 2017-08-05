From: David Lebrun <david.lebrun@uclouvain.be>
Subject: [PATCH net-next v2 4/5] ipv6: sr: add rtnetlink functions for seg6local action parameters
Date: Sat, 5 Aug 2017 12:38:27 +0200
Message-ID: <20170805103828.21458-5-david.lebrun@uclouvain.be>
References: <20170805103828.21458-1-david.lebrun@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Lebrun <david.lebrun@uclouvain.be>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:38892 "EHLO
        smtp5.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751371AbdHEKi3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 5 Aug 2017 06:38:29 -0400
Received: from mailboxes.uclouvain.be (mailboxes.uclouvain.be [130.104.6.131])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-SHA384 (256/256 bits))
        (No client certificate requested)
        by smtp5.sgsi.ucl.ac.be (Postfix) with ESMTPS id 1ABD867DC4E
        for <netdev@vger.kernel.org>; Sat,  5 Aug 2017 12:38:20 +0200 (CEST)
In-Reply-To: <20170805103828.21458-1-david.lebrun@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the necessary functions to parse, fill, and compare
seg6local rtnetlink attributes, for all defined action parameters.

- The SRH parameter defines an SRH to be inserted or encapsulated.
- The TABLE parameter defines the table to use for the route lookup of
  the next segment or the inner decapsulated packet.
- The NH4 parameter defines the IPv4 next-hop for an inner decapsulated
  IPv4 packet.
- The NH6 parameter defines the IPv6 next-hop for the next segment or
  for an inner decapsulated IPv6 packet
- The IIF parameter defines an ingress interface index.
- The OIF parameter defines an egress interface index.

Signed-off-by: David Lebrun <david.lebrun@uclouvain.be>
---
 net/ipv6/seg6_local.c | 211 +++++++++++++++++++++++++++++++++++++++++++++-----
 1 file changed, 193 insertions(+), 18 deletions(-)

diff --git a/net/ipv6/seg6_local.c b/net/ipv6/seg6_local.c
index 53615d7..ab1fc1b 100644
--- a/net/ipv6/seg6_local.c
+++ b/net/ipv6/seg6_local.c
@@ -104,6 +104,181 @@ static const struct nla_policy seg6_local_policy[SEG6_LOCAL_MAX + 1] = {
 	[SEG6_LOCAL_OIF]	= { .type = NLA_U32 },
 };
 
+static int parse_nla_srh(struct nlattr **attrs, struct seg6_local_lwt *slwt)
+{
+	struct ipv6_sr_hdr *srh;
+	int len;
+
+	srh = nla_data(attrs[SEG6_LOCAL_SRH]);
+	len = nla_len(attrs[SEG6_LOCAL_SRH]);
+
+	/* SRH must contain at least one segment */
+	if (len < sizeof(*srh) + sizeof(struct in6_addr))
+		return -EINVAL;
+
+	if (!seg6_validate_srh(srh, len))
+		return -EINVAL;
+
+	slwt->srh = kmalloc(len, GFP_KERNEL);
+	if (!slwt->srh)
+		return -ENOMEM;
+
+	memcpy(slwt->srh, srh, len);
+
+	slwt->headroom += len;
+
+	return 0;
+}
+
+static int put_nla_srh(struct sk_buff *skb, struct seg6_local_lwt *slwt)
+{
+	struct ipv6_sr_hdr *srh;
+	struct nlattr *nla;
+	int len;
+
+	srh = slwt->srh;
+	len = (srh->hdrlen + 1) << 3;
+
+	nla = nla_reserve(skb, SEG6_LOCAL_SRH, len);
+	if (!nla)
+		return -EMSGSIZE;
+
+	memcpy(nla_data(nla), srh, len);
+
+	return 0;
+}
+
+static int cmp_nla_srh(struct seg6_local_lwt *a, struct seg6_local_lwt *b)
+{
+	int len = (a->srh->hdrlen + 1) << 3;
+
+	if (len != ((b->srh->hdrlen + 1) << 3))
+		return 1;
+
+	return memcmp(a->srh, b->srh, len);
+}
+
+static int parse_nla_table(struct nlattr **attrs, struct seg6_local_lwt *slwt)
+{
+	slwt->table = nla_get_u32(attrs[SEG6_LOCAL_TABLE]);
+
+	return 0;
+}
+
+static int put_nla_table(struct sk_buff *skb, struct seg6_local_lwt *slwt)
+{
+	if (nla_put_u32(skb, SEG6_LOCAL_TABLE, slwt->table))
+		return -EMSGSIZE;
+
+	return 0;
+}
+
+static int cmp_nla_table(struct seg6_local_lwt *a, struct seg6_local_lwt *b)
+{
+	if (a->table != b->table)
+		return 1;
+
+	return 0;
+}
+
+static int parse_nla_nh4(struct nlattr **attrs, struct seg6_local_lwt *slwt)
+{
+	memcpy(&slwt->nh4, nla_data(attrs[SEG6_LOCAL_NH4]),
+	       sizeof(struct in_addr));
+
+	return 0;
+}
+
+static int put_nla_nh4(struct sk_buff *skb, struct seg6_local_lwt *slwt)
+{
+	struct nlattr *nla;
+
+	nla = nla_reserve(skb, SEG6_LOCAL_NH4, sizeof(struct in_addr));
+	if (!nla)
+		return -EMSGSIZE;
+
+	memcpy(nla_data(nla), &slwt->nh4, sizeof(struct in_addr));
+
+	return 0;
+}
+
+static int cmp_nla_nh4(struct seg6_local_lwt *a, struct seg6_local_lwt *b)
+{
+	return memcmp(&a->nh4, &b->nh4, sizeof(struct in_addr));
+}
+
+static int parse_nla_nh6(struct nlattr **attrs, struct seg6_local_lwt *slwt)
+{
+	memcpy(&slwt->nh6, nla_data(attrs[SEG6_LOCAL_NH6]),
+	       sizeof(struct in6_addr));
+
+	return 0;
+}
+
+static int put_nla_nh6(struct sk_buff *skb, struct seg6_local_lwt *slwt)
+{
+	struct nlattr *nla;
+
+	nla = nla_reserve(skb, SEG6_LOCAL_NH6, sizeof(struct in6_addr));
+	if (!nla)
+		return -EMSGSIZE;
+
+	memcpy(nla_data(nla), &slwt->nh6, sizeof(struct in6_addr));
+
+	return 0;
+}
+
+static int cmp_nla_nh6(struct seg6_local_lwt *a, struct seg6_local_lwt *b)
+{
+	return memcmp(&a->nh6, &b->nh6, sizeof(struct in6_addr));
+}
+
+static int parse_nla_iif(struct nlattr **attrs, struct seg6_local_lwt *slwt)
+{
+	slwt->iif = nla_get_u32(attrs[SEG6_LOCAL_IIF]);
+
+	return 0;
+}
+
+static int put_nla_iif(struct sk_buff *skb, struct seg6_local_lwt *slwt)
+{
+	if (nla_put_u32(skb, SEG6_LOCAL_IIF, slwt->iif))
+		return -EMSGSIZE;
+
+	return 0;
+}
+
+static int cmp_nla_iif(struct seg6_local_lwt *a, struct seg6_local_lwt *b)
+{
+	if (a->iif != b->iif)
+		return 1;
+
+	return 0;
+}
+
+static int parse_nla_oif(struct nlattr **attrs, struct seg6_local_lwt *slwt)
+{
+	slwt->oif = nla_get_u32(attrs[SEG6_LOCAL_OIF]);
+
+	return 0;
+}
+
+static int put_nla_oif(struct sk_buff *skb, struct seg6_local_lwt *slwt)
+{
+	if (nla_put_u32(skb, SEG6_LOCAL_OIF, slwt->oif))
+		return -EMSGSIZE;
+
+	return 0;
+}
+
+static int cmp_nla_oif(struct seg6_local_lwt *a, struct seg6_local_lwt *b)
+{
+	if (a->oif != b->oif)
+		return 1;
+
+	return 0;
+}
+
 struct seg6_action_param {
 	int (*parse)(struct nlattr **attrs, struct seg6_local_lwt *slwt);
 	int (*put)(struct sk_buff *skb, struct seg6_local_lwt *slwt);
@@ -111,29 +286,29 @@ struct seg6_action_param {
 };
 
 static struct seg6_action_param seg6_action_params[SEG6_LOCAL_MAX + 1] = {
-	[SEG6_LOCAL_SRH]	= { .parse = NULL,
-				    .put = NULL,
-				    .cmp = NULL },
+	[SEG6_LOCAL_SRH]	= { .parse = parse_nla_srh,
+				    .put = put_nla_srh,
+				    .cmp = cmp_nla_srh },
 
-	[SEG6_LOCAL_TABLE]	= { .parse = NULL,
-				    .put = NULL,
-				    .cmp = NULL },
+	[SEG6_LOCAL_TABLE]	= { .parse = parse_nla_table,
+				    .put = put_nla_table,
+				    .cmp = cmp_nla_table },
 
-	[SEG6_LOCAL_NH4]	= { .parse = NULL,
-				    .put = NULL,
-				    .cmp = NULL },
+	[SEG6_LOCAL_NH4]	= { .parse = parse_nla_nh4,
+				    .put = put_nla_nh4,
+				    .cmp = cmp_nla_nh4 },
 
-	[SEG6_LOCAL_NH6]	= { .parse = NULL,
-				    .put = NULL,
-				    .cmp = NULL },
+	[SEG6_LOCAL_NH6]	= { .parse = parse_nla_nh6,
+				    .put = put_nla_nh6,
+				    .cmp = cmp_nla_nh6 },
 
-	[SEG6_LOCAL_IIF]	= { .parse = NULL,
-				    .put = NULL,
-				    .cmp = NULL },
+	[SEG6_LOCAL_IIF]	= { .parse = parse_nla_iif,
+				    .put = put_nla_iif,
+				    .cmp = cmp_nla_iif },
 
-	[SEG6_LOCAL_OIF]	= { .parse = NULL,
-				    .put = NULL,
-				    .cmp = NULL },
+	[SEG6_LOCAL_OIF]	= { .parse = parse_nla_oif,
+				    .put = put_nla_oif,
+				    .cmp = cmp_nla_oif },
 };
 
 static int parse_nla_action(struct nlattr **attrs, struct seg6_local_lwt *slwt)
-- 
2.10.2
