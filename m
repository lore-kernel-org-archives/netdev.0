From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 46/53] netns xfrm: flush SA/SPDs on netns stop
Date: Tue, 25 Nov 2008 20:27:18 +0300
Message-ID: <1227634045-27534-46-git-send-email-adobriyan@gmail.com>
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
 <1227634045-27534-31-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-32-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-33-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-34-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-35-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-36-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-37-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-38-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-39-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-40-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-41-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-42-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-43-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-44-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-45-git-send-email-adobriyan@gmail.com>
Cc: herbert@gondor.apana.org.au, kuznet@ms2.inr.ac.ru,
	netdev@vger.kernel.org, containers@lists.linux-foundation.org,
	Alexey Dobriyan <adobriyan@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.190]:3932 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754499AbYKYRZe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2008 12:25:34 -0500
Received: by nf-out-0910.google.com with SMTP id d3so28136nfc.21
        for <netdev@vger.kernel.org>; Tue, 25 Nov 2008 09:25:32 -0800 (PST)
In-Reply-To: <1227634045-27534-45-git-send-email-adobriyan@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SA/SPD doesn't pin netns (and it shouldn't), so get rid of them by hand.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---
 net/xfrm/xfrm_policy.c |   14 ++++++++++++++
 net/xfrm/xfrm_state.c  |    8 ++++++++
 2 files changed, 22 insertions(+), 0 deletions(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 7c7bb54..fcf8c92 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -2441,9 +2441,23 @@ out_byidx:
 
 static void xfrm_policy_fini(struct net *net)
 {
+	struct xfrm_audit audit_info;
 	unsigned int sz;
 	int dir;
 
+	flush_work(&net->xfrm.policy_hash_work);
+#ifdef CONFIG_XFRM_SUB_POLICY
+	audit_info.loginuid = -1;
+	audit_info.sessionid = -1;
+	audit_info.secid = 0;
+	xfrm_policy_flush(net, XFRM_POLICY_TYPE_SUB, &audit_info);
+#endif
+	audit_info.loginuid = -1;
+	audit_info.sessionid = -1;
+	audit_info.secid = 0;
+	xfrm_policy_flush(net, XFRM_POLICY_TYPE_MAIN, &audit_info);
+	flush_work(&xfrm_policy_gc_work);
+
 	WARN_ON(!list_empty(&net->xfrm.policy_all));
 
 	for (dir = 0; dir < XFRM_POLICY_MAX * 2; dir++) {
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index d594b5a..662e47b 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -2114,8 +2114,16 @@ out_bydst:
 
 void xfrm_state_fini(struct net *net)
 {
+	struct xfrm_audit audit_info;
 	unsigned int sz;
 
+	flush_work(&net->xfrm.state_hash_work);
+	audit_info.loginuid = -1;
+	audit_info.sessionid = -1;
+	audit_info.secid = 0;
+	xfrm_state_flush(net, IPSEC_PROTO_ANY, &audit_info);
+	flush_work(&net->xfrm.state_gc_work);
+
 	WARN_ON(!list_empty(&net->xfrm.state_all));
 
 	sz = (net->xfrm.state_hmask + 1) * sizeof(struct hlist_head);
-- 
1.5.6.5

