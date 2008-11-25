From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 31/53] netns xfrm: policy flushing in netns
Date: Tue, 25 Nov 2008 20:27:03 +0300
Message-ID: <1227634045-27534-31-git-send-email-adobriyan@gmail.com>
References: <1227634045-27534-1-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-2-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-3-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-4-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-5-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-6-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-7-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-8-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-9-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-10-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-11-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-12-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-13-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-14-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-15-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-16-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-17-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-18-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-19-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-20-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-21-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-22-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-23-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-24-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-25-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-26-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-27-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-28-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-29-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-30-git-send-email-adobriyan@gmail.com>
Cc: herbert@gondor.apana.org.au, kuznet@ms2.inr.ac.ru,
	netdev@vger.kernel.org, containers@lists.linux-foundation.org,
	Alexey Dobriyan <adobriyan@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.184]:4839 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753889AbYKYRYw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2008 12:24:52 -0500
Received: by nf-out-0910.google.com with SMTP id d3so28104nfc.21
        for <netdev@vger.kernel.org>; Tue, 25 Nov 2008 09:24:52 -0800 (PST)
In-Reply-To: <1227634045-27534-30-git-send-email-adobriyan@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---
 include/net/xfrm.h     |    2 +-
 net/key/af_key.c       |    2 +-
 net/xfrm/xfrm_policy.c |   22 +++++++++++-----------
 net/xfrm/xfrm_user.c   |    2 +-
 4 files changed, 14 insertions(+), 14 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 40ed487..766cc71 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -1444,7 +1444,7 @@ struct xfrm_policy *xfrm_policy_bysel_ctx(u8 type, int dir,
 					  struct xfrm_sec_ctx *ctx, int delete,
 					  int *err);
 struct xfrm_policy *xfrm_policy_byid(u8, int dir, u32 id, int delete, int *err);
-int xfrm_policy_flush(u8 type, struct xfrm_audit *audit_info);
+int xfrm_policy_flush(struct net *net, u8 type, struct xfrm_audit *audit_info);
 u32 xfrm_get_acqseq(void);
 extern int xfrm_alloc_spi(struct xfrm_state *x, u32 minspi, u32 maxspi);
 struct xfrm_state * xfrm_find_acq(struct net *net, u8 mode, u32 reqid, u8 proto,
diff --git a/net/key/af_key.c b/net/key/af_key.c
index b74d939..0f44856 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -2686,7 +2686,7 @@ static int pfkey_spdflush(struct sock *sk, struct sk_buff *skb, struct sadb_msg
 	audit_info.loginuid = audit_get_loginuid(current);
 	audit_info.sessionid = audit_get_sessionid(current);
 	audit_info.secid = 0;
-	err = xfrm_policy_flush(XFRM_POLICY_TYPE_MAIN, &audit_info);
+	err = xfrm_policy_flush(&init_net, XFRM_POLICY_TYPE_MAIN, &audit_info);
 	if (err)
 		return err;
 	c.data.type = XFRM_POLICY_TYPE_MAIN;
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 11fee87..7c264a7 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -732,7 +732,7 @@ EXPORT_SYMBOL(xfrm_policy_byid);
 
 #ifdef CONFIG_SECURITY_NETWORK_XFRM
 static inline int
-xfrm_policy_flush_secctx_check(u8 type, struct xfrm_audit *audit_info)
+xfrm_policy_flush_secctx_check(struct net *net, u8 type, struct xfrm_audit *audit_info)
 {
 	int dir, err = 0;
 
@@ -742,7 +742,7 @@ xfrm_policy_flush_secctx_check(u8 type, struct xfrm_audit *audit_info)
 		int i;
 
 		hlist_for_each_entry(pol, entry,
-				     &init_net.xfrm.policy_inexact[dir], bydst) {
+				     &net->xfrm.policy_inexact[dir], bydst) {
 			if (pol->type != type)
 				continue;
 			err = security_xfrm_policy_delete(pol->security);
@@ -754,9 +754,9 @@ xfrm_policy_flush_secctx_check(u8 type, struct xfrm_audit *audit_info)
 				return err;
 			}
 		}
-		for (i = init_net.xfrm.policy_bydst[dir].hmask; i >= 0; i--) {
+		for (i = net->xfrm.policy_bydst[dir].hmask; i >= 0; i--) {
 			hlist_for_each_entry(pol, entry,
-					     init_net.xfrm.policy_bydst[dir].table + i,
+					     net->xfrm.policy_bydst[dir].table + i,
 					     bydst) {
 				if (pol->type != type)
 					continue;
@@ -776,19 +776,19 @@ xfrm_policy_flush_secctx_check(u8 type, struct xfrm_audit *audit_info)
 }
 #else
 static inline int
-xfrm_policy_flush_secctx_check(u8 type, struct xfrm_audit *audit_info)
+xfrm_policy_flush_secctx_check(struct net *net, u8 type, struct xfrm_audit *audit_info)
 {
 	return 0;
 }
 #endif
 
-int xfrm_policy_flush(u8 type, struct xfrm_audit *audit_info)
+int xfrm_policy_flush(struct net *net, u8 type, struct xfrm_audit *audit_info)
 {
 	int dir, err = 0;
 
 	write_lock_bh(&xfrm_policy_lock);
 
-	err = xfrm_policy_flush_secctx_check(type, audit_info);
+	err = xfrm_policy_flush_secctx_check(net, type, audit_info);
 	if (err)
 		goto out;
 
@@ -800,7 +800,7 @@ int xfrm_policy_flush(u8 type, struct xfrm_audit *audit_info)
 		killed = 0;
 	again1:
 		hlist_for_each_entry(pol, entry,
-				     &init_net.xfrm.policy_inexact[dir], bydst) {
+				     &net->xfrm.policy_inexact[dir], bydst) {
 			if (pol->type != type)
 				continue;
 			hlist_del(&pol->bydst);
@@ -818,10 +818,10 @@ int xfrm_policy_flush(u8 type, struct xfrm_audit *audit_info)
 			goto again1;
 		}
 
-		for (i = init_net.xfrm.policy_bydst[dir].hmask; i >= 0; i--) {
+		for (i = net->xfrm.policy_bydst[dir].hmask; i >= 0; i--) {
 	again2:
 			hlist_for_each_entry(pol, entry,
-					     init_net.xfrm.policy_bydst[dir].table + i,
+					     net->xfrm.policy_bydst[dir].table + i,
 					     bydst) {
 				if (pol->type != type)
 					continue;
@@ -842,7 +842,7 @@ int xfrm_policy_flush(u8 type, struct xfrm_audit *audit_info)
 			}
 		}
 
-		init_net.xfrm.policy_count[dir] -= killed;
+		net->xfrm.policy_count[dir] -= killed;
 	}
 	atomic_inc(&flow_cache_genid);
 out:
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 787b0ee..d4983e8 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -1546,7 +1546,7 @@ static int xfrm_flush_policy(struct sk_buff *skb, struct nlmsghdr *nlh,
 	audit_info.loginuid = NETLINK_CB(skb).loginuid;
 	audit_info.sessionid = NETLINK_CB(skb).sessionid;
 	audit_info.secid = NETLINK_CB(skb).sid;
-	err = xfrm_policy_flush(type, &audit_info);
+	err = xfrm_policy_flush(&init_net, type, &audit_info);
 	if (err)
 		return err;
 	c.data.type = type;
-- 
1.5.6.5

