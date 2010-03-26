From: Nicolas Dichtel <nicolas.dichtel@dev.6wind.com>
Subject: [PATCH] net: ipmr/ip6mr: prevent out-of-bounds vif_table access
Date: Fri, 26 Mar 2010 10:45:35 +0100
Message-ID: <4BAC823F.8050409@dev.6wind.com>
Reply-To: nicolas.dichtel@dev.6wind.com
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090109040003080606090404"
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4-g21.free.fr ([212.27.42.4]:52959 "EHLO smtp4-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752799Ab0CZJpp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Mar 2010 05:45:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------090109040003080606090404
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Hi,

please consider the attached patch about IPv4 and IPv6 multicast.


Regards,
Nicolas

--------------090109040003080606090404
Content-Type: text/x-diff;
 name="0001-net-ipmr-ip6mr-prevent-out-of-bounds-vif_table-acc.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename*0="0001-net-ipmr-ip6mr-prevent-out-of-bounds-vif_table-acc.patc";
 filename*1="h"

>From fb0b874d55bfe2b81499d4c17598b94ac6c58594 Mon Sep 17 00:00:00 2001
From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Fri, 26 Mar 2010 10:12:34 +0100
Subject: [PATCH] net: ipmr/ip6mr: prevent out-of-bounds vif_table access

When cache is unresolved, c->mf[6]c_parent is set to 65535 and
minvif, maxvif are not initialized, hence we must avoid to
parse IIF and OIF.
A second problem can happen when the user dumps a cache entry
where a VIF, that was referenced at creation time, has been
removed.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/ipv4/ipmr.c  |   11 +++++++----
 net/ipv6/ip6mr.c |   11 +++++++----
 2 files changed, 14 insertions(+), 8 deletions(-)

diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 0b9d03c..d0a6092 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -1616,17 +1616,20 @@ ipmr_fill_mroute(struct sk_buff *skb, struct mfc_cache *c, struct rtmsg *rtm)
 	int ct;
 	struct rtnexthop *nhp;
 	struct net *net = mfc_net(c);
-	struct net_device *dev = net->ipv4.vif_table[c->mfc_parent].dev;
 	u8 *b = skb_tail_pointer(skb);
 	struct rtattr *mp_head;
 
-	if (dev)
-		RTA_PUT(skb, RTA_IIF, 4, &dev->ifindex);
+	/* If cache is unresolved, don't try to parse IIF and OIF */
+	if (c->mfc_parent > MAXVIFS)
+		return -ENOENT;
+
+	if (VIF_EXISTS(net, c->mfc_parent))
+		RTA_PUT(skb, RTA_IIF, 4, &net->ipv4.vif_table[c->mfc_parent].dev->ifindex);
 
 	mp_head = (struct rtattr *)skb_put(skb, RTA_LENGTH(0));
 
 	for (ct = c->mfc_un.res.minvif; ct < c->mfc_un.res.maxvif; ct++) {
-		if (c->mfc_un.res.ttls[ct] < 255) {
+		if (VIF_EXISTS(net, ct) && c->mfc_un.res.ttls[ct] < 255) {
 			if (skb_tailroom(skb) < RTA_ALIGN(RTA_ALIGN(sizeof(*nhp)) + 4))
 				goto rtattr_failure;
 			nhp = (struct rtnexthop *)skb_put(skb, RTA_ALIGN(sizeof(*nhp)));
diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index 23e4ac0..27acfb5 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -1695,17 +1695,20 @@ ip6mr_fill_mroute(struct sk_buff *skb, struct mfc6_cache *c, struct rtmsg *rtm)
 	int ct;
 	struct rtnexthop *nhp;
 	struct net *net = mfc6_net(c);
-	struct net_device *dev = net->ipv6.vif6_table[c->mf6c_parent].dev;
 	u8 *b = skb_tail_pointer(skb);
 	struct rtattr *mp_head;
 
-	if (dev)
-		RTA_PUT(skb, RTA_IIF, 4, &dev->ifindex);
+	/* If cache is unresolved, don't try to parse IIF and OIF */
+	if (c->mf6c_parent > MAXMIFS)
+		return -ENOENT;
+
+	if (MIF_EXISTS(net, c->mf6c_parent))
+		RTA_PUT(skb, RTA_IIF, 4, &net->ipv6.vif6_table[c->mf6c_parent].dev->ifindex);
 
 	mp_head = (struct rtattr *)skb_put(skb, RTA_LENGTH(0));
 
 	for (ct = c->mfc_un.res.minvif; ct < c->mfc_un.res.maxvif; ct++) {
-		if (c->mfc_un.res.ttls[ct] < 255) {
+		if (MIF_EXISTS(net, ct) && c->mfc_un.res.ttls[ct] < 255) {
 			if (skb_tailroom(skb) < RTA_ALIGN(RTA_ALIGN(sizeof(*nhp)) + 4))
 				goto rtattr_failure;
 			nhp = (struct rtnexthop *)skb_put(skb, RTA_ALIGN(sizeof(*nhp)));
-- 
1.5.4.5


--------------090109040003080606090404--
