From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] hamradio/scc -
Date: Mon, 15 Sep 2003 16:23:35 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030915162335.0034a551.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-hams@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Update hamradio/scc for 2.6.0-test5
	- use seq_file for /proc
	- get rid of dev_get()
	- use alloc_netdev

Don't have hardware, but can load/unload the module fine.

diff -Nru a/drivers/net/hamradio/scc.c b/drivers/net/hamradio/scc.c
--- a/drivers/net/hamradio/scc.c	Mon Sep 15 16:20:49 2003
+++ b/drivers/net/hamradio/scc.c	Mon Sep 15 16:20:49 2003
@@ -171,6 +171,7 @@
 #include <linux/ctype.h>
 #include <linux/kernel.h>
 #include <linux/proc_fs.h>
+#include <linux/seq_file.h>
 
 #include <net/ax25.h>
 
@@ -202,8 +203,8 @@
 static irqreturn_t scc_isr(int irq, void *dev_id, struct pt_regs *regs);
 static void scc_init_timer(struct scc_channel *scc);
 
-static int scc_net_setup(struct scc_channel *scc, unsigned char *name, int addev);
-static int scc_net_init(struct net_device *dev);
+static int scc_net_alloc(const char *name, struct scc_channel *scc);
+static void scc_net_setup(struct net_device *dev);
 static int scc_net_open(struct net_device *dev);
 static int scc_net_close(struct net_device *dev);
 static void scc_net_rx(struct scc_channel *scc, struct sk_buff *skb);
@@ -235,7 +236,7 @@
 
 /* These provide interrupt save 2-step access to the Z8530 registers */
 
-static spinlock_t iolock;	/* Guards paired accesses */
+static spinlock_t iolock = SPIN_LOCK_UNLOCKED;	/* Guards paired accesses */
 
 static inline unsigned char InReg(io_port port, unsigned char reg)
 {
@@ -1512,34 +1513,28 @@
  * Allocate device structure, err, instance, and register driver
  */
 
-static int scc_net_setup(struct scc_channel *scc, unsigned char *name, int addev)
+static int scc_net_alloc(const char *name, struct scc_channel *scc)
 {
+	int err;
 	struct net_device *dev;
 
-	if (dev_get(name))
-	{
-		printk(KERN_INFO "Z8530drv: device %s already exists.\n", name);
-		return -EEXIST;
-	}
-
-	if ((scc->dev = (struct net_device *) kmalloc(sizeof(struct net_device), GFP_KERNEL)) == NULL)
+	dev = alloc_netdev(0, name, scc_net_setup);
+	if (!dev) 
 		return -ENOMEM;
 
-	dev = scc->dev;
-	memset(dev, 0, sizeof(struct net_device));
-
-	strcpy(dev->name, name);
-	dev->priv = (void *) scc;
-	dev->init = scc_net_init;
-
+	dev->priv = scc;
+	scc->dev = dev;
 	spin_lock_init(&scc->lock);
-	
-	if ((addev? register_netdevice(dev) : register_netdev(dev)) != 0) {
-		kfree(dev);
-                return -EIO;
-        }
 
-	SET_MODULE_OWNER(dev);
+	err = register_netdev(dev);
+	if (err) {
+		printk(KERN_ERR "%s: can't register network device (%d)\n", 
+		       name, err);
+		free_netdev(dev);
+		scc->dev = NULL;
+		return err;
+	}
+
 	return 0;
 }
 
@@ -1556,8 +1551,9 @@
 
 /* ----> Initialize device <----- */
 
-static int scc_net_init(struct net_device *dev)
+static void scc_net_setup(struct net_device *dev)
 {
+	SET_MODULE_OWNER(dev);
 	dev->tx_queue_len    = 16;	/* should be enough... */
 
 	dev->open            = scc_net_open;
@@ -1581,7 +1577,6 @@
 	dev->mtu = AX25_DEF_PACLEN;
 	dev->addr_len = AX25_ADDR_LEN;
 
-	return 0;
 }
 
 /* ----> open network device <---- */
@@ -1719,10 +1714,10 @@
 	struct scc_mem_config memcfg;
 	struct scc_hw_config hwcfg;
 	struct scc_calibrate cal;
+	struct scc_channel *scc;
 	int chan;
-	unsigned char device_name[10];
+	unsigned char device_name[IFNAMSIZ];
 	void *arg;
-	struct scc_channel *scc;
 	
 	scc = (struct scc_channel *) dev->priv;
 	arg = (void *) ifr->ifr_data;
@@ -1828,8 +1823,10 @@
 				{
 					request_region(SCC_Info[2*Nchips+chan].ctrl, 1, "scc ctrl");
 					request_region(SCC_Info[2*Nchips+chan].data, 1, "scc data");
-					if (Nchips+chan != 0)
-						scc_net_setup(&SCC_Info[2*Nchips+chan], device_name, 1);
+					if (Nchips+chan != 0 &&
+					    scc_net_alloc(device_name, 
+							  &SCC_Info[2*Nchips+chan]))
+					    return -EINVAL;
 				}
 			}
 			
@@ -1978,39 +1975,58 @@
 /* *		dump statistics to /proc/net/z8530drv		      * */
 /* ******************************************************************** */
 
+#ifdef CONFIG_PROC_FS
 
-static int scc_net_get_info(char *buffer, char **start, off_t offset, int length)
+static inline struct scc_channel *scc_net_seq_idx(loff_t pos)
 {
-	struct scc_channel *scc;
-	struct scc_kiss *kiss;
-	struct scc_stat *stat;
-	int len = 0;
-	off_t pos = 0;
-	off_t begin = 0;
 	int k;
 
-	len += sprintf(buffer, "z8530drv-"VERSION"\n");
-
-	if (!Driver_Initialized)
-	{
-		len += sprintf(buffer+len, "not initialized\n");
-		goto done;
+	for (k = 0; k < Nchips*2; ++k) {
+		if (!SCC_Info[k].init) 
+			continue;
+		if (pos-- == 0)
+			return &SCC_Info[k];
 	}
+	return NULL;
+}
 
-	if (!Nchips)
-	{
-		len += sprintf(buffer+len, "chips missing\n");
-		goto done;
+static void *scc_net_seq_start(struct seq_file *seq, loff_t *pos)
+{
+	return *pos ? scc_net_seq_idx(*pos - 1) : SEQ_START_TOKEN;
+	
+}
+
+static void *scc_net_seq_next(struct seq_file *seq, void *v, loff_t *pos)
+{
+	unsigned k;
+	struct scc_channel *scc = v;
+	++*pos;
+	
+	for (k = (v == SEQ_START_TOKEN) ? 0 : (scc - SCC_Info)+1;
+	     k < Nchips*2; ++k) {
+		if (SCC_Info[k].init) 
+			return &SCC_Info[k];
 	}
+	return NULL;
+}
 
-	for (k = 0; k < Nchips*2; k++)
-	{
-		scc = &SCC_Info[k];
-		stat = &scc->stat;
-		kiss = &scc->kiss;
+static void scc_net_seq_stop(struct seq_file *seq, void *v)
+{
+}
+
+static int scc_net_seq_show(struct seq_file *seq, void *v)
+{
+	if (v == SEQ_START_TOKEN) {
+		seq_puts(seq, "z8530drv-"VERSION"\n");
+	} else if (!Driver_Initialized) {
+		seq_puts(seq, "not initialized\n");
+	} else if (!Nchips) {
+		seq_puts(seq, "chips missing\n");
+	} else {
+		const struct scc_channel *scc = v;
+		const struct scc_stat *stat = &scc->stat;
+		const struct scc_kiss *kiss = &scc->kiss;
 
-		if (!scc->init)
-			continue;
 
 		/* dev	data ctrl irq clock brand enh vector special option 
 		 *	baud nrz clocksrc softdcd bufsize
@@ -2021,24 +2037,24 @@
 		 *	R ## ## XX ## ## ## ## ## XX ## ## ## ## ## ## ##
 		 */
 
-		len += sprintf(buffer+len, "%s\t%3.3lx %3.3lx %d %lu %2.2x %d %3.3lx %3.3lx %d\n",
+		seq_printf(seq, "%s\t%3.3lx %3.3lx %d %lu %2.2x %d %3.3lx %3.3lx %d\n",
 				scc->dev->name,
 				scc->data, scc->ctrl, scc->irq, scc->clock, scc->brand,
 				scc->enhanced, Vector_Latch, scc->special,
 				scc->option);
-		len += sprintf(buffer+len, "\t%lu %d %d %d %d\n",
+		seq_printf(seq, "\t%lu %d %d %d %d\n",
 				scc->modem.speed, scc->modem.nrz,
 				scc->modem.clocksrc, kiss->softdcd,
 				stat->bufsize);
-		len += sprintf(buffer+len, "\t%lu %lu %lu %lu\n",
+		seq_printf(seq, "\t%lu %lu %lu %lu\n",
 				stat->rxints, stat->txints, stat->exints, stat->spints);
-		len += sprintf(buffer+len, "\t%lu %lu %d / %lu %lu %d / %d %d\n",
+		seq_printf(seq, "\t%lu %lu %d / %lu %lu %d / %d %d\n",
 				stat->rxframes, stat->rxerrs, stat->rx_over,
 				stat->txframes, stat->txerrs, stat->tx_under,
 				stat->nospace,  stat->tx_state);
 
 #define K(x) kiss->x
-		len += sprintf(buffer+len, "\t%d %d %d %d %d %d %d %d %d %d %d %d\n",
+		seq_printf(seq, "\t%d %d %d %d %d %d %d %d %d %d %d %d\n",
 				K(txdelay), K(persist), K(slottime), K(tailtime),
 				K(fulldup), K(waittime), K(mintime), K(maxkeyup),
 				K(idletime), K(maxdefer), K(tx_inhibit), K(group));
@@ -2047,43 +2063,49 @@
 		{
 			int reg;
 
-		len += sprintf(buffer+len, "\tW ");
+		seq_printf(seq, "\tW ");
 			for (reg = 0; reg < 16; reg++)
-				len += sprintf(buffer+len, "%2.2x ", scc->wreg[reg]);
-			len += sprintf(buffer+len, "\n");
+				seq_printf(seq, "%2.2x ", scc->wreg[reg]);
+			seq_printf(seq, "\n");
 			
-		len += sprintf(buffer+len, "\tR %2.2x %2.2x XX ", InReg(scc->ctrl,R0), InReg(scc->ctrl,R1));
+		seq_printf(seq, "\tR %2.2x %2.2x XX ", InReg(scc->ctrl,R0), InReg(scc->ctrl,R1));
 			for (reg = 3; reg < 8; reg++)
-				len += sprintf(buffer+len, "%2.2x ", InReg(scc->ctrl, reg));
-			len += sprintf(buffer+len, "XX ");
+				seq_printf(seq, "%2.2x ", InReg(scc->ctrl, reg));
+			seq_printf(seq, "XX ");
 			for (reg = 9; reg < 16; reg++)
-				len += sprintf(buffer+len, "%2.2x ", InReg(scc->ctrl, reg));
-			len += sprintf(buffer+len, "\n");
+				seq_printf(seq, "%2.2x ", InReg(scc->ctrl, reg));
+			seq_printf(seq, "\n");
 		}
 #endif
-		len += sprintf(buffer+len, "\n");
-
-                pos = begin + len;
-
-                if (pos < offset) {
-                        len   = 0;
-                        begin = pos;
-                }
-
-                if (pos > offset + length)
-                        break;
+		seq_putc(seq, '\n');
 	}
 
-done:
+        return 0;
+}
 
-        *start = buffer + (offset - begin);
-        len   -= (offset - begin);
+static struct seq_operations scc_net_seq_ops = {
+	.start  = scc_net_seq_start,
+	.next   = scc_net_seq_next,
+	.stop   = scc_net_seq_stop,
+	.show   = scc_net_seq_show,
+};
 
-        if (len > length) len = length;
 
-        return len;
+static int scc_net_seq_open(struct inode *inode, struct file *file)
+{
+	return seq_open(file, &scc_net_seq_ops);
 }
 
+static struct file_operations scc_net_seq_fops = {
+	.owner	 = THIS_MODULE,
+	.open	 = scc_net_seq_open,
+	.read	 = seq_read,
+	.llseek	 = seq_lseek,
+	.release = seq_release_private,
+};
+
+#endif /* CONFIG_PROC_FS */
+
  
 /* ******************************************************************** */
 /* * 			Init SCC driver 			      * */
@@ -2091,23 +2113,18 @@
 
 static int __init scc_init_driver (void)
 {
-	int result;
-	char devname[10];
+	char devname[IFNAMSIZ];
 	
 	printk(banner);
 	
-	spin_lock_init(&iolock);
-	
 	sprintf(devname,"%s0", SCC_DriverName);
 	
-	result = scc_net_setup(SCC_Info, devname, 0);
-	if (result)
-	{
+	if (scc_net_alloc(devname, SCC_Info)) {
 		printk(KERN_ERR "z8530drv: cannot initialize module\n");
-		return result;
+		return -EIO;
 	}
 
-	proc_net_create("z8530drv", 0, scc_net_get_info);
+	proc_net_fops_create("z8530drv", 0, &scc_net_seq_fops);
 
 	return 0;
 }
@@ -2117,11 +2134,12 @@
 	io_port ctrl;
 	int k;
 	struct scc_channel *scc;
+	struct net_device *dev;
 	
-	if (Nchips == 0)
+	if (Nchips == 0 && (dev = SCC_Info[0].dev)) 
 	{
-		unregister_netdev(SCC_Info[0].dev);
-		free_netdev(SCC_Info[0].dev);
+		unregister_netdev(dev);
+		free_netdev(dev);
 	}
 
 	/* Guard against chip prattle */
