From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 1/2] netlink: kill loginuid/sessionid/sid members from struct
 netlink_skb_parms
Date: Thu, 03 Mar 2011 10:38:01 +0100
Message-ID: <4D6F6179.7040203@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090501090005040502010003"
Cc: "David S. Miller" <davem@davemloft.net>,
	Al Viro <viro@ZenIV.linux.org.uk>,
	Eric Paris <eparis@redhat.com>, linux-audit@redhat.com
To: NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:52750 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750805Ab1CCJiF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2011 04:38:05 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------090501090005040502010003
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

The following two patches kill a few unnecessary members of the
netlink cb in order to make room for new members needed for memory
mapped netlink.


--------------090501090005040502010003
Content-Type: text/plain;
 name="01.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="01.diff"

commit 509c35212e0d2362393597f195dc5da3fafd4a9c
Author: Patrick McHardy <kaber@trash.net>
Date:   Thu Mar 3 10:17:28 2011 +0100

    netlink: kill loginuid/sessionid/sid members from struct netlink_skb_parms
    
    Netlink message processing in the kernel is synchronous these days, the
    session information can be collected when needed.
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/include/linux/netlink.h b/include/linux/netlink.h
index e2b9e63..66823b8 100644
--- a/include/linux/netlink.h
+++ b/include/linux/netlink.h
@@ -161,9 +161,6 @@ struct netlink_skb_parms {
 	__u32			pid;
 	__u32			dst_group;
 	kernel_cap_t		eff_cap;
-	__u32			loginuid;	/* Login (audit) uid */
-	__u32			sessionid;	/* Session id (audit) */
-	__u32			sid;		/* SELinux security id */
 };
 
 #define NETLINK_CB(skb)		(*(struct netlink_skb_parms*)&((skb)->cb))
diff --git a/kernel/audit.c b/kernel/audit.c
index 162e88e..9395003 100644
--- a/kernel/audit.c
+++ b/kernel/audit.c
@@ -673,9 +673,9 @@ static int audit_receive_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 
 	pid  = NETLINK_CREDS(skb)->pid;
 	uid  = NETLINK_CREDS(skb)->uid;
-	loginuid = NETLINK_CB(skb).loginuid;
-	sessionid = NETLINK_CB(skb).sessionid;
-	sid  = NETLINK_CB(skb).sid;
+	loginuid = audit_get_loginuid(current);
+	sessionid = audit_get_sessionid(current);
+	security_task_getsecid(current, &sid);
 	seq  = nlh->nlmsg_seq;
 	data = NLMSG_DATA(nlh);
 
diff --git a/kernel/auditfilter.c b/kernel/auditfilter.c
index add2819..f8277c8 100644
--- a/kernel/auditfilter.c
+++ b/kernel/auditfilter.c
@@ -1238,6 +1238,7 @@ static int audit_filter_user_rules(struct netlink_skb_parms *cb,
 	for (i = 0; i < rule->field_count; i++) {
 		struct audit_field *f = &rule->fields[i];
 		int result = 0;
+		u32 sid;
 
 		switch (f->type) {
 		case AUDIT_PID:
@@ -1250,19 +1251,22 @@ static int audit_filter_user_rules(struct netlink_skb_parms *cb,
 			result = audit_comparator(cb->creds.gid, f->op, f->val);
 			break;
 		case AUDIT_LOGINUID:
-			result = audit_comparator(cb->loginuid, f->op, f->val);
+			result = audit_comparator(audit_get_loginuid(current),
+						  f->op, f->val);
 			break;
 		case AUDIT_SUBJ_USER:
 		case AUDIT_SUBJ_ROLE:
 		case AUDIT_SUBJ_TYPE:
 		case AUDIT_SUBJ_SEN:
 		case AUDIT_SUBJ_CLR:
-			if (f->lsm_rule)
-				result = security_audit_rule_match(cb->sid,
+			if (f->lsm_rule) {
+				security_task_getsecid(current, &sid);
+				result = security_audit_rule_match(sid,
 								   f->type,
 								   f->op,
 								   f->lsm_rule,
 								   NULL);
+			}
 			break;
 		}
 
diff --git a/net/netlabel/netlabel_user.h b/net/netlabel/netlabel_user.h
index 6caef8b..f4fc4c9 100644
--- a/net/netlabel/netlabel_user.h
+++ b/net/netlabel/netlabel_user.h
@@ -49,9 +49,9 @@
 static inline void netlbl_netlink_auditinfo(struct sk_buff *skb,
 					    struct netlbl_audit *audit_info)
 {
-	audit_info->secid = NETLINK_CB(skb).sid;
-	audit_info->loginuid = NETLINK_CB(skb).loginuid;
-	audit_info->sessionid = NETLINK_CB(skb).sessionid;
+	security_task_getsecid(current, &audit_info->secid);
+	audit_info->loginuid = audit_get_loginuid(current);
+	audit_info->sessionid = audit_get_sessionid(current);
 }
 
 /* NetLabel NETLINK I/O functions */
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 478181d..97ecd92 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -1362,9 +1362,6 @@ static int netlink_sendmsg(struct kiocb *kiocb, struct socket *sock,
 
 	NETLINK_CB(skb).pid	= nlk->pid;
 	NETLINK_CB(skb).dst_group = dst_group;
-	NETLINK_CB(skb).loginuid = audit_get_loginuid(current);
-	NETLINK_CB(skb).sessionid = audit_get_sessionid(current);
-	security_task_getsecid(current, &(NETLINK_CB(skb).sid));
 	memcpy(NETLINK_CREDS(skb), &siocb->scm->creds, sizeof(struct ucred));
 
 	/* What can I do? Netlink is asynchronous, so that
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 673698d..468ab60 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -497,9 +497,9 @@ static int xfrm_add_sa(struct sk_buff *skb, struct nlmsghdr *nlh,
 	struct xfrm_state *x;
 	int err;
 	struct km_event c;
-	uid_t loginuid = NETLINK_CB(skb).loginuid;
-	u32 sessionid = NETLINK_CB(skb).sessionid;
-	u32 sid = NETLINK_CB(skb).sid;
+	uid_t loginuid = audit_get_loginuid(current);
+	u32 sessionid = audit_get_sessionid(current);
+	u32 sid;
 
 	err = verify_newsa_info(p, attrs);
 	if (err)
@@ -515,6 +515,7 @@ static int xfrm_add_sa(struct sk_buff *skb, struct nlmsghdr *nlh,
 	else
 		err = xfrm_state_update(x);
 
+	security_task_getsecid(current, &sid);
 	xfrm_audit_state_add(x, err ? 0 : 1, loginuid, sessionid, sid);
 
 	if (err < 0) {
@@ -575,9 +576,9 @@ static int xfrm_del_sa(struct sk_buff *skb, struct nlmsghdr *nlh,
 	int err = -ESRCH;
 	struct km_event c;
 	struct xfrm_usersa_id *p = nlmsg_data(nlh);
-	uid_t loginuid = NETLINK_CB(skb).loginuid;
-	u32 sessionid = NETLINK_CB(skb).sessionid;
-	u32 sid = NETLINK_CB(skb).sid;
+	uid_t loginuid = audit_get_loginuid(current);
+	u32 sessionid = audit_get_sessionid(current);
+	u32 sid;
 
 	x = xfrm_user_state_lookup(net, p, attrs, &err);
 	if (x == NULL)
@@ -602,6 +603,7 @@ static int xfrm_del_sa(struct sk_buff *skb, struct nlmsghdr *nlh,
 	km_state_notify(x, &c);
 
 out:
+	security_task_getsecid(current, &sid);
 	xfrm_audit_state_delete(x, err ? 0 : 1, loginuid, sessionid, sid);
 	xfrm_state_put(x);
 	return err;
@@ -1265,9 +1267,9 @@ static int xfrm_add_policy(struct sk_buff *skb, struct nlmsghdr *nlh,
 	struct km_event c;
 	int err;
 	int excl;
-	uid_t loginuid = NETLINK_CB(skb).loginuid;
-	u32 sessionid = NETLINK_CB(skb).sessionid;
-	u32 sid = NETLINK_CB(skb).sid;
+	uid_t loginuid = audit_get_loginuid(current);
+	u32 sessionid = audit_get_sessionid(current);
+	u32 sid;
 
 	err = verify_newpolicy_info(p);
 	if (err)
@@ -1286,6 +1288,7 @@ static int xfrm_add_policy(struct sk_buff *skb, struct nlmsghdr *nlh,
 	 * a type XFRM_MSG_UPDPOLICY - JHS */
 	excl = nlh->nlmsg_type == XFRM_MSG_NEWPOLICY;
 	err = xfrm_policy_insert(p->dir, xp, excl);
+	security_task_getsecid(current, &sid);
 	xfrm_audit_policy_add(xp, err ? 0 : 1, loginuid, sessionid, sid);
 
 	if (err) {
@@ -1522,10 +1525,11 @@ static int xfrm_get_policy(struct sk_buff *skb, struct nlmsghdr *nlh,
 					    NETLINK_CB(skb).pid);
 		}
 	} else {
-		uid_t loginuid = NETLINK_CB(skb).loginuid;
-		u32 sessionid = NETLINK_CB(skb).sessionid;
-		u32 sid = NETLINK_CB(skb).sid;
+		uid_t loginuid = audit_get_loginuid(current);
+		u32 sessionid = audit_get_sessionid(current);
+		u32 sid;
 
+		security_task_getsecid(current, &sid);
 		xfrm_audit_policy_delete(xp, err ? 0 : 1, loginuid, sessionid,
 					 sid);
 
@@ -1553,9 +1557,9 @@ static int xfrm_flush_sa(struct sk_buff *skb, struct nlmsghdr *nlh,
 	struct xfrm_audit audit_info;
 	int err;
 
-	audit_info.loginuid = NETLINK_CB(skb).loginuid;
-	audit_info.sessionid = NETLINK_CB(skb).sessionid;
-	audit_info.secid = NETLINK_CB(skb).sid;
+	audit_info.loginuid = audit_get_loginuid(current);
+	audit_info.sessionid = audit_get_sessionid(current);
+	security_task_getsecid(current, &audit_info.secid);
 	err = xfrm_state_flush(net, p->proto, &audit_info);
 	if (err) {
 		if (err == -ESRCH) /* empty table */
@@ -1720,9 +1724,9 @@ static int xfrm_flush_policy(struct sk_buff *skb, struct nlmsghdr *nlh,
 	if (err)
 		return err;
 
-	audit_info.loginuid = NETLINK_CB(skb).loginuid;
-	audit_info.sessionid = NETLINK_CB(skb).sessionid;
-	audit_info.secid = NETLINK_CB(skb).sid;
+	audit_info.loginuid = audit_get_loginuid(current);
+	audit_info.sessionid = audit_get_sessionid(current);
+	security_task_getsecid(current, &audit_info.secid);
 	err = xfrm_policy_flush(net, type, &audit_info);
 	if (err) {
 		if (err == -ESRCH) /* empty table */
@@ -1789,9 +1793,11 @@ static int xfrm_add_pol_expire(struct sk_buff *skb, struct nlmsghdr *nlh,
 
 	err = 0;
 	if (up->hard) {
-		uid_t loginuid = NETLINK_CB(skb).loginuid;
-		uid_t sessionid = NETLINK_CB(skb).sessionid;
-		u32 sid = NETLINK_CB(skb).sid;
+		uid_t loginuid = audit_get_loginuid(current);
+		u32 sessionid = audit_get_sessionid(current);
+		u32 sid;
+
+		security_task_getsecid(current, &sid);
 		xfrm_policy_delete(xp, p->dir);
 		xfrm_audit_policy_delete(xp, 1, loginuid, sessionid, sid);
 
@@ -1830,9 +1836,11 @@ static int xfrm_add_sa_expire(struct sk_buff *skb, struct nlmsghdr *nlh,
 	km_state_expired(x, ue->hard, current->pid);
 
 	if (ue->hard) {
-		uid_t loginuid = NETLINK_CB(skb).loginuid;
-		uid_t sessionid = NETLINK_CB(skb).sessionid;
-		u32 sid = NETLINK_CB(skb).sid;
+		uid_t loginuid = audit_get_loginuid(current);
+		u32 sessionid = audit_get_sessionid(current);
+		u32 sid;
+
+		security_task_getsecid(current, &sid);
 		__xfrm_state_delete(x);
 		xfrm_audit_state_delete(x, 1, loginuid, sessionid, sid);
 	}
diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index c8d6992..cef42f5 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -4669,6 +4669,7 @@ static int selinux_netlink_recv(struct sk_buff *skb, int capability)
 {
 	int err;
 	struct common_audit_data ad;
+	u32 sid;
 
 	err = cap_netlink_recv(skb, capability);
 	if (err)
@@ -4677,8 +4678,9 @@ static int selinux_netlink_recv(struct sk_buff *skb, int capability)
 	COMMON_AUDIT_DATA_INIT(&ad, CAP);
 	ad.u.cap = capability;
 
-	return avc_has_perm(NETLINK_CB(skb).sid, NETLINK_CB(skb).sid,
-			    SECCLASS_CAPABILITY, CAP_TO_MASK(capability), &ad);
+	security_task_getsecid(current, &sid);
+	return avc_has_perm(sid, sid, SECCLASS_CAPABILITY,
+			    CAP_TO_MASK(capability), &ad);
 }
 
 static int ipc_alloc_security(struct task_struct *task,

--------------090501090005040502010003--
