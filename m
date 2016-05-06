From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH v3 net-next 03/11] gre6: Fix flag translations
Date: Fri, 6 May 2016 15:11:58 -0700
Message-ID: <1462572726-566137-4-git-send-email-tom@herbertland.com>
References: <1462572726-566137-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:51281 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758944AbcEFWMS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 May 2016 18:12:18 -0400
Received: from pps.filterd (m0044010.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u46MBxf1022301
	for <netdev@vger.kernel.org>; Fri, 6 May 2016 15:12:17 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 22rybth96c-2
	(version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 06 May 2016 15:12:17 -0700
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.212.236.87) with ESMTP	id
 975bbb0613d711e6ae7d0002c9521c9e-807fcc50 for <netdev@vger.kernel.org>;	Fri,
 06 May 2016 15:12:16 -0700
In-Reply-To: <1462572726-566137-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

GRE for IPv6 does not properly translate for GRE flags to tunnel
flags and vice versa. This patch fixes that.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 net/ipv6/ip6_gre.c | 20 ++++++++++++--------
 1 file changed, 12 insertions(+), 8 deletions(-)

diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
index 47b671a..70a1f72 100644
--- a/net/ipv6/ip6_gre.c
+++ b/net/ipv6/ip6_gre.c
@@ -799,8 +799,8 @@ static void ip6gre_tnl_parm_from_user(struct __ip6_tnl_parm *p,
 	p->link = u->link;
 	p->i_key = u->i_key;
 	p->o_key = u->o_key;
-	p->i_flags = u->i_flags;
-	p->o_flags = u->o_flags;
+	p->i_flags = gre_flags_to_tnl_flags(u->i_flags);
+	p->o_flags = gre_flags_to_tnl_flags(u->o_flags);
 	memcpy(p->name, u->name, sizeof(u->name));
 }
 
@@ -817,8 +817,8 @@ static void ip6gre_tnl_parm_to_user(struct ip6_tnl_parm2 *u,
 	u->link = p->link;
 	u->i_key = p->i_key;
 	u->o_key = p->o_key;
-	u->i_flags = p->i_flags;
-	u->o_flags = p->o_flags;
+	u->i_flags = gre_tnl_flags_to_gre_flags(p->i_flags);
+	u->o_flags = gre_tnl_flags_to_gre_flags(p->o_flags);
 	memcpy(u->name, p->name, sizeof(u->name));
 }
 
@@ -1217,10 +1217,12 @@ static void ip6gre_netlink_parms(struct nlattr *data[],
 		parms->link = nla_get_u32(data[IFLA_GRE_LINK]);
 
 	if (data[IFLA_GRE_IFLAGS])
-		parms->i_flags = nla_get_be16(data[IFLA_GRE_IFLAGS]);
+		parms->i_flags = gre_flags_to_tnl_flags(
+				nla_get_be16(data[IFLA_GRE_IFLAGS]));
 
 	if (data[IFLA_GRE_OFLAGS])
-		parms->o_flags = nla_get_be16(data[IFLA_GRE_OFLAGS]);
+		parms->o_flags = gre_flags_to_tnl_flags(
+				nla_get_be16(data[IFLA_GRE_OFLAGS]));
 
 	if (data[IFLA_GRE_IKEY])
 		parms->i_key = nla_get_be32(data[IFLA_GRE_IKEY]);
@@ -1412,8 +1414,10 @@ static int ip6gre_fill_info(struct sk_buff *skb, const struct net_device *dev)
 	struct __ip6_tnl_parm *p = &t->parms;
 
 	if (nla_put_u32(skb, IFLA_GRE_LINK, p->link) ||
-	    nla_put_be16(skb, IFLA_GRE_IFLAGS, p->i_flags) ||
-	    nla_put_be16(skb, IFLA_GRE_OFLAGS, p->o_flags) ||
+	    nla_put_be16(skb, IFLA_GRE_IFLAGS,
+			 gre_tnl_flags_to_gre_flags(p->i_flags)) ||
+	    nla_put_be16(skb, IFLA_GRE_OFLAGS,
+			 gre_tnl_flags_to_gre_flags(p->o_flags)) ||
 	    nla_put_be32(skb, IFLA_GRE_IKEY, p->i_key) ||
 	    nla_put_be32(skb, IFLA_GRE_OKEY, p->o_key) ||
 	    nla_put_in6_addr(skb, IFLA_GRE_LOCAL, &p->laddr) ||
-- 
2.8.0.rc2
