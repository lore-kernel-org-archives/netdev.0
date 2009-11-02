From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] icmp: icmp_send() can avoid a dev_put()
Date: Mon, 02 Nov 2009 06:31:03 +0100
Message-ID: <4AEE6E97.5070809@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:58046 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750778AbZKBFbE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Nov 2009 00:31:04 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We can avoid touching device refcount in icmp_send(),
using dev_get_by_index_rcu()

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---

diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index 84adb57..fe11f60 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -501,15 +501,16 @@ void icmp_send(struct sk_buff *skb_in, int type, int code, __be32 info)
 	if (!(rt->rt_flags & RTCF_LOCAL)) {
 		struct net_device *dev = NULL;
 
+		rcu_read_lock();
 		if (rt->fl.iif &&
 			net->ipv4.sysctl_icmp_errors_use_inbound_ifaddr)
-			dev = dev_get_by_index(net, rt->fl.iif);
+			dev = dev_get_by_index_rcu(net, rt->fl.iif);
 
-		if (dev) {
+		if (dev)
 			saddr = inet_select_addr(dev, 0, RT_SCOPE_LINK);
-			dev_put(dev);
-		} else
+		else
 			saddr = 0;
+		rcu_read_unlock();
 	}
 
 	tos = icmp_pointers[type].error ? ((iph->tos & IPTOS_TOS_MASK) |
