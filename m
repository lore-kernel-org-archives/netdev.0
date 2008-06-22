From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 17/25] netns ct: undo protocol in all netns
Date: Sun, 22 Jun 2008 05:15:14 +0400
Message-ID: <20080622011514.GS5392@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	den@openvz.org, xemul@openvz.org, ebiederm@xmission.com,
	benjamin.thery@bull.net, dlezcano@fr.ibm.com
To: kaber@trash.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Again, locking aroung netns list is most certainly broken.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 net/netfilter/nf_conntrack_proto.c |   10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

--- a/net/netfilter/nf_conntrack_proto.c
+++ b/net/netfilter/nf_conntrack_proto.c
@@ -207,6 +207,8 @@ EXPORT_SYMBOL_GPL(nf_conntrack_l3proto_register);
 
 void nf_conntrack_l3proto_unregister(struct nf_conntrack_l3proto *proto)
 {
+	struct net *net;
+
 	BUG_ON(proto->l3proto >= AF_MAX);
 
 	mutex_lock(&nf_ct_proto_mutex);
@@ -219,7 +221,8 @@ void nf_conntrack_l3proto_unregister(struct nf_conntrack_l3proto *proto)
 	synchronize_rcu();
 
 	/* Remove all contrack entries for this protocol */
-	nf_ct_iterate_cleanup(&init_net, kill_l3proto, proto);
+	for_each_net(net)
+		nf_ct_iterate_cleanup(net, kill_l3proto, proto);
 }
 EXPORT_SYMBOL_GPL(nf_conntrack_l3proto_unregister);
 
@@ -316,6 +319,8 @@ EXPORT_SYMBOL_GPL(nf_conntrack_l4proto_register);
 
 void nf_conntrack_l4proto_unregister(struct nf_conntrack_l4proto *l4proto)
 {
+	struct net *net;
+
 	BUG_ON(l4proto->l3proto >= PF_MAX);
 
 	mutex_lock(&nf_ct_proto_mutex);
@@ -328,7 +333,8 @@ void nf_conntrack_l4proto_unregister(struct nf_conntrack_l4proto *l4proto)
 	synchronize_rcu();
 
 	/* Remove all contrack entries for this protocol */
-	nf_ct_iterate_cleanup(&init_net, kill_l4proto, l4proto);
+	for_each_net(net)
+		nf_ct_iterate_cleanup(net, kill_l4proto, l4proto);
 }
 EXPORT_SYMBOL_GPL(nf_conntrack_l4proto_unregister);
 
-- 
1.5.4.5


