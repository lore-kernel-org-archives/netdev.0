From: Joe Stringer <joestringer@nicira.com>
Subject: [PATCH net 1/3] openvswitch: Fix double-free on ip_defrag() errors
Date: Fri, 23 Oct 2015 16:01:49 -0700
Message-ID: <1445641311-63081-1-git-send-email-joestringer@nicira.com>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	Andy Zhou <azhou@nicira.com>
To: netdev@vger.kernel.org, Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:34661 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751301AbbJWXCA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2015 19:02:00 -0400
Received: by padhk11 with SMTP id hk11so129891016pad.1
        for <netdev@vger.kernel.org>; Fri, 23 Oct 2015 16:02:00 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If ip_defrag() returns an error other than -EINPROGRESS, then the skb is
freed. When handle_fragments() passes this back up to
do_execute_actions(), it will be freed again. Prevent this double free
by always freeing the skb in ovs_ct_execute() if an error occurs.

Fixes: 7f8a436eaa2c ("openvswitch: Add conntrack action")
Reported-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Joe Stringer <joestringer@nicira.com>
---
 net/openvswitch/actions.c   |  4 ++--
 net/openvswitch/conntrack.c | 18 ++++++++++++++----
 net/openvswitch/conntrack.h |  1 +
 3 files changed, 17 insertions(+), 6 deletions(-)

diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
index c6a39bf2c3b9..92c021a84cd5 100644
--- a/net/openvswitch/actions.c
+++ b/net/openvswitch/actions.c
@@ -1112,8 +1112,8 @@ static int do_execute_actions(struct datapath *dp, struct sk_buff *skb,
 					     nla_data(a));
 
 			/* Hide stolen IP fragments from user space. */
-			if (err == -EINPROGRESS)
-				return 0;
+			if (err)
+				return err == -EINPROGRESS ? 0 : err;
 			break;
 		}
 
diff --git a/net/openvswitch/conntrack.c b/net/openvswitch/conntrack.c
index 80bf702715bb..6d907f913c8b 100644
--- a/net/openvswitch/conntrack.c
+++ b/net/openvswitch/conntrack.c
@@ -294,6 +294,9 @@ static int ovs_ct_helper(struct sk_buff *skb, u16 proto)
 	return helper->help(skb, protoff, ct, ctinfo);
 }
 
+/* Returns 0 on success, -EINPROGRESS if 'skb' is stolen, or other nonzero
+ * value if 'skb' is freed.
+ */
 static int handle_fragments(struct net *net, struct sw_flow_key *key,
 			    u16 zone, struct sk_buff *skb)
 {
@@ -304,13 +307,14 @@ static int handle_fragments(struct net *net, struct sw_flow_key *key,
 		int err;
 
 		memset(IPCB(skb), 0, sizeof(struct inet_skb_parm));
+
 		err = ip_defrag(skb, user);
 		if (err)
 			return err;
 
 		ovs_cb.mru = IPCB(skb)->frag_max_size;
-	} else if (key->eth.type == htons(ETH_P_IPV6)) {
 #if IS_ENABLED(CONFIG_NF_DEFRAG_IPV6)
+	} else if (key->eth.type == htons(ETH_P_IPV6)) {
 		enum ip6_defrag_users user = IP6_DEFRAG_CONNTRACK_IN + zone;
 		struct sk_buff *reasm;
 
@@ -319,17 +323,18 @@ static int handle_fragments(struct net *net, struct sw_flow_key *key,
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
 
@@ -476,6 +481,9 @@ static bool labels_nonzero(const struct ovs_key_ct_labels *labels)
 	return false;
 }
 
+/* Returns 0 on success, -EINPROGRESS if 'skb' is stolen, or other nonzero
+ * value if 'skb' is freed.
+ */
 int ovs_ct_execute(struct net *net, struct sk_buff *skb,
 		   struct sw_flow_key *key,
 		   const struct ovs_conntrack_info *info)
@@ -510,6 +518,8 @@ int ovs_ct_execute(struct net *net, struct sk_buff *skb,
 		err = ovs_ct_set_labels(skb, key, &info->labels.value,
 					&info->labels.mask);
 err:
+	if (err)
+		kfree_skb(skb);
 	skb_push(skb, nh_ofs);
 	return err;
 }
diff --git a/net/openvswitch/conntrack.h b/net/openvswitch/conntrack.h
index da8714942c95..a1501efdc56e 100644
--- a/net/openvswitch/conntrack.h
+++ b/net/openvswitch/conntrack.h
@@ -75,6 +75,7 @@ static inline int ovs_ct_execute(struct net *net, struct sk_buff *skb,
 				 struct sw_flow_key *key,
 				 const struct ovs_conntrack_info *info)
 {
+	kfree_skb(skb);
 	return -ENOTSUPP;
 }
 
-- 
2.1.4
