From: yazzep@gmail.com
Subject: [PATCH] ipv6 addrconf:fix preferred lifetime state-changing behavior while valid_lft is infinity
Date: Sun, 29 Dec 2013 16:47:40 +0900
Message-ID: <1388303260-3668-1-git-send-email-yazzep@gmail.com>
References: <20131214091917.GB23563@order.stressinduktion.org>
Cc: Yasushi Asano <yasushi.asano@jp.fujitsu.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:36181 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751048Ab3L2Hru (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Dec 2013 02:47:50 -0500
Received: by mail-pd0-f172.google.com with SMTP id g10so10322030pdj.17
        for <netdev@vger.kernel.org>; Sat, 28 Dec 2013 23:47:49 -0800 (PST)
In-Reply-To: <20131214091917.GB23563@order.stressinduktion.org>
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
 net/ipv6/addrconf.c | 14 ++++++++++----
 1 file changed, 10 insertions(+), 4 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index cd2d7d0..796d52a 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -3479,7 +3479,8 @@ restart:
 					 &inet6_addr_lst[i], addr_lst) {
 			unsigned long age;
 
-			if (ifp->flags & IFA_F_PERMANENT)
+			if ((ifp->flags & IFA_F_PERMANENT) &&
+			    (ifp->prefered_lft == INFINITY_LIFE_TIME))
 				continue;
 
 			spin_lock(&ifp->lock);
@@ -3504,8 +3505,12 @@ restart:
 					ifp->flags |= IFA_F_DEPRECATED;
 				}
 
-				if (time_before(ifp->tstamp + ifp->valid_lft * HZ, next))
-					next = ifp->tstamp + ifp->valid_lft * HZ;
+				if (ifp->valid_lft != INFINITY_LIFE_TIME) {
+				    if (time_before(ifp->tstamp +
+					    ifp->valid_lft * HZ, next))
+						next = ifp->tstamp +
+							 ifp->valid_lft * HZ;
+				}
 
 				spin_unlock(&ifp->lock);
 
@@ -3804,7 +3809,8 @@ static int inet6_fill_ifaddr(struct sk_buff *skb, struct inet6_ifaddr *ifa,
 	put_ifaddrmsg(nlh, ifa->prefix_len, ifa->flags, rt_scope(ifa->scope),
 		      ifa->idev->dev->ifindex);
 
-	if (!(ifa->flags&IFA_F_PERMANENT)) {
+	if (!((ifa->flags&IFA_F_PERMANENT) &&
+	      (ifa->prefered_lft == INFINITY_LIFE_TIME))) {
 		preferred = ifa->prefered_lft;
 		valid = ifa->valid_lft;
 		if (preferred != INFINITY_LIFE_TIME) {
-- 
1.7.12.4
