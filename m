From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: [PATCH] seq_file conversion 4/5: /proc/net/mfilter6
Date: Tue, 01 Jul 2003 14:48:55 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030701.144855.86742367.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com, jmorris@intercode.com.au
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

4/5: convert /proc/net/mfilter6 to seq_file.

--- linux-2.5/net/ipv6/mcast.c.orig	Tue Jul  1 01:45:32 2003
+++ linux-2.5/net/ipv6/mcast.c	Tue Jul  1 01:46:12 2003
@@ -2179,80 +2179,178 @@
 	.release	=	seq_release_private,
 };
 
-static int ip6_mcf_read_proc(char *buffer, char **start, off_t offset,
-			   int length, int *eof, void *data)
-{
-	off_t pos=0, begin=0;
-	int len=0;
-	int first=1;
+struct igmp6_mcf_iter_state {
 	struct net_device *dev;
-	
-	read_lock(&dev_base_lock);
-	for (dev=dev_base; dev; dev=dev->next) {
-		struct inet6_dev *idev = in6_dev_get(dev);
-		struct ifmcaddr6 *imc;
+	struct inet6_dev *idev;
+	struct ifmcaddr6 *im;
+};
 
-		if (idev == NULL)
-			continue;
+#define igmp6_mcf_seq_private(seq)	((struct igmp6_mcf_iter_state *)&seq->private)
 
+static inline struct ip6_sf_list *igmp6_mcf_get_first(struct seq_file *seq)
+{
+	struct ip6_sf_list *psf = NULL;
+	struct ifmcaddr6 *im = NULL;
+	struct igmp6_mcf_iter_state *state = igmp6_mcf_seq_private(seq);
+
+	for (state->dev = dev_base, state->idev = NULL, state->im = NULL;
+	     state->dev; 
+	     state->dev = state->dev->next) {
+		struct inet6_dev *idev;
+		idev = in6_dev_get(state->dev);
+		if (unlikely(idev == NULL))
+			continue;
 		read_lock_bh(&idev->lock);
-
-		for (imc=idev->mc_list; imc; imc=imc->next) {
-			struct ip6_sf_list *psf;
-			unsigned long i;
-
-			spin_lock_bh(&imc->mca_lock);
-			for (psf=imc->mca_sources; psf; psf=psf->sf_next) {
-				if (first) {
-					len += sprintf(buffer+len, "%3s %6s "
-						"%32s %32s %6s %6s\n", "Idx",
-						"Device", "Multicast Address",
-						"Source Address", "INC", "EXC");
-					first = 0;
-				}
-				len += sprintf(buffer+len,"%3d %6.6s ",
-					dev->ifindex, dev->name);
-
-				for (i=0; i<16; i++)
-					len += sprintf(buffer+len, "%02x",
-						imc->mca_addr.s6_addr[i]);
-				buffer[len++] = ' ';
-				for (i=0; i<16; i++)
-					len += sprintf(buffer+len, "%02x",
-						psf->sf_addr.s6_addr[i]);
-				len += sprintf(buffer+len, " %6lu %6lu\n",
-					psf->sf_count[MCAST_INCLUDE],
-					psf->sf_count[MCAST_EXCLUDE]);
-				pos = begin+len;
-				if (pos < offset) {
-					len=0;
-					begin=pos;
-				}
-				if (pos > offset+length) {
-					spin_unlock_bh(&imc->mca_lock);
-					read_unlock_bh(&idev->lock);
-					in6_dev_put(idev);
-					goto done;
-				}
+		im = idev->mc_list;
+		if (likely(im != NULL)) {
+			spin_lock_bh(&im->mca_lock);
+			psf = im->mca_sources;
+			if (likely(psf != NULL)) {
+				state->im = im;
+				state->idev = idev;
+				break;
 			}
-			spin_unlock_bh(&imc->mca_lock);
+			spin_unlock_bh(&im->mca_lock);
 		}
 		read_unlock_bh(&idev->lock);
-		in6_dev_put(idev);
 	}
-	*eof = 1;
+	return psf;
+}
+
+static struct ip6_sf_list *igmp6_mcf_get_next(struct seq_file *seq, struct ip6_sf_list *psf)
+{
+	struct igmp6_mcf_iter_state *state = igmp6_mcf_seq_private(seq);
+
+	psf = psf->sf_next;
+	while (!psf) {
+		spin_unlock_bh(&state->im->mca_lock);
+		state->im = state->im->next;
+		while (!state->im) {
+			if (likely(state->idev != NULL)) {
+				read_unlock_bh(&state->idev->lock);
+				in6_dev_put(state->idev);
+			}
+			state->dev = state->dev->next;
+			if (!state->dev) {
+				state->idev = NULL;
+				goto out;
+			}
+			state->idev = in6_dev_get(state->dev);
+			if (!state->idev)
+				continue;
+			read_lock_bh(&state->idev->lock);
+			state->im = state->idev->mc_list;
+		}
+		if (!state->im)
+			break;
+		spin_lock_bh(&state->im->mca_lock);
+		psf = state->im->mca_sources;
+	}
+out:
+	return psf;
+}
+
+static struct ip6_sf_list *igmp6_mcf_get_idx(struct seq_file *seq, loff_t pos)
+{
+	struct ip6_sf_list *psf = igmp6_mcf_get_first(seq);
+	if (psf)
+		while (pos && (psf = igmp6_mcf_get_next(seq, psf)) != NULL)
+			--pos;
+	return pos ? NULL : psf;
+}
+
+static void *igmp6_mcf_seq_start(struct seq_file *seq, loff_t *pos)
+{
+	read_lock(&dev_base_lock);
+	return *pos ? igmp6_mcf_get_idx(seq, *pos) : (void *)1;
+}
+
+static void *igmp6_mcf_seq_next(struct seq_file *seq, void *v, loff_t *pos)
+{
+	struct ip6_sf_list *psf;
+	if (v == (void *)1)
+		psf = igmp6_mcf_get_first(seq);
+	else
+		psf = igmp6_mcf_get_next(seq, v);
+	++*pos;
+	return psf;
+}
 
-done:
+static void igmp6_mcf_seq_stop(struct seq_file *seq, void *v)
+{
+	struct igmp6_mcf_iter_state *state = igmp6_mcf_seq_private(seq);
+	if (likely(state->im != NULL))
+		spin_unlock_bh(&state->im->mca_lock);
+	if (likely(state->idev != NULL)) {
+		read_unlock_bh(&state->idev->lock);
+		in6_dev_put(state->idev);
+	}
 	read_unlock(&dev_base_lock);
+}
+
+static int igmp6_mcf_seq_show(struct seq_file *seq, void *v)
+{
+	struct ip6_sf_list *psf = (struct ip6_sf_list *)v;
+	struct igmp6_mcf_iter_state *state = igmp6_mcf_seq_private(seq);
+
+	if (v == (void *)1) {
+		seq_printf(seq, 
+			   "%3s %6s "
+			   "%32s %32s %6s %6s\n", "Idx",
+			   "Device", "Multicast Address",
+			   "Source Address", "INC", "EXC");
+	} else {
+		seq_printf(seq,
+			   "%3d %6.6s "
+			   "%04x%04x%04x%04x%04x%04x%04x%04x "
+			   "%04x%04x%04x%04x%04x%04x%04x%04x "
+			   "%6lu %6lu\n",
+			   state->dev->ifindex, state->dev->name,
+			   NIP6(state->im->mca_addr),
+			   NIP6(psf->sf_addr),
+			   psf->sf_count[MCAST_INCLUDE],
+			   psf->sf_count[MCAST_EXCLUDE]);
+	}
+	return 0;
+}
+
+static struct seq_operations igmp6_mcf_seq_ops = {
+	.start	=	igmp6_mcf_seq_start,
+	.next	=	igmp6_mcf_seq_next,
+	.stop	=	igmp6_mcf_seq_stop,
+	.show	=	igmp6_mcf_seq_show,
+};
+
+static int igmp6_mcf_seq_open(struct inode *inode, struct file *file)
+{
+	struct seq_file *seq;
+	int rc = -ENOMEM;
+	struct igmp6_mcf_iter_state *s = kmalloc(sizeof(*s), GFP_KERNEL);
+	
+	if (!s)
+		goto out;
+
+	rc = seq_open(file, &igmp6_mcf_seq_ops);
+	if (rc)
+		goto out_kfree;
 
-	*start=buffer+(offset-begin);
-	len-=(offset-begin);
-	if(len>length)
-		len=length;
-	if (len<0)
-		len=0;
-	return len;
+	seq = file->private_data;
+	seq->private = s;
+	memset(s, 0, sizeof(*s));
+out:
+	return rc;
+out_kfree:
+	kfree(s);
+	goto out;
 }
+
+static struct file_operations igmp6_mcf_seq_fops = {
+	.owner		=	THIS_MODULE,
+	.open		=	igmp6_mcf_seq_open,
+	.read		=	seq_read,
+	.llseek		=	seq_lseek,
+	.release	=	seq_release_private,
+};
 #endif
 
 int __init igmp6_init(struct net_proto_family *ops)
@@ -2284,7 +2382,9 @@
 	p = create_proc_entry("igmp6", S_IRUGO, proc_net);
 	if (p)
 		p->proc_fops = &igmp6_mc_seq_fops;
-	create_proc_read_entry("net/mcfilter6", 0, 0, ip6_mcf_read_proc, NULL);
+	p = create_proc_entry("mcfilter6", S_IRUGO, proc_net);
+	if (p)
+		p->proc_fops = &igmp6_mcf_seq_fops;
 #endif
 
 	return 0;
@@ -2295,6 +2395,7 @@
 	sock_release(igmp6_socket);
 	igmp6_socket = NULL; /* for safety */
 #ifdef CONFIG_PROC_FS
+	proc_net_remove("mcfilter6");
 	proc_net_remove("igmp6");
 #endif
 }


-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
