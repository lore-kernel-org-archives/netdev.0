From: jamal <hadi@cyberus.ca>
Subject: [PATCH 2/3] xfrm: Flushing empty SAD generates false events
Date: Fri, 19 Feb 2010 07:00:41 -0500
Message-ID: <1266580842-10608-3-git-send-email-hadi@cyberus.ca>
References: <flush-fix-xfrm>
 <1266580842-10608-1-git-send-email-hadi@cyberus.ca>
 <1266580842-10608-2-git-send-email-hadi@cyberus.ca>
Cc: netdev@vger.kernel.org, Jamal Hadi Salim <hadi@cyberus.ca>
To: davem@davemloft.net, adobriyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.27]:23182 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751152Ab0BSMA7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Feb 2010 07:00:59 -0500
Received: by qw-out-2122.google.com with SMTP id 8so171666qwh.37
        for <netdev@vger.kernel.org>; Fri, 19 Feb 2010 04:00:58 -0800 (PST)
In-Reply-To: <1266580842-10608-2-git-send-email-hadi@cyberus.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <hadi@cyberus.ca>

To see the effect make sure you have an empty SAD.
On window1 "ip xfrm mon" and on window2 issue "ip xfrm state flush"
You get prompt back in window2 and you see the flush event on window1.
With this fix, you still get prompt on window1 but no event on window2.

Thanks to Alexey Dobriyan for finding a bug in earlier version
when using pfkey to do the flushing.

Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>
---
 net/key/af_key.c      |    5 ++++-
 net/xfrm/xfrm_state.c |    8 ++++++--
 net/xfrm/xfrm_user.c  |    5 ++++-
 3 files changed, 14 insertions(+), 4 deletions(-)

diff --git a/net/key/af_key.c b/net/key/af_key.c
index b3faede..c269ce6 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -1768,8 +1768,11 @@ static int pfkey_flush(struct sock *sk, struct sk_buff *skb, struct sadb_msg *hd
 	audit_info.secid = 0;
 	err = xfrm_state_flush(net, proto, &audit_info);
 	err2 = unicast_flush_resp(sk, hdr);
-	if (err || err2)
+	if (err || err2) {
+		if (err == -ESRCH) /* empty table - go quietly */
+			err = 0;
 		return err ? err : err2;
+	}
 
 	c.data.proto = proto;
 	c.seq = hdr->sadb_msg_seq;
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index c9d6a5f..9fa3322 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -603,13 +603,14 @@ xfrm_state_flush_secctx_check(struct net *net, u8 proto, struct xfrm_audit *audi
 
 int xfrm_state_flush(struct net *net, u8 proto, struct xfrm_audit *audit_info)
 {
-	int i, err = 0;
+	int i, err = 0, cnt = 0;
 
 	spin_lock_bh(&xfrm_state_lock);
 	err = xfrm_state_flush_secctx_check(net, proto, audit_info);
 	if (err)
 		goto out;
 
+	err = -ESRCH;
 	for (i = 0; i <= net->xfrm.state_hmask; i++) {
 		struct hlist_node *entry;
 		struct xfrm_state *x;
@@ -626,13 +627,16 @@ restart:
 							audit_info->sessionid,
 							audit_info->secid);
 				xfrm_state_put(x);
+				if (!err)
+					cnt++;
 
 				spin_lock_bh(&xfrm_state_lock);
 				goto restart;
 			}
 		}
 	}
-	err = 0;
+	if (cnt)
+		err = 0;
 
 out:
 	spin_unlock_bh(&xfrm_state_lock);
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 943c871..cd94a9d 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -1524,8 +1524,11 @@ static int xfrm_flush_sa(struct sk_buff *skb, struct nlmsghdr *nlh,
 	audit_info.sessionid = NETLINK_CB(skb).sessionid;
 	audit_info.secid = NETLINK_CB(skb).sid;
 	err = xfrm_state_flush(net, p->proto, &audit_info);
-	if (err)
+	if (err) {
+		if (err == -ESRCH) /* empty table */
+			return 0;
 		return err;
+	}
 	c.data.proto = p->proto;
 	c.event = nlh->nlmsg_type;
 	c.seq = nlh->nlmsg_seq;
-- 
1.6.0.4

