From: Stephen Hemminger <shemminger@osdl.org>
Subject: [RFT][PATCH] convert 802/tr to seq_file
Date: Tue, 19 Aug 2003 14:13:26 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030819141326.2a63bad0.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-tr@linuxtr.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Mike Phillips <mikep@linuxtr.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Convert the /proc interface to tokenring routing information
to the new seq_file interface.

Builds and loads on 2.6.0-test3, but I don't have any real tokenring hardware
to make entries show up in table.

diff -Nru a/net/802/tr.c b/net/802/tr.c
--- a/net/802/tr.c	Tue Aug 19 14:07:56 2003
+++ b/net/802/tr.c	Tue Aug 19 14:07:56 2003
@@ -33,6 +33,7 @@
 #include <linux/timer.h>
 #include <linux/net.h>
 #include <linux/proc_fs.h>
+#include <linux/seq_file.h>
 #include <linux/init.h>
 #include <net/arp.h>
 
@@ -456,84 +457,108 @@
  *	routing.
  */
  
-#ifndef CONFIG_PROC_FS
-static int rif_get_info(char *buffer,char **start, off_t offset, int length)  { return 0;}
-#else
-static int rif_get_info(char *buffer,char **start, off_t offset, int length) 
-{
-	int len=0;
-	off_t begin=0;
-	off_t pos=0;
-	int size,i,j,rcf_len,segment,brdgnmb;
-	unsigned long now=jiffies;
+#ifdef CONFIG_PROC_FS
+/* Magic token to indicate first entry (header line) */
+#define RIF_PROC_START	((void *)1)
+
+static struct rif_cache_s *rif_get_idx(loff_t pos)
+{
+	int i;
+	struct rif_cache_s *entry;
+	loff_t off = 0;
+
+	for(i=0;i < RIF_TABLE_SIZE;i++) 
+		for(entry=rif_table[i];entry;entry=entry->next) {
+			if (off == pos)
+				return entry;
+			++off;
+		}
+
+	return NULL;
+}
+
+static void *rif_seq_start(struct seq_file *seq, loff_t *pos)
+{
 	unsigned long flags;
 
-	rif_cache entry;
+	spin_lock_irqsave(&rif_lock, flags);
+	seq->private = (void *) flags;
+
+	return *pos ? rif_get_idx(*pos - 1) : RIF_PROC_START;
+}
+
+static void *rif_seq_next(struct seq_file *seq, void *v, loff_t *pos)
+{
+	return rif_get_idx(*pos++);
+}
+
+static void rif_seq_stop(struct seq_file *seq, void *v)
+{
+	unsigned long flags = (unsigned long) seq->private;
+	spin_lock_irqsave(&rif_lock, flags);
+}
 
-	size=sprintf(buffer,
+static int rif_seq_show(struct seq_file *seq, void *v)
+{
+	int j, rcf_len, segment, brdgnmb;
+	rif_cache entry = v;
+
+	if (v == RIF_PROC_START)
+		seq_puts(seq,
 		     "if     TR address       TTL   rcf   routing segments\n");
-	pos+=size;
-	len+=size;
+	else {
+		struct net_device *dev = dev_get_by_index(entry->iface);
 
-	spin_lock_irqsave(&rif_lock,flags);
-	for(i=0;i < RIF_TABLE_SIZE;i++) 
-	{
-		for(entry=rif_table[i];entry;entry=entry->next) {
-			struct net_device *dev = __dev_get_by_index(entry->iface);
+		seq_printf(seq, "%s %02X:%02X:%02X:%02X:%02X:%02X %7li ",
+			   dev?dev->name:"?",
+			   entry->addr[0],entry->addr[1],entry->addr[2],
+			   entry->addr[3],entry->addr[4],entry->addr[5],
+			   sysctl_tr_rif_timeout-(jiffies-entry->last_used));
 
-			size=sprintf(buffer+len,"%s %02X:%02X:%02X:%02X:%02X:%02X %7li ",
-				     dev?dev->name:"?",entry->addr[0],entry->addr[1],entry->addr[2],entry->addr[3],entry->addr[4],entry->addr[5],
-				     sysctl_tr_rif_timeout-(now-entry->last_used));
-			len+=size;
-			pos=begin+len;
 			if (entry->local_ring)
-			        size=sprintf(buffer+len,"local\n");
+			        seq_puts(seq, "local\n");
 			else {
-			        size=sprintf(buffer+len,"%04X", ntohs(entry->rcf));
+
+				seq_printf(seq, "%04X", ntohs(entry->rcf));
 				rcf_len = ((ntohs(entry->rcf) & TR_RCF_LEN_MASK)>>8)-2; 
 				if (rcf_len)
 				        rcf_len >>= 1;
 				for(j = 1; j < rcf_len; j++) {
 					if(j==1) {
 						segment=ntohs(entry->rseg[j-1])>>4;
-						len+=size;
-						pos=begin+len;
-						size=sprintf(buffer+len,"  %03X",segment);
+						seq_printf(seq,"  %03X",segment);
 					};
 					segment=ntohs(entry->rseg[j])>>4;
 					brdgnmb=ntohs(entry->rseg[j-1])&0x00f;
-					len+=size;
-					pos=begin+len;
-					size=sprintf(buffer+len,"-%01X-%03X",brdgnmb,segment);
+					seq_printf(seq,"-%01X-%03X",brdgnmb,segment);
 				}
-				len+=size;
-				pos=begin+len;
-			        size=sprintf(buffer+len,"\n");
-			}
-			len+=size;
-			pos=begin+len;
-
-			if(pos<offset) 
-			{
-				len=0;
-				begin=pos;
+				seq_putc(seq, '\n');
 			}
-			if(pos>offset+length)
-				break;
 	   	}
-		if(pos>offset+length)
-			break;
-	}
-	spin_unlock_irqrestore(&rif_lock,flags);
+	return 0;
+}
+
+
+static struct seq_operations rif_seq_ops = {
+	.start = rif_seq_start,
+	.next  = rif_seq_next,
+	.stop  = rif_seq_stop,
+	.show  = rif_seq_show,
+};
 
-	*start=buffer+(offset-begin); /* Start of wanted data */
-	len-=(offset-begin);    /* Start slop */
-	if(len>length)
-		len=length;    /* Ending slop */
-	if (len<0)
-		len=0;
-	return len;
+static int rif_seq_open(struct inode *inode, struct file *file)
+{
+	return seq_open(file, &rif_seq_ops);
 }
+
+static struct file_operations rif_seq_fops = {
+	.owner	 = THIS_MODULE,
+	.open    = rif_seq_open,
+	.read    = seq_read,
+	.llseek  = seq_lseek,
+	.release = seq_release,
+};
+
 #endif
 
 /*
@@ -549,7 +574,7 @@
 	rif_timer.function = rif_check_expire;
 	add_timer(&rif_timer);
 
-	proc_net_create("tr_rif",0,rif_get_info);
+	proc_net_fops_create("tr_rif", S_IRUGO, &rif_seq_fops);
 	return 0;
 }
 
