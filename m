From: Ahmed Amamou <ahmed@gandi.net>
Subject: [PATCH RFC v2 12/21] net: rbridge: update node table
Date: Tue,  1 Sep 2015 17:43:07 +0200
Message-ID: <1441122196-11662-13-git-send-email-ahmed@gandi.net>
References: <1441122196-11662-1-git-send-email-ahmed@gandi.net>
Cc: William Dauchy <william@gandi.net>, Ahmed Amamou <ahmed@gandi.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail4.gandi.net ([217.70.183.210]:56617 "EHLO gandi.net"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752900AbbIAPxn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Sep 2015 11:53:43 -0400
In-Reply-To: <1441122196-11662-1-git-send-email-ahmed@gandi.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ahmed Amamou <ahmed@gandi.net>
---
 net/bridge/rbr_rtnetlink.c | 43 +++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 43 insertions(+)

diff --git a/net/bridge/rbr_rtnetlink.c b/net/bridge/rbr_rtnetlink.c
index 5b6dab4..23fd0d7 100644
--- a/net/bridge/rbr_rtnetlink.c
+++ b/net/bridge/rbr_rtnetlink.c
@@ -42,7 +42,50 @@ int rbr_set_data(struct net_device *dev, struct nlattr *tb[],
 		nick = nla_get_u16(data[IFLA_TRILL_ROOT]);
 		err = set_treeroot(br->rbr, htons(nick));
 	}
+	if (data[IFLA_TRILL_INFO]) {
+		struct rbr_nickinfo *rbr_ni;
+		struct rbr_node *old;
+		size_t old_size = 0;
+		size_t size = 0;
+		struct rbr *rbr;
 
+		if (!br->rbr)
+			return -EINVAL;
+
+		rbr = br->rbr;
+		size = nla_len(data[IFLA_TRILL_INFO]);
+		rbr_ni = kzalloc(size, GFP_KERNEL);
+		if (!rbr_ni)
+			goto fail;
+		memcpy(rbr_ni, nla_data(data[IFLA_TRILL_INFO]), size);
+		nick = rbr_ni->nick;
+		old = br->rbr->rbr_nodes[nick];
+		if (old)
+			old_size = RBR_NI_TOTALSIZE(old->rbr_ni);
+		/* replace old node by a new one only if nickname
+		 * information have changed
+		 */
+		if (!old || old_size != size ||
+		    memcmp(old->rbr_ni, rbr_ni, size)) {
+			struct rbr_node *new;
+
+			new = kzalloc(sizeof(*old), GFP_KERNEL);
+			if (!new) {
+				kfree(rbr_ni);
+				goto fail;
+			}
+			atomic_set(&new->refs, 1);
+			new->rbr_ni = rbr_ni;
+			/* Avoid deleting node while it is been used for
+			 * routing
+			 */
+			rcu_assign_pointer(rbr->rbr_nodes[nick], new);
+			if (old)
+				rbr_node_put(old);
+		} else {
+			kfree(rbr_ni);
+		}
+	}
 	return 0;
 fail:
 	pr_warn("rbr_set_data FAILED\n");
-- 
2.1.4
