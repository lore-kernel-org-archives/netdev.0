From: Joe Perches <joe@perches.com>
Subject: [PATCH V2 net-next 14/15] drivers/net/typhoon.c: Use
 (pr|netdev)_<level> macro helpers
Date: Sun, 21 Feb 2010 19:08:47 -0800
Message-ID: <1266808127.10646.77.camel@Joe-Laptop.home>
References: <1266460221.5719.60.camel@obelisk.thedillows.org>
	 <20100217.184100.232538560.davem@davemloft.net>
	 <1266462064.5719.78.camel@obelisk.thedillows.org>
	 <20100217.191002.240804576.davem@davemloft.net>
	 <1266463341.5719.96.camel@obelisk.thedillows.org>
	 <1266467718.8446.251.camel@Joe-Laptop.home>
	 <1266795829.2930.8.camel@obelisk.thedillows.org>
	 <1266804176.10646.65.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, David Dillow <dave@thedillows.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1123 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754237Ab0BVDIt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 21 Feb 2010 22:08:49 -0500
In-Reply-To: <1266804176.10646.65.camel@Joe-Laptop.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Dillow took my suggestions and improved on them.
Here is this latest version.

Add #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
Remove #define PFX
Remove #define ERR_PFX
Remove now unused member name from struct typhoon
Use pr_<level>
Use netdev_<level>
Coalesce long formats
Remove version information

Signed-off-by: Joe Perches <joe@perches.com>
Signed-off-by: David Dillow <dave@thedillows.org>
---
diff --git a/drivers/net/typhoon.c b/drivers/net/typhoon.c
index edabc49..38c2161 100644
--- a/drivers/net/typhoon.c
+++ b/drivers/net/typhoon.c
@@ -98,14 +98,10 @@ static const int multicast_filter_limit = 32;
 #define TX_TIMEOUT  (2*HZ)
 
 #define PKT_BUF_SZ		1536
-
-#define DRV_MODULE_NAME		"typhoon"
-#define DRV_MODULE_VERSION 	"1.5.9"
-#define DRV_MODULE_RELDATE	"Mar 2, 2009"
-#define PFX			DRV_MODULE_NAME ": "
-#define ERR_PFX			KERN_ERR PFX
 #define FIRMWARE_NAME		"3com/typhoon.bin"
 
+#define pr_fmt(fmt)		KBUILD_MODNAME " " fmt
+
 #include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/sched.h>
@@ -132,14 +128,12 @@ static const int multicast_filter_limit = 32;
 #include <linux/in6.h>
 #include <linux/dma-mapping.h>
 #include <linux/firmware.h>
+#include <generated/utsrelease.h>
 
 #include "typhoon.h"
 
-static char version[] __devinitdata =
-    "typhoon.c: version " DRV_MODULE_VERSION " (" DRV_MODULE_RELDATE ")\n";
-
 MODULE_AUTHOR("David Dillow <dave@thedillows.org>");
-MODULE_VERSION(DRV_MODULE_VERSION);
+MODULE_VERSION(UTS_RELEASE);
 MODULE_LICENSE("GPL");
 MODULE_FIRMWARE(FIRMWARE_NAME);
 MODULE_DESCRIPTION("3Com Typhoon Family (3C990, 3CR990, and variants)");
@@ -161,8 +155,8 @@ module_param(use_mmio, int, 0);
 #endif
 
 struct typhoon_card_info {
-	char *name;
-	int capabilities;
+	const char *name;
+	const int capabilities;
 };
 
 #define TYPHOON_CRYPTO_NONE		0x00
@@ -299,7 +293,6 @@ struct typhoon {
 	struct basic_ring	respRing;
 	struct net_device_stats	stats;
 	struct net_device_stats	stats_saved;
-	const char *		name;
 	struct typhoon_shared *	shared;
 	dma_addr_t		shared_dma;
 	__le16			xcvr_select;
@@ -534,13 +527,13 @@ typhoon_process_response(struct typhoon *tp, int resp_size,
 		} else if(resp->cmd == TYPHOON_CMD_HELLO_RESP) {
 			typhoon_hello(tp);
 		} else {
-			printk(KERN_ERR "%s: dumping unexpected response "
-			       "0x%04x:%d:0x%02x:0x%04x:%08x:%08x\n",
-			       tp->name, le16_to_cpu(resp->cmd),
-			       resp->numDesc, resp->flags,
-			       le16_to_cpu(resp->parm1),
-			       le32_to_cpu(resp->parm2),
-			       le32_to_cpu(resp->parm3));
+			netdev_err(tp->dev,
+				   "dumping unexpected response 0x%04x:%d:0x%02x:0x%04x:%08x:%08x\n",
+				   le16_to_cpu(resp->cmd),
+				   resp->numDesc, resp->flags,
+				   le16_to_cpu(resp->parm1),
+				   le32_to_cpu(resp->parm2),
+				   le32_to_cpu(resp->parm3));
 		}
 
 cleanup:
@@ -606,9 +599,8 @@ typhoon_issue_command(struct typhoon *tp, int num_cmd, struct cmd_desc *cmd,
 	freeResp = typhoon_num_free_resp(tp);
 
 	if(freeCmd < num_cmd || freeResp < num_resp) {
-		printk("%s: no descs for cmd, had (needed) %d (%d) cmd, "
-			"%d (%d) resp\n", tp->name, freeCmd, num_cmd,
-			freeResp, num_resp);
+		netdev_err(tp->dev, "no descs for cmd, had (needed) %d (%d) cmd, %d (%d) resp\n",
+			   freeCmd, num_cmd, freeResp, num_resp);
 		err = -ENOMEM;
 		goto out;
 	}
@@ -733,7 +725,7 @@ typhoon_vlan_rx_register(struct net_device *dev, struct vlan_group *grp)
 		spin_unlock_bh(&tp->state_lock);
 		err = typhoon_issue_command(tp, 1, &xp_cmd, 0, NULL);
 		if(err < 0)
-			printk("%s: vlan offload error %d\n", tp->name, -err);
+			netdev_err(tp->dev, "vlan offload error %d\n", -err);
 		spin_lock_bh(&tp->state_lock);
 	}
 
@@ -1021,7 +1013,7 @@ typhoon_get_stats(struct net_device *dev)
 		return saved;
 
 	if(typhoon_do_get_stats(tp) < 0) {
-		printk(KERN_ERR "%s: error getting stats\n", dev->name);
+		netdev_err(dev, "error getting stats\n");
 		return saved;
 	}
 
@@ -1063,8 +1055,8 @@ typhoon_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info)
 		}
 	}
 
-	strcpy(info->driver, DRV_MODULE_NAME);
-	strcpy(info->version, DRV_MODULE_VERSION);
+	strcpy(info->driver, KBUILD_MODNAME);
+	strcpy(info->version, UTS_RELEASE);
 	strcpy(info->bus_info, pci_name(pci_dev));
 }
 
@@ -1366,8 +1358,8 @@ typhoon_request_firmware(struct typhoon *tp)
 
 	err = request_firmware(&typhoon_fw, FIRMWARE_NAME, &tp->pdev->dev);
 	if (err) {
-		printk(KERN_ERR "%s: Failed to load firmware \"%s\"\n",
-				tp->name, FIRMWARE_NAME);
+		netdev_err(tp->dev, "Failed to load firmware \"%s\"\n",
+			   FIRMWARE_NAME);
 		return err;
 	}
 
@@ -1402,7 +1394,7 @@ typhoon_request_firmware(struct typhoon *tp)
 	return 0;
 
 invalid_fw:
-	printk(KERN_ERR "%s: Invalid firmware image\n", tp->name);
+	netdev_err(tp->dev, "Invalid firmware image\n");
 	release_firmware(typhoon_fw);
 	typhoon_fw = NULL;
 	return -EINVAL;
@@ -1439,7 +1431,7 @@ typhoon_download_firmware(struct typhoon *tp)
 	err = -ENOMEM;
 	dpage = pci_alloc_consistent(pdev, PAGE_SIZE, &dpage_dma);
 	if(!dpage) {
-		printk(KERN_ERR "%s: no DMA mem for firmware\n", tp->name);
+		netdev_err(tp->dev, "no DMA mem for firmware\n");
 		goto err_out;
 	}
 
@@ -1452,7 +1444,7 @@ typhoon_download_firmware(struct typhoon *tp)
 
 	err = -ETIMEDOUT;
 	if(typhoon_wait_status(ioaddr, TYPHOON_STATUS_WAITING_FOR_HOST) < 0) {
-		printk(KERN_ERR "%s: card ready timeout\n", tp->name);
+		netdev_err(tp->dev, "card ready timeout\n");
 		goto err_out_irq;
 	}
 
@@ -1492,8 +1484,7 @@ typhoon_download_firmware(struct typhoon *tp)
 			if(typhoon_wait_interrupt(ioaddr) < 0 ||
 			   ioread32(ioaddr + TYPHOON_REG_STATUS) !=
 			   TYPHOON_STATUS_WAITING_FOR_SEGMENT) {
-				printk(KERN_ERR "%s: segment ready timeout\n",
-				       tp->name);
+				netdev_err(tp->dev, "segment ready timeout\n");
 				goto err_out_irq;
 			}
 
@@ -1503,8 +1494,8 @@ typhoon_download_firmware(struct typhoon *tp)
 			 * the checksum, we can do this once, at the end.
 			 */
 			csum = csum_fold(csum_partial_copy_nocheck(image_data,
-								  dpage, len,
-								  0));
+								   dpage, len,
+								   0));
 
 			iowrite32(len, ioaddr + TYPHOON_REG_BOOT_LENGTH);
 			iowrite32(le16_to_cpu((__force __le16)csum),
@@ -1515,7 +1506,7 @@ typhoon_download_firmware(struct typhoon *tp)
 			iowrite32(dpage_dma, ioaddr + TYPHOON_REG_BOOT_DATA_LO);
 			typhoon_post_pci_writes(ioaddr);
 			iowrite32(TYPHOON_BOOTCMD_SEG_AVAILABLE,
-			       ioaddr + TYPHOON_REG_COMMAND);
+					ioaddr + TYPHOON_REG_COMMAND);
 
 			image_data += len;
 			load_addr += len;
@@ -1526,15 +1517,15 @@ typhoon_download_firmware(struct typhoon *tp)
 	if(typhoon_wait_interrupt(ioaddr) < 0 ||
 	   ioread32(ioaddr + TYPHOON_REG_STATUS) !=
 	   TYPHOON_STATUS_WAITING_FOR_SEGMENT) {
-		printk(KERN_ERR "%s: final segment ready timeout\n", tp->name);
+		netdev_err(tp->dev, "final segment ready timeout\n");
 		goto err_out_irq;
 	}
 
 	iowrite32(TYPHOON_BOOTCMD_DNLD_COMPLETE, ioaddr + TYPHOON_REG_COMMAND);
 
 	if(typhoon_wait_status(ioaddr, TYPHOON_STATUS_WAITING_FOR_BOOT) < 0) {
-		printk(KERN_ERR "%s: boot ready timeout, status 0x%0x\n",
-		       tp->name, ioread32(ioaddr + TYPHOON_REG_STATUS));
+		netdev_err(tp->dev, "boot ready timeout, status 0x%0x\n",
+			   ioread32(ioaddr + TYPHOON_REG_STATUS));
 		goto err_out_irq;
 	}
 
@@ -1556,7 +1547,7 @@ typhoon_boot_3XP(struct typhoon *tp, u32 initial_status)
 	void __iomem *ioaddr = tp->ioaddr;
 
 	if(typhoon_wait_status(ioaddr, initial_status) < 0) {
-		printk(KERN_ERR "%s: boot ready timeout\n", tp->name);
+		netdev_err(tp->dev, "boot ready timeout\n");
 		goto out_timeout;
 	}
 
@@ -1567,8 +1558,8 @@ typhoon_boot_3XP(struct typhoon *tp, u32 initial_status)
 				ioaddr + TYPHOON_REG_COMMAND);
 
 	if(typhoon_wait_status(ioaddr, TYPHOON_STATUS_RUNNING) < 0) {
-		printk(KERN_ERR "%s: boot finish timeout (status 0x%x)\n",
-		       tp->name, ioread32(ioaddr + TYPHOON_REG_STATUS));
+		netdev_err(tp->dev, "boot finish timeout (status 0x%x)\n",
+			   ioread32(ioaddr + TYPHOON_REG_STATUS));
 		goto out_timeout;
 	}
 
@@ -1867,8 +1858,7 @@ typhoon_interrupt(int irq, void *dev_instance)
 		typhoon_post_pci_writes(ioaddr);
 		__napi_schedule(&tp->napi);
 	} else {
-		printk(KERN_ERR "%s: Error, poll already scheduled\n",
-                       dev->name);
+		netdev_err(dev, "Error, poll already scheduled\n");
 	}
 	return IRQ_HANDLED;
 }
@@ -1901,16 +1891,15 @@ typhoon_sleep(struct typhoon *tp, pci_power_t state, __le16 events)
 	xp_cmd.parm1 = events;
 	err = typhoon_issue_command(tp, 1, &xp_cmd, 0, NULL);
 	if(err < 0) {
-		printk(KERN_ERR "%s: typhoon_sleep(): wake events cmd err %d\n",
-				tp->name, err);
+		netdev_err(tp->dev, "typhoon_sleep(): wake events cmd err %d\n",
+			   err);
 		return err;
 	}
 
 	INIT_COMMAND_NO_RESPONSE(&xp_cmd, TYPHOON_CMD_GOTO_SLEEP);
 	err = typhoon_issue_command(tp, 1, &xp_cmd, 0, NULL);
 	if(err < 0) {
-		printk(KERN_ERR "%s: typhoon_sleep(): sleep cmd err %d\n",
-				tp->name, err);
+		netdev_err(tp->dev, "typhoon_sleep(): sleep cmd err %d\n", err);
 		return err;
 	}
 
@@ -1961,12 +1950,12 @@ typhoon_start_runtime(struct typhoon *tp)
 
 	err = typhoon_download_firmware(tp);
 	if(err < 0) {
-		printk("%s: cannot load runtime on 3XP\n", tp->name);
+		netdev_err(tp->dev, "cannot load runtime on 3XP\n");
 		goto error_out;
 	}
 
 	if(typhoon_boot_3XP(tp, TYPHOON_STATUS_WAITING_FOR_BOOT) < 0) {
-		printk("%s: cannot boot 3XP\n", tp->name);
+		netdev_err(tp->dev, "cannot boot 3XP\n");
 		err = -EIO;
 		goto error_out;
 	}
@@ -2070,9 +2059,7 @@ typhoon_stop_runtime(struct typhoon *tp, int wait_type)
 	}
 
 	if(i == TYPHOON_WAIT_TIMEOUT)
-		printk(KERN_ERR
-		       "%s: halt timed out waiting for Tx to complete\n",
-		       tp->name);
+		netdev_err(tp->dev, "halt timed out waiting for Tx to complete\n");
 
 	INIT_COMMAND_NO_RESPONSE(&xp_cmd, TYPHOON_CMD_TX_DISABLE);
 	typhoon_issue_command(tp, 1, &xp_cmd, 0, NULL);
@@ -2089,11 +2076,10 @@ typhoon_stop_runtime(struct typhoon *tp, int wait_type)
 	typhoon_issue_command(tp, 1, &xp_cmd, 0, NULL);
 
 	if(typhoon_wait_status(ioaddr, TYPHOON_STATUS_HALTED) < 0)
-		printk(KERN_ERR "%s: timed out waiting for 3XP to halt\n",
-		       tp->name);
+		netdev_err(tp->dev, "timed out waiting for 3XP to halt\n");
 
 	if(typhoon_reset(ioaddr, wait_type) < 0) {
-		printk(KERN_ERR "%s: unable to reset 3XP\n", tp->name);
+		netdev_err(tp->dev, "unable to reset 3XP\n");
 		return -ETIMEDOUT;
 	}
 
@@ -2112,8 +2098,7 @@ typhoon_tx_timeout(struct net_device *dev)
 	struct typhoon *tp = netdev_priv(dev);
 
 	if(typhoon_reset(tp->ioaddr, WaitNoSleep) < 0) {
-		printk(KERN_WARNING "%s: could not reset in tx timeout\n",
-					dev->name);
+		netdev_warn(dev, "could not reset in tx timeout\n");
 		goto truely_dead;
 	}
 
@@ -2122,8 +2107,7 @@ typhoon_tx_timeout(struct net_device *dev)
 	typhoon_free_rx_rings(tp);
 
 	if(typhoon_start_runtime(tp) < 0) {
-		printk(KERN_ERR "%s: could not start runtime in tx timeout\n",
-					dev->name);
+		netdev_err(dev, "could not start runtime in tx timeout\n");
 		goto truely_dead;
         }
 
@@ -2148,7 +2132,7 @@ typhoon_open(struct net_device *dev)
 
 	err = typhoon_wakeup(tp, WaitSleep);
 	if(err < 0) {
-		printk(KERN_ERR "%s: unable to wakeup device\n", dev->name);
+		netdev_err(dev, "unable to wakeup device\n");
 		goto out_sleep;
 	}
 
@@ -2173,14 +2157,13 @@ out_irq:
 
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
@@ -2195,7 +2178,7 @@ typhoon_close(struct net_device *dev)
 	napi_disable(&tp->napi);
 
 	if(typhoon_stop_runtime(tp, WaitSleep) < 0)
-		printk(KERN_ERR "%s: unable to stop runtime\n", dev->name);
+		netdev_err(dev, "unable to stop runtime\n");
 
 	/* Make sure there is no irq handler running on a different CPU. */
 	free_irq(dev->irq, dev);
@@ -2204,10 +2187,10 @@ typhoon_close(struct net_device *dev)
 	typhoon_init_rings(tp);
 
 	if(typhoon_boot_3XP(tp, TYPHOON_STATUS_WAITING_FOR_HOST) < 0)
-		printk(KERN_ERR "%s: unable to boot sleep image\n", dev->name);
+		netdev_err(dev, "unable to boot sleep image\n");
 
 	if(typhoon_sleep(tp, PCI_D3hot, 0) < 0)
-		printk(KERN_ERR "%s: unable to put card to sleep\n", dev->name);
+		netdev_err(dev, "unable to put card to sleep\n");
 
 	return 0;
 }
@@ -2225,14 +2208,12 @@ typhoon_resume(struct pci_dev *pdev)
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
 
@@ -2259,8 +2240,7 @@ typhoon_suspend(struct pci_dev *pdev, pm_message_t state)
 	spin_lock_bh(&tp->state_lock);
 	if(tp->vlgrp && tp->wol_events & TYPHOON_WAKE_MAGIC_PKT) {
 		spin_unlock_bh(&tp->state_lock);
-		printk(KERN_ERR "%s: cannot do WAKE_MAGIC with VLANS\n",
-				dev->name);
+		netdev_err(dev, "cannot do WAKE_MAGIC with VLANS\n");
 		return -EBUSY;
 	}
 	spin_unlock_bh(&tp->state_lock);
@@ -2268,7 +2248,7 @@ typhoon_suspend(struct pci_dev *pdev, pm_message_t state)
 	netif_device_detach(dev);
 
 	if(typhoon_stop_runtime(tp, WaitNoSleep) < 0) {
-		printk(KERN_ERR "%s: unable to stop runtime\n", dev->name);
+		netdev_err(dev, "unable to stop runtime\n");
 		goto need_resume;
 	}
 
@@ -2276,7 +2256,7 @@ typhoon_suspend(struct pci_dev *pdev, pm_message_t state)
 	typhoon_init_rings(tp);
 
 	if(typhoon_boot_3XP(tp, TYPHOON_STATUS_WAITING_FOR_HOST) < 0) {
-		printk(KERN_ERR "%s: unable to boot sleep image\n", dev->name);
+		netdev_err(dev, "unable to boot sleep image\n");
 		goto need_resume;
 	}
 
@@ -2284,21 +2264,19 @@ typhoon_suspend(struct pci_dev *pdev, pm_message_t state)
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
 
@@ -2352,7 +2330,7 @@ out_unmap:
 
 out:
 	if(!mode)
-		printk(KERN_INFO PFX "falling back to port IO\n");
+		pr_info("%s: falling back to port IO\n", pci_name(pdev));
 	return mode;
 }
 
@@ -2372,7 +2350,6 @@ static const struct net_device_ops typhoon_netdev_ops = {
 static int __devinit
 typhoon_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
-	static int did_version = 0;
 	struct net_device *dev;
 	struct typhoon *tp;
 	int card_id = (int) ent->driver_data;
@@ -2382,14 +2359,11 @@ typhoon_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	struct cmd_desc xp_cmd;
 	struct resp_desc xp_resp[3];
 	int err = 0;
-
-	if(!did_version++)
-		printk(KERN_INFO "%s", version);
+	const char *err_msg;
 
 	dev = alloc_etherdev(sizeof(*tp));
 	if(dev == NULL) {
-		printk(ERR_PFX "%s: unable to alloc new net device\n",
-		       pci_name(pdev));
+		err_msg = "unable to alloc new net device";
 		err = -ENOMEM;
 		goto error_out;
 	}
@@ -2397,57 +2371,48 @@ typhoon_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	err = pci_enable_device(pdev);
 	if(err < 0) {
-		printk(ERR_PFX "%s: unable to enable device\n",
-		       pci_name(pdev));
+		err_msg = "unable to enable device";
 		goto error_out_dev;
 	}
 
 	err = pci_set_mwi(pdev);
 	if(err < 0) {
-		printk(ERR_PFX "%s: unable to set MWI\n", pci_name(pdev));
+		err_msg = "unable to set MWI";
 		goto error_out_disable;
 	}
 
 	err = pci_set_dma_mask(pdev, DMA_BIT_MASK(32));
 	if(err < 0) {
-		printk(ERR_PFX "%s: No usable DMA configuration\n",
-		       pci_name(pdev));
+		err_msg = "No usable DMA configuration";
 		goto error_out_mwi;
 	}
 
 	/* sanity checks on IO and MMIO BARs
 	 */
 	if(!(pci_resource_flags(pdev, 0) & IORESOURCE_IO)) {
-		printk(ERR_PFX
-		       "%s: region #1 not a PCI IO resource, aborting\n",
-		       pci_name(pdev));
+		err_msg = "region #1 not a PCI IO resource, aborting";
 		err = -ENODEV;
 		goto error_out_mwi;
 	}
 	if(pci_resource_len(pdev, 0) < 128) {
-		printk(ERR_PFX "%s: Invalid PCI IO region size, aborting\n",
-		       pci_name(pdev));
+		err_msg = "Invalid PCI IO region size, aborting";
 		err = -ENODEV;
 		goto error_out_mwi;
 	}
 	if(!(pci_resource_flags(pdev, 1) & IORESOURCE_MEM)) {
-		printk(ERR_PFX
-		       "%s: region #1 not a PCI MMIO resource, aborting\n",
-		       pci_name(pdev));
+		err_msg = "region #1 not a PCI MMIO resource, aborting";
 		err = -ENODEV;
 		goto error_out_mwi;
 	}
 	if(pci_resource_len(pdev, 1) < 128) {
-		printk(ERR_PFX "%s: Invalid PCI MMIO region size, aborting\n",
-		       pci_name(pdev));
+		err_msg = "Invalid PCI MMIO region size, aborting";
 		err = -ENODEV;
 		goto error_out_mwi;
 	}
 
-	err = pci_request_regions(pdev, "typhoon");
+	err = pci_request_regions(pdev, KBUILD_MODNAME);
 	if(err < 0) {
-		printk(ERR_PFX "%s: could not request regions\n",
-		       pci_name(pdev));
+		err_msg = "could not request regions";
 		goto error_out_mwi;
 	}
 
@@ -2458,8 +2423,7 @@ typhoon_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	ioaddr = pci_iomap(pdev, use_mmio, 128);
 	if (!ioaddr) {
-		printk(ERR_PFX "%s: cannot remap registers, aborting\n",
-		       pci_name(pdev));
+		err_msg = "cannot remap registers, aborting";
 		err = -EIO;
 		goto error_out_regions;
 	}
@@ -2469,8 +2433,7 @@ typhoon_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	shared = pci_alloc_consistent(pdev, sizeof(struct typhoon_shared),
 				      &shared_dma);
 	if(!shared) {
-		printk(ERR_PFX "%s: could not allocate DMA memory\n",
-		       pci_name(pdev));
+		err_msg = "could not allocate DMA memory";
 		err = -ENOMEM;
 		goto error_out_remap;
 	}
@@ -2493,7 +2456,7 @@ typhoon_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	 * 5) Put the card to sleep.
 	 */
 	if (typhoon_reset(ioaddr, WaitSleep) < 0) {
-		printk(ERR_PFX "%s: could not reset 3XP\n", pci_name(pdev));
+		err_msg = "could not reset 3XP";
 		err = -EIO;
 		goto error_out_dma;
 	}
@@ -2505,26 +2468,18 @@ typhoon_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	pci_set_master(pdev);
 	pci_save_state(pdev);
 
-	/* dev->name is not valid until we register, but we need to
-	 * use some common routines to initialize the card. So that those
-	 * routines print the right name, we keep our oun pointer to the name
-	 */
-	tp->name = pci_name(pdev);
-
 	typhoon_init_interface(tp);
 	typhoon_init_rings(tp);
 
 	if(typhoon_boot_3XP(tp, TYPHOON_STATUS_WAITING_FOR_HOST) < 0) {
-		printk(ERR_PFX "%s: cannot boot 3XP sleep image\n",
-		       pci_name(pdev));
+		err_msg = "cannot boot 3XP sleep image";
 		err = -EIO;
 		goto error_out_reset;
 	}
 
 	INIT_COMMAND_WITH_RESPONSE(&xp_cmd, TYPHOON_CMD_READ_MAC_ADDRESS);
 	if(typhoon_issue_command(tp, 1, &xp_cmd, 1, xp_resp) < 0) {
-		printk(ERR_PFX "%s: cannot read MAC address\n",
-		       pci_name(pdev));
+		err_msg = "cannot read MAC address";
 		err = -EIO;
 		goto error_out_reset;
 	}
@@ -2533,8 +2488,7 @@ typhoon_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	*(__be32 *)&dev->dev_addr[2] = htonl(le32_to_cpu(xp_resp[0].parm2));
 
 	if(!is_valid_ether_addr(dev->dev_addr)) {
-		printk(ERR_PFX "%s: Could not obtain valid ethernet address, "
-		       "aborting\n", pci_name(pdev));
+		err_msg = "Could not obtain valid ethernet address, aborting";
 		goto error_out_reset;
 	}
 
@@ -2543,8 +2497,7 @@ typhoon_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	 */
 	INIT_COMMAND_WITH_RESPONSE(&xp_cmd, TYPHOON_CMD_READ_VERSIONS);
 	if(typhoon_issue_command(tp, 1, &xp_cmd, 3, xp_resp) < 0) {
-		printk(ERR_PFX "%s: Could not get Sleep Image version\n",
-			pci_name(pdev));
+		err_msg = "Could not get Sleep Image version";
 		goto error_out_reset;
 	}
 
@@ -2561,8 +2514,7 @@ typhoon_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 		tp->capabilities |= TYPHOON_WAKEUP_NEEDS_RESET;
 
 	if(typhoon_sleep(tp, PCI_D3hot, 0) < 0) {
-		printk(ERR_PFX "%s: cannot put adapter to sleep\n",
-		       pci_name(pdev));
+		err_msg = "cannot put adapter to sleep";
 		err = -EIO;
 		goto error_out_reset;
 	}
@@ -2581,19 +2533,18 @@ typhoon_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	dev->features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
 	dev->features |= NETIF_F_TSO;
 
-	if(register_netdev(dev) < 0)
+	if(register_netdev(dev) < 0) {
+		err_msg = "unable to register netdev";
 		goto error_out_reset;
-
-	/* fixup our local name */
-	tp->name = dev->name;
+	}
 
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
@@ -2603,23 +2554,20 @@ typhoon_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
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
+			    sleep_ver >> 24, (sleep_ver >> 12) & 0xfff,
+			    sleep_ver & 0xfff, ver_string);
 	} else {
-		printk(KERN_WARNING "%s: Unknown Sleep Image version "
-			"(%u:%04x)\n", dev->name, xp_resp[0].numDesc,
-			le32_to_cpu(xp_resp[0].parm2));
+		netdev_warn(dev, "Unknown Sleep Image version (%u:%04x)\n",
+			    xp_resp[0].numDesc, le32_to_cpu(xp_resp[0].parm2));
 	}
 
 	return 0;
@@ -2641,6 +2589,7 @@ error_out_disable:
 error_out_dev:
 	free_netdev(dev);
 error_out:
+	pr_err("%s: %s\n", pci_name(pdev), err_msg);
 	return err;
 }
 
@@ -2665,7 +2614,7 @@ typhoon_remove_one(struct pci_dev *pdev)
 }
 
 static struct pci_driver typhoon_driver = {
-	.name		= DRV_MODULE_NAME,
+	.name		= KBUILD_MODNAME,
 	.id_table	= typhoon_pci_tbl,
 	.probe		= typhoon_init_one,
 	.remove		= __devexit_p(typhoon_remove_one),




