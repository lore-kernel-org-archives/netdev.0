From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: [PATCH] seq_file conversion 3/5: /proc/net/mfilter
Date: Tue, 01 Jul 2003 14:48:53 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030701.144853.89770574.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com, jmorris@intercode.com.au
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

3/5: convert /proc/net/mfilter to seq_file.

--- linux-2.5/include/net/ip.h.orig	Tue Jul  1 01:45:32 2003
+++ linux-2.5/include/net/ip.h	Tue Jul  1 01:46:12 2003
@@ -80,7 +80,6 @@
 extern void		ip_mc_dropsocket(struct sock *);
 extern void		ip_mc_dropdevice(struct net_device *dev);
 extern int		igmp_mc_proc_init(void);
-extern int		ip_mcf_procinfo(char *, char **, off_t, int);
 
 /*
  *	Functions provided by ip.c
--- linux-2.5/net/ipv4/igmp.c.orig	Tue Jul  1 01:45:32 2003
+++ linux-2.5/net/ipv4/igmp.c	Tue Jul  1 01:46:12 2003
@@ -2247,74 +2247,177 @@
 	.llseek		=	seq_lseek,
 	.release	=	seq_release_private,
 };
-#endif
 
-int ip_mcf_procinfo(char *buffer, char **start, off_t offset, int length)
-{
-	off_t pos=0, begin=0;
-	int len=0;
-	int first = 1;
+struct igmp_mcf_iter_state {
 	struct net_device *dev;
+	struct in_device *idev;
+	struct ip_mc_list *im;
+};
 
-	read_lock(&dev_base_lock);
-	for(dev=dev_base; dev; dev=dev->next) {
-		struct in_device *in_dev = in_dev_get(dev);
-		struct ip_mc_list *imc;
+#define igmp_mcf_seq_private(seq)	((struct igmp_mcf_iter_state *)&seq->private)
 
-		if (in_dev == NULL)
+static inline struct ip_sf_list *igmp_mcf_get_first(struct seq_file *seq)
+{
+	struct ip_sf_list *psf = NULL;
+	struct ip_mc_list *im = NULL;
+	struct igmp_mcf_iter_state *state = igmp_mcf_seq_private(seq);
+
+	for (state->dev = dev_base, state->idev = NULL, state->im = NULL;
+	     state->dev; 
+	     state->dev = state->dev->next) {
+		struct in_device *idev;
+		idev = in_dev_get(state->dev);
+		if (unlikely(idev == NULL))
 			continue;
+		read_lock_bh(&idev->lock);
+		im = idev->mc_list;
+		if (likely(im != NULL)) {
+			spin_lock_bh(&im->lock);
+			psf = im->sources;
+			if (likely(psf != NULL)) {
+				state->im = im;
+				state->idev = idev;
+				break;
+			}
+			spin_unlock_bh(&im->lock);
+		}
+		read_unlock_bh(&idev->lock);
+	}
+	return psf;
+}
 
-		read_lock(&in_dev->lock);
-
-		for (imc=in_dev->mc_list; imc; imc=imc->next) {
-			struct ip_sf_list *psf;
+static struct ip_sf_list *igmp_mcf_get_next(struct seq_file *seq, struct ip_sf_list *psf)
+{
+	struct igmp_mcf_iter_state *state = igmp_mcf_seq_private(seq);
 
-			spin_lock_bh(&imc->lock);
-			for (psf=imc->sources; psf; psf=psf->sf_next) {
-				if (first) {
-					len += sprintf(buffer+len, "%3s %6s "
-						"%10s %10s %6s %6s\n", "Idx",
-						"Device", "MCA", "SRC", "INC",
-						"EXC");
-					first = 0;
-				}
-				len += sprintf(buffer+len, "%3d %6.6s 0x%08x "
-					"0x%08x %6lu %6lu\n", dev->ifindex,
-					dev->name, ntohl(imc->multiaddr),
-					ntohl(psf->sf_inaddr),
-					psf->sf_count[MCAST_INCLUDE],
-					psf->sf_count[MCAST_EXCLUDE]);
-				pos=begin+len;
-				if(pos<offset)
-				{
-					len=0;
-					begin=pos;
-				}
-				if(pos>offset+length) {
-					spin_unlock_bh(&imc->lock);
-					read_unlock(&in_dev->lock);
-					in_dev_put(in_dev);
-					goto done;
-				}
+	psf = psf->sf_next;
+	while (!psf) {
+		spin_unlock_bh(&state->im->lock);
+		state->im = state->im->next;
+		while (!state->im) {
+			if (likely(state->idev != NULL)) {
+				read_unlock_bh(&state->idev->lock);
+				in_dev_put(state->idev);
 			}
-			spin_unlock_bh(&imc->lock);
+			state->dev = state->dev->next;
+			if (!state->dev) {
+				state->idev = NULL;
+				goto out;
+			}
+			state->idev = in_dev_get(state->dev);
+			if (!state->idev)
+				continue;
+			read_lock_bh(&state->idev->lock);
+			state->im = state->idev->mc_list;
 		}
-		read_unlock(&in_dev->lock);
-		in_dev_put(in_dev);
+		if (!state->im)
+			break;
+		spin_lock_bh(&state->im->lock);
+		psf = state->im->sources;
+	}
+out:
+	return psf;
+}
+
+static struct ip_sf_list *igmp_mcf_get_idx(struct seq_file *seq, loff_t pos)
+{
+	struct ip_sf_list *psf = igmp_mcf_get_first(seq);
+	if (psf)
+		while (pos && (psf = igmp_mcf_get_next(seq, psf)) != NULL)
+			--pos;
+	return pos ? NULL : psf;
+}
+
+static void *igmp_mcf_seq_start(struct seq_file *seq, loff_t *pos)
+{
+	read_lock(&dev_base_lock);
+	return *pos ? igmp_mcf_get_idx(seq, *pos) : (void *)1;
+}
+
+static void *igmp_mcf_seq_next(struct seq_file *seq, void *v, loff_t *pos)
+{
+	struct ip_sf_list *psf;
+	if (v == (void *)1)
+		psf = igmp_mcf_get_first(seq);
+	else
+		psf = igmp_mcf_get_next(seq, v);
+	++*pos;
+	return psf;
+}
+
+static void igmp_mcf_seq_stop(struct seq_file *seq, void *v)
+{
+	struct igmp_mcf_iter_state *state = igmp_mcf_seq_private(seq);
+	if (likely(state->im != NULL))
+		spin_unlock_bh(&state->im->lock);
+	if (likely(state->idev != NULL)) {
+		read_unlock_bh(&state->idev->lock);
+		in_dev_put(state->idev);
 	}
-done:
 	read_unlock(&dev_base_lock);
+}
+
+static int igmp_mcf_seq_show(struct seq_file *seq, void *v)
+{
+	struct ip_sf_list *psf = (struct ip_sf_list *)v;
+	struct igmp_mcf_iter_state *state = igmp_mcf_seq_private(seq);
 
-	*start=buffer+(offset-begin);
-	len-=(offset-begin);
-	if(len>length)
-		len=length;
-	if(len<0)
-		len=0;
-	return len;
+	if (v == (void *)1) {
+		seq_printf(seq, 
+			   "%3s %6s "
+			   "%10s %10s %6s %6s\n", "Idx",
+			   "Device", "MCA",
+			   "SRC", "INC", "EXC");
+	} else {
+		seq_printf(seq,
+			   "%3d %6.6s 0x%08x "
+			   "0x%08x %6lu %6lu\n", 
+			   state->dev->ifindex, state->dev->name, 
+			   ntohl(state->im->multiaddr),
+			   ntohl(psf->sf_inaddr),
+			   psf->sf_count[MCAST_INCLUDE],
+			   psf->sf_count[MCAST_EXCLUDE]);
+	}
+	return 0;
+}
+
+static struct seq_operations igmp_mcf_seq_ops = {
+	.start	=	igmp_mcf_seq_start,
+	.next	=	igmp_mcf_seq_next,
+	.stop	=	igmp_mcf_seq_stop,
+	.show	=	igmp_mcf_seq_show,
+};
+
+static int igmp_mcf_seq_open(struct inode *inode, struct file *file)
+{
+	struct seq_file *seq;
+	int rc = -ENOMEM;
+	struct igmp_mcf_iter_state *s = kmalloc(sizeof(*s), GFP_KERNEL);
+
+	if (!s)
+		goto out;
+	rc = seq_open(file, &igmp_mcf_seq_ops);
+	if (rc)
+		goto out_kfree;
+
+	seq = file->private_data;
+	seq->private = s;
+	memset(s, 0, sizeof(*s));
+out:
+	return rc;
+out_kfree:
+	kfree(s);
+	goto out;
 }
 
-#ifdef CONFIG_PROC_FS
+static struct file_operations igmp_mcf_seq_fops = {
+	.owner		=	THIS_MODULE,
+	.open		=	igmp_mcf_seq_open,
+	.read		=	seq_read,
+	.llseek		=	seq_lseek,
+	.release	=	seq_release_private,
+};
+
 int __init igmp_mc_proc_init(void)
 {
 	struct proc_dir_entry *p;
@@ -2322,6 +2425,10 @@
 	p = create_proc_entry("igmp", S_IRUGO, proc_net);
 	if (p)
 		p->proc_fops = &igmp_mc_seq_fops;
+
+	p = create_proc_entry("mcfilter", S_IRUGO, proc_net);
+	if (p)
+		p->proc_fops = &igmp_mcf_seq_fops;
 	return 0;
 }
 #endif
--- linux-2.5/net/ipv4/ip_output.c.orig	Tue Jul  1 01:45:32 2003
+++ linux-2.5/net/ipv4/ip_output.c	Tue Jul  1 01:46:12 2003
@@ -1316,5 +1316,4 @@
 #ifdef CONFIG_IP_MULTICAST
 	igmp_mc_proc_init();
 #endif
-	proc_net_create("mcfilter", 0, ip_mcf_procinfo);
 }

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
