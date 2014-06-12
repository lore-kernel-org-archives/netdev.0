From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net] vxlan: use dev->needed_headroom instead of dev->hard_header_len
Date: Thu, 12 Jun 2014 11:53:10 -0700
Message-ID: <1402599190-24350-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	stephen hemminger <stephen@networkplumber.org>,
	Pravin B Shelar <pshelar@nicira.com>,
	Cong Wang <cwang@twopensource.com>,
	Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:52954 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750790AbaFLSxY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jun 2014 14:53:24 -0400
Received: by mail-pd0-f175.google.com with SMTP id v10so367139pde.34
        for <netdev@vger.kernel.org>; Thu, 12 Jun 2014 11:53:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <cwang@twopensource.com>

When we mirror packets from a vxlan tunnel to other device,
the mirror device should see the same packets (that is, without
outer header). Because vxlan tunnel sets dev->hard_header_len,
tcf_mirred() resets mac header back to outer mac, the mirror device
actually sees packets with outer headers

Vxlan tunnel should set dev->needed_headroom instead of
dev->hard_header_len, like what other ip tunnels do. This fixes
the above problem.

Cc: "David S. Miller" <davem@davemloft.net>
Cc: stephen hemminger <stephen@networkplumber.org>
Cc: Pravin B Shelar <pshelar@nicira.com>
Signed-off-by: Cong Wang <cwang@twopensource.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

---
diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 1610d51..e0995ff 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -2247,9 +2247,9 @@ static void vxlan_setup(struct net_device *dev)
 	eth_hw_addr_random(dev);
 	ether_setup(dev);
 	if (vxlan->default_dst.remote_ip.sa.sa_family == AF_INET6)
-		dev->hard_header_len = ETH_HLEN + VXLAN6_HEADROOM;
+		dev->needed_headroom = ETH_HLEN + VXLAN6_HEADROOM;
 	else
-		dev->hard_header_len = ETH_HLEN + VXLAN_HEADROOM;
+		dev->needed_headroom = ETH_HLEN + VXLAN_HEADROOM;
 
 	dev->netdev_ops = &vxlan_netdev_ops;
 	dev->destructor = free_netdev;
@@ -2646,8 +2646,7 @@ static int vxlan_newlink(struct net *net, struct net_device *dev,
 		if (!tb[IFLA_MTU])
 			dev->mtu = lowerdev->mtu - (use_ipv6 ? VXLAN6_HEADROOM : VXLAN_HEADROOM);
 
-		/* update header length based on lower device */
-		dev->hard_header_len = lowerdev->hard_header_len +
+		dev->needed_headroom = lowerdev->hard_header_len +
 				       (use_ipv6 ? VXLAN6_HEADROOM : VXLAN_HEADROOM);
 	} else if (use_ipv6)
 		vxlan->flags |= VXLAN_F_IPV6;
