From: David Lamparter <equinox@diac24.net>
Subject: [PATCH 5/6] bridge: add VPLS pseudowire info in fdb dump
Date: Wed, 16 Aug 2017 19:02:01 +0200
Message-ID: <20170816170202.456851-6-equinox@diac24.net>
References: <20170816170202.456851-1-equinox@diac24.net>
Cc: amine.kherbouche@6wind.com, roopa@cumulusnetworks.com,
        David Lamparter <equinox@diac24.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eidolon.nox.tf ([185.142.180.128]:43718 "EHLO eidolon.nox.tf"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751678AbdHPRC3 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 16 Aug 2017 13:02:29 -0400
In-Reply-To: <20170816170202.456851-1-equinox@diac24.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a NDA_VPLS_WIRE attribute to the FDB dump if we have dst metadata
that is indicative of a VPLS pseudowire.  This is really helpful for
debugging.

Signed-off-by: David Lamparter <equinox@diac24.net>
---
 include/uapi/linux/neighbour.h |  1 +
 net/bridge/br_fdb.c            | 12 ++++++++++++
 2 files changed, 13 insertions(+)

diff --git a/include/uapi/linux/neighbour.h b/include/uapi/linux/neighbour.h
index 3199d28980b3..703089c91b04 100644
--- a/include/uapi/linux/neighbour.h
+++ b/include/uapi/linux/neighbour.h
@@ -27,6 +27,7 @@ enum {
 	NDA_MASTER,
 	NDA_LINK_NETNSID,
 	NDA_SRC_VNI,
+	NDA_VPLS_WIRE,
 	__NDA_MAX
 };
 
diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
index 0751fcb89699..ffbaff914d55 100644
--- a/net/bridge/br_fdb.c
+++ b/net/bridge/br_fdb.c
@@ -670,6 +670,18 @@ static int fdb_fill_info(struct sk_buff *skb, const struct net_bridge *br,
 
 	if (fdb->vlan_id && nla_put(skb, NDA_VLAN, sizeof(u16), &fdb->vlan_id))
 		goto nla_put_failure;
+	if (fdb->md_dst) {
+		struct metadata_dst *md_dst;
+		md_dst = (struct metadata_dst *)fdb->md_dst;
+		/* ensured in br_fdb_update */
+		BUG_ON(!(md_dst->dst.flags & DST_METADATA));
+
+		if (md_dst->type == METADATA_VPLS) {
+			unsigned wire = md_dst->u.vpls_info.pw_label;
+			if (nla_put_u32(skb, NDA_VPLS_WIRE, wire))
+				goto nla_put_failure;
+		}
+	}
 
 	nlmsg_end(skb, nlh);
 	return 0;
-- 
2.13.0
