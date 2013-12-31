From: Yasushi Asano <yazzep@gmail.com>
Subject: [PATCH] ipv6 addrconf: fix preferred lifetime state-changing behavior while valid_lft is infinity
Date: Tue, 31 Dec 2013 12:04:19 +0900
Message-ID: <1388459059-2563-1-git-send-email-yazzep@gmail.com>
References: <20131230021754.GA7718@order.stressinduktion.org>
Cc: Yasushi Asano <yasushi.asano@jp.fujitsu.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:48718 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752559Ab3LaDEd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Dec 2013 22:04:33 -0500
Received: by mail-pd0-f180.google.com with SMTP id q10so11887551pdj.25
        for <netdev@vger.kernel.org>; Mon, 30 Dec 2013 19:04:33 -0800 (PST)
In-Reply-To: <20131230021754.GA7718@order.stressinduktion.org>
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
 net/ipv6/addrconf.c |   13 ++++++++++---
 1 files changed, 10 insertions(+), 3 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index cd2d7d0..a9371fc 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -3479,7 +3479,12 @@ restart:
 					 &inet6_addr_lst[i], addr_lst) {
 			unsigned long age;
 
-			if (ifp->flags & IFA_F_PERMANENT)
+			/* When setting preferred_lft to a value not zero or
+			 * infinity, while valid_lft is infinity
+			 * IFA_F_PERMANENT has a non-infinity life time.
+			 */
+			if ((ifp->flags & IFA_F_PERMANENT) &&
+			    (ifp->prefered_lft == INFINITY_LIFE_TIME))
 				continue;
 
 			spin_lock(&ifp->lock);
@@ -3504,7 +3509,8 @@ restart:
 					ifp->flags |= IFA_F_DEPRECATED;
 				}
 
-				if (time_before(ifp->tstamp + ifp->valid_lft * HZ, next))
+				if ((ifp->valid_lft != INFINITY_LIFE_TIME) &&
+				    (time_before(ifp->tstamp + ifp->valid_lft * HZ, next)))
 					next = ifp->tstamp + ifp->valid_lft * HZ;
 
 				spin_unlock(&ifp->lock);
@@ -3804,7 +3810,8 @@ static int inet6_fill_ifaddr(struct sk_buff *skb, struct inet6_ifaddr *ifa,
 	put_ifaddrmsg(nlh, ifa->prefix_len, ifa->flags, rt_scope(ifa->scope),
 		      ifa->idev->dev->ifindex);
 
-	if (!(ifa->flags&IFA_F_PERMANENT)) {
+	if (!((ifa->flags&IFA_F_PERMANENT) &&
+	      (ifa->prefered_lft == INFINITY_LIFE_TIME))) {
 		preferred = ifa->prefered_lft;
 		valid = ifa->valid_lft;
 		if (preferred != INFINITY_LIFE_TIME) {
-- 
1.7.7.6
