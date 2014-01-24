From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH net v2] ipv6: reallocate addrconf router for ipv6 address when lo device up
Date: Fri, 24 Jan 2014 16:29:11 +0800
Message-ID: <1390552151-20735-1-git-send-email-gaofeng@cn.fujitsu.com>
Cc: davem@davemloft.net, Gao feng <gaofeng@cn.fujitsu.com>,
	Sabrina Dubroca <sd@queasysnail.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Weilong Chen <chenweilong@huawei.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:43530 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751093AbaAXI23 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Jan 2014 03:28:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 25fb6ca4ed9cad72f14f61629b68dc03c0d9713f
"net IPv6 : Fix broken IPv6 routing table after loopback down-up"
allocates addrconf router for ipv6 address when lo device up.
but commit a881ae1f625c599b460cc8f8a7fcb1c438f699ad
"ipv6:don't call addrconf_dst_alloc again when enable lo" breaks
this behavior.

Since the addrconf router is moved to the garbage list when
lo device down, we should release this router and rellocate
a new one for ipv6 address when lo device up.

This patch solves bug 67951 on bugzilla
https://bugzilla.kernel.org/show_bug.cgi?id=67951

change from v1:
use ip6_rt_put to repleace ip6_del_rt, thanks Hannes!
change code style, suggested by Sergei.

CC: Sabrina Dubroca <sd@queasysnail.net>
CC: Hannes Frederic Sowa <hannes@stressinduktion.org>
Reported-by: Weilong Chen <chenweilong@huawei.com>
Signed-off-by: Weilong Chen <chenweilong@huawei.com>
Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
---
 net/ipv6/addrconf.c | 14 ++++++++++++--
 1 file changed, 12 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 4b6b720..dee84d6 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -2611,8 +2611,18 @@ static void init_loopback(struct net_device *dev)
 			if (sp_ifa->flags & (IFA_F_DADFAILED | IFA_F_TENTATIVE))
 				continue;
 
-			if (sp_ifa->rt)
-				continue;
+			if (sp_ifa->rt) {
+				/* This dst has been added to garbage list when
+				 * lo device down, release this obsolete dst and
+				 * reallocate a new router for ifa.
+				 */
+				if (sp_ifa->rt->dst.obsolete > 0) {
+					ip6_rt_put(sp_ifa->rt);
+					sp_ifa->rt = NULL;
+				} else {
+					continue;
+				}
+			}
 
 			sp_rt = addrconf_dst_alloc(idev, &sp_ifa->addr, false);
 
-- 
1.8.4.2
