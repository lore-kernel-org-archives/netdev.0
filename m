From: Steven Barth <cyrus@openwrt.org>
Subject: [PATCH v2] ipv6: fix inconsistent prefix route handling
Date: Sun, 16 Feb 2014 17:25:54 +0100
Message-ID: <1392567954-25752-1-git-send-email-cyrus@openwrt.org>
References: <5300DDB1.9000404@openwrt.org>
Cc: Steven Barth <cyrus@openwrt.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from chi.subsignal.org ([188.40.166.11]:40108 "EHLO
	chi.subsignal.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752474AbaBPQ0K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Feb 2014 11:26:10 -0500
In-Reply-To: <5300DDB1.9000404@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When temporary addresses are created in userspace an accompanying
on-link prefix-route is created alongside. However when said address is
afterwards removed in userspace the respective prefix route remains
until it expires. Similarly when userspace turns a permanent address
into a temporary one the prefix route remains and is not removed when
the address expires and is thus dangling until removed manually.

This behavior is inconsistent with the addition and removal of permanent
addresses and can potentially cause lots of dangling routes on
downstream interfaces on an IPv6-router with changing prefixes.

This patch runs the on-link prefix removal check also when a temporary
address is removed and thus unifies the prefix route handling.

Signed-off-by: Steven Barth <cyrus@openwrt.org>
---
 net/ipv6/addrconf.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index ad23569..55c35d5 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -1013,7 +1013,7 @@ static void ipv6_del_addr(struct inet6_ifaddr *ifp)
 		__in6_ifa_put(ifp);
 	}
 
-	if (ifp->flags & IFA_F_PERMANENT && !(ifp->flags & IFA_F_NOPREFIXROUTE))
+	if (!(ifp->flags & IFA_F_NOPREFIXROUTE))
 		action = check_cleanup_prefix_route(ifp, &expires);
 
 	list_del_init(&ifp->if_list);
-- 
1.8.3.2
