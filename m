From: "Steven J. Hill" <sjhill@realitydiluted.com>
Subject: [PATCH] Merge GT/MV642xx Support into MV643xx Driver [4/8]
Date: Wed, 18 Jul 2007 23:53:31 -0500
Message-ID: <469EEE4B.2090008@realitydiluted.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigBCABA663FD2CCE3BD0FC02D4"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from real.realitydiluted.com ([66.43.201.61]:33990 "EHLO
	real.realitydiluted.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751265AbXGSExj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2007 00:53:39 -0400
Received: from atlas.inter.net ([10.0.0.3])
	by real.realitydiluted.com with esmtp (Exim 4.67)
	(envelope-from <sjhill@realitydiluted.com>)
	id 1IBO3F-00066Y-Rh
	for netdev@vger.kernel.org; Wed, 18 Jul 2007 23:55:52 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigBCABA663FD2CCE3BD0FC02D4
Content-Type: multipart/mixed;
 boundary="------------010103000105000101090502"

This is a multi-part message in MIME format.
--------------010103000105000101090502
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Add main 642xx support to 'drivers/net/mv643xx_eth.c' file.

Signed-off-by: Steven J. Hill <sjhill1@rockwellcollins.com>
---


--------------010103000105000101090502
Content-Type: text/x-patch;
 name="04-mv643xx-64260-support.patch"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline;
 filename="04-mv643xx-64260-support.patch"

--- linux-2.6.22.1/drivers/net/mv643xx_eth.c	2007-07-18 22:19:31.00000000=
0 -0500
+++ linux-2.6.22.1-rci/drivers/net/mv643xx_eth.c	2007-07-18 22:22:04.0000=
00000 -0500
@@ -13,8 +13,7 @@
  * Copyright (C) 2004-2006 MontaVista Software, Inc.
  *			   Dale Farnsworth <dale@farnsworth.org>
  *
- * Copyright (C) 2004 Steven J. Hill <sjhill1@rockwellcollins.com>
- *				     <sjhill@realitydiluted.com>
+ * Copyright (C) 2004-2007 Steven J. Hill <sjhill1@rockwellcollins.com>
  *
  * This program is free software; you can redistribute it and/or
  * modify it under the terms of the GNU General Public License
@@ -48,6 +47,11 @@
 #include <asm/pgtable.h>
 #include <asm/system.h>
 #include <asm/delay.h>
+#ifdef CONFIG_GT64260
+# include <asm/cacheflush.h>
+# include <asm/tlbflush.h>
+# include <asm/mv64x60.h>
+#endif
 #include "mv643xx_eth.h"
=20
 /* Static function declarations */
@@ -83,6 +87,14 @@
=20
 /* used to protect MV643XX_ETH_SMI_REG, which is shared across ports */
 static DEFINE_SPINLOCK(mv643xx_eth_phy_lock);
+#ifdef CONFIG_GT64260
+extern struct mv64x60_handle bh;
+static u32 eth_hash_table_size[3] =3D { 1, 1, 1 };
+static u32 eth_hash_table_hash_mode[3] =3D { 0, 0, 0 };
+static u32 eth_hash_table_default_mode[3] =3D { 0, 0, 0 };
+static u32 eth_hash_table_vbase_addr[3];
+static const u32 eth_hash_length[2] =3D { 0x8000, 0x800 };
+#endif
=20
 static inline u32 mv_read(int offset)
 {
@@ -102,7 +114,7 @@
 }
=20
 /*
- * Changes MTU (maximum transfer unit) of the gigabit ethenret port
+ * Changes MTU (maximum transfer unit) of the gigabit ethernet port
  *
  * Input :	pointer to ethernet interface network device structure
  *		new mtu size
@@ -113,6 +125,29 @@
 	if ((new_mtu > 9500) || (new_mtu < 64))
 		return -EINVAL;
=20
+#ifdef CONFIG_GT64260
+	/*
+	 * The 642XX needs the frame length to be set for certain MTU
+	 * sizes to avoid length overrun errors.
+	 */
+	{
+		struct mv643xx_private *mp =3D netdev_priv(dev);
+		unsigned int reg;
+
+		reg =3D mv_read(MV643XX_ETH_PORT_CONFIG_EXTEND_REG(mp->port_num));
+
+		if (new_mtu <=3D 1528)
+			reg &=3D ~(0x3 << 14);
+		else if (new_mtu <=3D 1536)
+			reg |=3D (0x1 << 14);
+		else if (new_mtu <=3D 2048)
+			reg |=3D (0x2 << 14);
+		else
+			reg |=3D (0x3 << 14);
+
+		mv_write(MV643XX_ETH_PORT_CONFIG_EXTEND_REG(mp->port_num), reg);
+	}
+#endif
 	dev->mtu =3D new_mtu;
 	/*
 	 * Stop then re-open the interface. This will allocate RX skb's with
@@ -158,13 +193,18 @@
 		pkt_info.byte_cnt =3D ETH_RX_SKB_SIZE;
 		pkt_info.buf_ptr =3D dma_map_single(NULL, skb->data,
 					ETH_RX_SKB_SIZE, DMA_FROM_DEVICE);
+#ifdef CONFIG_GT64260
+		invalidate_dcache_addr_size((u32) skb->data, dev->mtu);
+#endif
 		pkt_info.return_info =3D skb;
 		if (eth_rx_return_buff(mp, &pkt_info) !=3D ETH_OK) {
 			printk(KERN_ERR
 				"%s: Error allocating RX Ring\n", dev->name);
 			break;
 		}
+#ifndef CONFIG_GT64260
 		skb_reserve(skb, ETH_HW_IP_ALIGN);
+#endif
 	}
 	/*
 	 * If RX ring is empty of SKB, set a timer to try allocating
@@ -323,6 +361,10 @@
=20
 		tx_index =3D mp->tx_used_desc_q;
 		desc =3D &mp->p_tx_desc_area[tx_index];
+#ifdef CONFIG_GT64260
+		invalidate_dcache_addr_size((u32) desc, sizeof(struct eth_tx_desc));
+		mb();
+#endif
 		cmd_sts =3D desc->cmd_sts;
=20
 		if (!force && (cmd_sts & ETH_BUFFER_OWNED_BY_DMA)) {
@@ -338,6 +380,10 @@
 		skb =3D mp->tx_skb[tx_index];
 		if (skb)
 			mp->tx_skb[tx_index] =3D NULL;
+#ifdef CONFIG_GT64260
+		flush_dcache_addr_size(skb, skb->len);
+		flush_dcache_addr_size((u32) desc, sizeof(struct eth_tx_desc));
+#endif
=20
 		if (cmd_sts & ETH_ERROR_SUMMARY) {
 			printk("%s: Error in TX\n", dev->name);
@@ -381,7 +427,7 @@
  * queues toward kernel core or FastRoute them to another interface.
  *
  * Input :	dev - a pointer to the required interface
- *		max - maximum number to receive (0 means unlimted)
+ *		budget - maximum number to receive (0 means unlimited)
  *
  * Output :	number of served packets
  */
@@ -394,8 +440,10 @@
 	struct pkt_info pkt_info;
=20
 	while (budget-- > 0 && eth_port_receive(mp, &pkt_info) =3D=3D ETH_OK) {=

+#ifndef CONFIG_GT64260
 		dma_unmap_single(NULL, pkt_info.buf_ptr, ETH_RX_SKB_SIZE,
 							DMA_FROM_DEVICE);
+#endif
 		mp->rx_desc_count--;
 		received_packets++;
=20
@@ -429,6 +477,12 @@
=20
 			dev_kfree_skb_irq(skb);
 		} else {
+#ifdef CONFIG_GT64260
+			skb_put(skb, pkt_info.byte_cnt);
+			skb->ip_summed =3D CHECKSUM_NONE;
+			skb->pkt_type =3D PACKET_HOST;
+			skb->dev =3D dev;
+#else
 			/*
 			 * The -4 is for the CRC in the trailer of the
 			 * received packet
@@ -440,6 +494,7 @@
 				skb->csum =3D htons(
 					(pkt_info.cmd_sts & 0x0007fff8) >> 3);
 			}
+#endif
 			skb->protocol =3D eth_type_trans(skb, dev);
 #ifdef MV643XX_NAPI
 			netif_receive_skb(skb);
@@ -460,6 +515,7 @@
 {
 	struct mv643xx_private *mp =3D netdev_priv(dev);
 	int port_num =3D mp->port_num;
+#ifndef CONFIG_GT64260
 	u32 o_pscr, n_pscr;
 	unsigned int queues;
=20
@@ -502,6 +558,52 @@
 				mv643xx_eth_port_enable_tx(port_num, queues);
 		}
 	}
+#else
+	u32 o_pcr, n_pcr;
+	u32 o_pcxr, n_pcxr;
+	unsigned int queues;
+
+	o_pcr =3D mv_read(MV643XX_ETH_PORT_CONFIG_REG(port_num));
+	n_pcr =3D o_pcr;
+	o_pcxr =3D mv_read(MV643XX_ETH_PORT_CONFIG_EXTEND_REG(port_num));
+	n_pcxr =3D o_pcxr;
+
+	/* clear speed and duplex fields */
+	n_pcr &=3D ~(GT64260_ETH_SET_SPEED_TO_10 |
+		   GT64260_ETH_SET_SPEED_TO_100 |
+		   GT64260_ETH_SET_FULL_DUPLEX_MODE);
+	n_pcxr |=3D GT64260_ETH_DISABLE_AUTO_NEG_FOR_DPLX;
+
+	if (ecmd->duplex =3D=3D DUPLEX_FULL)
+		n_pcr |=3D GT64260_ETH_SET_FULL_DUPLEX_MODE;
+
+	if (ecmd->speed =3D=3D SPEED_100)
+		n_pcr |=3D GT64260_ETH_SET_SPEED_TO_100;
+
+	if (n_pcr !=3D o_pcr) {
+		if ((o_pcr & GT64260_ETH_ENABLE) =3D=3D 0)
+		{
+			mv_write(MV643XX_ETH_PORT_CONFIG_REG(port_num), n_pcr);
+
+			mv_write(MV643XX_ETH_PORT_CONFIG_EXTEND_REG(port_num),
+				n_pcxr);
+		}
+		else
+		{
+			queues =3D mv643xx_eth_port_disable_tx(port_num);
+
+			n_pcr &=3D ~GT64260_ETH_ENABLE;
+
+			mv_write(MV643XX_ETH_PORT_CONFIG_REG(port_num), n_pcr);
+
+			mv_write(MV643XX_ETH_PORT_CONFIG_EXTEND_REG(port_num),
+				n_pcxr);
+
+			if (queues)
+				mv643xx_eth_port_enable_tx(port_num, queues);
+		}
+	}
+#endif
 }
=20
 /*
@@ -515,6 +617,80 @@
  * Output :	N/A
  */
=20
+#ifdef CONFIG_GT64260
+static irqreturn_t mv643xx_eth_int_handler(int irq, void *dev_id)
+{
+	struct net_device *dev =3D (struct net_device *)dev_id;
+	struct mv643xx_private *mp =3D netdev_priv(dev);
+	u32 eth_int_cause;
+	unsigned int port_num =3D mp->port_num;
+
+	/* Read interrupt cause registers */
+	eth_int_cause =3D mv_read(MV643XX_ETH_INTERRUPT_CAUSE_REG(port_num)) &
+						ETH_INT_UNMASK_ALL;
+
+	/* Tx interrupt */
+	if (eth_int_cause & 0x000000cc) {
+		mv643xx_eth_free_completed_tx_descs(dev);
+		eth_int_cause &=3D ~0x000000cc;
+		mv_write(MV643XX_ETH_INTERRUPT_CAUSE_REG(port_num), eth_int_cause);
+	}
+
+	/* PHY status changed */
+	if (eth_int_cause & ETH_INT_CAUSE_PHY) {
+		struct ethtool_cmd cmd;
+
+		if (mii_link_ok(&mp->mii)) {
+			mv643xx_eth_update_pscr(dev, &cmd);
+			mv643xx_eth_port_enable_tx(port_num,
+						   ETH_TX_QUEUES_ENABLED);
+			if (!netif_carrier_ok(dev)) {
+				netif_carrier_on(dev);
+				if (mp->tx_ring_size - mp->tx_desc_count >=3D
+							MAX_DESCS_PER_SKB)
+					netif_wake_queue(dev);
+			}
+		} else if (netif_carrier_ok(dev)) {
+			netif_stop_queue(dev);
+			netif_carrier_off(dev);
+		}
+		eth_int_cause &=3D ~ETH_INT_CAUSE_PHY;
+		mv_write(MV643XX_ETH_INTERRUPT_CAUSE_REG(port_num), eth_int_cause);
+	}
+
+	/* Handle SMI completion */
+	if (eth_int_cause & 0x20000000) {
+		eth_int_cause &=3D ~0x20000000;
+		mv_write(MV643XX_ETH_INTERRUPT_CAUSE_REG(port_num), eth_int_cause);
+	}
+
+	/* Rx interrupt */
+#ifdef MV643XX_NAPI
+	if (eth_int_cause & 0x00110101) {
+		/* schedule the NAPI poll routine to maintain port */
+		mv_write(MV643XX_ETH_INTERRUPT_MASK_REG(port_num),
+							ETH_INT_MASK_ALL);
+		/* wait for previous write to complete */
+		mv_read(MV643XX_ETH_INTERRUPT_MASK_REG(port_num));
+
+		netif_rx_schedule(dev);
+	}
+#else
+	if (eth_int_cause & 0x00ff0101) {
+		mv643xx_eth_receive_queue(dev, INT_MAX);
+		eth_int_cause &=3D ~0x00ff0101;
+		mv_write(MV643XX_ETH_INTERRUPT_CAUSE_REG(port_num), eth_int_cause);
+	}
+#endif
+=09
+	if (eth_int_cause) {
+		printk("MV-643xx: port %d interrupts remaining =3D 0x%08x\n",
+				port_num, eth_int_cause);
+	}
+
+	return IRQ_HANDLED;
+}
+#else
 static irqreturn_t mv643xx_eth_int_handler(int irq, void *dev_id)
 {
 	struct net_device *dev =3D (struct net_device *)dev_id;
@@ -580,6 +756,7 @@
=20
 	return IRQ_HANDLED;
 }
+#endif
=20
 #ifdef MV643XX_COAL
=20
@@ -621,6 +798,7 @@
 }
 #endif
=20
+#ifndef CONFIG_GT64260
 /*
  * eth_port_set_tx_coal - Sets coalescing interrupt mechanism on TX path=

  *
@@ -654,6 +832,7 @@
 								coal << 4);
 	return coal;
 }
+#endif
=20
 /*
  * ether_init_rx_desc_ring - Curve a Rx chain desc list and buffer in me=
mory.
@@ -690,6 +869,22 @@
 			((i + 1) % rx_desc_num) * sizeof(struct eth_rx_desc);
 	}
=20
+#ifdef CONFIG_GT64260
+		/*
+		 * For the GT64260, we set the Enable Interrupt (EI) bit
+		 * to interrupt only on frames and not buffer boundaries.
+		 * It is also necessary to set the Receive Interrupt on
+		 * Frame Boundaries (RIFB) bit in the SDMA Configuration
+		 * Register (SDCR) of the Ethernet port. The RIFB bit is
+		 * set in the 'eth_port_start' function.
+		 *
+		 * These bits are documented on Pages 421 and 455 of the
+		 * Marvell GT64260B datasheet dated August 04, 2004.
+		 */
+		p_rx_desc[i].cmd_sts =3D
+			(ETH_BUFFER_OWNED_BY_DMA | ETH_RX_ENABLE_INTERRUPT);
+#endif
+
 	/* Save Rx desc pointer to driver struct. */
 	mp->rx_curr_desc_q =3D 0;
 	mp->rx_used_desc_q =3D 0;
@@ -698,7 +893,7 @@
 }
=20
 /*
- * ether_init_tx_desc_ring - Curve a Tx chain desc list and buffer in me=
mory.
+ * ether_init_tx_desc_ring - Carve a Tx chain desc list and buffer in me=
mory.
  *
  * DESCRIPTION:
  *	This function prepares a Tx chained list of descriptors and packet
@@ -788,9 +983,11 @@
=20
 	/* Clear any pending ethernet port interrupts */
 	mv_write(MV643XX_ETH_INTERRUPT_CAUSE_REG(port_num), 0);
+#ifndef CONFIG_GT64260
 	mv_write(MV643XX_ETH_INTERRUPT_CAUSE_EXTEND_REG(port_num), 0);
 	/* wait for previous write to complete */
 	mv_read (MV643XX_ETH_INTERRUPT_CAUSE_EXTEND_REG(port_num));
+#endif
=20
 	err =3D request_irq(dev->irq, mv643xx_eth_int_handler,
 			IRQF_SHARED | IRQF_SAMPLE_RANDOM, dev->name, dev);
@@ -800,6 +997,50 @@
 		return -EAGAIN;
 	}
=20
+#ifdef CONFIG_GT64260
+	/*
+	 * Allocate and initialize hash table. We do this here so that
+	 * if the memory allocation fails, we can clean up and because
+	 * the table must be allocated before calling 'eth_port_init'.
+	 *
+	 * Hash mode	     - Hash mode 0 or Hash mode 1.
+	 * Hash size	     - Indicates number of table entries
+	 *		       (0 =3D 0x8000, 1 =3D 0x800)
+	 * Hash default mode - 0 =3D Discard addresses not found
+	 *		       1 =3D Pass addresses not found
+	 */
+	mp->eth_hash_table_size =3D
+		MAC_ENTRY_SIZE * eth_hash_length[eth_hash_table_size[port_num]];
+	mp->eth_hash_table =3D dma_alloc_coherent(NULL, mp->eth_hash_table_size=
,
+						&mp->eth_hash_table_dma,
+						GFP_KERNEL);
+	if (!mp->eth_hash_table) {
+		printk(KERN_ERR "%s: Cannot allocate hash table\n", dev->name);
+		err =3D -ENOMEM;
+		goto out_free_irq;
+	}
+	mv_write(GT64260_ETH_HASH_TABLE_POINTER_REG(port_num),
+			mp->eth_hash_table_dma);
+	eth_hash_table_vbase_addr[port_num] =3D (u32) mp->eth_hash_table;
+	invalidate_dcache_addr_size(mp->eth_hash_table, (MAC_ENTRY_SIZE *
+			eth_hash_length[eth_hash_table_size[port_num]]));
+
+	/* Set hash table parameters. */
+	{
+		u32 pcr =3D mv_read(MV643XX_ETH_PORT_CONFIG_REG(port_num));
+		pcr &=3D ~(GT64260_ETH_HASH_SIZE_8K |
+			 GT64260_ETH_HASH_MODE_1 |
+			 GT64260_ETH_HASH_DEFAULT_PASS);
+		pcr |=3D ((eth_hash_table_default_mode[port_num] <<
+				GT64260_ETH_HASH_DEFAULT_SHIFT)
+		     | (eth_hash_table_hash_mode[port_num] <<
+				GT64260_ETH_HASH_MODE_SHIFT)
+		     | (eth_hash_table_size[port_num] <<
+				GT64260_ETH_HASH_SIZE_SHIFT));
+		mv_write(MV643XX_ETH_PORT_CONFIG_REG(port_num), pcr);
+	}
+#endif
+
 	eth_port_init(mp);
=20
 	memset(&mp->timeout, 0, sizeof(struct timer_list));
@@ -807,12 +1048,24 @@
 	mp->timeout.data =3D (unsigned long)dev;
=20
 	/* Allocate RX and TX skb rings */
+#ifdef CONFIG_GT64260
+	/* GT642XX needs page alignment for RX skb ring */
+	size =3D PAGE_SIZE;
+	while (size < (sizeof(*mp->rx_skb) * mp->rx_ring_size))
+		size +=3D PAGE_SIZE;
+	mp->rx_skb =3D kmalloc(size, GFP_KERNEL);
+#else
 	mp->rx_skb =3D kmalloc(sizeof(*mp->rx_skb) * mp->rx_ring_size,
 								GFP_KERNEL);
+#endif
 	if (!mp->rx_skb) {
 		printk(KERN_ERR "%s: Cannot allocate Rx skb ring\n", dev->name);
 		err =3D -ENOMEM;
+#ifdef CONFIG_GT64260
+		goto out_free_hash_table;
+#else
 		goto out_free_irq;
+#endif
 	}
 	mp->tx_skb =3D kmalloc(sizeof(*mp->tx_skb) * mp->tx_ring_size,
 								GFP_KERNEL);
@@ -848,8 +1101,15 @@
 	ether_init_tx_desc_ring(mp);
=20
 	/* Allocate RX ring */
+#ifdef CONFIG_GT64260
+	/* GT642XX needs page alignment for RX ring */
+	size =3D PAGE_SIZE;
+	while (size < (mp->rx_ring_size * sizeof(struct eth_rx_desc)))
+		size +=3D PAGE_SIZE;
+#else
 	mp->rx_desc_count =3D 0;
 	size =3D mp->rx_ring_size * sizeof(struct eth_rx_desc);
+#endif
 	mp->rx_desc_area_size =3D size;
=20
 	if (mp->rx_sram_size) {
@@ -889,12 +1149,14 @@
 		eth_port_set_rx_coal(port_num, 133000000, MV643XX_RX_COAL);
 #endif
=20
+#ifndef CONFIG_GT64260
 	mp->tx_int_coal =3D
 		eth_port_set_tx_coal(port_num, 133000000, MV643XX_TX_COAL);
=20
 	/* Unmask phy and link status changes interrupts */
 	mv_write(MV643XX_ETH_INTERRUPT_EXTEND_MASK_REG(port_num),
 						ETH_INT_UNMASK_ALL_EXT);
+#endif
=20
 	/* Unmask RX buffer and TX end interrupt */
 	mv_write(MV643XX_ETH_INTERRUPT_MASK_REG(port_num), ETH_INT_UNMASK_ALL);=

@@ -905,6 +1167,11 @@
 	kfree(mp->tx_skb);
 out_free_rx_skb:
 	kfree(mp->rx_skb);
+#ifdef CONFIG_GT64260
+out_free_hash_table:
+	dma_free_coherent(NULL, mp->eth_hash_table_size,
+			mp->eth_hash_table, mp->eth_hash_table_dma);
+#endif
 out_free_irq:
 	free_irq(dev->irq, dev);
=20
@@ -1035,7 +1302,9 @@
 	if (done) {
 		netif_rx_complete(dev);
 		mv_write(MV643XX_ETH_INTERRUPT_CAUSE_REG(port_num), 0);
+#ifndef CONFIG_GT64260
 		mv_write(MV643XX_ETH_INTERRUPT_CAUSE_EXTEND_REG(port_num), 0);
+#endif
 		mv_write(MV643XX_ETH_INTERRUPT_MASK_REG(port_num),
 						ETH_INT_UNMASK_ALL);
 	}
@@ -1090,6 +1359,9 @@
 static void eth_tx_fill_frag_descs(struct mv643xx_private *mp,
 				   struct sk_buff *skb)
 {
+#ifdef CONFIG_GT64260
+	printk("eth_tx_fill_frag_descs: Unable to handle fragments!\n");
+#else
 	int frag;
 	int tx_index;
 	struct eth_tx_desc *desc;
@@ -1108,7 +1380,7 @@
 					 ETH_TX_ENABLE_INTERRUPT;
 			mp->tx_skb[tx_index] =3D skb;
 		} else
-			mp->tx_skb[tx_index] =3D NULL;
+			mp->tx_skb[tx_index] =3D 0;
=20
 		desc =3D &mp->p_tx_desc_area[tx_index];
 		desc->l4i_chk =3D 0;
@@ -1118,6 +1390,7 @@
 						this_frag->size,
 						DMA_TO_DEVICE);
 	}
+#endif
 }
=20
 /**
@@ -1144,7 +1417,7 @@
 		eth_tx_fill_frag_descs(mp, skb);
=20
 		length =3D skb_headlen(skb);
-		mp->tx_skb[tx_index] =3D NULL;
+		mp->tx_skb[tx_index] =3D 0;
 	} else {
 		cmd_sts |=3D ETH_ZERO_PADDING |
 			   ETH_TX_LAST_DESC |
@@ -1156,6 +1429,13 @@
 	desc->byte_cnt =3D length;
 	desc->buf_ptr =3D dma_map_single(NULL, skb->data, length, DMA_TO_DEVICE=
);
=20
+#ifdef CONFIG_GT64260
+	flush_dcache_addr_size(skb->data, length);
+	invalidate_dcache_addr_size(skb->data, length);
+
+	if (skb->ip_summed =3D=3D CHECKSUM_PARTIAL)
+		BUG();
+#else
 	if (skb->ip_summed =3D=3D CHECKSUM_PARTIAL) {
 		BUG_ON(skb->protocol !=3D ETH_P_IP);
=20
@@ -1179,10 +1459,14 @@
 		cmd_sts |=3D 5 << ETH_TX_IHL_SHIFT;
 		desc->l4i_chk =3D 0;
 	}
+#endif
=20
 	/* ensure all other descriptors are written before first cmd_sts */
 	wmb();
 	desc->cmd_sts =3D cmd_sts;
+#ifdef CONFIG_GT64260
+	flush_dcache_addr_size(desc, sizeof(struct eth_tx_desc));
+#endif
=20
 	/* ensure all descriptors are written before poking hardware */
 	wmb();
@@ -1640,7 +1936,7 @@
  *		within the scope of this driver. Thus, the user is required to
  *		allocate memory for the descriptors ring and buffers. Those
  *		memory parameters are used by the Rx and Tx ring initialization
- *		routines in order to curve the descriptor linked list in a form
+ *		routines in order to carve the descriptor linked list in a form
  *		of a ring.
  *		Note: Pay special attention to alignment issues when using
  *		cached descriptors/buffers. In this phase the driver store
@@ -1716,7 +2012,12 @@
 static void ethernet_phy_set(unsigned int eth_port_num, int phy_addr);
=20
 /* Ethernet Port routines */
+#ifdef CONFIG_GT64260
+static void eth_port_set_filter_table_entry(unsigned int port,
+	unsigned char *p_addr, unsigned int rd, unsigned int skip);
+#else
 static void eth_port_set_filter_table_entry(int table, unsigned char ent=
ry);
+#endif
=20
 /*
  * eth_port_init - Initialize the Ethernet port driver
@@ -1783,7 +2084,7 @@
 	struct mv643xx_private *mp =3D netdev_priv(dev);
 	unsigned int port_num =3D mp->port_num;
 	int tx_curr_desc, rx_curr_desc;
-	u32 pscr;
+	u32 reg;
 	struct ethtool_cmd ethtool_cmd;
=20
 	/* Assignment of Tx CTRP of given queue */
@@ -1793,6 +2094,10 @@
=20
 	/* Assignment of Rx CRDP of given queue */
 	rx_curr_desc =3D mp->rx_curr_desc_q;
+#ifdef CONFIG_GT64260
+	mv_write(MV643XX_ETH_RX_FIRST_QUEUE_DESC_PTR_0(port_num),
+		(u32)((struct eth_rx_desc *)mp->rx_desc_dma + rx_curr_desc));
+#endif
 	mv_write(MV643XX_ETH_RX_CURRENT_QUEUE_DESC_PTR_0(port_num),
 		(u32)((struct eth_rx_desc *)mp->rx_desc_dma + rx_curr_desc));
=20
@@ -1800,27 +2105,57 @@
 	eth_port_uc_addr_set(port_num, dev->dev_addr);
=20
 	/* Assign port configuration and command. */
+#ifdef CONFIG_GT64260
+	reg =3D GT64260_ETH_PORT_CONFIG_DEFAULT_VALUE;
+	reg |=3D ((eth_hash_table_default_mode[port_num] << GT64260_ETH_HASH_DE=
FAULT_SHIFT)
+	      | (eth_hash_table_hash_mode[port_num] << GT64260_ETH_HASH_MODE_SH=
IFT)
+	      | (eth_hash_table_size[port_num] << GT64260_ETH_HASH_SIZE_SHIFT))=
;
+	mv_write(MV643XX_ETH_PORT_CONFIG_REG(port_num), reg);
+
+	mv_write(MV643XX_ETH_PORT_CONFIG_EXTEND_REG(port_num),
+			GT64260_ETH_PORT_CONFIG_EXTEND_DEFAULT_VALUE);
+
+	/* Assign port SDMA configuration */
+	mv_write(MV643XX_ETH_SDMA_CONFIG_REG(port_num),
+			GT64260_ETH_PORT_SDMA_CONFIG_DEFAULT_VALUE);
+
+	/* Enable the interrupt for the port */
+	mv64x60_set_bits(&bh, GT64260_IC_CPU_INTR_MASK_HI, (1 << port_num));
+
+	/* Enable the actual Ethernet port */
+	reg =3D mv_read(MV643XX_ETH_PORT_CONFIG_REG(mp->port_num));
+	reg |=3D GT64260_ETH_ENABLE;
+	mv_write(MV643XX_ETH_PORT_CONFIG_REG(mp->port_num), reg);
+
+	/* Enable port Rx DMA */
+	mv643xx_eth_port_enable_rx(port_num, 0);
+
+	/* Disable port bandwidth limits by clearing MTU register */
+	reg =3D mv_read(MV643XX_ETH_PORT_CONFIG_EXTEND_REG(mp->port_num));
+	reg &=3D ~(0x3 << 14);
+	mv_write(MV643XX_ETH_PORT_CONFIG_EXTEND_REG(mp->port_num), reg);
+#else
 	mv_write(MV643XX_ETH_PORT_CONFIG_REG(port_num),
 			  MV643XX_ETH_PORT_CONFIG_DEFAULT_VALUE);
=20
 	mv_write(MV643XX_ETH_PORT_CONFIG_EXTEND_REG(port_num),
 			  MV643XX_ETH_PORT_CONFIG_EXTEND_DEFAULT_VALUE);
=20
-	pscr =3D mv_read(MV643XX_ETH_PORT_SERIAL_CONTROL_REG(port_num));
+	reg =3D mv_read(MV643XX_ETH_PORT_SERIAL_CONTROL_REG(port_num));
=20
-	pscr &=3D ~(MV643XX_ETH_SERIAL_PORT_ENABLE | MV643XX_ETH_FORCE_LINK_PAS=
S);
-	mv_write(MV643XX_ETH_PORT_SERIAL_CONTROL_REG(port_num), pscr);
+	reg &=3D ~(MV643XX_ETH_SERIAL_PORT_ENABLE | MV643XX_ETH_FORCE_LINK_PASS=
);
+	mv_write(MV643XX_ETH_PORT_SERIAL_CONTROL_REG(port_num), reg);
=20
-	pscr |=3D MV643XX_ETH_DISABLE_AUTO_NEG_FOR_FLOW_CTRL |
-		MV643XX_ETH_DISABLE_AUTO_NEG_SPEED_GMII    |
-		MV643XX_ETH_DISABLE_AUTO_NEG_FOR_DUPLX     |
-		MV643XX_ETH_DO_NOT_FORCE_LINK_FAIL	   |
-		MV643XX_ETH_SERIAL_PORT_CONTROL_RESERVED;
+	reg |=3D MV643XX_ETH_DISABLE_AUTO_NEG_FOR_FLOW_CTRL |
+	       MV643XX_ETH_DISABLE_AUTO_NEG_SPEED_GMII    |
+	       MV643XX_ETH_DISABLE_AUTO_NEG_FOR_DUPLX     |
+	       MV643XX_ETH_DO_NOT_FORCE_LINK_FAIL	   |
+	       MV643XX_ETH_SERIAL_PORT_CONTROL_RESERVED;
=20
-	mv_write(MV643XX_ETH_PORT_SERIAL_CONTROL_REG(port_num), pscr);
+	mv_write(MV643XX_ETH_PORT_SERIAL_CONTROL_REG(port_num), reg);
=20
-	pscr |=3D MV643XX_ETH_SERIAL_PORT_ENABLE;
-	mv_write(MV643XX_ETH_PORT_SERIAL_CONTROL_REG(port_num), pscr);
+	reg |=3D MV643XX_ETH_SERIAL_PORT_ENABLE;
+	mv_write(MV643XX_ETH_PORT_SERIAL_CONTROL_REG(port_num), reg);
=20
 	/* Assign port SDMA configuration */
 	mv_write(MV643XX_ETH_SDMA_CONFIG_REG(port_num),
@@ -1831,6 +2166,7 @@
=20
 	/* Disable port bandwidth limits by clearing MTU register */
 	mv_write(MV643XX_ETH_MAXIMUM_TRANSMIT_UNIT(port_num), 0);
+#endif
=20
 	/* save phy settings across reset */
 	mv643xx_get_settings(dev, &ethtool_cmd);
@@ -1839,10 +2175,27 @@
 }
=20
 /*
- * eth_port_uc_addr_set - Write a MAC address into the port's hw registe=
rs
+ * eth_port_uc_addr_set - This function sets the port Unicast address.
+ *
+ * DESCRIPTION:
+ *		This function sets the port Ethernet MAC address.
+ *
+ * INPUT:
+ *	unsigned int	eth_port_num	Port number.
+ *	char *		p_addr		Address to be set
+ *
+ * OUTPUT:
+ *	Set MAC address low and high registers. also calls
+ *	eth_port_set_filter_table_entry() to set the unicast
+ *	table with the proper information.
+ *
+ * RETURN:
+ *	N/A.
+ *
  */
 static void eth_port_uc_addr_set(unsigned int port_num, unsigned char *p=
_addr)
 {
+#ifndef CONFIG_GT64260
 	unsigned int mac_h;
 	unsigned int mac_l;
 	int table;
@@ -1854,13 +2207,31 @@
 	mv_write(MV643XX_ETH_MAC_ADDR_LOW(port_num), mac_l);
 	mv_write(MV643XX_ETH_MAC_ADDR_HIGH(port_num), mac_h);
=20
-	/* Accept frames with this address */
+	/* Accept frames of this address */
 	table =3D MV643XX_ETH_DA_FILTER_UNICAST_TABLE_BASE(port_num);
 	eth_port_set_filter_table_entry(table, p_addr[5] & 0x0f);
+#else
+	eth_port_set_filter_table_entry(eth_port_num, p_addr, 1, 0);
+#endif
 }
=20
 /*
- * eth_port_uc_addr_get - Read the MAC address from the port's hw regist=
ers
+ * eth_port_uc_addr_get - This function retrieves the port Unicast addre=
ss
+ * (MAC address) from the ethernet hw registers.
+ *
+ * DESCRIPTION:
+ *		This function retrieves the port Ethernet MAC address.
+ *
+ * INPUT:
+ *	unsigned int	eth_port_num	Port number.
+ *	char		*MacAddr	pointer where the MAC address is stored
+ *
+ * OUTPUT:
+ *	Copy the MAC address to the location pointed to by MacAddr
+ *
+ * RETURN:
+ *	N/A.
+ *
  */
 static void eth_port_uc_addr_get(unsigned int port_num, unsigned char *p=
_addr)
 {
@@ -1878,6 +2249,185 @@
 	p_addr[5] =3D mac_l & 0xff;
 }
=20
+#ifdef CONFIG_GT64260
+# define HOP_NUMBER	12
+# define SKIP_BIT	1
+# define VALID		1
+# define _8K_TABLE	0
+
+# define NIBBLE_SWAPPING_32_BIT(X)			\
+	( (((X) & 0xf0f0f0f0) >> 4)			\
+	| (((X) & 0x0f0f0f0f) << 4) )
+
+# define NIBBLE_SWAPPING_16_BIT(X)			\
+	( (((X) & 0x0000f0f0) >> 4)			\
+	| (((X) & 0x00000f0f) << 4) )
+
+# define FLIP_4_BITS(X)					\
+	( (((X) & 0x01) << 3) | (((X) & 0x002) << 1)	\
+	| (((X) & 0x04) >> 1) | (((X) & 0x008) >> 3) )
+
+# define FLIP_6_BITS(X)					\
+	( (((X) & 0x01) << 5) | (((X) & 0x020) >> 5)	\
+	| (((X) & 0x02) << 3) | (((X) & 0x010) >> 3)	\
+	| (((X) & 0x04) << 1) | (((X) & 0x008) >> 1) )
+
+# define FLIP_9_BITS(X)					\
+	( (((X) & 0x01) << 8) | (((X) & 0x100) >> 8)	\
+	| (((X) & 0x02) << 6) | (((X) & 0x080) >> 6)	\
+	| (((X) & 0x04) << 4) | (((X) & 0x040) >> 4)	\
+	| ((X) & 0x10)	| (((X) & 0x08) << 2) | (((X) & 0x020) >> 2) )
+
+/*
+ * eth_hash_table_function - Calculates hash function of an address.
+ *
+ * Depends on the hash mode and hash size being initialized.
+ *
+ * Input :	macH - The 2 most significant bytes of the MAC address.
+ * 		macL - The 4 least significant bytes of the MAC address.
+ * 		hashMode - Hash mode 0 or hash mode 1.
+ * 		hashSizeSelector - Indicates number of hash table entries:
+ *				   (0 =3D 0x8000, 1 =3D 0x800)
+ *
+ * Output :	Calculated entry.
+ */
+static unsigned int
+eth_hash_table_function(unsigned int macH, unsigned int macL,
+		 unsigned int HashSize, unsigned int hash_mode)
+{
+	unsigned int hashResult;
+	unsigned int addrH;
+	unsigned int addrL;
+	unsigned int addr0;
+	unsigned int addr1;
+	unsigned int addr2;
+	unsigned int addr3;
+	unsigned int addrHSwapped;
+	unsigned int addrLSwapped;
+
+	addrH =3D NIBBLE_SWAPPING_16_BIT(macH);
+	addrL =3D NIBBLE_SWAPPING_32_BIT(macL);
+
+	addrHSwapped =3D FLIP_4_BITS(addrH & 0xf)
+	    + ((FLIP_4_BITS((addrH >> 4) & 0xf)) << 4)
+	    + ((FLIP_4_BITS((addrH >> 8) & 0xf)) << 8)
+	    + ((FLIP_4_BITS((addrH >> 12) & 0xf)) << 12);
+
+	addrLSwapped =3D FLIP_4_BITS(addrL & 0xf)
+	    + ((FLIP_4_BITS((addrL >> 4) & 0xf)) << 4)
+	    + ((FLIP_4_BITS((addrL >> 8) & 0xf)) << 8)
+	    + ((FLIP_4_BITS((addrL >> 12) & 0xf)) << 12)
+	    + ((FLIP_4_BITS((addrL >> 16) & 0xf)) << 16)
+	    + ((FLIP_4_BITS((addrL >> 20) & 0xf)) << 20)
+	    + ((FLIP_4_BITS((addrL >> 24) & 0xf)) << 24)
+	    + ((FLIP_4_BITS((addrL >> 28) & 0xf)) << 28);
+
+	addrH =3D addrHSwapped;
+	addrL =3D addrLSwapped;
+
+	if (hash_mode =3D=3D 0) {
+		addr0 =3D (addrL >> 2) & 0x03f;
+		addr1 =3D (addrL & 0x003) | ((addrL >> 8) & 0x7f) << 2;
+		addr2 =3D (addrL >> 15) & 0x1ff;
+		addr3 =3D ((addrL >> 24) & 0x0ff) | ((addrH & 1) << 8);
+	} else {
+		addr0 =3D FLIP_6_BITS(addrL & 0x03f);
+		addr1 =3D FLIP_9_BITS(((addrL >> 6) & 0x1ff));
+		addr2 =3D FLIP_9_BITS((addrL >> 15) & 0x1ff);
+		addr3 =3D
+		    FLIP_9_BITS((((addrL >> 24) & 0x0ff) |
+				 ((addrH & 0x1) << 8)));
+	}
+
+	hashResult =3D (addr0 << 9) | (addr1 ^ addr2 ^ addr3);
+
+	if (HashSize =3D=3D _8K_TABLE) {
+		hashResult =3D hashResult & 0xffff;
+	} else {
+		hashResult =3D hashResult & 0x07ff;
+	}
+
+	return (hashResult);
+}
+
+/*
+ * eth_port_set_filter_table_entry - Add an entry to the hash address ta=
ble.
+ *
+ * Depends on the hash mode and hash size being initialized.
+ *
+ * Input :	port - Ethernet port number.
+ * 		macH - The 2 most significant bytes of the MAC address.
+ * 		macL - The 4 least significant bytes of the MAC address.
+ * 		skip - If 1, skip this address.
+ * 		rd   - If 0, Discard packet upon match. If 1, receive packet.
+ *
+ * Output :	N/A
+ */
+static void eth_port_set_filter_table_entry(unsigned int port,
+		unsigned char *p_addr, unsigned int rd, unsigned int skip)
+{
+	struct eth_hash_table_entry *entry;
+	unsigned int newHi;
+	unsigned int newLo;
+	unsigned int macHi;
+	unsigned int macLo;
+	unsigned int i;
+
+	macHi =3D p_addr[0];
+	macHi =3D (macHi << 8) | p_addr[1];
+	macLo =3D p_addr[2];
+	macLo =3D (macLo << 8) | p_addr[3];
+	macLo =3D (macLo << 8) | p_addr[4];
+	macLo =3D (macLo << 8) | p_addr[5];
+
+	newLo =3D (((macHi >> 4) & 0xf) << 15)
+	    | (((macHi >> 0) & 0xf) << 11)
+	    | (((macHi >> 12) & 0xf) << 7)
+	    | (((macHi >> 8) & 0xf) << 3)
+	    | (((macLo >> 20) & 0x1) << 31)
+	    | (((macLo >> 16) & 0xf) << 27)
+	    | (((macLo >> 28) & 0xf) << 23)
+	    | (((macLo >> 24) & 0xf) << 19)
+	    | (skip << SKIP_BIT) | (rd << 2) | VALID;
+
+	newHi =3D (((macLo >> 4) & 0xf) << 15)
+	    | (((macLo >> 0) & 0xf) << 11)
+	    | (((macLo >> 12) & 0xf) << 7)
+	    | (((macLo >> 8) & 0xf) << 3)
+	    | (((macLo >> 21) & 0x7) << 0);
+
+	/*
+	 * Pick the appropriate table, start scanning for free/reusable
+	 * entries at the index obtained by hashing the specified MAC address
+	 */
+	entry =3D (struct eth_hash_table_entry *) eth_hash_table_vbase_addr[por=
t];
+	entry +=3D eth_hash_table_function(macHi, macLo,
+			eth_hash_table_size[port],
+			eth_hash_table_default_mode[port]);
+
+	for (i =3D 0; i < HOP_NUMBER; i++, entry++) {
+		if (!(entry->lo & VALID) /*|| (entry->lo & SKIP) */ ) {
+			break;
+		} else {	/* if same address put in same position */
+			if (((entry->lo & 0xfffffff8) =3D=3D (newLo & 0xfffffff8))
+			    && (entry->hi =3D=3D newHi)) {
+				break;
+			}
+		}
+	}
+
+	if (i =3D=3D HOP_NUMBER) {
+		printk("eth_port_set_filter_table_entry: Hash table full!\n");
+	}
+
+	/*
+	 * Update the selected entry
+	 */
+	entry->hi =3D newHi;
+	entry->lo =3D newLo;
+	flush_dcache_addr_size(entry, MAC_ENTRY_SIZE);
+}
+#else
 /*
  * The entries in each table are indexed by a hash of a packet's MAC
  * address.  One bit in each entry determines whether the packet is
@@ -2005,13 +2555,13 @@
 	table =3D MV643XX_ETH_DA_FILTER_OTHER_MULTICAST_TABLE_BASE(eth_port_num=
);
 	eth_port_set_filter_table_entry(table, crc_result);
 }
+#endif
=20
 /*
  * Set the entire multicast list based on dev->mc_list.
  */
 static void eth_port_set_multicast_list(struct net_device *dev)
 {
-
 	struct dev_mc_list	*mc_list;
 	int			i;
 	int			table_index;
@@ -2022,6 +2572,24 @@
 	 * we will fully populate both multicast tables with accept.
 	 * This is guaranteed to yield a match on all multicast addresses...
 	 */
+#ifdef CONFIG_GT64260
+	if ((dev->flags & IFF_PROMISC) || (dev->flags & IFF_ALLMULTI)) {
+		struct eth_hash_table_entry *hash_table;
+
+		hash_table =3D (struct eth_hash_table_entry *) eth_hash_table_vbase_ad=
dr[eth_port_num];
+		for (table_index =3D 0; table_index <=3D eth_hash_table_size[eth_port_=
num]; table_index +=3D 1) {
+			hash_table[table_index].lo |=3D VALID;
+		}
+		return;
+	}
+
+	/* Get pointer to net_device multicast list and add each one... */
+	for (i =3D 0, mc_list =3D dev->mc_list;
+			(i < 256) && (mc_list !=3D NULL) && (i < dev->mc_count);
+			i++, mc_list =3D mc_list->next)
+		if (mc_list->dmi_addrlen =3D=3D 6)
+			eth_port_set_filter_table_entry(eth_port_num, mc_list->dmi_addr, 1, 0=
);
+#else
 	if ((dev->flags & IFF_PROMISC) || (dev->flags & IFF_ALLMULTI)) {
 		for (table_index =3D 0; table_index <=3D 0xFC; table_index +=3D 4) {
 			/* Set all entries in DA filter special multicast
@@ -2066,6 +2634,7 @@
 			i++, mc_list =3D mc_list->next)
 		if (mc_list->dmi_addrlen =3D=3D 6)
 			eth_port_mc_addr(eth_port_num, mc_list->dmi_addr);
+#endif
 }
=20
 /*
@@ -2086,6 +2655,12 @@
  */
 static void eth_port_init_mac_tables(unsigned int eth_port_num)
 {
+#ifdef CONFIG_GT64260
+	memset((void *) eth_hash_table_vbase_addr[eth_port_num], 0,
+		(eth_hash_table_size[eth_port_num] * MAC_ENTRY_SIZE));
+	flush_dcache_addr_size(eth_hash_table_vbase_addr[eth_port_num],
+		(eth_hash_table_size[eth_port_num] * MAC_ENTRY_SIZE));
+#else
 	int table_index;
=20
 	/* Clear DA filter unicast table (Ex_dFUT) */
@@ -2101,6 +2676,7 @@
 		mv_write(MV643XX_ETH_DA_FILTER_OTHER_MULTICAST_TABLE_BASE
 					(eth_port_num) + table_index, 0);
 	}
+#endif
 }
=20
 /*
@@ -2125,8 +2701,13 @@
 	int i;
=20
 	/* Perform dummy reads from MIB counters */
+#ifdef CONFIG_GT64260
+	for (i =3D ETH_MIB_OCTETS_RECEIVED; i < ETH_MIB_UNDERSIZE_RECEIVED;
+									i +=3D 4)
+#else
 	for (i =3D ETH_MIB_GOOD_OCTETS_RECEIVED_LOW; i < ETH_MIB_LATE_COLLISION=
;
 									i +=3D 4)
+#endif
 		mv_read(MV643XX_ETH_MIB_COUNTERS_BASE(eth_port_num) + i);
 }
=20
@@ -2137,6 +2718,19 @@
=20
 static void eth_update_mib_counters(struct mv643xx_private *mp)
 {
+#ifdef CONFIG_GT64260
+	struct gt64260_mib_counters *p =3D &mp->mib_counters;
+	int offset;
+
+	p->good_octets_received +=3D
+		read_mib(mp, ETH_MIB_OCTETS_RECEIVED);
+
+	p->good_octets_sent +=3D read_mib(mp, ETH_MIB_OCTETS_SENT);
+
+	for (offset =3D ETH_MIB_OCTETS_RECEIVED;
+			offset < ETH_MIB_UNDERSIZE_RECEIVED; offset +=3D 4)
+		*(u32 *)((char *)p + offset) =3D read_mib(mp, offset);
+#else
 	struct mv643xx_mib_counters *p =3D &mp->mib_counters;
 	int offset;
=20
@@ -2158,6 +2752,7 @@
 			offset <=3D ETH_MIB_LATE_COLLISION;
 			offset +=3D 4)
 		*(u32 *)((char *)p + offset) +=3D read_mib(mp, offset);
+#endif
 }
=20
 /*
@@ -2285,19 +2880,49 @@
 static void mv643xx_eth_port_enable_tx(unsigned int port_num,
 					unsigned int queues)
 {
+#ifdef CONFIG_GT64260
+	mv64x60_set_bits(&bh, MV643XX_ETH_SDMA_COMMAND_REG(port_num),
+		(GT64260_ETH_START_TX_HIGH | GT64260_ETH_START_TX_LOW));
+#else
 	mv_write(MV643XX_ETH_TRANSMIT_QUEUE_COMMAND_REG(port_num), queues);
+#endif
 }
=20
 static void mv643xx_eth_port_enable_rx(unsigned int port_num,
 					unsigned int queues)
 {
+#ifdef CONFIG_GT64260
+	mv64x60_set_bits(&bh, MV643XX_ETH_SDMA_COMMAND_REG(port_num),
+		GT64260_ETH_ENABLE_RX_DMA);
+#else
 	mv_write(MV643XX_ETH_RECEIVE_QUEUE_COMMAND_REG(port_num), queues);
+#endif
 }
=20
 static unsigned int mv643xx_eth_port_disable_tx(unsigned int port_num)
 {
 	u32 queues;
=20
+#ifdef CONFIG_GT64260
+	u32 timeout =3D 100;=20
+
+	queues =3D mv_read(MV643XX_ETH_PORT_STATUS_REG(port_num))
+			& MV643XX_ETH_PORT_STATUS_TX_IN_PROGRESS;
+	if (queues) {
+		/* Stop Tx activity and wait until bit is set */
+		mv64x60_set_bits(&bh, MV643XX_ETH_SDMA_COMMAND_REG(port_num),
+				GT64260_ETH_ABORT_TX_DMA);
+		while ((mv_read(MV643XX_ETH_SDMA_COMMAND_REG(port_num))
+				& GT64260_ETH_ABORT_TX_DMA) && timeout)
+		{
+			udelay(PHY_WAIT_MICRO_SECONDS);
+			timeout--;
+		}
+
+		if (!timeout)
+			printk(KERN_WARNING "MV-643xx: port %d Disable Tx DMA timed out, no l=
ink?\n", port_num);
+	}
+#else
 	/* Stop Tx port activity. Check port Tx activity. */
 	queues =3D mv_read(MV643XX_ETH_TRANSMIT_QUEUE_COMMAND_REG(port_num))
 							& 0xFF;
@@ -2317,6 +2942,7 @@
 							ETH_PORT_TX_FIFO_EMPTY)
 			udelay(PHY_WAIT_MICRO_SECONDS);
 	}
+#endif
=20
 	return queues;
 }
@@ -2325,6 +2951,16 @@
 {
 	u32 queues;
=20
+#ifdef CONFIG_GT64260
+	/* Stop Rx activity and wait until bit is set */
+	mv64x60_set_bits(&bh, MV643XX_ETH_SDMA_COMMAND_REG(port_num),
+			GT64260_ETH_ABORT_RX_DMA);
+	while (mv_read(MV643XX_ETH_SDMA_COMMAND_REG(port_num))
+			& GT64260_ETH_ABORT_RX_DMA)
+		udelay(PHY_WAIT_MICRO_SECONDS);
+
+	queues =3D 0;
+#else
 	/* Stop Rx port activity. Check port Rx activity. */
 	queues =3D mv_read(MV643XX_ETH_RECEIVE_QUEUE_COMMAND_REG(port_num))
 							& 0xFF;
@@ -2339,6 +2975,7 @@
 							& 0xFF)
 			udelay(PHY_WAIT_MICRO_SECONDS);
 	}
+#endif
=20
 	return queues;
 }
@@ -2363,7 +3000,9 @@
  */
 static void eth_port_reset(unsigned int port_num)
 {
+#ifndef CONFIG_GT64260
 	unsigned int reg_data;
+#endif
=20
 	mv643xx_eth_port_disable_tx(port_num);
 	mv643xx_eth_port_disable_rx(port_num);
@@ -2371,12 +3010,18 @@
 	/* Clear all MIB counters */
 	eth_clear_mib_counters(port_num);
=20
+#ifdef CONFIG_GT64260
+	/* Mask main Ethernet interrupt */
+	mv64x60_clr_bits(&bh, GT64260_IC_CPU_INTR_MASK_HI,
+		(1 << port_num));
+#else
 	/* Reset the Enable bit in the Configuration Register */
 	reg_data =3D mv_read(MV643XX_ETH_PORT_SERIAL_CONTROL_REG(port_num));
 	reg_data &=3D ~(MV643XX_ETH_SERIAL_PORT_ENABLE		|
 			MV643XX_ETH_DO_NOT_FORCE_LINK_FAIL	|
 			MV643XX_ETH_FORCE_LINK_PASS);
 	mv_write(MV643XX_ETH_PORT_SERIAL_CONTROL_REG(port_num), reg_data);
+#endif
 }
=20
=20
@@ -2544,6 +3189,10 @@
 	rx_used_desc =3D mp->rx_used_desc_q;
=20
 	p_rx_desc =3D &mp->p_rx_desc_area[rx_curr_desc];
+#ifdef CONFIG_GT64260
+	flush_dcache_addr_size(p_rx_desc, sizeof(struct eth_rx_desc));
+	mb();
+#endif
=20
 	/* The following parameters are used to save readings from memory */
 	command_status =3D p_rx_desc->cmd_sts;
@@ -2555,6 +3204,10 @@
 		return ETH_END_OF_JOB;
 	}
=20
+#ifdef CONFIG_GT64260
+	invalidate_dcache_addr_size(p_rx_desc, sizeof(struct eth_rx_desc));
+	mb();
+#endif
 	p_pkt_info->byte_cnt =3D (p_rx_desc->byte_cnt) - RX_BUF_OFFSET;
 	p_pkt_info->cmd_sts =3D command_status;
 	p_pkt_info->buf_ptr =3D (p_rx_desc->buf_ptr) + RX_BUF_OFFSET;
@@ -2623,6 +3276,9 @@
 	wmb();
 	p_used_rx_desc->cmd_sts =3D
 			ETH_BUFFER_OWNED_BY_DMA | ETH_RX_ENABLE_INTERRUPT;
+#ifdef CONFIG_GT64260
+	flush_dcache_addr_size(p_used_rx_desc, sizeof(struct eth_rx_desc));
+#endif
 	wmb();
=20
 	/* Move the used descriptor pointer to the next descriptor */
@@ -2656,6 +3312,33 @@
 	{ "tx_errors", MV643XX_STAT(stats.tx_errors) },
 	{ "rx_dropped", MV643XX_STAT(stats.rx_dropped) },
 	{ "tx_dropped", MV643XX_STAT(stats.tx_dropped) },
+#ifdef CONFIG_GT64260
+	{ "good_octets_received", MV643XX_STAT(mib_counters.good_octets_receive=
d) },
+	{ "good_frames_received", MV643XX_STAT(mib_counters.good_frames_receive=
d) },
+	{ "broadcast_frames_received", MV643XX_STAT(mib_counters.broadcast_fram=
es_received) },
+	{ "multicast_frames_received", MV643XX_STAT(mib_counters.multicast_fram=
es_received) },
+	{ "total_octets_received", MV643XX_STAT(mib_counters.total_octets_recei=
ved) },
+	{ "total_frames_received", MV643XX_STAT(mib_counters.total_frames_recei=
ved) },
+	{ "frames_64_octets", MV643XX_STAT(mib_counters.frames_64_octets) },
+	{ "frames_65_to_127_octets", MV643XX_STAT(mib_counters.frames_65_to_127=
_octets) },
+	{ "frames_128_to_255_octets", MV643XX_STAT(mib_counters.frames_128_to_2=
55_octets) },
+	{ "frames_256_to_511_octets", MV643XX_STAT(mib_counters.frames_256_to_5=
11_octets) },
+	{ "frames_512_to_1023_octets", MV643XX_STAT(mib_counters.frames_512_to_=
1023_octets) },
+	{ "frames_1024_to_max_octets", MV643XX_STAT(mib_counters.frames_1024_to=
_max_octets) },
+	{ "good_octets_sent", MV643XX_STAT(mib_counters.good_octets_sent) },
+	{ "good_frames_sent", MV643XX_STAT(mib_counters.good_frames_sent) },
+	{ "multicast_frames_sent", MV643XX_STAT(mib_counters.multicast_frames_s=
ent) },
+	{ "broadcast_frames_sent", MV643XX_STAT(mib_counters.broadcast_frames_s=
ent) },
+	{ "dropped_frames", MV643XX_STAT(mib_counters.dropped_frames) },
+	{ "undersize_received", MV643XX_STAT(mib_counters.undersize_received) }=
,
+	{ "fragments_received", MV643XX_STAT(mib_counters.fragments_received) }=
,
+	{ "oversize_received", MV643XX_STAT(mib_counters.oversize_received) },
+	{ "jabber_received", MV643XX_STAT(mib_counters.jabber_received) },
+	{ "mac_receive_error", MV643XX_STAT(mib_counters.mac_receive_error) },
+	{ "bad_crc_event", MV643XX_STAT(mib_counters.bad_crc_event) },
+	{ "collision", MV643XX_STAT(mib_counters.collision) },
+	{ "late_collision", MV643XX_STAT(mib_counters.late_collision) },
+#else
 	{ "good_octets_received", MV643XX_STAT(mib_counters.good_octets_receive=
d) },
 	{ "bad_octets_received", MV643XX_STAT(mib_counters.bad_octets_received)=
 },
 	{ "internal_mac_transmit_err", MV643XX_STAT(mib_counters.internal_mac_t=
ransmit_err) },
@@ -2686,6 +3369,7 @@
 	{ "bad_crc_event", MV643XX_STAT(mib_counters.bad_crc_event) },
 	{ "collision", MV643XX_STAT(mib_counters.collision) },
 	{ "late_collision", MV643XX_STAT(mib_counters.late_collision) },
+#endif
 };
=20
 #define MV643XX_STATS_LEN	\

--------------010103000105000101090502--

--------------enigBCABA663FD2CCE3BD0FC02D4
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2.2 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iD8DBQFGnu5MgyK5H2Ic36cRAoLYAJ49nnQ0JmNxQt1kjG5f56LuCE585wCfVWz6
OjDjD8V+TddXu/3i/oGF+Y4=
=F1B9
-----END PGP SIGNATURE-----

--------------enigBCABA663FD2CCE3BD0FC02D4--
