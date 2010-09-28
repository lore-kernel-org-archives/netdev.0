From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] ipip: fix percpu stats accounting
Date: Tue, 28 Sep 2010 11:56:46 +0200
Message-ID: <1285667806.3154.8.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:62383 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753214Ab0I1J4u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Sep 2010 05:56:50 -0400
Received: by fxm3 with SMTP id 3so2459103fxm.19
        for <netdev@vger.kernel.org>; Tue, 28 Sep 2010 02:56:49 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 3c97af99a5aa1 (ipip: percpu stats accounting) forgot the fallback
tunnel case (tunl0), and can crash pretty fast.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv4/ipip.c |   13 ++++++++++---
 1 file changed, 10 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index 12b6fde..9e78f11 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -789,7 +789,7 @@ static int ipip_tunnel_init(struct net_device *dev)
 	return 0;
 }
 
-static void __net_init ipip_fb_tunnel_init(struct net_device *dev)
+static int __net_init ipip_fb_tunnel_init(struct net_device *dev)
 {
 	struct ip_tunnel *tunnel = netdev_priv(dev);
 	struct iphdr *iph = &tunnel->parms.iph;
@@ -802,8 +802,13 @@ static void __net_init ipip_fb_tunnel_init(struct net_device *dev)
 	iph->protocol		= IPPROTO_IPIP;
 	iph->ihl		= 5;
 
+	dev->tstats = alloc_percpu(struct pcpu_tstats);
+	if (!dev->tstats)
+		return -ENOMEM;
+
 	dev_hold(dev);
 	rcu_assign_pointer(ipn->tunnels_wc[0], tunnel);
+	return 0;
 }
 
 static struct xfrm_tunnel ipip_handler __read_mostly = {
@@ -852,7 +857,9 @@ static int __net_init ipip_init_net(struct net *net)
 	}
 	dev_net_set(ipn->fb_tunnel_dev, net);
 
-	ipip_fb_tunnel_init(ipn->fb_tunnel_dev);
+	err = ipip_fb_tunnel_init(ipn->fb_tunnel_dev);
+	if (err)
+		goto err_reg_dev;
 
 	if ((err = register_netdev(ipn->fb_tunnel_dev)))
 		goto err_reg_dev;
@@ -860,7 +867,7 @@ static int __net_init ipip_init_net(struct net *net)
 	return 0;
 
 err_reg_dev:
-	free_netdev(ipn->fb_tunnel_dev);
+	ipip_dev_free(ipn->fb_tunnel_dev);
 err_alloc_dev:
 	/* nothing */
 	return err;


