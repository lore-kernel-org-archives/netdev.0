From: Johannes Berg <johannes@sipsolutions.net>
Subject: [RFC 2/3] genetlink: pass extended error report down
Date: Fri,  7 Apr 2017 20:26:19 +0200
Message-ID: <20170407182620.6438-3-johannes@sipsolutions.net>
References: <20170407182620.6438-1-johannes@sipsolutions.net>
Cc: pablo@netfilter.org, Johannes Berg <johannes.berg@intel.com>
To: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:51216 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756021AbdDGS01 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 7 Apr 2017 14:26:27 -0400
In-Reply-To: <20170407182620.6438-1-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes.berg@intel.com>

Signed-off-by: Johannes Berg <johannes.berg@intel.com>
---
 include/net/genetlink.h | 27 +++++++++++++++++++++++++++
 net/netlink/genetlink.c |  6 ++++--
 2 files changed, 31 insertions(+), 2 deletions(-)

diff --git a/include/net/genetlink.h b/include/net/genetlink.h
index a34275be3600..67ad2326cfa6 100644
--- a/include/net/genetlink.h
+++ b/include/net/genetlink.h
@@ -84,6 +84,7 @@ struct nlattr **genl_family_attrbuf(const struct genl_family *family);
  * @attrs: netlink attributes
  * @_net: network namespace
  * @user_ptr: user pointers
+ * @exterr: extended error report struct
  */
 struct genl_info {
 	u32			snd_seq;
@@ -94,6 +95,7 @@ struct genl_info {
 	struct nlattr **	attrs;
 	possible_net_t		_net;
 	void *			user_ptr[2];
+	struct netlink_ext_err *exterr;
 };
 
 static inline struct net *genl_info_net(struct genl_info *info)
@@ -106,6 +108,31 @@ static inline void genl_info_net_set(struct genl_info *info, struct net *net)
 	write_pnet(&info->_net, net);
 }
 
+static inline int genl_err_str(struct genl_info *info, int err,
+			       const char *msg)
+{
+	info->exterr->msg = msg;
+
+	return err;
+}
+
+static inline int genl_err_attr(struct genl_info *info, int err,
+				u16 attr)
+{
+	info->exterr->attr = attr;
+
+	return err;
+}
+
+static inline int genl_err_str_attr(struct genl_info *info, int err,
+				    const char *msg, u16 attr)
+{
+	info->exterr->msg = msg;
+	info->exterr->attr = attr;
+
+	return err;
+}
+
 /**
  * struct genl_ops - generic netlink operations
  * @cmd: command identifier
diff --git a/net/netlink/genetlink.c b/net/netlink/genetlink.c
index 48f21dc467a7..39182d6a990e 100644
--- a/net/netlink/genetlink.c
+++ b/net/netlink/genetlink.c
@@ -497,7 +497,8 @@ static int genl_lock_done(struct netlink_callback *cb)
 
 static int genl_family_rcv_msg(const struct genl_family *family,
 			       struct sk_buff *skb,
-			       struct nlmsghdr *nlh)
+			       struct nlmsghdr *nlh,
+			       struct netlink_ext_err *exterr)
 {
 	const struct genl_ops *ops;
 	struct net *net = sock_net(skb->sk);
@@ -584,6 +585,7 @@ static int genl_family_rcv_msg(const struct genl_family *family,
 	info.genlhdr = nlmsg_data(nlh);
 	info.userhdr = nlmsg_data(nlh) + GENL_HDRLEN;
 	info.attrs = attrbuf;
+	info.exterr = exterr;
 	genl_info_net_set(&info, net);
 	memset(&info.user_ptr, 0, sizeof(info.user_ptr));
 
@@ -618,7 +620,7 @@ static int genl_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh,
 	if (!family->parallel_ops)
 		genl_lock();
 
-	err = genl_family_rcv_msg(family, skb, nlh);
+	err = genl_family_rcv_msg(family, skb, nlh, exterr);
 
 	if (!family->parallel_ops)
 		genl_unlock();
-- 
2.11.0
