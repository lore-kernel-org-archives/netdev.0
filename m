From: jamal <hadi@cyberus.ca>
Subject: [PATCH 3/3] xfrm: Flushing empty SPD generates false events
Date: Fri, 19 Feb 2010 07:00:42 -0500
Message-ID: <1266580842-10608-4-git-send-email-hadi@cyberus.ca>
References: <flush-fix-xfrm>
 <1266580842-10608-1-git-send-email-hadi@cyberus.ca>
 <1266580842-10608-2-git-send-email-hadi@cyberus.ca>
 <1266580842-10608-3-git-send-email-hadi@cyberus.ca>
Cc: netdev@vger.kernel.org, Jamal Hadi Salim <hadi@cyberus.ca>
To: davem@davemloft.net, adobriyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f179.google.com ([209.85.221.179]:59575 "EHLO
	mail-qy0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751045Ab0BSMBB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Feb 2010 07:01:01 -0500
Received: by qyk9 with SMTP id 9so5661015qyk.22
        for <netdev@vger.kernel.org>; Fri, 19 Feb 2010 04:01:00 -0800 (PST)
In-Reply-To: <1266580842-10608-3-git-send-email-hadi@cyberus.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <hadi@cyberus.ca>

To see the effect make sure you have an empty SPD.
On window1 "ip xfrm mon" and on window2 issue "ip xfrm policy flush"
You get prompt back in window2 and you see the flush event on window1.
With this fix, you still get prompt on window1 but no event on window2.

Thanks to Alexey Dobriyan for finding a bug in earlier version
when using pfkey to do the flushing.

Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>
---
 net/key/af_key.c       |    7 +++++--
 net/xfrm/xfrm_policy.c |   13 ++++++++++---
 net/xfrm/xfrm_user.c   |    6 +++++-
 3 files changed, 20 insertions(+), 6 deletions(-)

diff --git a/net/key/af_key.c b/net/key/af_key.c
index c269ce6..a20d2fa 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -2735,8 +2735,11 @@ static int pfkey_spdflush(struct sock *sk, struct sk_buff *skb, struct sadb_msg
 	audit_info.secid = 0;
 	err = xfrm_policy_flush(net, XFRM_POLICY_TYPE_MAIN, &audit_info);
 	err2 = unicast_flush_resp(sk, hdr);
-	if (err || err2)
-		return err ? err : err2;
+	if (err || err2) {
+		if (err == -ESRCH) /* empty table - old silent behavior */
+			return 0;
+		return err;
+	}
 
 	c.data.type = XFRM_POLICY_TYPE_MAIN;
 	c.event = XFRM_MSG_FLUSHPOLICY;
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 4368e7b..d6eb16d 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -771,7 +771,8 @@ xfrm_policy_flush_secctx_check(struct net *net, u8 type, struct xfrm_audit *audi
 
 int xfrm_policy_flush(struct net *net, u8 type, struct xfrm_audit *audit_info)
 {
-	int dir, err = 0;
+	int dir, err = 0, cnt = 0;
+	struct xfrm_policy *dp;
 
 	write_lock_bh(&xfrm_policy_lock);
 
@@ -789,8 +790,10 @@ int xfrm_policy_flush(struct net *net, u8 type, struct xfrm_audit *audit_info)
 				     &net->xfrm.policy_inexact[dir], bydst) {
 			if (pol->type != type)
 				continue;
-			__xfrm_policy_unlink(pol, dir);
+			dp = __xfrm_policy_unlink(pol, dir);
 			write_unlock_bh(&xfrm_policy_lock);
+			if (dp)
+				cnt++;
 
 			xfrm_audit_policy_delete(pol, 1, audit_info->loginuid,
 						 audit_info->sessionid,
@@ -809,8 +812,10 @@ int xfrm_policy_flush(struct net *net, u8 type, struct xfrm_audit *audit_info)
 					     bydst) {
 				if (pol->type != type)
 					continue;
-				__xfrm_policy_unlink(pol, dir);
+				dp = __xfrm_policy_unlink(pol, dir);
 				write_unlock_bh(&xfrm_policy_lock);
+				if (dp)
+					cnt++;
 
 				xfrm_audit_policy_delete(pol, 1,
 							 audit_info->loginuid,
@@ -824,6 +829,8 @@ int xfrm_policy_flush(struct net *net, u8 type, struct xfrm_audit *audit_info)
 		}
 
 	}
+	if (!cnt)
+		err = -ESRCH;
 	atomic_inc(&flow_cache_genid);
 out:
 	write_unlock_bh(&xfrm_policy_lock);
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index cd94a9d..ee04e6b 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -1679,8 +1679,12 @@ static int xfrm_flush_policy(struct sk_buff *skb, struct nlmsghdr *nlh,
 	audit_info.sessionid = NETLINK_CB(skb).sessionid;
 	audit_info.secid = NETLINK_CB(skb).sid;
 	err = xfrm_policy_flush(net, type, &audit_info);
-	if (err)
+	if (err) {
+		if (err == -ESRCH) /* empty table */
+			return 0;
 		return err;
+	}
+
 	c.data.type = type;
 	c.event = nlh->nlmsg_type;
 	c.seq = nlh->nlmsg_seq;
-- 
1.6.0.4

