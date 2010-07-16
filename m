From: Shreyas Bhatewara <sbhatewara@vmware.com>
Subject: Re: [PATCH 2.6.35-rc1] net-next: vmxnet3 fixes [5/5] Respect the
 interrupt type in VM configuration
Date: Thu, 15 Jul 2010 18:21:27 -0700 (PDT)
Message-ID: <alpine.LRH.2.00.1007151458580.10176@localhost.localdomain>
References: <alpine.LRH.2.00.1007070202080.5939@localhost.localdomain> <alpine.LRH.2.00.1007070232300.5939@localhost.localdomain> <alpine.LRH.2.00.1007131750060.32055@localhost.localdomain> <20100714.141118.260092331.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"pv-drivers@vmware.com" <pv-drivers@vmware.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-outbound-2.vmware.com ([65.115.85.73]:49279 "EHLO
	smtp-outbound-2.vmware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S935145Ab0GPBV1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jul 2010 21:21:27 -0400
In-Reply-To: <20100714.141118.260092331.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Wed, 14 Jul 2010, David Miller wrote:

> From: Shreyas Bhatewara <sbhatewara@vmware.com>
> Date: Tue, 13 Jul 2010 17:51:39 -0700 (PDT)
> 
> > 
> > Do not ignore interrupt type in VM configuration
> > 
> > When interrupt type is not auto, do not ignore the interrupt type set from
> > VM configuration.
> > Driver may not always respect the interrupt type in configuration but it 
> > will certainly try to. Eg: if MSIx is configured and enabling MSIx fails 
> > in driver, it fall back on MSI and then on INTx.
> > 
> > Signed-off-by: Shreyas Bhatewara <sbhatewara@vmware.com>
>  ...
> > @@ -291,7 +291,7 @@ vmxnet3_set_flags(struct net_device *netdev, u32 data)
> >  
> >  		/* update harware LRO capability accordingly */
> >  		if (lro_requested)
> > -			adapter->shared->devRead.misc.uptFeatures &= UPT1_F_LRO;
> > +			adapter->shared->devRead.misc.uptFeatures |= UPT1_F_LRO;
> >  		else
> 
> This change has nothing to do with respecting the VM interrupt setting.
> 
> Do not stuff unrelated changes into a commit.
> ...

Sorry about that. This is a fix I wanted to add and I did not operate stg
correctly. Reposting the patch w/o the feature update bits.


---

Respect the interrupt type set in VM configuration.

When interrupt type is not auto, do not ignore the interrupt type set from
VM configuration.

Signed-off-by: Shreyas Bhatewara <sbhatewara@vmware.com>

---


 drivers/net/vmxnet3/vmxnet3_drv.c |   13 ++++++++++---
 drivers/net/vmxnet3/vmxnet3_int.h |    4 ++--
 2 files changed, 12 insertions(+), 5 deletions(-)

diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vmxnet3_drv.c
index c4d7e42..9282635 100644
--- a/drivers/net/vmxnet3/vmxnet3_drv.c
+++ b/drivers/net/vmxnet3/vmxnet3_drv.c
@@ -2357,9 +2357,13 @@ vmxnet3_alloc_intr_resources(struct vmxnet3_adapter *adapter)
 	adapter->intr.mask_mode = (cfg >> 2) & 0x3;
 
 	if (adapter->intr.type == VMXNET3_IT_AUTO) {
-		int err;
+		adapter->intr.type = VMXNET3_IT_MSIX;
+	}
 
 #ifdef CONFIG_PCI_MSI
+	if (adapter->intr.type == VMXNET3_IT_MSIX) {
+		int err;
+
 		adapter->intr.msix_entries[0].entry = 0;
 		err = pci_enable_msix(adapter->pdev, adapter->intr.msix_entries,
 				      VMXNET3_LINUX_MAX_MSIX_VECT);
@@ -2368,15 +2372,18 @@ vmxnet3_alloc_intr_resources(struct vmxnet3_adapter *adapter)
 			adapter->intr.type = VMXNET3_IT_MSIX;
 			return;
 		}
-#endif
+		adapter->intr.type = VMXNET3_IT_MSI;
+	}
 
+	if (adapter->intr.type == VMXNET3_IT_MSI) {
+		int err;
 		err = pci_enable_msi(adapter->pdev);
 		if (!err) {
 			adapter->intr.num_intrs = 1;
-			adapter->intr.type = VMXNET3_IT_MSI;
 			return;
 		}
 	}
+#endif /* CONFIG_PCI_MSI */
 
 	adapter->intr.type = VMXNET3_IT_INTX;
 
diff --git a/drivers/net/vmxnet3/vmxnet3_int.h b/drivers/net/vmxnet3/vmxnet3_int.h
index 9c2fe9a..d17fae6 100644
--- a/drivers/net/vmxnet3/vmxnet3_int.h
+++ b/drivers/net/vmxnet3/vmxnet3_int.h
@@ -68,10 +68,10 @@
 /*
  * Version numbers
  */
-#define VMXNET3_DRIVER_VERSION_STRING   "1.0.5.0-k"
+#define VMXNET3_DRIVER_VERSION_STRING   "1.0.13.0-k"
 
 /* a 32-bit int, each byte encode a verion number in VMXNET3_DRIVER_VERSION */
-#define VMXNET3_DRIVER_VERSION_NUM      0x01000500
+#define VMXNET3_DRIVER_VERSION_NUM      0x01000B00
 
 
 /*
