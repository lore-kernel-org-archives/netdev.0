From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Subject: [PATCH 22/23] [PATCH] [XFRM] POLICY: Support netlink socket interface for sub policy.
Date: Sat, 29 Jul 2006 18:30:55 +0900
Message-ID: <1154165455769-git-send-email-nakam@linux-ipv6.org>
Reply-To: Masahide NAKAMURA <nakam@linux-ipv6.org>
Cc: yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi, vnuorval@tcs.hut.fi,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org,
	Masahide NAKAMURA <nakam@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pc9.nezu.wide.ad.jp ([203.178.142.216]:33411 "EHLO jupiter")
	by vger.kernel.org with ESMTP id S1422703AbWG2Ja5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Jul 2006 05:30:57 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sub policy can be used through netlink socket.
(PF_KEY uses main only and it is TODO to support sub.)
---
 include/linux/xfrm.h |    6 +++++
 include/net/xfrm.h   |    1 +
 net/key/af_key.c     |   13 +++++++----
 net/xfrm/xfrm_user.c |   60 +++++++++++++++++++++++++++++++++++++++++++-------
 4 files changed, 66 insertions(+), 14 deletions(-)

diff --git a/include/linux/xfrm.h b/include/linux/xfrm.h
index 901bb65..68d3443 100644
--- a/include/linux/xfrm.h
+++ b/include/linux/xfrm.h
@@ -303,12 +303,14 @@ #define XFRM_POLICY_BLOCK	1
 	__u8				flags;
 #define XFRM_POLICY_LOCALOK	1	/* Allow user to override global policy */
 	__u8				share;
+	__u8				type;
 };
 
 struct xfrm_userpolicy_id {
 	struct xfrm_selector		sel;
 	__u32				index;
 	__u8				dir;
+	__u8				type;
 };
 
 struct xfrm_user_acquire {
@@ -336,6 +338,10 @@ struct xfrm_usersa_flush {
 	__u8				proto;
 };
 
+struct xfrm_userpolicy_flush {
+	__u8			        type;
+};
+
 /*
  * This notifies flow information to the user space with carrying XFRMA_ADDR.
  */
diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index c1cc2f5..0d14b1f 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -202,6 +202,7 @@ struct km_event
 		u32 proto;
 		u32 byid;
 		u32 aevent;
+		u32 type;
 	} data;
 
 	u32	seq;
diff --git a/net/key/af_key.c b/net/key/af_key.c
index ed2d712..2bc9665 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -1730,7 +1730,8 @@ static u32 gen_reqid(void)
 		++reqid;
 		if (reqid == 0)
 			reqid = IPSEC_MANUAL_REQID_MAX+1;
-		if (xfrm_policy_walk(check_reqid, (void*)&reqid) != -EEXIST)
+		if (xfrm_policy_walk(XFRM_POLICY_TYPE_MAIN, check_reqid,
+				     (void*)&reqid) != -EEXIST)
 			return reqid;
 	} while (reqid != start);
 	return 0;
@@ -2267,7 +2268,8 @@ static int pfkey_spddelete(struct sock *
 			return err;
 	}
 
-	xp = xfrm_policy_bysel_ctx(pol->sadb_x_policy_dir-1, &sel, tmp.security, 1);
+	xp = xfrm_policy_bysel_ctx(XFRM_POLICY_TYPE_MAIN, pol->sadb_x_policy_dir-1,
+				   &sel, tmp.security, 1);
 	security_xfrm_policy_free(&tmp);
 	if (xp == NULL)
 		return -ENOENT;
@@ -2326,7 +2328,7 @@ static int pfkey_spdget(struct sock *sk,
 	if (dir >= XFRM_POLICY_MAX)
 		return -EINVAL;
 
-	xp = xfrm_policy_byid(dir, pol->sadb_x_policy_id,
+	xp = xfrm_policy_byid(XFRM_POLICY_TYPE_MAIN, dir, pol->sadb_x_policy_id,
 			      hdr->sadb_msg_type == SADB_X_SPDDELETE2);
 	if (xp == NULL)
 		return -ENOENT;
@@ -2374,7 +2376,7 @@ static int pfkey_spddump(struct sock *sk
 {
 	struct pfkey_dump_data data = { .skb = skb, .hdr = hdr, .sk = sk };
 
-	return xfrm_policy_walk(dump_sp, &data);
+	return xfrm_policy_walk(XFRM_POLICY_TYPE_MAIN, dump_sp, &data);
 }
 
 static int key_notify_policy_flush(struct km_event *c)
@@ -2401,7 +2403,8 @@ static int pfkey_spdflush(struct sock *s
 {
 	struct km_event c;
 
-	xfrm_policy_flush();
+	xfrm_policy_flush(XFRM_POLICY_TYPE_MAIN);
+	c.data.type = XFRM_POLICY_TYPE_MAIN;
 	c.event = XFRM_MSG_FLUSHPOLICY;
 	c.pid = hdr->sadb_msg_pid;
 	c.seq = hdr->sadb_msg_seq;
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 8d7bf0a..cf62208 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -754,8 +754,26 @@ static int verify_policy_dir(__u8 dir)
 	return 0;
 }
 
+static int verify_policy_type(__u8 type)
+{
+	switch (type) {
+	case XFRM_POLICY_TYPE_MAIN:
+#ifdef CONFIG_XFRM_SUB_POLICY
+	case XFRM_POLICY_TYPE_SUB:
+#endif
+		break;
+
+	default:
+		return -EINVAL;
+	};
+
+	return 0;
+}
+
 static int verify_newpolicy_info(struct xfrm_userpolicy_info *p)
 {
+	int err;
+
 	switch (p->share) {
 	case XFRM_SHARE_ANY:
 	case XFRM_SHARE_SESSION:
@@ -791,6 +809,10 @@ #endif
 		return -EINVAL;
 	};
 
+	err = verify_policy_type(p->type);
+	if (err)
+		return err;
+
 	return verify_policy_dir(p->dir);
 }
 
@@ -857,6 +879,7 @@ static void copy_from_user_policy(struct
 	xp->flags = p->flags;
 	xp->family = p->sel.family;
 	/* XXX xp->share = p->share; */
+	xp->type = p->type;
 }
 
 static void copy_to_user_policy(struct xfrm_policy *xp, struct xfrm_userpolicy_info *p, int dir)
@@ -871,6 +894,7 @@ static void copy_to_user_policy(struct x
 	p->action = xp->action;
 	p->flags = xp->flags;
 	p->share = XFRM_SHARE_ANY; /* XXX xp->share */
+	p->type = xp->type;
 }
 
 static struct xfrm_policy *xfrm_policy_construct(struct xfrm_userpolicy_info *p, struct rtattr **xfrma, int *errp)
@@ -1036,7 +1060,10 @@ static int xfrm_dump_policy(struct sk_bu
 	info.nlmsg_flags = NLM_F_MULTI;
 	info.this_idx = 0;
 	info.start_idx = cb->args[0];
-	(void) xfrm_policy_walk(dump_one_policy, &info);
+	(void) xfrm_policy_walk(XFRM_POLICY_TYPE_MAIN, dump_one_policy, &info);
+#ifdef CONFIG_XFRM_SUB_POLICY
+	(void) xfrm_policy_walk(XFRM_POLICY_TYPE_SUB, dump_one_policy, &info);
+#endif
 	cb->args[0] = info.this_idx;
 
 	return skb->len;
@@ -1079,12 +1106,16 @@ static int xfrm_get_policy(struct sk_buf
 	p = NLMSG_DATA(nlh);
 	delete = nlh->nlmsg_type == XFRM_MSG_DELPOLICY;
 
+	err = verify_policy_type(p->type);
+	if (err)
+		return err;
+
 	err = verify_policy_dir(p->dir);
 	if (err)
 		return err;
 
 	if (p->index)
-		xp = xfrm_policy_byid(p->dir, p->index, delete);
+		xp = xfrm_policy_byid(p->type, p->dir, p->index, delete);
 	else {
 		struct rtattr **rtattrs = (struct rtattr **)xfrma;
 		struct rtattr *rt = rtattrs[XFRMA_SEC_CTX-1];
@@ -1101,7 +1132,7 @@ static int xfrm_get_policy(struct sk_buf
 			if ((err = security_xfrm_policy_alloc(&tmp, uctx)))
 				return err;
 		}
-		xp = xfrm_policy_bysel_ctx(p->dir, &p->sel, tmp.security, delete);
+		xp = xfrm_policy_bysel_ctx(p->type, p->dir, &p->sel, tmp.security, delete);
 		security_xfrm_policy_free(&tmp);
 	}
 	if (xp == NULL)
@@ -1282,8 +1313,10 @@ out:
 static int xfrm_flush_policy(struct sk_buff *skb, struct nlmsghdr *nlh, void **xfrma)
 {
 struct km_event c;
+	struct xfrm_userpolicy_flush *p = NLMSG_DATA(nlh);
 
-	xfrm_policy_flush();
+	xfrm_policy_flush(p->type);
+	c.data.type = p->type;
 	c.event = nlh->nlmsg_type;
 	c.seq = nlh->nlmsg_seq;
 	c.pid = nlh->nlmsg_pid;
@@ -1299,7 +1332,7 @@ static int xfrm_add_pol_expire(struct sk
 	int err = -ENOENT;
 
 	if (p->index)
-		xp = xfrm_policy_byid(p->dir, p->index, 0);
+		xp = xfrm_policy_byid(p->type, p->dir, p->index, 0);
 	else {
 		struct rtattr **rtattrs = (struct rtattr **)xfrma;
 		struct rtattr *rt = rtattrs[XFRMA_SEC_CTX-1];
@@ -1316,7 +1349,7 @@ static int xfrm_add_pol_expire(struct sk
 			if ((err = security_xfrm_policy_alloc(&tmp, uctx)))
 				return err;
 		}
-		xp = xfrm_policy_bysel_ctx(p->dir, &p->sel, tmp.security, 0);
+		xp = xfrm_policy_bysel_ctx(p->type, p->dir, &p->sel, tmp.security, 0);
 		security_xfrm_policy_free(&tmp);
 	}
 
@@ -1838,6 +1871,11 @@ #endif
 	    verify_newpolicy_info(p))
 		return NULL;
 
+#ifdef CONFIG_XFRM_SUB_POLICY
+	if (p->type != XFRM_POLICY_TYPE_MAIN)
+		return NULL;
+#endif
+
 	nr = ((len - sizeof(*p)) / sizeof(*ut));
 	if (nr > XFRM_MAX_DEPTH)
 		return NULL;
@@ -1964,15 +2002,19 @@ static int xfrm_notify_policy_flush(stru
 	struct nlmsghdr *nlh;
 	struct sk_buff *skb;
 	unsigned char *b;
-	int len = NLMSG_LENGTH(0);
+	struct xfrm_userpolicy_flush *p;
+	int len = NLMSG_LENGTH(sizeof(struct xfrm_userpolicy_flush));
 
 	skb = alloc_skb(len, GFP_ATOMIC);
 	if (skb == NULL)
 		return -ENOMEM;
 	b = skb->tail;
 
-
-	nlh = NLMSG_PUT(skb, c->pid, c->seq, XFRM_MSG_FLUSHPOLICY, 0);
+	nlh = NLMSG_PUT(skb, c->pid, c->seq, XFRM_MSG_FLUSHPOLICY, sizeof(*p));
+	nlh->nlmsg_flags = 0;
+  
+	p = NLMSG_DATA(nlh);
+	p->type = c->data.type;
 
 	nlh->nlmsg_len = skb->tail - b;
 
-- 
1.4.1

