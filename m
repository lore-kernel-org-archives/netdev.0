From: Luca Tettamanti <kronos.it@gmail.com>
Subject: Re: [PATCH 0/4] atl1: Revised Attansic L1 ethernet driver
Date: Sat, 25 Nov 2006 23:43:58 +0100
Message-ID: <20061125224358.GA29403@dreamland.darkstar.lan>
References: <20061121202541.GA23036@dreamland.darkstar.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kronos.it@gmail.com, Chris Snook <csnook@redhat.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S967279AbWKYWoO@vger.kernel.org>
To: Jay Cliburn <jacliburn@bellsouth.net>
Content-Disposition: inline
In-Reply-To: <20061121202541.GA23036@dreamland.darkstar.lan>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

Luca Tettamanti <kronos.it@gmail.com> ha scritto:
> Chris Snook <csnook@redhat.com> ha scritto:
>> 
>> I've been working on this with Jay since his initial submission.  Thanks 
>> to everyone who has provided feedback on the resubmit.  We're currently 
>> quite short on actual testers, since the chip only seems to be on Asus 
>> M2V motherboards at present.  Please let me and Jay know if you have one 
>> of these boards and would like to test and/or have encountered bugs.
> 
> Asus P5B-E also has L1 chip. I'll get the board in a few days and I'll
> test whatever patch you throw at me ;)

Got the board, done some basic testing: so far so good :)

The controller also supports MSI and (at least with my chipset - G965)
it works fine:

218:      80649          0   PCI-MSI-edge      eth1

which is nice, otherwise it ends up sharing the IRQ with SATA and USB.

I also have a small patch:

On probe failure and on removal the device should be disabled:

Signed-Off-By: Luca Tettamanti <kronos.it@gmail.com> 

---
 drivers/net/atl1/atl1_main.c |    8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/net/atl1/atl1_main.c b/drivers/net/atl1/atl1_main.c
index 167e28c..4883111 100644
--- a/drivers/net/atl1/atl1_main.c
+++ b/drivers/net/atl1/atl1_main.c
@@ -2224,14 +2224,14 @@ static int __devinit at_probe(struct pci
 			printk(KERN_DEBUG 
 				"%s: no usable DMA configuration, aborting\n",
  				at_driver_name);
-			return err;
+			goto err_dma;
 		}
 		pci_using_64 = false;
 	}
 	/* Mark all PCI regions associated with PCI device 
 	 * pdev as being reserved by owner at_driver_name */
 	if ((err = pci_request_regions(pdev, at_driver_name)))
-		return err;
+		goto err_request_regions;
 	/* Enables bus-mastering on the device and calls 
 	 * pcibios_set_master to do the needed arch specific settings */
 	pci_set_master(pdev);
@@ -2384,6 +2384,9 @@ static int __devinit at_probe(struct pci
 	free_netdev(netdev);
       err_alloc_etherdev:
 	pci_release_regions(pdev);
+      err_request_regions:
+      err_dma:
+	pci_disable_device(pdev);
 	return err;
 }
 
@@ -2410,6 +2413,7 @@ static void __devexit at_remove(struct p
 	iounmap(adapter->hw.hw_addr);
 	pci_release_regions(pdev);
 	free_netdev(netdev);
+	pci_disable_device(pdev);
 }
 
 static int at_suspend(struct pci_dev *pdev, pm_message_t state)


Luca
-- 
Not an editor command: Wq
