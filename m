From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 2.6.7-rc3-mm2 3/5] via-velocity: velocity_receive_frame diets
Date: Fri, 18 Jun 2004 22:13:36 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040618221336.B20210@electric-eye.fr.zoreil.com>
References: <20040618221014.A15640@electric-eye.fr.zoreil.com> <20040618221142.A20210@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: alan@redhat.com, akpm@osdl.org, jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20040618221142.A20210@electric-eye.fr.zoreil.com>; from romieu@fr.zoreil.com on Fri, Jun 18, 2004 at 10:11:42PM +0200
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Weight loss in velocity_receive_frame():
- isolate the ip header alignment tsk from velocity_receive_frame();
- following p.30 of the datasheet, rdesc0.len includes the CRC length:
  the amount of data copied during the ip alignment can be shortened.

diff -puN drivers/net/via-velocity.c~via-velocity-40 drivers/net/via-velocity.c
--- linux-2.6.7-rc3/drivers/net/via-velocity.c~via-velocity-40	2004-06-18 21:38:59.000000000 +0200
+++ linux-2.6.7-rc3-fr/drivers/net/via-velocity.c	2004-06-18 21:58:58.000000000 +0200
@@ -1255,6 +1255,28 @@ static inline void velocity_rx_csum(stru
 }
 
 /**
+ *	velocity_iph_realign	-	IP header alignment
+ *	@vptr: velocity we are handling
+ *	@skb: network layer packet buffer
+ *	@pkt_size: received data size
+ *
+ *	Align IP header on a 2 bytes boundary. This behavior can be
+ *	configured by the user.
+ */
+static inline void velocity_iph_realign(struct velocity_info *vptr,
+					struct sk_buff *skb, int pkt_size)
+{
+	/* FIXME - memmove ? */
+	if (vptr->flags & VELOCITY_FLAGS_IP_ALIGN) {
+		int i;
+
+		for (i = pkt_size; i >= 0; i--)
+			*(skb->data + i + 2) = *(skb->data + i);
+		skb_reserve(skb, 2);
+	}
+}
+
+/**
  *	velocity_receive_frame	-	received packet processor
  *	@vptr: velocity we are handling
  *	@idx: ring index
@@ -1268,6 +1290,7 @@ static int velocity_receive_frame(struct
 	struct net_device_stats *stats = &vptr->stats;
 	struct velocity_rd_info *rd_info = &(vptr->rd_info[idx]);
 	struct rx_desc *rd = &(vptr->rd_ring[idx]);
+	int pkt_len = rd->rdesc0.len;
 	struct sk_buff *skb;
 
 	if (rd->rdesc0.RSR & (RSR_STP | RSR_EDP)) {
@@ -1287,16 +1310,9 @@ static int velocity_receive_frame(struct
 	rd_info->skb_dma = (dma_addr_t) NULL;
 	rd_info->skb = NULL;
 
-	/* FIXME - memmove ? */
-	if (vptr->flags & VELOCITY_FLAGS_IP_ALIGN) {
-		int i;
-		for (i = rd->rdesc0.len + 4; i >= 0; i--)
-			*(skb->data + i + 2) = *(skb->data + i);
-		skb->data += 2;
-		skb->tail += 2;
-	}
+	velocity_iph_realign(vptr, skb, pkt_len);
 
-	skb_put(skb, (rd->rdesc0.len - 4));
+	skb_put(skb, pkt_len - 4);
 	skb->protocol = eth_type_trans(skb, skb->dev);
 
 	/*
@@ -1316,7 +1332,7 @@ static int velocity_receive_frame(struct
 	 *	FIXME: need rx_copybreak handling
 	 */
 
-	stats->rx_bytes += skb->len;
+	stats->rx_bytes += pkt_len;
 	netif_rx(skb);
 
 	return 0;

_
