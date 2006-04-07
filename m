From: Andy Fleming <afleming@freescale.com>
Subject: [PATCH] Fix locking in gianfar
Date: Thu, 6 Apr 2006 20:36:00 -0500 (CDT)
Message-ID: <9312C75A-DB98-4818-859E-906FA6461489@freescale.com>
Mime-Version: 1.0 (Apple Message framework v749.3)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw01.freescale.net ([192.88.165.102]:4240 "EHLO
	de01egw01.freescale.net") by vger.kernel.org with ESMTP
	id S932395AbWDLXIt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Apr 2006 19:08:49 -0400
To: Netdev <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fixes several bugs in the gianfar driver, including a  
major one
where spinlocks were horribly broken:

* Split gianfar locks into two types: TX and RX
* Made it so gfar_start() now clears RHALT
* Fixed a bug where calling gfar_start_xmit() with interrupts off would
corrupt the interrupt state
* Fixed a bug where a frame could potentially arrive, and never be  
handled
(if no more frames arrived
* Fixed a bug where the rx_work_limit would never be observed by the rx
completion code
* Fixed a bug where the interrupt handlers were not actually  
protected by
their spinlocks

Signed-off-by: Andy Fleming <afleming@freescale.com>

---

  drivers/net/gianfar.c         |   56 ++++++++++++++++ 
+-----------------
  drivers/net/gianfar.h         |   67 +++++++++++++++++++++++++++ 
+-------------
  drivers/net/gianfar_ethtool.c |   20 +++++++++---
  drivers/net/gianfar_sysfs.c   |   24 +++++++--------
  4 files changed, 100 insertions(+), 67 deletions(-)

5b638b01fefa46929a284b48e51ae36ad0c63009
diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 771e25d..218d317 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -210,7 +210,8 @@ static int gfar_probe(struct platform_de
  		goto regs_fail;
  	}

-	spin_lock_init(&priv->lock);
+	spin_lock_init(&priv->txlock);
+	spin_lock_init(&priv->rxlock);

  	platform_set_drvdata(pdev, dev);

@@ -515,11 +516,13 @@ void stop_gfar(struct net_device *dev)
  	phy_stop(priv->phydev);

  	/* Lock it down */
-	spin_lock_irqsave(&priv->lock, flags);
+	spin_lock_irqsave(&priv->txlock, flags);
+	spin_lock(&priv->rxlock);

  	gfar_halt(dev);

-	spin_unlock_irqrestore(&priv->lock, flags);
+	spin_unlock(&priv->rxlock);
+	spin_unlock_irqrestore(&priv->txlock, flags);

  	/* Free the IRQs */
  	if (priv->einfo->device_flags & FSL_GIANFAR_DEV_HAS_MULTI_INTR) {
@@ -605,14 +608,15 @@ void gfar_start(struct net_device *dev)
  	tempval |= DMACTRL_INIT_SETTINGS;
  	gfar_write(&priv->regs->dmactrl, tempval);

-	/* Clear THLT, so that the DMA starts polling now */
-	gfar_write(&regs->tstat, TSTAT_CLEAR_THALT);
-
  	/* Make sure we aren't stopped */
  	tempval = gfar_read(&priv->regs->dmactrl);
  	tempval &= ~(DMACTRL_GRS | DMACTRL_GTS);
  	gfar_write(&priv->regs->dmactrl, tempval);

+	/* Clear THLT/RHLT, so that the DMA starts polling now */
+	gfar_write(&regs->tstat, TSTAT_CLEAR_THALT);
+	gfar_write(&regs->rstat, RSTAT_CLEAR_RHALT);
+
  	/* Unmask the interrupts we look for */
  	gfar_write(&regs->imask, IMASK_DEFAULT);
  }
@@ -928,12 +932,13 @@ static int gfar_start_xmit(struct sk_buf
  	struct txfcb *fcb = NULL;
  	struct txbd8 *txbdp;
  	u16 status;
+	unsigned long flags;

  	/* Update transmit stats */
  	priv->stats.tx_bytes += skb->len;

  	/* Lock priv now */
-	spin_lock_irq(&priv->lock);
+	spin_lock_irqsave(&priv->txlock, flags);

  	/* Point at the first free tx descriptor */
  	txbdp = priv->cur_tx;
@@ -1004,7 +1009,7 @@ static int gfar_start_xmit(struct sk_buf
  	gfar_write(&priv->regs->tstat, TSTAT_CLEAR_THALT);

  	/* Unlock priv */
-	spin_unlock_irq(&priv->lock);
+	spin_unlock_irqrestore(&priv->txlock, flags);

  	return 0;
  }
@@ -1049,7 +1054,7 @@ static void gfar_vlan_rx_register(struct
  	unsigned long flags;
  	u32 tempval;

-	spin_lock_irqsave(&priv->lock, flags);
+	spin_lock_irqsave(&priv->rxlock, flags);

  	priv->vlgrp = grp;

@@ -1076,7 +1081,7 @@ static void gfar_vlan_rx_register(struct
  		gfar_write(&priv->regs->rctrl, tempval);
  	}

-	spin_unlock_irqrestore(&priv->lock, flags);
+	spin_unlock_irqrestore(&priv->rxlock, flags);
  }


@@ -1085,12 +1090,12 @@ static void gfar_vlan_rx_kill_vid(struct
  	struct gfar_private *priv = netdev_priv(dev);
  	unsigned long flags;

-	spin_lock_irqsave(&priv->lock, flags);
+	spin_lock_irqsave(&priv->rxlock, flags);

  	if (priv->vlgrp)
  		priv->vlgrp->vlan_devices[vid] = NULL;

-	spin_unlock_irqrestore(&priv->lock, flags);
+	spin_unlock_irqrestore(&priv->rxlock, flags);
  }


@@ -1179,7 +1184,7 @@ static irqreturn_t gfar_transmit(int irq
  	gfar_write(&priv->regs->ievent, IEVENT_TX_MASK);

  	/* Lock priv */
-	spin_lock(&priv->lock);
+	spin_lock(&priv->txlock);
  	bdp = priv->dirty_tx;
  	while ((bdp->status & TXBD_READY) == 0) {
  		/* If dirty_tx and cur_tx are the same, then either the */
@@ -1224,7 +1229,7 @@ static irqreturn_t gfar_transmit(int irq
  	else
  		gfar_write(&priv->regs->txic, 0);

-	spin_unlock(&priv->lock);
+	spin_unlock(&priv->txlock);

  	return IRQ_HANDLED;
  }
@@ -1305,9 +1310,10 @@ irqreturn_t gfar_receive(int irq, void *
  {
  	struct net_device *dev = (struct net_device *) dev_id;
  	struct gfar_private *priv = netdev_priv(dev);
-
  #ifdef CONFIG_GFAR_NAPI
  	u32 tempval;
+#else
+	unsigned long flags;
  #endif

  	/* Clear IEVENT, so rx interrupt isn't called again
@@ -1330,7 +1336,7 @@ irqreturn_t gfar_receive(int irq, void *
  	}
  #else

-	spin_lock(&priv->lock);
+	spin_lock_irqsave(&priv->rxlock, flags);
  	gfar_clean_rx_ring(dev, priv->rx_ring_size);

  	/* If we are coalescing interrupts, update the timer */
@@ -1341,7 +1347,7 @@ irqreturn_t gfar_receive(int irq, void *
  	else
  		gfar_write(&priv->regs->rxic, 0);

-	spin_unlock(&priv->lock);
+	spin_unlock_irqrestore(&priv->rxlock, flags);
  #endif

  	return IRQ_HANDLED;
@@ -1490,13 +1496,6 @@ int gfar_clean_rx_ring(struct net_device
  	/* Update the current rxbd pointer to be the next one */
  	priv->cur_rx = bdp;

-	/* If no packets have arrived since the
-	 * last one we processed, clear the IEVENT RX and
-	 * BSY bits so that another interrupt won't be
-	 * generated when we set IMASK */
-	if (bdp->status & RXBD_EMPTY)
-		gfar_write(&priv->regs->ievent, IEVENT_RX_MASK);
-
  	return howmany;
  }

@@ -1516,7 +1515,7 @@ static int gfar_poll(struct net_device *
  	rx_work_limit -= howmany;
  	*budget -= howmany;

-	if (rx_work_limit >= 0) {
+	if (rx_work_limit > 0) {
  		netif_rx_complete(dev);

  		/* Clear the halt bit in RSTAT */
@@ -1533,7 +1532,8 @@ static int gfar_poll(struct net_device *
  			gfar_write(&priv->regs->rxic, 0);
  	}

-	return (rx_work_limit < 0) ? 1 : 0;
+	/* Return 1 if there's more work to do */
+	return (rx_work_limit > 0) ? 0 : 1;
  }
  #endif

@@ -1629,7 +1629,7 @@ static void adjust_link(struct net_devic
  	struct phy_device *phydev = priv->phydev;
  	int new_state = 0;

-	spin_lock_irqsave(&priv->lock, flags);
+	spin_lock_irqsave(&priv->txlock, flags);
  	if (phydev->link) {
  		u32 tempval = gfar_read(&regs->maccfg2);
  		u32 ecntrl = gfar_read(&regs->ecntrl);
@@ -1694,7 +1694,7 @@ static void adjust_link(struct net_devic
  	if (new_state && netif_msg_link(priv))
  		phy_print_status(phydev);

-	spin_unlock_irqrestore(&priv->lock, flags);
+	spin_unlock_irqrestore(&priv->txlock, flags);
  }

  /* Update the hash table based on the current list of multicast
diff --git a/drivers/net/gianfar.h b/drivers/net/gianfar.h
index d37d540..127c98c 100644
--- a/drivers/net/gianfar.h
+++ b/drivers/net/gianfar.h
@@ -656,43 +656,62 @@ struct gfar {
   * the buffer descriptor determines the actual condition.
   */
  struct gfar_private {
-	/* pointers to arrays of skbuffs for tx and rx */
+	/* Fields controlled by TX lock */
+	spinlock_t txlock;
+
+	/* Pointer to the array of skbuffs */
  	struct sk_buff ** tx_skbuff;
-	struct sk_buff ** rx_skbuff;

-	/* indices pointing to the next free sbk in skb arrays */
+	/* next free skb in the array */
  	u16 skb_curtx;
-	u16 skb_currx;

-	/* index of the first skb which hasn't been transmitted
-	 * yet. */
+	/* First skb in line to be transmitted */
  	u16 skb_dirtytx;

  	/* Configuration info for the coalescing features */
  	unsigned char txcoalescing;
  	unsigned short txcount;
  	unsigned short txtime;
+
+	/* Buffer descriptor pointers */
+	struct txbd8 *tx_bd_base;	/* First tx buffer descriptor */
+	struct txbd8 *cur_tx;	        /* Next free ring entry */
+	struct txbd8 *dirty_tx;		/* First buffer in line
+					   to be transmitted */
+	unsigned int tx_ring_size;
+
+	/* RX Locked fields */
+	spinlock_t rxlock;
+
+	/* skb array and index */
+	struct sk_buff ** rx_skbuff;
+	u16 skb_currx;
+
+	/* RX Coalescing values */
  	unsigned char rxcoalescing;
  	unsigned short rxcount;
  	unsigned short rxtime;

-	/* GFAR addresses */
-	struct rxbd8 *rx_bd_base;	/* Base addresses of Rx and Tx Buffers */
-	struct txbd8 *tx_bd_base;
+	struct rxbd8 *rx_bd_base;	/* First Rx buffers */
  	struct rxbd8 *cur_rx;           /* Next free rx ring entry */
-	struct txbd8 *cur_tx;	        /* Next free ring entry */
-	struct txbd8 *dirty_tx;		/* The Ring entry to be freed. */
-	struct gfar __iomem *regs;	/* Pointer to the GFAR memory mapped  
Registers */
-	u32 __iomem *hash_regs[16];
-	int hash_width;
-	struct net_device_stats stats; /* linux network statistics */
-	struct gfar_extra_stats extra_stats;
-	spinlock_t lock;
+
+	/* RX parameters */
+	unsigned int rx_ring_size;
  	unsigned int rx_buffer_size;
  	unsigned int rx_stash_size;
  	unsigned int rx_stash_index;
-	unsigned int tx_ring_size;
-	unsigned int rx_ring_size;
+
+	struct vlan_group *vlgrp;
+
+	/* Unprotected fields */
+	/* Pointer to the GFAR memory mapped Registers */
+	struct gfar __iomem *regs;
+
+	/* Hash registers and their width */
+	u32 __iomem *hash_regs[16];
+	int hash_width;
+
+	/* global parameters */
  	unsigned int fifo_threshold;
  	unsigned int fifo_starve;
  	unsigned int fifo_starve_off;
@@ -702,13 +721,15 @@ struct gfar_private {
  		extended_hash:1,
  		bd_stash_en:1;
  	unsigned short padding;
-	struct vlan_group *vlgrp;
-	/* Info structure initialized by board setup code */
+
  	unsigned int interruptTransmit;
  	unsigned int interruptReceive;
  	unsigned int interruptError;
+
+	/* info structure initialized by platform code */
  	struct gianfar_platform_data *einfo;

+	/* PHY stuff */
  	struct phy_device *phydev;
  	struct mii_bus *mii_bus;
  	int oldspeed;
@@ -716,6 +737,10 @@ struct gfar_private {
  	int oldlink;

  	uint32_t msg_enable;
+
+	/* Network Statistics */
+	struct net_device_stats stats;
+	struct gfar_extra_stats extra_stats;
  };

  static inline u32 gfar_read(volatile unsigned __iomem *addr)
diff --git a/drivers/net/gianfar_ethtool.c b/drivers/net/ 
gianfar_ethtool.c
index 5de7b2e..d69698c 100644
--- a/drivers/net/gianfar_ethtool.c
+++ b/drivers/net/gianfar_ethtool.c
@@ -455,10 +455,14 @@ static int gfar_sringparam(struct net_de

  		/* Halt TX and RX, and process the frames which
  		 * have already been received */
-		spin_lock_irqsave(&priv->lock, flags);
+		spin_lock_irqsave(&priv->txlock, flags);
+		spin_lock(&priv->rxlock);
+
  		gfar_halt(dev);
  		gfar_clean_rx_ring(dev, priv->rx_ring_size);
-		spin_unlock_irqrestore(&priv->lock, flags);
+
+		spin_unlock(&priv->rxlock);
+		spin_unlock_irqrestore(&priv->txlock, flags);

  		/* Now we take down the rings to rebuild them */
  		stop_gfar(dev);
@@ -488,10 +492,14 @@ static int gfar_set_rx_csum(struct net_d

  		/* Halt TX and RX, and process the frames which
  		 * have already been received */
-		spin_lock_irqsave(&priv->lock, flags);
+		spin_lock_irqsave(&priv->txlock, flags);
+		spin_lock(&priv->rxlock);
+
  		gfar_halt(dev);
  		gfar_clean_rx_ring(dev, priv->rx_ring_size);
-		spin_unlock_irqrestore(&priv->lock, flags);
+
+		spin_unlock(&priv->rxlock);
+		spin_unlock_irqrestore(&priv->txlock, flags);

  		/* Now we take down the rings to rebuild them */
  		stop_gfar(dev);
@@ -523,7 +531,7 @@ static int gfar_set_tx_csum(struct net_d
  	if (!(priv->einfo->device_flags & FSL_GIANFAR_DEV_HAS_CSUM))
  		return -EOPNOTSUPP;

-	spin_lock_irqsave(&priv->lock, flags);
+	spin_lock_irqsave(&priv->txlock, flags);
  	gfar_halt(dev);

  	if (data)
@@ -532,7 +540,7 @@ static int gfar_set_tx_csum(struct net_d
  		dev->features &= ~NETIF_F_IP_CSUM;

  	gfar_start(dev);
-	spin_unlock_irqrestore(&priv->lock, flags);
+	spin_unlock_irqrestore(&priv->txlock, flags);

  	return 0;
  }
diff --git a/drivers/net/gianfar_sysfs.c b/drivers/net/gianfar_sysfs.c
index 51ef181..a6d5c43 100644
--- a/drivers/net/gianfar_sysfs.c
+++ b/drivers/net/gianfar_sysfs.c
@@ -82,7 +82,7 @@ static ssize_t gfar_set_bd_stash(struct
  	else
  		return count;

-	spin_lock_irqsave(&priv->lock, flags);
+	spin_lock_irqsave(&priv->rxlock, flags);

  	/* Set the new stashing value */
  	priv->bd_stash_en = new_setting;
@@ -96,7 +96,7 @@ static ssize_t gfar_set_bd_stash(struct

  	gfar_write(&priv->regs->attr, temp);

-	spin_unlock_irqrestore(&priv->lock, flags);
+	spin_unlock_irqrestore(&priv->rxlock, flags);

  	return count;
  }
@@ -118,7 +118,7 @@ static ssize_t gfar_set_rx_stash_size(st
  	u32 temp;
  	unsigned long flags;

-	spin_lock_irqsave(&priv->lock, flags);
+	spin_lock_irqsave(&priv->rxlock, flags);
  	if (length > priv->rx_buffer_size)
  		return count;

@@ -142,7 +142,7 @@ static ssize_t gfar_set_rx_stash_size(st

  	gfar_write(&priv->regs->attr, temp);

-	spin_unlock_irqrestore(&priv->lock, flags);
+	spin_unlock_irqrestore(&priv->rxlock, flags);

  	return count;
  }
@@ -166,7 +166,7 @@ static ssize_t gfar_set_rx_stash_index(s
  	u32 temp;
  	unsigned long flags;

-	spin_lock_irqsave(&priv->lock, flags);
+	spin_lock_irqsave(&priv->rxlock, flags);
  	if (index > priv->rx_stash_size)
  		return count;

@@ -180,7 +180,7 @@ static ssize_t gfar_set_rx_stash_index(s
  	temp |= ATTRELI_EI(index);
  	gfar_write(&priv->regs->attreli, flags);

-	spin_unlock_irqrestore(&priv->lock, flags);
+	spin_unlock_irqrestore(&priv->rxlock, flags);

  	return count;
  }
@@ -205,7 +205,7 @@ static ssize_t gfar_set_fifo_threshold(s
  	if (length > GFAR_MAX_FIFO_THRESHOLD)
  		return count;

-	spin_lock_irqsave(&priv->lock, flags);
+	spin_lock_irqsave(&priv->txlock, flags);

  	priv->fifo_threshold = length;

@@ -214,7 +214,7 @@ static ssize_t gfar_set_fifo_threshold(s
  	temp |= length;
  	gfar_write(&priv->regs->fifo_tx_thr, temp);

-	spin_unlock_irqrestore(&priv->lock, flags);
+	spin_unlock_irqrestore(&priv->txlock, flags);

  	return count;
  }
@@ -240,7 +240,7 @@ static ssize_t gfar_set_fifo_starve(stru
  	if (num > GFAR_MAX_FIFO_STARVE)
  		return count;

-	spin_lock_irqsave(&priv->lock, flags);
+	spin_lock_irqsave(&priv->txlock, flags);

  	priv->fifo_starve = num;

@@ -249,7 +249,7 @@ static ssize_t gfar_set_fifo_starve(stru
  	temp |= num;
  	gfar_write(&priv->regs->fifo_tx_starve, temp);

-	spin_unlock_irqrestore(&priv->lock, flags);
+	spin_unlock_irqrestore(&priv->txlock, flags);

  	return count;
  }
@@ -274,7 +274,7 @@ static ssize_t gfar_set_fifo_starve_off(
  	if (num > GFAR_MAX_FIFO_STARVE_OFF)
  		return count;

-	spin_lock_irqsave(&priv->lock, flags);
+	spin_lock_irqsave(&priv->txlock, flags);

  	priv->fifo_starve_off = num;

@@ -283,7 +283,7 @@ static ssize_t gfar_set_fifo_starve_off(
  	temp |= num;
  	gfar_write(&priv->regs->fifo_tx_starve_shutoff, temp);

-	spin_unlock_irqrestore(&priv->lock, flags);
+	spin_unlock_irqrestore(&priv->txlock, flags);

  	return count;
  }
-- 
1.2.4

-
To unsubscribe from this list: send the line "unsubscribe netdev" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
