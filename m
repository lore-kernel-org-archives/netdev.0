From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 1/3] ATM-iphase: Adjust 11 function calls together with a
 variable assignment
Date: Sun, 6 Aug 2017 08:26:40 +0200
Message-ID: <3e7b36a6-41e0-9b55-5933-bc9ef2d5fae6@users.sourceforge.net>
References: <c30df8dd-a6e9-23c1-842b-afa8696e10d4@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
        Chas Williams <3chas3@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <c30df8dd-a6e9-23c1-842b-afa8696e10d4@users.sourceforge.net>
Content-Language: en-GB
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Sat, 5 Aug 2017 21:39:06 +0200

The script "checkpatch.pl" pointed information out like the following.

ERROR: do not use assignment in if condition

Thus fix affected source code places.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/atm/iphase.c | 57 +++++++++++++++++++++++++++++++---------------------
 1 file changed, 34 insertions(+), 23 deletions(-)

diff --git a/drivers/atm/iphase.c b/drivers/atm/iphase.c
index fc72b763fdd7..472762f70921 100644
--- a/drivers/atm/iphase.c
+++ b/drivers/atm/iphase.c
@@ -152,7 +152,8 @@ static void ia_hack_tcq(IADEV *dev) {
         *(u_short *) (dev->seg_ram + dev->host_tcq_wr) = 0;
      }                                 
      else if (dev->desc_tbl[desc1 -1].timestamp) {
-        if (!(iavcc_r = dev->desc_tbl[desc1 -1].iavcc)) { 
+			iavcc_r = dev->desc_tbl[desc1 - 1].iavcc;
+			if (!iavcc_r) {
            printk("IA: Fatal err in get_desc\n");
            continue;
         }
@@ -617,7 +618,8 @@ static int ia_que_tx (IADEV *iadev) {
    num_desc = ia_avail_descs(iadev);
 
    while (num_desc && (skb = skb_dequeue(&iadev->tx_backlog))) {
-      if (!(vcc = ATM_SKB(skb)->vcc)) {
+		vcc = ATM_SKB(skb)->vcc;
+		if (!vcc) {
          dev_kfree_skb_any(skb);
          printk("ia_que_tx: Null vcc\n");
          break;
@@ -1172,8 +1174,9 @@ static int rx_pkt(struct atm_dev *dev)
            atomic_inc(&vcc->stats->rx_err);
 	   goto out_free_desc;
         }
-		  
-        if (!(skb = atm_alloc_charge(vcc, len, GFP_ATOMIC))) {
+
+	skb = atm_alloc_charge(vcc, len, GFP_ATOMIC);
+	if (!skb) {
            if (vcc->vci < 32)
               printk("Drop control packets\n");
 	   goto out_free_desc;
@@ -1296,7 +1299,8 @@ static void rx_dle_intr(struct atm_dev *dev)
       desc = ATM_DESC(skb);
       free_desc(dev, desc);  
                
-      if (!(len = skb->len))
+	len = skb->len;
+	if (!len)
       {  
           printk("rx_dle_intr: skb len 0\n");  
 	  dev_kfree_skb_any(skb);  
@@ -1882,9 +1886,9 @@ static int open_tx(struct atm_vcc *vcc)
                 }
                 vc->type = CBR;
                 vc->status = CRC_APPEND;
-                if ((ret = ia_cbr_setup (iadev, vcc)) < 0) {     
-                    return ret;
-                }
+		ret = ia_cbr_setup(iadev, vcc);
+		if (ret < 0)
+			return ret;
 	} else {
 		printk("iadev:  Non UBR, ABR and CBR traffic not supported\n");
 	}
@@ -2293,15 +2297,19 @@ static int reset_sar(struct atm_dev *dev)
 	unsigned int pci[64];  
 	  
 	iadev = INPH_IA_DEV(dev);  
-	for(i=0; i<64; i++)  
-	  if ((error = pci_read_config_dword(iadev->pci,  
-				i*4, &pci[i])) != PCIBIOS_SUCCESSFUL)  
-  	      return error;  
+	for (i = 0; i < 64; i++) {
+		error = pci_read_config_dword(iadev->pci, i * 4, &pci[i]);
+		if (error != PCIBIOS_SUCCESSFUL)
+			return error;
+	}
+
 	writel(0, iadev->reg+IPHASE5575_EXT_RESET);  
-	for(i=0; i<64; i++)  
-	  if ((error = pci_write_config_dword(iadev->pci,  
-					i*4, pci[i])) != PCIBIOS_SUCCESSFUL)  
-	    return error;  
+	for (i = 0; i < 64; i++) {
+		error = pci_write_config_dword(iadev->pci, i * 4, pci[i]);
+		if (error != PCIBIOS_SUCCESSFUL)
+			return error;
+	}
+
 	udelay(5);  
 	return 0;  
 }  
@@ -2516,9 +2524,10 @@ static int ia_start(struct atm_dev *dev)
         }  
         /* @@@ should release IRQ on error */  
 	/* enabling memory + master */  
-        if ((error = pci_write_config_word(iadev->pci,   
-				PCI_COMMAND,   
-				PCI_COMMAND_MEMORY | PCI_COMMAND_MASTER )))   
+	error = pci_write_config_word(iadev->pci,
+				      PCI_COMMAND,
+				      PCI_COMMAND_MEMORY | PCI_COMMAND_MASTER);
+	if (error)
 	{  
                 printk(KERN_ERR DEV_LABEL "(itf %d): can't enable memory+"  
                     "master (0x%x)\n",dev->number, error);  
@@ -2569,7 +2578,8 @@ static int ia_start(struct atm_dev *dev)
                                readl(iadev->reg+IPHASE5575_BUS_CONTROL_REG));)  
         phy = 0; /* resolve compiler complaint */
         IF_INIT ( 
-	if ((phy=ia_phy_get(dev,0)) == 0x30)  
+	phy = ia_phy_get(dev, 0);
+	if (phy == 0x30)
 		printk("IA: pm5346,rev.%d\n",phy&0x0f);  
 	else  
 		printk("IA: utopia,rev.%0x\n",phy);) 
@@ -2710,15 +2720,16 @@ static int ia_open(struct atm_vcc *vcc)
 	ia_vcc = kmalloc(sizeof(*ia_vcc), GFP_KERNEL);  
 	if (!ia_vcc) return -ENOMEM;  
 	vcc->dev_data = ia_vcc;
-  
-	if ((error = open_rx(vcc)))  
+	error = open_rx(vcc);
+	if (error)
 	{  
 		IF_EVENT(printk("iadev: error in open_rx, closing\n");)  
 		ia_close(vcc);  
 		return error;  
 	}  
   
-	if ((error = open_tx(vcc)))  
+	error = open_tx(vcc);
+	if (error)
 	{  
 		IF_EVENT(printk("iadev: error in open_tx, closing\n");)  
 		ia_close(vcc);  
-- 
2.13.4
