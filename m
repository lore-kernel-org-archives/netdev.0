From: Shreyas Bhatewara <sbhatewara@vmware.com>
Subject: Re: [PATCH 2.6.35-rc1] net-next: vmxnet3 fixes [3/5] Initialize link
 state at probe time
Date: Fri, 16 Jul 2010 00:51:14 -0700 (PDT)
Message-ID: <alpine.LRH.2.00.1007160050030.12503@localhost.localdomain>
References: <alpine.LRH.2.00.1007131748180.32055@localhost.localdomain> <20100714.141054.48510602.davem@davemloft.net> <alpine.LRH.2.00.1007150125240.25472@localhost.localdomain> <20100715.224435.45920963.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"pv-drivers@vmware.com" <pv-drivers@vmware.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-outbound-2.vmware.com ([65.115.85.73]:60857 "EHLO
	smtp-outbound-2.vmware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S935843Ab0GPHvP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jul 2010 03:51:15 -0400
In-Reply-To: <20100715.224435.45920963.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Thu, 15 Jul 2010, David Miller wrote:

> From: Shreyas Bhatewara <sbhatewara@vmware.com>
> Date: Thu, 15 Jul 2010 18:20:14 -0700 (PDT)
> 
> > 
> > On Wed, 14 Jul 2010, David Miller wrote:
> > 
> >> From: Shreyas Bhatewara <sbhatewara@vmware.com>
> >> Date: Tue, 13 Jul 2010 17:48:55 -0700 (PDT)
> >> 
> >> > 
> >> > Initialize vmxnet3 link state at probe time
> >> > 
> >> > This change initializes the state of link at the time when driver is
> >> > loaded. The ethtool output for 'link detected' and 'link speed'
> >> > is thus valid even before the interface is brought up.
> >> > 
> >> > Signed-off-by: Shreyas Bhatewara <sbhatewara@vmware.com>
> >> 
> >> You should never, ever, call netif_start_queue() on a device which has
> >> not been brought up.
> >> 
> >> But that is what this patch is doing.
> >> 
> > 
> > I do not understand why you say so. vmxnet3_check_link() is called in 
> > probe() with affectTxQueue as false. Hence netif_start_queue() will not be 
> > called before device is brought up.
> > vmxnet3_check_link() is again called with affectTxQueue as true in 
> > vmxnet3_activate_dev() after device was activated.
> 
> Aha, I see how the logic works now.
> 
> But still there is a problem with this patch, please remove the
> driver version bump and resubmit.
> 
> You should only version bump at the last patch in a series.
> 
> Thanks.
> 

---

Initialize vmxnet3 link state at probe time

This change initializes the state of link at the time when driver is
loaded. The ethtool output for 'link detected' and 'link speed'
is thus valid even before the interface is brought up.

Signed-off-by: Shreyas Bhatewara <sbhatewara@vmware.com>

---
 drivers/net/vmxnet3/vmxnet3_drv.c |   13 ++++++++-----
 1 files changed, 8 insertions(+), 5 deletions(-)

diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vmxnet3_drv.c
index 7792a44..1e31d40 100644
--- a/drivers/net/vmxnet3/vmxnet3_drv.c
+++ b/drivers/net/vmxnet3/vmxnet3_drv.c
@@ -130,7 +130,7 @@ vmxnet3_tq_stop(struct vmxnet3_tx_queue *tq, struct vmxnet3_adapter *adapter)
  * Check the link state. This may start or stop the tx queue.
  */
 static void
-vmxnet3_check_link(struct vmxnet3_adapter *adapter)
+vmxnet3_check_link(struct vmxnet3_adapter *adapter, bool affectTxQueue)
 {
 	u32 ret;
 
@@ -143,14 +143,16 @@ vmxnet3_check_link(struct vmxnet3_adapter *adapter)
 		if (!netif_carrier_ok(adapter->netdev))
 			netif_carrier_on(adapter->netdev);
 
-		vmxnet3_tq_start(&adapter->tx_queue, adapter);
+		if (affectTxQueue)
+			vmxnet3_tq_start(&adapter->tx_queue, adapter);
 	} else {
 		printk(KERN_INFO "%s: NIC Link is Down\n",
 		       adapter->netdev->name);
 		if (netif_carrier_ok(adapter->netdev))
 			netif_carrier_off(adapter->netdev);
 
-		vmxnet3_tq_stop(&adapter->tx_queue, adapter);
+		if (affectTxQueue)
+			vmxnet3_tq_stop(&adapter->tx_queue, adapter);
 	}
 }
 
@@ -165,7 +167,7 @@ vmxnet3_process_events(struct vmxnet3_adapter *adapter)
 
 	/* Check if link state has changed */
 	if (events & VMXNET3_ECR_LINK)
-		vmxnet3_check_link(adapter);
+		vmxnet3_check_link(adapter, true);
 
 	/* Check if there is an error on xmit/recv queues */
 	if (events & (VMXNET3_ECR_TQERR | VMXNET3_ECR_RQERR)) {
@@ -1947,7 +1949,7 @@ vmxnet3_activate_dev(struct vmxnet3_adapter *adapter)
 	 * Check link state when first activating device. It will start the
 	 * tx queue if the link is up.
 	 */
-	vmxnet3_check_link(adapter);
+	vmxnet3_check_link(adapter, true);
 
 	napi_enable(&adapter->napi);
 	vmxnet3_enable_all_intrs(adapter);
@@ -2549,6 +2551,7 @@ vmxnet3_probe_device(struct pci_dev *pdev,
 	}
 
 	set_bit(VMXNET3_STATE_BIT_QUIESCED, &adapter->state);
+	vmxnet3_check_link(adapter, false);
 	atomic_inc(&devices_found);
 	return 0;

