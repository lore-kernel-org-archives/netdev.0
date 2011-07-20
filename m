From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next-2.6 27/47] acenic: do vlan cleanup
Date: Wed, 20 Jul 2011 16:54:29 +0200
Message-ID: <1311173689-17419-28-git-send-email-jpirko@redhat.com>
References: <1311173689-17419-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net, shemminger@linux-foundation.org,
	eric.dumazet@gmail.com, greearb@candelatech.com, mirqus@gmail.com,
	jes@trained-monkey.org, linux-acenic@sunsite.dk
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:10160 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751543Ab1GTOzv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jul 2011 10:55:51 -0400
In-Reply-To: <1311173689-17419-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- unify vlan and nonvlan rx path
- kill ap->vlgrp and ace_vlan_rx_register
- enable vlan hw accel always (kill vlan ifdefs)

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/acenic.c |   60 +++++--------------------------------------------
 drivers/net/acenic.h |    7 -----
 2 files changed, 7 insertions(+), 60 deletions(-)

diff --git a/drivers/net/acenic.c b/drivers/net/acenic.c
index d7c1bfe4..02fcb5c 100644
--- a/drivers/net/acenic.c
+++ b/drivers/net/acenic.c
@@ -69,10 +69,7 @@
 #include <linux/firmware.h>
 #include <linux/slab.h>
 #include <linux/prefetch.h>
-
-#if defined(CONFIG_VLAN_8021Q) || defined(CONFIG_VLAN_8021Q_MODULE)
 #include <linux/if_vlan.h>
-#endif
 
 #ifdef SIOCETHTOOL
 #include <linux/ethtool.h>
@@ -171,15 +168,6 @@ MODULE_DEVICE_TABLE(pci, acenic_pci_tbl);
 #define BOARD_IDX_STATIC	0
 #define BOARD_IDX_OVERFLOW	-1
 
-#if (defined(CONFIG_VLAN_8021Q) || defined(CONFIG_VLAN_8021Q_MODULE)) && \
-	defined(NETIF_F_HW_VLAN_RX)
-#define ACENIC_DO_VLAN		1
-#define ACE_RCB_VLAN_FLAG	RCB_FLG_VLAN_ASSIST
-#else
-#define ACENIC_DO_VLAN		0
-#define ACE_RCB_VLAN_FLAG	0
-#endif
-
 #include "acenic.h"
 
 /*
@@ -465,9 +453,6 @@ static const struct net_device_ops ace_netdev_ops = {
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address	= ace_set_mac_addr,
 	.ndo_change_mtu		= ace_change_mtu,
-#if ACENIC_DO_VLAN
-	.ndo_vlan_rx_register	= ace_vlan_rx_register,
-#endif
 };
 
 static int __devinit acenic_probe_one(struct pci_dev *pdev,
@@ -491,9 +476,7 @@ static int __devinit acenic_probe_one(struct pci_dev *pdev,
 	ap->name = pci_name(pdev);
 
 	dev->features |= NETIF_F_SG | NETIF_F_IP_CSUM;
-#if ACENIC_DO_VLAN
 	dev->features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
-#endif
 
 	dev->watchdog_timeo = 5*HZ;
 
@@ -1248,7 +1231,7 @@ static int __devinit ace_init(struct net_device *dev)
 	set_aceaddr(&info->rx_std_ctrl.rngptr, ap->rx_ring_base_dma);
 	info->rx_std_ctrl.max_len = ACE_STD_BUFSIZE;
 	info->rx_std_ctrl.flags =
-	  RCB_FLG_TCP_UDP_SUM | RCB_FLG_NO_PSEUDO_HDR | ACE_RCB_VLAN_FLAG;
+	  RCB_FLG_TCP_UDP_SUM | RCB_FLG_NO_PSEUDO_HDR | RCB_FLG_VLAN_ASSIST;
 
 	memset(ap->rx_std_ring, 0,
 	       RX_STD_RING_ENTRIES * sizeof(struct rx_desc));
@@ -1264,7 +1247,7 @@ static int __devinit ace_init(struct net_device *dev)
 		     (sizeof(struct rx_desc) * RX_STD_RING_ENTRIES)));
 	info->rx_jumbo_ctrl.max_len = 0;
 	info->rx_jumbo_ctrl.flags =
-	  RCB_FLG_TCP_UDP_SUM | RCB_FLG_NO_PSEUDO_HDR | ACE_RCB_VLAN_FLAG;
+	  RCB_FLG_TCP_UDP_SUM | RCB_FLG_NO_PSEUDO_HDR | RCB_FLG_VLAN_ASSIST;
 
 	memset(ap->rx_jumbo_ring, 0,
 	       RX_JUMBO_RING_ENTRIES * sizeof(struct rx_desc));
@@ -1286,7 +1269,7 @@ static int __devinit ace_init(struct net_device *dev)
 			       RX_JUMBO_RING_ENTRIES))));
 		info->rx_mini_ctrl.max_len = ACE_MINI_SIZE;
 		info->rx_mini_ctrl.flags =
-		  RCB_FLG_TCP_UDP_SUM|RCB_FLG_NO_PSEUDO_HDR|ACE_RCB_VLAN_FLAG;
+		  RCB_FLG_TCP_UDP_SUM|RCB_FLG_NO_PSEUDO_HDR|RCB_FLG_VLAN_ASSIST;
 
 		for (i = 0; i < RX_MINI_RING_ENTRIES; i++)
 			ap->rx_mini_ring[i].flags =
@@ -1332,7 +1315,7 @@ static int __devinit ace_init(struct net_device *dev)
 	}
 
 	info->tx_ctrl.max_len = ACE_TX_RING_ENTRIES(ap);
-	tmp = RCB_FLG_TCP_UDP_SUM | RCB_FLG_NO_PSEUDO_HDR | ACE_RCB_VLAN_FLAG;
+	tmp = RCB_FLG_TCP_UDP_SUM | RCB_FLG_NO_PSEUDO_HDR | RCB_FLG_VLAN_ASSIST;
 
 	/*
 	 * The Tigon I does not like having the TX ring in host memory ;-(
@@ -2038,12 +2021,9 @@ static void ace_rx_int(struct net_device *dev, u32 rxretprd, u32 rxretcsm)
 		}
 
 		/* send it up */
-#if ACENIC_DO_VLAN
-		if (ap->vlgrp && (bd_flags & BD_FLG_VLAN_TAG)) {
-			vlan_hwaccel_rx(skb, ap->vlgrp, retdesc->vlan);
-		} else
-#endif
-			netif_rx(skb);
+		if ((bd_flags & BD_FLG_VLAN_TAG))
+			__vlan_hwaccel_put_tag(skb, retdesc->vlan);
+		netif_rx(skb);
 
 		dev->stats.rx_packets++;
 		dev->stats.rx_bytes += retdesc->size;
@@ -2262,24 +2242,6 @@ static irqreturn_t ace_interrupt(int irq, void *dev_id)
 	return IRQ_HANDLED;
 }
 
-
-#if ACENIC_DO_VLAN
-static void ace_vlan_rx_register(struct net_device *dev, struct vlan_group *grp)
-{
-	struct ace_private *ap = netdev_priv(dev);
-	unsigned long flags;
-
-	local_irq_save(flags);
-	ace_mask_irq(dev);
-
-	ap->vlgrp = grp;
-
-	ace_unmask_irq(dev);
-	local_irq_restore(flags);
-}
-#endif /* ACENIC_DO_VLAN */
-
-
 static int ace_open(struct net_device *dev)
 {
 	struct ace_private *ap = netdev_priv(dev);
@@ -2449,16 +2411,12 @@ ace_load_tx_bd(struct ace_private *ap, struct tx_desc *desc, u64 addr,
 		writel(addr >> 32, &io->addr.addrhi);
 		writel(addr & 0xffffffff, &io->addr.addrlo);
 		writel(flagsize, &io->flagsize);
-#if ACENIC_DO_VLAN
 		writel(vlan_tag, &io->vlanres);
-#endif
 	} else {
 		desc->addr.addrhi = addr >> 32;
 		desc->addr.addrlo = addr;
 		desc->flagsize = flagsize;
-#if ACENIC_DO_VLAN
 		desc->vlanres = vlan_tag;
-#endif
 	}
 }
 
@@ -2486,12 +2444,10 @@ restart:
 		flagsize = (skb->len << 16) | (BD_FLG_END);
 		if (skb->ip_summed == CHECKSUM_PARTIAL)
 			flagsize |= BD_FLG_TCP_UDP_SUM;
-#if ACENIC_DO_VLAN
 		if (vlan_tx_tag_present(skb)) {
 			flagsize |= BD_FLG_VLAN_TAG;
 			vlan_tag = vlan_tx_tag_get(skb);
 		}
-#endif
 		desc = ap->tx_ring + idx;
 		idx = (idx + 1) % ACE_TX_RING_ENTRIES(ap);
 
@@ -2509,12 +2465,10 @@ restart:
 		flagsize = (skb_headlen(skb) << 16);
 		if (skb->ip_summed == CHECKSUM_PARTIAL)
 			flagsize |= BD_FLG_TCP_UDP_SUM;
-#if ACENIC_DO_VLAN
 		if (vlan_tx_tag_present(skb)) {
 			flagsize |= BD_FLG_VLAN_TAG;
 			vlan_tag = vlan_tx_tag_get(skb);
 		}
-#endif
 
 		ace_load_tx_bd(ap, ap->tx_ring + idx, mapping, flagsize, vlan_tag);
 
diff --git a/drivers/net/acenic.h b/drivers/net/acenic.h
index fd25a3b..f67dc9b 100644
--- a/drivers/net/acenic.h
+++ b/drivers/net/acenic.h
@@ -665,10 +665,6 @@ struct ace_private
 	struct rx_desc		*rx_mini_ring;
 	struct rx_desc		*rx_return_ring;
 
-#if ACENIC_DO_VLAN
-	struct vlan_group	*vlgrp;
-#endif
-
 	int			tasklet_pending, jumbo;
 	struct tasklet_struct	ace_tasklet;
 
@@ -790,8 +786,5 @@ static void ace_free_descriptors(struct net_device *dev);
 static void ace_init_cleanup(struct net_device *dev);
 static struct net_device_stats *ace_get_stats(struct net_device *dev);
 static int read_eeprom_byte(struct net_device *dev, unsigned long offset);
-#if ACENIC_DO_VLAN
-static void ace_vlan_rx_register(struct net_device *dev, struct vlan_group *grp);
-#endif
 
 #endif /* _ACENIC_H_ */
-- 
1.7.6

