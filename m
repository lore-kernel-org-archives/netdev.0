From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (2/2) Convert yam driver to seq_file
Date: Wed, 13 Aug 2003 09:39:26 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030813093926.7b267dd6.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: Jean-Paul Roubelat <jpr@f6fbb.org>, "David S. Miller" <davem@redhat.com>,
   Jeff Garzik <jgarzik@pobox.com>, linux-hams@vger.kernel.org,
   netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Convert the yam driver to use the new seq_file interface to /proc.
This resolves potential issues with module owner and buffer sizes
by using the common library.


This applies to 2.6.0-test3.  Since this driver will come up with out any actual
hardware was able to test load/unload on SMP.

diff -Nru a/drivers/net/hamradio/yam.c b/drivers/net/hamradio/yam.c
--- a/drivers/net/hamradio/yam.c	Wed Aug 13 09:31:31 2003
+++ b/drivers/net/hamradio/yam.c	Wed Aug 13 09:31:31 2003
@@ -72,6 +72,7 @@
 
 #include <linux/kernel.h>
 #include <linux/proc_fs.h>
+#include <linux/seq_file.h>
 
 #include <linux/version.h>
 #include <asm/uaccess.h>
@@ -765,56 +766,73 @@
 	return IRQ_RETVAL(handled);
 }
 
-static int yam_net_get_info(char *buffer, char **start, off_t offset, int length)
+#ifdef CONFIG_PROC_FS
+
+static void *yam_seq_start(struct seq_file *seq, loff_t *pos)
 {
-	int len = 0;
-	int i;
-	off_t pos = 0;
-	off_t begin = 0;
+	return (*pos < NR_PORTS) ? yam_devs[*pos] : NULL;
+}
 
+static void *yam_seq_next(struct seq_file *seq, void *v, loff_t *pos)
+{
+	++*pos;
+	return (*pos < NR_PORTS) ? yam_devs[*pos] : NULL;
+}
 
-	for (i = 0; i < NR_PORTS; i++) {
-		if (yam_ports[i].iobase == 0 || yam_ports[i].irq == 0)
-			continue;
-		len += sprintf(buffer + len, "Device yam%d\n", i);
-		len += sprintf(buffer + len, "  Up       %d\n", netif_running(&yam_ports[i].dev));
-		len += sprintf(buffer + len, "  Speed    %u\n", yam_ports[i].bitrate);
-		len += sprintf(buffer + len, "  IoBase   0x%x\n", yam_ports[i].iobase);
-		len += sprintf(buffer + len, "  BaudRate %u\n", yam_ports[i].baudrate);
-		len += sprintf(buffer + len, "  IRQ      %u\n", yam_ports[i].irq);
-		len += sprintf(buffer + len, "  TxState  %u\n", yam_ports[i].tx_state);
-		len += sprintf(buffer + len, "  Duplex   %u\n", yam_ports[i].dupmode);
-		len += sprintf(buffer + len, "  HoldDly  %u\n", yam_ports[i].holdd);
-		len += sprintf(buffer + len, "  TxDelay  %u\n", yam_ports[i].txd);
-		len += sprintf(buffer + len, "  TxTail   %u\n", yam_ports[i].txtail);
-		len += sprintf(buffer + len, "  SlotTime %u\n", yam_ports[i].slot);
-		len += sprintf(buffer + len, "  Persist  %u\n", yam_ports[i].pers);
-		len += sprintf(buffer + len, "  TxFrames %lu\n", yam_ports[i].stats.tx_packets);
-		len += sprintf(buffer + len, "  RxFrames %lu\n", yam_ports[i].stats.rx_packets);
-		len += sprintf(buffer + len, "  TxInt    %u\n", yam_ports[i].nb_mdint);
-		len += sprintf(buffer + len, "  RxInt    %u\n", yam_ports[i].nb_rxint);
-		len += sprintf(buffer + len, "  RxOver   %lu\n", yam_ports[i].stats.rx_fifo_errors);
-		len += sprintf(buffer + len, "\n");
-
-		pos = begin + len;
-
-		if (pos < offset) {
-			len = 0;
-			begin = pos;
-		}
-		if (pos > offset + length)
-			break;
-	}
+static void yam_seq_stop(struct seq_file *seq, void *v)
+{
+}
 
-	*start = buffer + (offset - begin);
-	len -= (offset - begin);
+static int yam_seq_show(struct seq_file *seq, void *v)
+{
+	const struct net_device *dev = v;
+	const struct yam_port *yp = dev->priv;
+
+	seq_printf(seq, "Device %s\n", dev->name);
+	seq_printf(seq, "  Up       %d\n", netif_running(dev));
+	seq_printf(seq, "  Speed    %u\n", yp->bitrate);
+	seq_printf(seq, "  IoBase   0x%x\n", yp->iobase);
+	seq_printf(seq, "  BaudRate %u\n", yp->baudrate);
+	seq_printf(seq, "  IRQ      %u\n", yp->irq);
+	seq_printf(seq, "  TxState  %u\n", yp->tx_state);
+	seq_printf(seq, "  Duplex   %u\n", yp->dupmode);
+	seq_printf(seq, "  HoldDly  %u\n", yp->holdd);
+	seq_printf(seq, "  TxDelay  %u\n", yp->txd);
+	seq_printf(seq, "  TxTail   %u\n", yp->txtail);
+	seq_printf(seq, "  SlotTime %u\n", yp->slot);
+	seq_printf(seq, "  Persist  %u\n", yp->pers);
+	seq_printf(seq, "  TxFrames %lu\n", yp->stats.tx_packets);
+	seq_printf(seq, "  RxFrames %lu\n", yp->stats.rx_packets);
+	seq_printf(seq, "  TxInt    %u\n", yp->nb_mdint);
+	seq_printf(seq, "  RxInt    %u\n", yp->nb_rxint);
+	seq_printf(seq, "  RxOver   %lu\n", yp->stats.rx_fifo_errors);
+	seq_printf(seq, "\n");
 
-	if (len > length)
-		len = length;
+}
+
+static struct seq_operations yam_seqops = {
+	.start = yam_seq_start,
+	.next = yam_seq_next,
+	.stop = yam_seq_stop,
+	.show = yam_seq_show,
+};
 
-	return len;
+static int yam_info_open(struct inode *inode, struct file *file)
+{
+	return seq_open(file, &yam_seqops);
 }
 
+static struct file_operations yam_info_fops = {
+	.owner = THIS_MODULE,
+	.open = yam_info_open,
+	.read = seq_read,
+	.llseek = seq_lseek,
+	.release = seq_release,
+};
+
+#endif
+
+
 /* --------------------------------------------------------------------- */
 
 static struct net_device_stats *yam_get_stats(struct net_device *dev)
@@ -1153,7 +1171,7 @@
 	yam_timer.expires = jiffies + HZ / 100;
 	add_timer(&yam_timer);
 
-	proc_net_create("yam", 0, yam_net_get_info);
+	proc_net_fops_create("yam", S_IRUGO, &yam_info_fops);
 	return 0;
  error:
 	while (--i >= 0) {
