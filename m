From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCH 2/3] genetlink: Build a generic netlink family module alias
Date: Tue, 29 May 2012 15:30:41 -0400
Message-ID: <1338319842-18395-3-git-send-email-nhorman@tuxdriver.com>
References: <1338319842-18395-1-git-send-email-nhorman@tuxdriver.com>
Cc: Neil Horman <nhorman@tuxdriver.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	James Chapman <jchapman@katalix.com>,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:36056 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755372Ab2E2TbK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 May 2012 15:31:10 -0400
In-Reply-To: <1338319842-18395-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Generic netlink searches for -type- formatted aliases when requesting a module to
fulfill a protocol request (i.e. net-pf-16-proto-16-type-<x>, where x is a type
value).  However generic netlink protocols have no well defined type numbers,
they have string names.  Modify genl_ctrl_getfamily to request an alias in the
format net-pf-16-proto-16-family-<x> instead, where x is a generic string, and
add a macro that builds on the previously added MODULE_ALIAS_NET_PF_PROTO_NAME
macro to allow modules to specifify those generic strings.

Note, l2tp previously hacked together an net-pf-16-proto-16-type-l2tp alias
using the MODULE_ALIAS macro, with these updates we can convert that to use the
PROTO_NAME macro.

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
CC: Eric Dumazet <eric.dumazet@gmail.com>
CC: James Chapman <jchapman@katalix.com>
CC: David Miller <davem@davemloft.net>
---
 include/linux/genetlink.h |    3 +++
 net/l2tp/l2tp_netlink.c   |    3 +--
 net/netlink/genetlink.c   |    2 +-
 3 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/include/linux/genetlink.h b/include/linux/genetlink.h
index 73c28de..7a11401 100644
--- a/include/linux/genetlink.h
+++ b/include/linux/genetlink.h
@@ -110,6 +110,9 @@ extern int lockdep_genl_is_held(void);
 #define genl_dereference(p)					\
 	rcu_dereference_protected(p, lockdep_genl_is_held())
 
+#define MODULE_ALIAS_GENL_FAMILY(family)\
+ MODULE_ALIAS_NET_PF_PROTO_NAME(PF_NETLINK, NETLINK_GENERIC, "-family-" family)
+
 #endif /* __KERNEL__ */
 
 #endif	/* __LINUX_GENERIC_NETLINK_H */
diff --git a/net/l2tp/l2tp_netlink.c b/net/l2tp/l2tp_netlink.c
index 8577264..ddc553e 100644
--- a/net/l2tp/l2tp_netlink.c
+++ b/net/l2tp/l2tp_netlink.c
@@ -923,5 +923,4 @@ MODULE_AUTHOR("James Chapman <jchapman@katalix.com>");
 MODULE_DESCRIPTION("L2TP netlink");
 MODULE_LICENSE("GPL");
 MODULE_VERSION("1.0");
-MODULE_ALIAS("net-pf-" __stringify(PF_NETLINK) "-proto-" \
-	     __stringify(NETLINK_GENERIC) "-type-" "l2tp");
+MODULE_ALIAS_GENL_FAMILY("l2tp");
diff --git a/net/netlink/genetlink.c b/net/netlink/genetlink.c
index 8340ace..2cc7c1e 100644
--- a/net/netlink/genetlink.c
+++ b/net/netlink/genetlink.c
@@ -836,7 +836,7 @@ static int ctrl_getfamily(struct sk_buff *skb, struct genl_info *info)
 #ifdef CONFIG_MODULES
 		if (res == NULL) {
 			genl_unlock();
-			request_module("net-pf-%d-proto-%d-type-%s",
+			request_module("net-pf-%d-proto-%d-family-%s",
 				       PF_NETLINK, NETLINK_GENERIC, name);
 			genl_lock();
 			res = genl_family_find_byname(name);
-- 
1.7.7.6
