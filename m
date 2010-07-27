From: Sonny Rao <sonnyrao@us.ibm.com>
Subject: [PATCHv3] Add missing memory barriers to clean_rx_irq functions in
 Intel Drivers
Date: Tue, 27 Jul 2010 18:05:40 -0500
Message-ID: <20100727230540.GQ17248@us.ibm.com>
References: <20100727223452.GM17248@us.ibm.com>
 <20100727224434.GN17248@us.ibm.com>
 <AANLkTikMNFSyPxRCXc=cPWHkOfsx9iH0mEu-TH7bHL_h@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, e1000-devel@lists.sf.net
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:48460 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752132Ab0G0XEZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jul 2010 19:04:25 -0400
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by e35.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id o6RMu3Cg027506
	for <netdev@vger.kernel.org>; Tue, 27 Jul 2010 16:56:03 -0600
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o6RN4LMs150292
	for <netdev@vger.kernel.org>; Tue, 27 Jul 2010 17:04:23 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o6RN4Jtk000989
	for <netdev@vger.kernel.org>; Tue, 27 Jul 2010 17:04:20 -0600
Content-Disposition: inline
In-Reply-To: <AANLkTikMNFSyPxRCXc=cPWHkOfsx9iH0mEu-TH7bHL_h@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 27, 2010 at 03:45:42PM -0700, Jeff Kirsher wrote:
> 
> You also seem to be missing igb.

This patch is similar to what was fixed in ixgbe in this patch:

http://marc.info/?l=e1000-devel&m=126593062701537&w=3

We should add read memory barriers to all the similar cases across the
Intel ethernet driver family.  In the case of ixgbevf, igb, and igbvf
I've also added a missing barrier to the clean_tx_irq path because I
missed it in my last patch.

Without the barrier a processor can speculate a load ahead of the load
which looks at the status bit and get stale information causing a
number of different issues including invalid packet length, NULL
pointers, or bad data since checksumming was assumed to be done
in hardware.

v2: I missed the e100 the first time
v3: I missed igb and igbvf, third time's the charm?

Signed-off-by: Milton Miller <miltonm@bga.com>
Signed-off-by: Sonny Rao <sonnyrao@us.ibm.com>
cc: stable <stable@kernel.org>

Index: linux-2.6.35-rc5/drivers/net/e1000/e1000_main.c
===================================================================
--- linux-2.6.35-rc5.orig/drivers/net/e1000/e1000_main.c	2010-07-27 16:15:18.000000000 -0500
+++ linux-2.6.35-rc5/drivers/net/e1000/e1000_main.c	2010-07-27 16:22:21.000000000 -0500
@@ -3638,6 +3638,7 @@ static bool e1000_clean_jumbo_rx_irq(str
 		if (*work_done >= work_to_do)
 			break;
 		(*work_done)++;
+		rmb(); /* read descriptor and rx_buffer_info after status DD */
 
 		status = rx_desc->status;
 		skb = buffer_info->skb;
@@ -3844,6 +3845,7 @@ static bool e1000_clean_rx_irq(struct e1
 		if (*work_done >= work_to_do)
 			break;
 		(*work_done)++;
+		rmb(); /* read descriptor and rx_buffer_info after status DD */
 
 		status = rx_desc->status;
 		skb = buffer_info->skb;
Index: linux-2.6.35-rc5/drivers/net/e1000e/netdev.c
===================================================================
--- linux-2.6.35-rc5.orig/drivers/net/e1000e/netdev.c	2010-07-27 16:22:38.000000000 -0500
+++ linux-2.6.35-rc5/drivers/net/e1000e/netdev.c	2010-07-27 16:25:23.000000000 -0500
@@ -774,6 +774,7 @@ static bool e1000_clean_rx_irq(struct e1
 		if (*work_done >= work_to_do)
 			break;
 		(*work_done)++;
+		rmb();	/* read descriptor and rx_buffer_info after status DD */
 
 		status = rx_desc->status;
 		skb = buffer_info->skb;
@@ -1081,6 +1082,7 @@ static bool e1000_clean_rx_irq_ps(struct
 			break;
 		(*work_done)++;
 		skb = buffer_info->skb;
+		rmb();	/* read descriptor and rx_buffer_info after status DD */
 
 		/* in the packet split case this is header only */
 		prefetch(skb->data - NET_IP_ALIGN);
@@ -1280,6 +1282,7 @@ static bool e1000_clean_jumbo_rx_irq(str
 		if (*work_done >= work_to_do)
 			break;
 		(*work_done)++;
+		rmb();	/* read descriptor and rx_buffer_info after status DD */
 
 		status = rx_desc->status;
 		skb = buffer_info->skb;
Index: linux-2.6.35-rc5/drivers/net/ixgb/ixgb_main.c
===================================================================
--- linux-2.6.35-rc5.orig/drivers/net/ixgb/ixgb_main.c	2010-07-27 16:27:23.000000000 -0500
+++ linux-2.6.35-rc5/drivers/net/ixgb/ixgb_main.c	2010-07-27 16:41:57.000000000 -0500
@@ -1977,6 +1977,7 @@ ixgb_clean_rx_irq(struct ixgb_adapter *a
 			break;
 
 		(*work_done)++;
+		rmb();	/* read descriptor and rx_buffer_info after status DD */
 		status = rx_desc->status;
 		skb = buffer_info->skb;
 		buffer_info->skb = NULL;
Index: linux-2.6.35-rc5/drivers/net/ixgbevf/ixgbevf_main.c
===================================================================
--- linux-2.6.35-rc5.orig/drivers/net/ixgbevf/ixgbevf_main.c	2010-07-27 16:30:51.000000000 -0500
+++ linux-2.6.35-rc5/drivers/net/ixgbevf/ixgbevf_main.c	2010-07-27 16:40:19.000000000 -0500
@@ -231,6 +231,7 @@ static bool ixgbevf_clean_tx_irq(struct 
 	while ((eop_desc->wb.status & cpu_to_le32(IXGBE_TXD_STAT_DD)) &&
 	       (count < tx_ring->work_limit)) {
 		bool cleaned = false;
+		rmb(); /* read buffer_info after eop_desc */
 		for ( ; !cleaned; count++) {
 			struct sk_buff *skb;
 			tx_desc = IXGBE_TX_DESC_ADV(*tx_ring, i);
@@ -518,6 +519,7 @@ static bool ixgbevf_clean_rx_irq(struct 
 			break;
 		(*work_done)++;
 
+		rmb(); /* read descriptor and rx_buffer_info after status DD */
 		if (adapter->flags & IXGBE_FLAG_RX_PS_ENABLED) {
 			hdr_info = le16_to_cpu(ixgbevf_get_hdr_info(rx_desc));
 			len = (hdr_info & IXGBE_RXDADV_HDRBUFLEN_MASK) >>
Index: linux-2.6.35-rc5/drivers/net/e100.c
===================================================================
--- linux-2.6.35-rc5.orig/drivers/net/e100.c	2010-07-27 17:36:44.000000000 -0500
+++ linux-2.6.35-rc5/drivers/net/e100.c	2010-07-27 17:41:38.000000000 -0500
@@ -1928,6 +1928,7 @@ static int e100_rx_indicate(struct nic *
 
 	netif_printk(nic, rx_status, KERN_DEBUG, nic->netdev,
 		     "status=0x%04X\n", rfd_status);
+	rmb(); /* read size after status bit */
 
 	/* If data isn't ready, nothing to indicate */
 	if (unlikely(!(rfd_status & cb_complete))) {
Index: linux-2.6.35-rc5/drivers/net/igb/igb_main.c
===================================================================
--- linux-2.6.35-rc5.orig/drivers/net/igb/igb_main.c	2010-07-27 17:50:47.000000000 -0500
+++ linux-2.6.35-rc5/drivers/net/igb/igb_main.c	2010-07-27 17:57:11.000000000 -0500
@@ -5335,6 +5335,7 @@ static bool igb_clean_tx_irq(struct igb_
 
 	while ((eop_desc->wb.status & cpu_to_le32(E1000_TXD_STAT_DD)) &&
 	       (count < tx_ring->count)) {
+		rmb();	/* read buffer_info after eop_desc status */
 		for (cleaned = false; !cleaned; count++) {
 			tx_desc = E1000_TX_DESC_ADV(*tx_ring, i);
 			buffer_info = &tx_ring->buffer_info[i];
@@ -5540,6 +5541,7 @@ static bool igb_clean_rx_irq_adv(struct 
 		if (*work_done >= budget)
 			break;
 		(*work_done)++;
+		rmb(); /* read descriptor and rx_buffer_info after status DD */
 
 		skb = buffer_info->skb;
 		prefetch(skb->data - NET_IP_ALIGN);
Index: linux-2.6.35-rc5/drivers/net/igbvf/netdev.c
===================================================================
--- linux-2.6.35-rc5.orig/drivers/net/igbvf/netdev.c	2010-07-27 17:51:00.000000000 -0500
+++ linux-2.6.35-rc5/drivers/net/igbvf/netdev.c	2010-07-27 17:59:15.000000000 -0500
@@ -248,6 +248,7 @@ static bool igbvf_clean_rx_irq(struct ig
 		if (*work_done >= work_to_do)
 			break;
 		(*work_done)++;
+		rmb(); /* read descriptor and rx_buffer_info after status DD */
 
 		buffer_info = &rx_ring->buffer_info[i];
 
@@ -780,6 +781,7 @@ static bool igbvf_clean_tx_irq(struct ig
 
 	while ((eop_desc->wb.status & cpu_to_le32(E1000_TXD_STAT_DD)) &&
 	       (count < tx_ring->count)) {
+		rmb();	/* read buffer_info after eop_desc status */
 		for (cleaned = false; !cleaned; count++) {
 			tx_desc = IGBVF_TX_DESC_ADV(*tx_ring, i);
 			buffer_info = &tx_ring->buffer_info[i];
