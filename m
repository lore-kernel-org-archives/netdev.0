From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] convert ipmr to seq_file.
Date: Thu, 25 Sep 2003 14:23:51 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030925142351.18cda5dd.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>,
        "YOSHIFUJI Hideaki / _$B5HF#1QL@" <yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Convert /proc/ip_mr_cache and /proc/ip_mr_vif to use seq_file.
Tested with 2.6.0-test5 latest.

--- linux-2.5/net/ipv4/ipmr.c	2003-09-05 09:36:05.000000000 -0700
+++ linux-2.5-net/net/ipv4/ipmr.c	2003-09-25 14:21:05.455075362 -0700
@@ -46,6 +46,7 @@
 #include <linux/inetdevice.h>
 #include <linux/igmp.h>
 #include <linux/proc_fs.h>
+#include <linux/seq_file.h>
 #include <linux/mroute.h>
 #include <linux/init.h>
 #include <net/ip.h>
@@ -1602,133 +1603,267 @@ int ipmr_get_route(struct sk_buff *skb, 
 /*
  *	The /proc interfaces to multicast routing /proc/ip_mr_cache /proc/ip_mr_vif
  */
- 
-static int ipmr_vif_info(char *buffer, char **start, off_t offset, int length)
-{
-	struct vif_device *vif;
-	int len=0;
-	off_t pos=0;
-	off_t begin=0;
-	int size;
+struct ipmr_vif_iter {
 	int ct;
+};
+
+static struct vif_device *ipmr_vif_seq_idx(struct ipmr_vif_iter *iter,
+					   loff_t pos)
+{
+	for (iter->ct = 0; iter->ct < maxvif; ++iter->ct) {
+		if(!VIF_EXISTS(iter->ct))
+			continue;
+		if (pos-- == 0) 
+			return &vif_table[iter->ct];
+	}
+	return NULL;
+}
 
-	len += sprintf(buffer,
-		 "Interface      BytesIn  PktsIn  BytesOut PktsOut Flags Local    Remote\n");
-	pos=len;
-  
+static void *ipmr_vif_seq_start(struct seq_file *seq, loff_t *pos)
+{
 	read_lock(&mrt_lock);
-	for (ct=0;ct<maxvif;ct++) 
-	{
-		char *name = "none";
-		vif=&vif_table[ct];
-		if(!VIF_EXISTS(ct))
+	return *pos ? ipmr_vif_seq_idx(seq->private, *pos - 1) 
+		: SEQ_START_TOKEN;
+}
+
+static void *ipmr_vif_seq_next(struct seq_file *seq, void *v, loff_t *pos)
+{
+	struct ipmr_vif_iter *iter = seq->private;
+
+	++*pos;
+	if (v == SEQ_START_TOKEN)
+		return ipmr_vif_seq_idx(iter, 0);
+	
+	while (++iter->ct < maxvif) {
+		if(!VIF_EXISTS(iter->ct))
 			continue;
-		if (vif->dev)
-			name = vif->dev->name;
-        	size = sprintf(buffer+len, "%2d %-10s %8ld %7ld  %8ld %7ld %05X %08X %08X\n",
-        		ct, name, vif->bytes_in, vif->pkt_in, vif->bytes_out, vif->pkt_out,
-        		vif->flags, vif->local, vif->remote);
-		len+=size;
-		pos+=size;
-		if(pos<offset)
-		{
-			len=0;
-			begin=pos;
-		}
-		if(pos>offset+length)
-			break;
-  	}
+		return &vif_table[iter->ct];
+	}
+	return NULL;
+}
+
+static void ipmr_vif_seq_stop(struct seq_file *seq, void *v)
+{
 	read_unlock(&mrt_lock);
-  	
-  	*start=buffer+(offset-begin);
-  	len-=(offset-begin);
-  	if(len>length)
-  		len=length;
-	if (len<0)
-		len = 0;
-  	return len;
 }
 
-static int ipmr_mfc_info(char *buffer, char **start, off_t offset, int length)
+static int ipmr_vif_seq_show(struct seq_file *seq, void *v)
 {
-	struct mfc_cache *mfc;
-	int len=0;
-	off_t pos=0;
-	off_t begin=0;
-	int size;
+	if (v == SEQ_START_TOKEN) {
+		seq_puts(seq, 
+			 "Interface      BytesIn  PktsIn  BytesOut PktsOut Flags Local    Remote\n");
+	} else {
+		const struct vif_device *vif = v;
+		const char *name =  vif->dev ? vif->dev->name : "none";
+
+		seq_printf(seq,
+			   "%2d %-10s %8ld %7ld  %8ld %7ld %05X %08X %08X\n",
+			   vif - vif_table,
+			   name, vif->bytes_in, vif->pkt_in, 
+			   vif->bytes_out, vif->pkt_out,
+			   vif->flags, vif->local, vif->remote);
+	}
+	return 0;
+}
+
+static struct seq_operations ipmr_vif_seq_ops = {
+	.start = ipmr_vif_seq_start,
+	.next  = ipmr_vif_seq_next,
+	.stop  = ipmr_vif_seq_stop,
+	.show  = ipmr_vif_seq_show,
+};
+
+static int ipmr_vif_open(struct inode *inode, struct file *file)
+{
+	struct seq_file *seq;
+	int rc = -ENOMEM;
+	struct ipmr_vif_iter *s = kmalloc(sizeof(*s), GFP_KERNEL);
+       
+	if (!s)
+		goto out;
+
+	rc = seq_open(file, &ipmr_vif_seq_ops);
+	if (rc)
+		goto out_kfree;
+
+	s->ct = 0;
+	seq = file->private_data;
+	seq->private = s;
+out:
+	return rc;
+out_kfree:
+	kfree(s);
+	goto out;
+
+}
+
+static struct file_operations ipmr_vif_fops = {
+	.owner	 = THIS_MODULE,
+	.open    = ipmr_vif_open,
+	.read    = seq_read,
+	.llseek  = seq_lseek,
+	.release = seq_release,
+};
+
+struct ipmr_mfc_iter {
+	struct mfc_cache **cache;
 	int ct;
+};
 
-	len += sprintf(buffer,
-		 "Group    Origin   Iif     Pkts    Bytes    Wrong Oifs\n");
-	pos=len;
 
-	read_lock(&mrt_lock);
-	for (ct=0;ct<MFC_LINES;ct++) 
-	{
-		for(mfc=mfc_cache_array[ct]; mfc; mfc=mfc->next)
-		{
-			int n;
+static struct mfc_cache *ipmr_mfc_seq_idx(struct ipmr_mfc_iter *it, loff_t pos)
+{
+	struct mfc_cache *mfc;
 
-			/*
-			 *	Interface forwarding map
-			 */
-			size = sprintf(buffer+len, "%08lX %08lX %-3d %8ld %8ld %8ld",
-				(unsigned long)mfc->mfc_mcastgrp,
-				(unsigned long)mfc->mfc_origin,
-				mfc->mfc_parent,
-				mfc->mfc_un.res.pkt,
-				mfc->mfc_un.res.bytes,
-				mfc->mfc_un.res.wrong_if);
-			for(n=mfc->mfc_un.res.minvif;n<mfc->mfc_un.res.maxvif;n++)
-			{
-				if(VIF_EXISTS(n) && mfc->mfc_un.res.ttls[n] < 255)
-					size += sprintf(buffer+len+size, " %2d:%-3d", n, mfc->mfc_un.res.ttls[n]);
-			}
-			size += sprintf(buffer+len+size, "\n");
-			len+=size;
-			pos+=size;
-			if(pos<offset)
-			{
-				len=0;
-				begin=pos;
-			}
-			if(pos>offset+length)
-				goto done;
-	  	}
-  	}
+	it->cache = mfc_cache_array;
+	read_lock(&mrt_lock);
+	for (it->ct = 0; it->ct < MFC_LINES; it->ct++) 
+		for(mfc = mfc_cache_array[it->ct]; mfc; mfc = mfc->next) 
+			if (pos-- == 0) 
+				return mfc;
+	read_unlock(&mrt_lock);
 
+	it->cache = &mfc_unres_queue;
 	spin_lock_bh(&mfc_unres_lock);
-	for(mfc=mfc_unres_queue; mfc; mfc=mfc->next) {
-		size = sprintf(buffer+len, "%08lX %08lX %-3d %8ld %8ld %8ld\n",
-			       (unsigned long)mfc->mfc_mcastgrp,
-			       (unsigned long)mfc->mfc_origin,
-			       -1,
-				(long)mfc->mfc_un.unres.unresolved.qlen,
-				0L, 0L);
-		len+=size;
-		pos+=size;
-		if(pos<offset)
-		{
-			len=0;
-			begin=pos;
-		}
-		if(pos>offset+length)
-			break;
-	}
+	for(mfc = mfc_unres_queue; mfc; mfc = mfc->next) 
+		if (pos-- == 0)
+			return mfc;
 	spin_unlock_bh(&mfc_unres_lock);
 
-done:
+	it->cache = NULL;
+	return NULL;
+}
+
+
+static void *ipmr_mfc_seq_start(struct seq_file *seq, loff_t *pos)
+{
+	return *pos ? ipmr_mfc_seq_idx(seq->private, *pos - 1) 
+		: SEQ_START_TOKEN;
+}
+
+static void *ipmr_mfc_seq_next(struct seq_file *seq, void *v, loff_t *pos)
+{
+	struct mfc_cache *mfc = v;
+	struct ipmr_mfc_iter *it = seq->private;
+
+	++*pos;
+
+	if (v == SEQ_START_TOKEN)
+		return ipmr_mfc_seq_idx(seq->private, 0);
+
+	if (mfc->next)
+		return mfc->next;
+	
+	if (it->cache == &mfc_unres_queue) 
+		goto end_of_list;
+
+	BUG_ON(it->cache != mfc_cache_array);
+
+	while (++it->ct < MFC_LINES) {
+		mfc = mfc_cache_array[it->ct];
+		if (mfc)
+			return mfc;
+	}
+
+	/* exhausted cache_array, show unresolved */
 	read_unlock(&mrt_lock);
-  	*start=buffer+(offset-begin);
-  	len-=(offset-begin);
-  	if(len>length)
-  		len=length;
-	if (len < 0) {
-		len = 0;
+	it->cache = &mfc_unres_queue;
+	it->ct = 0;
+		
+	spin_lock_bh(&mfc_unres_lock);
+	mfc = mfc_unres_queue;
+	if (mfc) 
+		return mfc;
+
+ end_of_list:
+	spin_unlock_bh(&mfc_unres_lock);
+	it->cache = NULL;
+
+	return NULL;
+}
+
+static void ipmr_mfc_seq_stop(struct seq_file *seq, void *v)
+{
+	struct ipmr_mfc_iter *it = seq->private;
+
+	if (it->cache == &mfc_unres_queue)
+		spin_unlock_bh(&mfc_unres_lock);
+	else if (it->cache == mfc_cache_array)
+		read_unlock(&mrt_lock);
+}
+
+static int ipmr_mfc_seq_show(struct seq_file *seq, void *v)
+{
+	int n;
+
+	if (v == SEQ_START_TOKEN) {
+		seq_puts(seq, 
+		 "Group    Origin   Iif     Pkts    Bytes    Wrong Oifs\n");
+	} else {
+		const struct mfc_cache *mfc = v;
+		const struct ipmr_mfc_iter *it = seq->private;
+		
+		seq_printf(seq, "%08lX %08lX %-3d %8ld %8ld %8ld",
+			   (unsigned long) mfc->mfc_mcastgrp,
+			   (unsigned long) mfc->mfc_origin,
+			   mfc->mfc_parent,
+			   mfc->mfc_un.res.pkt,
+			   mfc->mfc_un.res.bytes,
+			   mfc->mfc_un.res.wrong_if);
+
+		if (it->cache != &mfc_unres_queue) {
+			for(n = mfc->mfc_un.res.minvif; 
+			    n < mfc->mfc_un.res.maxvif; n++ ) {
+				if(VIF_EXISTS(n) 
+				   && mfc->mfc_un.res.ttls[n] < 255)
+				seq_printf(seq, 
+					   " %2d:%-3d", 
+					   n, mfc->mfc_un.res.ttls[n]);
+			}
+		}
+		seq_putc(seq, '\n');
 	}
-  	return len;
+	return 0;
 }
 
+static struct seq_operations ipmr_mfc_seq_ops = {
+	.start = ipmr_mfc_seq_start,
+	.next  = ipmr_mfc_seq_next,
+	.stop  = ipmr_mfc_seq_stop,
+	.show  = ipmr_mfc_seq_show,
+};
+
+static int ipmr_mfc_open(struct inode *inode, struct file *file)
+{
+	struct seq_file *seq;
+	int rc = -ENOMEM;
+	struct ipmr_mfc_iter *s = kmalloc(sizeof(*s), GFP_KERNEL);
+       
+	if (!s)
+		goto out;
+
+	rc = seq_open(file, &ipmr_mfc_seq_ops);
+	if (rc)
+		goto out_kfree;
+
+	memset(s, 0, sizeof(*s));
+	seq = file->private_data;
+	seq->private = s;
+out:
+	return rc;
+out_kfree:
+	kfree(s);
+	goto out;
+
+}
+
+static struct file_operations ipmr_mfc_fops = {
+	.owner	 = THIS_MODULE,
+	.open    = ipmr_mfc_open,
+	.read    = seq_read,
+	.llseek  = seq_lseek,
+	.release = seq_release,
+};
 #endif	
 
 #ifdef CONFIG_IP_PIMSM_V2
@@ -1752,7 +1887,7 @@ void __init ip_mr_init(void)
 	ipmr_expire_timer.function=ipmr_expire_process;
 	register_netdevice_notifier(&ip_mr_notifier);
 #ifdef CONFIG_PROC_FS	
-	proc_net_create("ip_mr_vif",0,ipmr_vif_info);
-	proc_net_create("ip_mr_cache",0,ipmr_mfc_info);
+	proc_net_fops_create("ip_mr_vif", 0, &ipmr_vif_fops);
+	proc_net_fops_create("ip_mr_cache", 0, &ipmr_mfc_fops);
 #endif	
 }
