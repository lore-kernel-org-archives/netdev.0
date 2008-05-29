From: James Cammarata <jimi@sngx.net>
Subject: [PATCH] net: add ability to clear stats via ethtool - e1000/pcnet32
Date: Wed, 28 May 2008 20:45:18 -0500
Message-ID: <483E0AAE.2020107@sngx.net>
References: <482DA5B6.1020606@sngx.net> <482DB46A.8020103@cosmosbay.com> <482EF192.4070707@sngx.net> <482F5113.5090703@cosmosbay.com> <482F610D.2080108@sngx.net> <20080518003104.GK28241@solarflare.com> <482FBA09.80201@sngx.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl093-193-175.stl1.dsl.speakeasy.net ([66.93.193.175]:61779
	"EHLO hades.sngx.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753666AbYE2BoE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 May 2008 21:44:04 -0400
In-Reply-To: <482FBA09.80201@sngx.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I had originally submitted this ability as a patch to procfs, and
general consensus was that it seemed "hackish" to do it that way.  It
was suggested that it be implemented as a feature of ethtool, so I 
thought I'd take on the challenge and add it that way.

I've laid the groundwork here, and added the ability to two of the 
drivers for which I have hardware to test on (e1000 and pcnet32).  I 
also added the code required to call this functionality to the ethtool 
code base, and have been using that to test my changes (using -z as the 
flag to ethtool for clearing stats for now).

If this is an acceptable start, I will gladly start working on adding 
this to as many drivers as possible (we do have some bnx2 hardware, 
though I'm not sure if it's available for testing).

Some other sys-admins have mentioned to me that ethtool doesn't work 
sometimes and they fall back to using mii-tool to configure interfaces,
so I'd still like to have the procfs change implemented to accommodate 
that hardware, but I agree, this is a better way forward.


Signed-off-by: James Cammarata <jimi@sngx.net>
---

--- linux-2.6.25.4/include/linux/ethtool.h	2008-05-15 10:00:12.000000000 -0500
+++ linux-2.6.25.4-jcammara/include/linux/ethtool.h	2008-05-28 17:45:56.000000000 -0500
@@ -325,6 +325,7 @@ int ethtool_op_set_flags(struct net_devi
  * get_strings: Return a set of strings that describe the requested objects 
  * phys_id: Identify the device
  * get_stats: Return statistics about the device
+ * clear_ethtool_stats: Clear device statistics
  * get_flags: get 32-bit flags bitmap
  * set_flags: set 32-bit flags bitmap
  * 
@@ -383,6 +384,7 @@ struct ethtool_ops {
 	void	(*get_strings)(struct net_device *, u32 stringset, u8 *);
 	int	(*phys_id)(struct net_device *, u32);
 	void	(*get_ethtool_stats)(struct net_device *, struct ethtool_stats *, u64 *);
+	int	(*clear_ethtool_stats)(struct net_device *);
 	int	(*begin)(struct net_device *);
 	void	(*complete)(struct net_device *);
 	u32     (*get_ufo)(struct net_device *);
@@ -441,6 +443,7 @@ struct ethtool_ops {
 #define ETHTOOL_SFLAGS		0x00000026 /* Set flags bitmap(ethtool_value) */
 #define ETHTOOL_GPFLAGS		0x00000027 /* Get driver-private flags bitmap */
 #define ETHTOOL_SPFLAGS		0x00000028 /* Set driver-private flags bitmap */
+#define ETHTOOL_CSTATS		0x00000029 /* Clear NIC statistics */
 
 /* compatibility with older code */
 #define SPARC_ETH_GSET		ETHTOOL_GSET
--- linux-2.6.25.4/net/core/ethtool.c	2008-05-15 10:00:12.000000000 -0500
+++ linux-2.6.25.4-jcammara/net/core/ethtool.c	2008-05-28 17:48:51.000000000 -0500
@@ -714,6 +714,16 @@ static int ethtool_get_stats(struct net_
 	return ret;
 }
 
+static int ethtool_clear_stats(struct net_device *dev, void __user *useraddr)
+{
+	const struct ethtool_ops *ops = dev->ethtool_ops;
+
+	if (!ops->clear_ethtool_stats)
+		return -EOPNOTSUPP;
+
+	return ops->clear_ethtool_stats(dev);
+}
+
 static int ethtool_get_perm_addr(struct net_device *dev, void __user *useraddr)
 {
 	struct ethtool_perm_addr epaddr;
@@ -964,6 +974,9 @@ int dev_ethtool(struct net *net, struct 
 		rc = ethtool_set_value(dev, useraddr,
 				       dev->ethtool_ops->set_priv_flags);
 		break;
+	case ETHTOOL_CSTATS:
+		rc = ethtool_clear_stats(dev, useraddr);
+		break;
 	default:
 		rc = -EOPNOTSUPP;
 	}
--- linux-2.6.25.4/drivers/net/e1000/e1000_main.c	2008-05-15 10:00:12.000000000 -0500
+++ linux-2.6.25.4-jcammara/drivers/net/e1000/e1000_main.c	2008-05-28 17:51:07.000000000 -0500
@@ -141,6 +141,7 @@ static void e1000_free_tx_resources(stru
 static void e1000_free_rx_resources(struct e1000_adapter *adapter,
                              struct e1000_rx_ring *rx_ring);
 void e1000_update_stats(struct e1000_adapter *adapter);
+void e1000_clear_stats(struct e1000_adapter *adapter);
 
 static int e1000_init_module(void);
 static void e1000_exit_module(void);
@@ -3819,6 +3820,31 @@ e1000_update_stats(struct e1000_adapter 
 	spin_unlock_irqrestore(&adapter->stats_lock, flags);
 }
 
+void
+e1000_clear_stats(struct e1000_adapter *adapter)
+{
+	struct pci_dev *pdev = adapter->pdev;
+	unsigned long flags;
+
+	#define PHY_IDLE_ERROR_COUNT_MASK 0x00FF
+
+	/*
+	 * Prevent stats update while adapter is being reset, or if the pci
+	 * connection is down.
+	 */
+	if (adapter->link_speed == 0)
+		return;
+	if (pci_channel_offline(pdev))
+		return;
+
+	spin_lock_irqsave(&adapter->stats_lock, flags);
+
+	memset(&adapter->stats, 0, sizeof(struct e1000_hw_stats));
+	memset(&adapter->net_stats, 0, sizeof(struct net_device_stats));
+
+	spin_unlock_irqrestore(&adapter->stats_lock, flags);
+}
+
 /**
  * e1000_intr_msi - Interrupt Handler
  * @irq: interrupt number
--- linux-2.6.25.4/drivers/net/e1000/e1000_ethtool.c	2008-05-15 10:00:12.000000000 -0500
+++ linux-2.6.25.4-jcammara/drivers/net/e1000/e1000_ethtool.c	2008-05-28 17:53:28.000000000 -0500
@@ -42,7 +42,7 @@ extern int e1000_setup_all_tx_resources(
 extern void e1000_free_all_rx_resources(struct e1000_adapter *adapter);
 extern void e1000_free_all_tx_resources(struct e1000_adapter *adapter);
 extern void e1000_update_stats(struct e1000_adapter *adapter);
-
+extern void e1000_clear_stats(struct e1000_adapter *adapter);
 
 struct e1000_stats {
 	char stat_string[ETH_GSTRING_LEN];
@@ -1940,6 +1940,14 @@ e1000_get_ethtool_stats(struct net_devic
 /*	BUG_ON(i != E1000_STATS_LEN); */
 }
 
+static int
+e1000_clear_ethtool_stats(struct net_device *netdev)
+{
+	struct e1000_adapter *adapter = netdev_priv(netdev);
+	e1000_clear_stats(adapter);
+	return 0;
+}
+
 static void
 e1000_get_strings(struct net_device *netdev, uint32_t stringset, uint8_t *data)
 {
@@ -1991,6 +1999,7 @@ static const struct ethtool_ops e1000_et
 	.get_strings            = e1000_get_strings,
 	.phys_id                = e1000_phys_id,
 	.get_ethtool_stats      = e1000_get_ethtool_stats,
+	.clear_ethtool_stats	= e1000_clear_ethtool_stats,
 	.get_sset_count		= e1000_get_sset_count,
 };
 
--- linux-2.6.25.4/drivers/net/pcnet32.c	2008-05-15 10:00:12.000000000 -0500
+++ linux-2.6.25.4-jcammara/drivers/net/pcnet32.c	2008-05-28 17:59:42.000000000 -0500
@@ -312,6 +312,7 @@ static void pcnet32_tx_timeout(struct ne
 static irqreturn_t pcnet32_interrupt(int, void *);
 static int pcnet32_close(struct net_device *);
 static struct net_device_stats *pcnet32_get_stats(struct net_device *);
+static int pcnet32_clear_stats(struct net_device *);
 static void pcnet32_load_multicast(struct net_device *dev);
 static void pcnet32_set_multicast_list(struct net_device *);
 static int pcnet32_ioctl(struct net_device *, struct ifreq *, int);
@@ -1532,6 +1533,7 @@ static const struct ethtool_ops pcnet32_
 	.get_regs_len		= pcnet32_get_regs_len,
 	.get_regs		= pcnet32_get_regs,
 	.get_sset_count		= pcnet32_get_sset_count,
+	.clear_ethtool_stats	= pcnet32_clear_stats,
 };
 
 /* only probes for non-PCI devices, the rest are handled by
@@ -2719,6 +2721,17 @@ static struct net_device_stats *pcnet32_
 	return &dev->stats;
 }
 
+static int pcnet32_clear_stats(struct net_device *dev)
+{
+	struct pcnet32_private *lp = netdev_priv(dev);
+	unsigned long flags;
+
+	spin_lock_irqsave(&lp->lock, flags);
+	memset(&dev->stats, 0, sizeof(struct net_device_stats));
+	spin_unlock_irqrestore(&lp->lock, flags);
+	return 0;
+}
+
 /* taken from the sunlance driver, which it took from the depca driver */
 static void pcnet32_load_multicast(struct net_device *dev)
 {
