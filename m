From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH] ipv6: don't call addrconf_dst_alloc again when enable lo
Date: Sun, 16 Jun 2013 11:14:30 +0800
Message-ID: <1371352470-3226-1-git-send-email-gaofeng@cn.fujitsu.com>
Cc: kumaran.4353@gmail.com, netdev@vger.kernel.org,
	Gao feng <gaofeng@cn.fujitsu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:34808 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1754991Ab3FPHAR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 16 Jun 2013 03:00:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If we disable all of the net interfaces, and enable
un-lo interface before lo interface, we already allocated
the addrconf dst in ipv6_add_addr. So we shouldn't allocate
it again when we enable lo interface.

Otherwise the message below will be triggered.
unregister_netdevice: waiting for sit1 to become free. Usage count = 1

This problem is introduced by commit 25fb6ca4ed9cad72f14f61629b68dc03c0d9713f
"net IPv6 : Fix broken IPv6 routing table after loopback down-up"

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
---
 net/ipv6/addrconf.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 1bbf744..77b6261 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -2655,6 +2655,9 @@ static void init_loopback(struct net_device *dev)
 			if (sp_ifa->flags & (IFA_F_DADFAILED | IFA_F_TENTATIVE))
 				continue;
 
+			if (sp_ifa->rt)
+				continue;
+
 			sp_rt = addrconf_dst_alloc(idev, &sp_ifa->addr, 0);
 
 			/* Failure cases are ignored */
-- 
1.8.1.4
