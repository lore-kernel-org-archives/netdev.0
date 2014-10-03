From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 7/9] netfilter: explicit module dependency between br_netfilter and physdev
Date: Fri,  3 Oct 2014 19:20:22 +0200
Message-ID: <1412356824-6362-8-git-send-email-pablo@netfilter.org>
References: <1412356824-6362-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:43929 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754286AbaJCRTl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Oct 2014 13:19:41 -0400
In-Reply-To: <1412356824-6362-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

You can use physdev to match the physical interface enslaved to the
bridge device. This information is stored in skb->nf_bridge and it is
set up by br_netfilter. So, this is only available when iptables is
used from the bridge netfilter path.

Since 34666d4 ("netfilter: bridge: move br_netfilter out of the core"),
the br_netfilter code is modular. To reduce the impact of this change,
we can autoload the br_netfilter if the physdev match is used since
we assume that the users need br_netfilter in place.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/br_netfilter.h |    6 ++++++
 net/bridge/br_netfilter.c            |    5 +++++
 net/netfilter/xt_physdev.c           |    3 +++
 3 files changed, 14 insertions(+)
 create mode 100644 include/net/netfilter/br_netfilter.h

diff --git a/include/net/netfilter/br_netfilter.h b/include/net/netfilter/br_netfilter.h
new file mode 100644
index 0000000..2aa6048
--- /dev/null
+++ b/include/net/netfilter/br_netfilter.h
@@ -0,0 +1,6 @@
+#ifndef _BR_NETFILTER_H_
+#define _BR_NETFILTER_H_
+
+void br_netfilter_enable(void);
+
+#endif /* _BR_NETFILTER_H_ */
diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index 97e4393..fa1270c 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -856,6 +856,11 @@ static unsigned int ip_sabotage_in(const struct nf_hook_ops *ops,
 	return NF_ACCEPT;
 }
 
+void br_netfilter_enable(void)
+{
+}
+EXPORT_SYMBOL_GPL(br_netfilter_enable);
+
 /* For br_nf_post_routing, we need (prio = NF_BR_PRI_LAST), because
  * br_dev_queue_push_xmit is called afterwards */
 static struct nf_hook_ops br_nf_ops[] __read_mostly = {
diff --git a/net/netfilter/xt_physdev.c b/net/netfilter/xt_physdev.c
index d7ca16b..f440f57 100644
--- a/net/netfilter/xt_physdev.c
+++ b/net/netfilter/xt_physdev.c
@@ -13,6 +13,7 @@
 #include <linux/netfilter_bridge.h>
 #include <linux/netfilter/xt_physdev.h>
 #include <linux/netfilter/x_tables.h>
+#include <net/netfilter/br_netfilter.h>
 
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Bart De Schuymer <bdschuym@pandora.be>");
@@ -87,6 +88,8 @@ static int physdev_mt_check(const struct xt_mtchk_param *par)
 {
 	const struct xt_physdev_info *info = par->matchinfo;
 
+	br_netfilter_enable();
+
 	if (!(info->bitmask & XT_PHYSDEV_OP_MASK) ||
 	    info->bitmask & ~XT_PHYSDEV_OP_MASK)
 		return -EINVAL;
-- 
1.7.10.4
