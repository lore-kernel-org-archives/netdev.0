From: Eric Paris <eparis@redhat.com>
Subject: Re: [PATCH]: Add security check before flushing SAD/SPD
Date: Mon, 04 Jun 2007 15:05:53 -0400
Message-ID: <1180983953.3950.37.camel@localhost.localdomain>
References: <200703262321.l2QNLZlR014240@faith.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jmorris@namei.org, selinux@tycho.nsa.gov,
	Joy Latten <latten@austin.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:56657 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759094AbXFDTL5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jun 2007 15:11:57 -0400
In-Reply-To: <200703262321.l2QNLZlR014240@faith.austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Some time ago this thread bounced back and forth and seemed to come to
rest with the patch below, I cleaned up the comments and put all the
ACKs it received in one place below, but so much time has passed I doubt
if they should still count for free.  I also rediffed the patch against
the latest miller tree.  Is the idea or patch in any way flawed or
unacceptable to people at the moment?

Anyone willing to step up an re-ack the patch to get it moving into the
tree?

-Eric

Currently we check for permission before deleting entries from SAD and
SPD, (see security_xfrm_policy_delete() security_xfrm_state_delete())
However we are not checking for authorization when flushing the SPD and
the SAD completely. It was perhaps missed in the original security hooks
patch.

This patch adds a security check when flushing entries from the SAD and
SPD.  It runs the entire database and checks each entry for a denial.
If the process attempting the flush is unable to remove all of the
entries a denial is logged the the flush function returns an error
without removing anything.

This is particularly useful when a process may need to create or delete
its own xfrm entries used for things like labeled networking but that
same process should not be able to delete other entries or flush the
entire database.

WAS Signed-off-by: Signed-off-by: Joy Latten<latten@austin.ibm.com> NOT NOW
WAS Acked-by: James Morris <jmorris@namei.org> NOT NOW
WAS Acked-by: Eric Paris <eparis@parisplace.org> NOT NOW

---

 include/net/xfrm.h     |    6 ++--
 net/key/af_key.c       |   10 ++++++-
 net/xfrm/xfrm_policy.c |   63 +++++++++++++++++++++++++++++++++++++++++++++--
 net/xfrm/xfrm_state.c  |   46 ++++++++++++++++++++++++++++++++--
 net/xfrm/xfrm_user.c   |    9 +++++-
 5 files changed, 121 insertions(+), 13 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 90185e8..311f25a 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -964,7 +964,7 @@ struct xfrmk_spdinfo {
 
 extern struct xfrm_state *xfrm_find_acq_byseq(u32 seq);
 extern int xfrm_state_delete(struct xfrm_state *x);
-extern void xfrm_state_flush(u8 proto, struct xfrm_audit *audit_info);
+extern int xfrm_state_flush(u8 proto, struct xfrm_audit *audit_info);
 extern void xfrm_sad_getinfo(struct xfrmk_sadinfo *si);
 extern void xfrm_spd_getinfo(struct xfrmk_spdinfo *si);
 extern int xfrm_replay_check(struct xfrm_state *x, __be32 seq);
@@ -1020,13 +1020,13 @@ struct xfrm_policy *xfrm_policy_bysel_ctx(u8 type, int dir,
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
diff --git a/net/key/af_key.c b/net/key/af_key.c
index d302dda..0f8304b 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -1682,6 +1682,7 @@ static int pfkey_flush(struct sock *sk, struct sk_buff *skb, struct sadb_msg *hd
 	unsigned proto;
 	struct km_event c;
 	struct xfrm_audit audit_info;
+	int err;
 
 	proto = pfkey_satype2proto(hdr->sadb_msg_satype);
 	if (proto == 0)
@@ -1689,7 +1690,9 @@ static int pfkey_flush(struct sock *sk, struct sk_buff *skb, struct sadb_msg *hd
 
 	audit_info.loginuid = audit_get_loginuid(current->audit_context);
 	audit_info.secid = 0;
-	xfrm_state_flush(proto, &audit_info);
+	err = xfrm_state_flush(proto, &audit_info);
+	if (err)
+		return err;
 	c.data.proto = proto;
 	c.seq = hdr->sadb_msg_seq;
 	c.pid = hdr->sadb_msg_pid;
@@ -2683,10 +2686,13 @@ static int pfkey_spdflush(struct sock *sk, struct sk_buff *skb, struct sadb_msg
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
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 64a3751..157bfbd 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -834,11 +834,67 @@ struct xfrm_policy *xfrm_policy_byid(u8 type, int dir, u32 id, int delete,
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
@@ -891,7 +947,9 @@ void xfrm_policy_flush(u8 type, struct xfrm_audit *audit_info)
 		xfrm_policy_count[dir] -= killed;
 	}
 	atomic_inc(&flow_cache_genid);
+out:
 	write_unlock_bh(&xfrm_policy_lock);
+	return err;
 }
 EXPORT_SYMBOL(xfrm_policy_flush);
 
@@ -2583,4 +2641,3 @@ restore_state:
 }
 EXPORT_SYMBOL(xfrm_migrate);
 #endif
-
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 372f06e..2cc9d87 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -391,12 +391,48 @@ int xfrm_state_delete(struct xfrm_state *x)
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
@@ -419,8 +455,12 @@ restart:
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
 
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index b14c7e5..c06883b 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -1418,10 +1418,13 @@ static int xfrm_flush_sa(struct sk_buff *skb, struct nlmsghdr *nlh,
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
@@ -1582,7 +1585,9 @@ static int xfrm_flush_policy(struct sk_buff *skb, struct nlmsghdr *nlh,
 
 	audit_info.loginuid = NETLINK_CB(skb).loginuid;
 	audit_info.secid = NETLINK_CB(skb).sid;
-	xfrm_policy_flush(type, &audit_info);
+	err = xfrm_policy_flush(type, &audit_info);
+	if (err)
+		return err;
 	c.data.type = type;
 	c.event = nlh->nlmsg_type;
 	c.seq = nlh->nlmsg_seq;


