From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] convert VLAN to use seq_file for /proc
Date: Mon, 28 Jul 2003 15:30:24 -0700
Sender: vlan-bounces@wanfear.com
Message-ID: <20030728153024.6b1d7cde.shemminger@osdl.org>
Reply-To: "Linux 802.1Q VLAN" <vlan@wanfear.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <vlan-bounces@wanfear.com>
To: Ben Greear <greearb@candelatech.com>,
   "David S. Miller"
	<davem@redhat.com>,
   "Linux 802.1Q VLAN" <vlan@wanfear.com>, netdev@oss.sgi.com
List-Unsubscribe: <http://www.WANfear.com/mailman/listinfo/vlan>,
	<mailto:vlan-request@wanfear.com?subject=unsubscribe>
List-Archive: <http://ns1.wanfear.com/pipermail/vlan>
List-Post: <mailto:vlan@wanfear.com>
List-Help: <mailto:vlan-request@wanfear.com?subject=help>
List-Subscribe: <http://www.WANfear.com/mailman/listinfo/vlan>,
	<mailto:vlan-request@wanfear.com?subject=subscribe>
Errors-To: vlan-bounces@wanfear.com
List-Id: netdev.vger.kernel.org

Use seq_file interface for smaller, simpler, safer code in /proc.
Output format is the same.

Patch for 2.6.0-test2 with earlier proc patches

diff -Nru a/net/8021q/vlanproc.c b/net/8021q/vlanproc.c
--- a/net/8021q/vlanproc.c	Mon Jul 28 15:28:36 2003
+++ b/net/8021q/vlanproc.c	Mon Jul 28 15:28:36 2003
@@ -30,6 +30,7 @@
 #include <asm/uaccess.h>	/* copy_to_user */
 #include <asm/io.h>
 #include <linux/proc_fs.h>
+#include <linux/seq_file.h>
 #include <linux/fs.h>
 #include <linux/netdevice.h>
 #include <linux/if_vlan.h>
@@ -38,28 +39,28 @@
 
 /****** Function Prototypes *************************************************/
 
-/* Proc filesystem interface */
-static ssize_t vlan_proc_read(struct file *file, char *buf, size_t count,
-                              loff_t *ppos);
-
 /* Methods for preparing data for reading proc entries */
-
-static int vlan_config_get_info(char *buf, char **start, off_t offs, int len);
-static int vlandev_get_info(char *buf, char **start, off_t offs, int len);
+static int vlan_seq_show(struct seq_file *seq, void *v);
+static void *vlan_seq_start(struct seq_file *seq, loff_t *pos);
+static void *vlan_seq_next(struct seq_file *seq, void *v, loff_t *pos);
+static void vlan_seq_stop(struct seq_file *seq, void *);
+static int vlandev_seq_show(struct seq_file *seq, void *v);
 
 /* Miscellaneous */
+#define SEQ_START_TOKEN		((void *) 1)
+
 
 /*
  *	Global Data
  */
 
+
 /*
  *	Names of the proc directory entries 
  */
 
-static char name_root[]	 = "vlan";
-static char name_conf[]	 = "config";
-static char term_msg[]   = "***KERNEL:  Out of buffer space!***\n";
+static const char name_root[]	 = "vlan";
+static const char name_conf[]	 = "config";
 
 /*
  *	Structures for interfacing with the /proc filesystem.
@@ -73,20 +74,41 @@
  *	Generic /proc/net/vlan/<file> file and inode operations 
  */
 
+static struct seq_operations vlan_seq_ops = {
+	.start = vlan_seq_start,
+	.next = vlan_seq_next,
+	.stop = vlan_seq_stop,
+	.show = vlan_seq_show,
+};
+
+static int vlan_seq_open(struct inode *inode, struct file *file)
+{
+	return seq_open(file, &vlan_seq_ops);
+}
+
 static struct file_operations vlan_fops = {
-	.owner = THIS_MODULE,
-	.read =	vlan_proc_read,
-	.ioctl = NULL, /* vlan_proc_ioctl */
+	.owner	 = THIS_MODULE,
+	.open    = vlan_seq_open,
+	.read    = seq_read,
+	.llseek  = seq_lseek,
+	.release = seq_release,
 };
 
 /*
  *	/proc/net/vlan/<device> file and inode operations
  */
 
+static int vlandev_seq_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, vlandev_seq_show, PDE(inode)->data);
+}
+
 static struct file_operations vlandev_fops = {
 	.owner = THIS_MODULE,
-	.read =	vlan_proc_read,
-	.ioctl =NULL, /* vlan_proc_ioctl */
+	.open    = vlandev_seq_open,
+	.read    = seq_read,
+	.llseek  = seq_lseek,
+	.release = single_release,
 };
 
 /*
@@ -106,8 +128,12 @@
 static struct proc_dir_entry *proc_vlan_conf;
 
 /* Strings */
-static char conf_hdr[] = "VLAN Dev name	 | VLAN ID\n";
-
+static const char *vlan_name_type_str[VLAN_NAME_TYPE_HIGHEST] = {
+    [VLAN_NAME_TYPE_RAW_PLUS_VID]       = "VLAN_NAME_TYPE_RAW_PLUS_VID",
+    [VLAN_NAME_TYPE_PLUS_VID_NO_PAD]	= "VLAN_NAME_TYPE_PLUS_VID_NO_PAD",
+    [VLAN_NAME_TYPE_RAW_PLUS_VID_NO_PAD]= "VLAN_NAME_TYPE_RAW_PLUS_VID_NO_PAD",
+    [VLAN_NAME_TYPE_PLUS_VID]		= "VLAN_NAME_TYPE_PLUS_VID",
+};
 /*
  *	Interface functions
  */
@@ -142,7 +168,6 @@
 						   proc_vlan_dir);
 		if (proc_vlan_conf) {
 			proc_vlan_conf->proc_fops = &vlan_fops;
-			proc_vlan_conf->get_info = vlan_config_get_info;
 			return 0;
 		}
 	}
@@ -172,7 +197,6 @@
 		return -ENOBUFS;
 
 	dev_info->dent->proc_fops = &vlandev_fops;
-	dev_info->dent->get_info = &vlandev_get_info;
 	dev_info->dent->data = vlandev;
 
 #ifdef VLAN_DEBUG
@@ -187,6 +211,7 @@
  */
 void vlan_proc_rem_dev(struct net_device *vlandev)
 {
+
 #ifdef VLAN_DEBUG
 	printk(VLAN_DBG __FUNCTION__ ": dev: %p\n", vlandev);
 #endif
@@ -201,185 +226,103 @@
 /****** Proc filesystem entry points ****************************************/
 
 /*
- *	Read VLAN proc directory entry.
- *	This is universal routine for reading all entries in /proc/net/vlan
- *	directory.  Each directory entry contains a pointer to the 'method' for
- *	preparing data for that entry.
- *	o verify arguments
- *	o allocate kernel buffer
- *	o call get_info() to prepare data
- *	o copy data to user space
- *	o release kernel buffer
- *
- *	Return:	number of bytes copied to user space (0, if no data)
- *		<0	error
- */
-static ssize_t vlan_proc_read(struct file *file, char *buf,
-			      size_t count, loff_t *ppos)
-{
-	struct inode *inode = file->f_dentry->d_inode;
-	struct proc_dir_entry *dent;
-	char *page;
-	int pos, offs, len;
+ * The following few functions build the content of /proc/net/vlan/config
+ */
 
-	if (count <= 0)
-		return 0;
+/* starting at dev, find a VLAN device */
+struct net_device *vlan_skip(struct net_device *dev) 
+{
+	while (dev && !(dev->priv_flags & IFF_802_1Q_VLAN)) 
+		dev = dev->next;
 
-	dent = PDE(inode);
-	if ((dent == NULL) || (dent->get_info == NULL))
-		return 0;
+	return dev;
+}
 
-	page = kmalloc(VLAN_PROC_BUFSZ, GFP_KERNEL);
-	VLAN_MEM_DBG("page malloc, addr: %p  size: %i\n",
-		     page, VLAN_PROC_BUFSZ);
+/* start read of /proc/net/vlan/config */ 
+static void *vlan_seq_start(struct seq_file *seq, loff_t *pos)
+{
+	struct net_device *dev;
+	loff_t i = 1;
 
-	if (page == NULL)
-		return -ENOBUFS;
+	read_lock(&dev_base_lock);
 
-	pos = dent->get_info(page, dent->data, 0, 0);
-	offs = file->f_pos;
-	if (offs < pos) {
-		len = min_t(int, pos - offs, count);
-		if (copy_to_user(buf, (page + offs), len)) {
-			kfree(page);
-			return -EFAULT;
-		}
+	if (*pos == 0)
+		return SEQ_START_TOKEN;
+	
+	for (dev = vlan_skip(dev_base); dev && i < *pos; 
+	     dev = vlan_skip(dev->next), ++i);
+		
+	return  (i == *pos) ? dev : NULL;
+} 
 
-		file->f_pos += len;
-	} else {
-		len = 0;
-	}
+static void *vlan_seq_next(struct seq_file *seq, void *v, loff_t *pos)
+{
+	++*pos;
 
-	kfree(page);
-	VLAN_FMEM_DBG("page free, addr: %p\n", page);
-	return len;
+	return vlan_skip((v == SEQ_START_TOKEN)  
+			    ? dev_base 
+			    : ((struct net_device *)v)->next);
 }
 
-/*
- * The following few functions build the content of /proc/net/vlan/config
- */
+static void vlan_seq_stop(struct seq_file *seq, void *v)
+{
+	read_unlock(&dev_base_lock);
+}
 
-static int vlan_proc_get_vlan_info(char* buf, unsigned int cnt)
+static int vlan_seq_show(struct seq_file *seq, void *v)
 {
-	struct net_device *vlandev = NULL;
-	struct vlan_group *grp = NULL;
-	int h, i;
-	char *nm_type = NULL;
-	struct vlan_dev_info *dev_info = NULL;
+	if (v == SEQ_START_TOKEN) {
+		const char *nmtype = NULL;
 
-#ifdef VLAN_DEBUG
-	printk(VLAN_DBG __FUNCTION__ ": cnt == %i\n", cnt);
-#endif
+		seq_puts(seq, "VLAN Dev name	 | VLAN ID\n");
 
-	if (vlan_name_type == VLAN_NAME_TYPE_RAW_PLUS_VID) {
-		nm_type = "VLAN_NAME_TYPE_RAW_PLUS_VID";
-	} else if (vlan_name_type == VLAN_NAME_TYPE_PLUS_VID_NO_PAD) {
-		nm_type = "VLAN_NAME_TYPE_PLUS_VID_NO_PAD";
-	} else if (vlan_name_type == VLAN_NAME_TYPE_RAW_PLUS_VID_NO_PAD) {
-		nm_type = "VLAN_NAME_TYPE_RAW_PLUS_VID_NO_PAD";
-	} else if (vlan_name_type == VLAN_NAME_TYPE_PLUS_VID) {
-		nm_type = "VLAN_NAME_TYPE_PLUS_VID";
-	} else {
-		nm_type = "UNKNOWN";
-	}
+		if (vlan_name_type < ARRAY_SIZE(vlan_name_type_str))
+		    nmtype =  vlan_name_type_str[vlan_name_type];
 
-	cnt += sprintf(buf + cnt, "Name-Type: %s\n", nm_type);
+		seq_printf(seq, "Name-Type: %s\n", 
+			   nmtype ? nmtype :  "UNKNOWN" );
+	} else {
+		const struct net_device *vlandev = v;
+		const struct vlan_dev_info *dev_info = VLAN_DEV_INFO(vlandev);
 
-	spin_lock_bh(&vlan_group_lock);
-	for (h = 0; h < VLAN_GRP_HASH_SIZE; h++) {
-		for (grp = vlan_group_hash[h]; grp != NULL; grp = grp->next) {
-			for (i = 0; i < VLAN_GROUP_ARRAY_LEN; i++) {
-				vlandev = grp->vlan_devices[i];
-				if (!vlandev)
-					continue;
-
-				if ((cnt + 100) > VLAN_PROC_BUFSZ) {
-					if ((cnt+strlen(term_msg)) < VLAN_PROC_BUFSZ)
-						cnt += sprintf(buf+cnt, "%s", term_msg);
-
-					goto out;
-				}
-
-				dev_info = VLAN_DEV_INFO(vlandev);
-				cnt += sprintf(buf + cnt, "%-15s| %d  | %s\n",
-					       vlandev->name,
-					       dev_info->vlan_id,
-					       dev_info->real_dev->name);
-			}
-		}
+		seq_printf(seq, "%-15s| %d  | %s\n",  vlandev->name,  
+			   dev_info->vlan_id,    dev_info->real_dev->name);
 	}
-out:
-	spin_unlock_bh(&vlan_group_lock);
-
-	return cnt;
+	return 0;
 }
 
-/*
- *	Prepare data for reading 'Config' entry.
- *	Return length of data.
- */
-
-static int vlan_config_get_info(char *buf, char **start,
-				off_t offs, int len)
+static int vlandev_seq_show(struct seq_file *seq, void *offset)
 {
-	strcpy(buf, conf_hdr);
-	return vlan_proc_get_vlan_info(buf, (unsigned int)(strlen(conf_hdr)));
-}
-
-/*
- *	Prepare data for reading <device> entry.
- *	Return length of data.
- *
- *	On entry, the 'start' argument will contain a pointer to VLAN device
- *	data space.
- */
-
-static int vlandev_get_info(char *buf, char **start,
-			    off_t offs, int len)
-{
-	struct net_device *vlandev = (void *) start;
-	struct net_device_stats *stats = NULL;
-	struct vlan_dev_info *dev_info = NULL;
-	struct vlan_priority_tci_mapping *mp;
-	int cnt = 0;
+	struct net_device *vlandev = (struct net_device *) seq->private;
+	const struct vlan_dev_info *dev_info = VLAN_DEV_INFO(vlandev);
+	struct net_device_stats *stats;
+	static const char *fmt = "%30s %12lu\n";
 	int i;
 
 	if ((vlandev == NULL) || (!(vlandev->priv_flags & IFF_802_1Q_VLAN)))
 		return 0;
 
-	dev_info = VLAN_DEV_INFO(vlandev);
-
-	cnt += sprintf(buf + cnt, "%s  VID: %d	 REORDER_HDR: %i  dev->priv_flags: %hx\n",
+	seq_printf(seq, "%s  VID: %d	 REORDER_HDR: %i  dev->priv_flags: %hx\n",
 		       vlandev->name, dev_info->vlan_id,
 		       (int)(dev_info->flags & 1), vlandev->priv_flags);
 
-	stats = vlan_dev_get_stats(vlandev);
-
-	cnt += sprintf(buf + cnt, "%30s: %12lu\n",
-		       "total frames received", stats->rx_packets);
-
-	cnt += sprintf(buf + cnt, "%30s: %12lu\n",
-		       "total bytes received", stats->rx_bytes);
-
-	cnt += sprintf(buf + cnt, "%30s: %12lu\n",
-		       "Broadcast/Multicast Rcvd", stats->multicast);
-
-	cnt += sprintf(buf + cnt, "\n%30s: %12lu\n",
-		       "total frames transmitted", stats->tx_packets);
-
-	cnt += sprintf(buf + cnt, "%30s: %12lu\n",
-		       "total bytes transmitted", stats->tx_bytes);
-
-	cnt += sprintf(buf + cnt, "%30s: %12lu\n",
-		       "total headroom inc", dev_info->cnt_inc_headroom_on_tx);
-
-	cnt += sprintf(buf + cnt, "%30s: %12lu\n",
-		       "total encap on xmit", dev_info->cnt_encap_on_xmit);
 
-	cnt += sprintf(buf + cnt, "Device: %s", dev_info->real_dev->name);
+	stats = vlan_dev_get_stats(vlandev);
 
+	seq_printf(seq, fmt, "total frames received", stats->rx_packets);
+	seq_printf(seq, fmt, "total bytes received", stats->rx_bytes);
+	seq_printf(seq, fmt, "Broadcast/Multicast Rcvd", stats->multicast);
+	seq_puts(seq, "\n");
+	seq_printf(seq, fmt, "total frames transmitted", stats->tx_packets);
+	seq_printf(seq, fmt, "total bytes transmitted", stats->tx_bytes);
+	seq_printf(seq, fmt, "total headroom inc", 
+		   dev_info->cnt_inc_headroom_on_tx);
+	seq_printf(seq, fmt, "total encap on xmit", 
+		   dev_info->cnt_encap_on_xmit);
+	seq_printf(seq, "Device: %s", dev_info->real_dev->name);
 	/* now show all PRIORITY mappings relating to this VLAN */
-	cnt += sprintf(buf + cnt, "\nINGRESS priority mappings: 0:%lu  1:%lu  2:%lu  3:%lu  4:%lu  5:%lu  6:%lu 7:%lu\n",
+	seq_printf(seq, 
+		       "\nINGRESS priority mappings: 0:%lu  1:%lu  2:%lu  3:%lu  4:%lu  5:%lu  6:%lu 7:%lu\n",
 		       dev_info->ingress_priority_map[0],
 		       dev_info->ingress_priority_map[1],
 		       dev_info->ingress_priority_map[2],
@@ -389,38 +332,17 @@
 		       dev_info->ingress_priority_map[6],
 		       dev_info->ingress_priority_map[7]);
 
-	if ((cnt + 100) > VLAN_PROC_BUFSZ) {
-		if ((cnt + strlen(term_msg)) >= VLAN_PROC_BUFSZ) {
-			/* should never get here */
-			return cnt;
-		} else {
-			cnt += sprintf(buf + cnt, "%s", term_msg);
-			return cnt;
-		}
-	}
-
-	cnt += sprintf(buf + cnt, "EGRESSS priority Mappings: ");
-
+	seq_printf(seq, "EGRESSS priority Mappings: ");
 	for (i = 0; i < 16; i++) {
-		mp = dev_info->egress_priority_map[i];
+		const struct vlan_priority_tci_mapping *mp
+			= dev_info->egress_priority_map[i];
 		while (mp) {
-			cnt += sprintf(buf + cnt, "%lu:%hu ",
-				       mp->priority, ((mp->vlan_qos >> 13) & 0x7));
-
-			if ((cnt + 100) > VLAN_PROC_BUFSZ) {
-				if ((cnt + strlen(term_msg)) >= VLAN_PROC_BUFSZ) {
-					/* should never get here */
-					return cnt;
-				} else {
-					cnt += sprintf(buf + cnt, "%s", term_msg);
-					return cnt;
-				}
-			}
+			seq_printf(seq, "%lu:%hu ",
+				   mp->priority, ((mp->vlan_qos >> 13) & 0x7));
 			mp = mp->next;
 		}
 	}
+	seq_puts(seq, "\n");
 
-	cnt += sprintf(buf + cnt, "\n");
-
-	return cnt;
+	return 0;
 }
diff -Nru a/net/8021q/vlanproc.h b/net/8021q/vlanproc.h
--- a/net/8021q/vlanproc.h	Mon Jul 28 15:28:36 2003
+++ b/net/8021q/vlanproc.h	Mon Jul 28 15:28:36 2003
@@ -3,12 +3,9 @@
 
 #ifdef CONFIG_PROC_FS
 int vlan_proc_init(void);
-
 void vlan_proc_rem_dev(struct net_device *vlandev);
 int vlan_proc_add_dev (struct net_device *vlandev);
 void vlan_proc_cleanup (void);
-
-#define	VLAN_PROC_BUFSZ	(4096)	/* buffer size for printing proc info */
 
 #else /* No CONFIG_PROC_FS */
 


_______________________________________________
VLAN mailing list  -  VLAN@wanfear.com
http://www.WANfear.com/mailman/listinfo/vlan
VLAN Page:  http://scry.wanfear.com/~greear/vlan.html
