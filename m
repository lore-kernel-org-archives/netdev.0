From: Joe Stringer <joe@ovn.org>
Subject: [PATCH net] openvswitch: Fix template leak in error cases.
Date: Wed, 23 Dec 2015 14:39:27 -0800
Message-ID: <1450910367-61953-1-git-send-email-joe@ovn.org>
Cc: Joe Stringer <joe@ovn.org>, linux-kernel@vger.kernel.org,
	pshelar@nicira.com
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commit 5b48bb8506c5 ("openvswitch: Fix helper reference leak") fixed a
reference leak on helper objects, but inadvertently introduced a leak on
the ct template.

Previously, ct_info.ct->general.use was initialized to 0 by
nf_ct_tmpl_alloc() and only incremented when ovs_ct_copy_action()
returned successful. If an error occurred while adding the helper or
adding the action to the actions buffer, the __ovs_ct_free_action()
cleanup would use nf_ct_put() to free the entry; However, this relies on
atomic_dec_and_test(ct_info.ct->general.use). This reference must be
incremented first, or nf_ct_put() will never free it.

Fix the issue by acquiring a reference to the template immediately after
allocation.

Fixes: cae3a2627520 ("openvswitch: Allow attaching helpers to ct action")
Fixes: 5b48bb8506c5 ("openvswitch: Fix helper reference leak")
Signed-off-by: Joe Stringer <joe@ovn.org>
---
 net/openvswitch/conntrack.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/openvswitch/conntrack.c b/net/openvswitch/conntrack.c
index 8fc1bafc99fd..c6d8738d6970 100644
--- a/net/openvswitch/conntrack.c
+++ b/net/openvswitch/conntrack.c
@@ -683,6 +683,10 @@ int ovs_ct_copy_action(struct net *net, const struct nlattr *attr,
 		OVS_NLERR(log, "Failed to allocate conntrack template");
 		return -ENOMEM;
 	}
+
+	__set_bit(IPS_CONFIRMED_BIT, &ct_info.ct->status);
+	nf_conntrack_get(&ct_info.ct->ct_general);
+
 	if (helper) {
 		err = ovs_ct_add_helper(&ct_info, helper, key, log);
 		if (err)
@@ -694,8 +698,6 @@ int ovs_ct_copy_action(struct net *net, const struct nlattr *attr,
 	if (err)
 		goto err_free_ct;
 
-	__set_bit(IPS_CONFIRMED_BIT, &ct_info.ct->status);
-	nf_conntrack_get(&ct_info.ct->ct_general);
 	return 0;
 err_free_ct:
 	__ovs_ct_free_action(&ct_info);
-- 
2.1.4
