From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next 14/15] drivers/net/typhoon.c: Use
 (pr|netdev)_<level> macro helpers
Date: Wed, 17 Feb 2010 18:53:51 -0800
Message-ID: <1266461631.8446.227.camel@Joe-Laptop.home>
References: <cover.1266454575.git.joe@perches.com>
	 <40a714d7757b0c24f3f0737f028d0242853f935b.1266454576.git.joe@perches.com>
	 <1266458370.5719.43.camel@obelisk.thedillows.org>
	 <1266459504.8446.201.camel@Joe-Laptop.home>
	 <1266460221.5719.60.camel@obelisk.thedillows.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net
To: David Dillow <dave@thedillows.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1082 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932784Ab0BRCxw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Feb 2010 21:53:52 -0500
In-Reply-To: <1266460221.5719.60.camel@obelisk.thedillows.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-02-17 at 21:30 -0500, David Dillow wrote:
> > Doesn't that mean that "%s: ...", tp->name should be removed?
> No, because the routines that use tp->name are called both before and
> after the netdev is registered. Prior to that time, it contains the PCI
> slot name -- "00:01.0" etc -- so that the user can determine which card
> is acting up. Once the card is registered, it has "ethX" to use a
> commonly expected name for the card.

I think those messages should just use netdev_<level> then.

If not registered, "(unregistered net_device)" and
the PCI slot are emitted.

>From include/linux/netdevice.h:

static inline const char *netdev_name(const struct net_device *dev)
{
	if (dev->reg_state != NETREG_REGISTERED)
		return "(unregistered net_device)";
	return dev->name;
}

#define netdev_printk(level, netdev, format, args...)		\
	dev_printk(level, (netdev)->dev.parent,			\
		   "%s: " format,				\
		   netdev_name(netdev), ##args)


> > > These __func__ conversions need to go.
> > > 
> > > > @@ -1901,16 +1898,16 @@ typhoon_sleep(struct typhoon *tp, pci_power_t state, __le16 events)
> > > >  	xp_cmd.parm1 = events;
> > > >  	err = typhoon_issue_command(tp, 1, &xp_cmd, 0, NULL);
> > > >  	if(err < 0) {
> > > > -		printk(KERN_ERR "%s: typhoon_sleep(): wake events cmd err %d\n",
> > > > -				tp->name, err);
> > > > +		pr_err("%s: %s(): wake events cmd err %d\n",
> > > > +		       tp->name, __func__, err);
> > > >  		return err;
> > > >  	}
> > 
> > why?  It makes it harder to get the function name wrong if
> > it's rewritten.
> 
> This driver is rarely touched, except for API changes and such cleanups
> people like to make from time to time. It is unlikely to be renamed,
> adds code, and looks ugly. It may make sense for other printks in
> functions that are in flux, but not here.

> > How about something like this (on top of previous)?
> The version change is fine, but you shouldn't get rid of tp->name.

How about this?

diff --git a/drivers/net/typhoon.c b/drivers/net/typhoon.c
index 843f986..e41fb9e 100644
--- a/drivers/net/typhoon.c
+++ b/drivers/net/typhoon.c
@@ -161,7 +161,7 @@ module_param(use_mmio, int, 0);
 #endif
 
 struct typhoon_card_info {
-	char *name;
+	const char *name;
 	int capabilities;
 };
 
@@ -534,12 +534,13 @@ typhoon_process_response(struct typhoon *tp, int resp_size,
 		} else if(resp->cmd == TYPHOON_CMD_HELLO_RESP) {
 			typhoon_hello(tp);
 		} else {
-			pr_err("%s: dumping unexpected response 0x%04x:%d:0x%02x:0x%04x:%08x:%08x\n",
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
@@ -605,8 +606,8 @@ typhoon_issue_command(struct typhoon *tp, int num_cmd, struct cmd_desc *cmd,
 	freeResp = typhoon_num_free_resp(tp);
 
 	if(freeCmd < num_cmd || freeResp < num_resp) {
-		pr_err("%s: no descs for cmd, had (needed) %d (%d) cmd, %d (%d) resp\n",
-		       tp->name, freeCmd, num_cmd, freeResp, num_resp);
+		netdev_err(tp->dev, "no descs for cmd, had (needed) %d (%d) cmd, %d (%d) resp\n",
+			   freeCmd, num_cmd, freeResp, num_resp);
 		err = -ENOMEM;
 		goto out;
 	}
@@ -731,7 +732,7 @@ typhoon_vlan_rx_register(struct net_device *dev, struct vlan_group *grp)
 		spin_unlock_bh(&tp->state_lock);
 		err = typhoon_issue_command(tp, 1, &xp_cmd, 0, NULL);
 		if(err < 0)
-			printk("%s: vlan offload error %d\n", tp->name, -err);
+			netdev_err(tp->dev, "vlan offload error %d\n", -err);
 		spin_lock_bh(&tp->state_lock);
 	}
 
@@ -1364,8 +1365,8 @@ typhoon_request_firmware(struct typhoon *tp)
 
 	err = request_firmware(&typhoon_fw, FIRMWARE_NAME, &tp->pdev->dev);
 	if (err) {
-		pr_err("%s: Failed to load firmware \"%s\"\n",
-		       tp->name, FIRMWARE_NAME);
+		netdev_err(tp->dev, "Failed to load firmware \"%s\"\n",
+			   FIRMWARE_NAME);
 		return err;
 	}
 
@@ -1400,7 +1401,7 @@ typhoon_request_firmware(struct typhoon *tp)
 	return 0;
 
 invalid_fw:
-	pr_err("%s: Invalid firmware image\n", tp->name);
+	netdev_err(tp->dev, "Invalid firmware image\n");
 	release_firmware(typhoon_fw);
 	typhoon_fw = NULL;
 	return -EINVAL;
@@ -1437,7 +1438,7 @@ typhoon_download_firmware(struct typhoon *tp)
 	err = -ENOMEM;
 	dpage = pci_alloc_consistent(pdev, PAGE_SIZE, &dpage_dma);
 	if(!dpage) {
-		pr_err("%s: no DMA mem for firmware\n", tp->name);
+		netdev_err(tp->dev, "no DMA mem for firmware\n");
 		goto err_out;
 	}
 
@@ -1450,7 +1451,7 @@ typhoon_download_firmware(struct typhoon *tp)
 
 	err = -ETIMEDOUT;
 	if(typhoon_wait_status(ioaddr, TYPHOON_STATUS_WAITING_FOR_HOST) < 0) {
-		pr_err("%s: card ready timeout\n", tp->name);
+		netdev_err(tp->dev, "card ready timeout\n");
 		goto err_out_irq;
 	}
 
@@ -1490,8 +1491,7 @@ typhoon_download_firmware(struct typhoon *tp)
 			if(typhoon_wait_interrupt(ioaddr) < 0 ||
 			   ioread32(ioaddr + TYPHOON_REG_STATUS) !=
 			   TYPHOON_STATUS_WAITING_FOR_SEGMENT) {
-				pr_err("%s: segment ready timeout\n",
-				       tp->name);
+				netdev_err(tp->dev, "segment ready timeout\n");
 				goto err_out_irq;
 			}
 
@@ -1524,15 +1524,15 @@ typhoon_download_firmware(struct typhoon *tp)
 	if(typhoon_wait_interrupt(ioaddr) < 0 ||
 	   ioread32(ioaddr + TYPHOON_REG_STATUS) !=
 	   TYPHOON_STATUS_WAITING_FOR_SEGMENT) {
-		pr_err("%s: final segment ready timeout\n", tp->name);
+		netdev_err(tp->dev, "final segment ready timeout\n");
 		goto err_out_irq;
 	}
 
 	iowrite32(TYPHOON_BOOTCMD_DNLD_COMPLETE, ioaddr + TYPHOON_REG_COMMAND);
 
 	if(typhoon_wait_status(ioaddr, TYPHOON_STATUS_WAITING_FOR_BOOT) < 0) {
-		pr_err("%s: boot ready timeout, status 0x%0x\n",
-		       tp->name, ioread32(ioaddr + TYPHOON_REG_STATUS));
+		netdev_err(tp->dev, "boot ready timeout, status 0x%0x\n",
+			   ioread32(ioaddr + TYPHOON_REG_STATUS));
 		goto err_out_irq;
 	}
 
@@ -1554,7 +1554,7 @@ typhoon_boot_3XP(struct typhoon *tp, u32 initial_status)
 	void __iomem *ioaddr = tp->ioaddr;
 
 	if(typhoon_wait_status(ioaddr, initial_status) < 0) {
-		pr_err("%s: boot ready timeout\n", tp->name);
+		netdev_err(tp->dev, "boot ready timeout\n");
 		goto out_timeout;
 	}
 
@@ -1565,8 +1565,8 @@ typhoon_boot_3XP(struct typhoon *tp, u32 initial_status)
 				ioaddr + TYPHOON_REG_COMMAND);
 
 	if(typhoon_wait_status(ioaddr, TYPHOON_STATUS_RUNNING) < 0) {
-		pr_err("%s: boot finish timeout (status 0x%x)\n",
-		       tp->name, ioread32(ioaddr + TYPHOON_REG_STATUS));
+		netdev_err(tp->dev, "boot finish timeout (status 0x%x)\n",
+			   ioread32(ioaddr + TYPHOON_REG_STATUS));
 		goto out_timeout;
 	}
 
@@ -1898,16 +1898,15 @@ typhoon_sleep(struct typhoon *tp, pci_power_t state, __le16 events)
 	xp_cmd.parm1 = events;
 	err = typhoon_issue_command(tp, 1, &xp_cmd, 0, NULL);
 	if(err < 0) {
-		pr_err("%s: %s(): wake events cmd err %d\n",
-		       tp->name, __func__, err);
+		netdev_err(tp->dev, "typhoon_sleep(): wake events cmd err %d\n",
+			   err);
 		return err;
 	}
 
 	INIT_COMMAND_NO_RESPONSE(&xp_cmd, TYPHOON_CMD_GOTO_SLEEP);
 	err = typhoon_issue_command(tp, 1, &xp_cmd, 0, NULL);
 	if(err < 0) {
-		pr_err("%s: %s(): sleep cmd err %d\n",
-		       tp->name, __func__, err);
+		netdev_err(tp->dev, "typhoon_sleep(): sleep cmd err %d\n", err);
 		return err;
 	}
 
@@ -1958,12 +1957,12 @@ typhoon_start_runtime(struct typhoon *tp)
 
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
@@ -2067,8 +2066,7 @@ typhoon_stop_runtime(struct typhoon *tp, int wait_type)
 	}
 
 	if(i == TYPHOON_WAIT_TIMEOUT)
-		pr_err("%s: halt timed out waiting for Tx to complete\n",
-		       tp->name);
+		netdev_err(tp->dev, "halt timed out waiting for Tx to complete\n");
 
 	INIT_COMMAND_NO_RESPONSE(&xp_cmd, TYPHOON_CMD_TX_DISABLE);
 	typhoon_issue_command(tp, 1, &xp_cmd, 0, NULL);
@@ -2085,11 +2083,10 @@ typhoon_stop_runtime(struct typhoon *tp, int wait_type)
 	typhoon_issue_command(tp, 1, &xp_cmd, 0, NULL);
 
 	if(typhoon_wait_status(ioaddr, TYPHOON_STATUS_HALTED) < 0)
-		pr_err("%s: timed out waiting for 3XP to halt\n",
-		       tp->name);
+		netdev_err(tp->dev, "timed out waiting for 3XP to halt\n");
 
 	if(typhoon_reset(ioaddr, wait_type) < 0) {
-		pr_err("%s: unable to reset 3XP\n", tp->name);
+		netdev_err(tp->dev, "unable to reset 3XP\n");
 		return -ETIMEDOUT;
 	}
 
@@ -2385,55 +2382,48 @@ typhoon_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	err = pci_enable_device(pdev);
 	if(err < 0) {
-		pr_err("%s: unable to enable device\n",
-		       pci_name(pdev));
+		netdev_err(dev, "unable to enable device\n");
 		goto error_out_dev;
 	}
 
 	err = pci_set_mwi(pdev);
 	if(err < 0) {
-		pr_err("%s: unable to set MWI\n", pci_name(pdev));
+		netdev_err(dev, "unable to set MWI\n");
 		goto error_out_disable;
 	}
 
 	err = pci_set_dma_mask(pdev, DMA_BIT_MASK(32));
 	if(err < 0) {
-		pr_err("%s: No usable DMA configuration\n",
-		       pci_name(pdev));
+		netdev_err(dev, "No usable DMA configuration\n");
 		goto error_out_mwi;
 	}
 
 	/* sanity checks on IO and MMIO BARs
 	 */
 	if(!(pci_resource_flags(pdev, 0) & IORESOURCE_IO)) {
-		pr_err("%s: region #1 not a PCI IO resource, aborting\n",
-		       pci_name(pdev));
+		netdev_err(dev, "region #1 not a PCI IO resource, aborting\n");
 		err = -ENODEV;
 		goto error_out_mwi;
 	}
 	if(pci_resource_len(pdev, 0) < 128) {
-		pr_err("%s: Invalid PCI IO region size, aborting\n",
-		       pci_name(pdev));
+		netdev_err(dev, "Invalid PCI IO region size, aborting\n");
 		err = -ENODEV;
 		goto error_out_mwi;
 	}
 	if(!(pci_resource_flags(pdev, 1) & IORESOURCE_MEM)) {
-		pr_err("%s: region #1 not a PCI MMIO resource, aborting\n",
-		       pci_name(pdev));
+		netdev_err(dev, "region #1 not a PCI MMIO resource, aborting\n");
 		err = -ENODEV;
 		goto error_out_mwi;
 	}
 	if(pci_resource_len(pdev, 1) < 128) {
-		pr_err("%s: Invalid PCI MMIO region size, aborting\n",
-		       pci_name(pdev));
+		netdev_err(dev, "Invalid PCI MMIO region size, aborting\n");
 		err = -ENODEV;
 		goto error_out_mwi;
 	}
 
 	err = pci_request_regions(pdev, "typhoon");
 	if(err < 0) {
-		pr_err("%s: could not request regions\n",
-		       pci_name(pdev));
+		netdev_err(dev, "could not request regions\n");
 		goto error_out_mwi;
 	}
 
@@ -2444,8 +2434,7 @@ typhoon_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	ioaddr = pci_iomap(pdev, use_mmio, 128);
 	if (!ioaddr) {
-		pr_err("%s: cannot remap registers, aborting\n",
-		       pci_name(pdev));
+		netdev_err(dev, "cannot remap registers, aborting\n");
 		err = -EIO;
 		goto error_out_regions;
 	}
@@ -2455,8 +2444,7 @@ typhoon_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	shared = pci_alloc_consistent(pdev, sizeof(struct typhoon_shared),
 				      &shared_dma);
 	if(!shared) {
-		pr_err("%s: could not allocate DMA memory\n",
-		       pci_name(pdev));
+		netdev_err(dev, "could not allocate DMA memory\n");
 		err = -ENOMEM;
 		goto error_out_remap;
 	}
@@ -2479,7 +2467,7 @@ typhoon_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	 * 5) Put the card to sleep.
 	 */
 	if (typhoon_reset(ioaddr, WaitSleep) < 0) {
-		pr_err("%s: could not reset 3XP\n", pci_name(pdev));
+		netdev_err(dev, "could not reset 3XP\n");
 		err = -EIO;
 		goto error_out_dma;
 	}
@@ -2491,12 +2479,6 @@ typhoon_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
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
 
@@ -2570,9 +2552,6 @@ typhoon_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	if(register_netdev(dev) < 0)
 		goto error_out_reset;
 
-	/* fixup our local name */
-	tp->name = dev->name;
-
 	pci_set_drvdata(pdev, dev);
 
 	netdev_info(dev, "%s at %s 0x%llx, %pM\n",


