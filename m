From: Andrew Morton <akpm@osdl.org>
Subject: [patch] e100: early reset fix
Date: Mon, 22 Nov 2004 01:52:22 -0800
Message-ID: <20041122015222.43c2a31a.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: john.ronciak@intel.com, ganesh.venkatesan@intel.com,
        jesse.brandeburg@intel.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Gents, what do we think of the below fix?

Thanks.

My IBM A21P laptop is getting an IRQ storm at boot.

IRQ #11 is shared between USB and e100, and USB is getting in there first. 
Consequently, when e100 initialises the hardware, that interrupt line is ready
to go.  As soon as e100.c runs pci_set_master(), the interrupt hits the CPU. 
But of course the e100 driver isn't ready to handle the interrupt yet, so the
system disables IRQ #11.

This only happens on warm boots (/sbin/reboot).  Things work OK from power-on.
 So I assume that the BIOS is failing to fully reset the NIC and that some
sort of interrupt is internally pending.

The patch rearranges e100_probe() so that we issue e100_hw_reset() prior to
running pci_set_master(), and fixes the problem.

Note that e100_probe() is now running e100_hw_reset() twice - I didn't remove
the later call for general paranoia reasons.

eepro100.c has the same lockup, and needs a similar fix.

Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 25-akpm/drivers/net/e100.c |   18 ++++++++++--------
 1 files changed, 10 insertions(+), 8 deletions(-)

diff -puN drivers/net/e100.c~e100-early-reset-fix drivers/net/e100.c
--- 25/drivers/net/e100.c~e100-early-reset-fix	2004-11-22 01:44:59.031615736 -0800
+++ 25-akpm/drivers/net/e100.c	2004-11-22 01:44:59.036614976 -0800
@@ -2205,23 +2205,25 @@ static int __devinit e100_probe(struct p
 		goto err_out_disable_pdev;
 	}
 
+	nic->csr = ioremap(pci_resource_start(pdev, 0), sizeof(struct csr));
+	if(!nic->csr) {
+		DPRINTK(PROBE, ERR, "Cannot map device registers, aborting.\n");
+		err = -ENOMEM;
+		goto err_out_free_res;
+	}
+
+	e100_hw_reset(nic);
+
 	pci_set_master(pdev);
 
 	if((err = pci_set_dma_mask(pdev, 0xFFFFFFFFULL))) {
 		DPRINTK(PROBE, ERR, "No usable DMA configuration, aborting.\n");
-		goto err_out_free_res;
+		goto err_out_iounmap;
 	}
 
 	SET_MODULE_OWNER(netdev);
 	SET_NETDEV_DEV(netdev, &pdev->dev);
 
-	nic->csr = ioremap(pci_resource_start(pdev, 0), sizeof(struct csr));
-	if(!nic->csr) {
-		DPRINTK(PROBE, ERR, "Cannot map device registers, aborting.\n");
-		err = -ENOMEM;
-		goto err_out_free_res;
-	}
-
 	if(ent->driver_data)
 		nic->flags |= ich;
 	else
_
