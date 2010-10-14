From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] netns: reorder fields in struct net
Date: Thu, 14 Oct 2010 17:56:18 +0200
Message-ID: <1287071778.2712.73.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f47.google.com ([74.125.82.47]:58501 "EHLO
	mail-ww0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755268Ab0JNP4Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Oct 2010 11:56:24 -0400
Received: by wwf26 with SMTP id 26so9292059wwf.4
        for <netdev@vger.kernel.org>; Thu, 14 Oct 2010 08:56:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In a network bench, I noticed an unfortunate false sharing between
'loopback_dev' and 'count' fields in "struct net".

'count' is written each time a socket is created or destroyed, while
loopback_dev might be often read in routing code.

Move loopback_dev in a read mostly section of "struct net"

Note: struct netns_xfrm is cache line aligned on SMP.
(It contains a "struct dst_ops")
Move it at the end to avoid holes, and reduce sizeof(struct net) by 128
bytes on ia32.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/net/net_namespace.h |   17 ++++++++++-------
 include/net/netns/xfrm.h    |    9 +++++----
 2 files changed, 15 insertions(+), 11 deletions(-)

diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
index bd10a79..65af9a0 100644
--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -41,6 +41,8 @@ struct net {
 						 * destroy on demand
 						 */
 #endif
+	spinlock_t		rules_mod_lock;
+
 	struct list_head	list;		/* list of network namespaces */
 	struct list_head	cleanup_list;	/* namespaces on death row */
 	struct list_head	exit_list;	/* Use only net_mutex */
@@ -52,7 +54,8 @@ struct net {
 	struct ctl_table_set	sysctls;
 #endif
 
-	struct net_device       *loopback_dev;          /* The loopback */
+	struct sock 		*rtnl;			/* rtnetlink socket */
+	struct sock		*genl_sock;
 
 	struct list_head 	dev_base_head;
 	struct hlist_head 	*dev_name_head;
@@ -60,11 +63,9 @@ struct net {
 
 	/* core fib_rules */
 	struct list_head	rules_ops;
-	spinlock_t		rules_mod_lock;
 
-	struct sock 		*rtnl;			/* rtnetlink socket */
-	struct sock		*genl_sock;
 
+	struct net_device       *loopback_dev;          /* The loopback */
 	struct netns_core	core;
 	struct netns_mib	mib;
 	struct netns_packet	packet;
@@ -84,13 +85,15 @@ struct net {
 	struct sock		*nfnl;
 	struct sock		*nfnl_stash;
 #endif
-#ifdef CONFIG_XFRM
-	struct netns_xfrm	xfrm;
-#endif
 #ifdef CONFIG_WEXT_CORE
 	struct sk_buff_head	wext_nlevents;
 #endif
 	struct net_generic	*gen;
+
+	/* Note : following structs are cache line aligned */
+#ifdef CONFIG_XFRM
+	struct netns_xfrm	xfrm;
+#endif
 };
 
 
diff --git a/include/net/netns/xfrm.h b/include/net/netns/xfrm.h
index 74f119a..748f91f 100644
--- a/include/net/netns/xfrm.h
+++ b/include/net/netns/xfrm.h
@@ -43,10 +43,6 @@ struct netns_xfrm {
 	unsigned int		policy_count[XFRM_POLICY_MAX * 2];
 	struct work_struct	policy_hash_work;
 
-	struct dst_ops		xfrm4_dst_ops;
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
-	struct dst_ops		xfrm6_dst_ops;
-#endif
 
 	struct sock		*nlsk;
 	struct sock		*nlsk_stash;
@@ -58,6 +54,11 @@ struct netns_xfrm {
 #ifdef CONFIG_SYSCTL
 	struct ctl_table_header	*sysctl_hdr;
 #endif
+
+	struct dst_ops		xfrm4_dst_ops;
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+	struct dst_ops		xfrm6_dst_ops;
+#endif
 };
 
 #endif


