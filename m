From: Joe Perches <joe@perches.com>
Subject: [RFC PATCH net-next 5/7] drivers/net/jme: Use netif_printk helpers
Date: Tue,  9 Feb 2010 13:49:51 -0800
Message-ID: <3ea1ade8014781cd348f4edef6195c1b2ec612f1.1265751024.git.joe@perches.com>
References: <cover.1265751023.git.joe@perches.com>
Cc: netdev@vger.kernel.org, Ben Hutchings <bhutchings@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1916 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753344Ab0BIVt4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Feb 2010 16:49:56 -0500
In-Reply-To: <cover.1265751023.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert uses of msg_<type> to netif_<level>(
Remove msg_<type> macros

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/jme.c |   54 ++++++++++++++++++++++++++--------------------------
 drivers/net/jme.h |   41 ++++++---------------------------------
 2 files changed, 34 insertions(+), 61 deletions(-)

diff --git a/drivers/net/jme.c b/drivers/net/jme.c
index 26eed49..282a968 100644
--- a/drivers/net/jme.c
+++ b/drivers/net/jme.c
@@ -288,7 +288,7 @@ jme_set_rx_pcc(struct jme_adapter *jme, int p)
 	wmb();
 
 	if (!(test_bit(JME_FLAG_POLL, &jme->flags)))
-		msg_rx_status(jme, "Switched to PCC_P%d\n", p);
+		netif_info(jme, rx_status, jme->dev, "Switched to PCC_P%d\n", p);
 }
 
 static void
@@ -483,13 +483,13 @@ jme_check_link(struct net_device *netdev, int testonly)
 		strcat(linkmsg, (phylink & PHY_LINK_MDI_STAT) ?
 					"MDI-X" :
 					"MDI");
-		msg_link(jme, "Link is up at %s.\n", linkmsg);
+		netif_info(jme, link, jme->dev, "Link is up at %s.\n", linkmsg);
 		netif_carrier_on(netdev);
 	} else {
 		if (testonly)
 			goto out;
 
-		msg_link(jme, "Link is down.\n");
+		netif_info(jme, link, jme->dev, "Link is down.\n");
 		jme->phylink = 0;
 		netif_carrier_off(netdev);
 	}
@@ -883,20 +883,20 @@ jme_rxsum_ok(struct jme_adapter *jme, u16 flags)
 	if (unlikely((flags & (RXWBFLAG_MF | RXWBFLAG_TCPON | RXWBFLAG_TCPCS))
 			== RXWBFLAG_TCPON)) {
 		if (flags & RXWBFLAG_IPV4)
-			msg_rx_err(jme, "TCP Checksum error\n");
+			netif_err(jme, rx_err, jme->dev, "TCP Checksum error\n");
 		return false;
 	}
 
 	if (unlikely((flags & (RXWBFLAG_MF | RXWBFLAG_UDPON | RXWBFLAG_UDPCS))
 			== RXWBFLAG_UDPON)) {
 		if (flags & RXWBFLAG_IPV4)
-			msg_rx_err(jme, "UDP Checksum error.\n");
+			netif_err(jme, rx_err, jme->dev, "UDP Checksum error.\n");
 		return false;
 	}
 
 	if (unlikely((flags & (RXWBFLAG_IPV4 | RXWBFLAG_IPCS))
 			== RXWBFLAG_IPV4)) {
-		msg_rx_err(jme, "IPv4 Checksum error.\n");
+		netif_err(jme, rx_err, jme->dev, "IPv4 Checksum error.\n");
 		return false;
 	}
 
@@ -1186,9 +1186,9 @@ jme_link_change_tasklet(unsigned long arg)
 
 	while (!atomic_dec_and_test(&jme->link_changing)) {
 		atomic_inc(&jme->link_changing);
-		msg_intr(jme, "Get link change lock failed.\n");
+		netif_info(jme, intr, jme->dev, "Get link change lock failed.\n");
 		while (atomic_read(&jme->link_changing) != 1)
-			msg_intr(jme, "Waiting link change lock.\n");
+			netif_info(jme, intr, jme->dev, "Waiting link change lock.\n");
 	}
 
 	if (jme_check_link(netdev, 1) && jme->old_mtu == netdev->mtu)
@@ -1305,7 +1305,7 @@ jme_rx_empty_tasklet(unsigned long arg)
 	if (unlikely(!netif_carrier_ok(jme->dev)))
 		return;
 
-	msg_rx_status(jme, "RX Queue Full!\n");
+	netif_info(jme, rx_status, jme->dev, "RX Queue Full!\n");
 
 	jme_rx_clean_tasklet(arg);
 
@@ -1325,7 +1325,7 @@ jme_wake_queue_if_stopped(struct jme_adapter *jme)
 	smp_wmb();
 	if (unlikely(netif_queue_stopped(jme->dev) &&
 	atomic_read(&txring->nr_free) >= (jme->tx_wake_threshold))) {
-		msg_tx_done(jme, "TX Queue Waked.\n");
+		netif_info(jme, tx_done, jme->dev, "TX Queue Waked.\n");
 		netif_wake_queue(jme->dev);
 	}
 
@@ -1835,7 +1835,7 @@ jme_tx_csum(struct jme_adapter *jme, struct sk_buff *skb, u8 *flags)
 			*flags |= TXFLAG_UDPCS;
 			break;
 		default:
-			msg_tx_err(jme, "Error upper layer protocol.\n");
+			netif_err(jme, tx_err, jme->dev, "Error upper layer protocol.\n");
 			break;
 		}
 	}
@@ -1910,12 +1910,12 @@ jme_stop_queue_if_full(struct jme_adapter *jme)
 	smp_wmb();
 	if (unlikely(atomic_read(&txring->nr_free) < (MAX_SKB_FRAGS+2))) {
 		netif_stop_queue(jme->dev);
-		msg_tx_queued(jme, "TX Queue Paused.\n");
+		netif_info(jme, tx_queued, jme->dev, "TX Queue Paused.\n");
 		smp_wmb();
 		if (atomic_read(&txring->nr_free)
 			>= (jme->tx_wake_threshold)) {
 			netif_wake_queue(jme->dev);
-			msg_tx_queued(jme, "TX Queue Fast Waked.\n");
+			netif_info(jme, tx_queued, jme->dev, "TX Queue Fast Waked.\n");
 		}
 	}
 
@@ -1923,7 +1923,7 @@ jme_stop_queue_if_full(struct jme_adapter *jme)
 			(jiffies - txbi->start_xmit) >= TX_TIMEOUT &&
 			txbi->skb)) {
 		netif_stop_queue(jme->dev);
-		msg_tx_queued(jme, "TX Queue Stopped %d@%lu.\n", idx, jiffies);
+		netif_info(jme, tx_queued, jme->dev, "TX Queue Stopped %d@%lu.\n", idx, jiffies);
 	}
 }
 
@@ -1946,7 +1946,7 @@ jme_start_xmit(struct sk_buff *skb, struct net_device *netdev)
 
 	if (unlikely(idx < 0)) {
 		netif_stop_queue(netdev);
-		msg_tx_err(jme, "BUG! Tx ring full when queue awake!\n");
+		netif_err(jme, tx_err, jme->dev, "BUG! Tx ring full when queue awake!\n");
 
 		return NETDEV_TX_BUSY;
 	}
@@ -2473,7 +2473,7 @@ jme_smb_read(struct jme_adapter *jme, unsigned int addr)
 		val = jread32(jme, JME_SMBCSR);
 	}
 	if (!to) {
-		msg_hw(jme, "SMB Bus Busy.\n");
+		netif_err(jme, hw, jme->dev, "SMB Bus Busy.\n");
 		return 0xFF;
 	}
 
@@ -2489,7 +2489,7 @@ jme_smb_read(struct jme_adapter *jme, unsigned int addr)
 		val = jread32(jme, JME_SMBINTF);
 	}
 	if (!to) {
-		msg_hw(jme, "SMB Bus Busy.\n");
+		netif_err(jme, hw, jme->dev, "SMB Bus Busy.\n");
 		return 0xFF;
 	}
 
@@ -2509,7 +2509,7 @@ jme_smb_write(struct jme_adapter *jme, unsigned int addr, u8 data)
 		val = jread32(jme, JME_SMBCSR);
 	}
 	if (!to) {
-		msg_hw(jme, "SMB Bus Busy.\n");
+		netif_err(jme, hw, jme->dev, "SMB Bus Busy.\n");
 		return;
 	}
 
@@ -2526,7 +2526,7 @@ jme_smb_write(struct jme_adapter *jme, unsigned int addr, u8 data)
 		val = jread32(jme, JME_SMBINTF);
 	}
 	if (!to) {
-		msg_hw(jme, "SMB Bus Busy.\n");
+		netif_err(jme, hw, jme->dev, "SMB Bus Busy.\n");
 		return;
 	}
 
@@ -2876,14 +2876,14 @@ jme_init_one(struct pci_dev *pdev,
 		goto err_out_unmap;
 	}
 
-	msg_probe(jme, "%s%s ver:%x rev:%x macaddr:%pM\n",
-		(jme->pdev->device == PCI_DEVICE_ID_JMICRON_JMC250) ?
-			"JMC250 Gigabit Ethernet" :
-			(jme->pdev->device == PCI_DEVICE_ID_JMICRON_JMC260) ?
-				"JMC260 Fast Ethernet" : "Unknown",
-		(jme->fpgaver != 0) ? " (FPGA)" : "",
-		(jme->fpgaver != 0) ? jme->fpgaver : jme->chiprev,
-		jme->rev, netdev->dev_addr);
+	netif_info(jme, probe, jme->dev, "%s%s ver:%x rev:%x macaddr:%pM\n",
+		   (jme->pdev->device == PCI_DEVICE_ID_JMICRON_JMC250) ?
+		   "JMC250 Gigabit Ethernet" :
+		   (jme->pdev->device == PCI_DEVICE_ID_JMICRON_JMC260) ?
+		   "JMC260 Fast Ethernet" : "Unknown",
+		   (jme->fpgaver != 0) ? " (FPGA)" : "",
+		   (jme->fpgaver != 0) ? jme->fpgaver : jme->chiprev,
+		   jme->rev, netdev->dev_addr);
 
 	return 0;
 
diff --git a/drivers/net/jme.h b/drivers/net/jme.h
index 251abed..c19db91 100644
--- a/drivers/net/jme.h
+++ b/drivers/net/jme.h
@@ -45,43 +45,16 @@
 	printk(KERN_ERR PFX fmt, ## args)
 
 #ifdef TX_DEBUG
-#define tx_dbg(priv, fmt, args...) \
-	printk(KERN_DEBUG "%s: " fmt, (priv)->dev->name, ## args)
+#define tx_dbg(priv, fmt, args...)					\
+	printk(KERN_DEBUG "%s: " fmt, (priv)->dev->name, ##args)
 #else
-#define tx_dbg(priv, fmt, args...)
+#define tx_dbg(priv, fmt, args...)					\
+do {									\
+	if (0)								\
+		printk(KERN_DEBUG "%s: " fmt, (priv)->dev->name, ##args); \
+} while (0)
 #endif
 
-#define jme_msg(msglvl, type, priv, fmt, args...) \
-	if (netif_msg_##type(priv)) \
-		printk(msglvl "%s: " fmt, (priv)->dev->name, ## args)
-
-#define msg_probe(priv, fmt, args...) \
-	jme_msg(KERN_INFO, probe, priv, fmt, ## args)
-
-#define msg_link(priv, fmt, args...) \
-	jme_msg(KERN_INFO, link, priv, fmt, ## args)
-
-#define msg_intr(priv, fmt, args...) \
-	jme_msg(KERN_INFO, intr, priv, fmt, ## args)
-
-#define msg_rx_err(priv, fmt, args...) \
-	jme_msg(KERN_ERR, rx_err, priv, fmt, ## args)
-
-#define msg_rx_status(priv, fmt, args...) \
-	jme_msg(KERN_INFO, rx_status, priv, fmt, ## args)
-
-#define msg_tx_err(priv, fmt, args...) \
-	jme_msg(KERN_ERR, tx_err, priv, fmt, ## args)
-
-#define msg_tx_done(priv, fmt, args...) \
-	jme_msg(KERN_INFO, tx_done, priv, fmt, ## args)
-
-#define msg_tx_queued(priv, fmt, args...) \
-	jme_msg(KERN_INFO, tx_queued, priv, fmt, ## args)
-
-#define msg_hw(priv, fmt, args...) \
-	jme_msg(KERN_ERR, hw, priv, fmt, ## args)
-
 /*
  * Extra PCI Configuration space interface
  */
-- 
1.7.0.rc1.33.g07cf0f

