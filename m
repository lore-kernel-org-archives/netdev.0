From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 2.6.7-rc3-mm2 4/5] via-velocity: Rx buffers allocation rework
Date: Fri, 18 Jun 2004 22:14:44 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040618221444.C20210@electric-eye.fr.zoreil.com>
References: <20040618221014.A15640@electric-eye.fr.zoreil.com> <20040618221142.A20210@electric-eye.fr.zoreil.com> <20040618221336.B20210@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: alan@redhat.com, akpm@osdl.org, jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20040618221336.B20210@electric-eye.fr.zoreil.com>; from romieu@fr.zoreil.com on Fri, Jun 18, 2004 at 10:13:36PM +0200
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Rework of the Rx buffers allocation:
- Rx irq handler (velocity_rx_srv): defer the Rx buffer allocation until
  the packet processing loop is done;
- a separate index related to the Rx descriptor ("rd_dirty") is introduced
  to distinguish the first Rx descriptor whose buffer has to be refilled.
  This way the driver does not need to confuse this descriptor with the
  most recently netif()ed one. Rationale: batch + rx_copybreak;
- dirty/empty Rx descriptors are identified through the whole driver
  via an adequate NULL pointer in the velocity_rd_info[] array (see
  velocity_rx_refill() and velocity_receive_frame());
- Rx descriptors need to be grouped by a multiple of 4 before they can
  be handed back to the asic (hardware constraint). This task is moved
  from the Rx processing loop to the Rx refill function;
- factorization of code in velocity_init_rd_ring().

diff -puN drivers/net/via-velocity.c~via-velocity-50 drivers/net/via-velocity.c
--- linux-2.6.7-rc3/drivers/net/via-velocity.c~via-velocity-50	2004-06-18 21:56:21.000000000 +0200
+++ linux-2.6.7-rc3-fr/drivers/net/via-velocity.c	2004-06-18 21:56:21.000000000 +0200
@@ -485,7 +485,7 @@ static void velocity_rx_reset(struct vel
 	struct mac_regs * regs = vptr->mac_regs;
 	int i;
 
-	vptr->rd_used = vptr->rd_curr = 0;
+	vptr->rd_dirty = vptr->rd_filled = vptr->rd_curr = 0;
 
 	/*
 	 *	Init state, all RD entries belong to the NIC
@@ -980,6 +980,49 @@ static void velocity_free_rings(struct v
 	pci_free_consistent(vptr->pdev, size, vptr->tx_bufs, vptr->tx_bufs_dma);
 }
 
+static inline void velocity_give_many_rx_descs(struct velocity_info *vptr)
+{
+	struct mac_regs *regs = vptr->mac_regs;
+	int avail, dirty, unusable;
+
+	/*
+	 * RD number must be equal to 4X per hardware spec
+	 * (programming guide rev 1.20, p.13)
+	 */
+	if (vptr->rd_filled < 4)
+		return;
+
+	unusable = vptr->rd_filled | 0x0003;
+	dirty = vptr->rd_dirty - unusable + 1;
+	for (avail = vptr->rd_filled & 0xfffc; avail; avail--) {
+		dirty = (dirty > 0) ? dirty - 1 : vptr->options.numrx - 1;
+		velocity_give_rx_desc(vptr->rd_ring + dirty);
+	}
+
+	writew(vptr->rd_filled & 0xfffc, &regs->RBRDU);
+	vptr->rd_filled = unusable;
+}
+
+static int velocity_rx_refill(struct velocity_info *vptr)
+{
+	int dirty = vptr->rd_dirty, done = 0, ret = 0;
+
+	while (!vptr->rd_info[dirty].skb) {
+		ret = velocity_alloc_rx_buf(vptr, dirty);
+		if (ret < 0)
+			break;
+		done++;
+		dirty = (dirty < vptr->options.numrx - 1) ? dirty + 1 : 0;	
+	}
+	if (done) {
+		vptr->rd_dirty = dirty;
+		vptr->rd_filled += done;
+		velocity_give_many_rx_descs(vptr);
+	}
+
+	return ret;
+}
+
 /**
  *	velocity_init_rd_ring	-	set up receive ring
  *	@vptr: velocity to configure
@@ -990,9 +1033,7 @@ static void velocity_free_rings(struct v
 
 static int velocity_init_rd_ring(struct velocity_info *vptr)
 {
-	int i, ret = -ENOMEM;
-	struct rx_desc *rd;
-	struct velocity_rd_info *rd_info;
+	int ret = -ENOMEM;
 	unsigned int rsize = sizeof(struct velocity_rd_info) *
 					vptr->options.numrx;
 
@@ -1001,22 +1042,14 @@ static int velocity_init_rd_ring(struct 
 		goto out;
 	memset(vptr->rd_info, 0, rsize);
 
-	/* Init the RD ring entries */
-	for (i = 0; i < vptr->options.numrx; i++) {
-		rd = &(vptr->rd_ring[i]);
-		rd_info = &(vptr->rd_info[i]);
+	vptr->rd_filled = vptr->rd_dirty = vptr->rd_curr = 0;
 
-		ret = velocity_alloc_rx_buf(vptr, i);
-		if (ret < 0) {
-			VELOCITY_PRT(MSG_LEVEL_ERR, KERN_ERR
-				"%s: failed to allocate RX buffer.\n",
-				vptr->dev->name);
-			velocity_free_rd_ring(vptr);
-			goto out;
-		}
-		velocity_give_rx_desc(rd);
+	ret = velocity_rx_refill(vptr);
+	if (ret < 0) {
+		VELOCITY_PRT(MSG_LEVEL_ERR, KERN_ERR
+			"%s: failed to allocate RX buffer.\n", vptr->dev->name);
+		velocity_free_rd_ring(vptr);
 	}
-	vptr->rd_used = vptr->rd_curr = 0;
 out:
 	return ret;
 }
@@ -1160,22 +1193,14 @@ static void velocity_free_td_ring(struct
 
 static int velocity_rx_srv(struct velocity_info *vptr, int status)
 {
-	struct rx_desc *rd;
 	struct net_device_stats *stats = &vptr->stats;
-	struct mac_regs * regs = vptr->mac_regs;
 	int rd_curr = vptr->rd_curr;
 	int works = 0;
 
 	while (1) {
+		struct rx_desc *rd = vptr->rd_ring + rd_curr;
 
-		rd = &(vptr->rd_ring[rd_curr]);
-
-		if ((vptr->rd_info[rd_curr]).skb == NULL) {
-			if (velocity_alloc_rx_buf(vptr, rd_curr) < 0)
-				break;
-		}
-
-		if (works++ > 15)
+		if (!vptr->rd_info[rd_curr].skb || (works++ > 15))
 			break;
 
 		if (rd->rdesc0.owner == OWNED_BY_NIC)
@@ -1186,14 +1211,8 @@ static int velocity_rx_srv(struct veloci
 		 *	FIXME: need to handle copybreak
 		 */
 		if ((rd->rdesc0.RSR & RSR_RXOK) || (!(rd->rdesc0.RSR & RSR_RXOK) && (rd->rdesc0.RSR & (RSR_CE | RSR_RL)))) {
-			if (velocity_receive_frame(vptr, rd_curr) == 0) {
-				if (velocity_alloc_rx_buf(vptr, rd_curr) < 0) {
-					VELOCITY_PRT(MSG_LEVEL_ERR, KERN_ERR "%s: can not allocate rx buf\n", vptr->dev->name);
-					break;
-				}
-			} else {
+			if (velocity_receive_frame(vptr, rd_curr) < 0)
 				stats->rx_dropped++;
-			}
 		} else {
 			if (rd->rdesc0.RSR & RSR_CRC)
 				stats->rx_crc_errors++;
@@ -1205,24 +1224,18 @@ static int velocity_rx_srv(struct veloci
 
 		rd->inten = 1;
 
-		if (++vptr->rd_used >= 4) {
-			int i, rd_prev = rd_curr;
-			for (i = 0; i < 4; i++) {
-				if (--rd_prev < 0)
-					rd_prev = vptr->options.numrx - 1;
-
-				velocity_give_rx_desc(vptr->rd_ring + rd_prev);
-			}
-			writew(4, &(regs->RBRDU));
-			vptr->rd_used -= 4;
-		}
-
 		vptr->dev->last_rx = jiffies;
 
 		rd_curr++;
 		if (rd_curr >= vptr->options.numrx)
 			rd_curr = 0;
 	}
+
+	if (velocity_rx_refill(vptr) < 0) {
+		VELOCITY_PRT(MSG_LEVEL_ERR, KERN_ERR
+			"%s: rx buf allocation failure\n", vptr->dev->name);
+	}
+
 	vptr->rd_curr = rd_curr;
 	VAR_USED(stats);
 	return works;
diff -puN drivers/net/via-velocity.h~via-velocity-50 drivers/net/via-velocity.h
--- linux-2.6.7-rc3/drivers/net/via-velocity.h~via-velocity-50	2004-06-18 21:56:21.000000000 +0200
+++ linux-2.6.7-rc3-fr/drivers/net/via-velocity.h	2004-06-18 21:56:21.000000000 +0200
@@ -1771,7 +1771,8 @@ struct velocity_info {
 	struct velocity_td_info *td_infos[TX_QUEUE_NO];
 
 	int rd_curr;
-	int rd_used;
+	int rd_dirty;
+	u32 rd_filled;
 	struct rx_desc *rd_ring;
 	struct velocity_rd_info *rd_info;	/* It's an array */
 

_
