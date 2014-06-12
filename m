From: Chen Weilong <chenweilong@huawei.com>
Subject: [request for stable inclusion] ipv6: reallocate addrconf router for ipv6 address when lo device up
Date: Thu, 12 Jun 2014 14:17:31 +0800
Message-ID: <1402553851-8944-1-git-send-email-chenweilong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Weilong Chen <chenweilong@huawei.com>
To: <davem@davemloft.net>, <kuznet@ms2.inr.ac.ru>, <jmorris@namei.org>,
	<yoshfuji@linux-ipv6.org>, <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:5083 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751479AbaFLGS4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jun 2014 02:18:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Weilong Chen <chenweilong@huawei.com>

"commit 33d99113b1102c2d2f8603b9ba72d89d915c13f5
ipv6: reallocate addrconf router for ipv6 address when lo device up."
This commit don't have a stable tag, but it fix the bug
no reply after loopback down-up.I think it should be
applied to stable 3.4.x kernels.

The bug is 67951 on bugzilla
https://bugzilla.kernel.org/show_bug.cgi?id=67951

The patch can't be applied directly. And it used the function introduced
by "commit 94e187c0" ip6_rt_put(), this patch can't be applied directly
either. 

Signed-off-by: Weilong Chen <chenweilong@huawei.com>
---
 include/net/ip6_fib.h |  9 +++++++++
 net/ipv6/addrconf.c   | 14 ++++++++++++--
 2 files changed, 21 insertions(+), 2 deletions(-)

diff --git a/include/net/ip6_fib.h b/include/net/ip6_fib.h
index 0ae759a..7c17c35 100644
--- a/include/net/ip6_fib.h
+++ b/include/net/ip6_fib.h
@@ -171,6 +171,15 @@ static inline void rt6_set_from(struct rt6_info *rt, struct rt6_info *from)
 	dst_hold(new);
 }
 
+static inline void ip6_rt_put(struct rt6_info *rt)
+{
+	/* dst_release() accepts a NULL parameter.
+	 * We rely on dst being first structure in struct rt6_info
+	 */
+	BUILD_BUG_ON(offsetof(struct rt6_info, dst) != 0);
+	dst_release(&rt->dst);
+}
+
 struct fib6_walker_t {
 	struct list_head lh;
 	struct fib6_node *root, *node;
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 9b8c3c6..00a0904 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -2424,8 +2424,18 @@ static void init_loopback(struct net_device *dev)
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
 
 			sp_rt = addrconf_dst_alloc(idev, &sp_ifa->addr, 0);
 
-- 
1.7.12
