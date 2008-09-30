From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: Re: Regression: ixgb warning on MTU change
Date: Tue, 30 Sep 2008 16:08:48 -0700 (Pacific Daylight Time)
Message-ID: <Pine.WNT.4.63.0809301603030.2188@jbrandeb-desk.amr.corp.intel.com>
References: <48DAAFE2.1050607@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: e1000-devel@lists.sourceforge.net, netdev <netdev@vger.kernel.org>,
	jesse.brandeburg@intel.com,
	Rafael Lorandi <rafael.lorandi@linux.vnet.ibm.com>
To: Breno Leitao <leitao@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:40831 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752739AbYI3XIu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Sep 2008 19:08:50 -0400
In-Reply-To: <48DAAFE2.1050607@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 24 Sep 2008, Breno Leitao wrote:
> I just found an issue related to ixgb that seems to be a regression.
> After the interface is up and running (packets already transmitted), if
> I try to change the MTU, running "ifconfig ethX mtu 70", for example,
> causes the following warning[1].
> 
> Bisecting I found that the commit that caused this warning is
> fc2d14e36c69a8d44a2f5230835b54e95025363e. Reverting it solves the
> problem, ie, no more warnings.
> 
> Digging further, I found that just removing the following line added
> by fc2d14e36c69a8d44a2f5230835b54e95025363e's patch
> "buffer_info->dma = 0;", also solves the problem.
> 

Thanks for the report, I think this patch should fix it.  Please test and 
let us know.  This was compile tested only.

----

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

ixgb: fix bug when freeing resources

It was pointed out by Breno Leitao <leitao@linux.vnet.ibm.com> that
ixgb would crash on PPC when an IOMMU was in use, if change_mtu was
called.

It appears to be a pretty simple issue in the driver that wasn't discovered
because most systems don't run with an IOMMU.  The driver needs to only unmap
buffers that are mapped (duh).

CC: Breno Leitao <leitao@linux.vnet.ibm.com>

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
---
 drivers/net/ixgb/ixgb_main.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index aa75385..be3c7dc 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -977,15 +977,17 @@ ixgb_clean_rx_ring(struct ixgb_adapter *adapter)
 
 	for (i = 0; i < rx_ring->count; i++) {
 		buffer_info = &rx_ring->buffer_info[i];
-		if (buffer_info->skb) {
-
+		if (buffer_info->dma) {
 			pci_unmap_single(pdev,
 					 buffer_info->dma,
 					 buffer_info->length,
 					 PCI_DMA_FROMDEVICE);
+			buffer_info->dma = 0;
+			buffer_info->length = 0;
+		}
 
+		if (buffer_info->skb) {
 			dev_kfree_skb(buffer_info->skb);
-
 			buffer_info->skb = NULL;
 		}
 	}

