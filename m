From: Joe Stringer <joestringer@nicira.com>
Subject: [PATCHv3 net 1/3] openvswitch: Fix double-free on ip_defrag() errors
Date: Sun, 25 Oct 2015 20:21:48 -0700
Message-ID: <1445829710-11292-1-git-send-email-joestringer@nicira.com>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	Andy Zhou <azhou@nicira.com>
To: netdev@vger.kernel.org, Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:35235 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752644AbbJZDVz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Oct 2015 23:21:55 -0400
Received: by pasz6 with SMTP id z6so173633487pas.2
        for <netdev@vger.kernel.org>; Sun, 25 Oct 2015 20:21:54 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If ip_defrag() returns an error other than -EINPROGRESS, then the skb is
freed. When handle_fragments() passes this back up to
do_execute_actions(), it will be freed again. Prevent this double free
by never freeing the skb in do_execute_actions() for errors returned by
ovs_ct_execute. Always free it in ovs_ct_execute() error paths instead.

Fixes: 7f8a436eaa2c ("openvswitch: Add conntrack action")
Reported-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Joe Stringer <joestringer@nicira.com>
---
v2: Remove extraneous whitespace change.
v3: Push skb before checking error to free
---
 net/openvswitch/actions.c   |  4 ++--
 net/openvswitch/conntrack.c | 17 +++++++++++++----
 net/openvswitch/conntrack.h |  1 +
 3 files changed, 16 insertions(+), 6 deletions(-)

diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
index 0bf0f406de52..dba635d086b2 100644
--- a/net/openvswitch/actions.c
+++ b/net/openvswitch/actions.c
@@ -1109,8 +1109,8 @@ static int do_execute_actions(struct datapath *dp, struct sk_buff *skb,
 					     nla_data(a));
 
 			/* Hide stolen IP fragments from user space. */
-			if (err == -EINPROGRESS)
-				return 0;
+			if (err)
+				return err == -EINPROGRESS ? 0 : err;
 			break;
 		}
 
diff --git a/net/openvswitch/conntrack.c b/net/openvswitch/conntrack.c
index a5ec34f8502f..b5dcc0abde66 100644
--- a/net/openvswitch/conntrack.c
+++ b/net/openvswitch/conntrack.c
@@ -293,6 +293,9 @@ static int ovs_ct_helper(struct sk_buff *skb, u16 proto)
 	return helper->help(skb, protoff, ct, ctinfo);
 }
 
+/* Returns 0 on success, -EINPROGRESS if 'skb' is stolen, or other nonzero
+ * value if 'skb' is freed.
+ */
 static int handle_fragments(struct net *net, struct sw_flow_key *key,
 			    u16 zone, struct sk_buff *skb)
 {
@@ -308,8 +311,8 @@ static int handle_fragments(struct net *net, struct sw_flow_key *key,
 			return err;
 
 		ovs_cb.mru = IPCB(skb)->frag_max_size;
-	} else if (key->eth.type == htons(ETH_P_IPV6)) {
 #if IS_ENABLED(CONFIG_NF_DEFRAG_IPV6)
+	} else if (key->eth.type == htons(ETH_P_IPV6)) {
 		enum ip6_defrag_users user = IP6_DEFRAG_CONNTRACK_IN + zone;
 		struct sk_buff *reasm;
 
@@ -318,17 +321,18 @@ static int handle_fragments(struct net *net, struct sw_flow_key *key,
 		if (!reasm)
 			return -EINPROGRESS;
 
-		if (skb == reasm)
+		if (skb == reasm) {
+			kfree_skb(skb);
 			return -EINVAL;
+		}
 
 		key->ip.proto = ipv6_hdr(reasm)->nexthdr;
 		skb_morph(skb, reasm);
 		consume_skb(reasm);
 		ovs_cb.mru = IP6CB(skb)->frag_max_size;
-#else
-		return -EPFNOSUPPORT;
 #endif
 	} else {
+		kfree_skb(skb);
 		return -EPFNOSUPPORT;
 	}
 
@@ -473,6 +477,9 @@ static bool labels_nonzero(const struct ovs_key_ct_labels *labels)
 	return false;
 }
 
+/* Returns 0 on success, -EINPROGRESS if 'skb' is stolen, or other nonzero
+ * value if 'skb' is freed.
+ */
 int ovs_ct_execute(struct net *net, struct sk_buff *skb,
 		   struct sw_flow_key *key,
 		   const struct ovs_conntrack_info *info)
@@ -508,6 +515,8 @@ int ovs_ct_execute(struct net *net, struct sk_buff *skb,
 					&info->labels.mask);
 err:
 	skb_push(skb, nh_ofs);
+	if (err)
+		kfree_skb(skb);
 	return err;
 }
 
diff --git a/net/openvswitch/conntrack.h b/net/openvswitch/conntrack.h
index 82e0dfc66028..a7544f405c16 100644
--- a/net/openvswitch/conntrack.h
+++ b/net/openvswitch/conntrack.h
@@ -67,6 +67,7 @@ static inline int ovs_ct_execute(struct net *net, struct sk_buff *skb,
 				 struct sw_flow_key *key,
 				 const struct ovs_conntrack_info *info)
 {
+	kfree_skb(skb);
 	return -ENOTSUPP;
 }
 
-- 
2.1.4
