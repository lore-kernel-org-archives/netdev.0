From: David Miller <davem@davemloft.net>
Subject: Re: [BUG] 2.6.20 Oopses in xfrm_audit_log
Date: Mon, 12 Feb 2007 14:49:38 -0800 (PST)
Message-ID: <20070212.144938.36664406.davem@davemloft.net>
References: <20070212142138.32983793.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ce@ruault.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56402
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1030389AbXBLWtl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Feb 2007 17:49:41 -0500
In-Reply-To: <20070212142138.32983793.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Andrew, we're already discussing a fix for this in another
thread today:

commit 13fcfbb0675bf87da694f55dec11cada489a205c
Author: David S. Miller <davem@sunset.davemloft.net>
Date:   Mon Feb 12 13:53:54 2007 -0800

    [XFRM]: Fix OOPSes in xfrm_audit_log().
    
    Make sure that this function is called correctly, and
    add BUG() checking to ensure the arguments are sane.
    
    Based upon a patch by Joy Latten.
    
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/net/key/af_key.c b/net/key/af_key.c
index f3a026f..1c58204 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -2297,16 +2297,17 @@ static int pfkey_spddelete(struct sock *sk, struct sk_buff *skb, struct sadb_msg
 				   &sel, tmp.security, 1);
 	security_xfrm_policy_free(&tmp);
 
-	xfrm_audit_log(audit_get_loginuid(current->audit_context), 0,
-		       AUDIT_MAC_IPSEC_DELSPD, (xp) ? 1 : 0, xp, NULL);
-
 	if (xp == NULL)
 		return -ENOENT;
 
-	err = 0;
+	err = security_xfrm_policy_delete(xp);
 
-	if ((err = security_xfrm_policy_delete(xp)))
+	xfrm_audit_log(audit_get_loginuid(current->audit_context), 0,
+		       AUDIT_MAC_IPSEC_DELSPD, err ? 0 : 1, xp, NULL);
+
+	if (err)
 		goto out;
+
 	c.seq = hdr->sadb_msg_seq;
 	c.pid = hdr->sadb_msg_pid;
 	c.event = XFRM_MSG_DELPOLICY;
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index a24f385..c394b41 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1997,9 +1997,14 @@ void xfrm_audit_log(uid_t auid, u32 sid, int type, int result,
 	if (audit_enabled == 0)
 		return;
 
+	BUG_ON((type == AUDIT_MAC_IPSEC_ADDSA ||
+		type == AUDIT_MAC_IPSEC_DELSA) && !x);
+	BUG_ON((type == AUDIT_MAC_IPSEC_ADDSPD ||
+		type == AUDIT_MAC_IPSEC_DELSPD) && !xp);
+
 	audit_buf = audit_log_start(current->audit_context, GFP_ATOMIC, type);
 	if (audit_buf == NULL)
-	return;
+		return;
 
 	switch(type) {
 	case AUDIT_MAC_IPSEC_ADDSA:
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index d55436d..2567453 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -1273,10 +1273,6 @@ static int xfrm_get_policy(struct sk_buff *skb, struct nlmsghdr *nlh,
 		xp = xfrm_policy_bysel_ctx(type, p->dir, &p->sel, tmp.security, delete);
 		security_xfrm_policy_free(&tmp);
 	}
-	if (delete)
-		xfrm_audit_log(NETLINK_CB(skb).loginuid, NETLINK_CB(skb).sid,
-			       AUDIT_MAC_IPSEC_DELSPD, (xp) ? 1 : 0, xp, NULL);
-
 	if (xp == NULL)
 		return -ENOENT;
 
@@ -1292,8 +1288,14 @@ static int xfrm_get_policy(struct sk_buff *skb, struct nlmsghdr *nlh,
 					      MSG_DONTWAIT);
 		}
 	} else {
-		if ((err = security_xfrm_policy_delete(xp)) != 0)
+		err = security_xfrm_policy_delete(xp);
+
+		xfrm_audit_log(NETLINK_CB(skb).loginuid, NETLINK_CB(skb).sid,
+			       AUDIT_MAC_IPSEC_DELSPD, err ? 0 : 1, xp, NULL);
+
+		if (err != 0)
 			goto out;
+
 		c.data.byid = p->index;
 		c.event = nlh->nlmsg_type;
 		c.seq = nlh->nlmsg_seq;
