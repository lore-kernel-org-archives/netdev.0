From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [net-next PATCH 3/6] ethernet/intel: Use napi_alloc_skb
Date: Tue, 09 Dec 2014 19:40:56 -0800
Message-ID: <20141210034056.2114.52972.stgit@ahduyck-vm-fedora20>
References: <20141210033902.2114.68658.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, ast@plumgrid.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	eric.dumazet@gmail.com, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43682 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754406AbaLJDlB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Dec 2014 22:41:01 -0500
In-Reply-To: <20141210033902.2114.68658.stgit@ahduyck-vm-fedora20>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change replaces calls to netdev_alloc_skb_ip_align with
napi_alloc_skb.  The advantage of napi_alloc_skb is currently the fact that
the page allocation doesn't make use of any irq disable calls.

There are few spots where I couldn't replace the calls as the buffer
allocation routine is called as a part of init which is outside of the
softirq context.

Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 drivers/net/ethernet/intel/e1000/e1000_main.c |    2 +-
 drivers/net/ethernet/intel/e1000e/netdev.c    |    2 +-
 drivers/net/ethernet/intel/fm10k/fm10k_main.c |    4 ++--
 drivers/net/ethernet/intel/igb/igb_main.c     |    3 +--
 drivers/net/ethernet/intel/ixgb/ixgb_main.c   |    6 +++---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    4 ++--
 6 files changed, 10 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/net/ethernet/intel/e1000/e1000_main.c
index 862d198..83140cb 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_main.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
@@ -4100,7 +4100,7 @@ static bool e1000_tbi_should_accept(struct e1000_adapter *adapter,
 static struct sk_buff *e1000_alloc_rx_skb(struct e1000_adapter *adapter,
 					  unsigned int bufsz)
 {
-	struct sk_buff *skb = netdev_alloc_skb_ip_align(adapter->netdev, bufsz);
+	struct sk_buff *skb = napi_alloc_skb(&adapter->napi, bufsz);
 
 	if (unlikely(!skb))
 		adapter->alloc_rx_buff_failed++;
diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 88936aa..5c82c80 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -1016,7 +1016,7 @@ static bool e1000_clean_rx_irq(struct e1000_ring *rx_ring, int *work_done,
 		 */
 		if (length < copybreak) {
 			struct sk_buff *new_skb =
-			    netdev_alloc_skb_ip_align(netdev, length);
+				napi_alloc_skb(&adapter->napi, length);
 			if (new_skb) {
 				skb_copy_to_linear_data_offset(new_skb,
 							       -NET_IP_ALIGN,
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_main.c b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
index f0d9d6c..3418665 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_main.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
@@ -308,8 +308,8 @@ static struct sk_buff *fm10k_fetch_rx_buffer(struct fm10k_ring *rx_ring,
 #endif
 
 		/* allocate a skb to store the frags */
-		skb = netdev_alloc_skb_ip_align(rx_ring->netdev,
-						FM10K_RX_HDR_LEN);
+		skb = napi_alloc_skb(&rx_ring->q_vector->napi,
+				     FM10K_RX_HDR_LEN);
 		if (unlikely(!skb)) {
 			rx_ring->rx_stats.alloc_failed++;
 			return NULL;
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index bfd60577..675a330 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -6641,8 +6641,7 @@ static struct sk_buff *igb_fetch_rx_buffer(struct igb_ring *rx_ring,
 #endif
 
 		/* allocate a skb to store the frags */
-		skb = netdev_alloc_skb_ip_align(rx_ring->netdev,
-						IGB_RX_HDR_LEN);
+		skb = napi_alloc_skb(&rx_ring->q_vector->napi, IGB_RX_HDR_LEN);
 		if (unlikely(!skb)) {
 			rx_ring->rx_stats.alloc_failed++;
 			return NULL;
diff --git a/drivers/net/ethernet/intel/ixgb/ixgb_main.c b/drivers/net/ethernet/intel/ixgb/ixgb_main.c
index 055961b..aa87605 100644
--- a/drivers/net/ethernet/intel/ixgb/ixgb_main.c
+++ b/drivers/net/ethernet/intel/ixgb/ixgb_main.c
@@ -1963,7 +1963,7 @@ ixgb_rx_checksum(struct ixgb_adapter *adapter,
  * this should improve performance for small packets with large amounts
  * of reassembly being done in the stack
  */
-static void ixgb_check_copybreak(struct net_device *netdev,
+static void ixgb_check_copybreak(struct napi_struct *napi,
 				 struct ixgb_buffer *buffer_info,
 				 u32 length, struct sk_buff **skb)
 {
@@ -1972,7 +1972,7 @@ static void ixgb_check_copybreak(struct net_device *netdev,
 	if (length > copybreak)
 		return;
 
-	new_skb = netdev_alloc_skb_ip_align(netdev, length);
+	new_skb = napi_alloc_skb(napi, length);
 	if (!new_skb)
 		return;
 
@@ -2064,7 +2064,7 @@ ixgb_clean_rx_irq(struct ixgb_adapter *adapter, int *work_done, int work_to_do)
 			goto rxdesc_done;
 		}
 
-		ixgb_check_copybreak(netdev, buffer_info, length, &skb);
+		ixgb_check_copybreak(&adapter->napi, buffer_info, length, &skb);
 
 		/* Good Receive */
 		skb_put(skb, length);
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 94feddf..d75d01b 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -1909,8 +1909,8 @@ static struct sk_buff *ixgbe_fetch_rx_buffer(struct ixgbe_ring *rx_ring,
 #endif
 
 		/* allocate a skb to store the frags */
-		skb = netdev_alloc_skb_ip_align(rx_ring->netdev,
-						IXGBE_RX_HDR_SIZE);
+		skb = napi_alloc_skb(&rx_ring->q_vector->napi,
+				     IXGBE_RX_HDR_SIZE);
 		if (unlikely(!skb)) {
 			rx_ring->rx_stats.alloc_rx_buff_failed++;
 			return NULL;
