From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (2/25) sk98: handle device rename impact on /proc
Date: Mon, 15 Nov 2004 15:21:06 -0800
Message-ID: <20041115152106.22482337@zqx3.pdx.osdl.net>
References: <20041115150910.0f3b8498@zqx3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Mirko Lindner <demon@pro-linux.de>, netdev@oss.sgi.com,
        Christoph
 Hellwig <hch@infradead.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <20041115150910.0f3b8498@zqx3.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Move all /proc related functions into skproc.c and handle device
name changes.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/drivers/net/sk98lin/Makefile b/drivers/net/sk98lin/Makefile
--- a/drivers/net/sk98lin/Makefile	2004-11-15 11:21:41 -08:00
+++ b/drivers/net/sk98lin/Makefile	2004-11-15 11:21:41 -08:00
@@ -27,8 +27,12 @@
 		sktimer.o	\
 		skvpd.o		\
 		skxmac2.o	\
-		skproc.o	\
 		skcsum.o
+
+ifdef CONFIG_PROC_FS
+sk98lin-objs	+= skproc.o
+endif
+
 
 # DBGDEF =  \
 # -DDEBUG
diff -Nru a/drivers/net/sk98lin/h/skdrv2nd.h b/drivers/net/sk98lin/h/skdrv2nd.h
--- a/drivers/net/sk98lin/h/skdrv2nd.h	2004-11-15 11:21:41 -08:00
+++ b/drivers/net/sk98lin/h/skdrv2nd.h	2004-11-15 11:21:41 -08:00
@@ -70,6 +70,19 @@
 extern int		SkDrvLeaveDiagMode(SK_AC *pAc);
 #endif
 
+extern int	SkGeXmit(struct sk_buff *skb, struct SK_NET_DEVICE *dev);
+#ifdef CONFIG_PROC_FS
+extern struct proc_dir_entry *SkGeProcCreate(struct net_device *dev);
+extern void	SkGeProcRemove(struct proc_dir_entry *pe);
+extern void	SkGeProcInit(void);
+extern void	SkGeProcExit(void);
+#else
+#define SkGeProcCreate(dev)	(NULL)
+#define SkGeProcRemove(pe)	do { } while(0)
+#define SkGeProcInit()		do { } while(0)
+#define SkGeProcExit()		do { } while(0)
+#endif
+
 struct s_DrvRlmtMbuf {
 	SK_MBUF		*pNext;		/* Pointer to next RLMT Mbuf. */
 	SK_U8		*pData;		/* Data buffer (virtually contig.). */
@@ -266,11 +279,12 @@
 typedef struct s_DevNet DEV_NET;
 
 struct s_DevNet {
+	SK_AC   	*pAC;
 	int             PortNr;
 	int             NetNr;
 	int             Mtu;
 	int             Up;
-	SK_AC   *pAC;
+	struct proc_dir_entry *proc;
 };  
 
 typedef struct s_TxPort		TX_PORT;
diff -Nru a/drivers/net/sk98lin/skge.c b/drivers/net/sk98lin/skge.c
--- a/drivers/net/sk98lin/skge.c	2004-11-15 11:21:41 -08:00
+++ b/drivers/net/sk98lin/skge.c	2004-11-15 11:21:41 -08:00
@@ -199,7 +199,6 @@
 static SkIsrRetVar	SkGeIsrOnePort(int irq, void *dev_id, struct pt_regs *ptregs);
 static int	SkGeOpen(struct SK_NET_DEVICE *dev);
 static int	SkGeClose(struct SK_NET_DEVICE *dev);
-static int	SkGeXmit(struct sk_buff *skb, struct SK_NET_DEVICE *dev);
 static int	SkGeSetMacAddr(struct SK_NET_DEVICE *dev, void *p);
 static void	SkGeSetRxMode(struct SK_NET_DEVICE *dev);
 static struct	net_device_stats *SkGeStats(struct SK_NET_DEVICE *dev);
@@ -234,27 +233,6 @@
  * Extern Function Prototypes
  *
  ******************************************************************************/
-static const char 	SKRootName[] = "sk98lin";
-static struct		proc_dir_entry *pSkRootDir;
-extern struct	file_operations sk_proc_fops;
-
-static inline void SkGeProcCreate(struct net_device *dev)
-{
-	struct proc_dir_entry *pe;
-
-	if (pSkRootDir && 
-	    (pe = create_proc_entry(dev->name, S_IRUGO, pSkRootDir))) {
-		pe->proc_fops = &sk_proc_fops;
-		pe->data = dev;
-		pe->owner = THIS_MODULE;
-	}
-}
- 
-static inline void SkGeProcRemove(struct net_device *dev)
-{
-	if (pSkRootDir)
-		remove_proc_entry(dev->name, pSkRootDir);
-}
 
 extern void SkDimEnableModerationIfNeeded(SK_AC *pAC);	
 extern void SkDimDisplayModerationSettings(SK_AC *pAC);
@@ -1420,7 +1398,7 @@
  * WARNING: returning 1 in 'tbusy' case caused system crashes (double
  *	allocated skb's) !!!
  */
-static int SkGeXmit(struct sk_buff *skb, struct SK_NET_DEVICE *dev)
+int SkGeXmit(struct sk_buff *skb, struct SK_NET_DEVICE *dev)
 {
 DEV_NET		*pNet;
 SK_AC		*pAC;
@@ -5004,7 +4982,7 @@
 
 	memcpy(&dev->dev_addr, &pAC->Addr.Net[0].CurrentMacAddress, 6);
 
-	SkGeProcCreate(dev);
+	pNet->proc = SkGeProcCreate(dev);
 
 	pNet->PortNr = 0;
 	pNet->NetNr  = 0;
@@ -5053,7 +5031,7 @@
 			free_netdev(dev);
 			pAC->dev[1] = pAC->dev[0];
 		} else {
-			SkGeProcCreate(dev);
+			pNet->proc = SkGeProcCreate(dev);
 			memcpy(&dev->dev_addr,
 					&pAC->Addr.Net[1].CurrentMacAddress, 6);
 	
@@ -5093,10 +5071,12 @@
 	SK_AC *pAC = pNet->pAC;
 	struct net_device *otherdev = pAC->dev[1];
 
-	SkGeProcRemove(dev);
+	SkGeProcRemove(pNet->proc);
 	unregister_netdev(dev);
-	if (otherdev != dev)
-		SkGeProcRemove(otherdev);
+	if (otherdev != dev) {
+		DEV_NET *otherNet = netdev_priv(otherdev);
+		SkGeProcRemove(otherNet->proc);
+	}
 
 	SkGeYellowLED(pAC, pAC->IoBase, 0);
 
@@ -5163,21 +5143,18 @@
 {
 	int error;
 
-	pSkRootDir = proc_mkdir(SKRootName, proc_net);
-	if (pSkRootDir) 
-		pSkRootDir->owner = THIS_MODULE;
+	SkGeProcInit();
 	
 	error = pci_register_driver(&skge_driver);
 	if (error)
-		proc_net_remove(SKRootName);
+		SkGeProcExit();
 	return error;
 }
 
 static void __exit skge_exit(void)
 {
 	pci_unregister_driver(&skge_driver);
-	proc_net_remove(SKRootName);
-
+	SkGeProcExit();
 }
 
 module_init(skge_init);
diff -Nru a/drivers/net/sk98lin/skproc.c b/drivers/net/sk98lin/skproc.c
--- a/drivers/net/sk98lin/skproc.c	2004-11-15 11:21:41 -08:00
+++ b/drivers/net/sk98lin/skproc.c	2004-11-15 11:21:41 -08:00
@@ -31,10 +31,13 @@
 #include "h/skdrv2nd.h"
 #include "h/skversion.h"
 
+static const char 	SKRootName[] = "sk98lin";
+static struct		proc_dir_entry *pSkRootDir;
+
 static int sk_seq_show(struct seq_file *seq, void *v);
 static int sk_proc_open(struct inode *inode, struct file *file);
 
-struct file_operations sk_proc_fops = {
+static struct file_operations sk_proc_fops = {
 	.owner		= THIS_MODULE,
 	.open		= sk_proc_open,
 	.read		= seq_read,
@@ -258,8 +261,66 @@
     return single_open(file, sk_seq_show, PDE(inode)->data);
 }
 
-/*******************************************************************************
- *
- * End of file
- *
- ******************************************************************************/
+
+struct proc_dir_entry *SkGeProcCreate(struct net_device *dev)
+{
+	struct proc_dir_entry *pe = NULL;
+
+	if (pSkRootDir && 
+	    (pe = create_proc_entry(dev->name, S_IRUGO, pSkRootDir))) {
+		pe->proc_fops = &sk_proc_fops;
+		pe->data = dev;
+		pe->owner = THIS_MODULE;
+	}
+	return pe;
+}
+ 
+void SkGeProcRemove(struct proc_dir_entry *pe)
+{
+	char oldname[IFNAMSIZ];
+
+	if (pe) {
+		strlcpy(oldname, pe->name, IFNAMSIZ);
+		remove_proc_entry(oldname, pSkRootDir);
+	}
+}
+
+/* Callback about network device events.
+ * Only care if device is this driver and it is a name change
+ */
+static int skge_device_notifier(struct notifier_block *unused, 
+				unsigned long event, void *ptr)
+{
+	struct net_device *dev = ptr;
+	DEV_NET *pNet = netdev_priv(dev);
+
+	if (event == NETDEV_CHANGENAME 
+	    && dev->hard_start_xmit == &SkGeXmit
+	    && pNet->proc) {
+		SkGeProcRemove(pNet->proc);
+		pNet->proc = SkGeProcCreate(dev);
+	}
+	return NOTIFY_DONE;
+}
+
+static struct notifier_block skge_dev_notifier = {
+	.notifier_call = skge_device_notifier,
+};
+
+void SkGeProcInit(void)
+{
+	pSkRootDir = proc_mkdir(SKRootName, proc_net);
+	if (pSkRootDir) {
+		pSkRootDir->owner = THIS_MODULE;
+		register_netdevice_notifier(&skge_dev_notifier);
+	}
+}
+
+void SkGeProcExit(void)
+{
+	if (pSkRootDir) {
+		proc_net_remove(SKRootName);
+		unregister_netdevice_notifier(&skge_dev_notifier);
+	}
+}
+
