From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH 3/3] rx_all e100 patch
Date: Tue, 25 Nov 2003 10:03:21 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3FC39969.4030609@candelatech.com>
References: <3FC30AEE.7000005@candelatech.com> <20031125162152.D1107@sygehus.dk>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070408020408090403060907"
Cc: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Rask Ingemann Lambertsen <rask@sygehus.dk>
In-Reply-To: <20031125162152.D1107@sygehus.dk>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------070408020408090403060907
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Rask Ingemann Lambertsen wrote:
> On Mon, Nov 24, 2003 at 11:55:26PM -0800, Ben Greear wrote:
> 
>>@@ -2052,13 +2065,26 @@
>> 			if (bdp->rev_id >= D102_REV_ID) {
>> 				skb->ip_summed = e100_D102_check_checksum(rfd);
>> 			} else {
>>-				skb->ip_summed = e100_D101M_checksum(bdp, skb);
>>+				skb->ip_summed = e100_D101M_checksum(bdp, skb, !!(dev->priv_flags & IFF_ACCEPT_ALL_FRAMES));
>> 			}
> 
> 
> Shouldn't that be IFF_SAVE_FCS rather than IFF_ACCEPT_ALL_FRAMES?

Yes, will fix, actually, considering your next comment, it should not even
be needed at all, eh?

>> 		} else {
>> 			skb->ip_summed = CHECKSUM_NONE;
>> 		}
>> 
>>+		/* Show the FCS? */
>>+		if (unlikely(dev->priv_flags & IFF_SAVE_FCS)) {
>>+			if (bdp->rev_id < D102_REV_ID) {
>>+				/* Have to over-write the two IP checksum bytes
>>+				 * TODO:  Will this break vlan_hwaccel_rx???
>>+				 */
>>+				skb->tail[-4] = skb->tail[-2];
>>+				skb->tail[-3] = skb->tail[-1];
>>+				skb->tail[-2] = skb->tail[0];
>>+				skb->tail[-1] = skb->tail[1];
>>+			}
>>+		}
>>+		
> 
> 
> I don't understand this part of the code. The 55x docs say that the IP
> checksum bytes are transferred to memory _following_ the FCS.

I can't find this in the docs, but it could easily be true.  If you have a page/section
number, please let me know.  I don't appear to have hardware that takes this
branch at any rate.  Anyone know which chipset/NIC has this particular rev-id?

Also, this should invalidate all of the hacks from the e100_D101M_checksum code...

> 
> 
>>+/**
>>+ * e100_config_promisc - configure promiscuous mode
>>+ * @bdp: atapter's private data struct
>>+ * @enable: should we enable this option or not
> 
> 
> s/atapter/adapter/g
> 
> s/etherne /ethernet /g too, somewhere, IIRC.
> 
> 
>>+/* Only valid for 82558 and 82559.  Must be zero for 82557 */
>>+#define CB_CFIG_LONG_RX_OK          BIT_3	/* OK to receive Long frames */
> 
> 
> I find it disappointing that the good, old 82586 transfers long frames to
> memory without complaint while newer chips such as the 82557 and tulip
> can't/don't.

Tulip can at least work with VLANs with a hack or two, but not sure how it's
max longness.

There may be other ways to get the 82557 to do VLANs, but the docs definately
indicate the rx-long bit does not exist for 82557 (page 62-64, byte 18, bit 3)
of the e100 docs from sourceforge.

Thanks for the thorough review.  Attached is a new patch that I believe
addresses these problems.

Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com


--------------070408020408090403060907
Content-Type: text/plain;
 name="rx_all_e100.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="rx_all_e100.patch"

--- linux-2.4.22/drivers/net/e100/e100_main.c	2003-08-25 04:44:42.000000000 -0700
+++ linux-2.4.22.p4s/drivers/net/e100/e100_main.c	2003-11-25 09:56:38.000000000 -0800
@@ -1,4 +1,4 @@
-/*******************************************************************************
+/** -*-linux-c-*- ************************************************************
 
   
   Copyright(c) 1999 - 2003 Intel Corporation. All rights reserved.
@@ -644,8 +644,9 @@
 	dev->do_ioctl = &e100_ioctl;
 
 	if (bdp->flags & USE_IPCB)
-	dev->features = NETIF_F_SG | NETIF_F_HW_CSUM |
-			NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
+		dev->features = NETIF_F_SG | NETIF_F_HW_CSUM |
+			NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX |
+		        NETIF_F_RX_ALL | NETIF_F_SAVE_CRC;
 		
 	if ((rc = register_netdev(dev)) != 0) {
 		goto err_pci;
@@ -830,7 +831,7 @@
 /**
  * e100_check_options - check command line options
  * @board: board number
- * @bdp: atapter's private data struct
+ * @bdp: adapter's private data struct
  *
  * This routine does range checking on command-line options
  */
@@ -1198,11 +1199,17 @@
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
 
@@ -2016,9 +2023,15 @@
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
@@ -2925,7 +2950,7 @@
 
 /**
  * e100_D101M_checksum
- * @bdp: atapter's private data struct
+ * @bdp: adapter's private data struct
  * @skb: skb received
  *
  * Sets the skb->csum value from D101 csum found at the end of the Rx frame. The
@@ -3143,6 +3168,27 @@
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
@@ -3342,7 +3388,43 @@
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
+	case ETHTOOL_SETRXFCS: {
+		struct ethtool_value id;
+		if (copy_from_user(&id, ifr->ifr_data, sizeof(id)))
+			return -EFAULT;
+		spin_lock_bh(&dev->xmit_lock);
+		dev->priv_flags |= IFF_SAVE_FCS;
+		spin_unlock_bh(&dev->xmit_lock);
+		return 0;
+	}
+	case ETHTOOL_GETRXFCS: {
+		struct ethtool_value edata = { ETHTOOL_GSG };
+		edata.data = !!(dev->priv_flags & IFF_SAVE_FCS);
+		/*printk("GETRXFCS, data: %d  priv_flags: %hx\n",
+		  edata.data, netdev->priv_flags);*/
+		if (copy_to_user(ifr->ifr_data, &edata, sizeof(edata)))
+			return -EFAULT;
+		return 0;
+	}
 	default:
 		break;
 	}			//switch
--- linux-2.4.22/drivers/net/e100/e100_config.c	2003-06-13 07:51:34.000000000 -0700
+++ linux-2.4.22.p4s/drivers/net/e100/e100_config.c	2003-11-25 09:05:26.000000000 -0800
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
+ * @bdp: adapter's private data struct
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
+			bdp->config[6] &= ~CB_CFIG_SAVE_OVERRUNS;
+			E100_CONFIG(bdp, 6);
 		}
-	}
+
+		/* Don't send CRC (FCS) to memory */
+		if (bdp->config[18] & CB_CFIG_CRC_IN_MEM) {
+			bdp->config[18] &= ~CB_CFIG_CRC_IN_MEM;
+			E100_CONFIG(bdp, 18);
+		}
+        }
 
 	spin_unlock_bh(&(bdp->config_lock));
 }
--- linux-2.4.22/drivers/net/e100/e100_config.h	2003-06-13 07:51:34.000000000 -0700
+++ linux-2.4.22.p4s/drivers/net/e100/e100_config.h	2003-11-24 23:21:53.000000000 -0800
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
@@ -155,7 +157,8 @@
 extern unsigned char e100_config(struct e100_private *bdp);
 extern void e100_config_fc(struct e100_private *bdp);
 extern void e100_config_promisc(struct e100_private *bdp, unsigned char enable);
+extern void e100_config_rx_all(struct e100_private *bdp, unsigned char enable);
 extern void e100_config_brdcast_dsbl(struct e100_private *bdp);
 extern void e100_config_mulcast_enbl(struct e100_private *bdp,
 				     unsigned char enable);
--- linux-2.4.22/drivers/net/e100/e100.h	2003-08-25 04:44:42.000000000 -0700
+++ linux-2.4.22.p4s/drivers/net/e100/e100.h	2003-11-24 23:21:53.000000000 -0800
@@ -362,6 +362,7 @@
 #define CB_EL_BIT           BIT_15	/* CB EL Bit */
 #define CB_S_BIT            BIT_14	/* CB Suspend Bit */
 #define CB_I_BIT            BIT_13	/* CB Interrupt Bit */
+#define CB_TX_NC_BIT        BIT_4	        /* If true, do not calculate FCS */
 #define CB_TX_SF_BIT        BIT_3	/* TX CB Flexible Mode */
 #define CB_CMD_MASK         BIT_0_3	/* CB 4-bit CMD Mask */
 #define CB_CID_DEFAULT      (0x1f << 8)	/* CB 5-bit CID (max value) */

--------------070408020408090403060907--
