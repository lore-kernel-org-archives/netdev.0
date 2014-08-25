From: Vladislav Yasevich <vyasevich@gmail.com>
Subject: [PATCH v2 2/8] e1000: Fix TSO for non-accelerated
	vlan traffic
Date: Mon, 25 Aug 2014 10:34:49 -0400
Message-ID: <1408977295-9162-3-git-send-email-vyasevic@redhat.com>
References: <1408977295-9162-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Vladislav Yasevich <vyasevic@redhat.com>, Linux NICS <linux.nics@intel.com>,
	e1000-devel@lists.sourceforge.net, Bruce Allan <bruce.w.allan@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	John Ronciak <john.ronciak@intel.com>
To: netdev@vger.kernel.org
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1408977295-9162-1-git-send-email-vyasevic@redhat.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

This device claims TSO and checksum support for vlans.  It also
allows a user to control vlan acceleration offloading.  As such,
it is possible to turn off vlan acceleration and configure a vlan
which will continue to support TSO.

In such situation the packet passed down the the device will contain
a vlan header and skb->protocol will be set to ETH_P_8021Q.
The device assumes that skb->protocol contains network protocol
value and uses that value to set up TSO and checksum information.
This will results in corrupted frames sent on the wire.

This patch extract the protocol value correctly and corrects TSO
for non-accelerated traffic.

CC: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
CC: Jesse Brandeburg <jesse.brandeburg@intel.com>
CC: Bruce Allan <bruce.w.allan@intel.com>
CC: Carolyn Wyborny <carolyn.wyborny@intel.com>
CC: Don Skidmore <donald.c.skidmore@intel.com>
CC: Greg Rose <gregory.v.rose@intel.com>
CC: Alex Duyck <alexander.h.duyck@intel.com>
CC: John Ronciak <john.ronciak@intel.com>
CC: Mitch Williams <mitch.a.williams@intel.com>
CC: Linux NICS <linux.nics@intel.com>
CC: e1000-devel@lists.sourceforge.net
Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
---
 drivers/net/ethernet/intel/e1000/e1000_main.c | 19 +++++++++++--------
 1 file changed, 11 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/net/ethernet/intel/e1000/e1000_main.c
index cbc330b..ad3d5d1 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_main.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
@@ -2674,7 +2674,8 @@ set_itr_now:
 #define E1000_TX_FLAGS_VLAN_SHIFT	16
 
 static int e1000_tso(struct e1000_adapter *adapter,
-		     struct e1000_tx_ring *tx_ring, struct sk_buff *skb)
+		     struct e1000_tx_ring *tx_ring, struct sk_buff *skb,
+		     __be16 protocol)
 {
 	struct e1000_context_desc *context_desc;
 	struct e1000_buffer *buffer_info;
@@ -2692,7 +2693,7 @@ static int e1000_tso(struct e1000_adapter *adapter,
 
 		hdr_len = skb_transport_offset(skb) + tcp_hdrlen(skb);
 		mss = skb_shinfo(skb)->gso_size;
-		if (skb->protocol == htons(ETH_P_IP)) {
+		if (protocol == htons(ETH_P_IP)) {
 			struct iphdr *iph = ip_hdr(skb);
 			iph->tot_len = 0;
 			iph->check = 0;
@@ -2702,7 +2703,7 @@ static int e1000_tso(struct e1000_adapter *adapter,
 								 0);
 			cmd_length = E1000_TXD_CMD_IP;
 			ipcse = skb_transport_offset(skb) - 1;
-		} else if (skb->protocol == htons(ETH_P_IPV6)) {
+		} else if (skb_is_gso_v6(skb)) {
 			ipv6_hdr(skb)->payload_len = 0;
 			tcp_hdr(skb)->check =
 				~csum_ipv6_magic(&ipv6_hdr(skb)->saddr,
@@ -2745,7 +2746,8 @@ static int e1000_tso(struct e1000_adapter *adapter,
 }
 
 static bool e1000_tx_csum(struct e1000_adapter *adapter,
-			  struct e1000_tx_ring *tx_ring, struct sk_buff *skb)
+			  struct e1000_tx_ring *tx_ring, struct sk_buff *skb,
+			  __be16 protocol)
 {
 	struct e1000_context_desc *context_desc;
 	struct e1000_buffer *buffer_info;
@@ -2756,7 +2758,7 @@ static bool e1000_tx_csum(struct e1000_adapter *adapter,
 	if (skb->ip_summed != CHECKSUM_PARTIAL)
 		return false;
 
-	switch (skb->protocol) {
+	switch (protocol) {
 	case cpu_to_be16(ETH_P_IP):
 		if (ip_hdr(skb)->protocol == IPPROTO_TCP)
 			cmd_len |= E1000_TXD_CMD_TCP;
@@ -3097,6 +3099,7 @@ static netdev_tx_t e1000_xmit_frame(struct sk_buff *skb,
 	int count = 0;
 	int tso;
 	unsigned int f;
+	__be16 protocol = vlan_get_protocol(skb);
 
 	/* This goes back to the question of how to logically map a Tx queue
 	 * to a flow.  Right now, performance is impacted slightly negatively
@@ -3210,7 +3213,7 @@ static netdev_tx_t e1000_xmit_frame(struct sk_buff *skb,
 
 	first = tx_ring->next_to_use;
 
-	tso = e1000_tso(adapter, tx_ring, skb);
+	tso = e1000_tso(adapter, tx_ring, skb, protocol);
 	if (tso < 0) {
 		dev_kfree_skb_any(skb);
 		return NETDEV_TX_OK;
@@ -3220,10 +3223,10 @@ static netdev_tx_t e1000_xmit_frame(struct sk_buff *skb,
 		if (likely(hw->mac_type != e1000_82544))
 			tx_ring->last_tx_tso = true;
 		tx_flags |= E1000_TX_FLAGS_TSO;
-	} else if (likely(e1000_tx_csum(adapter, tx_ring, skb)))
+	} else if (likely(e1000_tx_csum(adapter, tx_ring, skb, protocol)))
 		tx_flags |= E1000_TX_FLAGS_CSUM;
 
-	if (likely(skb->protocol == htons(ETH_P_IP)))
+	if (protocol == htons(ETH_P_IP))
 		tx_flags |= E1000_TX_FLAGS_IPV4;
 
 	if (unlikely(skb->no_fcs))
-- 
1.9.3


------------------------------------------------------------------------------
Slashdot TV.  
Video for Nerds.  Stuff that matters.
http://tv.slashdot.org/
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
