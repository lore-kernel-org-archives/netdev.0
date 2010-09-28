From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] sit: fix percpu stats accounting
Date: Tue, 28 Sep 2010 14:17:58 +0200
Message-ID: <1285676278.3154.21.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:57673 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754169Ab0I1MSC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Sep 2010 08:18:02 -0400
Received: by fxm3 with SMTP id 3so2509580fxm.19
        for <netdev@vger.kernel.org>; Tue, 28 Sep 2010 05:18:01 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 15fc1f7056ebd (sit: percpu stats accounting) forgot the fallback
tunnel case (sit0), and can crash pretty fast.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv6/sit.c |   14 +++++++++++---
 1 files changed, 11 insertions(+), 3 deletions(-)

diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 011ecf5..2cb6460 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -1160,7 +1160,7 @@ static int ipip6_tunnel_init(struct net_device *dev)
 	return 0;
 }
 
-static void __net_init ipip6_fb_tunnel_init(struct net_device *dev)
+static int __net_init ipip6_fb_tunnel_init(struct net_device *dev)
 {
 	struct ip_tunnel *tunnel = netdev_priv(dev);
 	struct iphdr *iph = &tunnel->parms.iph;
@@ -1175,8 +1175,12 @@ static void __net_init ipip6_fb_tunnel_init(struct net_device *dev)
 	iph->ihl		= 5;
 	iph->ttl		= 64;
 
+	dev->tstats = alloc_percpu(struct pcpu_tstats);
+	if (!dev->tstats)
+		return -ENOMEM;
 	dev_hold(dev);
 	sitn->tunnels_wc[0]	= tunnel;
+	return 0;
 }
 
 static struct xfrm_tunnel sit_handler __read_mostly = {
@@ -1220,7 +1224,10 @@ static int __net_init sit_init_net(struct net *net)
 	}
 	dev_net_set(sitn->fb_tunnel_dev, net);
 
-	ipip6_fb_tunnel_init(sitn->fb_tunnel_dev);
+	err = ipip6_fb_tunnel_init(sitn->fb_tunnel_dev);
+	if (err)
+		goto err_dev_free;
+
 	ipip6_tunnel_clone_6rd(sitn->fb_tunnel_dev, sitn);
 
 	if ((err = register_netdev(sitn->fb_tunnel_dev)))
@@ -1230,7 +1237,8 @@ static int __net_init sit_init_net(struct net *net)
 
 err_reg_dev:
 	dev_put(sitn->fb_tunnel_dev);
-	free_netdev(sitn->fb_tunnel_dev);
+err_dev_free:
+	ipip6_dev_free(sitn->fb_tunnel_dev);
 err_alloc_dev:
 	return err;
 }


