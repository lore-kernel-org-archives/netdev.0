From: jamal <hadi@cyberus.ca>
Subject: [PATCH]xfrm: Flushing empty SPD generates false events
Date: Thu, 11 Feb 2010 05:53:13 -0500
Message-ID: <1265885593.3988.6.camel@bigi>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-NBkn3IT5jPpF1y8l1tj9"
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.24]:49965 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752223Ab0BKKxR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Feb 2010 05:53:17 -0500
Received: by qw-out-2122.google.com with SMTP id 9so214632qwb.37
        for <netdev@vger.kernel.org>; Thu, 11 Feb 2010 02:53:16 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-NBkn3IT5jPpF1y8l1tj9
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Observed similar behavior on SPD as previouly seen on SAD flushing..
This fixes it.

cheers,
jamal

--=-NBkn3IT5jPpF1y8l1tj9
Content-Disposition: attachment; filename="SPD-flush-ev"
Content-Type: text/plain; name="SPD-flush-ev"; charset="UTF-8"
Content-Transfer-Encoding: 7bit

commit 428b20432dc31bc2e01a94cd451cf5a2c00d2bf4
Author: Jamal Hadi Salim <hadi@cyberus.ca>
Date:   Thu Feb 11 05:49:38 2010 -0500

    xfrm: Flushing empty SPD generates false events
    
    To see the effect make sure you have an empty SPD.
    On window1 "ip xfrm mon" and on window2 issue "ip xfrm policy flush"
    You get prompt back in window1 and you see the flush event on window2.
    With this fix, you still get prompt on window1 but no event on window2.
    
    Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>

diff --git a/net/key/af_key.c b/net/key/af_key.c
index 0f53e60..978f78b 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -2713,7 +2713,7 @@ static int pfkey_spdflush(struct sock *sk, struct sk_buff *skb, struct sadb_msg
 	audit_info.secid = 0;
 	err = xfrm_policy_flush(net, XFRM_POLICY_TYPE_MAIN, &audit_info);
 	if (err)
-		return err;
+		return 0;
 	c.data.type = XFRM_POLICY_TYPE_MAIN;
 	c.event = XFRM_MSG_FLUSHPOLICY;
 	c.pid = hdr->sadb_msg_pid;
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 0ecb16a..eb870fc 100644
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
index 7c87004..b0fb7d3 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -1677,7 +1677,7 @@ static int xfrm_flush_policy(struct sk_buff *skb, struct nlmsghdr *nlh,
 	audit_info.secid = NETLINK_CB(skb).sid;
 	err = xfrm_policy_flush(net, type, &audit_info);
 	if (err)
-		return err;
+		return 0;
 	c.data.type = type;
 	c.event = nlh->nlmsg_type;
 	c.seq = nlh->nlmsg_seq;

--=-NBkn3IT5jPpF1y8l1tj9--

