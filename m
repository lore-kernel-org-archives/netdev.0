From: chas williams <chas@cmf.nrl.navy.mil>
Subject: [PATCH][ATM] seqfile conversion for net/atm/proc.c
Date: Mon, 08 Sep 2003 16:41:19 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200309082041.h88KfISa003500@ginger.cmf.nrl.navy.mil>
Reply-To: chas3@users.sourceforge.net
Cc: netdev@oss.sgi.com, romieu@fr.zoreil.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

please apply to 2.6 (please note this patch has been split into
8 pieces) -- thanks

[ATM]: seq_file for /proc/net/atm (devices) [1/8] (from romieu@fr.zoreil.com)

seq_file conversion for proc/atm/devices:
- code inspired from seq_file use in net/core/dev.c;
- atm_dev_lock taken/released in atm_dev_seq_{start/stop};
- add a helper CREATE_SEQ_ENTRY() similar to CREATE_ENTRY() (both are removed
  once conversion is done).
- atm_dev_seq_{start/stop/next} done in net/atm/resource.[ch] to ease
  future handling of atm_devs and locking structure (per Chas suggestion)


 net/atm/proc.c      |   86 +++++++++++++++++++++++++++++++---------------------
 net/atm/resources.c |   29 +++++++++++++++++
 net/atm/resources.h |    5 +++
 3 files changed, 86 insertions(+), 34 deletions(-)

diff -puN net/atm/proc.c~atm-proc-seq-devices net/atm/proc.c
--- linux-2.6.0-test4-bk8/net/atm/proc.c~atm-proc-seq-devices	Sat Sep  6 23:22:58 2003
+++ linux-2.6.0-test4-bk8-fr/net/atm/proc.c	Sat Sep  6 23:22:58 2003
@@ -24,6 +24,7 @@
 #include <linux/fs.h>
 #include <linux/stat.h>
 #include <linux/proc_fs.h>
+#include <linux/seq_file.h>
 #include <linux/errno.h>
 #include <linux/atm.h>
 #include <linux/atmdev.h>
@@ -64,32 +65,30 @@ static struct file_operations proc_spec_
 	.read =		proc_spec_atm_read,
 };
 
-static void add_stats(char *buf,const char *aal,
+static void add_stats(struct seq_file *seq, const char *aal,
   const struct k_atm_aal_stats *stats)
 {
-	sprintf(strchr(buf,0),"%s ( %d %d %d %d %d )",aal,
+	seq_printf(seq, "%s ( %d %d %d %d %d )", aal,
 	    atomic_read(&stats->tx),atomic_read(&stats->tx_err),
 	    atomic_read(&stats->rx),atomic_read(&stats->rx_err),
 	    atomic_read(&stats->rx_drop));
 }
 
-
-static void atm_dev_info(const struct atm_dev *dev,char *buf)
+static void atm_dev_info(struct seq_file *seq, const struct atm_dev *dev)
 {
-	int off,i;
+	int i;
 
-	off = sprintf(buf,"%3d %-8s",dev->number,dev->type);
+	seq_printf(seq, "%3d %-8s", dev->number, dev->type);
 	for (i = 0; i < ESI_LEN; i++)
-		off += sprintf(buf+off,"%02x",dev->esi[i]);
-	strcat(buf,"  ");
-	add_stats(buf,"0",&dev->stats.aal0);
-	strcat(buf,"  ");
-	add_stats(buf,"5",&dev->stats.aal5);
-	sprintf(strchr(buf,0), "\t[%d]", atomic_read(&dev->refcnt));
-	strcat(buf,"\n");
+		seq_printf(seq, "%02x", dev->esi[i]);
+	seq_puts(seq, "  ");
+	add_stats(seq, "0", &dev->stats.aal0);
+	seq_puts(seq, "  ");
+	add_stats(seq, "5", &dev->stats.aal5);
+	seq_printf(seq, "\t[%d]", atomic_read(&dev->refcnt));
+	seq_putc(seq, '\n');
 }
 
-
 #if defined(CONFIG_ATM_CLIP) || defined(CONFIG_ATM_CLIP_MODULE)
 
 
@@ -303,29 +302,40 @@ lec_info(struct lec_arp_table *entry, ch
 
 #endif
 
-static int atm_devices_info(loff_t pos,char *buf)
+static int atm_dev_seq_show(struct seq_file *seq, void *v)
 {
-	struct atm_dev *dev;
-	struct list_head *p;
-	int left;
+	static char atm_dev_banner[] =
+		"Itf Type    ESI/\"MAC\"addr "
+		"AAL(TX,err,RX,err,drop) ...               [refcnt]\n";
+ 
+	if (v == (void *)1)
+		seq_puts(seq, atm_dev_banner);
+	else {
+		struct atm_dev *dev = list_entry(v, struct atm_dev, dev_list);
 
-	if (!pos) {
-		return sprintf(buf,"Itf Type    ESI/\"MAC\"addr "
-		    "AAL(TX,err,RX,err,drop) ...               [refcnt]\n");
-	}
-	left = pos-1;
-	spin_lock(&atm_dev_lock);
-	list_for_each(p, &atm_devs) {
-		dev = list_entry(p, struct atm_dev, dev_list);
-		if (left-- == 0) {
-			atm_dev_info(dev,buf);
-			spin_unlock(&atm_dev_lock);
-			return strlen(buf);
-		}
+		atm_dev_info(seq, dev);
 	}
-	spin_unlock(&atm_dev_lock);
-	return 0;
+ 	return 0;
 }
+ 
+static struct seq_operations atm_dev_seq_ops = {
+	.start	= atm_dev_seq_start,
+	.next	= atm_dev_seq_next,
+	.stop	= atm_dev_seq_stop,
+	.show	= atm_dev_seq_show,
+};
+ 
+static int atm_dev_seq_open(struct inode *inode, struct file *file)
+{
+	return seq_open(file, &atm_dev_seq_ops);
+}
+ 
+static struct file_operations devices_seq_fops = {
+	.open		= atm_dev_seq_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= seq_release,
+};
 
 /*
  * FIXME: it isn't safe to walk the VCC list without turning off interrupts.
@@ -630,6 +640,14 @@ void atm_proc_dev_deregister(struct atm_
 	kfree(dev->proc_name);
 }
 
+#define CREATE_SEQ_ENTRY(name) \
+	do { \
+		name = create_proc_entry(#name, S_IRUGO, atm_proc_root); \
+		if (!name) \
+			goto cleanup; \
+		name->proc_fops = & name##_seq_fops; \
+		name->owner = THIS_MODULE; \
+	} while (0)
 
 #define CREATE_ENTRY(name) \
     name = create_proc_entry(#name,0,atm_proc_root); \
@@ -663,7 +681,7 @@ int __init atm_proc_init(void)
 	atm_proc_root = proc_mkdir("net/atm",NULL);
 	if (!atm_proc_root)
 		return -ENOMEM;
-	CREATE_ENTRY(devices);
+	CREATE_SEQ_ENTRY(devices);
 	CREATE_ENTRY(pvc);
 	CREATE_ENTRY(svc);
 	CREATE_ENTRY(vc);
diff -puN net/atm/resources.c~atm-proc-seq-devices net/atm/resources.c
--- linux-2.6.0-test4-bk8/net/atm/resources.c~atm-proc-seq-devices	Sat Sep  6 23:22:58 2003
+++ linux-2.6.0-test4-bk8-fr/net/atm/resources.c	Sat Sep  6 23:22:58 2003
@@ -395,6 +395,35 @@ done:
 	return error;
 }
 
+static __inline__ void *dev_get_idx(loff_t left)
+{
+	struct list_head *p;
+
+	list_for_each(p, &atm_devs) {
+		if (!--left)
+			break;
+	}
+	return (p != &atm_devs) ? p : NULL;
+}
+
+void *atm_dev_seq_start(struct seq_file *seq, loff_t *pos)
+{
+ 	spin_lock(&atm_dev_lock);
+	return *pos ? dev_get_idx(*pos) : (void *) 1;
+}
+
+void atm_dev_seq_stop(struct seq_file *seq, void *v)
+{
+ 	spin_unlock(&atm_dev_lock);
+}
+ 
+void *atm_dev_seq_next(struct seq_file *seq, void *v, loff_t *pos)
+{
+	++*pos;
+	v = (v == (void *)1) ? atm_devs.next : ((struct list_head *)v)->next;
+	return (v == &atm_devs) ? NULL : v;
+}
+
 
 EXPORT_SYMBOL(atm_dev_register);
 EXPORT_SYMBOL(atm_dev_deregister);
diff -puN net/atm/resources.h~atm-proc-seq-devices net/atm/resources.h
--- linux-2.6.0-test4-bk8/net/atm/resources.h~atm-proc-seq-devices	Sat Sep  6 23:22:58 2003
+++ linux-2.6.0-test4-bk8-fr/net/atm/resources.h	Sat Sep  6 23:22:58 2003
@@ -21,6 +21,11 @@ int atm_dev_ioctl(unsigned int cmd, unsi
 
 #include <linux/proc_fs.h>
 
+void *atm_dev_seq_start(struct seq_file *seq, loff_t *pos);
+void atm_dev_seq_stop(struct seq_file *seq, void *v);
+void *atm_dev_seq_next(struct seq_file *seq, void *v, loff_t *pos);
+
+
 int atm_proc_dev_register(struct atm_dev *dev);
 void atm_proc_dev_deregister(struct atm_dev *dev);
 

[ATM]: seq_file for /proc/net/atm (vc utils) [2/8] (from romieu@fr.zoreil.com)

Helpers for seq_file conversion of proc/atm/{pvc/svc/vc}:
- struct vcc_state keeps
  1) the struct sock from which the current struct atm_vcc is deduced
  2) the family to which must belong the vcc (PF_ATM{SVC/PVC/any})
  3) the availability of clip module
- vcc_seq{start/stop} are responsible for vcc_sklist locking
- __vcc_seq_open and vcc_seq_release take care of get/put for the clip module.

Chas's suggestions applied since last version:
- atm_vc_xxx renamed to vcc_xxx
- atm_vc_common_seq_open renamed  __vcc_seq_open (future name clashes
  avoidance)


 net/atm/proc.c |  100 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 100 insertions(+)

diff -puN net/atm/proc.c~atm-proc-seq-vc-utils net/atm/proc.c
--- linux-2.6.0-test4-bk8/net/atm/proc.c~atm-proc-seq-vc-utils	Sat Sep  6 23:25:10 2003
+++ linux-2.6.0-test4-bk8-fr/net/atm/proc.c	Sat Sep  6 23:25:10 2003
@@ -161,6 +161,106 @@ static void atmarp_info(struct net_devic
 
 #endif
 
+struct vcc_state {
+	struct sock *sk;
+	int family;
+	int clip_info;
+};
+
+static inline int compare_family(struct sock *sk, int family)
+{
+	struct atm_vcc *vcc = atm_sk(sk);
+
+	return !family || (vcc->sk->sk_family == family);
+}
+
+static int __vcc_walk(struct sock **sock, int family, loff_t l)
+{
+	struct sock *sk = *sock;
+
+	if (sk == (void *)1) {
+		sk = hlist_empty(&vcc_sklist) ? NULL : __sk_head(&vcc_sklist);
+		l--;
+	} 
+	for (; sk; sk = sk_next(sk)) {
+		l -= compare_family(sk, family);
+		if (l < 0)
+			goto out;
+	}
+	sk = (void *)1;
+out:
+	*sock = sk;
+	return (l < 0);
+}
+
+static inline void *vcc_walk(struct vcc_state *state, loff_t l)
+{
+	return __vcc_walk(&state->sk, state->family, l) ?
+	       state : NULL;
+}
+
+static int __vcc_seq_open(struct inode *inode, struct file *file,
+	int family, struct seq_operations *ops)
+{
+	struct vcc_state *state;
+	struct seq_file *seq;
+	int rc = -ENOMEM;
+
+	state = kmalloc(sizeof(*state), GFP_KERNEL);
+	if (!state)
+		goto out;
+
+	rc = seq_open(file, ops);
+	if (rc)
+		goto out_kfree;
+
+	state->family = family;
+	state->clip_info = try_atm_clip_ops();
+
+	seq = file->private_data;
+	seq->private = state;
+out:
+	return rc;
+out_kfree:
+	kfree(state);
+	goto out;
+}
+
+static int vcc_seq_release(struct inode *inode, struct file *file)
+{
+#if defined(CONFIG_ATM_CLIP) || defined(CONFIG_ATM_CLIP_MODULE)
+	struct seq_file *seq = file->private_data;
+	struct vcc_state *state = seq->private;
+
+	if (state->clip_info)
+		module_put(atm_clip_ops->owner);
+#endif
+	return seq_release_private(inode, file);
+}
+
+static void *vcc_seq_start(struct seq_file *seq, loff_t *pos)
+{
+	struct vcc_state *state = seq->private;
+	loff_t left = *pos;
+
+	read_lock(&vcc_sklist_lock);
+	state->sk = (void *)1;
+	return left ? vcc_walk(state, left) : (void *)1;
+}
+
+static void vcc_seq_stop(struct seq_file *seq, void *v)
+{
+	read_unlock(&vcc_sklist_lock);
+}
+
+static void *vcc_seq_next(struct seq_file *seq, void *v, loff_t *pos)
+{
+	struct vcc_state *state = seq->private;
+
+	v = vcc_walk(state, 1);
+	*pos += !!PTR_ERR(v);
+	return v;
+}
 
 static void pvc_info(struct atm_vcc *vcc, char *buf, int clip_info)
 {


[ATM]: seq_file for /proc/net/atm (pvc) [3/8] (from romieu@fr.zoreil.com)

seq_file support for /proc/net/atm/pvc:
- pvc_info(): seq_printf/seq_putc replaces sprintf;
- atm_pvc_info() removal;
- the vc helpers (vcc__seq_xxx) do the remaining work.

Chas's suggestions applied since last version:
- atm_pvc_xxx renamed to pvc_xxx
- atm_seq_pvc_fops renamed to pvc_seq_fops


 net/atm/proc.c |   81 +++++++++++++++++++++++----------------------------------
 1 files changed, 34 insertions(+), 47 deletions(-)

diff -puN net/atm/proc.c~atm-proc-seq-pvc-conversion net/atm/proc.c
--- linux-2.6.0-test4-bk8/net/atm/proc.c~atm-proc-seq-pvc-conversion	Sat Sep  6 23:26:53 2003
+++ linux-2.6.0-test4-bk8-fr/net/atm/proc.c	Sat Sep  6 23:26:53 2003
@@ -262,7 +262,7 @@ static void *vcc_seq_next(struct seq_fil
 	return v;
 }
 
-static void pvc_info(struct atm_vcc *vcc, char *buf, int clip_info)
+static void pvc_info(struct seq_file *seq, struct atm_vcc *vcc, int clip_info)
 {
 	static const char *class_name[] = { "off","UBR","CBR","VBR","ABR" };
 	static const char *aal_name[] = {
@@ -270,9 +270,8 @@ static void pvc_info(struct atm_vcc *vcc
 		"???",	"5",	"???",	"???",	/*  4- 7 */
 		"???",	"???",	"???",	"???",	/*  8-11 */
 		"???",	"0",	"???",	"???"};	/* 12-15 */
-	int off;
 
-	off = sprintf(buf,"%3d %3d %5d %-3s %7d %-5s %7d %-6s",
+	seq_printf(seq, "%3d %3d %5d %-3s %7d %-5s %7d %-6s",
 	    vcc->dev->number,vcc->vpi,vcc->vci,
 	    vcc->qos.aal >= sizeof(aal_name)/sizeof(aal_name[0]) ? "err" :
 	    aal_name[vcc->qos.aal],vcc->qos.rxtp.min_pcr,
@@ -284,18 +283,14 @@ static void pvc_info(struct atm_vcc *vcc
 		struct net_device *dev;
 
 		dev = clip_vcc->entry ? clip_vcc->entry->neigh->dev : NULL;
-		off += sprintf(buf+off,"CLIP, Itf:%s, Encap:",
+		seq_printf(seq, "CLIP, Itf:%s, Encap:",
 		    dev ? dev->name : "none?");
-		if (clip_vcc->encap)
-			off += sprintf(buf+off,"LLC/SNAP");
-		else
-			off += sprintf(buf+off,"None");
+		seq_printf(seq, "%s", clip_vcc->encap ? "LLC/SNAP" : "None");
 	}
 #endif
-	strcpy(buf+off,"\n");
+	seq_putc(seq, '\n');
 }
 
-
 static const char *vcc_state(struct atm_vcc *vcc)
 {
 	static const char *map[] = { ATM_VS2TXT_MAP };
@@ -437,48 +432,40 @@ static struct file_operations devices_se
 	.release	= seq_release,
 };
 
-/*
- * FIXME: it isn't safe to walk the VCC list without turning off interrupts.
- * What is really needed is some lock on the devices. Ditto for ATMARP.
- */
-
-static int atm_pvc_info(loff_t pos,char *buf)
+static int pvc_seq_show(struct seq_file *seq, void *v)
 {
-	struct hlist_node *node;
-	struct sock *s;
-	struct atm_vcc *vcc;
-	int left, clip_info = 0;
+	static char atm_pvc_banner[] = 
+		"Itf VPI VCI   AAL RX(PCR,Class) TX(PCR,Class)\n";
 
-	if (!pos) {
-		return sprintf(buf,"Itf VPI VCI   AAL RX(PCR,Class) "
-		    "TX(PCR,Class)\n");
-	}
-	left = pos-1;
-#if defined(CONFIG_ATM_CLIP) || defined(CONFIG_ATM_CLIP_MODULE)
-	if (try_atm_clip_ops())
-		clip_info = 1;
-#endif
-	read_lock(&vcc_sklist_lock);
-	sk_for_each(s, node, &vcc_sklist) {
-		vcc = atm_sk(s);
-		if (vcc->sk->sk_family == PF_ATMPVC && vcc->dev && !left--) {
-			pvc_info(vcc,buf,clip_info);
-			read_unlock(&vcc_sklist_lock);
-#if defined(CONFIG_ATM_CLIP) || defined(CONFIG_ATM_CLIP_MODULE)
-			if (clip_info)
-				module_put(atm_clip_ops->owner);
-#endif
-			return strlen(buf);
-		}
+	if (v == (void *)1)
+		seq_puts(seq, atm_pvc_banner);
+	else {
+		struct vcc_state *state = seq->private;
+		struct atm_vcc *vcc = atm_sk(state->sk);
+
+		pvc_info(seq, vcc, state->clip_info);
 	}
-	read_unlock(&vcc_sklist_lock);
-#if defined(CONFIG_ATM_CLIP) || defined(CONFIG_ATM_CLIP_MODULE)
-	if (clip_info)
-		module_put(atm_clip_ops->owner);
-#endif
 	return 0;
 }
 
+static struct seq_operations pvc_seq_ops = {
+	.start	= vcc_seq_start,
+	.next	= vcc_seq_next,
+	.stop	= vcc_seq_stop,
+	.show	= pvc_seq_show,
+};
+
+static int pvc_seq_open(struct inode *inode, struct file *file)
+{
+	return __vcc_seq_open(inode, file, PF_ATMPVC, &pvc_seq_ops);
+}
+
+static struct file_operations pvc_seq_fops = {
+	.open		= pvc_seq_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= vcc_seq_release,
+};
 
 static int atm_vc_info(loff_t pos,char *buf)
 {
@@ -782,7 +769,7 @@ int __init atm_proc_init(void)
 	if (!atm_proc_root)
 		return -ENOMEM;
 	CREATE_SEQ_ENTRY(devices);
-	CREATE_ENTRY(pvc);
+	CREATE_SEQ_ENTRY(pvc);
 	CREATE_ENTRY(svc);
 	CREATE_ENTRY(vc);
 #if defined(CONFIG_ATM_CLIP) || defined(CONFIG_ATM_CLIP_MODULE)

[ATM]: seq_file for /proc/net/atm (svc) [4/8] (from romieu@fr.zoreil.com)

seq_file support for /proc/net/atm/svc:

Exactly same comments as pvc. Just s/p/s/


 net/atm/proc.c |   81 ++++++++++++++++++++++++++++++---------------------------
 1 files changed, 44 insertions(+), 37 deletions(-)

diff -puN net/atm/proc.c~atm-proc-seq-svc-conversion net/atm/proc.c
--- linux-2.6.0-test4-bk8/net/atm/proc.c~atm-proc-seq-svc-conversion	Sat Sep  6 23:29:31 2003
+++ linux-2.6.0-test4-bk8-fr/net/atm/proc.c	Sat Sep  6 23:29:31 2003
@@ -323,29 +323,26 @@ static void vc_info(struct atm_vcc *vcc,
 	    atomic_read(&vcc->sk->sk_rmem_alloc), vcc->sk->sk_rcvbuf);
 }
 
-
-static void svc_info(struct atm_vcc *vcc,char *buf)
+static void svc_info(struct seq_file *seq, struct atm_vcc *vcc)
 {
-	char *here;
-	int i;
-
 	if (!vcc->dev)
-		sprintf(buf,sizeof(void *) == 4 ? "N/A@%p%10s" : "N/A@%p%2s",
-		    vcc,"");
-	else sprintf(buf,"%3d %3d %5d         ",vcc->dev->number,vcc->vpi,
-		    vcc->vci);
-	here = strchr(buf,0);
-	here += sprintf(here,"%-10s ",vcc_state(vcc));
-	here += sprintf(here,"%s%s",vcc->remote.sas_addr.pub,
+		seq_printf(seq, sizeof(void *) == 4 ?
+			   "N/A@%p%10s" : "N/A@%p%2s", vcc, "");
+	else
+		seq_printf(seq, "%3d %3d %5d         ",
+			   vcc->dev->number, vcc->vpi, vcc->vci);
+	seq_printf(seq, "%-10s ", vcc_state(vcc));
+	seq_printf(seq, "%s%s", vcc->remote.sas_addr.pub,
 	    *vcc->remote.sas_addr.pub && *vcc->remote.sas_addr.prv ? "+" : "");
-	if (*vcc->remote.sas_addr.prv)
+	if (*vcc->remote.sas_addr.prv) {
+		int i;
+
 		for (i = 0; i < ATM_ESA_LEN; i++)
-			here += sprintf(here,"%02x",
-			    vcc->remote.sas_addr.prv[i]);
-	strcat(here,"\n");
+			seq_printf(seq, "%02x", vcc->remote.sas_addr.prv[i]);
+	}
+	seq_putc(seq, '\n');
 }
 
-
 #if defined(CONFIG_ATM_LANE) || defined(CONFIG_ATM_LANE_MODULE)
 
 static char*
@@ -493,31 +490,41 @@ static int atm_vc_info(loff_t pos,char *
 	return 0;
 }
 
-
-static int atm_svc_info(loff_t pos,char *buf)
+static int svc_seq_show(struct seq_file *seq, void *v)
 {
-	struct hlist_node *node;
-	struct sock *s;
-	struct atm_vcc *vcc;
-	int left;
+	static char atm_svc_banner[] = 
+		"Itf VPI VCI           State      Remote\n";
 
-	if (!pos)
-		return sprintf(buf,"Itf VPI VCI           State      Remote\n");
-	left = pos-1;
-	read_lock(&vcc_sklist_lock);
-	sk_for_each(s, node, &vcc_sklist) {
-		vcc = atm_sk(s);
-		if (vcc->sk->sk_family == PF_ATMSVC && !left--) {
-			svc_info(vcc,buf);
-			read_unlock(&vcc_sklist_lock);
-			return strlen(buf);
-		}
-	}
-	read_unlock(&vcc_sklist_lock);
+	if (v == (void *)1)
+		seq_puts(seq, atm_svc_banner);
+	else {
+		struct vcc_state *state = seq->private;
+		struct atm_vcc *vcc = atm_sk(state->sk);
 
+		svc_info(seq, vcc);
+	}
 	return 0;
 }
 
+static struct seq_operations svc_seq_ops = {
+	.start	= vcc_seq_start,
+	.next	= vcc_seq_next,
+	.stop	= vcc_seq_stop,
+	.show	= svc_seq_show,
+};
+
+static int svc_seq_open(struct inode *inode, struct file *file)
+{
+	return __vcc_seq_open(inode, file, PF_ATMSVC, &svc_seq_ops);
+}
+
+static struct file_operations svc_seq_fops = {
+	.open		= svc_seq_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= vcc_seq_release,
+};
+
 #if defined(CONFIG_ATM_CLIP) || defined(CONFIG_ATM_CLIP_MODULE)
 static int atm_arp_info(loff_t pos,char *buf)
 {
@@ -770,7 +777,7 @@ int __init atm_proc_init(void)
 		return -ENOMEM;
 	CREATE_SEQ_ENTRY(devices);
 	CREATE_SEQ_ENTRY(pvc);
-	CREATE_ENTRY(svc);
+	CREATE_SEQ_ENTRY(svc);
 	CREATE_ENTRY(vc);
 #if defined(CONFIG_ATM_CLIP) || defined(CONFIG_ATM_CLIP_MODULE)
 	CREATE_ENTRY(arp);



[ATM]: seq_file for /proc/net/atm (vc) [5/8] (from romieu@fr.zoreil.com)

seq_file support for /proc/net/atm/vc:

Same comments as for pvc and svc.

Extra Chas's suggestion applied since last version:
- atm_vc_xxx renamed to vcc_xxx.


 net/atm/proc.c |   90 ++++++++++++++++++++++++++++++---------------------------
 1 files changed, 48 insertions(+), 42 deletions(-)

diff -puN net/atm/proc.c~atm-proc-seq-vc-conversion net/atm/proc.c
--- linux-2.6.0-test4-bk8/net/atm/proc.c~atm-proc-seq-vc-conversion	Sat Sep  6 23:30:55 2003
+++ linux-2.6.0-test4-bk8-fr/net/atm/proc.c	Sat Sep  6 23:30:55 2003
@@ -298,29 +298,27 @@ static const char *vcc_state(struct atm_
 	return map[ATM_VF2VS(vcc->flags)];
 }
 
-
-static void vc_info(struct atm_vcc *vcc,char *buf)
+static void vcc_info(struct seq_file *seq, struct atm_vcc *vcc)
 {
-	char *here;
-
-	here = buf+sprintf(buf,"%p ",vcc);
-	if (!vcc->dev) here += sprintf(here,"Unassigned    ");
-	else here += sprintf(here,"%3d %3d %5d ",vcc->dev->number,vcc->vpi,
-		    vcc->vci);
+	seq_printf(seq, "%p ", vcc);
+	if (!vcc->dev)
+		seq_printf(seq, "Unassigned    ");
+	else 
+		seq_printf(seq, "%3d %3d %5d ", vcc->dev->number, vcc->vpi,
+			vcc->vci);
 	switch (vcc->sk->sk_family) {
 		case AF_ATMPVC:
-			here += sprintf(here,"PVC");
+			seq_printf(seq, "PVC");
 			break;
 		case AF_ATMSVC:
-			here += sprintf(here,"SVC");
+			seq_printf(seq, "SVC");
 			break;
 		default:
-			here += sprintf(here, "%3d", vcc->sk->sk_family);
+			seq_printf(seq, "%3d", vcc->sk->sk_family);
 	}
-	here += sprintf(here," %04lx  %5d %7d/%7d %7d/%7d\n",vcc->flags,
-	    vcc->sk->sk_err,
-	    atomic_read(&vcc->sk->sk_wmem_alloc), vcc->sk->sk_sndbuf,
-	    atomic_read(&vcc->sk->sk_rmem_alloc), vcc->sk->sk_rcvbuf);
+	seq_printf(seq, " %04lx  %5d %7d/%7d %7d/%7d\n", vcc->flags, vcc->sk->sk_err,
+		atomic_read(&vcc->sk->sk_wmem_alloc),vcc->sk->sk_sndbuf,
+		atomic_read(&vcc->sk->sk_rmem_alloc),vcc->sk->sk_rcvbuf);
 }
 
 static void svc_info(struct seq_file *seq, struct atm_vcc *vcc)
@@ -464,31 +462,39 @@ static struct file_operations pvc_seq_fo
 	.release	= vcc_seq_release,
 };
 
-static int atm_vc_info(loff_t pos,char *buf)
+static int vcc_seq_show(struct seq_file *seq, void *v)
 {
-	struct atm_vcc *vcc;
-	struct hlist_node *node;
-	struct sock *s;
-	int left;
-
-	if (!pos)
-		return sprintf(buf,sizeof(void *) == 4 ? "%-8s%s" : "%-16s%s",
-		    "Address"," Itf VPI VCI   Fam Flags Reply Send buffer"
-		    "     Recv buffer\n");
-	left = pos-1;
-	read_lock(&vcc_sklist_lock);
-	sk_for_each(s, node, &vcc_sklist) {
-		vcc = atm_sk(s);
-		if (!left--) {
-			vc_info(vcc,buf);
-			read_unlock(&vcc_sklist_lock);
-			return strlen(buf);
-		}
-	}
-	read_unlock(&vcc_sklist_lock);
-
-	return 0;
+ 	if (v == (void *)1) {
+ 		seq_printf(seq, sizeof(void *) == 4 ? "%-8s%s" : "%-16s%s",
+ 			"Address ", "Itf VPI VCI   Fam Flags Reply "
+ 			"Send buffer     Recv buffer\n");
+ 	} else {
+ 		struct vcc_state *state = seq->private;
+ 		struct atm_vcc *vcc = atm_sk(state->sk);
+  
+ 		vcc_info(seq, vcc);
+ 	}
+  	return 0;
+}
+  
+static struct seq_operations vcc_seq_ops = {
+ 	.start	= vcc_seq_start,
+ 	.next	= vcc_seq_next,
+ 	.stop	= vcc_seq_stop,
+ 	.show	= vcc_seq_show,
+};
+ 
+static int vcc_seq_open(struct inode *inode, struct file *file)
+{
+ 	return __vcc_seq_open(inode, file, 0, &vcc_seq_ops);
 }
+ 
+static struct file_operations vcc_seq_fops = {
+	.open		= vcc_seq_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= vcc_seq_release,
+};
 
 static int svc_seq_show(struct seq_file *seq, void *v)
 {
@@ -751,7 +757,7 @@ void atm_proc_dev_deregister(struct atm_
     name->owner = THIS_MODULE
 
 static struct proc_dir_entry *devices = NULL, *pvc = NULL,
-		*svc = NULL, *arp = NULL, *lec = NULL, *vc = NULL;
+		*svc = NULL, *arp = NULL, *lec = NULL, *vcc = NULL;
 
 static void atm_proc_cleanup(void)
 {
@@ -765,8 +771,8 @@ static void atm_proc_cleanup(void)
 		remove_proc_entry("arp",atm_proc_root);
 	if (lec)
 		remove_proc_entry("lec",atm_proc_root);
-	if (vc)
-		remove_proc_entry("vc",atm_proc_root);
+	if (vcc)
+		remove_proc_entry("vcc",atm_proc_root);
 	remove_proc_entry("net/atm",NULL);
 }
 
@@ -778,7 +784,7 @@ int __init atm_proc_init(void)
 	CREATE_SEQ_ENTRY(devices);
 	CREATE_SEQ_ENTRY(pvc);
 	CREATE_SEQ_ENTRY(svc);
-	CREATE_ENTRY(vc);
+	CREATE_SEQ_ENTRY(vcc);
 #if defined(CONFIG_ATM_CLIP) || defined(CONFIG_ATM_CLIP_MODULE)
 	CREATE_ENTRY(arp);
 #endif

_




[ATM]: seq_file for /proc/net/atm (arp) [6/8] (from romieu@fr.zoreil.com)

seq_file support for /proc/net/atm/arp:
- svc_addr/atmarp_info(): seq_printf/seq_putc replace sprintf and friends;
- arp_getidx/arp_vcc_walk() take care of the usual seq_file cursor
  positionning: they both return NULL until the cursor has reached its
  position. struct atm_arp_state is updated accordingly;
- arp_seq_{stop/start} are responsible for clip_tbl_hook (un)locking;
- module refcounting is done in arp_seq_open()/arp_seq_release();
- atm_lec_info() is removed.

Chas's suggestions applied since last version:
- atm_arp_xxx renamed to arp_xxx;
- atm_seq_arp_fops renamed to arp_seq_fops.

Chas didn't ask for it but I renamed arp_vc_walk to arp_vcc_walk.


 net/atm/proc.c |  269 +++++++++++++++++++++++++++++++++++++++------------------
 1 files changed, 185 insertions(+), 84 deletions(-)

diff -puN net/atm/proc.c~atm-proc-seq-arp-conversion net/atm/proc.c
--- linux-2.6.0-test4-bk8/net/atm/proc.c~atm-proc-seq-arp-conversion	Sat Sep  6 23:31:55 2003
+++ linux-2.6.0-test4-bk8-fr/net/atm/proc.c	Sat Sep  6 23:31:55 2003
@@ -91,75 +91,67 @@ static void atm_dev_info(struct seq_file
 
 #if defined(CONFIG_ATM_CLIP) || defined(CONFIG_ATM_CLIP_MODULE)
 
-
-static int svc_addr(char *buf,struct sockaddr_atmsvc *addr)
+static void svc_addr(struct seq_file *seq, struct sockaddr_atmsvc *addr)
 {
 	static int code[] = { 1,2,10,6,1,0 };
 	static int e164[] = { 1,8,4,6,1,0 };
-	int *fields;
-	int len,i,j,pos;
 
-	len = 0;
 	if (*addr->sas_addr.pub) {
-		strcpy(buf,addr->sas_addr.pub);
-		len = strlen(addr->sas_addr.pub);
-		buf += len;
-		if (*addr->sas_addr.prv) {
-			*buf++ = '+';
-			len++;
-		}
+		seq_printf(seq, "%s", addr->sas_addr.pub);
+		if (*addr->sas_addr.prv)
+			seq_putc(seq, '+');
+	} else if (!*addr->sas_addr.prv) {
+		seq_printf(seq, "%s", "(none)");
+		return;
 	}
-	else if (!*addr->sas_addr.prv) {
-			strcpy(buf,"(none)");
-			return strlen(buf);
-		}
 	if (*addr->sas_addr.prv) {
-		len += 44;
-		pos = 0;
-		fields = *addr->sas_addr.prv == ATM_AFI_E164 ? e164 : code;
+		unsigned char *prv = addr->sas_addr.prv;
+		int *fields;
+		int i, j;
+
+		fields = *prv == ATM_AFI_E164 ? e164 : code;
 		for (i = 0; fields[i]; i++) {
-			for (j = fields[i]; j; j--) {
-				sprintf(buf,"%02X",addr->sas_addr.prv[pos++]);
-				buf += 2;
-			}
-			if (fields[i+1]) *buf++ = '.';
+			for (j = fields[i]; j; j--)
+				seq_printf(seq, "%02X", *prv++);
+			if (fields[i+1])
+				seq_putc(seq, '.');
 		}
 	}
-	return len;
 }
 
-
-static void atmarp_info(struct net_device *dev,struct atmarp_entry *entry,
-    struct clip_vcc *clip_vcc,char *buf)
+static void atmarp_info(struct seq_file *seq, struct net_device *dev,
+			struct atmarp_entry *entry, struct clip_vcc *clip_vcc)
 {
-	unsigned char *ip;
-	int svc,off,ip_len;
+	char buf[17];
+	int svc, off;
 
 	svc = !clip_vcc || clip_vcc->vcc->sk->sk_family == AF_ATMSVC;
-	off = sprintf(buf,"%-6s%-4s%-4s%5ld ",dev->name,svc ? "SVC" : "PVC",
+	seq_printf(seq, "%-6s%-4s%-4s%5ld ", dev->name, svc ? "SVC" : "PVC",
 	    !clip_vcc || clip_vcc->encap ? "LLC" : "NULL",
-	    (jiffies-(clip_vcc ? clip_vcc->last_use : entry->neigh->used))/
-	    HZ);
-	ip = (unsigned char *) &entry->ip;
-	ip_len = sprintf(buf+off,"%d.%d.%d.%d",ip[0],ip[1],ip[2],ip[3]);
-	off += ip_len;
-	while (ip_len++ < 16) buf[off++] = ' ';
-	if (!clip_vcc)
+	    (jiffies-(clip_vcc ? clip_vcc->last_use : entry->neigh->used))/HZ);
+
+	off = snprintf(buf, sizeof(buf) - 1, "%d.%d.%d.%d", NIPQUAD(entry->ip));
+	while (off < 16)
+		buf[off++] = ' ';
+	buf[off] = '\0';
+	seq_printf(seq, "%s", buf);
+
+	if (!clip_vcc) {
 		if (time_before(jiffies, entry->expires))
-			strcpy(buf+off,"(resolving)\n");
-		else sprintf(buf+off,"(expired, ref %d)\n",
-			    atomic_read(&entry->neigh->refcnt));
-	else if (!svc)
-			sprintf(buf+off,"%d.%d.%d\n",clip_vcc->vcc->dev->number,
-			    clip_vcc->vcc->vpi,clip_vcc->vcc->vci);
-		else {
-			off += svc_addr(buf+off,&clip_vcc->vcc->remote);
-			strcpy(buf+off,"\n");
-		}
+			seq_printf(seq, "(resolving)\n");
+		else
+			seq_printf(seq, "(expired, ref %d)\n",
+				   atomic_read(&entry->neigh->refcnt));
+	} else if (!svc) {
+		seq_printf(seq, "%d.%d.%d\n", clip_vcc->vcc->dev->number,
+			   clip_vcc->vcc->vpi, clip_vcc->vcc->vci);
+	} else {
+		svc_addr(seq, &clip_vcc->vcc->remote);
+		seq_putc(seq, '\n');
+	}
 }
 
-
-#endif
+#endif /* CONFIG_ATM_CLIP */
 
 struct vcc_state {
 	struct sock *sk;
@@ -532,45 +524,154 @@ static struct file_operations svc_seq_fo
 };
 
 #if defined(CONFIG_ATM_CLIP) || defined(CONFIG_ATM_CLIP_MODULE)
-static int atm_arp_info(loff_t pos,char *buf)
+
+struct arp_state {
+	int bucket;
+  	struct neighbour *n;
+	struct clip_vcc *vcc;
+};
+  
+static void *arp_vcc_walk(struct arp_state *state,
+			  struct atmarp_entry *e, loff_t *l)
 {
-	struct neighbour *n;
-	int i,count;
+	struct clip_vcc *vcc = state->vcc;
 
-	if (!pos) {
-		return sprintf(buf,"IPitf TypeEncp Idle IP address      "
-		    "ATM address\n");
+	if (!vcc)
+		vcc = e->vccs;
+	if (vcc == (void *)1) {
+		vcc = e->vccs;
+		--*l;
+  	}
+	for (; vcc; vcc = vcc->next) {
+		if (--*l < 0)
+			break;
 	}
-	if (!try_atm_clip_ops())
-		return 0;
-	count = pos;
+	state->vcc = vcc;
+	return (*l < 0) ? state : NULL;
+}
+  
+static void *arp_get_idx(struct arp_state *state, loff_t l)
+{
+	void *v = NULL;
+
+	for (; state->bucket <= NEIGH_HASHMASK; state->bucket++) {
+		for (; state->n; state->n = state->n->next) {
+			v = arp_vcc_walk(state, NEIGH2ENTRY(state->n), &l);
+			if (v)
+				goto done;
+  		}
+		state->n = clip_tbl_hook->hash_buckets[state->bucket + 1];
+	}
+done:
+	return v;
+}
+
+static void *arp_seq_start(struct seq_file *seq, loff_t *pos)
+{
+	struct arp_state *state = seq->private;
+	void *ret = (void *)1;
+
+	if (!clip_tbl_hook) {
+		state->bucket = -1;
+		goto out;
+	}
+
 	read_lock_bh(&clip_tbl_hook->lock);
-	for (i = 0; i <= NEIGH_HASHMASK; i++)
-		for (n = clip_tbl_hook->hash_buckets[i]; n; n = n->next) {
-			struct atmarp_entry *entry = NEIGH2ENTRY(n);
-			struct clip_vcc *vcc;
-
-			if (!entry->vccs) {
-				if (--count) continue;
-				atmarp_info(n->dev,entry,NULL,buf);
-				read_unlock_bh(&clip_tbl_hook->lock);
-				module_put(atm_clip_ops->owner);
-				return strlen(buf);
-			}
-			for (vcc = entry->vccs; vcc;
-			    vcc = vcc->next) {
-				if (--count) continue;
-				atmarp_info(n->dev,entry,vcc,buf);
-				read_unlock_bh(&clip_tbl_hook->lock);
-				module_put(atm_clip_ops->owner);
-				return strlen(buf);
-			}
-		}
-	read_unlock_bh(&clip_tbl_hook->lock);
+	state->bucket = 0;
+	state->n = clip_tbl_hook->hash_buckets[0];
+	state->vcc = (void *)1;
+	if (*pos)
+		ret = arp_get_idx(state, *pos);
+out:
+	return ret;
+}
+
+static void arp_seq_stop(struct seq_file *seq, void *v)
+{
+	struct arp_state *state = seq->private;
+
+	if (state->bucket != -1)
+		read_unlock_bh(&clip_tbl_hook->lock);
+}
+
+static void *arp_seq_next(struct seq_file *seq, void *v, loff_t *pos)
+{
+	struct arp_state *state = seq->private;
+
+	v = arp_get_idx(state, 1);
+	*pos += !!PTR_ERR(v);
+	return v;
+}
+
+static int arp_seq_show(struct seq_file *seq, void *v)
+{
+	static char atm_arp_banner[] = 
+		"IPitf TypeEncp Idle IP address      ATM address\n";
+
+	if (v == (void *)1)
+		seq_puts(seq, atm_arp_banner);
+	else {
+		struct arp_state *state = seq->private;
+		struct neighbour *n = state->n;	
+		struct clip_vcc *vcc = state->vcc;
+
+		atmarp_info(seq, n->dev, NEIGH2ENTRY(n), vcc);
+	}
+  	return 0;
+}
+
+static struct seq_operations arp_seq_ops = {
+	.start	= arp_seq_start,
+	.next	= arp_seq_next,
+	.stop	= arp_seq_stop,
+	.show	= arp_seq_show,
+};
+
+static int arp_seq_open(struct inode *inode, struct file *file)
+{
+	struct arp_state *state;
+	struct seq_file *seq;
+	int rc = -EAGAIN;
+
+	if (!try_atm_clip_ops())
+		goto out;
+
+	state = kmalloc(sizeof(*state), GFP_KERNEL);
+	if (!state) {
+		rc = -ENOMEM;
+		goto out_put;
+	}
+
+	rc = seq_open(file, &arp_seq_ops);
+	if (rc)
+		goto out_kfree;
+
+	seq = file->private_data;
+	seq->private = state;
+out:
+	return rc;
+
+out_put:
 	module_put(atm_clip_ops->owner);
-	return 0;
+out_kfree:
+	kfree(state);
+	goto out;
 }
-#endif
+
+static int arp_seq_release(struct inode *inode, struct file *file)
+{
+	module_put(atm_clip_ops->owner);
+	return seq_release_private(inode, file);
+}
+
+static struct file_operations arp_seq_fops = {
+	.open		= arp_seq_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= arp_seq_release,
+};
+
+#endif /* CONFIG_ATM_CLIP */
 
 #if defined(CONFIG_ATM_LANE) || defined(CONFIG_ATM_LANE_MODULE)
 static int atm_lec_info(loff_t pos,char *buf)
@@ -786,7 +887,7 @@ int __init atm_proc_init(void)
 	CREATE_SEQ_ENTRY(svc);
 	CREATE_SEQ_ENTRY(vcc);
 #if defined(CONFIG_ATM_CLIP) || defined(CONFIG_ATM_CLIP_MODULE)
-	CREATE_ENTRY(arp);
+	CREATE_SEQ_ENTRY(arp);
 #endif
 #if defined(CONFIG_ATM_LANE) || defined(CONFIG_ATM_LANE_MODULE)
 	CREATE_ENTRY(lec);




[ATM] seq_file conversion of /proc/net/atm [7/8]

seq_file support for /proc/net/atm/lec:
- lec_info(): seq_printf/seq_putc replaces sprintf;
- traversal of the lec structure needs to walk:
  -> the lec interfaces
     -> the tables of arp tables(lec_arp_tables);
        -> the arp tables themselves
     -> the misc tables (lec_arp_empty_ones/lec_no_forward/mcast_fwds)

  Sum up of the call tree:
  atm_lec_seq_start()/atm_lec_seq_next()
  -> atm_lec_get_idx()
     -> atm_lec_itf_walk() (responsible for dev_lec/dev_put handling)
        -> atm_lec_priv_walk() (responsible for lec_priv locking)
           -> atm_lec_arp_walk()
              -> atm_lec_tbl_walk()
           -> atm_lec_misc_walk()
              -> atm_lec_tbl_walk()

  Each of the dedicated functions follows the same convention: return NULL
  as long as the seq_file cursor hasn't been digested (i.e. until < 0).
  Locking is only done when an entry (i.e. a lec_arp_table) is referenced.
  atm_lec_seq_stop()/atm_lec_itf_walk()/atm_lec_priv_walk() are responsible
  for getting this point right.
- module refcounting is done in atm_lec_seq_open()/atm_lec_seq_release();
- atm_lec_info() is removed.

Chas's suggestions applied since last version:
- atm_seq_lec_fops renamed to lec_seq_fops;
- change in state handling: it wasn't correctly set to its reset value
  after a complete interface walk;
- lec_arp_get_status_string() bugfix.


 net/atm/proc.c |  342 +++++++++++++++++++++++++++++++++++++++------------------
 1 files changed, 236 insertions(+), 106 deletions(-)

diff -puN net/atm/proc.c~atm-proc-seq-lec-conversion net/atm/proc.c
--- linux-2.6.0-test4-bk8/net/atm/proc.c~atm-proc-seq-lec-conversion	Sat Sep  6 23:34:01 2003
+++ linux-2.6.0-test4-bk8-fr/net/atm/proc.c	Sun Sep  7 00:33:49 2003
@@ -335,54 +335,46 @@ static void svc_info(struct seq_file *se
 
 #if defined(CONFIG_ATM_LANE) || defined(CONFIG_ATM_LANE_MODULE)
 
-static char*
-lec_arp_get_status_string(unsigned char status)
+static char* lec_arp_get_status_string(unsigned char status)
 {
-  switch(status) {
-  case ESI_UNKNOWN:
-    return "ESI_UNKNOWN       ";
-  case ESI_ARP_PENDING:
-    return "ESI_ARP_PENDING   ";
-  case ESI_VC_PENDING:
-    return "ESI_VC_PENDING    ";
-  case ESI_FLUSH_PENDING:
-    return "ESI_FLUSH_PENDING ";
-  case ESI_FORWARD_DIRECT:
-    return "ESI_FORWARD_DIRECT";
-  default:
-    return "<Unknown>         ";
-  }
-}
-
-static void 
-lec_info(struct lec_arp_table *entry, char *buf)
-{
-        int j, offset=0;
-
-        for(j=0;j<ETH_ALEN;j++) {
-                offset+=sprintf(buf+offset,"%2.2x",0xff&entry->mac_addr[j]);
+	static char *lec_arp_status_string[] = {
+		"ESI_UNKNOWN       ",
+		"ESI_ARP_PENDING   ",
+		"ESI_VC_PENDING    ",
+		"<Unknown>         ",
+		"ESI_FLUSH_PENDING ",
+		"ESI_FORWARD_DIRECT",
+		"<Undefined>"
+	};
+
+	if (status > ESI_FORWARD_DIRECT)
+		status = ESI_FORWARD_DIRECT + 1;
+	return lec_arp_status_string[status];
+}
+
+static void lec_info(struct seq_file *seq, struct lec_arp_table *entry)
+{
+	int i;
+
+	for (i = 0; i < ETH_ALEN; i++)
+		seq_printf(seq, "%2.2x", entry->mac_addr[i] & 0xff);
+	seq_printf(seq, " ");
+	for (i = 0; i < ATM_ESA_LEN; i++)
+		seq_printf(seq, "%2.2x", entry->atm_addr[i] & 0xff);
+	seq_printf(seq, " %s %4.4x", lec_arp_get_status_string(entry->status),
+		   entry->flags & 0xffff);
+	if (entry->vcc)
+		seq_printf(seq, "%3d %3d ", entry->vcc->vpi, entry->vcc->vci);
+	else
+	        seq_printf(seq, "        ");
+	if (entry->recv_vcc) {
+		seq_printf(seq, "     %3d %3d", entry->recv_vcc->vpi,
+			   entry->recv_vcc->vci);
         }
-        offset+=sprintf(buf+offset, " ");
-        for(j=0;j<ATM_ESA_LEN;j++) {
-                offset+=sprintf(buf+offset,"%2.2x",0xff&entry->atm_addr[j]);
-        }
-        offset+=sprintf(buf+offset, " %s %4.4x",
-                        lec_arp_get_status_string(entry->status),
-                        entry->flags&0xffff);
-        if (entry->vcc) {
-                offset+=sprintf(buf+offset, "%3d %3d ", entry->vcc->vpi, 
-                                entry->vcc->vci);                
-        } else
-                offset+=sprintf(buf+offset, "        ");
-        if (entry->recv_vcc) {
-                offset+=sprintf(buf+offset, "     %3d %3d", 
-                                entry->recv_vcc->vpi, entry->recv_vcc->vci);
-        }
-
-        sprintf(buf+offset,"\n");
+        seq_putc(seq, '\n');
 }
 
-#endif
+#endif /* CONFIG_ATM_LANE */
 
 static int atm_dev_seq_show(struct seq_file *seq, void *v)
 {
@@ -674,78 +666,216 @@ static struct file_operations arp_seq_fo
 #endif /* CONFIG_ATM_CLIP */
 
 #if defined(CONFIG_ATM_LANE) || defined(CONFIG_ATM_LANE_MODULE)
-static int atm_lec_info(loff_t pos,char *buf)
-{
+
+struct lec_state {
 	unsigned long flags;
-	struct lec_priv *priv;
+	struct lec_priv *locked;
 	struct lec_arp_table *entry;
-	int i, count, d, e;
 	struct net_device *dev;
+	int itf;
+	int arp_table;
+	int misc_table;
+};
 
-	if (!pos) {
-		return sprintf(buf,"Itf  MAC          ATM destination"
-		    "                          Status            Flags "
-		    "VPI/VCI Recv VPI/VCI\n");
+static void *lec_tbl_walk(struct lec_state *state, struct lec_arp_table *tbl,
+			  loff_t *l)
+{
+	struct lec_arp_table *e = state->entry;
+
+	if (!e)
+		e = tbl;
+	if (e == (void *)1) {
+		e = tbl;
+		--*l;
 	}
-	if (!try_atm_lane_ops())
-		return 0; /* the lane module is not there yet */
+	for (; e; e = e->next) {
+		if (--*l < 0)
+			break;
+	}
+	state->entry = e;
+	return (*l < 0) ? state : NULL;
+}
+
+static void *lec_arp_walk(struct lec_state *state, loff_t *l,
+			      struct lec_priv *priv)
+{
+	void *v = NULL;
+	int p;
 
-	count = pos;
-	for(d = 0; d < MAX_LEC_ITF; d++) {
-		dev = atm_lane_ops->get_lec(d);
-		if (!dev || !(priv = (struct lec_priv *) dev->priv))
-			continue;
-		spin_lock_irqsave(&priv->lec_arp_lock, flags);
-		for(i = 0; i < LEC_ARP_TABLE_SIZE; i++) {
-			for(entry = priv->lec_arp_tables[i]; entry; entry = entry->next) {
-				if (--count)
-					continue;
-				e = sprintf(buf,"%s ", dev->name);
-				lec_info(entry, buf+e);
-				spin_unlock_irqrestore(&priv->lec_arp_lock, flags);
-				dev_put(dev);
-				module_put(atm_lane_ops->owner);
-				return strlen(buf);
-			}
-		}
-		for(entry = priv->lec_arp_empty_ones; entry; entry = entry->next) {
-			if (--count)
-				continue;
-			e = sprintf(buf,"%s ", dev->name);
-			lec_info(entry, buf+e);
-			spin_unlock_irqrestore(&priv->lec_arp_lock, flags);
-			dev_put(dev);
-			module_put(atm_lane_ops->owner);
-			return strlen(buf);
-		}
-		for(entry = priv->lec_no_forward; entry; entry=entry->next) {
-			if (--count)
-				continue;
-			e = sprintf(buf,"%s ", dev->name);
-			lec_info(entry, buf+e);
-			spin_unlock_irqrestore(&priv->lec_arp_lock, flags);
-			dev_put(dev);
-			module_put(atm_lane_ops->owner);
-			return strlen(buf);
-		}
-		for(entry = priv->mcast_fwds; entry; entry = entry->next) {
-			if (--count)
-				continue;
-			e = sprintf(buf,"%s ", dev->name);
-			lec_info(entry, buf+e);
-			spin_unlock_irqrestore(&priv->lec_arp_lock, flags);
-			dev_put(dev);
-			module_put(atm_lane_ops->owner);
-			return strlen(buf);
-		}
-		spin_unlock_irqrestore(&priv->lec_arp_lock, flags);
+	for (p = state->arp_table; p < LEC_ARP_TABLE_SIZE; p++) {
+		v = lec_tbl_walk(state, priv->lec_arp_tables[p], l);
+		if (v)
+			break;
+	}
+	state->arp_table = p;
+	return v;
+}
+
+static void *lec_misc_walk(struct lec_state *state, loff_t *l,
+			   struct lec_priv *priv)
+{
+	struct lec_arp_table *lec_misc_tables[] = {
+		priv->lec_arp_empty_ones,
+		priv->lec_no_forward,
+		priv->mcast_fwds
+	};
+	void *v = NULL;
+	int q;
+
+	for (q = state->misc_table; q < ARRAY_SIZE(lec_misc_tables); q++) {
+		v = lec_tbl_walk(state, lec_misc_tables[q], l);
+		if (v)
+			break;
+	}
+	state->misc_table = q;
+	return v;
+}
+
+static void *lec_priv_walk(struct lec_state *state, loff_t *l,
+			   struct lec_priv *priv)
+{
+	if (!state->locked) {
+		state->locked = priv;
+		spin_lock_irqsave(&priv->lec_arp_lock, state->flags);
+	}
+	if (!lec_arp_walk(state, l, priv) &&
+	    !lec_misc_walk(state, l, priv)) {
+		spin_unlock_irqrestore(&priv->lec_arp_lock, state->flags);
+		state->locked = NULL;
+		/* Partial state reset for the next time we get called */
+		state->arp_table = state->misc_table = 0;
+	}
+	return state->locked;
+}
+
+static void *lec_itf_walk(struct lec_state *state, loff_t *l)
+{
+	struct net_device *dev;
+	void *v;
+
+	dev = state->dev ? state->dev : atm_lane_ops->get_lec(state->itf);
+	v = (dev && dev->priv) ? lec_priv_walk(state, l, dev->priv) : NULL;
+	if (!v && dev) {
 		dev_put(dev);
+		/* Partial state reset for the next time we get called */
+		dev = NULL;
+	}
+	state->dev = dev;
+	return v;
+}
+
+static void *lec_get_idx(struct lec_state *state, loff_t l)
+{
+	void *v = NULL;
+
+	for (; state->itf < MAX_LEC_ITF; state->itf++) {
+		v = lec_itf_walk(state, &l);
+		if (v)
+			break;
+	}
+	return v; 
+}
+
+static void *lec_seq_start(struct seq_file *seq, loff_t *pos)
+{
+	struct lec_state *state = seq->private;
+
+	state->itf = 0;
+	state->dev = NULL;
+	state->locked = NULL;
+	state->arp_table = 0;
+	state->misc_table = 0;
+	state->entry = (void *)1;
+
+	return *pos ? lec_get_idx(state, *pos) : (void*)1;
+}
+
+static void lec_seq_stop(struct seq_file *seq, void *v)
+{
+	struct lec_state *state = seq->private;
+
+	if (state->dev) {
+		spin_unlock_irqrestore(&state->locked->lec_arp_lock,
+				       state->flags);
+		dev_put(state->dev);
+	}
+}
+
+static void *lec_seq_next(struct seq_file *seq, void *v, loff_t *pos)
+{
+	struct lec_state *state = seq->private;
+
+	v = lec_get_idx(state, 1);
+	*pos += !!PTR_ERR(v);
+	return v;
+}
+
+static int lec_seq_show(struct seq_file *seq, void *v)
+{
+	static char lec_banner[] = "Itf  MAC          ATM destination" 
+		"                          Status            Flags "
+		"VPI/VCI Recv VPI/VCI\n";
+
+	if (v == (void *)1)
+		seq_puts(seq, lec_banner);
+	else {
+		struct lec_state *state = seq->private;
+		struct net_device *dev = state->dev; 
+
+		seq_printf(seq, "%s ", dev->name);
+		lec_info(seq, state->entry);
 	}
-	module_put(atm_lane_ops->owner);
 	return 0;
 }
-#endif
 
+static struct seq_operations lec_seq_ops = {
+	.start	= lec_seq_start,
+	.next	= lec_seq_next,
+	.stop	= lec_seq_stop,
+	.show	= lec_seq_show,
+};
+
+static int lec_seq_open(struct inode *inode, struct file *file)
+{
+	struct lec_state *state;
+	struct seq_file *seq;
+	int rc = -EAGAIN;
+
+	if (!try_atm_lane_ops())
+		goto out;
+
+	state = kmalloc(sizeof(*state), GFP_KERNEL);
+	if (!state) {
+		rc = -ENOMEM;
+		goto out;
+	}
+
+	rc = seq_open(file, &lec_seq_ops);
+	if (rc)
+		goto out_kfree;
+	seq = file->private_data;
+	seq->private = state;
+out:
+	return rc;
+out_kfree:
+	kfree(state);
+	goto out;
+}
+
+static int lec_seq_release(struct inode *inode, struct file *file)
+{
+	module_put(atm_lane_ops->owner);
+	return seq_release_private(inode, file);
+}
+
+static struct file_operations lec_seq_fops = {
+	.open		= lec_seq_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= lec_seq_release,
+};
+
+#endif /* CONFIG_ATM_LANE */
 
 static ssize_t proc_dev_atm_read(struct file *file,char *buf,size_t count,
     loff_t *pos)
@@ -890,7 +1020,7 @@ int __init atm_proc_init(void)
 	CREATE_SEQ_ENTRY(arp);
 #endif
 #if defined(CONFIG_ATM_LANE) || defined(CONFIG_ATM_LANE_MODULE)
-	CREATE_ENTRY(lec);
+	CREATE_SEQ_ENTRY(lec);
 #endif
 	return 0;
 


[ATM]: seq_file conversion of /proc/net/atm [8/8] (from romieu@fr.zoreil.com)

- introduction of the struct array 'atm_proc_ents':
  - removal of code duplication in atm_proc_cleanup();
  - removal of code duplication in atm_proc_init();
  - removal of the macros CREATE_SEQ_ENTRY() and CREATE_ENTRY();
  - /proc/net/atm/vcc returns to /proc/net/atm/vc;
- credits at the top of the file;
- replaced proc_dev_atm_operations by proc_atm_dev_ops;
- atm_proc_dev_register: removal of tasteless "fail0/fail1" labels.


 net/atm/proc.c |  143 +++++++++++++++++++++++++--------------------------------
 1 files changed, 64 insertions(+), 79 deletions(-)

diff -puN net/atm/proc.c~atm-proc-seq-post-conversion-removal net/atm/proc.c
--- linux-2.6.0-test4-bk8/net/atm/proc.c~atm-proc-seq-post-conversion-removal	Sun Sep  7 00:36:05 2003
+++ linux-2.6.0-test4-bk8-fr/net/atm/proc.c	Sun Sep  7 00:36:05 2003
@@ -1,21 +1,13 @@
-/* net/atm/proc.c - ATM /proc interface */
-
-/* Written 1995-2000 by Werner Almesberger, EPFL LRC/ICA */
-
-/*
- * The mechanism used here isn't designed for speed but rather for convenience
- * of implementation. We only return one entry per read system call, so we can
- * be reasonably sure not to overrun the page and race conditions may lead to
- * the addition or omission of some lines but never to any corruption of a
- * line's internal structure.
+/* net/atm/proc.c - ATM /proc interface
+ *
+ * Written 1995-2000 by Werner Almesberger, EPFL LRC/ICA
  *
- * Making the whole thing slightly more efficient is left as an exercise to the
- * reader. (Suggestions: wrapper which loops to get several entries per system
- * call; or make --left slightly more clever to avoid O(n^2) characteristics.)
- * I find it fast enough on my unloaded 266 MHz Pentium 2 :-)
+ * seq_file api usage by romieu@fr.zoreil.com
+ *
+ * Evaluating the efficiency of the whole thing if left as an exercise to
+ * the reader.
  */
 
-
 #include <linux/config.h>
 #include <linux/module.h> /* for EXPORT_SYMBOL */
 #include <linux/string.h>
@@ -52,19 +44,12 @@
 
 static ssize_t proc_dev_atm_read(struct file *file,char *buf,size_t count,
     loff_t *pos);
-static ssize_t proc_spec_atm_read(struct file *file,char *buf,size_t count,
-    loff_t *pos);
 
-static struct file_operations proc_dev_atm_operations = {
+static struct file_operations proc_atm_dev_ops = {
 	.owner =	THIS_MODULE,
 	.read =		proc_dev_atm_read,
 };
 
-static struct file_operations proc_spec_atm_operations = {
-	.owner =	THIS_MODULE,
-	.read =		proc_spec_atm_read,
-};
-
 static void add_stats(struct seq_file *seq, const char *aal,
   const struct k_atm_aal_stats *stats)
 {
@@ -903,28 +888,6 @@
 }
 
 
-static ssize_t proc_spec_atm_read(struct file *file,char *buf,size_t count,
-    loff_t *pos)
-{
-	unsigned long page;
-	int length;
-	int (*info)(loff_t,char *);
-	info = PDE(file->f_dentry->d_inode)->data;
-
-	if (count == 0) return 0;
-	page = get_zeroed_page(GFP_KERNEL);
-	if (!page) return -ENOMEM;
-	length = (*info)(*pos,(char *) page);
-	if (length > count) length = -EINVAL;
-	if (length >= 0) {
-		if (copy_to_user(buf,(char *) page,length)) length = -EFAULT;
-		(*pos)++;
-	}
-	free_page(page);
-	return length;
-}
-
-
 struct proc_dir_entry *atm_proc_root;
 EXPORT_SYMBOL(atm_proc_root);
 
@@ -945,19 +908,19 @@
 
 	dev->proc_name = kmalloc(strlen(dev->type) + digits + 2, GFP_KERNEL);
 	if (!dev->proc_name)
-		goto fail1;
+		goto err_out;
 	sprintf(dev->proc_name,"%s:%d",dev->type, dev->number);
 
 	dev->proc_entry = create_proc_entry(dev->proc_name, 0, atm_proc_root);
 	if (!dev->proc_entry)
-		goto fail0;
+		goto err_free_name;
 	dev->proc_entry->data = dev;
-	dev->proc_entry->proc_fops = &proc_dev_atm_operations;
+	dev->proc_entry->proc_fops = &proc_atm_dev_ops;
 	dev->proc_entry->owner = THIS_MODULE;
 	return 0;
-fail0:
+err_free_name:
 	kfree(dev->proc_name);
-fail1:
+err_out:
 	return error;
 }
 
@@ -971,65 +934,65 @@
 	kfree(dev->proc_name);
 }
 
-#define CREATE_SEQ_ENTRY(name) \
-	do { \
-		name = create_proc_entry(#name, S_IRUGO, atm_proc_root); \
-		if (!name) \
-			goto cleanup; \
-		name->proc_fops = & name##_seq_fops; \
-		name->owner = THIS_MODULE; \
-	} while (0)
-
-#define CREATE_ENTRY(name) \
-    name = create_proc_entry(#name,0,atm_proc_root); \
-    if (!name) goto cleanup; \
-    name->data = atm_##name##_info; \
-    name->proc_fops = &proc_spec_atm_operations; \
-    name->owner = THIS_MODULE
-
-static struct proc_dir_entry *devices = NULL, *pvc = NULL,
-		*svc = NULL, *arp = NULL, *lec = NULL, *vcc = NULL;
-
-static void atm_proc_cleanup(void)
-{
-	if (devices)
-		remove_proc_entry("devices",atm_proc_root);
-	if (pvc)
-		remove_proc_entry("pvc",atm_proc_root);
-	if (svc)
-		remove_proc_entry("svc",atm_proc_root);
-	if (arp)
-		remove_proc_entry("arp",atm_proc_root);
-	if (lec)
-		remove_proc_entry("lec",atm_proc_root);
-	if (vcc)
-		remove_proc_entry("vcc",atm_proc_root);
-	remove_proc_entry("net/atm",NULL);
+static struct atm_proc_entry {
+	char *name;
+	struct file_operations *proc_fops;
+	struct proc_dir_entry *dirent;
+} atm_proc_ents[] = {
+	{ .name = "devices",	.proc_fops = &devices_seq_fops },
+	{ .name = "pvc",	.proc_fops = &pvc_seq_fops },
+	{ .name = "svc",	.proc_fops = &svc_seq_fops },
+	{ .name = "vc",		.proc_fops = &vcc_seq_fops },
+#if defined(CONFIG_ATM_CLIP) || defined(CONFIG_ATM_CLIP_MODULE)
+	{ .name = "arp",	.proc_fops = &arp_seq_fops },
+#endif
+#if defined(CONFIG_ATM_LANE) || defined(CONFIG_ATM_LANE_MODULE)
+	{ .name = "lec",	.proc_fops = &lec_seq_fops },
+#endif
+	{ .name = NULL,		.proc_fops = NULL }
+};
+
+static void atm_proc_dirs_remove(void)
+{
+	static struct atm_proc_entry *e;
+
+	for (e = atm_proc_ents; e->name; e++) {
+		if (e->dirent) 
+			remove_proc_entry(e->name, atm_proc_root);
+	}
+	remove_proc_entry("net/atm", NULL);
 }
 
 int __init atm_proc_init(void)
 {
+	static struct atm_proc_entry *e;
+	int ret;
+
 	atm_proc_root = proc_mkdir("net/atm",NULL);
 	if (!atm_proc_root)
-		return -ENOMEM;
-	CREATE_SEQ_ENTRY(devices);
-	CREATE_SEQ_ENTRY(pvc);
-	CREATE_SEQ_ENTRY(svc);
-	CREATE_SEQ_ENTRY(vcc);
-#if defined(CONFIG_ATM_CLIP) || defined(CONFIG_ATM_CLIP_MODULE)
-	CREATE_SEQ_ENTRY(arp);
-#endif
-#if defined(CONFIG_ATM_LANE) || defined(CONFIG_ATM_LANE_MODULE)
-	CREATE_SEQ_ENTRY(lec);
-#endif
-	return 0;
+		goto err_out;
+	for (e = atm_proc_ents; e->name; e++) {
+		struct proc_dir_entry *dirent;
+
+		dirent = create_proc_entry(e->name, S_IRUGO, atm_proc_root);
+		if (!dirent)
+			goto err_out_remove;
+		dirent->proc_fops = e->proc_fops;
+		dirent->owner = THIS_MODULE;
+		e->dirent = dirent;
+	}
+	ret = 0;
+out:
+	return ret;
 
-cleanup:
-	atm_proc_cleanup();
-	return -ENOMEM;
+err_out_remove:
+	atm_proc_dirs_remove();
+err_out:
+	ret = -ENOMEM;
+	goto out;
 }
 
-void atm_proc_exit(void)
+void __exit atm_proc_exit(void)
 {
-	atm_proc_cleanup();
+	atm_proc_dirs_remove();
 }
