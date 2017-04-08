From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH 2/5] genetlink: pass extended ACK report down
Date: Sat,  8 Apr 2017 19:48:57 +0200
Message-ID: <20170408174900.12820-3-johannes@sipsolutions.net>
References: <20170408174900.12820-1-johannes@sipsolutions.net>
Cc: pablo@netfilter.org, Jamal Hadi Salim <jhs@mojatatu.com>,
        Jiri Benc <jbenc@redhat.com>,
        David Ahern <dsa@cumulusnetworks.com>, jiri@resnulli.us,
        Johannes Berg <johannes.berg@intel.com>
To: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:38124 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751863AbdDHRtI (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 8 Apr 2017 13:49:08 -0400
In-Reply-To: <20170408174900.12820-1-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes.berg@intel.com>

Pass the extended ACK reporting struct down from
generic netlink to the families, using the existing
struct genl_info for simplicity.

Also add support to set the extended ACK information
from generic netlink users.

Signed-off-by: Johannes Berg <johannes.berg@intel.com>
---
 include/net/genetlink.h | 20 ++++++++++++++++++++
 net/netlink/genetlink.c |  6 ++++--
 2 files changed, 24 insertions(+), 2 deletions(-)

diff --git a/include/net/genetlink.h b/include/net/genetlink.h
index a34275be3600..b81a4979e1db 100644
--- a/include/net/genetlink.h
+++ b/include/net/genetlink.h
@@ -84,6 +84,7 @@ struct nlattr **genl_family_attrbuf(const struct genl_family *family);
  * @attrs: netlink attributes
  * @_net: network namespace
  * @user_ptr: user pointers
+ * @extack: extended ACK report struct
  */
 struct genl_info {
 	u32			snd_seq;
@@ -94,6 +95,7 @@ struct genl_info {
 	struct nlattr **	attrs;
 	possible_net_t		_net;
 	void *			user_ptr[2];
+	struct netlink_ext_ack *extack;
 };
 
 static inline struct net *genl_info_net(struct genl_info *info)
@@ -106,6 +108,24 @@ static inline void genl_info_net_set(struct genl_info *info, struct net *net)
 	write_pnet(&info->_net, net);
 }
 
+#define GENL_SET_ERR_MSG(info, msg) NL_SET_ERR_MSG((info)->extack, msg)
+
+static inline int genl_err_attr(struct genl_info *info, int err,
+				struct nlattr *attr)
+{
+	info->extack->bad_attr = attr;
+
+	return err;
+}
+
+static inline int genl_err_attr_missing(struct genl_info *info, int err,
+					u16 attr)
+{
+	info->extack->missing_attr = attr;
+
+	return err;
+}
+
 /**
  * struct genl_ops - generic netlink operations
  * @cmd: command identifier
diff --git a/net/netlink/genetlink.c b/net/netlink/genetlink.c
index 57b2e3648bc0..4b598a5999a2 100644
--- a/net/netlink/genetlink.c
+++ b/net/netlink/genetlink.c
@@ -497,7 +497,8 @@ static int genl_lock_done(struct netlink_callback *cb)
 
 static int genl_family_rcv_msg(const struct genl_family *family,
 			       struct sk_buff *skb,
-			       struct nlmsghdr *nlh)
+			       struct nlmsghdr *nlh,
+			       struct netlink_ext_ack *extack)
 {
 	const struct genl_ops *ops;
 	struct net *net = sock_net(skb->sk);
@@ -584,6 +585,7 @@ static int genl_family_rcv_msg(const struct genl_family *family,
 	info.genlhdr = nlmsg_data(nlh);
 	info.userhdr = nlmsg_data(nlh) + GENL_HDRLEN;
 	info.attrs = attrbuf;
+	info.extack = extack;
 	genl_info_net_set(&info, net);
 	memset(&info.user_ptr, 0, sizeof(info.user_ptr));
 
@@ -618,7 +620,7 @@ static int genl_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh,
 	if (!family->parallel_ops)
 		genl_lock();
 
-	err = genl_family_rcv_msg(family, skb, nlh);
+	err = genl_family_rcv_msg(family, skb, nlh, extack);
 
 	if (!family->parallel_ops)
 		genl_unlock();
-- 
2.11.0
