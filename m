From: Joe Stringer <joe@ovn.org>
Subject: [PATCH net 1/2] openvswitch: Fix helper reference leak
Date: Wed,  9 Dec 2015 14:07:39 -0800
Message-ID: <1449698860-20685-1-git-send-email-joe@ovn.org>
Cc: Joe Stringer <joe@ovn.org>, pshelar@nicira.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2-d.mail.gandi.net ([217.70.183.194]:38395 "EHLO
	relay2-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751261AbbLIWH4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Dec 2015 17:07:56 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the actions (re)allocation fails, or the actions list is larger than the
maximum size, and the conntrack action is the last action when these
problems are hit, then references to helper modules may be leaked. Fix
the issue.

Fixes: cae3a2627520 ("openvswitch: Allow attaching helpers to ct action")
Signed-off-by: Joe Stringer <joe@ovn.org>
---
 net/openvswitch/conntrack.c | 9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/net/openvswitch/conntrack.c b/net/openvswitch/conntrack.c
index c2cc11168fd5..585a5aa81f89 100644
--- a/net/openvswitch/conntrack.c
+++ b/net/openvswitch/conntrack.c
@@ -53,6 +53,8 @@ struct ovs_conntrack_info {
 	struct md_labels labels;
 };
 
+static void __ovs_ct_free_action(struct ovs_conntrack_info *ct_info);
+
 static u16 key_to_nfproto(const struct sw_flow_key *key)
 {
 	switch (ntohs(key->eth.type)) {
@@ -708,7 +710,7 @@ int ovs_ct_copy_action(struct net *net, const struct nlattr *attr,
 	nf_conntrack_get(&ct_info.ct->ct_general);
 	return 0;
 err_free_ct:
-	nf_conntrack_free(ct_info.ct);
+	__ovs_ct_free_action(&ct_info);
 	return err;
 }
 
@@ -750,6 +752,11 @@ void ovs_ct_free_action(const struct nlattr *a)
 {
 	struct ovs_conntrack_info *ct_info = nla_data(a);
 
+	__ovs_ct_free_action(ct_info);
+}
+
+static void __ovs_ct_free_action(struct ovs_conntrack_info *ct_info)
+{
 	if (ct_info->helper)
 		module_put(ct_info->helper->me);
 	if (ct_info->ct)
-- 
2.1.4
