From: Ben Greear <greearb@candelatech.com>
Subject: [PATCH]  e100: Enable receiving bogus packets, and transmitting bad/custom
 CRC
Date: Mon, 24 Nov 2003 15:24:11 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3FC2931B.3070903@candelatech.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080006090804050407060406"
Return-path: <netdev-bounce@oss.sgi.com>
To: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>,
        "Feldman, Scott" <scott.feldman@intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------080006090804050407060406
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Thanks to those who pointed me in the right direction, here is a patch
to the e100 (2.4.23-pre9) that allows it to capture all frames, bogons included.
It also coppies the FCS to the skb so ethereal et al can read it.

It utilizes ethtool commands to get/set the rx-all feature, and uses
a new flag in the skbuff (and socket struct) structure to determine when to disable generating
the FCS on transmit.  I have the entire patch that adds the management
bits and flags, but as usual, it's mixed in with various other things...

I've done some initial testing and it seems to work as planned...

If this patch or some version thereof has a possibility of being accepted,
I'll be happy to break out the other bits into a clean patch for
a more thorough review.  If this is DOA, then I thank you for your time
anyway!

Jeff, Dave, et al, please let me know if this is of interest!

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com


--------------080006090804050407060406
Content-Type: text/plain;
 name="e100_rxall.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="e100_rxall.patch"

--- linux-2.4.22/drivers/net/e100/e100_main.c	2003-08-25 04:44:42.000000000 -0700
+++ linux-2.4.22.p4s/drivers/net/e100/e100_main.c	2003-11-24 14:52:47.000000000 -0800
@@ -1,4 +1,4 @@
-/*******************************************************************************
+/** -*-linux-c-*- ************************************************************
 
   
   Copyright(c) 1999 - 2003 Intel Corporation. All rights reserved.
@@ -175,7 +175,7 @@
         MODULE_PARM_DESC(X, S);
 
 /* ====================================================================== */
-static u8 e100_D101M_checksum(struct e100_private *, struct sk_buff *);
+static u8 e100_D101M_checksum(struct e100_private *, struct sk_buff *, int crc_there);
 static u8 e100_D102_check_checksum(rfd_t *);
 static int e100_ioctl(struct net_device *, struct ifreq *, int);
 static int e100_change_mtu(struct net_device *, int);
@@ -1198,11 +1198,17 @@
 	struct e100_private *bdp = dev->priv;
 	unsigned char promisc_enbl;
 	unsigned char mulcast_enbl;
+	unsigned char enable_rx_all;
 
 	promisc_enbl = ((dev->flags & IFF_PROMISC) == IFF_PROMISC);
 	mulcast_enbl = ((dev->flags & IFF_ALLMULTI) ||
 			(dev->mc_count > MAX_MULTICAST_ADDRS));
+	enable_rx_all = ((dev->priv_flags & IFF_ACCEPT_ALL_FRAMES) == IFF_ACCEPT_ALL_FRAMES);
 
+	printk("e100_set_rx_multi (%s), promisc: %d  mcast: %d rxall: %d\n",
+	       dev->name, promisc_enbl, mulcast_enbl, enable_rx_all);
+        /* NOTE:  rx_long is unconditionally set to TRUE if the chipset supports it. */
+	e100_config_rx_all(bdp, enable_rx_all);
 	e100_config_promisc(bdp, promisc_enbl);
 	e100_config_mulcast_enbl(bdp, mulcast_enbl);
 
@@ -2016,8 +2022,14 @@
 		/* do not free & unmap badly received packet.
 		 * move it to the end of skb list for reuse */
 		if (!(rfd_status & RFD_STATUS_OK)) {
-			e100_add_skb_to_end(bdp, rx_struct);
-			continue;
+			if (unlikely(dev->priv_flags & IFF_ACCEPT_ALL_FRAMES)) {
+				/* printk("%s: Accepting a bogon, rfd_status: 0x%x\n",
+				   dev->name, rfd_status); */
+			}
+			else {
+				e100_add_skb_to_end(bdp, rx_struct);
+				continue;
+			}
 		}
 
 		data_sz = min_t(u16, (le16_to_cpu(rfd->rfd_act_cnt) & 0x3fff),
@@ -2052,12 +2064,25 @@
 			if (bdp->rev_id >= D102_REV_ID) {
 				skb->ip_summed = e100_D102_check_checksum(rfd);
 			} else {
-				skb->ip_summed = e100_D101M_checksum(bdp, skb);
+				skb->ip_summed = e100_D101M_checksum(bdp, skb, !!(dev->priv_flags & IFF_ACCEPT_ALL_FRAMES));
 			}
 		} else {
 			skb->ip_summed = CHECKSUM_NONE;
 		}
 
+		/* Show the FCS when in RX-ALL mode */
+		if (unlikely(dev->priv_flags & IFF_ACCEPT_ALL_FRAMES)) {
+			if (bdp->rev_id < D102_REV_ID) {
+				/* Have to over-write the two IP checksum bytes
+				 * TODO:  Will this break vlan_hwaccel_rx???
+				 */
+				skb->tail[-4] = skb->tail[-2];
+				skb->tail[-3] = skb->tail[-1];
+				skb->tail[-2] = skb->tail[0];
+				skb->tail[-1] = skb->tail[1];
+			}
+		}
+		
 		bdp->drv_stats.net_stats.rx_bytes += skb->len;
 
 		if(bdp->vlgrp && (rfd_status & CB_STATUS_VLAN)) {
@@ -2175,6 +2200,18 @@
 		/* Clear I bit on other packets */
 		tcb->tcb_hdr.cb_cmd &= ~__constant_cpu_to_le16(CB_I_BIT);
 
+#ifdef CONFIG_SUPPORT_SEND_BAD_CRC
+	/* Use the last 4 bytes of the SKB payload packet as the CRC, used for
+	 * testing, ie sending bogus stuff.
+	 */
+	if (unlikely(skb->general_flags & DONT_DO_TX_CRC)) {
+		tcb->tcb_hdr.cb_cmd |= __constant_cpu_to_le16(CB_TX_NC_BIT);
+	}
+	else {
+		tcb->tcb_hdr.cb_cmd &= ~__constant_cpu_to_le16(CB_TX_NC_BIT);
+	}
+#endif
+	
 	tcb->tcb_skb = skb;
 
 	if (skb->ip_summed == CHECKSUM_HW) {
@@ -2934,13 +2971,16 @@
  * assign this value to skb->csum.
  */
 static unsigned char
-e100_D101M_checksum(struct e100_private *bdp, struct sk_buff *skb)
+e100_D101M_checksum(struct e100_private *bdp, struct sk_buff *skb, int crc_there)
 {
 	unsigned short proto = (skb->protocol);
-
+	int offset = 0;
+	if (unlikely(crc_there)) {
+		offset = -4;
+	}
 	if (proto == __constant_htons(ETH_P_IP)) {
 
-		skb->csum = get_unaligned((u16 *) (skb->tail));
+		skb->csum = get_unaligned((u16 *) (skb->tail - offset));
 		return CHECKSUM_HW;
 	}
 	return CHECKSUM_NONE;
@@ -3143,6 +3183,27 @@
 	}
 }
 
+static int e100_ethtool_setrxall(struct net_device *netdev, uint32_t val) {
+	unsigned short old_flags = netdev->priv_flags;
+	if (val) {
+		netdev->priv_flags |= IFF_ACCEPT_ALL_FRAMES;
+	}
+	else {
+		netdev->priv_flags &= ~(IFF_ACCEPT_ALL_FRAMES);
+	}
+
+	/* printk("e100_ethtool_setrxall (%s) val: %d\n",
+	   netdev->name, val); */
+	if (old_flags != netdev->priv_flags) {
+		/*  Kick the driver to flush the values...
+		 * TODO:  Needs review of driver folks to make sure locking is sane, etc
+		 */
+		/*printk("Kicking e100_set_multi..\n");*/
+		e100_set_multi(netdev);
+	}
+	return 0;
+}      
+
 static int
 e100_do_ethtool_ioctl(struct net_device *dev, struct ifreq *ifr)
 {
@@ -3342,7 +3403,25 @@
 		return 0;
 	}
 #endif
+	case ETHTOOL_SETRXALL: {
+		struct ethtool_value id;
+		if (copy_from_user(&id, ifr->ifr_data, sizeof(id)))
+			return -EFAULT;
+		spin_lock_bh(&dev->xmit_lock);
+		e100_ethtool_setrxall(dev, id.data);
+		spin_unlock_bh(&dev->xmit_lock);
+		return 0;
+	}
+	case ETHTOOL_GETRXALL: {
+		struct ethtool_value edata = { ETHTOOL_GSG };
+		edata.data = !!(dev->priv_flags & IFF_ACCEPT_ALL_FRAMES);
+		/*printk("GETRXALL, data: %d  priv_flags: %hx\n",
+		  edata.data, netdev->priv_flags);*/
+		if (copy_to_user(ifr->ifr_data, &edata, sizeof(edata)))
+			return -EFAULT;
+		return 0;
+	}
 	default:
 		break;
 	}			//switch
--- linux-2.4.22/drivers/net/e100/e100_config.c	2003-06-13 07:51:34.000000000 -0700
+++ linux-2.4.22.p4s/drivers/net/e100/e100_config.c	2003-11-24 14:56:14.000000000 -0800
@@ -1,4 +1,4 @@
-/*******************************************************************************
+/**** -*-linux-c-*- ***********************************************************
 
   
   Copyright(c) 1999 - 2003 Intel Corporation. All rights reserved.
@@ -326,42 +326,92 @@
 {
 	spin_lock_bh(&(bdp->config_lock));
 
-	/* if in promiscuous mode, save bad frames */
+	/* Promiscuity */
 	if (enable) {
 
+		if (!(bdp->config[15] & CB_CFIG_PROMISCUOUS)) {
+			bdp->config[15] |= CB_CFIG_PROMISCUOUS;
+			E100_CONFIG(bdp, 15);
+		}
+
+	} else {		/* not in promiscuous mode */
+
+		if (bdp->config[15] & CB_CFIG_PROMISCUOUS) {
+			bdp->config[15] &= ~CB_CFIG_PROMISCUOUS;
+			E100_CONFIG(bdp, 15);
+		}
+	}
+
+	spin_unlock_bh(&(bdp->config_lock));
+}
+
+
+/**
+ * e100_config_promisc - configure promiscuous mode
+ * @bdp: atapter's private data struct
+ * @enable: should we enable this option or not
+ *
+ * This routine will enable or disable receiving all frames to
+ * memory, including bad ones, short ones, and long ones.  It also
+ * causes the Frame Check Sum (FCS) to be transferred to memory.
+ */
+void
+e100_config_rx_all(struct e100_private *bdp, unsigned char enable)
+{
+	spin_lock_bh(&(bdp->config_lock));
+
+	/* Should we save bad frames? */
+        if (enable) {
 		if (!(bdp->config[6] & CB_CFIG_SAVE_BAD_FRAMES)) {
 			bdp->config[6] |= CB_CFIG_SAVE_BAD_FRAMES;
 			E100_CONFIG(bdp, 6);
 		}
 
-		if (bdp->config[7] & (u8) BIT_0) {
-			bdp->config[7] &= (u8) (~BIT_0);
+                /* Don't discard short-receive */
+		if (bdp->config[7] & (u8) CB_CFIG_DISC_SHORT_FRAMES) {
+			bdp->config[7] &= (u8) (~CB_CFIG_DISC_SHORT_FRAMES);
 			E100_CONFIG(bdp, 7);
 		}
 
-		if (!(bdp->config[15] & CB_CFIG_PROMISCUOUS)) {
-			bdp->config[15] |= CB_CFIG_PROMISCUOUS;
-			E100_CONFIG(bdp, 15);
+		/* Save over-runs */
+		if (!(bdp->config[6] & CB_CFIG_SAVE_OVERRUNS)) {
+			bdp->config[6] |= CB_CFIG_SAVE_OVERRUNS;
+			E100_CONFIG(bdp, 6);
 		}
 
-	} else {		/* not in promiscuous mode */
-
+		/* Transfer the etherne CRC to memory too */
+		if (!(bdp->config[18] & CB_CFIG_CRC_IN_MEM)) {
+			bdp->config[18] |= CB_CFIG_CRC_IN_MEM;
+			E100_CONFIG(bdp, 18);
+		}
+		
+        }
+        else {
+		/* Don't discard short frames */
 		if (bdp->config[6] & CB_CFIG_SAVE_BAD_FRAMES) {
 			bdp->config[6] &= ~CB_CFIG_SAVE_BAD_FRAMES;
 			E100_CONFIG(bdp, 6);
 		}
 
-		if (!(bdp->config[7] & (u8) BIT_0)) {
-			bdp->config[7] |= (u8) (BIT_0);
+		/* Discard short-receive */
+		if (!(bdp->config[7] & (u8) CB_CFIG_DISC_SHORT_FRAMES)) {
+			bdp->config[7] |= (u8) (CB_CFIG_DISC_SHORT_FRAMES);
 			E100_CONFIG(bdp, 7);
 		}
 
-		if (bdp->config[15] & CB_CFIG_PROMISCUOUS) {
-			bdp->config[15] &= ~CB_CFIG_PROMISCUOUS;
-			E100_CONFIG(bdp, 15);
+		/* Discard over-runs */
+		if (bdp->config[6] & CB_CFIG_SAVE_OVERRUNS) {
+			bdp->config[6] &= !CB_CFIG_SAVE_OVERRUNS;
+			E100_CONFIG(bdp, 6);
 		}
-	}
+
+		/* Don't send CRC (FCS) to memory */
+		if (bdp->config[18] & CB_CFIG_CRC_IN_MEM) {
+			bdp->config[18] &= !CB_CFIG_CRC_IN_MEM;
+			E100_CONFIG(bdp, 18);
+		}
+        }
 
 	spin_unlock_bh(&(bdp->config_lock));
 }
--- linux-2.4.22/drivers/net/e100/e100_config.h	2003-06-13 07:51:34.000000000 -0700
+++ linux-2.4.22.p4s/drivers/net/e100/e100_config.h	2003-11-24 00:57:14.000000000 -0800
@@ -67,6 +67,7 @@
 #define CB_CFIG_CI_INT             BIT_3	/* Command Complete Interrupt */
 #define CB_CFIG_EXT_TCB_DIS        BIT_4	/* Extended TCB */
 #define CB_CFIG_EXT_STAT_DIS       BIT_5	/* Extended Stats */
+#define CB_CFIG_SAVE_OVERRUNS      BIT_6	/* Save over-run frames if != 0 */
 #define CB_CFIG_SAVE_BAD_FRAMES    BIT_7	/* Save Bad Frames Enabled */
 
 /* byte 7 bit definitions*/
@@ -117,6 +118,8 @@
 #define CB_CFIG_STRIPPING           BIT_0	/* Padding Disabled */
 #define CB_CFIG_PADDING             BIT_1	/* Padding Disabled */
 #define CB_CFIG_CRC_IN_MEM          BIT_2	/* Transfer CRC To Memory */
+/* Only valid for 82558 and 82559.  Must be zero for 82557 */
+#define CB_CFIG_LONG_RX_OK          BIT_3	/* OK to receive Long frames */
 
 /* byte 19 bit definitions*/
 #define CB_CFIG_TX_ADDR_WAKE        BIT_0	/* Address Wakeup */
@@ -142,8 +145,7 @@
 /* byte 22 bit defines */
 #define CB_CFIG_RECEIVE_GAMLA_MODE  BIT_0	/* D102 receive mode */
 #define CB_CFIG_VLAN_DROP_ENABLE    BIT_1	/* vlan stripping */
-
-#define CB_CFIG_LONG_RX_OK	    BIT_3
+/* LONG-RX OK (needed for VLAN) is in byte 18, bit 3, see above */
 
 #define NO_LOOPBACK	0	
 #define MAC_LOOPBACK	0x01
@@ -155,6 +157,7 @@
 extern unsigned char e100_config(struct e100_private *bdp);
 extern void e100_config_fc(struct e100_private *bdp);
 extern void e100_config_promisc(struct e100_private *bdp, unsigned char enable);
+extern void e100_config_rx_all(struct e100_private *bdp, unsigned char enable);
 extern void e100_config_brdcast_dsbl(struct e100_private *bdp);
 extern void e100_config_mulcast_enbl(struct e100_private *bdp,
 				     unsigned char enable);

--------------080006090804050407060406--
