From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH v3 1/2] genl: Fix genl dumpit() locking.
Date: Fri, 23 Aug 2013 12:44:55 -0700
Message-ID: <1377287095-13245-1-git-send-email-pshelar@nicira.com>
Cc: Pravin B Shelar <pshelar@nicira.com>,
	Jesse Gross <jesse@nicira.com>,
	Johannes Berg <johannes.berg@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog102.obsmtp.com ([74.125.149.69]:58930 "HELO
	na3sys009aog102.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754170Ab3HWTpB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Aug 2013 15:45:01 -0400
Received: by mail-pa0-f44.google.com with SMTP id fz6so1061106pac.3
        for <netdev@vger.kernel.org>; Fri, 23 Aug 2013 12:45:01 -0700 (PDT)
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
v2-v3:
coding style fix.
v1-v2:
No change.
---
 net/netlink/genetlink.c |   51 ++++++++++++++++++++++++++++++++++++++++++----
 1 files changed, 46 insertions(+), 5 deletions(-)

diff --git a/net/netlink/genetlink.c b/net/netlink/genetlink.c
index f85f8a2..f09d387 100644
--- a/net/netlink/genetlink.c
+++ b/net/netlink/genetlink.c
@@ -544,6 +544,30 @@ void *genlmsg_put(struct sk_buff *skb, u32 portid, u32 seq,
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
+	int rc = 0;
+
+	if (ops->done) {
+		genl_lock();
+		rc = ops->done(cb);
+		genl_unlock();
+	}
+	return rc;
+}
+
 static int genl_family_rcv_msg(struct genl_family *family,
 			       struct sk_buff *skb,
 			       struct nlmsghdr *nlh)
@@ -572,15 +596,32 @@ static int genl_family_rcv_msg(struct genl_family *family,
 		return -EPERM;
 
 	if ((nlh->nlmsg_flags & NLM_F_DUMP) == NLM_F_DUMP) {
-		struct netlink_dump_control c = {
-			.dump = ops->dumpit,
-			.done = ops->done,
-		};
+		int rc;
 
 		if (ops->dumpit == NULL)
 			return -EOPNOTSUPP;
 
-		return netlink_dump_start(net->genl_sock, skb, nlh, &c);
+		if (!family->parallel_ops) {
+			struct netlink_dump_control c = {
+				.data = ops,
+				.dump = genl_lock_dumpit,
+				.done = genl_lock_done,
+			};
+
+			genl_unlock();
+			rc = netlink_dump_start(net->genl_sock, skb, nlh, &c);
+			genl_lock();
+
+		} else {
+			struct netlink_dump_control c = {
+				.dump = ops->dumpit,
+				.done = ops->done,
+			};
+
+			rc = netlink_dump_start(net->genl_sock, skb, nlh, &c);
+		}
+
+		return rc;
 	}
 
 	if (ops->doit == NULL)
-- 
1.7.1
