From: Chen Weilong <chenweilong@huawei.com>
Subject: [request for stable inclusion] ipv6: reallocate addrconf router for ipv6 address when lo device up
Date: Mon, 16 Jun 2014 10:04:39 +0800
Message-ID: <1402884279-11896-1-git-send-email-chenweilong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <stable@vger.kernel.org>, <netdev@vger.kernel.org>,
	<hannes@stressinduktion.org>, <sd@queasysnail.net>,
	Chen Weilong <chenweilong@huawei.com>,
	Li Zefan <lizefan@huawei.com>
To: <gregkh@linuxfoundation.org>, <davem@davemloft.net>,
	<gaofeng@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:44368 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752114AbaFPCF5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Jun 2014 22:05:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao feng <gaofeng@cn.fujitsu.com>

commit 33d99113b1102c2d2f8603b9ba72d89d915c13f5 upstream.

/* CHANGELOG */

CC: Sabrina Dubroca <sd@queasysnail.net>
CC: Hannes Frederic Sowa <hannes@stressinduktion.org>
Reported-by: Weilong Chen <chenweilong@huawei.com>
Signed-off-by: Weilong Chen <chenweilong@huawei.com>
Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
Signed-off-by: David S. Miller <davem@davemloft.net>
[weilong: s/ip6_rt_put/dst_release]
Signed-off-by: Chen Weilong <chenweilong@huawei.com>
Signed-off-by: Li Zefan <lizefan@huawei.com>
---
 net/ipv6/addrconf.c | 14 ++++++++++++--
 1 file changed, 12 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index abfa007..25399bf 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -2435,8 +2435,18 @@ static void init_loopback(struct net_device *dev)
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
+					dst_release(sp_ifa->rt);
+					sp_ifa->rt = NULL;
+				} else {
+					continue;
+				}
+			}
 
 			sp_rt = addrconf_dst_alloc(idev, &sp_ifa->addr, 0);
 
-- 
1.7.12
