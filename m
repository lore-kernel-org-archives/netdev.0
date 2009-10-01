From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] sky2: irqname based on pci address
Date: Thu, 1 Oct 2009 10:11:46 -0700
Message-ID: <20091001101146.3368b4a4@s6510>
References: <20090922120127.14242.71353.stgit@localhost.localdomain>
	<20090922092826.5302225c@s6510>
	<20091001122720.3822bdd3@leela>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Michal Schmidt <mschmidt@redhat.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:54597 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754299AbZJARLn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Oct 2009 13:11:43 -0400
In-Reply-To: <20091001122720.3822bdd3@leela>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is based on Michal Schmidt fix for skge.

Most network drivers request their IRQ when the interface is activated.
sky2 does it in ->probe() instead, because it can work with two-port
cards where the two net_devices use the same IRQ. This works fine most
of the time, except in some situations when the interface gets renamed.
Consider this example:

1. modprobe sky2
   The card is detected as eth0 and requests IRQ 17. Directory
   /proc/irq/17/eth0 is created.
2. There is an udev rule which says this interface should be called
   eth1, so udev renames eth0 -> eth1.
3. modprobe 8139too
   The Realtek card is detected as eth0. It will be using IRQ 17 too.
4. ip link set eth0 up
   Now 8139too requests IRQ 17.

The result is:
WARNING: at fs/proc/generic.c:590 proc_register ...
proc_dir_entry '17/eth0' already registered

The fix is for sky2 to name the irq based on the pci device, as is done
by some other devices DRM, infiniband, ...  ie. sky2@pci:0000:00:00

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/sky2.c	2009-10-01 09:51:30.604556725 -0700
+++ b/drivers/net/sky2.c	2009-10-01 09:56:38.893342161 -0700
@@ -4487,13 +4487,16 @@ static int __devinit sky2_probe(struct p
 	wol_default = device_may_wakeup(&pdev->dev) ? WAKE_MAGIC : 0;
 
 	err = -ENOMEM;
-	hw = kzalloc(sizeof(*hw), GFP_KERNEL);
+
+	hw = kzalloc(sizeof(*hw) + strlen(DRV_NAME "@pci:")
+		     + strlen(pci_name(pdev)) + 1, GFP_KERNEL);
 	if (!hw) {
 		dev_err(&pdev->dev, "cannot allocate hardware struct\n");
 		goto err_out_free_regions;
 	}
 
 	hw->pdev = pdev;
+	sprintf(hw->irq_name, DRV_NAME "@pci:%s", pci_name(pdev));
 
 	hw->regs = ioremap_nocache(pci_resource_start(pdev, 0), 0x4000);
 	if (!hw->regs) {
@@ -4539,7 +4542,7 @@ static int __devinit sky2_probe(struct p
 
 	err = request_irq(pdev->irq, sky2_intr,
 			  (hw->flags & SKY2_HW_USE_MSI) ? 0 : IRQF_SHARED,
-			  dev->name, hw);
+			  hw->irq_name, hw);
 	if (err) {
 		dev_err(&pdev->dev, "cannot assign irq %d\n", pdev->irq);
 		goto err_out_unregister;
--- a/drivers/net/sky2.h	2009-10-01 09:51:17.553559116 -0700
+++ b/drivers/net/sky2.h	2009-10-01 09:51:42.069510492 -0700
@@ -2085,6 +2085,8 @@ struct sky2_hw {
 	struct timer_list    watchdog_timer;
 	struct work_struct   restart_work;
 	wait_queue_head_t    msi_wait;
+
+	char		     irq_name[0];
 };
 
 static inline int sky2_is_copper(const struct sky2_hw *hw)
