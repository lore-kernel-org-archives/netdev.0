From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net 2/2] vti: don't allow to add the same tunnel twice
Date: Fri, 11 Apr 2014 15:51:19 +0200
Message-ID: <1397224279-4161-3-git-send-email-nicolas.dichtel@6wind.com>
References: <1397224279-4161-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Cong Wang <amwang@redhat.com>,
	Steffen Klassert <steffen.klassert@secunet.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:37693 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932172AbaDKNv3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Apr 2014 09:51:29 -0400
In-Reply-To: <1397224279-4161-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Before the patch, it was possible to add two times the same tunnel:
ip l a vti1 type vti remote 10.16.0.121 local 10.16.0.249 key 41
ip l a vti2 type vti remote 10.16.0.121 local 10.16.0.249 key 41

It was possible, because ip_tunnel_newlink() calls ip_tunnel_find() with the
argument dev->type, which was set only later (when calling ndo_init handler
in register_netdevice()). Let's set this type in the setup handler, which is
called before newlink handler.

Introduced by commit b9959fd3b0fa ("vti: switch to new ip tunnel code").

CC: Cong Wang <amwang@redhat.com>
CC: Steffen Klassert <steffen.klassert@secunet.com>
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/ipv4/ip_vti.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/ip_vti.c b/net/ipv4/ip_vti.c
index 687ddef4e574..afcee51b90ed 100644
--- a/net/ipv4/ip_vti.c
+++ b/net/ipv4/ip_vti.c
@@ -337,6 +337,7 @@ static const struct net_device_ops vti_netdev_ops = {
 static void vti_tunnel_setup(struct net_device *dev)
 {
 	dev->netdev_ops		= &vti_netdev_ops;
+	dev->type		= ARPHRD_TUNNEL;
 	ip_tunnel_setup(dev, vti_net_id);
 }
 
@@ -348,7 +349,6 @@ static int vti_tunnel_init(struct net_device *dev)
 	memcpy(dev->dev_addr, &iph->saddr, 4);
 	memcpy(dev->broadcast, &iph->daddr, 4);
 
-	dev->type		= ARPHRD_TUNNEL;
 	dev->hard_header_len	= LL_MAX_HEADER + sizeof(struct iphdr);
 	dev->mtu		= ETH_DATA_LEN;
 	dev->flags		= IFF_NOARP;
-- 
1.9.0
