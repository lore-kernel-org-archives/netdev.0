From: raghavendra.koushik@neterion.com
Subject: [PATCH 2.6.13-rc4 8/13] S2io: VLAN support
Date: Wed,  3 Aug 2005 12:35:55 -0700 (PDT)
Message-ID: <20050803193555.9E77A98336@linux.site>
Cc: raghavendra.koushik@neterion.com, ravinandan.arakali@neterion.com,
        leonid.grossman@neterion.com, rapuru.sriram@neterion.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com, netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,
Patch below adds VLAN support to the driver.


Signed-off-by: Ravinandan Arakali <ravinandan.arakali@neterion.com>
Signed-off-by: Raghavendra Koushik <raghavendra.koushik@neterion.com>
---
diff -uprN vanilla_linux/drivers/net/s2io.c linux-2.6.13-rc4/drivers/net/s2io.c
--- vanilla_linux/drivers/net/s2io.c	2005-08-02 06:31:23.000000000 -0700
+++ linux-2.6.13-rc4/drivers/net/s2io.c	2005-08-02 06:31:39.000000000 -0700
@@ -55,6 +55,7 @@
 #include <linux/ethtool.h>
 #include <linux/version.h>
 #include <linux/workqueue.h>
+#include <linux/if_vlan.h>
 
 #include <asm/system.h>
 #include <asm/uaccess.h>
@@ -174,6 +175,30 @@ static char ethtool_stats_keys[][ETH_GST
 			timer.data = (unsigned long) arg;	\
 			mod_timer(&timer, (jiffies + exp))	\
 
+/* Add the vlan */
+static void s2io_vlan_rx_register(struct net_device *dev,
+					struct vlan_group *grp)
+{
+	nic_t *nic = dev->priv;
+	unsigned long flags;
+
+	spin_lock_irqsave(&nic->tx_lock, flags);
+	nic->vlgrp = grp;
+	spin_unlock_irqrestore(&nic->tx_lock, flags);
+}
+
+/* Unregister the vlan */
+static void s2io_vlan_rx_kill_vid(struct net_device *dev, unsigned long vid)
+{
+	nic_t *nic = dev->priv;
+	unsigned long flags;
+
+	spin_lock_irqsave(&nic->tx_lock, flags);
+	if (nic->vlgrp)
+		nic->vlgrp->vlan_devices[vid] = NULL;
+	spin_unlock_irqrestore(&nic->tx_lock, flags);
+}
+
 /*
  * Constants to be programmed into the Xena's registers, to configure
  * the XAUI.
@@ -2803,6 +2828,8 @@ int s2io_xmit(struct sk_buff *skb, struc
 #ifdef NETIF_F_TSO
 	int mss;
 #endif
+	u16 vlan_tag = 0;
+	int vlan_priority = 0;
 	mac_info_t *mac_control;
 	struct config_param *config;
 
@@ -2821,6 +2848,13 @@ int s2io_xmit(struct sk_buff *skb, struc
 
 	queue = 0;
 
+	/* Get Fifo number to Transmit based on vlan priority */
+	if (sp->vlgrp && vlan_tx_tag_present(skb)) {
+		vlan_tag = vlan_tx_tag_get(skb);
+		vlan_priority = vlan_tag >> 13;
+		queue = config->fifo_mapping[vlan_priority];
+	}
+
 	put_off = (u16) mac_control->fifos[queue].tx_curr_put_info.offset;
 	get_off = (u16) mac_control->fifos[queue].tx_curr_get_info.offset;
 	txdp = (TxD_t *) mac_control->fifos[queue].list_info[put_off].
@@ -2857,6 +2891,11 @@ int s2io_xmit(struct sk_buff *skb, struc
 
 	txdp->Control_2 |= config->tx_intr_type;
 
+	if (sp->vlgrp && vlan_tx_tag_present(skb)) {
+		txdp->Control_2 |= TXD_VLAN_ENABLE;
+		txdp->Control_2 |= TXD_VLAN_TAG(vlan_tag);
+	}
+
 	txdp->Control_1 |= (TXD_BUFFER0_SIZE(frg_len) |
 			    TXD_GATHER_CODE_FIRST);
 	txdp->Control_1 |= TXD_LIST_OWN_XENA;
@@ -4653,10 +4692,23 @@ static int rx_osm_handler(ring_info_t *r
 
 	skb->protocol = eth_type_trans(skb, dev);
 #ifdef CONFIG_S2IO_NAPI
-	netif_receive_skb(skb);
+	if (sp->vlgrp && RXD_GET_VLAN_TAG(rxdp->Control_2)) {
+		/* Queueing the vlan frame to the upper layer */
+		vlan_hwaccel_receive_skb(skb, sp->vlgrp,
+			RXD_GET_VLAN_TAG(rxdp->Control_2));
+	} else {
+		netif_receive_skb(skb);
+	}
 #else
-	netif_rx(skb);
+	if (sp->vlgrp && RXD_GET_VLAN_TAG(rxdp->Control_2)) {
+		/* Queueing the vlan frame to the upper layer */
+		vlan_hwaccel_rx(skb, sp->vlgrp,
+			RXD_GET_VLAN_TAG(rxdp->Control_2));
+	} else {
+		netif_rx(skb);
+	}
 #endif
+
 	dev->last_rx = jiffies;
 	atomic_dec(&sp->rx_bufs_left[ring_no]);
 	return SUCCESS;
@@ -4954,6 +5006,9 @@ s2io_init_nic(struct pci_dev *pdev, cons
 	dev->do_ioctl = &s2io_ioctl;
 	dev->change_mtu = &s2io_change_mtu;
 	SET_ETHTOOL_OPS(dev, &netdev_ethtool_ops);
+	dev->features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
+	dev->vlan_rx_register = s2io_vlan_rx_register;
+	dev->vlan_rx_kill_vid = (void *)s2io_vlan_rx_kill_vid;
 
 	/*
 	 * will use eth_mac_addr() for  dev->set_mac_address
diff -uprN vanilla_linux/drivers/net/s2io.h linux-2.6.13-rc4/drivers/net/s2io.h
--- vanilla_linux/drivers/net/s2io.h	2005-08-02 06:31:23.000000000 -0700
+++ linux-2.6.13-rc4/drivers/net/s2io.h	2005-08-02 06:31:39.000000000 -0700
@@ -689,6 +689,8 @@ struct s2io_nic {
 #define CARD_UP 2
 	atomic_t card_state;
 	volatile unsigned long link_state;
+	struct vlan_group *vlgrp;
+
 	spinlock_t	rx_lock;
 	atomic_t	isr_cnt;
 };
