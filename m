From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net 1/2] gre: don't allow to add the same tunnel twice
Date: Fri, 11 Apr 2014 15:51:18 +0200
Message-ID: <1397224279-4161-2-git-send-email-nicolas.dichtel@6wind.com>
References: <1397224279-4161-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Pravin B Shelar <pshelar@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:37692 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932075AbaDKNv3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Apr 2014 09:51:29 -0400
In-Reply-To: <1397224279-4161-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Before the patch, it was possible to add two times the same tunnel:
ip l a gre1 type gre remote 10.16.0.121 local 10.16.0.249
ip l a gre2 type gre remote 10.16.0.121 local 10.16.0.249

It was possible, because ip_tunnel_newlink() calls ip_tunnel_find() with the
argument dev->type, which was set only later (when calling ndo_init handler
in register_netdevice()). Let's set this type in the setup handler, which is
called before newlink handler.

Introduced by commit c54419321455 ("GRE: Refactor GRE tunneling code.").

CC: Pravin B Shelar <pshelar@nicira.com>
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/ipv4/ip_gre.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index ec4f762efda5..94213c891565 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -463,6 +463,7 @@ static const struct net_device_ops ipgre_netdev_ops = {
 static void ipgre_tunnel_setup(struct net_device *dev)
 {
 	dev->netdev_ops		= &ipgre_netdev_ops;
+	dev->type		= ARPHRD_IPGRE;
 	ip_tunnel_setup(dev, ipgre_net_id);
 }
 
@@ -501,7 +502,6 @@ static int ipgre_tunnel_init(struct net_device *dev)
 	memcpy(dev->dev_addr, &iph->saddr, 4);
 	memcpy(dev->broadcast, &iph->daddr, 4);
 
-	dev->type		= ARPHRD_IPGRE;
 	dev->flags		= IFF_NOARP;
 	dev->priv_flags		&= ~IFF_XMIT_DST_RELEASE;
 	dev->addr_len		= 4;
-- 
1.9.0
