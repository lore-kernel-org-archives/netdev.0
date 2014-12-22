From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH 5/5] genetlink: pass multicast bind/unbind to families
Date: Mon, 22 Dec 2014 18:56:39 +0100
Message-ID: <1419270999-22165-6-git-send-email-johannes@sipsolutions.net>
References: <1419270999-22165-1-git-send-email-johannes@sipsolutions.net>
Cc: Johannes Berg <johannes.berg@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:35038 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755587AbaLVR4r (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Dec 2014 12:56:47 -0500
In-Reply-To: <1419270999-22165-1-git-send-email-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes.berg@intel.com>

In order to make the newly fixed multicast bind/unbind
functionality in generic netlink, pass them down to the
appropriate family.

Signed-off-by: Johannes Berg <johannes.berg@intel.com>
---
 include/net/genetlink.h |  5 +++++
 net/netlink/genetlink.c | 51 +++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 56 insertions(+)

diff --git a/include/net/genetlink.h b/include/net/genetlink.h
index 38620da4aa7a..3ed31e5a445b 100644
--- a/include/net/genetlink.h
+++ b/include/net/genetlink.h
@@ -31,6 +31,9 @@ struct genl_info;
  *	do additional, common, filtering and return an error
  * @post_doit: called after an operation's doit callback, it may
  *	undo operations done by pre_doit, for example release locks
+ * @mcast_bind: a socket bound to the given multicast group (which
+ *	is given as the offset into the groups array)
+ * @mcast_unbind: a socket was unbound from the given multicast group
  * @attrbuf: buffer to store parsed attributes
  * @family_list: family list
  * @mcgrps: multicast groups used by this family (private)
@@ -53,6 +56,8 @@ struct genl_family {
 	void			(*post_doit)(const struct genl_ops *ops,
 					     struct sk_buff *skb,
 					     struct genl_info *info);
+	int			(*mcast_bind)(int group);
+	void			(*mcast_unbind)(int group);
 	struct nlattr **	attrbuf;	/* private */
 	const struct genl_ops *	ops;		/* private */
 	const struct genl_multicast_group *mcgrps; /* private */
diff --git a/net/netlink/genetlink.c b/net/netlink/genetlink.c
index 76393f2f4b22..960d3a41682a 100644
--- a/net/netlink/genetlink.c
+++ b/net/netlink/genetlink.c
@@ -983,11 +983,62 @@ static struct genl_multicast_group genl_ctrl_groups[] = {
 	{ .name = "notify", },
 };
 
+static int genl_bind(int group)
+{
+	int i, err;
+	bool found = false;
+
+	down_read(&cb_lock);
+	for (i = 0; i < GENL_FAM_TAB_SIZE; i++) {
+		struct genl_family *f;
+
+		list_for_each_entry(f, genl_family_chain(i), family_list) {
+			if (group >= f->mcgrp_offset &&
+			    group < f->mcgrp_offset + f->n_mcgrps) {
+				err = f->mcast_bind(group - f->mcgrp_offset);
+				found = true;
+				break;
+			}
+		}
+	}
+	up_read(&cb_lock);
+
+	if (WARN_ON(!found))
+		err = 0;
+
+	return err;
+}
+
+static void genl_unbind(int group)
+{
+	int i;
+	bool found = false;
+
+	down_read(&cb_lock);
+	for (i = 0; i < GENL_FAM_TAB_SIZE; i++) {
+		struct genl_family *f;
+
+		list_for_each_entry(f, genl_family_chain(i), family_list) {
+			if (group >= f->mcgrp_offset &&
+			    group < f->mcgrp_offset + f->n_mcgrps) {
+				f->mcast_unbind(group - f->mcgrp_offset);
+				found = true;
+				break;
+			}
+		}
+	}
+	up_read(&cb_lock);
+
+	WARN_ON(!found);
+}
+
 static int __net_init genl_pernet_init(struct net *net)
 {
 	struct netlink_kernel_cfg cfg = {
 		.input		= genl_rcv,
 		.flags		= NL_CFG_F_NONROOT_RECV,
+		.bind		= genl_bind,
+		.unbind		= genl_unbind,
 	};
 
 	/* we'll bump the group number right afterwards */
-- 
2.1.1
