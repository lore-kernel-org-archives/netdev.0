From: Joy Latten <latten@austin.ibm.com>
Subject: Re: [PATCH]: Add security check before flushing SAD/SPD
Date: Mon, 26 Mar 2007 16:58:55 -0600
Message-ID: <200703262258.l2QMwtqq014099@faith.austin.ibm.com>
Cc: davemloft@davemloft.net, eparis@redhat.com, jmorris@namei.org,
	selinux@tycho.nsa.gov
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:51935 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751477AbXCZXPZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Mar 2007 19:15:25 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e33.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l2QNFO98017077
	for <netdev@vger.kernel.org>; Mon, 26 Mar 2007 19:15:24 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l2QNFOOw060056
	for <netdev@vger.kernel.org>; Mon, 26 Mar 2007 17:15:24 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l2QNFNTW008999
	for <netdev@vger.kernel.org>; Mon, 26 Mar 2007 17:15:23 -0600
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I have made improvements based on James' and Eric's comments.

Regards,
Joy

Signed-off-by: Joy Latten<latten@austin.ibm.com>

diff -urpN linux-2.6.20.orig/include/net/xfrm.h linux-2.6.20.patch/include/net/xfrm.h
--- linux-2.6.20.orig/include/net/xfrm.h	2007-03-23 11:01:48.000000000 -0500
+++ linux-2.6.20.patch/include/net/xfrm.h	2007-03-25 21:36:05.000000000 -0500
@@ -937,7 +937,7 @@ static inline int xfrm_state_sort(struct
 #endif
 extern struct xfrm_state *xfrm_find_acq_byseq(u32 seq);
 extern int xfrm_state_delete(struct xfrm_state *x);
-extern void xfrm_state_flush(u8 proto, struct xfrm_audit *audit_info);
+extern int xfrm_state_flush(u8 proto, struct xfrm_audit *audit_info);
 extern int xfrm_replay_check(struct xfrm_state *x, __be32 seq);
 extern void xfrm_replay_advance(struct xfrm_state *x, __be32 seq);
 extern void xfrm_replay_notify(struct xfrm_state *x, int event);
@@ -991,13 +991,13 @@ struct xfrm_policy *xfrm_policy_bysel_ct
 					  struct xfrm_sec_ctx *ctx, int delete,
 					  int *err);
 struct xfrm_policy *xfrm_policy_byid(u8, int dir, u32 id, int delete, int *err);
-void xfrm_policy_flush(u8 type, struct xfrm_audit *audit_info);
+int xfrm_policy_flush(u8 type, struct xfrm_audit *audit_info);
 u32 xfrm_get_acqseq(void);
 void xfrm_alloc_spi(struct xfrm_state *x, __be32 minspi, __be32 maxspi);
 struct xfrm_state * xfrm_find_acq(u8 mode, u32 reqid, u8 proto,
 				  xfrm_address_t *daddr, xfrm_address_t *saddr,
 				  int create, unsigned short family);
-extern void xfrm_policy_flush(u8 type, struct xfrm_audit *audit_info);
+extern int xfrm_policy_flush(u8 type, struct xfrm_audit *audit_info);
 extern int xfrm_sk_policy_insert(struct sock *sk, int dir, struct xfrm_policy *pol);
 extern int xfrm_bundle_ok(struct xfrm_policy *pol, struct xfrm_dst *xdst,
 			  struct flowi *fl, int family, int strict);
diff -urpN linux-2.6.20.orig/net/key/af_key.c linux-2.6.20.patch/net/key/af_key.c
--- linux-2.6.20.orig/net/key/af_key.c	2007-03-23 11:02:49.000000000 -0500
+++ linux-2.6.20.patch/net/key/af_key.c	2007-03-25 21:34:35.000000000 -0500
@@ -1645,6 +1645,7 @@ static int pfkey_flush(struct sock *sk, 
 	unsigned proto;
 	struct km_event c;
 	struct xfrm_audit audit_info;
+	int err;
 
 	proto = pfkey_satype2proto(hdr->sadb_msg_satype);
 	if (proto == 0)
@@ -1652,7 +1653,9 @@ static int pfkey_flush(struct sock *sk, 
 
 	audit_info.loginuid = audit_get_loginuid(current->audit_context);
 	audit_info.secid = 0;
-	xfrm_state_flush(proto, &audit_info);
+	err = xfrm_state_flush(proto, &audit_info);
+	if (err)
+		return err;
 	c.data.proto = proto;
 	c.seq = hdr->sadb_msg_seq;
 	c.pid = hdr->sadb_msg_pid;
@@ -2628,10 +2631,13 @@ static int pfkey_spdflush(struct sock *s
 {
 	struct km_event c;
 	struct xfrm_audit audit_info;
+	int err;
 
 	audit_info.loginuid = audit_get_loginuid(current->audit_context);
 	audit_info.secid = 0;
-	xfrm_policy_flush(XFRM_POLICY_TYPE_MAIN, &audit_info);
+	err = xfrm_policy_flush(XFRM_POLICY_TYPE_MAIN, &audit_info);
+	if (err)
+		return err;
 	c.data.type = XFRM_POLICY_TYPE_MAIN;
 	c.event = XFRM_MSG_FLUSHPOLICY;
 	c.pid = hdr->sadb_msg_pid;
diff -urpN linux-2.6.20.orig/net/xfrm/xfrm_policy.c linux-2.6.20.patch/net/xfrm/xfrm_policy.c
--- linux-2.6.20.orig/net/xfrm/xfrm_policy.c	2007-03-23 11:02:46.000000000 -0500
+++ linux-2.6.20.patch/net/xfrm/xfrm_policy.c	2007-03-26 17:19:26.000000000 -0500
@@ -813,11 +813,67 @@ struct xfrm_policy *xfrm_policy_byid(u8 
 }
 EXPORT_SYMBOL(xfrm_policy_byid);
 
-void xfrm_policy_flush(u8 type, struct xfrm_audit *audit_info)
+#ifdef CONFIG_SECURITY_NETWORK_XFRM
+static inline int
+xfrm_policy_flush_secctx_check(u8 type, struct xfrm_audit *audit_info)
 {
-	int dir;
+	int dir, err = 0;
+
+	for (dir = 0; dir < XFRM_POLICY_MAX; dir++) {
+		struct xfrm_policy *pol;
+		struct hlist_node *entry;
+		int i;
+
+		hlist_for_each_entry(pol, entry,
+				     &xfrm_policy_inexact[dir], bydst) {
+			if (pol->type != type)
+				continue;
+			err = security_xfrm_policy_delete(pol);
+			if (err) {
+				xfrm_audit_log(audit_info->loginuid,
+					       audit_info->secid,
+					       AUDIT_MAC_IPSEC_DELSPD, 0,
+					       pol, NULL);
+				return err;
+			}
+                }
+		for (i = xfrm_policy_bydst[dir].hmask; i >= 0; i--) {
+			hlist_for_each_entry(pol, entry,
+					     xfrm_policy_bydst[dir].table + i,
+					     bydst) {
+				if (pol->type != type)
+					continue;
+				err = security_xfrm_policy_delete(pol);
+				if (err) {
+					xfrm_audit_log(audit_info->loginuid,
+						       audit_info->secid,
+						       AUDIT_MAC_IPSEC_DELSPD,
+						       0, pol, NULL);
+					return err;
+				}
+			}
+		}
+	}
+	return err;
+}
+#else
+static inline int
+xfrm_policy_flush_secctx_check(u8 type, struct xfrm_audit *audit_info)
+{
+	return 0;
+}
+#endif
+
+int xfrm_policy_flush(u8 type, struct xfrm_audit *audit_info)
+{
+	int dir, err = 0;
 
 	write_lock_bh(&xfrm_policy_lock);
+
+	err = xfrm_policy_flush_secctx_check(type, audit_info);
+	if (err)
+		goto out;
+
 	for (dir = 0; dir < XFRM_POLICY_MAX; dir++) {
 		struct xfrm_policy *pol;
 		struct hlist_node *entry;
@@ -870,7 +926,9 @@ void xfrm_policy_flush(u8 type, struct x
 		xfrm_policy_count[dir] -= killed;
 	}
 	atomic_inc(&flow_cache_genid);
+out:
 	write_unlock_bh(&xfrm_policy_lock);
+	return err;
 }
 EXPORT_SYMBOL(xfrm_policy_flush);
 
@@ -2485,4 +2543,3 @@ restore_state:
 }
 EXPORT_SYMBOL(xfrm_migrate);
 #endif
-
diff -urpN linux-2.6.20.orig/net/xfrm/xfrm_state.c linux-2.6.20.patch/net/xfrm/xfrm_state.c
--- linux-2.6.20.orig/net/xfrm/xfrm_state.c	2007-03-23 11:02:46.000000000 -0500
+++ linux-2.6.20.patch/net/xfrm/xfrm_state.c	2007-03-26 17:19:56.000000000 -0500
@@ -388,12 +388,48 @@ int xfrm_state_delete(struct xfrm_state 
 }
 EXPORT_SYMBOL(xfrm_state_delete);
 
-void xfrm_state_flush(u8 proto, struct xfrm_audit *audit_info)
+#ifdef CONFIG_SECURITY_NETWORK_XFRM
+static inline int
+xfrm_state_flush_secctx_check(u8 proto, struct xfrm_audit *audit_info) 
 {
-	int i;
-	int err = 0;
+	int i, err = 0;
+
+	for (i = 0; i <= xfrm_state_hmask; i++) {
+		struct hlist_node *entry;
+		struct xfrm_state *x;
+
+		hlist_for_each_entry(x, entry, xfrm_state_bydst+i, bydst) {
+			if (xfrm_id_proto_match(x->id.proto, proto) &&
+			   (err = security_xfrm_state_delete(x)) != 0) {
+				xfrm_audit_log(audit_info->loginuid,
+					       audit_info->secid,
+					       AUDIT_MAC_IPSEC_DELSA, 
+                                               0, NULL, x);
+
+				return err;
+			}
+		}
+	}
+
+	return err;
+}
+#else
+static inline int
+xfrm_state_flush_secctx_check(u8 proto, struct xfrm_audit *audit_info)
+{
+	return 0;
+}
+#endif
+
+int xfrm_state_flush(u8 proto, struct xfrm_audit *audit_info)
+{
+	int i, err = 0;
 
 	spin_lock_bh(&xfrm_state_lock);
+	err = xfrm_state_flush_secctx_check(proto, audit_info);
+	if (err)
+		goto out;
+		
 	for (i = 0; i <= xfrm_state_hmask; i++) {
 		struct hlist_node *entry;
 		struct xfrm_state *x;
@@ -416,8 +452,12 @@ restart:
 			}
 		}
 	}
+	err = 0;
+
+out:
 	spin_unlock_bh(&xfrm_state_lock);
 	wake_up(&km_waitq);
+	return err;
 }
 EXPORT_SYMBOL(xfrm_state_flush);
 
diff -urpN linux-2.6.20.orig/net/xfrm/xfrm_user.c linux-2.6.20.patch/net/xfrm/xfrm_user.c
--- linux-2.6.20.orig/net/xfrm/xfrm_user.c	2007-03-23 11:02:46.000000000 -0500
+++ linux-2.6.20.patch/net/xfrm/xfrm_user.c	2007-03-25 21:33:52.000000000 -0500
@@ -1312,10 +1312,13 @@ static int xfrm_flush_sa(struct sk_buff 
 	struct km_event c;
 	struct xfrm_usersa_flush *p = NLMSG_DATA(nlh);
 	struct xfrm_audit audit_info;
+	int err;
 
 	audit_info.loginuid = NETLINK_CB(skb).loginuid;
 	audit_info.secid = NETLINK_CB(skb).sid;
-	xfrm_state_flush(p->proto, &audit_info);
+	err = xfrm_state_flush(p->proto, &audit_info);
+	if (err)
+		return err;
 	c.data.proto = p->proto;
 	c.event = nlh->nlmsg_type;
 	c.seq = nlh->nlmsg_seq;
@@ -1476,7 +1479,9 @@ static int xfrm_flush_policy(struct sk_b
 
 	audit_info.loginuid = NETLINK_CB(skb).loginuid;
 	audit_info.secid = NETLINK_CB(skb).sid;
-	xfrm_policy_flush(type, &audit_info);
+	err = xfrm_policy_flush(type, &audit_info);
+	if (err)
+		return err;
 	c.data.type = type;
 	c.event = nlh->nlmsg_type;
 	c.seq = nlh->nlmsg_seq;
