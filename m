From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] olympic: convert to seq_file
Date: Fri, 13 May 2011 23:42:03 +0300
Message-ID: <20110513204203.GB29261@p183>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:59970 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759137Ab1EMUmJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 May 2011 16:42:09 -0400
Received: by ewy4 with SMTP id 4so807236ewy.19
        for <netdev@vger.kernel.org>; Fri, 13 May 2011 13:42:07 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

->read_proc interface is going away, switch to seq_file.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 drivers/net/tokenring/olympic.c |   57 +++++++++++++++++++---------------------
 1 file changed, 28 insertions(+), 29 deletions(-)

--- a/drivers/net/tokenring/olympic.c
+++ b/drivers/net/tokenring/olympic.c
@@ -86,6 +86,7 @@
 #include <linux/timer.h>
 #include <linux/in.h>
 #include <linux/ioport.h>
+#include <linux/seq_file.h>
 #include <linux/string.h>
 #include <linux/proc_fs.h>
 #include <linux/ptrace.h>
@@ -193,7 +194,7 @@ static void olympic_arb_cmd(struct net_device *dev);
 static int olympic_change_mtu(struct net_device *dev, int mtu);
 static void olympic_srb_bh(struct net_device *dev) ; 
 static void olympic_asb_bh(struct net_device *dev) ; 
-static int olympic_proc_info(char *buffer, char **start, off_t offset, int length, int *eof, void *data) ; 
+static const struct file_operations olympic_proc_ops;
 
 static const struct net_device_ops olympic_netdev_ops = {
 	.ndo_open		= olympic_open,
@@ -272,7 +273,7 @@ static int __devinit olympic_probe(struct pci_dev *pdev, const struct pci_device
 		char proc_name[20] ; 
 		strcpy(proc_name,"olympic_") ;
 		strcat(proc_name,dev->name) ; 
-		create_proc_read_entry(proc_name,0,init_net.proc_net,olympic_proc_info,(void *)dev) ;
+		proc_create_data(proc_name, 0, init_net.proc_net, &olympic_proc_ops, dev);
 		printk("Olympic: Network Monitor information: /proc/%s\n",proc_name); 
 	}
 	return  0 ;
@@ -1615,29 +1616,25 @@ static int olympic_change_mtu(struct net_device *dev, int mtu)
 	return 0 ; 
 }
 
-static int olympic_proc_info(char *buffer, char **start, off_t offset, int length, int *eof, void *data)
+static int olympic_proc_show(struct seq_file *m, void *v)
 {
-	struct net_device *dev = (struct net_device *)data ; 
+	struct net_device *dev = m->private;
 	struct olympic_private *olympic_priv=netdev_priv(dev);
 	u8 __iomem *oat = (olympic_priv->olympic_lap + olympic_priv->olympic_addr_table_addr) ; 
 	u8 __iomem *opt = (olympic_priv->olympic_lap + olympic_priv->olympic_parms_addr) ; 
-	int size = 0 ; 
-	int len=0;
-	off_t begin=0;
-	off_t pos=0;
 	u8 addr[6];
 	u8 addr2[6];
 	int i;
 
-	size = sprintf(buffer, 
+	seq_printf(m,
 		"IBM Pit/Pit-Phy/Olympic Chipset Token Ring Adapter %s\n",dev->name);
-	size += sprintf(buffer+size, "\n%6s: Adapter Address   : Node Address      : Functional Addr\n",
+	seq_printf(m, "\n%6s: Adapter Address   : Node Address      : Functional Addr\n",
  	   dev->name); 
 
 	for (i = 0 ; i < 6 ; i++)
 		addr[i] = readb(oat+offsetof(struct olympic_adapter_addr_table,node_addr) + i);
 
-	size += sprintf(buffer+size, "%6s: %pM : %pM : %02x:%02x:%02x:%02x\n",
+	seq_printf(m, "%6s: %pM : %pM : %02x:%02x:%02x:%02x\n",
 	   dev->name,
 	   dev->dev_addr, addr,
 	   readb(oat+offsetof(struct olympic_adapter_addr_table,func_addr)), 
@@ -1645,9 +1642,9 @@ static int olympic_proc_info(char *buffer, char **start, off_t offset, int lengt
 	   readb(oat+offsetof(struct olympic_adapter_addr_table,func_addr)+2),
 	   readb(oat+offsetof(struct olympic_adapter_addr_table,func_addr)+3));
 	 
-	size += sprintf(buffer+size, "\n%6s: Token Ring Parameters Table:\n", dev->name);
+	seq_printf(m, "\n%6s: Token Ring Parameters Table:\n", dev->name);
 
-	size += sprintf(buffer+size, "%6s: Physical Addr : Up Node Address   : Poll Address      : AccPri : Auth Src : Att Code :\n",
+	seq_printf(m, "%6s: Physical Addr : Up Node Address   : Poll Address      : AccPri : Auth Src : Att Code :\n",
 	  dev->name) ; 
 
 	for (i = 0 ; i < 6 ; i++)
@@ -1655,7 +1652,7 @@ static int olympic_proc_info(char *buffer, char **start, off_t offset, int lengt
 	for (i = 0 ; i < 6 ; i++)
 		addr2[i] =  readb(opt+offsetof(struct olympic_parameters_table, poll_addr) + i);
 
-	size += sprintf(buffer+size, "%6s: %02x:%02x:%02x:%02x   : %pM : %pM : %04x   : %04x     :  %04x    :\n",
+	seq_printf(m, "%6s: %02x:%02x:%02x:%02x   : %pM : %pM : %04x   : %04x     :  %04x    :\n",
 	  dev->name,
 	  readb(opt+offsetof(struct olympic_parameters_table, phys_addr)),
 	  readb(opt+offsetof(struct olympic_parameters_table, phys_addr)+1),
@@ -1666,12 +1663,12 @@ static int olympic_proc_info(char *buffer, char **start, off_t offset, int lengt
 	  swab16(readw(opt+offsetof(struct olympic_parameters_table, auth_source_class))),
 	  swab16(readw(opt+offsetof(struct olympic_parameters_table, att_code))));
 
-	size += sprintf(buffer+size, "%6s: Source Address    : Bcn T : Maj. V : Lan St : Lcl Rg : Mon Err : Frame Correl : \n",
+	seq_printf(m, "%6s: Source Address    : Bcn T : Maj. V : Lan St : Lcl Rg : Mon Err : Frame Correl : \n",
 	  dev->name) ; 
 	
 	for (i = 0 ; i < 6 ; i++)
 		addr[i] = readb(opt+offsetof(struct olympic_parameters_table, source_addr) + i);
-	size += sprintf(buffer+size, "%6s: %pM : %04x  : %04x   : %04x   : %04x   : %04x    :     %04x     : \n",
+	seq_printf(m, "%6s: %pM : %04x  : %04x   : %04x   : %04x   : %04x    :     %04x     : \n",
 	  dev->name, addr,
 	  swab16(readw(opt+offsetof(struct olympic_parameters_table, beacon_type))),
 	  swab16(readw(opt+offsetof(struct olympic_parameters_table, major_vector))),
@@ -1680,12 +1677,12 @@ static int olympic_proc_info(char *buffer, char **start, off_t offset, int lengt
 	  swab16(readw(opt+offsetof(struct olympic_parameters_table, mon_error))),
 	  swab16(readw(opt+offsetof(struct olympic_parameters_table, frame_correl))));
 
-	size += sprintf(buffer+size, "%6s: Beacon Details :  Tx  :  Rx  : NAUN Node Address : NAUN Node Phys : \n",
+	seq_printf(m, "%6s: Beacon Details :  Tx  :  Rx  : NAUN Node Address : NAUN Node Phys : \n",
 	  dev->name) ; 
 
 	for (i = 0 ; i < 6 ; i++)
 		addr[i] = readb(opt+offsetof(struct olympic_parameters_table, beacon_naun) + i);
-	size += sprintf(buffer+size, "%6s:                :  %02x  :  %02x  : %pM : %02x:%02x:%02x:%02x    : \n",
+	seq_printf(m, "%6s:                :  %02x  :  %02x  : %pM : %02x:%02x:%02x:%02x    : \n",
 	  dev->name,
 	  swab16(readw(opt+offsetof(struct olympic_parameters_table, beacon_transmit))),
 	  swab16(readw(opt+offsetof(struct olympic_parameters_table, beacon_receive))),
@@ -1695,19 +1692,21 @@ static int olympic_proc_info(char *buffer, char **start, off_t offset, int lengt
 	  readb(opt+offsetof(struct olympic_parameters_table, beacon_phys)+2),
 	  readb(opt+offsetof(struct olympic_parameters_table, beacon_phys)+3));
 
-	len=size;
-	pos=begin+size;
-	if (pos<offset) {
-		len=0;
-		begin=pos;
-	}
-	*start=buffer+(offset-begin);	/* Start of wanted data */
-	len-=(offset-begin);		/* Start slop */
-	if(len>length)
-		len=length;		/* Ending slop */
-	return len;
+	return 0;
 }
 
+static int olympic_proc_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, olympic_proc_show, PDE(inode)->data);
+}
+
+static const struct file_operations olympic_proc_ops = {
+	.open		= olympic_proc_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= single_release,
+};
+
 static void __devexit olympic_remove_one(struct pci_dev *pdev) 
 {
 	struct net_device *dev = pci_get_drvdata(pdev) ; 
