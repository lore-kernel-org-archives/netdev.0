From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH ipsec] vti6: fix uninit when using x-netns
Date: Thu,  2 Apr 2015 17:31:17 +0200
Message-ID: <1427988677-11478-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, Yao Xiwei <xiwei.yao@6wind.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: steffen.klassert@secunet.com, herbert@gondor.apana.org.au,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:56684 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752704AbbDBPbV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2015 11:31:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yao Xiwei <xiwei.yao@6wind.com>

When the kernel deleted a vti6 interface, this interface was not removed from
the tunnels list. Thus, when the ip6_vti module was removed, this old interface
was found and the kernel tried to delete it again. This was leading to a kernel
panic.

Fixes: 61220ab34948 ("vti6: Enable namespace changing")
Signed-off-by: Yao Xiwei <xiwei.yao@6wind.com>
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/ipv6/ip6_vti.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/ipv6/ip6_vti.c b/net/ipv6/ip6_vti.c
index ace10d0b3aac..96ba579917c1 100644
--- a/net/ipv6/ip6_vti.c
+++ b/net/ipv6/ip6_vti.c
@@ -288,8 +288,7 @@ static struct ip6_tnl *vti6_locate(struct net *net, struct __ip6_tnl_parm *p,
 static void vti6_dev_uninit(struct net_device *dev)
 {
 	struct ip6_tnl *t = netdev_priv(dev);
-	struct net *net = dev_net(dev);
-	struct vti6_net *ip6n = net_generic(net, vti6_net_id);
+	struct vti6_net *ip6n = net_generic(t->net, vti6_net_id);
 
 	if (dev == ip6n->fb_tnl_dev)
 		RCU_INIT_POINTER(ip6n->tnls_wc[0], NULL);
-- 
2.2.2
