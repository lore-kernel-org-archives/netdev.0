From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next 1/4] ipmr: __pim_rcv() is called under
 rcu_read_lock
Date: Sat, 02 Oct 2010 04:14:55 +0200
Message-ID: <1285985695.2582.521.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:54582 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751375Ab0JBCPA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Oct 2010 22:15:00 -0400
Received: by fxm14 with SMTP id 14so992146fxm.19
        for <netdev@vger.kernel.org>; Fri, 01 Oct 2010 19:14:59 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

No need to get a reference on reg_dev and release it, we are in a
rcu_read_lock() protected section.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv4/ipmr.c |   10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 10b24c0..1a92ebd 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -1805,6 +1805,7 @@ dont_forward:
 }
 
 #ifdef CONFIG_IP_PIMSM
+/* called with rcu_read_lock() */
 static int __pim_rcv(struct mr_table *mrt, struct sk_buff *skb,
 		     unsigned int pimlen)
 {
@@ -1826,26 +1827,23 @@ static int __pim_rcv(struct mr_table *mrt, struct sk_buff *skb,
 	read_lock(&mrt_lock);
 	if (mrt->mroute_reg_vif_num >= 0)
 		reg_dev = mrt->vif_table[mrt->mroute_reg_vif_num].dev;
-	if (reg_dev)
-		dev_hold(reg_dev);
 	read_unlock(&mrt_lock);
 
 	if (reg_dev == NULL)
 		return 1;
 
 	skb->mac_header = skb->network_header;
-	skb_pull(skb, (u8*)encap - skb->data);
+	skb_pull(skb, (u8 *)encap - skb->data);
 	skb_reset_network_header(skb);
 	skb->protocol = htons(ETH_P_IP);
-	skb->ip_summed = 0;
+	skb->ip_summed = CHECKSUM_NONE;
 	skb->pkt_type = PACKET_HOST;
 
 	skb_tunnel_rx(skb, reg_dev);
 
 	netif_rx(skb);
-	dev_put(reg_dev);
 
-	return 0;
+	return NET_RX_SUCCESS;
 }
 #endif
 


