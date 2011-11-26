From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH net-next 1/8] dsa: Change dsa_uses_{dsa,trailer}_tags() into
 inline functions
Date: Sat, 26 Nov 2011 00:32:52 +0000
Message-ID: <1322267572.2839.381.camel@deadeye>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: Lennert Buytenhek <buytenh@wantstofly.org>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:34252 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753798Ab1KZAdE convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Nov 2011 19:33:04 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

eth_type_trans() will use these functions if DSA is enabled, which
blocks building DSA as a module.

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
 include/linux/netdevice.h |    2 +-
 include/net/dsa.h         |   53 +++++++++++++++++++++++++++++++++++++++++++-
 net/dsa/dsa.c             |   23 -------------------
 net/dsa/dsa_priv.h        |   33 ----------------------------
 4 files changed, 52 insertions(+), 59 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 999bb26..63721a6 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1080,7 +1080,7 @@ struct net_device {
 	struct vlan_group __rcu	*vlgrp;		/* VLAN group */
 #endif
 #ifdef CONFIG_NET_DSA
-	void			*dsa_ptr;	/* dsa specific data */
+	struct dsa_switch_tree	*dsa_ptr;	/* dsa specific data */
 #endif
 	void 			*atalk_ptr;	/* AppleTalk link 	*/
 	struct in_device __rcu	*ip_ptr;	/* IPv4 specific data	*/
diff --git a/include/net/dsa.h b/include/net/dsa.h
index 839f768..32a1b49 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -11,6 +11,9 @@
 #ifndef __LINUX_NET_DSA_H
 #define __LINUX_NET_DSA_H
 
+#include <linux/timer.h>
+#include <linux/workqueue.h>
+
 #define DSA_MAX_SWITCHES	4
 #define DSA_MAX_PORTS		12
 
@@ -54,8 +57,54 @@ struct dsa_platform_data {
 	struct dsa_chip_data	*chip;
 };
 
-extern bool dsa_uses_dsa_tags(void *dsa_ptr);
-extern bool dsa_uses_trailer_tags(void *dsa_ptr);
+struct dsa_switch_tree {
+	/*
+	 * Configuration data for the platform device that owns
+	 * this dsa switch tree instance.
+	 */
+	struct dsa_platform_data	*pd;
+
+	/*
+	 * Reference to network device to use, and which tagging
+	 * protocol to use.
+	 */
+	struct net_device	*master_netdev;
+	__be16			tag_protocol;
+
+	/*
+	 * The switch and port to which the CPU is attached.
+	 */
+	s8			cpu_switch;
+	s8			cpu_port;
+
+	/*
+	 * Link state polling.
+	 */
+	int			link_poll_needed;
+	struct work_struct	link_poll_work;
+	struct timer_list	link_poll_timer;
+
+	/*
+	 * Data for the individual switch chips.
+	 */
+	struct dsa_switch	*ds[DSA_MAX_SWITCHES];
+};
+
+/*
+ * The original DSA tag format and some other tag formats have no
+ * ethertype, which means that we need to add a little hack to the
+ * networking receive path to make sure that received frames get
+ * the right ->protocol assigned to them when one of those tag
+ * formats is in use.
+ */
+static inline bool dsa_uses_dsa_tags(struct dsa_switch_tree *dst)
+{
+	return !!(dst->tag_protocol == htons(ETH_P_DSA));
+}
 
+static inline bool dsa_uses_trailer_tags(struct dsa_switch_tree *dst)
+{
+	return !!(dst->tag_protocol == htons(ETH_P_TRAILER));
+}
 
 #endif
diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index 0dc1589..66f5c04 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -199,29 +199,6 @@ static void dsa_switch_destroy(struct dsa_switch *ds)
 }
 

-/* hooks for ethertype-less tagging formats *********************************/
-/*
- * The original DSA tag format and some other tag formats have no
- * ethertype, which means that we need to add a little hack to the
- * networking receive path to make sure that received frames get
- * the right ->protocol assigned to them when one of those tag
- * formats is in use.
- */
-bool dsa_uses_dsa_tags(void *dsa_ptr)
-{
-	struct dsa_switch_tree *dst = dsa_ptr;
-
-	return !!(dst->tag_protocol == htons(ETH_P_DSA));
-}
-
-bool dsa_uses_trailer_tags(void *dsa_ptr)
-{
-	struct dsa_switch_tree *dst = dsa_ptr;
-
-	return !!(dst->tag_protocol == htons(ETH_P_TRAILER));
-}
-
-
 /* link polling *************************************************************/
 static void dsa_link_poll_work(struct work_struct *ugly)
 {
diff --git a/net/dsa/dsa_priv.h b/net/dsa/dsa_priv.h
index 4b0ea05..a45186cb 100644
--- a/net/dsa/dsa_priv.h
+++ b/net/dsa/dsa_priv.h
@@ -48,39 +48,6 @@ struct dsa_switch {
 	struct net_device	*ports[DSA_MAX_PORTS];
 };
 
-struct dsa_switch_tree {
-	/*
-	 * Configuration data for the platform device that owns
-	 * this dsa switch tree instance.
-	 */
-	struct dsa_platform_data	*pd;
-
-	/*
-	 * Reference to network device to use, and which tagging
-	 * protocol to use.
-	 */
-	struct net_device	*master_netdev;
-	__be16			tag_protocol;
-
-	/*
-	 * The switch and port to which the CPU is attached.
-	 */
-	s8			cpu_switch;
-	s8			cpu_port;
-
-	/*
-	 * Link state polling.
-	 */
-	int			link_poll_needed;
-	struct work_struct	link_poll_work;
-	struct timer_list	link_poll_timer;
-
-	/*
-	 * Data for the individual switch chips.
-	 */
-	struct dsa_switch	*ds[DSA_MAX_SWITCHES];
-};
-
 static inline bool dsa_is_cpu_port(struct dsa_switch *ds, int p)
 {
 	return !!(ds->index == ds->dst->cpu_switch && p == ds->dst->cpu_port);
-- 
1.7.7.3
