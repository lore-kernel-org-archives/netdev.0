From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 14/15] drivers/net/typhoon.c: Use (pr|netdev)_<level> macro helpers
Date: Wed, 17 Feb 2010 17:02:01 -0800
Message-ID: <40a714d7757b0c24f3f0737f028d0242853f935b.1266454576.git.joe@perches.com>
References: <cover.1266454575.git.joe@perches.com>
Cc: David Dillow <dave@thedillows.org>, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1057 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755339Ab0BRBCP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Feb 2010 20:02:15 -0500
In-Reply-To: <cover.1266454575.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
Remove #define PFX
Remove #define ERR_PFX
Use pr_<level>
Use netdev_<level>
Coalesce long formats

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/typhoon.c |  162 ++++++++++++++++++++++---------------------------
 1 files changed, 73 insertions(+), 89 deletions(-)

diff --git a/drivers/net/typhoon.c b/drivers/net/typhoon.c
index edabc49..843f986 100644
--- a/drivers/net/typhoon.c
+++ b/drivers/net/typhoon.c
@@ -45,6 +45,8 @@
 		http://oss.sgi.com/cgi-bin/mesg.cgi?a=netdev&i=20031215152211.7003fe8e.rddunlap%40osdl.org
 */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 /* Set the copy breakpoint for the copy-only-tiny-frames scheme.
  * Setting to > 1518 effectively disables this feature.
  */
@@ -102,8 +104,6 @@ static const int multicast_filter_limit = 32;
 #define DRV_MODULE_NAME		"typhoon"
 #define DRV_MODULE_VERSION 	"1.5.9"
 #define DRV_MODULE_RELDATE	"Mar 2, 2009"
-#define PFX			DRV_MODULE_NAME ": "
-#define ERR_PFX			KERN_ERR PFX
 #define FIRMWARE_NAME		"3com/typhoon.bin"
 
 #include <linux/module.h>
@@ -534,8 +534,7 @@ typhoon_process_response(struct typhoon *tp, int resp_size,
 		} else if(resp->cmd == TYPHOON_CMD_HELLO_RESP) {
 			typhoon_hello(tp);
 		} else {
-			printk(KERN_ERR "%s: dumping unexpected response "
-			       "0x%04x:%d:0x%02x:0x%04x:%08x:%08x\n",
+			pr_err("%s: dumping unexpected response 0x%04x:%d:0x%02x:0x%04x:%08x:%08x\n",
 			       tp->name, le16_to_cpu(resp->cmd),
 			       resp->numDesc, resp->flags,
 			       le16_to_cpu(resp->parm1),
@@ -606,9 +605,8 @@ typhoon_issue_command(struct typhoon *tp, int num_cmd, struct cmd_desc *cmd,
 	freeResp = typhoon_num_free_resp(tp);
 
 	if(freeCmd < num_cmd || freeResp < num_resp) {
-		printk("%s: no descs for cmd, had (needed) %d (%d) cmd, "
-			"%d (%d) resp\n", tp->name, freeCmd, num_cmd,
-			freeResp, num_resp);
+		pr_err("%s: no descs for cmd, had (needed) %d (%d) cmd, %d (%d) resp\n",
+		       tp->name, freeCmd, num_cmd, freeResp, num_resp);
 		err = -ENOMEM;
 		goto out;
 	}
@@ -1021,7 +1019,7 @@ typhoon_get_stats(struct net_device *dev)
 		return saved;
 
 	if(typhoon_do_get_stats(tp) < 0) {
-		printk(KERN_ERR "%s: error getting stats\n", dev->name);
+		netdev_err(dev, "error getting stats\n");
 		return saved;
 	}
 
@@ -1366,8 +1364,8 @@ typhoon_request_firmware(struct typhoon *tp)
 
 	err = request_firmware(&typhoon_fw, FIRMWARE_NAME, &tp->pdev->dev);
 	if (err) {
-		printk(KERN_ERR "%s: Failed to load firmware \"%s\"\n",
-				tp->name, FIRMWARE_NAME);
+		pr_err("%s: Failed to load firmware \"%s\"\n",
+		       tp->name, FIRMWARE_NAME);
 		return err;
 	}
 
@@ -1402,7 +1400,7 @@ typhoon_request_firmware(struct typhoon *tp)
 	return 0;
 
 invalid_fw:
-	printk(KERN_ERR "%s: Invalid firmware image\n", tp->name);
+	pr_err("%s: Invalid firmware image\n", tp->name);
 	release_firmware(typhoon_fw);
 	typhoon_fw = NULL;
 	return -EINVAL;
@@ -1439,7 +1437,7 @@ typhoon_download_firmware(struct typhoon *tp)
 	err = -ENOMEM;
 	dpage = pci_alloc_consistent(pdev, PAGE_SIZE, &dpage_dma);
 	if(!dpage) {
-		printk(KERN_ERR "%s: no DMA mem for firmware\n", tp->name);
+		pr_err("%s: no DMA mem for firmware\n", tp->name);
 		goto err_out;
 	}
 
@@ -1452,7 +1450,7 @@ typhoon_download_firmware(struct typhoon *tp)
 
 	err = -ETIMEDOUT;
 	if(typhoon_wait_status(ioaddr, TYPHOON_STATUS_WAITING_FOR_HOST) < 0) {
-		printk(KERN_ERR "%s: card ready timeout\n", tp->name);
+		pr_err("%s: card ready timeout\n", tp->name);
 		goto err_out_irq;
 	}
 
@@ -1492,7 +1490,7 @@ typhoon_download_firmware(struct typhoon *tp)
 			if(typhoon_wait_interrupt(ioaddr) < 0 ||
 			   ioread32(ioaddr + TYPHOON_REG_STATUS) !=
 			   TYPHOON_STATUS_WAITING_FOR_SEGMENT) {
-				printk(KERN_ERR "%s: segment ready timeout\n",
+				pr_err("%s: segment ready timeout\n",
 				       tp->name);
 				goto err_out_irq;
 			}
@@ -1526,14 +1524,14 @@ typhoon_download_firmware(struct typhoon *tp)
 	if(typhoon_wait_interrupt(ioaddr) < 0 ||
 	   ioread32(ioaddr + TYPHOON_REG_STATUS) !=
 	   TYPHOON_STATUS_WAITING_FOR_SEGMENT) {
-		printk(KERN_ERR "%s: final segment ready timeout\n", tp->name);
+		pr_err("%s: final segment ready timeout\n", tp->name);
 		goto err_out_irq;
 	}
 
 	iowrite32(TYPHOON_BOOTCMD_DNLD_COMPLETE, ioaddr + TYPHOON_REG_COMMAND);
 
 	if(typhoon_wait_status(ioaddr, TYPHOON_STATUS_WAITING_FOR_BOOT) < 0) {
-		printk(KERN_ERR "%s: boot ready timeout, status 0x%0x\n",
+		pr_err("%s: boot ready timeout, status 0x%0x\n",
 		       tp->name, ioread32(ioaddr + TYPHOON_REG_STATUS));
 		goto err_out_irq;
 	}
@@ -1556,7 +1554,7 @@ typhoon_boot_3XP(struct typhoon *tp, u32 initial_status)
 	void __iomem *ioaddr = tp->ioaddr;
 
 	if(typhoon_wait_status(ioaddr, initial_status) < 0) {
-		printk(KERN_ERR "%s: boot ready timeout\n", tp->name);
+		pr_err("%s: boot ready timeout\n", tp->name);
 		goto out_timeout;
 	}
 
@@ -1567,7 +1565,7 @@ typhoon_boot_3XP(struct typhoon *tp, u32 initial_status)
 				ioaddr + TYPHOON_REG_COMMAND);
 
 	if(typhoon_wait_status(ioaddr, TYPHOON_STATUS_RUNNING) < 0) {
-		printk(KERN_ERR "%s: boot finish timeout (status 0x%x)\n",
+		pr_err("%s: boot finish timeout (status 0x%x)\n",
 		       tp->name, ioread32(ioaddr + TYPHOON_REG_STATUS));
 		goto out_timeout;
 	}
@@ -1867,8 +1865,7 @@ typhoon_interrupt(int irq, void *dev_instance)
 		typhoon_post_pci_writes(ioaddr);
 		__napi_schedule(&tp->napi);
 	} else {
-		printk(KERN_ERR "%s: Error, poll already scheduled\n",
-                       dev->name);
+		netdev_err(dev, "Error, poll already scheduled\n");
 	}
 	return IRQ_HANDLED;
 }
@@ -1901,16 +1898,16 @@ typhoon_sleep(struct typhoon *tp, pci_power_t state, __le16 events)
 	xp_cmd.parm1 = events;
 	err = typhoon_issue_command(tp, 1, &xp_cmd, 0, NULL);
 	if(err < 0) {
-		printk(KERN_ERR "%s: typhoon_sleep(): wake events cmd err %d\n",
-				tp->name, err);
+		pr_err("%s: %s(): wake events cmd err %d\n",
+		       tp->name, __func__, err);
 		return err;
 	}
 
 	INIT_COMMAND_NO_RESPONSE(&xp_cmd, TYPHOON_CMD_GOTO_SLEEP);
 	err = typhoon_issue_command(tp, 1, &xp_cmd, 0, NULL);
 	if(err < 0) {
-		printk(KERN_ERR "%s: typhoon_sleep(): sleep cmd err %d\n",
-				tp->name, err);
+		pr_err("%s: %s(): sleep cmd err %d\n",
+		       tp->name, __func__, err);
 		return err;
 	}
 
@@ -2070,8 +2067,7 @@ typhoon_stop_runtime(struct typhoon *tp, int wait_type)
 	}
 
 	if(i == TYPHOON_WAIT_TIMEOUT)
-		printk(KERN_ERR
-		       "%s: halt timed out waiting for Tx to complete\n",
+		pr_err("%s: halt timed out waiting for Tx to complete\n",
 		       tp->name);
 
 	INIT_COMMAND_NO_RESPONSE(&xp_cmd, TYPHOON_CMD_TX_DISABLE);
@@ -2089,11 +2085,11 @@ typhoon_stop_runtime(struct typhoon *tp, int wait_type)
 	typhoon_issue_command(tp, 1, &xp_cmd, 0, NULL);
 
 	if(typhoon_wait_status(ioaddr, TYPHOON_STATUS_HALTED) < 0)
-		printk(KERN_ERR "%s: timed out waiting for 3XP to halt\n",
+		pr_err("%s: timed out waiting for 3XP to halt\n",
 		       tp->name);
 
 	if(typhoon_reset(ioaddr, wait_type) < 0) {
-		printk(KERN_ERR "%s: unable to reset 3XP\n", tp->name);
+		pr_err("%s: unable to reset 3XP\n", tp->name);
 		return -ETIMEDOUT;
 	}
 
@@ -2112,8 +2108,7 @@ typhoon_tx_timeout(struct net_device *dev)
 	struct typhoon *tp = netdev_priv(dev);
 
 	if(typhoon_reset(tp->ioaddr, WaitNoSleep) < 0) {
-		printk(KERN_WARNING "%s: could not reset in tx timeout\n",
-					dev->name);
+		netdev_warn(dev, "could not reset in tx timeout\n");
 		goto truely_dead;
 	}
 
@@ -2122,8 +2117,7 @@ typhoon_tx_timeout(struct net_device *dev)
 	typhoon_free_rx_rings(tp);
 
 	if(typhoon_start_runtime(tp) < 0) {
-		printk(KERN_ERR "%s: could not start runtime in tx timeout\n",
-					dev->name);
+		netdev_err(dev, "could not start runtime in tx timeout\n");
 		goto truely_dead;
         }
 
@@ -2148,7 +2142,7 @@ typhoon_open(struct net_device *dev)
 
 	err = typhoon_wakeup(tp, WaitSleep);
 	if(err < 0) {
-		printk(KERN_ERR "%s: unable to wakeup device\n", dev->name);
+		netdev_err(dev, "unable to wakeup device\n");
 		goto out_sleep;
 	}
 
@@ -2173,14 +2167,13 @@ out_irq:
 
 out_sleep:
 	if(typhoon_boot_3XP(tp, TYPHOON_STATUS_WAITING_FOR_HOST) < 0) {
-		printk(KERN_ERR "%s: unable to reboot into sleep img\n",
-				dev->name);
+		netdev_err(dev, "unable to reboot into sleep img\n");
 		typhoon_reset(tp->ioaddr, NoWait);
 		goto out;
 	}
 
 	if(typhoon_sleep(tp, PCI_D3hot, 0) < 0)
-		printk(KERN_ERR "%s: unable to go back to sleep\n", dev->name);
+		netdev_err(dev, "unable to go back to sleep\n");
 
 out:
 	return err;
@@ -2195,7 +2188,7 @@ typhoon_close(struct net_device *dev)
 	napi_disable(&tp->napi);
 
 	if(typhoon_stop_runtime(tp, WaitSleep) < 0)
-		printk(KERN_ERR "%s: unable to stop runtime\n", dev->name);
+		netdev_err(dev, "unable to stop runtime\n");
 
 	/* Make sure there is no irq handler running on a different CPU. */
 	free_irq(dev->irq, dev);
@@ -2204,10 +2197,10 @@ typhoon_close(struct net_device *dev)
 	typhoon_init_rings(tp);
 
 	if(typhoon_boot_3XP(tp, TYPHOON_STATUS_WAITING_FOR_HOST) < 0)
-		printk(KERN_ERR "%s: unable to boot sleep image\n", dev->name);
+		netdev_err(dev, "unable to boot sleep image\n");
 
 	if(typhoon_sleep(tp, PCI_D3hot, 0) < 0)
-		printk(KERN_ERR "%s: unable to put card to sleep\n", dev->name);
+		netdev_err(dev, "unable to put card to sleep\n");
 
 	return 0;
 }
@@ -2225,14 +2218,12 @@ typhoon_resume(struct pci_dev *pdev)
 		return 0;
 
 	if(typhoon_wakeup(tp, WaitNoSleep) < 0) {
-		printk(KERN_ERR "%s: critical: could not wake up in resume\n",
-				dev->name);
+		netdev_err(dev, "critical: could not wake up in resume\n");
 		goto reset;
 	}
 
 	if(typhoon_start_runtime(tp) < 0) {
-		printk(KERN_ERR "%s: critical: could not start runtime in "
-				"resume\n", dev->name);
+		netdev_err(dev, "critical: could not start runtime in resume\n");
 		goto reset;
 	}
 
@@ -2259,8 +2250,7 @@ typhoon_suspend(struct pci_dev *pdev, pm_message_t state)
 	spin_lock_bh(&tp->state_lock);
 	if(tp->vlgrp && tp->wol_events & TYPHOON_WAKE_MAGIC_PKT) {
 		spin_unlock_bh(&tp->state_lock);
-		printk(KERN_ERR "%s: cannot do WAKE_MAGIC with VLANS\n",
-				dev->name);
+		netdev_err(dev, "cannot do WAKE_MAGIC with VLANS\n");
 		return -EBUSY;
 	}
 	spin_unlock_bh(&tp->state_lock);
@@ -2268,7 +2258,7 @@ typhoon_suspend(struct pci_dev *pdev, pm_message_t state)
 	netif_device_detach(dev);
 
 	if(typhoon_stop_runtime(tp, WaitNoSleep) < 0) {
-		printk(KERN_ERR "%s: unable to stop runtime\n", dev->name);
+		netdev_err(dev, "unable to stop runtime\n");
 		goto need_resume;
 	}
 
@@ -2276,7 +2266,7 @@ typhoon_suspend(struct pci_dev *pdev, pm_message_t state)
 	typhoon_init_rings(tp);
 
 	if(typhoon_boot_3XP(tp, TYPHOON_STATUS_WAITING_FOR_HOST) < 0) {
-		printk(KERN_ERR "%s: unable to boot sleep image\n", dev->name);
+		netdev_err(dev, "unable to boot sleep image\n");
 		goto need_resume;
 	}
 
@@ -2284,21 +2274,19 @@ typhoon_suspend(struct pci_dev *pdev, pm_message_t state)
 	xp_cmd.parm1 = cpu_to_le16(ntohs(*(__be16 *)&dev->dev_addr[0]));
 	xp_cmd.parm2 = cpu_to_le32(ntohl(*(__be32 *)&dev->dev_addr[2]));
 	if(typhoon_issue_command(tp, 1, &xp_cmd, 0, NULL) < 0) {
-		printk(KERN_ERR "%s: unable to set mac address in suspend\n",
-				dev->name);
+		netdev_err(dev, "unable to set mac address in suspend\n");
 		goto need_resume;
 	}
 
 	INIT_COMMAND_NO_RESPONSE(&xp_cmd, TYPHOON_CMD_SET_RX_FILTER);
 	xp_cmd.parm1 = TYPHOON_RX_FILTER_DIRECTED | TYPHOON_RX_FILTER_BROADCAST;
 	if(typhoon_issue_command(tp, 1, &xp_cmd, 0, NULL) < 0) {
-		printk(KERN_ERR "%s: unable to set rx filter in suspend\n",
-				dev->name);
+		netdev_err(dev, "unable to set rx filter in suspend\n");
 		goto need_resume;
 	}
 
 	if(typhoon_sleep(tp, pci_choose_state(pdev, state), tp->wol_events) < 0) {
-		printk(KERN_ERR "%s: unable to put card to sleep\n", dev->name);
+		netdev_err(dev, "unable to put card to sleep\n");
 		goto need_resume;
 	}
 
@@ -2352,7 +2340,7 @@ out_unmap:
 
 out:
 	if(!mode)
-		printk(KERN_INFO PFX "falling back to port IO\n");
+		pr_info("falling back to port IO\n");
 	return mode;
 }
 
@@ -2384,11 +2372,11 @@ typhoon_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	int err = 0;
 
 	if(!did_version++)
-		printk(KERN_INFO "%s", version);
+		pr_info("%s", version);
 
 	dev = alloc_etherdev(sizeof(*tp));
 	if(dev == NULL) {
-		printk(ERR_PFX "%s: unable to alloc new net device\n",
+		pr_err("%s: unable to alloc new net device\n",
 		       pci_name(pdev));
 		err = -ENOMEM;
 		goto error_out;
@@ -2397,20 +2385,20 @@ typhoon_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	err = pci_enable_device(pdev);
 	if(err < 0) {
-		printk(ERR_PFX "%s: unable to enable device\n",
+		pr_err("%s: unable to enable device\n",
 		       pci_name(pdev));
 		goto error_out_dev;
 	}
 
 	err = pci_set_mwi(pdev);
 	if(err < 0) {
-		printk(ERR_PFX "%s: unable to set MWI\n", pci_name(pdev));
+		pr_err("%s: unable to set MWI\n", pci_name(pdev));
 		goto error_out_disable;
 	}
 
 	err = pci_set_dma_mask(pdev, DMA_BIT_MASK(32));
 	if(err < 0) {
-		printk(ERR_PFX "%s: No usable DMA configuration\n",
+		pr_err("%s: No usable DMA configuration\n",
 		       pci_name(pdev));
 		goto error_out_mwi;
 	}
@@ -2418,27 +2406,25 @@ typhoon_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	/* sanity checks on IO and MMIO BARs
 	 */
 	if(!(pci_resource_flags(pdev, 0) & IORESOURCE_IO)) {
-		printk(ERR_PFX
-		       "%s: region #1 not a PCI IO resource, aborting\n",
+		pr_err("%s: region #1 not a PCI IO resource, aborting\n",
 		       pci_name(pdev));
 		err = -ENODEV;
 		goto error_out_mwi;
 	}
 	if(pci_resource_len(pdev, 0) < 128) {
-		printk(ERR_PFX "%s: Invalid PCI IO region size, aborting\n",
+		pr_err("%s: Invalid PCI IO region size, aborting\n",
 		       pci_name(pdev));
 		err = -ENODEV;
 		goto error_out_mwi;
 	}
 	if(!(pci_resource_flags(pdev, 1) & IORESOURCE_MEM)) {
-		printk(ERR_PFX
-		       "%s: region #1 not a PCI MMIO resource, aborting\n",
+		pr_err("%s: region #1 not a PCI MMIO resource, aborting\n",
 		       pci_name(pdev));
 		err = -ENODEV;
 		goto error_out_mwi;
 	}
 	if(pci_resource_len(pdev, 1) < 128) {
-		printk(ERR_PFX "%s: Invalid PCI MMIO region size, aborting\n",
+		pr_err("%s: Invalid PCI MMIO region size, aborting\n",
 		       pci_name(pdev));
 		err = -ENODEV;
 		goto error_out_mwi;
@@ -2446,7 +2432,7 @@ typhoon_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	err = pci_request_regions(pdev, "typhoon");
 	if(err < 0) {
-		printk(ERR_PFX "%s: could not request regions\n",
+		pr_err("%s: could not request regions\n",
 		       pci_name(pdev));
 		goto error_out_mwi;
 	}
@@ -2458,7 +2444,7 @@ typhoon_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	ioaddr = pci_iomap(pdev, use_mmio, 128);
 	if (!ioaddr) {
-		printk(ERR_PFX "%s: cannot remap registers, aborting\n",
+		pr_err("%s: cannot remap registers, aborting\n",
 		       pci_name(pdev));
 		err = -EIO;
 		goto error_out_regions;
@@ -2469,7 +2455,7 @@ typhoon_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	shared = pci_alloc_consistent(pdev, sizeof(struct typhoon_shared),
 				      &shared_dma);
 	if(!shared) {
-		printk(ERR_PFX "%s: could not allocate DMA memory\n",
+		pr_err("%s: could not allocate DMA memory\n",
 		       pci_name(pdev));
 		err = -ENOMEM;
 		goto error_out_remap;
@@ -2493,7 +2479,7 @@ typhoon_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	 * 5) Put the card to sleep.
 	 */
 	if (typhoon_reset(ioaddr, WaitSleep) < 0) {
-		printk(ERR_PFX "%s: could not reset 3XP\n", pci_name(pdev));
+		pr_err("%s: could not reset 3XP\n", pci_name(pdev));
 		err = -EIO;
 		goto error_out_dma;
 	}
@@ -2515,7 +2501,7 @@ typhoon_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	typhoon_init_rings(tp);
 
 	if(typhoon_boot_3XP(tp, TYPHOON_STATUS_WAITING_FOR_HOST) < 0) {
-		printk(ERR_PFX "%s: cannot boot 3XP sleep image\n",
+		pr_err("%s: cannot boot 3XP sleep image\n",
 		       pci_name(pdev));
 		err = -EIO;
 		goto error_out_reset;
@@ -2523,7 +2509,7 @@ typhoon_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	INIT_COMMAND_WITH_RESPONSE(&xp_cmd, TYPHOON_CMD_READ_MAC_ADDRESS);
 	if(typhoon_issue_command(tp, 1, &xp_cmd, 1, xp_resp) < 0) {
-		printk(ERR_PFX "%s: cannot read MAC address\n",
+		pr_err("%s: cannot read MAC address\n",
 		       pci_name(pdev));
 		err = -EIO;
 		goto error_out_reset;
@@ -2533,8 +2519,8 @@ typhoon_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	*(__be32 *)&dev->dev_addr[2] = htonl(le32_to_cpu(xp_resp[0].parm2));
 
 	if(!is_valid_ether_addr(dev->dev_addr)) {
-		printk(ERR_PFX "%s: Could not obtain valid ethernet address, "
-		       "aborting\n", pci_name(pdev));
+		pr_err("%s: Could not obtain valid ethernet address, aborting\n",
+		       pci_name(pdev));
 		goto error_out_reset;
 	}
 
@@ -2543,7 +2529,7 @@ typhoon_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	 */
 	INIT_COMMAND_WITH_RESPONSE(&xp_cmd, TYPHOON_CMD_READ_VERSIONS);
 	if(typhoon_issue_command(tp, 1, &xp_cmd, 3, xp_resp) < 0) {
-		printk(ERR_PFX "%s: Could not get Sleep Image version\n",
+		pr_err("%s: Could not get Sleep Image version\n",
 			pci_name(pdev));
 		goto error_out_reset;
 	}
@@ -2561,7 +2547,7 @@ typhoon_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 		tp->capabilities |= TYPHOON_WAKEUP_NEEDS_RESET;
 
 	if(typhoon_sleep(tp, PCI_D3hot, 0) < 0) {
-		printk(ERR_PFX "%s: cannot put adapter to sleep\n",
+		pr_err("%s: cannot put adapter to sleep\n",
 		       pci_name(pdev));
 		err = -EIO;
 		goto error_out_reset;
@@ -2589,11 +2575,11 @@ typhoon_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	pci_set_drvdata(pdev, dev);
 
-	printk(KERN_INFO "%s: %s at %s 0x%llx, %pM\n",
-	       dev->name, typhoon_card_info[card_id].name,
-	       use_mmio ? "MMIO" : "IO",
-	       (unsigned long long)pci_resource_start(pdev, use_mmio),
-	       dev->dev_addr);
+	netdev_info(dev, "%s at %s 0x%llx, %pM\n",
+		    typhoon_card_info[card_id].name,
+		    use_mmio ? "MMIO" : "IO",
+		    (unsigned long long)pci_resource_start(pdev, use_mmio),
+		    dev->dev_addr);
 
 	/* xp_resp still contains the response to the READ_VERSIONS command.
 	 * For debugging, let the user know what version he has.
@@ -2603,23 +2589,21 @@ typhoon_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 		 * of version is Month/Day of build.
 		 */
 		u16 monthday = le32_to_cpu(xp_resp[0].parm2) & 0xffff;
-		printk(KERN_INFO "%s: Typhoon 1.0 Sleep Image built "
-			"%02u/%02u/2000\n", dev->name, monthday >> 8,
-			monthday & 0xff);
+		netdev_info(dev, "Typhoon 1.0 Sleep Image built %02u/%02u/2000\n",
+			    monthday >> 8, monthday & 0xff);
 	} else if(xp_resp[0].numDesc == 2) {
 		/* This is the Typhoon 1.1+ type Sleep Image
 		 */
 		u32 sleep_ver = le32_to_cpu(xp_resp[0].parm2);
 		u8 *ver_string = (u8 *) &xp_resp[1];
 		ver_string[25] = 0;
-		printk(KERN_INFO "%s: Typhoon 1.1+ Sleep Image version "
-			"%02x.%03x.%03x %s\n", dev->name, sleep_ver >> 24,
-			(sleep_ver >> 12) & 0xfff, sleep_ver & 0xfff,
-			ver_string);
+		netdev_info(dev, "Typhoon 1.1+ Sleep Image version %02x.%03x.%03x %s\n",
+			    sleep_ver >> 24,
+			    (sleep_ver >> 12) & 0xfff, sleep_ver & 0xfff,
+			    ver_string);
 	} else {
-		printk(KERN_WARNING "%s: Unknown Sleep Image version "
-			"(%u:%04x)\n", dev->name, xp_resp[0].numDesc,
-			le32_to_cpu(xp_resp[0].parm2));
+		netdev_warn(dev, "Unknown Sleep Image version (%u:%04x)\n",
+			    xp_resp[0].numDesc, le32_to_cpu(xp_resp[0].parm2));
 	}
 
 	return 0;
-- 
1.7.0.14.g7e948

