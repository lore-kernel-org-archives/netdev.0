From: chenweilong <chenweilong@huawei.com>
Subject: [PATCH 3.4-stable] ipv6: reallocate addrconf router for ipv6 address
 when lo, device up
Date: Thu, 19 Jun 2014 08:50:33 +0800
Message-ID: <53A233D9.8070202@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:18578 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751014AbaFSAus (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jun 2014 20:50:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

Please queue this for 3.4 stable kernel.

It fix the bug 67951 on bugzilla
https://bugzilla.kernel.org/show_bug.cgi?id=67951

The patch can't be applied directly, as it' used the function introduced
by "commit 94e187c0" ip6_rt_put(), that patch can't be applied directly
either. So I had to write this one.

====================

From: Gao feng <gaofeng@cn.fujitsu.com>

commit 33d99113b1102c2d2f8603b9ba72d89d915c13f5 upstream.

This commit don't have a stable tag, but it fix the bug
no reply after loopback down-up.It's very worthy to be
applied to stable 3.4 kernels.

The bug is 67951 on bugzilla
https://bugzilla.kernel.org/show_bug.cgi?id=67951


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

-- 1.7.12
