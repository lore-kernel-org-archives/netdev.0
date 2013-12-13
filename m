From: yazzep@gmail.com
Subject: [PATCH 1/1] ipv6 addrconf:fix preferred lifetime state-changing behavior while valid_lft is infinity
Date: Sat, 14 Dec 2013 02:33:48 +0900
Message-ID: <1386956028-3463-1-git-send-email-yazzep@gmail.com>
References: <1386843347-2725-1-git-send-email-yazzep@gmail.com>
Cc: Yasushi Asano <yasushi.asano@jp.fujitsu.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:36463 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753157Ab3LMReG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Dec 2013 12:34:06 -0500
Received: by mail-pd0-f174.google.com with SMTP id y13so2731571pdi.5
        for <netdev@vger.kernel.org>; Fri, 13 Dec 2013 09:34:05 -0800 (PST)
In-Reply-To: <1386843347-2725-1-git-send-email-yazzep@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yasushi Asano <yasushi.asano@jp.fujitsu.com>

Fixed a problem with setting the lifetime of an IPv6
address. When setting preferred_lft to a value not zero or
infinity, while valid_lft is infinity(0xffffffff) preferred
lifetime is set to forever and does not update. Therefore
preferred lifetime never becomes deprecated. valid lifetime
and preferred lifetime should be set independently, even if
valid lifetime is infinity, preferred lifetime must expire
correctly (meaning it must eventually become deprecated)


Signed-off-by: Yasushi Asano <yasushi.asano@jp.fujitsu.com>
---
 net/ipv6/addrconf.c | 37 +++++++++++++++++++++----------------
 1 file changed, 21 insertions(+), 16 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 3c3425e..00c135b 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -948,18 +948,21 @@ static void ipv6_del_addr(struct inet6_ifaddr *ifp)
 					if (!onlink)
 						onlink = -1;
 
-					spin_lock(&ifa->lock);
-
-					lifetime = addrconf_timeout_fixup(ifa->valid_lft, HZ);
-					/*
-					 * Note: Because this address is
-					 * not permanent, lifetime <
-					 * LONG_MAX / HZ here.
-					 */
-					if (time_before(expires,
-							ifa->tstamp + lifetime * HZ))
-						expires = ifa->tstamp + lifetime * HZ;
-					spin_unlock(&ifa->lock);
+					if (ifp->valid_lft !=
+					    INFINITY_LIFE_TIME) {
+						spin_lock(&ifa->lock);
+
+						lifetime = addrconf_timeout_fixup(
+								ifa->valid_lft,	HZ);
+						/* Note: because this address is
+						 * not permanent, lifetime <
+						 * LONG_MAX / HZ here.
+						 */
+						if (time_before(expires,
+								ifa->tstamp + lifetime * HZ))
+							expires = ifa->tstamp +	lifetime * HZ;
+						spin_unlock(&ifa->lock);
+					}
 				}
 			}
 		}
@@ -2415,7 +2418,6 @@ static int inet6_addr_add(struct net *net, int ifindex,
 	} else {
 		expires = 0;
 		flags = 0;
-		ifa_flags |= IFA_F_PERMANENT;
 	}
 
 	timeout = addrconf_timeout_fixup(prefered_lft, HZ);
@@ -3497,8 +3499,12 @@ restart:
 					ifp->flags |= IFA_F_DEPRECATED;
 				}
 
-				if (time_before(ifp->tstamp + ifp->valid_lft * HZ, next))
-					next = ifp->tstamp + ifp->valid_lft * HZ;
+				if (ifp->valid_lft != INFINITY_LIFE_TIME) {
+					if (time_before(ifp->tstamp +
+							ifp->valid_lft * HZ, next))
+						next = ifp->tstamp +
+							ifp->valid_lft * HZ;
+				}
 
 				spin_unlock(&ifp->lock);
 
@@ -3635,7 +3641,6 @@ static int inet6_addr_modify(struct inet6_ifaddr *ifp, u32 ifa_flags,
 	} else {
 		expires = 0;
 		flags = 0;
-		ifa_flags |= IFA_F_PERMANENT;
 	}
 
 	timeout = addrconf_timeout_fixup(prefered_lft, HZ);
