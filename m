From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH] e100/e1000*/igb*/ixgb*: Add missing read memory
	barrier
Date: Sun, 08 Aug 2010 19:02:31 -0700
Message-ID: <20100809020230.1087.42749.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Milton Miller <miltonm@bga.com>,
	Anton Blanchard <anton@samba.org>,
	Sonny Rao <sonnyrao@us.ibm.com>, stable <stable@kernel.org>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta11.westchester.pa.mail.comcast.net ([76.96.59.211]:37280
	"EHLO QMTA11.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752596Ab0HICC7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Aug 2010 22:02:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Based on patches from Sonny Rao and Milton Miller...

Combined the patches to fix up clean_tx_irq and clean_rx_irq.

The PowerPC architecture does not require loads to independent bytes
to be ordered without adding an explicit barrier.

In ixgbe_clean_rx_irq we load the status bit then load the packet data.
With packet split disabled if these loads go out of order we get a
stale packet, but we will notice the bad sequence numbers and drop it.

The problem occurs with packet split enabled where the TCP/IP header
and data are in different descriptors. If the reads go out of order
we may have data that doesn't match the TCP/IP header. Since we use
hardware checksumming this bad data is never verified and it makes it
all the way to the application.

This bug was found during stress testing and adding this barrier has
been shown to fix it.  The bug can manifest as a data integrity issue
(bad payload data) or as a BUG in skb_pull().

This was a nasty bug to hunt down, if people agree with the fix I think
it's a candidate for stable.

Previously Submitted to e1000-devel only for ixgbe

http://marc.info/?l=e1000-devel&m=126593062701537&w=3

We've now seen this problem hit with other device drivers (e1000e mostly)
So I'm resubmitting with fixes for other Intel Device Drivers with
similar issues.

CC: Milton Miller <miltonm@bga.com>
CC: Anton Blanchard <anton@samba.org>
CC: Sonny Rao <sonnyrao@us.ibm.com>
CC: stable <stable@kernel.org>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e100.c                 |    2 ++
 drivers/net/e1000/e1000_main.c     |    3 +++
 drivers/net/e1000e/netdev.c        |    4 ++++
 drivers/net/igb/igb_main.c         |    2 ++
 drivers/net/igbvf/netdev.c         |    2 ++
 drivers/net/ixgb/ixgb_main.c       |    2 ++
 drivers/net/ixgbe/ixgbe_main.c     |    1 +
 drivers/net/ixgbevf/ixgbevf_main.c |    2 ++
 8 files changed, 18 insertions(+), 0 deletions(-)

diff --git a/drivers/net/e100.c b/drivers/net/e100.c
index b194bad..8e2eab4 100644
--- a/drivers/net/e100.c
+++ b/drivers/net/e100.c
@@ -1779,6 +1779,7 @@ static int e100_tx_clean(struct nic *nic)
 	for (cb = nic->cb_to_clean;
 	    cb->status & cpu_to_le16(cb_complete);
 	    cb = nic->cb_to_clean = cb->next) {
+		rmb(); /* read skb after status */
 		netif_printk(nic, tx_done, KERN_DEBUG, nic->netdev,
 			     "cb[%d]->status = 0x%04X\n",
 			     (int)(((void*)cb - (void*)nic->cbs)/sizeof(struct cb)),
@@ -1927,6 +1928,7 @@ static int e100_rx_indicate(struct nic *nic, struct rx *rx,
 
 	netif_printk(nic, rx_status, KERN_DEBUG, nic->netdev,
 		     "status=0x%04X\n", rfd_status);
+	rmb(); /* read size after status bit */
 
 	/* If data isn't ready, nothing to indicate */
 	if (unlikely(!(rfd_status & cb_complete))) {
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 02833af..5cc39ed 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -3454,6 +3454,7 @@ static bool e1000_clean_tx_irq(struct e1000_adapter *adapter,
 	while ((eop_desc->upper.data & cpu_to_le32(E1000_TXD_STAT_DD)) &&
 	       (count < tx_ring->count)) {
 		bool cleaned = false;
+		rmb();	/* read buffer_info after eop_desc */
 		for ( ; !cleaned; count++) {
 			tx_desc = E1000_TX_DESC(*tx_ring, i);
 			buffer_info = &tx_ring->buffer_info[i];
@@ -3643,6 +3644,7 @@ static bool e1000_clean_jumbo_rx_irq(struct e1000_adapter *adapter,
 		if (*work_done >= work_to_do)
 			break;
 		(*work_done)++;
+		rmb(); /* read descriptor and rx_buffer_info after status DD */
 
 		status = rx_desc->status;
 		skb = buffer_info->skb;
@@ -3849,6 +3851,7 @@ static bool e1000_clean_rx_irq(struct e1000_adapter *adapter,
 		if (*work_done >= work_to_do)
 			break;
 		(*work_done)++;
+		rmb(); /* read descriptor and rx_buffer_info after status DD */
 
 		status = rx_desc->status;
 		skb = buffer_info->skb;
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 36d31a4..c3dd590 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -781,6 +781,7 @@ static bool e1000_clean_rx_irq(struct e1000_adapter *adapter,
 		if (*work_done >= work_to_do)
 			break;
 		(*work_done)++;
+		rmb();	/* read descriptor and rx_buffer_info after status DD */
 
 		status = rx_desc->status;
 		skb = buffer_info->skb;
@@ -991,6 +992,7 @@ static bool e1000_clean_tx_irq(struct e1000_adapter *adapter)
 	while ((eop_desc->upper.data & cpu_to_le32(E1000_TXD_STAT_DD)) &&
 	       (count < tx_ring->count)) {
 		bool cleaned = false;
+		rmb(); /* read buffer_info after eop_desc */
 		for (; !cleaned; count++) {
 			tx_desc = E1000_TX_DESC(*tx_ring, i);
 			buffer_info = &tx_ring->buffer_info[i];
@@ -1087,6 +1089,7 @@ static bool e1000_clean_rx_irq_ps(struct e1000_adapter *adapter,
 			break;
 		(*work_done)++;
 		skb = buffer_info->skb;
+		rmb();	/* read descriptor and rx_buffer_info after status DD */
 
 		/* in the packet split case this is header only */
 		prefetch(skb->data - NET_IP_ALIGN);
@@ -1286,6 +1289,7 @@ static bool e1000_clean_jumbo_rx_irq(struct e1000_adapter *adapter,
 		if (*work_done >= work_to_do)
 			break;
 		(*work_done)++;
+		rmb();	/* read descriptor and rx_buffer_info after status DD */
 
 		status = rx_desc->status;
 		skb = buffer_info->skb;
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index df5dcd2..9b4e589 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -5353,6 +5353,7 @@ static bool igb_clean_tx_irq(struct igb_q_vector *q_vector)
 
 	while ((eop_desc->wb.status & cpu_to_le32(E1000_TXD_STAT_DD)) &&
 	       (count < tx_ring->count)) {
+		rmb();	/* read buffer_info after eop_desc status */
 		for (cleaned = false; !cleaned; count++) {
 			tx_desc = E1000_TX_DESC_ADV(*tx_ring, i);
 			buffer_info = &tx_ring->buffer_info[i];
@@ -5558,6 +5559,7 @@ static bool igb_clean_rx_irq_adv(struct igb_q_vector *q_vector,
 		if (*work_done >= budget)
 			break;
 		(*work_done)++;
+		rmb(); /* read descriptor and rx_buffer_info after status DD */
 
 		skb = buffer_info->skb;
 		prefetch(skb->data - NET_IP_ALIGN);
diff --git a/drivers/net/igbvf/netdev.c b/drivers/net/igbvf/netdev.c
index ec808fa..c539f7c 100644
--- a/drivers/net/igbvf/netdev.c
+++ b/drivers/net/igbvf/netdev.c
@@ -248,6 +248,7 @@ static bool igbvf_clean_rx_irq(struct igbvf_adapter *adapter,
 		if (*work_done >= work_to_do)
 			break;
 		(*work_done)++;
+		rmb(); /* read descriptor and rx_buffer_info after status DD */
 
 		buffer_info = &rx_ring->buffer_info[i];
 
@@ -780,6 +781,7 @@ static bool igbvf_clean_tx_irq(struct igbvf_ring *tx_ring)
 
 	while ((eop_desc->wb.status & cpu_to_le32(E1000_TXD_STAT_DD)) &&
 	       (count < tx_ring->count)) {
+		rmb();	/* read buffer_info after eop_desc status */
 		for (cleaned = false; !cleaned; count++) {
 			tx_desc = IGBVF_TX_DESC_ADV(*tx_ring, i);
 			buffer_info = &tx_ring->buffer_info[i];
diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index c6b75c8..45fc89b 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -1816,6 +1816,7 @@ ixgb_clean_tx_irq(struct ixgb_adapter *adapter)
 
 	while (eop_desc->status & IXGB_TX_DESC_STATUS_DD) {
 
+		rmb(); /* read buffer_info after eop_desc */
 		for (cleaned = false; !cleaned; ) {
 			tx_desc = IXGB_TX_DESC(*tx_ring, i);
 			buffer_info = &tx_ring->buffer_info[i];
@@ -1976,6 +1977,7 @@ ixgb_clean_rx_irq(struct ixgb_adapter *adapter, int *work_done, int work_to_do)
 			break;
 
 		(*work_done)++;
+		rmb();	/* read descriptor and rx_buffer_info after status DD */
 		status = rx_desc->status;
 		skb = buffer_info->skb;
 		buffer_info->skb = NULL;
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 7d6a415..27cc8f8 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -748,6 +748,7 @@ static bool ixgbe_clean_tx_irq(struct ixgbe_q_vector *q_vector,
 	while ((eop_desc->wb.status & cpu_to_le32(IXGBE_TXD_STAT_DD)) &&
 	       (count < tx_ring->work_limit)) {
 		bool cleaned = false;
+		rmb(); /* read buffer_info after eop_desc */
 		for ( ; !cleaned; count++) {
 			struct sk_buff *skb;
 			tx_desc = IXGBE_TX_DESC_ADV(*tx_ring, i);
diff --git a/drivers/net/ixgbevf/ixgbevf_main.c b/drivers/net/ixgbevf/ixgbevf_main.c
index 3e291cc..918c003 100644
--- a/drivers/net/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ixgbevf/ixgbevf_main.c
@@ -231,6 +231,7 @@ static bool ixgbevf_clean_tx_irq(struct ixgbevf_adapter *adapter,
 	while ((eop_desc->wb.status & cpu_to_le32(IXGBE_TXD_STAT_DD)) &&
 	       (count < tx_ring->work_limit)) {
 		bool cleaned = false;
+		rmb(); /* read buffer_info after eop_desc */
 		for ( ; !cleaned; count++) {
 			struct sk_buff *skb;
 			tx_desc = IXGBE_TX_DESC_ADV(*tx_ring, i);
@@ -518,6 +519,7 @@ static bool ixgbevf_clean_rx_irq(struct ixgbevf_q_vector *q_vector,
 			break;
 		(*work_done)++;
 
+		rmb(); /* read descriptor and rx_buffer_info after status DD */
 		if (adapter->flags & IXGBE_FLAG_RX_PS_ENABLED) {
 			hdr_info = le16_to_cpu(ixgbevf_get_hdr_info(rx_desc));
 			len = (hdr_info & IXGBE_RXDADV_HDRBUFLEN_MASK) >>

