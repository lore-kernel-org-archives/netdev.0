From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH 1/2] genl: Fix genl dumpit() locking.
Date: Wed, 21 Aug 2013 20:58:02 -0700
Message-ID: <1377143882-20717-1-git-send-email-pshelar@nicira.com>
Cc: Pravin B Shelar <pshelar@nicira.com>,
	Jesse Gross <jesse@nicira.com>,
	Johannes Berg <johannes.berg@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog125.obsmtp.com ([74.125.149.153]:57462 "HELO
	na3sys009aog125.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752790Ab3HVD6K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Aug 2013 23:58:10 -0400
Received: by mail-pa0-f51.google.com with SMTP id lf1so911250pab.24
        for <netdev@vger.kernel.org>; Wed, 21 Aug 2013 20:58:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In case of genl-family with parallel ops off, dumpif() callback
is expected to run under genl_lock, But commit def3117493eafd9df
(genl: Allow concurrent genl callbacks.) changed this behaviour
where only first dumpit() op was called under genl-lock.
For subsequent dump, only nlk->cb_lock was taken.
Following patch fixes it by defining locked dumpit() and done()
callback which takes care of genl-locking.

CC: Jesse Gross <jesse@nicira.com>
CC: Johannes Berg <johannes.berg@intel.com>
Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 net/netlink/genetlink.c |   46 +++++++++++++++++++++++++++++++++++++++++-----
 1 files changed, 41 insertions(+), 5 deletions(-)

diff --git a/net/netlink/genetlink.c b/net/netlink/genetlink.c
index f85f8a2..3669039 100644
--- a/net/netlink/genetlink.c
+++ b/net/netlink/genetlink.c
@@ -544,6 +544,28 @@ void *genlmsg_put(struct sk_buff *skb, u32 portid, u32 seq,
 }
 EXPORT_SYMBOL(genlmsg_put);
 
+static int genl_lock_dumpit(struct sk_buff *skb, struct netlink_callback *cb)
+{
+	struct genl_ops *ops = cb->data;
+	int rc;
+
+	genl_lock();
+	rc = ops->dumpit(skb, cb);
+	genl_unlock();
+	return rc;
+}
+
+static int genl_lock_done(struct netlink_callback *cb)
+{
+	struct genl_ops *ops = cb->data;
+	int rc;
+
+	genl_lock();
+	rc = ops->done(cb);
+	genl_unlock();
+	return rc;
+}
+
 static int genl_family_rcv_msg(struct genl_family *family,
 			       struct sk_buff *skb,
 			       struct nlmsghdr *nlh)
@@ -572,15 +594,29 @@ static int genl_family_rcv_msg(struct genl_family *family,
 		return -EPERM;
 
 	if ((nlh->nlmsg_flags & NLM_F_DUMP) == NLM_F_DUMP) {
-		struct netlink_dump_control c = {
-			.dump = ops->dumpit,
-			.done = ops->done,
-		};
+		struct netlink_dump_control c;
+		int rc;
 
 		if (ops->dumpit == NULL)
 			return -EOPNOTSUPP;
 
-		return netlink_dump_start(net->genl_sock, skb, nlh, &c);
+		memset(&c, 0, sizeof(c));
+		if (!family->parallel_ops) {
+			genl_unlock();
+			c.data = ops;
+			c.dump = genl_lock_dumpit;
+			if (ops->done)
+				c.done = genl_lock_done;
+		} else {
+			c.dump = ops->dumpit;
+			c.done = ops->done;
+		}
+
+		rc = netlink_dump_start(net->genl_sock, skb, nlh, &c);
+		if (!family->parallel_ops)
+			genl_lock();
+		return rc;
+
 	}
 
 	if (ops->doit == NULL)
-- 
1.7.1
