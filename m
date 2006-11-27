From: Joy Latten <latten@austin.ibm.com>
Subject: [PATCH 1/1] add auditing to ipsec
Date: Mon, 27 Nov 2006 16:26:16 -0600
Message-ID: <200611272226.kARMQGor018386@faith.austin.ibm.com>
Cc: davem@davemloft.net, herbert@gondor.apana.org.au,
	latten@austin.ibm.com, sgrubb@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:4756 "EHLO e35.co.us.ibm.com")
	by vger.kernel.org with ESMTP id S934378AbWK0Wjq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Nov 2006 17:39:46 -0500
Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e35.co.us.ibm.com (8.13.8/8.12.11) with ESMTP id kARMdhqh000577
	for <netdev@vger.kernel.org>; Mon, 27 Nov 2006 17:39:43 -0500
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by westrelay02.boulder.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id kARMdh0o536464
	for <netdev@vger.kernel.org>; Mon, 27 Nov 2006 15:39:43 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id kARMdgIr008634
	for <netdev@vger.kernel.org>; Mon, 27 Nov 2006 15:39:42 -0700
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds auditing to ipsec in 
support of labeled ipsec. 
An audit message occurs when an ipsec SA
or ipsec policy is created/deleted.

Patch was built against linux kernel 2.6.19-rc6.
Please let me know if this is acceptable. 

Regards,
Joy

---------------------------------------------------------------------------
diff -urpN linux-2.6.18.orig/include/linux/audit.h linux-2.6.18-patch/include/linux/audit.h
--- linux-2.6.18.orig/include/linux/audit.h	2006-11-27 11:21:16.000000000 -0600
+++ linux-2.6.18-patch/include/linux/audit.h	2006-11-27 12:28:43.000000000 -0600
@@ -101,6 +101,10 @@
 #define AUDIT_MAC_CIPSOV4_DEL	1408	/* NetLabel: del CIPSOv4 DOI entry */
 #define AUDIT_MAC_MAP_ADD	1409	/* NetLabel: add LSM domain mapping */
 #define AUDIT_MAC_MAP_DEL	1410	/* NetLabel: del LSM domain mapping */
+#define AUDIT_MAC_IPSEC_ADDSA	1411	/* Add a XFRM state */
+#define AUDIT_MAC_IPSEC_DELSA	1412	/* Delete a XFRM state */
+#define AUDIT_MAC_IPSEC_ADDSPD	1413	/* Add a XFRM policy */
+#define AUDIT_MAC_IPSEC_DELSPD	1414	/* Delete a XFRM policy */
 
 #define AUDIT_FIRST_KERN_ANOM_MSG   1700
 #define AUDIT_LAST_KERN_ANOM_MSG    1799
@@ -377,6 +381,7 @@ extern void auditsc_get_stamp(struct aud
 			      struct timespec *t, unsigned int *serial);
 extern int  audit_set_loginuid(struct task_struct *task, uid_t loginuid);
 extern uid_t audit_get_loginuid(struct audit_context *ctx);
+extern void audit_log_task_context(struct audit_buffer *ab);
 extern int __audit_ipc_obj(struct kern_ipc_perm *ipcp);
 extern int __audit_ipc_set_perm(unsigned long qbytes, uid_t uid, gid_t gid, mode_t mode);
 extern int audit_bprm(struct linux_binprm *bprm);
@@ -449,6 +454,7 @@ extern int audit_n_rules;
 #define audit_inode_update(i) do { ; } while (0)
 #define auditsc_get_stamp(c,t,s) do { BUG(); } while (0)
 #define audit_get_loginuid(c) ({ -1; })
+#define audit_log_task_context(b) do { ; } while (0)
 #define audit_ipc_obj(i) ({ 0; })
 #define audit_ipc_set_perm(q,u,g,m) ({ 0; })
 #define audit_bprm(p) ({ 0; })
diff -urpN linux-2.6.18.orig/include/net/xfrm.h linux-2.6.18-patch/include/net/xfrm.h
--- linux-2.6.18.orig/include/net/xfrm.h	2006-11-27 11:21:43.000000000 -0600
+++ linux-2.6.18-patch/include/net/xfrm.h	2006-11-27 12:29:11.000000000 -0600
@@ -389,6 +389,15 @@ extern int xfrm_unregister_km(struct xfr
 
 extern unsigned int xfrm_policy_count[XFRM_POLICY_MAX*2];
 
+/* Audit Information */
+struct xfrm_audit
+{
+	uid_t	loginuid;
+	u32	secid;
+};
+void xfrm_audit_log(uid_t auid, u32 secid, int type, int result,
+		    struct xfrm_policy *xp, struct xfrm_state *x);
+
 static inline void xfrm_pol_hold(struct xfrm_policy *policy)
 {
 	if (likely(policy != NULL))
@@ -934,7 +943,7 @@ static inline int xfrm_state_sort(struct
 #endif
 extern struct xfrm_state *xfrm_find_acq_byseq(u32 seq);
 extern int xfrm_state_delete(struct xfrm_state *x);
-extern void xfrm_state_flush(u8 proto);
+extern void xfrm_state_flush(u8 proto, struct xfrm_audit *audit_info);
 extern int xfrm_replay_check(struct xfrm_state *x, __be32 seq);
 extern void xfrm_replay_advance(struct xfrm_state *x, __be32 seq);
 extern void xfrm_replay_notify(struct xfrm_state *x, int event);
@@ -987,13 +996,13 @@ struct xfrm_policy *xfrm_policy_bysel_ct
 					  struct xfrm_selector *sel,
 					  struct xfrm_sec_ctx *ctx, int delete);
 struct xfrm_policy *xfrm_policy_byid(u8, int dir, u32 id, int delete);
-void xfrm_policy_flush(u8 type);
+void xfrm_policy_flush(u8 type, struct xfrm_audit *audit_info);
 u32 xfrm_get_acqseq(void);
 void xfrm_alloc_spi(struct xfrm_state *x, __be32 minspi, __be32 maxspi);
 struct xfrm_state * xfrm_find_acq(u8 mode, u32 reqid, u8 proto, 
 				  xfrm_address_t *daddr, xfrm_address_t *saddr, 
 				  int create, unsigned short family);
-extern void xfrm_policy_flush(u8 type);
+extern void xfrm_policy_flush(u8 type, struct xfrm_audit *audit_info);
 extern int xfrm_sk_policy_insert(struct sock *sk, int dir, struct xfrm_policy *pol);
 extern int xfrm_bundle_ok(struct xfrm_policy *pol, struct xfrm_dst *xdst,
 			  struct flowi *fl, int family, int strict);
diff -urpN linux-2.6.18.orig/kernel/auditsc.c linux-2.6.18-patch/kernel/auditsc.c
--- linux-2.6.18.orig/kernel/auditsc.c	2006-11-27 11:19:36.000000000 -0600
+++ linux-2.6.18-patch/kernel/auditsc.c	2006-11-27 12:26:39.000000000 -0600
@@ -730,7 +730,7 @@ static inline void audit_free_context(st
 		printk(KERN_ERR "audit: freed %d contexts\n", count);
 }
 
-static void audit_log_task_context(struct audit_buffer *ab)
+void audit_log_task_context(struct audit_buffer *ab)
 {
 	char *ctx = NULL;
 	ssize_t len = 0;
@@ -759,6 +759,8 @@ error_path:
 	return;
 }
 
+EXPORT_SYMBOL(audit_log_task_context);
+
 static void audit_log_task_info(struct audit_buffer *ab, struct task_struct *tsk)
 {
 	char name[sizeof(tsk->comm)];
@@ -1487,6 +1489,8 @@ uid_t audit_get_loginuid(struct audit_co
 	return ctx ? ctx->loginuid : -1;
 }
 
+EXPORT_SYMBOL(audit_get_loginuid);
+
 /**
  * __audit_mq_open - record audit data for a POSIX MQ open
  * @oflag: open flag
diff -urpN linux-2.6.18.orig/net/key/af_key.c linux-2.6.18-patch/net/key/af_key.c
--- linux-2.6.18.orig/net/key/af_key.c	2006-11-27 11:22:04.000000000 -0600
+++ linux-2.6.18-patch/net/key/af_key.c	2006-11-27 12:29:32.000000000 -0600
@@ -27,6 +27,7 @@
 #include <linux/proc_fs.h>
 #include <linux/init.h>
 #include <net/xfrm.h>
+#include <linux/audit.h>
 
 #include <net/sock.h>
 
@@ -1420,6 +1421,9 @@ static int pfkey_add(struct sock *sk, st
 	else
 		err = xfrm_state_update(x);
 
+	xfrm_audit_log(audit_get_loginuid(current->audit_context), 0,
+		       AUDIT_MAC_IPSEC_ADDSA, err ? 0 : 1, NULL, x);
+
 	if (err < 0) {
 		x->km.state = XFRM_STATE_DEAD;
 		__xfrm_state_put(x);
@@ -1462,6 +1466,10 @@ static int pfkey_delete(struct sock *sk,
 	}
 	
 	err = xfrm_state_delete(x);
+
+	xfrm_audit_log(audit_get_loginuid(current->audit_context), 0,
+		       AUDIT_MAC_IPSEC_DELSA, err ? 0 : 1, NULL, x);
+
 	if (err < 0)
 		goto out;
 
@@ -1637,12 +1645,15 @@ static int pfkey_flush(struct sock *sk, 
 {
 	unsigned proto;
 	struct km_event c;
+	struct xfrm_audit audit_info;
 
 	proto = pfkey_satype2proto(hdr->sadb_msg_satype);
 	if (proto == 0)
 		return -EINVAL;
 
-	xfrm_state_flush(proto);
+	audit_info.loginuid = audit_get_loginuid(current->audit_context);
+	audit_info.secid = 0;
+	xfrm_state_flush(proto, &audit_info);
 	c.data.proto = proto;
 	c.seq = hdr->sadb_msg_seq;
 	c.pid = hdr->sadb_msg_pid;
@@ -2195,6 +2206,9 @@ static int pfkey_spdadd(struct sock *sk,
 	err = xfrm_policy_insert(pol->sadb_x_policy_dir-1, xp,
 				 hdr->sadb_msg_type != SADB_X_SPDUPDATE);
 
+	xfrm_audit_log(audit_get_loginuid(current->audit_context), 0,
+		       AUDIT_MAC_IPSEC_ADDSPD, err ? 0 : 1, xp, NULL);
+
 	if (err)
 		goto out;
 
@@ -2272,6 +2286,10 @@ static int pfkey_spddelete(struct sock *
 	xp = xfrm_policy_bysel_ctx(XFRM_POLICY_TYPE_MAIN, pol->sadb_x_policy_dir-1,
 				   &sel, tmp.security, 1);
 	security_xfrm_policy_free(&tmp);
+
+	xfrm_audit_log(audit_get_loginuid(current->audit_context), 0,
+		       AUDIT_MAC_IPSEC_DELSPD, (xp) ? 1 : 0, xp, NULL);
+
 	if (xp == NULL)
 		return -ENOENT;
 
@@ -2406,8 +2424,11 @@ static int key_notify_policy_flush(struc
 static int pfkey_spdflush(struct sock *sk, struct sk_buff *skb, struct sadb_msg *hdr, void **ext_hdrs)
 {
 	struct km_event c;
+	struct xfrm_audit audit_info;
 
-	xfrm_policy_flush(XFRM_POLICY_TYPE_MAIN);
+	audit_info.loginuid = audit_get_loginuid(current->audit_context);
+	audit_info.secid = 0;
+	xfrm_policy_flush(XFRM_POLICY_TYPE_MAIN, &audit_info);
 	c.data.type = XFRM_POLICY_TYPE_MAIN;
 	c.event = XFRM_MSG_FLUSHPOLICY;
 	c.pid = hdr->sadb_msg_pid;
diff -urpN linux-2.6.18.orig/net/xfrm/xfrm_policy.c linux-2.6.18-patch/net/xfrm/xfrm_policy.c
--- linux-2.6.18.orig/net/xfrm/xfrm_policy.c	2006-11-27 11:22:05.000000000 -0600
+++ linux-2.6.18-patch/net/xfrm/xfrm_policy.c	2006-11-27 12:29:33.000000000 -0600
@@ -25,6 +25,7 @@
 #include <linux/cache.h>
 #include <net/xfrm.h>
 #include <net/ip.h>
+#include <linux/audit.h>
 
 #include "xfrm_hash.h"
 
@@ -770,7 +771,7 @@ struct xfrm_policy *xfrm_policy_byid(u8 
 }
 EXPORT_SYMBOL(xfrm_policy_byid);
 
-void xfrm_policy_flush(u8 type)
+void xfrm_policy_flush(u8 type, struct xfrm_audit *audit_info)
 {
 	int dir;
 
@@ -790,6 +791,9 @@ void xfrm_policy_flush(u8 type)
 			hlist_del(&pol->byidx);
 			write_unlock_bh(&xfrm_policy_lock);
 
+			xfrm_audit_log(audit_info->loginuid, audit_info->secid,
+				       AUDIT_MAC_IPSEC_DELSPD, 1, pol, NULL);
+
 			xfrm_policy_kill(pol);
 			killed++;
 
@@ -808,6 +812,11 @@ void xfrm_policy_flush(u8 type)
 				hlist_del(&pol->byidx);
 				write_unlock_bh(&xfrm_policy_lock);
 
+				xfrm_audit_log(audit_info->loginuid, 
+					       audit_info->secid,
+					       AUDIT_MAC_IPSEC_DELSPD, 1, 
+					       pol, NULL);
+
 				xfrm_policy_kill(pol);
 				killed++;
 
@@ -1946,6 +1955,115 @@ int xfrm_bundle_ok(struct xfrm_policy *p
 
 EXPORT_SYMBOL(xfrm_bundle_ok);
 
+/* Audit addition and deletion of SAs and ipsec policy */
+
+void xfrm_audit_log(uid_t auid, u32 sid, int type, int result,
+		    struct xfrm_policy *xp, struct xfrm_state *x)
+{
+
+	char *secctx;
+	u32 secctx_len;
+	struct xfrm_sec_ctx *sctx = NULL;
+	struct audit_buffer *audit_buf;
+	int family;
+	extern int audit_enabled;
+
+	if (audit_enabled == 0)
+		return;
+
+	audit_buf = audit_log_start(current->audit_context, GFP_ATOMIC, type);
+	if (audit_buf == NULL)
+	return;
+
+	switch(type) {
+	case AUDIT_MAC_IPSEC_ADDSA:
+		audit_log_format(audit_buf, "SAD add: auid=%u", auid);
+		break;
+	case AUDIT_MAC_IPSEC_DELSA:
+		audit_log_format(audit_buf, "SAD delete: auid=%u", auid);
+		break;
+	case AUDIT_MAC_IPSEC_ADDSPD:
+		audit_log_format(audit_buf, "SPD add: auid=%u", auid);
+		break;
+	case AUDIT_MAC_IPSEC_DELSPD:
+		audit_log_format(audit_buf, "SPD delete: auid=%u", auid);
+		break;
+	default:
+		return;
+	}
+
+	if (sid != 0 &&
+		security_secid_to_secctx(sid, &secctx, &secctx_len) == 0)
+		audit_log_format(audit_buf, " subj=%s", secctx);
+	else
+		audit_log_task_context(audit_buf);
+
+	if (xp) {
+		family = xp->selector.family;
+		if (xp->security)
+			sctx = xp->security;
+	} else {
+		family = x->props.family;
+		if (x->security)
+			sctx = x->security;
+	}
+
+	if (sctx)
+		audit_log_format(audit_buf,
+				" sec_alg=%u sec_doi=%u sec_obj=%s",
+				sctx->ctx_alg, sctx->ctx_doi, sctx->ctx_str);
+
+	switch(family) {
+	case AF_INET:
+		{
+			struct in_addr saddr, daddr;
+			if (xp) {
+				saddr.s_addr = xp->selector.saddr.a4;
+				daddr.s_addr = xp->selector.daddr.a4;
+			} else {
+				saddr.s_addr = x->props.saddr.a4;
+				daddr.s_addr = x->id.daddr.a4;
+			}
+			audit_log_format(audit_buf,
+					 " src=%u.%u.%u.%u dst=%u.%u.%u.%u",
+					 NIPQUAD(saddr), NIPQUAD(daddr));
+		}
+			break;
+	case AF_INET6:
+		{
+			struct in6_addr saddr6, daddr6;
+			if (xp) {
+				memcpy(&saddr6, xp->selector.saddr.a6,
+					sizeof(struct in6_addr));
+				memcpy(&daddr6, xp->selector.daddr.a6,
+					sizeof(struct in6_addr));
+			} else {
+				memcpy(&saddr6, x->props.saddr.a6,
+					sizeof(struct in6_addr));
+				memcpy(&daddr6, x->id.daddr.a6,
+					sizeof(struct in6_addr));
+			}
+			audit_log_format(audit_buf,
+					 " src=" NIP6_FMT "dst=" NIP6_FMT,
+					 NIP6(saddr6), NIP6(daddr6));
+		}
+		break;
+	}
+
+	if (x)
+		audit_log_format(audit_buf, " spi=%lu(0x%lx) protocol=%s",
+				(unsigned long)ntohl(x->id.spi),
+				(unsigned long)ntohl(x->id.spi),
+				x->id.proto == IPPROTO_AH ? "AH" :
+				(x->id.proto == IPPROTO_ESP ?
+				"ESP" : "IPCOMP"));
+
+	audit_log_format(audit_buf, " res=%u", result);
+	audit_log_end(audit_buf);
+}
+
+EXPORT_SYMBOL(xfrm_audit_log);
+
 int xfrm_policy_register_afinfo(struct xfrm_policy_afinfo *afinfo)
 {
 	int err = 0;
diff -urpN linux-2.6.18.orig/net/xfrm/xfrm_state.c linux-2.6.18-patch/net/xfrm/xfrm_state.c
--- linux-2.6.18.orig/net/xfrm/xfrm_state.c	2006-11-27 11:22:05.000000000 -0600
+++ linux-2.6.18-patch/net/xfrm/xfrm_state.c	2006-11-27 12:29:33.000000000 -0600
@@ -20,6 +20,7 @@
 #include <linux/module.h>
 #include <linux/cache.h>
 #include <asm/uaccess.h>
+#include <linux/audit.h>
 
 #include "xfrm_hash.h"
 
@@ -238,6 +239,7 @@ static void xfrm_timer_handler(unsigned 
 	unsigned long now = (unsigned long)xtime.tv_sec;
 	long next = LONG_MAX;
 	int warn = 0;
+	int err = 0;
 
 	spin_lock(&x->lock);
 	if (x->km.state == XFRM_STATE_DEAD)
@@ -295,9 +297,14 @@ expired:
 		next = 2;
 		goto resched;
 	}
-	if (!__xfrm_state_delete(x) && x->id.spi)
+
+	err = __xfrm_state_delete(x);
+	if (!err && x->id.spi)
 		km_state_expired(x, 1, 0);
 
+	xfrm_audit_log(audit_get_loginuid(current->audit_context), 0,
+		       AUDIT_MAC_IPSEC_DELSA, err ? 0 : 1, NULL, x);
+
 out:
 	spin_unlock(&x->lock);
 }
@@ -384,9 +391,10 @@ int xfrm_state_delete(struct xfrm_state 
 }
 EXPORT_SYMBOL(xfrm_state_delete);
 
-void xfrm_state_flush(u8 proto)
+void xfrm_state_flush(u8 proto, struct xfrm_audit *audit_info)
 {
 	int i;
+	int err = 0;
 
 	spin_lock_bh(&xfrm_state_lock);
 	for (i = 0; i <= xfrm_state_hmask; i++) {
@@ -400,6 +408,11 @@ restart:
 				spin_unlock_bh(&xfrm_state_lock);
 
 				xfrm_state_delete(x);
+				err = xfrm_state_delete(x);
+				xfrm_audit_log(audit_info->loginuid,
+					       audit_info->secid,
+					       AUDIT_MAC_IPSEC_DELSA,
+					       err ? 0 : 1, NULL, x);
 				xfrm_state_put(x);
 
 				spin_lock_bh(&xfrm_state_lock);
diff -urpN linux-2.6.18.orig/net/xfrm/xfrm_user.c linux-2.6.18-patch/net/xfrm/xfrm_user.c
--- linux-2.6.18.orig/net/xfrm/xfrm_user.c	2006-11-27 11:22:05.000000000 -0600
+++ linux-2.6.18-patch/net/xfrm/xfrm_user.c	2006-11-27 12:29:33.000000000 -0600
@@ -31,6 +31,7 @@
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 #include <linux/in6.h>
 #endif
+#include <linux/audit.h>
 
 static int verify_one_alg(struct rtattr **xfrma, enum xfrm_attr_type_t type)
 {
@@ -457,6 +458,9 @@ static int xfrm_add_sa(struct sk_buff *s
 	else
 		err = xfrm_state_update(x);
 
+	xfrm_audit_log(NETLINK_CB(skb).loginuid, NETLINK_CB(skb).sid,
+		       AUDIT_MAC_IPSEC_ADDSA, err ? 0 : 1, NULL, x);
+
 	if (err < 0) {
 		x->km.state = XFRM_STATE_DEAD;
 		__xfrm_state_put(x);
@@ -525,6 +529,10 @@ static int xfrm_del_sa(struct sk_buff *s
 	}
 
 	err = xfrm_state_delete(x);
+
+	xfrm_audit_log(NETLINK_CB(skb).loginuid, NETLINK_CB(skb).sid,
+		       AUDIT_MAC_IPSEC_DELSA, err ? 0 : 1, NULL, x);
+
 	if (err < 0)
 		goto out;
 
@@ -998,6 +1006,9 @@ static int xfrm_add_policy(struct sk_buf
 	 * a type XFRM_MSG_UPDPOLICY - JHS */
 	excl = nlh->nlmsg_type == XFRM_MSG_NEWPOLICY;
 	err = xfrm_policy_insert(p->dir, xp, excl);
+	xfrm_audit_log(NETLINK_CB(skb).loginuid, NETLINK_CB(skb).sid,
+		       AUDIT_MAC_IPSEC_DELSPD, err ? 0 : 1, xp, NULL);
+
 	if (err) {
 		security_xfrm_policy_free(xp);
 		kfree(xp);
@@ -1226,6 +1237,10 @@ static int xfrm_get_policy(struct sk_buf
 		xp = xfrm_policy_bysel_ctx(type, p->dir, &p->sel, tmp.security, delete);
 		security_xfrm_policy_free(&tmp);
 	}
+	if (delete)
+		xfrm_audit_log(NETLINK_CB(skb).loginuid, NETLINK_CB(skb).sid,
+			       AUDIT_MAC_IPSEC_DELSPD, (xp) ? 1 : 0, xp, NULL);
+
 	if (xp == NULL)
 		return -ENOENT;
 
@@ -1260,8 +1275,11 @@ static int xfrm_flush_sa(struct sk_buff 
 {
 	struct km_event c;
 	struct xfrm_usersa_flush *p = NLMSG_DATA(nlh);
+	struct xfrm_audit audit_info;
 
-	xfrm_state_flush(p->proto);
+	audit_info.loginuid = NETLINK_CB(skb).loginuid;
+	audit_info.secid = NETLINK_CB(skb).sid;
+	xfrm_state_flush(p->proto, &audit_info);
 	c.data.proto = p->proto;
 	c.event = nlh->nlmsg_type;
 	c.seq = nlh->nlmsg_seq;
@@ -1409,12 +1427,15 @@ static int xfrm_flush_policy(struct sk_b
 	struct km_event c;
 	__u8 type = XFRM_POLICY_TYPE_MAIN;
 	int err;
+	struct xfrm_audit audit_info;
 
 	err = copy_from_user_policy_type(&type, (struct rtattr **)xfrma);
 	if (err)
 		return err;
 
-	xfrm_policy_flush(type);
+	audit_info.loginuid = NETLINK_CB(skb).loginuid;
+	audit_info.secid = NETLINK_CB(skb).sid;
+	xfrm_policy_flush(type, &audit_info);
 	c.data.type = type;
 	c.event = nlh->nlmsg_type;
 	c.seq = nlh->nlmsg_seq;
@@ -1469,6 +1490,9 @@ static int xfrm_add_pol_expire(struct sk
 	err = 0;
 	if (up->hard) {
 		xfrm_policy_delete(xp, p->dir);
+		xfrm_audit_log(NETLINK_CB(skb).loginuid, NETLINK_CB(skb).sid,
+				AUDIT_MAC_IPSEC_DELSPD, 1, xp, NULL);
+
 	} else {
 		// reset the timers here?
 		printk("Dont know what to do with soft policy expire\n");
@@ -1500,8 +1524,11 @@ static int xfrm_add_sa_expire(struct sk_
 		goto out;
 	km_state_expired(x, ue->hard, current->pid);
 
-	if (ue->hard)
+	if (ue->hard) {
 		__xfrm_state_delete(x);
+		xfrm_audit_log(NETLINK_CB(skb).loginuid, NETLINK_CB(skb).sid,
+			       AUDIT_MAC_IPSEC_DELSA, 1, NULL, x);
+	}
 out:
 	spin_unlock_bh(&x->lock);
 	xfrm_state_put(x);
