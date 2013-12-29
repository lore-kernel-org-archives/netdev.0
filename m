From: "yasushi.asano" <yazzep@gmail.com>
Subject: [PATCH] ipv6 addrconf:fix preferred lifetime state-changing behavior while valid_lft is infinity
Date: Sun, 29 Dec 2013 16:34:01 +0900
Message-ID: <1388302441-3293-1-git-send-email-yazzep@gmail.com>
References: <20131214091917.GB23563@order.stressinduktion.org>
Cc: Yasushi Asano <yasushi.asano@jp.fujitsu.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f45.google.com ([209.85.160.45]:58721 "EHLO
	mail-pb0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751178Ab3L2Hec (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Dec 2013 02:34:32 -0500
Received: by mail-pb0-f45.google.com with SMTP id rp16so10560741pbb.18
        for <netdev@vger.kernel.org>; Sat, 28 Dec 2013 23:34:32 -0800 (PST)
In-Reply-To: <20131214091917.GB23563@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yasushi Asano <yasushi.asano@jp.fujitsu.com>


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
