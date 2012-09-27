From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next 3/3] ipv4: gre: add GRO capability
Date: Thu, 27 Sep 2012 14:48:50 +0200
Message-ID: <1348750130.5093.1227.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:40650 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751355Ab2I0Msy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Sep 2012 08:48:54 -0400
Received: by bkcjk13 with SMTP id jk13so1706677bkc.19
        for <netdev@vger.kernel.org>; Thu, 27 Sep 2012 05:48:53 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Add GRO capability to IPv4 GRE tunnels, using the gro_cells
infrastructure.

Tested using IPv4 and IPv6 TCP traffic inside this tunnel, and
checking GRO is building large packets.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/ipip.h |    3 +++
 net/ipv4/ip_gre.c  |   13 +++++++++++--
 2 files changed, 14 insertions(+), 2 deletions(-)

diff --git a/include/net/ipip.h b/include/net/ipip.h
index a93cf6d..ddc077c 100644
--- a/include/net/ipip.h
+++ b/include/net/ipip.h
@@ -2,6 +2,7 @@
 #define __NET_IPIP_H 1
 
 #include <linux/if_tunnel.h>
+#include <net/gro_cells.h>
 #include <net/ip.h>
 
 /* Keep error state on tunnel for 30 sec */
@@ -36,6 +37,8 @@ struct ip_tunnel {
 #endif
 	struct ip_tunnel_prl_entry __rcu *prl;		/* potential router list */
 	unsigned int			prl_count;	/* # of entries in PRL */
+
+	struct gro_cells		gro_cells;
 };
 
 struct ip_tunnel_prl_entry {
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index f233c1d..1f00b30 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -714,8 +714,7 @@ static int ipgre_rcv(struct sk_buff *skb)
 		skb_reset_network_header(skb);
 		ipgre_ecn_decapsulate(iph, skb);
 
-		netif_rx(skb);
-
+		gro_cells_receive(&tunnel->gro_cells, skb);
 		rcu_read_unlock();
 		return 0;
 	}
@@ -1296,6 +1295,9 @@ static const struct net_device_ops ipgre_netdev_ops = {
 
 static void ipgre_dev_free(struct net_device *dev)
 {
+	struct ip_tunnel *tunnel = netdev_priv(dev);
+
+	gro_cells_destroy(&tunnel->gro_cells);
 	free_percpu(dev->tstats);
 	free_netdev(dev);
 }
@@ -1327,6 +1329,7 @@ static int ipgre_tunnel_init(struct net_device *dev)
 {
 	struct ip_tunnel *tunnel;
 	struct iphdr *iph;
+	int err;
 
 	tunnel = netdev_priv(dev);
 	iph = &tunnel->parms.iph;
@@ -1353,6 +1356,12 @@ static int ipgre_tunnel_init(struct net_device *dev)
 	if (!dev->tstats)
 		return -ENOMEM;
 
+	err = gro_cells_init(&tunnel->gro_cells, dev);
+	if (err) {
+		free_percpu(dev->tstats);
+		return err;
+	}
+
 	return 0;
 }
 
