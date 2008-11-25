From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 24/53] netns xfrm: state flush in netns
Date: Tue, 25 Nov 2008 20:26:56 +0300
Message-ID: <1227634045-27534-24-git-send-email-adobriyan@gmail.com>
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
Cc: herbert@gondor.apana.org.au, kuznet@ms2.inr.ac.ru,
	netdev@vger.kernel.org, containers@lists.linux-foundation.org,
	Alexey Dobriyan <adobriyan@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ik-out-1112.google.com ([66.249.90.178]:32462 "EHLO
	ik-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753923AbYKYRYf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2008 12:24:35 -0500
Received: by ik-out-1112.google.com with SMTP id c29so47248ika.5
        for <netdev@vger.kernel.org>; Tue, 25 Nov 2008 09:24:34 -0800 (PST)
In-Reply-To: <1227634045-27534-23-git-send-email-adobriyan@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---
 include/net/xfrm.h    |    2 +-
 net/key/af_key.c      |    2 +-
 net/xfrm/xfrm_state.c |   18 +++++++++---------
 net/xfrm/xfrm_user.c  |    2 +-
 4 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 8699620..e4bb672 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -1363,7 +1363,7 @@ struct xfrmk_spdinfo {
 
 extern struct xfrm_state *xfrm_find_acq_byseq(u32 seq);
 extern int xfrm_state_delete(struct xfrm_state *x);
-extern int xfrm_state_flush(u8 proto, struct xfrm_audit *audit_info);
+extern int xfrm_state_flush(struct net *net, u8 proto, struct xfrm_audit *audit_info);
 extern void xfrm_sad_getinfo(struct xfrmk_sadinfo *si);
 extern void xfrm_spd_getinfo(struct xfrmk_spdinfo *si);
 extern int xfrm_replay_check(struct xfrm_state *x,
diff --git a/net/key/af_key.c b/net/key/af_key.c
index 036315d..e5d595a 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -1732,7 +1732,7 @@ static int pfkey_flush(struct sock *sk, struct sk_buff *skb, struct sadb_msg *hd
 	audit_info.loginuid = audit_get_loginuid(current);
 	audit_info.sessionid = audit_get_sessionid(current);
 	audit_info.secid = 0;
-	err = xfrm_state_flush(proto, &audit_info);
+	err = xfrm_state_flush(&init_net, proto, &audit_info);
 	if (err)
 		return err;
 	c.data.proto = proto;
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index f3f635d..5f4c534 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -576,15 +576,15 @@ EXPORT_SYMBOL(xfrm_state_delete);
 
 #ifdef CONFIG_SECURITY_NETWORK_XFRM
 static inline int
-xfrm_state_flush_secctx_check(u8 proto, struct xfrm_audit *audit_info)
+xfrm_state_flush_secctx_check(struct net *net, u8 proto, struct xfrm_audit *audit_info)
 {
 	int i, err = 0;
 
-	for (i = 0; i <= init_net.xfrm.state_hmask; i++) {
+	for (i = 0; i <= net->xfrm.state_hmask; i++) {
 		struct hlist_node *entry;
 		struct xfrm_state *x;
 
-		hlist_for_each_entry(x, entry, init_net.xfrm.state_bydst+i, bydst) {
+		hlist_for_each_entry(x, entry, net->xfrm.state_bydst+i, bydst) {
 			if (xfrm_id_proto_match(x->id.proto, proto) &&
 			   (err = security_xfrm_state_delete(x)) != 0) {
 				xfrm_audit_state_delete(x, 0,
@@ -600,26 +600,26 @@ xfrm_state_flush_secctx_check(u8 proto, struct xfrm_audit *audit_info)
 }
 #else
 static inline int
-xfrm_state_flush_secctx_check(u8 proto, struct xfrm_audit *audit_info)
+xfrm_state_flush_secctx_check(struct net *net, u8 proto, struct xfrm_audit *audit_info)
 {
 	return 0;
 }
 #endif
 
-int xfrm_state_flush(u8 proto, struct xfrm_audit *audit_info)
+int xfrm_state_flush(struct net *net, u8 proto, struct xfrm_audit *audit_info)
 {
 	int i, err = 0;
 
 	spin_lock_bh(&xfrm_state_lock);
-	err = xfrm_state_flush_secctx_check(proto, audit_info);
+	err = xfrm_state_flush_secctx_check(net, proto, audit_info);
 	if (err)
 		goto out;
 
-	for (i = 0; i <= init_net.xfrm.state_hmask; i++) {
+	for (i = 0; i <= net->xfrm.state_hmask; i++) {
 		struct hlist_node *entry;
 		struct xfrm_state *x;
 restart:
-		hlist_for_each_entry(x, entry, init_net.xfrm.state_bydst+i, bydst) {
+		hlist_for_each_entry(x, entry, net->xfrm.state_bydst+i, bydst) {
 			if (!xfrm_state_kern(x) &&
 			    xfrm_id_proto_match(x->id.proto, proto)) {
 				xfrm_state_hold(x);
@@ -641,7 +641,7 @@ restart:
 
 out:
 	spin_unlock_bh(&xfrm_state_lock);
-	wake_up(&init_net.xfrm.km_waitq);
+	wake_up(&net->xfrm.km_waitq);
 	return err;
 }
 EXPORT_SYMBOL(xfrm_state_flush);
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 765c01e..49a7e89 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -1398,7 +1398,7 @@ static int xfrm_flush_sa(struct sk_buff *skb, struct nlmsghdr *nlh,
 	audit_info.loginuid = NETLINK_CB(skb).loginuid;
 	audit_info.sessionid = NETLINK_CB(skb).sessionid;
 	audit_info.secid = NETLINK_CB(skb).sid;
-	err = xfrm_state_flush(p->proto, &audit_info);
+	err = xfrm_state_flush(&init_net, p->proto, &audit_info);
 	if (err)
 		return err;
 	c.data.proto = p->proto;
-- 
1.5.6.5

