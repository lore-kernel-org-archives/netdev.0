From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] skge: use unique IRQ name
Date: Thu, 1 Oct 2009 09:50:32 -0700
Message-ID: <20091001095032.17271dcc@s6510>
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
Received: from mail.vyatta.com ([76.74.103.46]:53548 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755356AbZJAQu3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Oct 2009 12:50:29 -0400
In-Reply-To: <20091001122720.3822bdd3@leela>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(revised to use pci:)

From: Michal Schmidt <mschmidt@redhat.com>

Most network drivers request their IRQ when the interface is activated.
skge does it in ->probe() instead, because it can work with two-port
cards where the two net_devices use the same IRQ. This works fine most
of the time, except in some situations when the interface gets renamed.
Consider this example:

1. modprobe skge
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
...
And "ls /proc/irq/17" shows two subdirectories, both called eth0.

Fix it by using a unique name for skge's IRQ, based on the PCI address.
The naming from the example then looks like this:
$ grep skge /proc/interrupts
 17:        169   IO-APIC-fasteoi   skge@pci:0000:00:0a.0, eth0

irqbalance daemon will have to be taught to recognize "skge" as an
Ethernet interrupt. This will be a one-liner addition in classify.c. I
will send a patch to irqbalance if this change is accepted.

Signed-off-by: Michal Schmidt <mschmidt@redhat.com>
Acked-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/skge.c	2009-10-01 09:36:21.893095582 -0700
+++ b/drivers/net/skge.c	2009-10-01 09:46:22.064555679 -0700
@@ -3895,6 +3895,7 @@ static int __devinit skge_probe(struct p
 	struct net_device *dev, *dev1;
 	struct skge_hw *hw;
 	int err, using_dac = 0;
+	size_t irq_name_len;
 
 	err = pci_enable_device(pdev);
 	if (err) {
@@ -3935,11 +3936,14 @@ static int __devinit skge_probe(struct p
 #endif
 
 	err = -ENOMEM;
-	hw = kzalloc(sizeof(*hw), GFP_KERNEL);
+	/* space for skge@pci:0000:04:00.0 */
+	irq_name_len = strlen(DRV_NAME) + strlen(dev_name(&pdev->dev)) + 6;
+	hw = kzalloc(sizeof(*hw) + irq_name_len, GFP_KERNEL);
 	if (!hw) {
 		dev_err(&pdev->dev, "cannot allocate hardware struct\n");
 		goto err_out_free_regions;
 	}
+	sprintf(hw->irq_name, DRV_NAME "@pci:%s", pci_name(pdev));
 
 	hw->pdev = pdev;
 	spin_lock_init(&hw->hw_lock);
@@ -3974,7 +3978,7 @@ static int __devinit skge_probe(struct p
 		goto err_out_free_netdev;
 	}
 
-	err = request_irq(pdev->irq, skge_intr, IRQF_SHARED, dev->name, hw);
+	err = request_irq(pdev->irq, skge_intr, IRQF_SHARED, hw->irq_name, hw);
 	if (err) {
 		dev_err(&pdev->dev, "%s: cannot assign irq %d\n",
 		       dev->name, pdev->irq);
--- a/drivers/net/skge.h	2009-10-01 09:34:51.036505545 -0700
+++ b/drivers/net/skge.h	2009-10-01 09:47:38.096558002 -0700
@@ -2423,6 +2423,8 @@ struct skge_hw {
 	u16		     phy_addr;
 	spinlock_t	     phy_lock;
 	struct tasklet_struct phy_task;
+
+	char		     irq_name[0]; /* skge@pci:000:04:00.0 */
 };
 
 enum pause_control {
