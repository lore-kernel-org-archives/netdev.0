From: Malli Chilakala <mallikarjuna.chilakala@intel.com>
Subject: [PATCH net-drivers-2.6 5/6] e100: Performance optimizations to e100
 Tx Path
Date: Tue, 19 Apr 2005 22:50:31 -0700 (PDT)
Message-ID: <Pine.LNX.4.61.0504190534410.11186@anoushka.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "jgarzik@pobox.com" <jgarzik@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Performance optimizations to e100 Tx Path

Signed-off-by: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>
Signed-off-by: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Signed-off-by: John Ronciak <john.ronciak@intel.com>
diff -up net-drivers-2.6/drivers/net/e100.c net-drivers-2.6/drivers/net/e100.c.new
--- net-drivers-2.6/drivers/net/e100.c	2005-04-07 03:22:36.805273784 -0700
+++ net-drivers-2.6/drivers/net/e100.c.new	2005-04-07 03:22:37.251205992 -0700
@@ -777,7 +777,7 @@ static int e100_eeprom_save(struct nic *
 	return 0;
 }
 
-#define E100_WAIT_SCB_TIMEOUT 40
+#define E100_WAIT_SCB_TIMEOUT 20000 /* we might have to wait 100ms!!! */
 static inline int e100_exec_cmd(struct nic *nic, u8 cmd, dma_addr_t dma_addr)
 {
 	unsigned long flags;
@@ -847,6 +847,10 @@ static inline int e100_exec_cb(struct ni
 			 * because the controller is too busy, so
 			 * let's just queue the command and try again
 			 * when another command is scheduled. */
+			if(err == -ENOSPC) {
+				//request a reset
+				schedule_work(&nic->tx_timeout_task);
+			}
 			break;
 		} else {
 			nic->cuc_cmd = cuc_resume;
@@ -891,7 +895,7 @@ static void mdio_write(struct net_device
 
 static void e100_get_defaults(struct nic *nic)
 {
-	struct param_range rfds = { .min = 64, .max = 256, .count = 64 };
+	struct param_range rfds = { .min = 16, .max = 256, .count = 64 };
 	struct param_range cbs  = { .min = 64, .max = 256, .count = 64 };
 
 	pci_read_config_byte(nic->pdev, PCI_REVISION_ID, &nic->rev_id);
@@ -906,8 +910,9 @@ static void e100_get_defaults(struct nic
 	/* Quadwords to DMA into FIFO before starting frame transmit */
 	nic->tx_threshold = 0xE0;
 
-	nic->tx_command = cpu_to_le16(cb_tx | cb_i | cb_tx_sf |
-		((nic->mac >= mac_82558_D101_A4) ? cb_cid : 0));
+	/* no interrupt for every tx completion, delay = 256us if not 557*/
+	nic->tx_command = cpu_to_le16(cb_tx | cb_tx_sf |
+		((nic->mac >= mac_82558_D101_A4) ? cb_cid : cb_i));
 
 	/* Template for a freshly allocated RFD */
 	nic->blank_rfd.command = cpu_to_le16(cb_el);
@@ -1289,12 +1294,15 @@ static inline void e100_xmit_prepare(str
 	struct sk_buff *skb)
 {
 	cb->command = nic->tx_command;
+	/* interrupt every 16 packets regardless of delay */
+	if((nic->cbs_avail & ~15) == nic->cbs_avail) cb->command |= cb_i;
 	cb->u.tcb.tbd_array = cb->dma_addr + offsetof(struct cb, u.tcb.tbd);
 	cb->u.tcb.tcb_byte_count = 0;
 	cb->u.tcb.threshold = nic->tx_threshold;
 	cb->u.tcb.tbd_count = 1;
 	cb->u.tcb.tbd.buf_addr = cpu_to_le32(pci_map_single(nic->pdev,
 		skb->data, skb->len, PCI_DMA_TODEVICE));
+	// check for mapping failure?
 	cb->u.tcb.tbd.size = cpu_to_le16(skb->len);
 }
 
