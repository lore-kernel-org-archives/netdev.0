From: "Ravinandan Arakali" <ravinandan.arakali@s2io.com>
Subject: [PATCH 2.6.9-rc2 3/8] S2io: optimizations
Date: Wed, 13 Oct 2004 18:14:40 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <004601c4b18b$2ee81a30$6c10100a@S2IOtech.com>
Reply-To: <ravinandan.arakali@s2io.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_NextPart_000_0047_01C4B150.82894230"
Cc: <netdev@oss.sgi.com>, <leonid.grossman@s2io.com>,
        <raghavendra.koushik@s2io.com>, <rapuru.sriram@s2io.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "'Jeff Garzik'" <jgarzik@pobox.com>,
        "'Francois Romieu'" <romieu@fr.zoreil.com>
In-Reply-To: 
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.

------=_NextPart_000_0047_01C4B150.82894230
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,
Following are the optimization-related changes made in this patch.

1. Definitions of LOW and PANIC levels of the Rx buffers have changed.
2. In wait_for_cmd_complete there is no longer a writeq but just a read and
wait for strobe bit to reset.
3. In s2io_isr, the isr_lock has been done away with also the NICs interrupt
are no longer disabled explicitly on entering the interrupt handler and
re-enabled again before leaving it.
4. Also clearing the semaphore "tasklet_status" when exiting erroneously
from s2io_isr after failing fill_rx_buffer call.
5. The set/reset Tx Csum function through ethtool was added to the
ethtool_ops structure.
6. Added a Rx side error code in the rx_osm_handler function.
7. No longer stopping and waking Tx queue when link state changes in
s2io_link function.
8. removed the isr_lock spinlock from the s2io_nic structure.

Signed-off-by: Raghavendra Koushik <raghavendra.koushik@s2io.com>

------=_NextPart_000_0047_01C4B150.82894230
Content-Type: application/octet-stream;
	name="s2io_optimizations.patch3"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
	filename="s2io_optimizations.patch3"

diff -urN vanilla-linux/drivers/net/s2io.c =
linux-2.6.8.1/drivers/net/s2io.c
--- vanilla-linux/drivers/net/s2io.c	2004-10-06 17:24:02.000000000 -0700
+++ linux-2.6.8.1/drivers/net/s2io.c	2004-10-06 17:37:32.751003528 -0700
@@ -80,10 +80,11 @@
 static inline int rx_buffer_level(nic_t * sp, int rxb_size, int ring)
 {
 	int level =3D 0;
-	if ((sp->pkt_cnt[ring] - rxb_size) > 128) {
+	if ((sp->pkt_cnt[ring] - rxb_size) > 16) {
 		level =3D LOW;
-		if (rxb_size < sp->pkt_cnt[ring] / 8)
+		if ((sp->pkt_cnt[ring] - rxb_size) < MAX_RXDS_PER_BLOCK) {
 			level =3D PANIC;
+		}
 	}
=20
 	return level;
@@ -1916,12 +1917,8 @@
 	u64 val64;
=20
 	while (TRUE) {
-		val64 =3D
-		    RMAC_ADDR_CMD_MEM_RD | RMAC_ADDR_CMD_MEM_STROBE_NEW_CMD
-		    | RMAC_ADDR_CMD_MEM_OFFSET(0);
-		writeq(val64, &bar0->rmac_addr_cmd_mem);
 		val64 =3D readq(&bar0->rmac_addr_cmd_mem);
-		if (!val64) {
+		if (!(val64 & RMAC_ADDR_CMD_MEM_STROBE_CMD_EXECUTING)) {
 			ret =3D SUCCESS;
 			break;
 		}
@@ -2192,14 +2189,11 @@
 	register u64 val64 =3D 0;
 	u16 cnt =3D 0;
=20
-	spin_lock(&sp->isr_lock);
 	netif_stop_queue(dev);
=20
 	/* disable Tx and Rx traffic on the NIC */
 	stop_nic(sp);
=20
-	spin_unlock(&sp->isr_lock);
-
 	/*=20
 	 * If the device tasklet is running, wait till its done=20
 	 * before killing it=20
@@ -2398,15 +2392,13 @@
 	struct net_device *dev =3D (struct net_device *) dev_id;
 	nic_t *sp =3D dev->priv;
 	XENA_dev_config_t *bar0 =3D (XENA_dev_config_t *) sp->bar0;
-	u64 reason =3D 0, general_mask =3D 0;
+	u64 reason =3D 0;
 	mac_info_t *mac_control;
 	struct config_param *config;
=20
 	mac_control =3D &sp->mac_control;
 	config =3D &sp->config;
=20
-	spin_lock(&sp->isr_lock);
-
 	/*=20
 	 * Identify the cause for interrupt and call the appropriate
 	 * interrupt handler. Causes for the interrupt could be;
@@ -2419,14 +2411,9 @@
=20
 	if (!reason) {
 		/* The interrupt was not raised by Xena. */
-		spin_unlock(&sp->isr_lock);
 		return IRQ_NONE;
 	}
=20
-	/* Mask the Interrupts on the NIC. */
-	general_mask =3D readq(&bar0->general_int_mask);
-	writeq(0xFFFFFFFFFFFFFFFFULL, &bar0->general_int_mask);
-
 	/* If Intr is because of Tx Traffic */
 	if (reason & GEN_INTR_TXTRAFFIC) {
 		tx_intr_handler(sp);
@@ -2441,11 +2428,6 @@
 		if (netif_rx_schedule_prep(dev)) {
 			en_dis_able_nic_intrs(sp, RX_TRAFFIC_INTR,
 					      DISABLE_INTRS);
-			/*=20
-			 * Here we take a snap shot of the general=20
-			 * Intr Register.
-			 */
-			general_mask =3D readq(&bar0->general_int_mask);
 			__netif_rx_schedule(dev);
 		}
 	}
@@ -2481,9 +2463,9 @@
 						  "%s:Out of memory",
 						  dev->name);
 					DBG_PRINT(ERR_DBG, " in ISR!!\n");
-					writeq(general_mask,
-					       &bar0->general_int_mask);
-					spin_unlock(&sp->isr_lock);
+					clear_bit(0,
+						  (unsigned long *) (&sp->
+								     tasklet_status));
 					return IRQ_HANDLED;
 				}
 				clear_bit(0,
@@ -2501,10 +2483,6 @@
 	tasklet_schedule(&sp->task);
 #endif
=20
-	/* Unmask all previously enabled interrupts on the NIC. */
-	writeq(general_mask, &bar0->general_int_mask);
-
-	spin_unlock(&sp->isr_lock);
 	return IRQ_HANDLED;
 }
=20
@@ -3626,6 +3604,17 @@
 	return (S2IO_STAT_LEN);
 }
=20
+int s2io_ethtool_op_set_tx_csum(struct net_device *dev, u32 data)
+{
+	if (data)
+		dev->features |=3D NETIF_F_IP_CSUM;
+	else
+		dev->features &=3D ~NETIF_F_IP_CSUM;
+
+	return 0;
+}
+
+
 static struct ethtool_ops netdev_ethtool_ops =3D {
 	.get_settings =3D s2io_ethtool_gset,
 	.set_settings =3D s2io_ethtool_sset,
@@ -3641,7 +3630,7 @@
 	.get_rx_csum =3D s2io_ethtool_get_rx_csum,
 	.set_rx_csum =3D s2io_ethtool_set_rx_csum,
 	.get_tx_csum =3D ethtool_op_get_tx_csum,
-	.set_tx_csum =3D ethtool_op_set_tx_csum,
+	.set_tx_csum =3D s2io_ethtool_op_set_tx_csum,
 	.get_sg =3D ethtool_op_get_sg,
 	.set_sg =3D ethtool_op_set_sg,
 #ifdef NETIF_F_TSO
@@ -3902,6 +3891,12 @@
 		skb->ip_summed =3D CHECKSUM_NONE;
 	}
=20
+	if (rxdp->Control_1 & RXD_T_CODE) {
+		unsigned long long err =3D rxdp->Control_1 & RXD_T_CODE;
+		DBG_PRINT(ERR_DBG, "%s: Rx error Value: 0x%llx\n",
+			  dev->name, err);
+	}
+
 	skb->dev =3D dev;
 	skb_put(skb, len);
 	skb->protocol =3D eth_type_trans(skb, dev);
@@ -3922,25 +3917,6 @@
 	return SUCCESS;
 }
=20
-int check_for_tx_space(nic_t * sp)
-{
-	u32 put_off, get_off, queue_len;
-	int ret =3D TRUE, i;
-
-	for (i =3D 0; i < sp->config.tx_fifo_num; i++) {
-		queue_len =3D sp->mac_control.tx_curr_put_info[i].fifo_len
-		    + 1;
-		put_off =3D sp->mac_control.tx_curr_put_info[i].offset;
-		get_off =3D sp->mac_control.tx_curr_get_info[i].offset;
-		if (((put_off + 1) % queue_len) =3D=3D get_off) {
-			ret =3D FALSE;
-			break;
-		}
-	}
-
-	return ret;
-}
-
 /**
  *  s2io_link - stops/starts the Tx queue.
  *  @sp : private member of the device structure, which is a pointer to =
the
@@ -3962,17 +3938,9 @@
 		if (link =3D=3D LINK_DOWN) {
 			DBG_PRINT(ERR_DBG, "%s: Link down\n", dev->name);
 			netif_carrier_off(dev);
-			netif_stop_queue(dev);
 		} else {
 			DBG_PRINT(ERR_DBG, "%s: Link Up\n", dev->name);
 			netif_carrier_on(dev);
-			if (check_for_tx_space(sp) =3D=3D TRUE) {
-				/*
-				 * Dont wake the queue if we know there
-				 * are no free TxDs available.
-				 */
-				netif_wake_queue(dev);
-			}
 		}
 	}
 	sp->last_link_state =3D link;
@@ -4357,7 +4325,6 @@
=20
 	/* Initialize spinlocks */
 	spin_lock_init(&sp->tx_lock);
-	spin_lock_init(&sp->isr_lock);
=20
 	/*=20
 	 * SXE-002: Configure link and activity LED to init state=20
diff -urN vanilla-linux/drivers/net/s2io.h =
linux-2.6.8.1/drivers/net/s2io.h
--- vanilla-linux/drivers/net/s2io.h	2004-10-06 17:24:05.000000000 -0700
+++ linux-2.6.8.1/drivers/net/s2io.h	2004-10-06 17:37:47.532756360 -0700
@@ -612,7 +612,6 @@
 	atomic_t rx_bufs_left[MAX_RX_RINGS];
=20
 	spinlock_t tx_lock;
-	spinlock_t isr_lock;
=20
 #define PROMISC     1
 #define ALL_MULTI   2

------=_NextPart_000_0047_01C4B150.82894230--
