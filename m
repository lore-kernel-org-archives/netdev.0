From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH] econet: have failed ec_queue_packet() call return
	NET_RX_BAD
Date: Sat, 20 Jun 2009 12:53:25 +0200
Message-ID: <20090620105325.GC31266@Chamillionaire.breakpoint.cc>
References: <20090620200438.b5443520.lk-netdev@lk-netdev.nosense.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Mark Smith <lk-netdev@lk-netdev.nosense.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:50281 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751214AbZFTKxY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Jun 2009 06:53:24 -0400
Content-Disposition: inline
In-Reply-To: <20090620200438.b5443520.lk-netdev@lk-netdev.nosense.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mark Smith <lk-netdev@lk-netdev.nosense.org> wrote:
> econet_rcv() calls ec_queue_packet(). The return from ec_queue_packet()
> is the direct result of a call to sock_queue_rcv_skb(). Error returns
> from ec_queue_packet() and therefore sock_queue_rcv_skb() are due to
> kernel errors, so have econet_rcv() return NET_RX_BAD in this case.

What about doing this instead?

From: Florian Westphal <fw@strlen.de>
Date: Sat, 20 Jun 2009 12:39:05 +0200
Subject: [PATCH] net: remove NET_RX_BAD and NET_RX_CN* defines

almost no users in the tree; and the few that use them treat them
like NET_RX_DROP.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 drivers/net/rionet.c            |    5 -----
 drivers/net/wan/farsync.c       |   19 -------------------
 drivers/staging/otus/wrap_pkt.c |    3 ---
 include/linux/netdevice.h       |    4 ----
 net/decnet/dn_route.c           |    2 +-
 net/lapb/lapb_iface.c           |    2 +-
 6 files changed, 2 insertions(+), 33 deletions(-)

diff --git a/drivers/net/rionet.c b/drivers/net/rionet.c
index 8702e7a..74cdb6f 100644
--- a/drivers/net/rionet.c
+++ b/drivers/net/rionet.c
@@ -114,11 +114,6 @@ static int rionet_rx_clean(struct net_device *ndev)
 
 		if (error == NET_RX_DROP) {
 			ndev->stats.rx_dropped++;
-		} else if (error == NET_RX_BAD) {
-			if (netif_msg_rx_err(rnet))
-				printk(KERN_WARNING "%s: bad rx packet\n",
-				       DRV_NAME);
-			ndev->stats.rx_errors++;
 		} else {
 			ndev->stats.rx_packets++;
 			ndev->stats.rx_bytes += RIO_MAX_MSG_SIZE;
diff --git a/drivers/net/wan/farsync.c b/drivers/net/wan/farsync.c
index 25c9ef6..90c0a31 100644
--- a/drivers/net/wan/farsync.c
+++ b/drivers/net/wan/farsync.c
@@ -792,25 +792,6 @@ fst_process_rx_status(int rx_status, char *name)
 			 */
 			break;
 		}
-
-	case NET_RX_CN_LOW:
-		{
-			dbg(DBG_ASS, "%s: Receive Low Congestion\n", name);
-			break;
-		}
-
-	case NET_RX_CN_MOD:
-		{
-			dbg(DBG_ASS, "%s: Receive Moderate Congestion\n", name);
-			break;
-		}
-
-	case NET_RX_CN_HIGH:
-		{
-			dbg(DBG_ASS, "%s: Receive High Congestion\n", name);
-			break;
-		}
-
 	case NET_RX_DROP:
 		{
 			dbg(DBG_ASS, "%s: Received packet dropped\n", name);
diff --git a/drivers/staging/otus/wrap_pkt.c b/drivers/staging/otus/wrap_pkt.c
index 5db0004..89a6b92 100644
--- a/drivers/staging/otus/wrap_pkt.c
+++ b/drivers/staging/otus/wrap_pkt.c
@@ -156,10 +156,7 @@ void zfLnxRecvEth(zdev_t* dev, zbuf_t* buf, u16_t port)
     switch(netif_rx(buf))
 #endif
     {
-    case NET_RX_BAD:
     case NET_RX_DROP:
-    case NET_RX_CN_MOD:
-    case NET_RX_CN_HIGH:
         break;
     default:
             macp->drv_stats.net_stats.rx_packets++;
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index d4a4d98..9f25ab2 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -72,10 +72,6 @@ struct wireless_dev;
 /* Backlog congestion levels */
 #define NET_RX_SUCCESS		0   /* keep 'em coming, baby */
 #define NET_RX_DROP		1  /* packet dropped */
-#define NET_RX_CN_LOW		2   /* storm alert, just in case */
-#define NET_RX_CN_MOD		3   /* Storm on its way! */
-#define NET_RX_CN_HIGH		4   /* The storm is here */
-#define NET_RX_BAD		5  /* packet dropped due to kernel error */
 
 /* NET_XMIT_CN is special. It does not guarantee that this packet is lost. It
  * indicates that the device will soon be dropping packets, or already drops
diff --git a/net/decnet/dn_route.c b/net/decnet/dn_route.c
index 1d6ca8a..9383d3e 100644
--- a/net/decnet/dn_route.c
+++ b/net/decnet/dn_route.c
@@ -774,7 +774,7 @@ static int dn_rt_bug(struct sk_buff *skb)
 
 	kfree_skb(skb);
 
-	return NET_RX_BAD;
+	return NET_RX_DROP;
 }
 
 static int dn_rt_set_next_hop(struct dn_route *rt, struct dn_fib_res *res)
diff --git a/net/lapb/lapb_iface.c b/net/lapb/lapb_iface.c
index 2ba1bc4..bda96d1 100644
--- a/net/lapb/lapb_iface.c
+++ b/net/lapb/lapb_iface.c
@@ -407,7 +407,7 @@ int lapb_data_indication(struct lapb_cb *lapb, struct sk_buff *skb)
 		return lapb->callbacks.data_indication(lapb->dev, skb);
 
 	kfree_skb(skb);
-	return NET_RX_CN_HIGH; /* For now; must be != NET_RX_DROP */
+	return NET_RX_SUCCESS; /* For now; must be != NET_RX_DROP */
 }
 
 int lapb_data_transmit(struct lapb_cb *lapb, struct sk_buff *skb)
-- 
1.6.0.6

