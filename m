From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] Update STRIP driver
Date: Tue, 19 Aug 2003 16:21:56 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030819162156.4a9f6697.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Update the STRIP driver.
	- set owner field on tty ldisc
	- allocate network device objects with alloc_netdev
	- use list_head macros and put locking around list of devices
	- convert to seq_file for /proc
	- use change_mtu hook rather than guessing at mtu changes

Don't have the actual hardware, but since it is a serial line discipline
based thingy, could easily bring it up and play with it over a serial line.

diff -Nru a/drivers/net/wireless/strip.c b/drivers/net/wireless/strip.c
--- a/drivers/net/wireless/strip.c	Tue Aug 19 16:18:49 2003
+++ b/drivers/net/wireless/strip.c	Tue Aug 19 16:18:49 2003
@@ -103,6 +103,7 @@
 #include <linux/if_arp.h>
 #include <linux/if_strip.h>
 #include <linux/proc_fs.h>
+#include <linux/seq_file.h>
 #include <linux/serial.h>
 #include <linux/serialP.h>
 #include <net/arp.h>
@@ -259,8 +260,8 @@
 	 * Internal variables.
 	 */
 
-	struct strip *next;		/* The next struct in the list  */
-	struct strip **referrer;	/* The pointer that points to us */
+	struct list_head  list;		/* Linked list of devices */
+
 	int discard;			/* Set if serial error          */
 	int working;			/* Is radio working correctly?  */
 	int firmware_level;		/* Message structuring level    */
@@ -434,8 +435,8 @@
 /************************************************************************/
 /* Global variables							*/
 
-static struct strip *struct_strip_list;
-static spinlock_t strip_lock;
+static LIST_HEAD(strip_list);
+static spinlock_t strip_lock = SPIN_LOCK_UNLOCKED;
 
 /************************************************************************/
 /* Macros								*/
@@ -844,11 +845,11 @@
  * big enough to receive a large radio neighbour list (currently 4K).
  */
 
-static int allocate_buffers(struct strip *strip_info)
+static int allocate_buffers(struct strip *strip_info, int mtu)
 {
 	struct net_device *dev = strip_info->dev;
 	int sx_size = MAX(STRIP_ENCAP_SIZE(MAX_RECV_MTU), 4096);
-	int tx_size = STRIP_ENCAP_SIZE(dev->mtu) + MaxCommandStringLength;
+	int tx_size = STRIP_ENCAP_SIZE(mtu) + MaxCommandStringLength;
 	__u8 *r = kmalloc(MAX_RECV_MTU, GFP_ATOMIC);
 	__u8 *s = kmalloc(sx_size, GFP_ATOMIC);
 	__u8 *t = kmalloc(tx_size, GFP_ATOMIC);
@@ -858,7 +859,7 @@
 		strip_info->tx_buff = t;
 		strip_info->sx_size = sx_size;
 		strip_info->tx_size = tx_size;
-		strip_info->mtu = dev->mtu;
+		strip_info->mtu = dev->mtu = mtu;
 		return (1);
 	}
 	if (r)
@@ -871,34 +872,31 @@
 }
 
 /*
- * MTU has been changed by the IP layer. Unfortunately we are not told
- * about this, but we spot it ourselves and fix things up. We could be in
+ * MTU has been changed by the IP layer. 
+ * We could be in
  * an upcall from the tty driver, or in an ip packet queue.
- *
- * Caller must hold the strip_lock
  */
-
-static void strip_changedmtu(struct strip *strip_info)
+static int strip_change_mtu(struct net_device *dev, int new_mtu)
 {
+	struct strip *strip_info = dev->priv;
 	int old_mtu = strip_info->mtu;
-	struct net_device *dev = strip_info->dev;
 	unsigned char *orbuff = strip_info->rx_buff;
 	unsigned char *osbuff = strip_info->sx_buff;
 	unsigned char *otbuff = strip_info->tx_buff;
 
-	if (dev->mtu > MAX_SEND_MTU) {
+	if (new_mtu > MAX_SEND_MTU) {
 		printk(KERN_ERR
 		       "%s: MTU exceeds maximum allowable (%d), MTU change cancelled.\n",
 		       strip_info->dev->name, MAX_SEND_MTU);
-		dev->mtu = old_mtu;
-		return;
+		return -EINVAL;
 	}
 
-	if (!allocate_buffers(strip_info)) {
+	spin_lock_bh(&strip_lock);
+	if (!allocate_buffers(strip_info, new_mtu)) {
 		printk(KERN_ERR "%s: unable to grow strip buffers, MTU change cancelled.\n",
 		       strip_info->dev->name);
-		dev->mtu = old_mtu;
-		return;
+		spin_unlock_bh(&strip_lock);
+		return -ENOMEM;
 	}
 
 	if (strip_info->sx_count) {
@@ -921,6 +919,7 @@
 		}
 	}
 	strip_info->tx_head = strip_info->tx_buff;
+	spin_unlock_bh(&strip_lock);
 
 	printk(KERN_NOTICE "%s: strip MTU changed fom %d to %d.\n",
 	       strip_info->dev->name, old_mtu, strip_info->mtu);
@@ -931,6 +930,8 @@
 		kfree(osbuff);
 	if (otbuff)
 		kfree(otbuff);
+
+	return 0;
 }
 
 static void strip_unlock(struct strip *strip_info)
@@ -944,74 +945,6 @@
 }
 
 
-/************************************************************************/
-/* Callback routines for exporting information through /proc		*/
-
-/*
- * This function updates the total amount of data printed so far. It then
- * determines if the amount of data printed into a buffer  has reached the
- * offset requested. If it hasn't, then the buffer is shifted over so that
- * the next bit of data can be printed over the old bit. If the total
- * amount printed so far exceeds the total amount requested, then this
- * function returns 1, otherwise 0.
- */
-static int
-shift_buffer(char *buffer, int requested_offset, int requested_len,
-	     int *total, int *slop, char **buf)
-{
-	int printed;
-
-	/* printk(KERN_DEBUG "shift: buffer: %d o: %d l: %d t: %d buf: %d\n",
-	   (int) buffer, requested_offset, requested_len, *total,
-	   (int) *buf); */
-	printed = *buf - buffer;
-	if (*total + printed <= requested_offset) {
-		*total += printed;
-		*buf = buffer;
-	} else {
-		if (*total < requested_offset) {
-			*slop = requested_offset - *total;
-		}
-		*total = requested_offset + printed - *slop;
-	}
-	if (*total > requested_offset + requested_len) {
-		return 1;
-	} else {
-		return 0;
-	}
-}
-
-/*
- * This function calculates the actual start of the requested data
- * in the buffer. It also calculates actual length of data returned,
- * which could be less that the amount of data requested.
- */
-static int
-calc_start_len(char *buffer, char **start, int requested_offset,
-	       int requested_len, int total, char *buf)
-{
-	int return_len, buffer_len;
-
-	buffer_len = buf - buffer;
-	if (buffer_len >= 4095) {
-		printk(KERN_ERR "STRIP: exceeded /proc buffer size\n");
-	}
-
-	/*
-	 * There may be bytes before and after the
-	 * chunk that was actually requested.
-	 */
-	return_len = total - requested_offset;
-	if (return_len < 0) {
-		return_len = 0;
-	}
-	*start = buf - return_len;
-	if (return_len > requested_len) {
-		return_len = requested_len;
-	}
-	/* printk(KERN_DEBUG "return_len: %d\n", return_len); */
-	return return_len;
-}
 
 /*
  * If the time is in the near future, time_delta prints the number of
@@ -1032,44 +965,89 @@
 	return (buffer);
 }
 
-static int sprintf_neighbours(char *buffer, MetricomNodeTable * table,
-			      char *title)
+#define STRIP_PROC_HEADER	((void *)1)
+
+/* get Nth element of the linked list */
+static struct strip *strip_get_idx(loff_t pos) 
+{
+	struct list_head *l;
+	int i = 0;
+
+	list_for_each_rcu(l, &strip_list) {
+		if (pos == i)
+			return list_entry(l, struct strip, list);
+		++i;
+	}
+	return NULL;
+}
+
+static void *strip_seq_start(struct seq_file *seq, loff_t *pos)
+{
+	rcu_read_lock();
+	return *pos ? strip_get_idx(*pos - 1) : STRIP_PROC_HEADER;
+}
+
+static void *strip_seq_next(struct seq_file *seq, void *v, loff_t *pos)
+{
+	struct list_head *l;
+	struct strip *s;
+
+	++*pos;
+	if (v == STRIP_PROC_HEADER)
+		return strip_get_idx(1);
+
+	s = v;
+	l = &s->list;
+	list_for_each_continue_rcu(l, &strip_list) {
+		return list_entry(l, struct strip, list);
+	}
+	return NULL;
+}
+
+static void strip_seq_stop(struct seq_file *seq, void *v)
+{
+	rcu_read_unlock();
+}
+
+static void strip_seq_neighbours(struct seq_file *seq,
+			   const MetricomNodeTable * table,
+			   const char *title)
 {
 	/* We wrap this in a do/while loop, so if the table changes */
 	/* while we're reading it, we just go around and try again. */
 	struct timeval t;
-	char *ptr;
-	unsigned long flags;
 
 	do {
 		int i;
 		t = table->timestamp;
-		ptr = buffer;
 		if (table->num_nodes)
-			ptr += sprintf(ptr, "\n %s\n", title);
+			seq_printf(seq, "\n %s\n", title);
 		for (i = 0; i < table->num_nodes; i++) {
 			MetricomNode node;
 
-			spin_lock_irqsave(&strip_lock, flags);
+			spin_lock_bh(&strip_lock);
 			node = table->node[i];
-			spin_unlock_irqrestore(&strip_lock, flags);
-			ptr += sprintf(ptr, "  %s\n", node.c);
+			spin_unlock_bh(&strip_lock);
+			seq_printf(seq, "  %s\n", node.c);
 		}
 	} while (table->timestamp.tv_sec != t.tv_sec
 		 || table->timestamp.tv_usec != t.tv_usec);
-	return ptr - buffer;
 }
 
 /*
- * This function prints radio status information into the specified buffer.
- * I think the buffer size is 4K, so this routine should never print more
- * than 4K of data into it. With the maximum of 32 portables and 32 poletops
+ * This function prints radio status information via the seq_file
+ * interface.  The interface takes care of buffer size and over
+ * run issues. 
+ *
+ * The buffer in seq_file is PAGESIZE (4K) 
+ * so this routine should never print more or it will get truncated.
+ * With the maximum of 32 portables and 32 poletops
  * reported, the routine outputs 3107 bytes into the buffer.
  */
-static int sprintf_status_info(char *buffer, struct strip *strip_info)
+static void strip_seq_status_info(struct seq_file *seq, 
+				  const struct strip *strip_info)
 {
 	char temp[32];
-	char *p = buffer;
 	MetricomAddressString addr_string;
 
 	/* First, we must copy all of our data to a safe place, */
@@ -1103,98 +1081,104 @@
 	unsigned long tx_ebytes = strip_info->tx_ebytes;
 #endif
 
-	p += sprintf(p, "\nInterface name\t\t%s\n", if_name);
-	p += sprintf(p, " Radio working:\t\t%s\n", working ? "Yes" : "No");
+	seq_printf(seq, "\nInterface name\t\t%s\n", if_name);
+	seq_printf(seq, " Radio working:\t\t%s\n", working ? "Yes" : "No");
 	radio_address_to_string(&true_dev_addr, &addr_string);
-	p += sprintf(p, " Radio address:\t\t%s\n", addr_string.c);
+	seq_printf(seq, " Radio address:\t\t%s\n", addr_string.c);
 	if (manual_dev_addr) {
 		radio_address_to_string(&dev_dev_addr, &addr_string);
-		p += sprintf(p, " Device address:\t%s\n", addr_string.c);
+		seq_printf(seq, " Device address:\t%s\n", addr_string.c);
 	}
-	p += sprintf(p, " Firmware version:\t%s", !working ? "Unknown" :
+	seq_printf(seq, " Firmware version:\t%s", !working ? "Unknown" :
 		     !firmware_level ? "Should be upgraded" :
 		     firmware_version.c);
 	if (firmware_level >= ChecksummedMessages)
-		p += sprintf(p, " (Checksums Enabled)");
-	p += sprintf(p, "\n");
-	p += sprintf(p, " Serial number:\t\t%s\n", serial_number.c);
-	p += sprintf(p, " Battery voltage:\t%s\n", battery_voltage.c);
-	p += sprintf(p, " Transmit queue (bytes):%d\n", tx_left);
-	p += sprintf(p, " Receive packet rate:   %ld packets per second\n",
+		seq_printf(seq, " (Checksums Enabled)");
+	seq_printf(seq, "\n");
+	seq_printf(seq, " Serial number:\t\t%s\n", serial_number.c);
+	seq_printf(seq, " Battery voltage:\t%s\n", battery_voltage.c);
+	seq_printf(seq, " Transmit queue (bytes):%d\n", tx_left);
+	seq_printf(seq, " Receive packet rate:   %ld packets per second\n",
 		     rx_average_pps / 8);
-	p += sprintf(p, " Transmit packet rate:  %ld packets per second\n",
+	seq_printf(seq, " Transmit packet rate:  %ld packets per second\n",
 		     tx_average_pps / 8);
-	p += sprintf(p, " Sent packet rate:      %ld packets per second\n",
+	seq_printf(seq, " Sent packet rate:      %ld packets per second\n",
 		     sx_average_pps / 8);
-	p += sprintf(p, " Next watchdog probe:\t%s\n",
+	seq_printf(seq, " Next watchdog probe:\t%s\n",
 		     time_delta(temp, watchdog_doprobe));
-	p += sprintf(p, " Next watchdog reset:\t%s\n",
+	seq_printf(seq, " Next watchdog reset:\t%s\n",
 		     time_delta(temp, watchdog_doreset));
-	p += sprintf(p, " Next gratuitous ARP:\t");
+	seq_printf(seq, " Next gratuitous ARP:\t");
 
 	if (!memcmp
 	    (strip_info->dev->dev_addr, zero_address.c,
 	     sizeof(zero_address)))
-		p += sprintf(p, "Disabled\n");
+		seq_printf(seq, "Disabled\n");
 	else {
-		p += sprintf(p, "%s\n", time_delta(temp, gratuitous_arp));
-		p += sprintf(p, " Next ARP interval:\t%ld seconds\n",
+		seq_printf(seq, "%s\n", time_delta(temp, gratuitous_arp));
+		seq_printf(seq, " Next ARP interval:\t%ld seconds\n",
 			     JIFFIE_TO_SEC(arp_interval));
 	}
 
 	if (working) {
 #ifdef EXT_COUNTERS
-		p += sprintf(p, "\n");
-		p += sprintf(p,
+		seq_printf(seq, "\n");
+		seq_printf(seq,
 			     " Total bytes:         \trx:\t%lu\ttx:\t%lu\n",
 			     rx_bytes, tx_bytes);
-		p += sprintf(p,
+		seq_printf(seq,
 			     "  thru radio:         \trx:\t%lu\ttx:\t%lu\n",
 			     rx_rbytes, tx_rbytes);
-		p += sprintf(p,
+		seq_printf(seq,
 			     "  thru serial port:   \trx:\t%lu\ttx:\t%lu\n",
 			     rx_sbytes, tx_sbytes);
-		p += sprintf(p,
+		seq_printf(seq,
 			     " Total stat/err bytes:\trx:\t%lu\ttx:\t%lu\n",
 			     rx_ebytes, tx_ebytes);
 #endif
-		p += sprintf_neighbours(p, &strip_info->poletops,
+		strip_seq_neighbours(seq, &strip_info->poletops,
 					"Poletops:");
-		p += sprintf_neighbours(p, &strip_info->portables,
+		strip_seq_neighbours(seq, &strip_info->portables,
 					"Portables:");
 	}
-
-	return p - buffer;
 }
 
 /*
  * This function is exports status information from the STRIP driver through
  * the /proc file system.
  */
+static int strip_seq_show(struct seq_file *seq, void *v)
+{
+	if (v == STRIP_PROC_HEADER)
+		seq_printf(seq, "strip_version: %s\n", StripVersion);
+	else
+		strip_seq_status_info(seq, (const struct strip *)v);
+	return 0;
+}
 
-static int get_status_info(char *buffer, char **start, off_t req_offset,
-			   int req_len)
+
+static struct seq_operations strip_seq_ops = {
+	.start = strip_seq_start,
+	.next  = strip_seq_next,
+	.stop  = strip_seq_stop,
+	.show  = strip_seq_show,
+};
+
+static int strip_seq_open(struct inode *inode, struct file *file)
 {
-	int total = 0, slop = 0;
-	struct strip *strip_info = struct_strip_list;
-	char *buf = buffer;
-
-	buf += sprintf(buf, "strip_version: %s\n", StripVersion);
-	if (shift_buffer(buffer, req_offset, req_len, &total, &slop, &buf))
-		goto exit;
-
-	while (strip_info != NULL) {
-		buf += sprintf_status_info(buf, strip_info);
-		if (shift_buffer
-		    (buffer, req_offset, req_len, &total, &slop, &buf))
-			break;
-		strip_info = strip_info->next;
-	}
-      exit:
-	return (calc_start_len
-		(buffer, start, req_offset, req_len, total, buf));
+	return seq_open(file, &strip_seq_ops);
 }
 
+static struct file_operations strip_seq_fops = {
+	.owner	 = THIS_MODULE,
+	.open    = strip_seq_open,
+	.read    = seq_read,
+	.llseek  = seq_lseek,
+	.release = seq_release,
+};
+
+
+
 /************************************************************************/
 /* Sending routines							*/
 
@@ -1578,7 +1562,6 @@
 static int strip_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct strip *strip_info = (struct strip *) (dev->priv);
-	unsigned long flags;
 
 	if (!netif_running(dev)) {
 		printk(KERN_ERR "%s: xmit call when iface is down\n",
@@ -1617,14 +1600,11 @@
 			       strip_info->dev->name, sx_pps_count / 8);
 	}
 
-	spin_lock_irqsave(&strip_lock, flags);
-	/* See if someone has been ifconfigging */
-	if (strip_info->mtu != strip_info->dev->mtu)
-		strip_changedmtu(strip_info);
+	spin_lock_bh(&strip_lock);
 
 	strip_send(strip_info, skb);
 
-	spin_unlock_irqrestore(&strip_lock, flags);
+	spin_unlock_bh(&strip_lock);
 
 	if (skb)
 		dev_kfree_skb(skb);
@@ -2317,18 +2297,12 @@
 {
 	struct strip *strip_info = (struct strip *) tty->disc_data;
 	const unsigned char *end = cp + count;
-	unsigned long flags;
 
 	if (!strip_info || strip_info->magic != STRIP_MAGIC
 	    || !netif_running(strip_info->dev))
 		return;
 
-	spin_lock_irqsave(&strip_lock, flags);
-
-	/* Argh! mtu change time! - costs us the packet part received at the change */
-	if (strip_info->mtu != strip_info->dev->mtu)
-		strip_changedmtu(strip_info);
-
+	spin_lock_bh(&strip_lock);
 #if 0
 	{
 		struct timeval tv;
@@ -2395,7 +2369,7 @@
 		}
 		cp++;
 	}
-	spin_unlock_irqrestore(&strip_lock, flags);
+	spin_unlock_bh(&strip_lock);
 }
 
 
@@ -2483,7 +2457,7 @@
 	if (strip_info->tty == NULL)
 		return (-ENODEV);
 
-	if (!allocate_buffers(strip_info))
+	if (!allocate_buffers(strip_info, dev->mtu))
 		return (-ENOMEM);
 
 	strip_info->sx_count = 0;
@@ -2543,12 +2517,14 @@
  * (dynamically assigned) device is registered
  */
 
-static int strip_dev_init(struct net_device *dev)
+static void strip_dev_setup(struct net_device *dev)
 {
 	/*
 	 * Finish setting up the DEVICE info.
 	 */
 
+	SET_MODULE_OWNER(dev);
+
 	dev->trans_start = 0;
 	dev->last_rx = 0;
 	dev->tx_queue_len = 30;	/* Drop after 30 frames queued */
@@ -2576,7 +2552,7 @@
 	dev->rebuild_header = strip_rebuild_header;
 	dev->set_mac_address = dev_set_mac_address;
 	dev->get_stats = strip_get_stats;
-	return 0;
+	dev->change_mtu = strip_change_mtu;
 }
 
 /*
@@ -2585,65 +2561,34 @@
 
 static void strip_free(struct strip *strip_info)
 {
-	*(strip_info->referrer) = strip_info->next;
-	if (strip_info->next)
-		strip_info->next->referrer = strip_info->referrer;
+	spin_lock_bh(&strip_lock);
+	list_del_rcu(&strip_info->list);
+	spin_unlock_bh(&strip_lock);
+
 	strip_info->magic = 0;
-	if (strip_info->dev)
-		kfree(strip_info->dev);
-	kfree(strip_info);
+
+	kfree(strip_info->dev);
 }
 
+
 /*
  * Allocate a new free STRIP channel
  */
-
 static struct strip *strip_alloc(void)
 {
-	int channel_id = 0;
-	struct strip **s = &struct_strip_list;
+	struct list_head *n;
 	struct net_device *dev;
-	struct strip *strip_info = (struct strip *)
-	    kmalloc(sizeof(struct strip), GFP_KERNEL);
+	struct strip *strip_info;
 
-	if (!strip_info)
-		return NULL;	/* If no more memory, return */
+	dev = alloc_netdev(sizeof(struct strip), "st%d",
+			   strip_dev_setup);
 
-	/*
-	 * Clear the allocated memory
-	 */
+	if (!dev)
+		return NULL;	/* If no more memory, return */
 
-	memset(strip_info, 0, sizeof(struct strip));
 
-	/* allocate the net_device */
-	dev = kmalloc(sizeof(struct net_device), GFP_KERNEL);
-	if (!dev) {
-		kfree(strip_info);
-		return NULL;
-	}
+	strip_info = dev->priv;
 	strip_info->dev = dev;
-	SET_MODULE_OWNER(dev);
-
-	/*
-	 * Search the list to find where to put our new entry
-	 * (and in the process decide what channel number it is
-	 * going to be)
-	 */
-
-	while (*s && (*s)->dev->base_addr == channel_id) {
-		channel_id++;
-		s = &(*s)->next;
-	}
-
-	/*
-	 * Fill in the link pointers
-	 */
-
-	strip_info->next = *s;
-	if (*s)
-		(*s)->referrer = &strip_info->next;
-	strip_info->referrer = s;
-	*s = strip_info;
 
 	strip_info->magic = STRIP_MAGIC;
 	strip_info->tty = NULL;
@@ -2654,12 +2599,27 @@
 	strip_info->idle_timer.data = (long) dev;
 	strip_info->idle_timer.function = strip_IdleTask;
 
-	/* Note: strip_info->if_name is currently 8 characters long */
-	sprintf(dev->name, "st%d", channel_id);
-	dev->base_addr = channel_id;
-	dev->priv = (void *) strip_info;
-	dev->next = NULL;
-	dev->init = strip_dev_init;
+
+	spin_lock_bh(&strip_lock);
+ rescan:
+	/*
+	 * Search the list to find where to put our new entry
+	 * (and in the process decide what channel number it is
+	 * going to be)
+	 */
+	list_for_each(n, &strip_list) {
+		struct strip *s = hlist_entry(n, struct strip, list);
+
+		if (s->dev->base_addr == dev->base_addr) {
+			++dev->base_addr;
+			goto rescan;
+		}
+	}
+
+	sprintf(dev->name, "st%ld", dev->base_addr);
+
+	list_add_tail_rcu(&strip_info->list, &strip_list);
+	spin_unlock_bh(&strip_lock);
 
 	return strip_info;
 }
@@ -2809,6 +2769,7 @@
 static struct tty_ldisc strip_ldisc = {
 	.magic = TTY_LDISC_MAGIC,
 	.name = "strip",
+	.owner = THIS_MODULE,
 	.open = strip_open,
 	.close = strip_close,
 	.ioctl = strip_ioctl,
@@ -2832,7 +2793,6 @@
 
 	printk(signon, StripVersion);
 
-	spin_lock_init(&strip_lock);
 	
 	/*
 	 * Fill in our line protocol discipline, and register it
@@ -2844,7 +2804,7 @@
 	/*
 	 * Register the status file with /proc
 	 */
-	proc_net_create("strip", S_IFREG | S_IRUGO, get_status_info);
+	proc_net_fops_create("strip", S_IFREG | S_IRUGO, &strip_seq_fops);
 
 	return status;
 }
@@ -2857,8 +2817,13 @@
 static void __exit strip_exit_driver(void)
 {
 	int i;
-	while (struct_strip_list)
-		strip_free(struct_strip_list);
+	struct list_head *p,*n;
+
+	/* module ref count rules assure that all entries are unregistered */
+	list_for_each_safe(p, n, &strip_list) {
+		struct strip *s = list_entry(p, struct strip, list);
+		strip_free(s);
+	}
 
 	/* Unregister with the /proc/net file here. */
 	proc_net_remove("strip");
