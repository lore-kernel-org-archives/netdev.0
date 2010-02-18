From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next 14/15] drivers/net/typhoon.c: Use
 (pr|netdev)_<level> macro helpers
Date: Wed, 17 Feb 2010 18:18:24 -0800
Message-ID: <1266459504.8446.201.camel@Joe-Laptop.home>
References: <cover.1266454575.git.joe@perches.com>
	 <40a714d7757b0c24f3f0737f028d0242853f935b.1266454576.git.joe@perches.com>
	 <1266458370.5719.43.camel@obelisk.thedillows.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Dillow <dave@thedillows.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1266458370.5719.43.camel@obelisk.thedillows.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2010-02-17 at 20:59 -0500, David Dillow wrote:
> On Wed, 2010-02-17 at 17:02 -0800, Joe Perches wrote:
> > Use pr_<level>
> > Use netdev_<level>
> 
> The way the driver uses tp->name, most of the pr_<level> changes add an
> extraneous "typhoon:" to the front of the messages, which is not
> desirable. Your absolute change-over from PFX/ERR_PFX to pr_fmt()
> KBUILD_MODNAME misses the distinction between the message where the
> prefix is needed, and where it isn't.

Doesn't that mean that "%s: ...", tp->name should be removed?

> The netdev_<level> changes are much more palatable to me than the
> pr_<level> ones. I have no problem getting behind those.
> 
> > Coalesce long formats
> 
> I don't like these changes very much, either. I tend to work in 80 char
> terminals, and the wrap of a few characters is usually annoying.

Linus prefers formats not be split across multiple lines.
http://lkml.org/lkml/2008/2/23/251
I can change it back if you want, no matter to me.

> I don't have very much to do on this driver these days, so I'll defer to
> others on this issue. However, if you're going to be reformatting
> things, please pull things up a line when you shorten things enough to
> fit.

I try do that when I see it.

I prefer to use arguments on a separate line when all arguments
don't fit on a single one.

> But not here -- perhaps an 80 char limit, I've not looked at the patched
> file:
> 
> > @@ -1492,7 +1490,7 @@ typhoon_download_firmware(struct typhoon *tp)
> >  			if(typhoon_wait_interrupt(ioaddr) < 0 ||
> >  			   ioread32(ioaddr + TYPHOON_REG_STATUS) !=
> >  			   TYPHOON_STATUS_WAITING_FOR_SEGMENT) {
> > -				printk(KERN_ERR "%s: segment ready timeout\n",
> > +				pr_err("%s: segment ready timeout\n",
> >  				       tp->name);

Doesn't fit tp->name on 80 cols

> These __func__ conversions need to go.
> 
> > @@ -1901,16 +1898,16 @@ typhoon_sleep(struct typhoon *tp, pci_power_t state, __le16 events)
> >  	xp_cmd.parm1 = events;
> >  	err = typhoon_issue_command(tp, 1, &xp_cmd, 0, NULL);
> >  	if(err < 0) {
> > -		printk(KERN_ERR "%s: typhoon_sleep(): wake events cmd err %d\n",
> > -				tp->name, err);
> > +		pr_err("%s: %s(): wake events cmd err %d\n",
> > +		       tp->name, __func__, err);
> >  		return err;
> >  	}

why?  It makes it harder to get the function name wrong if
it's rewritten.

> Pull up tp->name?


> > @@ -2089,11 +2085,11 @@ typhoon_stop_runtime(struct typhoon *tp, int wait_type)
> >  	typhoon_issue_command(tp, 1, &xp_cmd, 0, NULL);
> >  
> >  	if(typhoon_wait_status(ioaddr, TYPHOON_STATUS_HALTED) < 0)
> > -		printk(KERN_ERR "%s: timed out waiting for 3XP to halt\n",
> > +		pr_err("%s: timed out waiting for 3XP to halt\n",
> >  		       tp->name);
> 
> Please don't change this printk(), or change the version string, as
> you'll have a redundant "typhoon:" in there now.

How about something like this (on top of previous)?

diff --git a/drivers/net/typhoon.c b/drivers/net/typhoon.c
index 843f986..6fa887a 100644
--- a/drivers/net/typhoon.c
+++ b/drivers/net/typhoon.c
@@ -136,7 +136,7 @@ static const int multicast_filter_limit = 32;
 #include "typhoon.h"
 
 static char version[] __devinitdata =
-    "typhoon.c: version " DRV_MODULE_VERSION " (" DRV_MODULE_RELDATE ")\n";
+    "version " DRV_MODULE_VERSION " (" DRV_MODULE_RELDATE ")\n";
 
 MODULE_AUTHOR("David Dillow <dave@thedillows.org>");
 MODULE_VERSION(DRV_MODULE_VERSION);
@@ -534,8 +534,8 @@ typhoon_process_response(struct typhoon *tp, int resp_size,
 		} else if(resp->cmd == TYPHOON_CMD_HELLO_RESP) {
 			typhoon_hello(tp);
 		} else {
-			pr_err("%s: dumping unexpected response 0x%04x:%d:0x%02x:0x%04x:%08x:%08x\n",
-			       tp->name, le16_to_cpu(resp->cmd),
+			pr_err("dumping unexpected response 0x%04x:%d:0x%02x:0x%04x:%08x:%08x\n",
+			       le16_to_cpu(resp->cmd),
 			       resp->numDesc, resp->flags,
 			       le16_to_cpu(resp->parm1),
 			       le32_to_cpu(resp->parm2),
@@ -605,8 +605,8 @@ typhoon_issue_command(struct typhoon *tp, int num_cmd, struct cmd_desc *cmd,
 	freeResp = typhoon_num_free_resp(tp);
 
 	if(freeCmd < num_cmd || freeResp < num_resp) {
-		pr_err("%s: no descs for cmd, had (needed) %d (%d) cmd, %d (%d) resp\n",
-		       tp->name, freeCmd, num_cmd, freeResp, num_resp);
+		pr_err("no descs for cmd, had (needed) %d (%d) cmd, %d (%d) resp\n",
+		       freeCmd, num_cmd, freeResp, num_resp);
 		err = -ENOMEM;
 		goto out;
 	}
@@ -731,7 +731,7 @@ typhoon_vlan_rx_register(struct net_device *dev, struct vlan_group *grp)
 		spin_unlock_bh(&tp->state_lock);
 		err = typhoon_issue_command(tp, 1, &xp_cmd, 0, NULL);
 		if(err < 0)
-			printk("%s: vlan offload error %d\n", tp->name, -err);
+			pr_err("vlan offload error %d\n", -err);
 		spin_lock_bh(&tp->state_lock);
 	}
 
@@ -1364,8 +1364,7 @@ typhoon_request_firmware(struct typhoon *tp)
 
 	err = request_firmware(&typhoon_fw, FIRMWARE_NAME, &tp->pdev->dev);
 	if (err) {
-		pr_err("%s: Failed to load firmware \"%s\"\n",
-		       tp->name, FIRMWARE_NAME);
+		pr_err("Failed to load firmware \"%s\"\n", FIRMWARE_NAME);
 		return err;
 	}
 
@@ -1400,7 +1399,7 @@ typhoon_request_firmware(struct typhoon *tp)
 	return 0;
 
 invalid_fw:
-	pr_err("%s: Invalid firmware image\n", tp->name);
+	pr_err("Invalid firmware image\n");
 	release_firmware(typhoon_fw);
 	typhoon_fw = NULL;
 	return -EINVAL;
@@ -1437,7 +1436,7 @@ typhoon_download_firmware(struct typhoon *tp)
 	err = -ENOMEM;
 	dpage = pci_alloc_consistent(pdev, PAGE_SIZE, &dpage_dma);
 	if(!dpage) {
-		pr_err("%s: no DMA mem for firmware\n", tp->name);
+		pr_err("no DMA mem for firmware\n");
 		goto err_out;
 	}
 
@@ -1450,7 +1449,7 @@ typhoon_download_firmware(struct typhoon *tp)
 
 	err = -ETIMEDOUT;
 	if(typhoon_wait_status(ioaddr, TYPHOON_STATUS_WAITING_FOR_HOST) < 0) {
-		pr_err("%s: card ready timeout\n", tp->name);
+		pr_err("card ready timeout\n");
 		goto err_out_irq;
 	}
 
@@ -1490,8 +1489,7 @@ typhoon_download_firmware(struct typhoon *tp)
 			if(typhoon_wait_interrupt(ioaddr) < 0 ||
 			   ioread32(ioaddr + TYPHOON_REG_STATUS) !=
 			   TYPHOON_STATUS_WAITING_FOR_SEGMENT) {
-				pr_err("%s: segment ready timeout\n",
-				       tp->name);
+				pr_err("segment ready timeout\n");
 				goto err_out_irq;
 			}
 
@@ -1524,15 +1522,15 @@ typhoon_download_firmware(struct typhoon *tp)
 	if(typhoon_wait_interrupt(ioaddr) < 0 ||
 	   ioread32(ioaddr + TYPHOON_REG_STATUS) !=
 	   TYPHOON_STATUS_WAITING_FOR_SEGMENT) {
-		pr_err("%s: final segment ready timeout\n", tp->name);
+		pr_err("final segment ready timeout\n");
 		goto err_out_irq;
 	}
 
 	iowrite32(TYPHOON_BOOTCMD_DNLD_COMPLETE, ioaddr + TYPHOON_REG_COMMAND);
 
 	if(typhoon_wait_status(ioaddr, TYPHOON_STATUS_WAITING_FOR_BOOT) < 0) {
-		pr_err("%s: boot ready timeout, status 0x%0x\n",
-		       tp->name, ioread32(ioaddr + TYPHOON_REG_STATUS));
+		pr_err("boot ready timeout, status 0x%0x\n",
+		       ioread32(ioaddr + TYPHOON_REG_STATUS));
 		goto err_out_irq;
 	}
 
@@ -1554,7 +1552,7 @@ typhoon_boot_3XP(struct typhoon *tp, u32 initial_status)
 	void __iomem *ioaddr = tp->ioaddr;
 
 	if(typhoon_wait_status(ioaddr, initial_status) < 0) {
-		pr_err("%s: boot ready timeout\n", tp->name);
+		pr_err("boot ready timeout\n");
 		goto out_timeout;
 	}
 
@@ -1565,8 +1563,8 @@ typhoon_boot_3XP(struct typhoon *tp, u32 initial_status)
 				ioaddr + TYPHOON_REG_COMMAND);
 
 	if(typhoon_wait_status(ioaddr, TYPHOON_STATUS_RUNNING) < 0) {
-		pr_err("%s: boot finish timeout (status 0x%x)\n",
-		       tp->name, ioread32(ioaddr + TYPHOON_REG_STATUS));
+		pr_err("boot finish timeout (status 0x%x)\n",
+		       ioread32(ioaddr + TYPHOON_REG_STATUS));
 		goto out_timeout;
 	}
 
@@ -1898,16 +1896,16 @@ typhoon_sleep(struct typhoon *tp, pci_power_t state, __le16 events)
 	xp_cmd.parm1 = events;
 	err = typhoon_issue_command(tp, 1, &xp_cmd, 0, NULL);
 	if(err < 0) {
-		pr_err("%s: %s(): wake events cmd err %d\n",
-		       tp->name, __func__, err);
+		pr_err("%s(): wake events cmd err %d\n",
+		       __func__, err);
 		return err;
 	}
 
 	INIT_COMMAND_NO_RESPONSE(&xp_cmd, TYPHOON_CMD_GOTO_SLEEP);
 	err = typhoon_issue_command(tp, 1, &xp_cmd, 0, NULL);
 	if(err < 0) {
-		pr_err("%s: %s(): sleep cmd err %d\n",
-		       tp->name, __func__, err);
+		pr_err("%s(): sleep cmd err %d\n",
+		       __func__, err);
 		return err;
 	}
 
@@ -1958,12 +1956,12 @@ typhoon_start_runtime(struct typhoon *tp)
 
 	err = typhoon_download_firmware(tp);
 	if(err < 0) {
-		printk("%s: cannot load runtime on 3XP\n", tp->name);
+		pr_err("cannot load runtime on 3XP\n");
 		goto error_out;
 	}
 
 	if(typhoon_boot_3XP(tp, TYPHOON_STATUS_WAITING_FOR_BOOT) < 0) {
-		printk("%s: cannot boot 3XP\n", tp->name);
+		pr_err("cannot boot 3XP\n");
 		err = -EIO;
 		goto error_out;
 	}
@@ -2067,8 +2065,7 @@ typhoon_stop_runtime(struct typhoon *tp, int wait_type)
 	}
 
 	if(i == TYPHOON_WAIT_TIMEOUT)
-		pr_err("%s: halt timed out waiting for Tx to complete\n",
-		       tp->name);
+		pr_err("halt timed out waiting for Tx to complete\n");
 
 	INIT_COMMAND_NO_RESPONSE(&xp_cmd, TYPHOON_CMD_TX_DISABLE);
 	typhoon_issue_command(tp, 1, &xp_cmd, 0, NULL);
@@ -2085,11 +2082,10 @@ typhoon_stop_runtime(struct typhoon *tp, int wait_type)
 	typhoon_issue_command(tp, 1, &xp_cmd, 0, NULL);
 
 	if(typhoon_wait_status(ioaddr, TYPHOON_STATUS_HALTED) < 0)
-		pr_err("%s: timed out waiting for 3XP to halt\n",
-		       tp->name);
+		pr_err("timed out waiting for 3XP to halt\n");
 
 	if(typhoon_reset(ioaddr, wait_type) < 0) {
-		pr_err("%s: unable to reset 3XP\n", tp->name);
+		pr_err("unable to reset 3XP\n");
 		return -ETIMEDOUT;
 	}
 
@@ -2376,8 +2372,7 @@ typhoon_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	dev = alloc_etherdev(sizeof(*tp));
 	if(dev == NULL) {
-		pr_err("%s: unable to alloc new net device\n",
-		       pci_name(pdev));
+		pr_err("%s: unable to alloc new net device\n", pci_name(pdev));
 		err = -ENOMEM;
 		goto error_out;
 	}
@@ -2385,8 +2380,7 @@ typhoon_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	err = pci_enable_device(pdev);
 	if(err < 0) {
-		pr_err("%s: unable to enable device\n",
-		       pci_name(pdev));
+		pr_err("%s: unable to enable device\n", pci_name(pdev));
 		goto error_out_dev;
 	}
 
@@ -2398,8 +2392,7 @@ typhoon_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	err = pci_set_dma_mask(pdev, DMA_BIT_MASK(32));
 	if(err < 0) {
-		pr_err("%s: No usable DMA configuration\n",
-		       pci_name(pdev));
+		pr_err("%s: No usable DMA configuration\n", pci_name(pdev));
 		goto error_out_mwi;
 	}
 
@@ -2432,8 +2425,7 @@ typhoon_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	err = pci_request_regions(pdev, "typhoon");
 	if(err < 0) {
-		pr_err("%s: could not request regions\n",
-		       pci_name(pdev));
+		pr_err("%s: could not request regions\n", pci_name(pdev));
 		goto error_out_mwi;
 	}
 
@@ -2455,8 +2447,7 @@ typhoon_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	shared = pci_alloc_consistent(pdev, sizeof(struct typhoon_shared),
 				      &shared_dma);
 	if(!shared) {
-		pr_err("%s: could not allocate DMA memory\n",
-		       pci_name(pdev));
+		pr_err("%s: could not allocate DMA memory\n", pci_name(pdev));
 		err = -ENOMEM;
 		goto error_out_remap;
 	}
@@ -2493,7 +2484,7 @@ typhoon_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	/* dev->name is not valid until we register, but we need to
 	 * use some common routines to initialize the card. So that those
-	 * routines print the right name, we keep our oun pointer to the name
+	 * routines print the right name, we keep our own pointer to the name
 	 */
 	tp->name = pci_name(pdev);
 
@@ -2501,16 +2492,14 @@ typhoon_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	typhoon_init_rings(tp);
 
 	if(typhoon_boot_3XP(tp, TYPHOON_STATUS_WAITING_FOR_HOST) < 0) {
-		pr_err("%s: cannot boot 3XP sleep image\n",
-		       pci_name(pdev));
+		pr_err("%s: cannot boot 3XP sleep image\n", pci_name(pdev));
 		err = -EIO;
 		goto error_out_reset;
 	}
 
 	INIT_COMMAND_WITH_RESPONSE(&xp_cmd, TYPHOON_CMD_READ_MAC_ADDRESS);
 	if(typhoon_issue_command(tp, 1, &xp_cmd, 1, xp_resp) < 0) {
-		pr_err("%s: cannot read MAC address\n",
-		       pci_name(pdev));
+		pr_err("%s: cannot read MAC address\n", pci_name(pdev));
 		err = -EIO;
 		goto error_out_reset;
 	}
@@ -2530,7 +2519,7 @@ typhoon_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	INIT_COMMAND_WITH_RESPONSE(&xp_cmd, TYPHOON_CMD_READ_VERSIONS);
 	if(typhoon_issue_command(tp, 1, &xp_cmd, 3, xp_resp) < 0) {
 		pr_err("%s: Could not get Sleep Image version\n",
-			pci_name(pdev));
+		       pci_name(pdev));
 		goto error_out_reset;
 	}
 
@@ -2547,8 +2536,7 @@ typhoon_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 		tp->capabilities |= TYPHOON_WAKEUP_NEEDS_RESET;
 
 	if(typhoon_sleep(tp, PCI_D3hot, 0) < 0) {
-		pr_err("%s: cannot put adapter to sleep\n",
-		       pci_name(pdev));
+		pr_err("%s: cannot put adapter to sleep\n", pci_name(pdev));
 		err = -EIO;
 		goto error_out_reset;
 	}
