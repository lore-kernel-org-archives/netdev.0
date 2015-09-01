From: Ahmed Amamou <ahmed@gandi.net>
Subject: [PATCH RFC v2 09/21] net: rbridge: add elected dtroot
Date: Tue,  1 Sep 2015 17:43:04 +0200
Message-ID: <1441122196-11662-10-git-send-email-ahmed@gandi.net>
References: <1441122196-11662-1-git-send-email-ahmed@gandi.net>
Cc: William Dauchy <william@gandi.net>, Ahmed Amamou <ahmed@gandi.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail4.gandi.net ([217.70.183.210]:56207 "EHLO gandi.net"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752709AbbIAPxl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Sep 2015 11:53:41 -0400
In-Reply-To: <1441122196-11662-1-git-send-email-ahmed@gandi.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ahmed Amamou <ahmed@gandi.net>
---
 net/bridge/rbr.c           | 14 ++++++++++++++
 net/bridge/rbr_private.h   |  2 ++
 net/bridge/rbr_rtnetlink.c |  6 ++++++
 3 files changed, 22 insertions(+)

diff --git a/net/bridge/rbr.c b/net/bridge/rbr.c
index c554743..31e72ef 100644
--- a/net/bridge/rbr.c
+++ b/net/bridge/rbr.c
@@ -69,3 +69,17 @@ void br_trill_set_enabled(struct net_bridge *br, unsigned long val)
 			br_trill_stop(br);
 	}
 }
+
+int set_treeroot(struct rbr *rbr, uint16_t treeroot)
+{
+	if (unlikely(!VALID_NICK(treeroot))) {
+		pr_warn_ratelimited
+			("rbr_set_treeroot: given tree root not valid\n");
+		goto set_tree_root_fail;
+	}
+	if (rbr->treeroot != treeroot)
+		rbr->treeroot = treeroot;
+	return 0;
+ set_tree_root_fail:
+	return -ENOENT;
+}
diff --git a/net/bridge/rbr_private.h b/net/bridge/rbr_private.h
index 8d9fb4c..9166a8b 100644
--- a/net/bridge/rbr_private.h
+++ b/net/bridge/rbr_private.h
@@ -44,6 +44,8 @@ struct rbr {
 	struct net_bridge *br;	/* back pointer */
 };
 
+int set_treeroot(struct rbr *rbr, uint16_t treeroot);
+
 /* Access the adjacency nick list at the end of rbr_nickinfo */
 #define	RBR_NI_ADJNICKSPTR(v) ((u16 *)((struct rbr_nickinfo *)(v) + 1))
 #define	RBR_NI_ADJNICK(v, n) (RBR_NI_ADJNICKSPTR(v)[(n)])
diff --git a/net/bridge/rbr_rtnetlink.c b/net/bridge/rbr_rtnetlink.c
index d75d45c..5b6dab4 100644
--- a/net/bridge/rbr_rtnetlink.c
+++ b/net/bridge/rbr_rtnetlink.c
@@ -36,6 +36,12 @@ int rbr_set_data(struct net_device *dev, struct nlattr *tb[],
 			br->rbr->nick = htons(nick);
 		spin_unlock_bh(&br->lock);
 	}
+	if (data[IFLA_TRILL_ROOT]) {
+		if (!br->rbr)
+			return -EINVAL;
+		nick = nla_get_u16(data[IFLA_TRILL_ROOT]);
+		err = set_treeroot(br->rbr, htons(nick));
+	}
 
 	return 0;
 fail:
-- 
2.1.4
