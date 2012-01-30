From: Andrea Shepard <andrea@persephoneslair.org>
Subject: [07/22] Cyclades PC300 driver: ioctl() fixes for mixed 64/32-bit systems
Date: Sun, 29 Jan 2012 18:49:29 -0800
Message-ID: <20120130024929.GH10262@cronus.persephoneslair.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: khc@pm.waw.pl, davem@davemloft.net, mmarek@suse.cz,
	jkosina@suse.cz, joe@perches.com, justinmattock@gmail.com,
	gregkh@suse.de, alan@linux.intel.com, jdmason@kudzu.us
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This driver originally passed a struct net_device_stats out in response to
an ioctl(), which broke the case of a 32-bit userland on a 64-bit kernel.
This changes the structure to always use 64-bit field widths and to not try
to pass address of registers out in the hardware info.

Since the format of structures passed in an ioctl() is changed, this requires
an updated userland pc300cfg/pc300util, which may be obtained from:

http://charon.persephoneslair.org/~andrea/software/pc300utils/pc300utils-4.1.1.tar.bz2

This patch also adds a comment noting the need for updated userland tools.

Signed-off-by: Andrea Shepard <andrea@persephoneslair.org>

diff --git a/drivers/net/wan/pc300.h b/drivers/net/wan/pc300.h
index 3a73833..134227a 100644
--- a/drivers/net/wan/pc300.h
+++ b/drivers/net/wan/pc300.h
@@ -290,11 +290,47 @@ typedef struct rsv_x21_status {
 	u8 dtr;
 } rsv_x21_status_t;
 
+struct pc300_net_stats {
+	u64 rx_packets;
+	u64 tx_packets;
+	u64 rx_bytes;
+	u64 tx_bytes;
+	u64 rx_errors;
+	u64 tx_errors;
+	u64 rx_dropped;
+	u64 tx_dropped;
+	u64 multicast;
+	u64 collisions;
+
+	/* detailed rx_errors: */
+	u64 rx_length_errors;
+	u64 rx_over_errors;
+	u64 rx_crc_errors;
+	u64 rx_frame_errors;
+	u64 rx_fifo_errors;
+	u64 rx_missed_errors;
+
+	/* detailed tx_errors */
+	u64 tx_aborted_errors;
+	u64 tx_carrier_errors;
+	u64 tx_fifo_errors;
+	u64 tx_heartbeat_errors;
+	u64 tx_window_errors;
+
+	u64 rx_compressed;
+	u64 tx_compressed;
+};
+
 typedef struct pc300stats {
 	int hw_type;
 	u32 line_on;
 	u32 line_off;
-	struct net_device_stats gen_stats;
+	/* Use this instead of net_device_stats, since passing
+	 * net_device_stats breaks 32-bit user processes on 64-bit kernels,
+	 * and rtnetlink is unreasonably complicated just to get
+	 * some statistics.
+	 */
+	struct pc300_net_stats net_stats;
 	falc_t te_stats;
 } pc300stats_t;
 
@@ -314,6 +350,8 @@ typedef struct pc300patterntst {
 	u16 num_errors;
 } pc300patterntst_t;
 
+#ifdef __KERNEL__
+
 typedef struct pc300dev {
 	struct pc300ch *chan;
 	u8 trace_on;
@@ -360,6 +398,36 @@ typedef struct pc300hw {
 	u32 falcsize;		/* FALC registers MMIO size */
 } pc300hw_t;
 
+#endif /* __KERNEL__ */
+
+/*
+ * It's problematic to pass the addresses out to userland, since their sizes
+ * are so platform-dependent.  The userland pc300cfg program might be 32-bit
+ * even on a 64-bit kernel, and in any case it can't see phys_addr_t.  Since
+ * this information isn't even very interesting and in any case is visible in
+ * from the printk() calls when we init, just leave it out when responding to
+ * SIOCGPC300CONF.
+ */
+
+struct pc300hw_user {
+	int type;               /* RSV, X21, etc. */
+	int bus;                /* Bus (PCI, PMC, etc.) */
+	int nchan;              /* number of channels */
+	int irq;                /* interrupt request level */
+	u32 clock;              /* Board clock */
+	u8 cpld_id;             /* CPLD ID (TE only) */
+	u16 cpld_reg1;          /* CPLD reg 1 (TE only) */
+	u16 cpld_reg2;          /* CPLD reg 2 (TE only) */
+	u16 gpioc_reg;          /* PLX GPIOC reg */
+	u16 intctl_reg;         /* PLX Int Ctrl/Status reg */
+	u32 iosize;             /* PLX registers I/O size */
+	u32 plxsize;            /* PLX registers MMIO size */
+	u32 scasize;            /* SCA registers MMIO size */
+	u32 alloc_ramsize;      /* RAM MMIO size allocated by the PCI bridge */
+	u32 ramsize;            /* On-board RAM MMIO size */
+	u32 falcsize;           /* FALC registers MMIO size */
+};
+
 typedef struct pc300chconf {
 	sync_serial_settings	phys_settings;	/* Clock type/rate (in bps), 
 						   loopback mode */
@@ -376,6 +444,8 @@ typedef struct pc300chconf {
 	u32 tslot_bitmap;	/* bit[i]=1  =>  timeslot _i_ is active */
 } pc300chconf_t;
 
+#ifdef __KERNEL__
+
 typedef struct pc300ch {
 	struct pc300 *card;
 	int channel;
@@ -392,13 +462,13 @@ typedef struct pc300ch {
 typedef struct pc300 {
 	pc300hw_t hw;			/* hardware config. */
 	pc300ch_t chan[PC300_MAXCHAN];
-#ifdef __KERNEL__
 	spinlock_t card_lock;
-#endif /* __KERNEL__ */
 } pc300_t;
 
+#endif /* __KERNEL__ */
+
 typedef struct pc300conf {
-	pc300hw_t hw;
+	struct pc300hw_user hw;
 	pc300chconf_t conf;
 } pc300conf_t;
 
diff --git a/drivers/net/wan/pc300_drv.c b/drivers/net/wan/pc300_drv.c
index 1e59a74..5d51ac1 100644
--- a/drivers/net/wan/pc300_drv.c
+++ b/drivers/net/wan/pc300_drv.c
@@ -16,6 +16,10 @@ static char rcsid[] =
  *	2 of the License, or (at your option) any later version.
  *	
  *	Using tabstop = 4.
+ *
+ * Due to changes in certain ioctls necessary for portability, this
+ * version requires a new version of pc300utils, which may be found
+ * at: http://charon.persephoneslair.org/~andrea/software/pc300utils/
  * 
  * $Log: pc300_drv.c,v $
  * Revision 3.23  2002/03/20 13:58:40  henrique
@@ -344,6 +348,7 @@ static void cpc_closech(pc300dev_t *);
 static int cpc_close(struct net_device *);
 static void cpc_falc_status(pc300_t *, int);
 static struct net_device_stats *cpc_get_stats(struct net_device *);
+static void cpc_hw_info_to_user(const pc300hw_t *, struct pc300hw_user *);
 static void cpc_init_card(pc300_t *);
 static int __devinit cpc_init_one(struct pci_dev *,
 				  const struct pci_device_id *);
@@ -351,6 +356,8 @@ static int __init cpc_init(void);
 static irqreturn_t cpc_intr(int, void *, struct pt_regs *);
 static int cpc_ioctl(struct net_device *, struct ifreq *, int);
 static void cpc_net_rx(struct net_device *);
+static void cpc_net_stats_to_user(const struct net_device_stats *,
+				  struct pc300_net_stats *);
 static int cpc_opench(pc300dev_t *);
 static int cpc_queue_xmit(struct sk_buff *, struct net_device *);
 static void __devexit cpc_remove_one(struct pci_dev *);
@@ -2612,6 +2619,58 @@ static int cpc_change_mtu(struct net_device *dev, int new_mtu)
 	return 0;
 }
 
+/* Helper function to produce userland version of network stats */
+static void cpc_net_stats_to_user(const struct net_device_stats *stats,
+				  struct pc300_net_stats *user_stats)
+{
+	user_stats->rx_packets = stats->rx_packets;
+	user_stats->tx_packets = stats->tx_packets;
+	user_stats->rx_bytes = stats->rx_bytes;
+	user_stats->tx_bytes = stats->tx_bytes;
+	user_stats->rx_errors = stats->rx_errors;
+	user_stats->tx_errors = stats->tx_errors;
+	user_stats->rx_dropped = stats->rx_dropped;
+	user_stats->tx_dropped = stats->tx_dropped;
+	user_stats->multicast = stats->multicast;
+	user_stats->collisions = stats->collisions;
+	user_stats->rx_length_errors = stats->rx_length_errors;
+	user_stats->rx_over_errors = stats->rx_over_errors;
+	user_stats->rx_crc_errors = stats->rx_crc_errors;
+	user_stats->rx_frame_errors = stats->rx_frame_errors;
+	user_stats->rx_fifo_errors = stats->rx_fifo_errors;
+	user_stats->rx_missed_errors = stats->rx_missed_errors;
+	user_stats->tx_aborted_errors = stats->tx_aborted_errors;
+	user_stats->tx_carrier_errors = stats->tx_carrier_errors;
+	user_stats->tx_fifo_errors = stats->tx_fifo_errors;
+	user_stats->tx_heartbeat_errors = stats->tx_heartbeat_errors;
+	user_stats->tx_window_errors = stats->tx_window_errors;
+	user_stats->rx_compressed = stats->rx_compressed;
+	user_stats->tx_compressed = stats->tx_compressed;
+}
+
+/* Helper function to produce userland version of pc300hw struct */
+static void cpc_hw_info_to_user(const pc300hw_t *hw,
+				struct pc300hw_user *user_hw)
+{
+	memset(user_hw, 0, sizeof(*user_hw));
+	user_hw->type = hw->type;
+	user_hw->bus = hw->bus;
+	user_hw->nchan = hw->nchan;
+	user_hw->irq = hw->irq;
+	user_hw->clock = hw->clock;
+	user_hw->cpld_id = hw->cpld_id;
+	user_hw->cpld_reg1 = hw->cpld_reg1;
+	user_hw->cpld_reg2 = hw->cpld_reg2;
+	user_hw->gpioc_reg = hw->gpioc_reg;
+	user_hw->intctl_reg = hw->intctl_reg;
+	user_hw->iosize = hw->iosize;
+	user_hw->plxsize = hw->plxsize;
+	user_hw->scasize = hw->scasize;
+	user_hw->alloc_ramsize = hw->alloc_ramsize;
+	user_hw->ramsize = hw->ramsize;
+	user_hw->falcsize = hw->falcsize;
+}
+
 static int cpc_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 {
 	pc300dev_t *d = (pc300dev_t *) (dev_to_hdlc(dev))->priv;
@@ -2637,7 +2696,7 @@ static int cpc_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 			conf->proto = 0;
 #endif
 			memcpy(&conf_aux.conf, conf, sizeof(pc300chconf_t));
-			memcpy(&conf_aux.hw, &card->hw, sizeof(pc300hw_t));
+			cpc_hw_info_to_user(&card->hw, &conf_aux.hw);
 			if (!arg || 
 				copy_to_user(arg, &conf_aux, sizeof(pc300conf_t))) 
 				return -EINVAL;
@@ -2694,8 +2753,13 @@ static int cpc_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 					pc300stats.hw_type = card->hw.type;
 					pc300stats.line_on = card->chan[ch].d.line_on;
 					pc300stats.line_off = card->chan[ch].d.line_off;
-					memcpy(&pc300stats.gen_stats, &dev->stats,
-					       sizeof(struct net_device_stats));
+					/*
+					 * Do this instead of passing dev->stats
+					 * out so 32-bit userland on 64-bit
+					 * kernel works.
+					 */
+					cpc_net_stats_to_user(&(dev->stats),
+						&(pc300stats.net_stats));
 					if (card->hw.type == PC300_TE)
 						memcpy(&pc300stats.te_stats,&chan->falc,sizeof(falc_t));
 				    	if (copy_to_user(arg, &pc300stats, sizeof(pc300stats_t)))
