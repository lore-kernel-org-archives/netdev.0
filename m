From: vyasevich@gmail.com
Subject: [PATCH 1/8] e1000e: Fix TSO with non-accelerated vlans
Date: Fri, 22 Aug 2014 22:17:03 -0400
Message-ID: <1408760230-7457-2-git-send-email-vysevich@gmail.com>
References: <1408760230-7457-1-git-send-email-vysevich@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Vladislav Yasevich <vyasevic@redhat.com>, Linux NICS <linux.nics@intel.com>,
	e1000-devel@lists.sourceforge.net, Bruce Allan <bruce.w.allan@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	John Ronciak <john.ronciak@intel.com>
To: netdev@vger.kernel.org
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1408760230-7457-1-git-send-email-vysevich@gmail.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: Vladislav Yasevich <vyasevic@redhat.com>

This device claims  TSO support for vlans.  It also allows a
user to control vlan acceleration offloading.  As such, it is
possible to turn off vlan acceleration and configure a vlan
which will continue to support TSO.

In such situation the packet passed down the the device will contain
a vlan header and skb->protocol will be set to ETH_P_8021Q.
The device assumes that skb->protocol contains network protocol
value and uses that value to set up TSO information.  This results
in corrupted frames sent on the wire.  Corruptions include
incorrect IP total length and invalid IP checksum.

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
 drivers/net/ethernet/intel/e1000e/netdev.c | 21 +++++++++------------
 1 file changed, 9 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 65c3aef..247335d 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -5164,7 +5164,8 @@ link_up:
 #define E1000_TX_FLAGS_VLAN_MASK	0xffff0000
 #define E1000_TX_FLAGS_VLAN_SHIFT	16
 
-static int e1000_tso(struct e1000_ring *tx_ring, struct sk_buff *skb)
+static int e1000_tso(struct e1000_ring *tx_ring, struct sk_buff *skb,
+		     __be16 protocol)
 {
 	struct e1000_context_desc *context_desc;
 	struct e1000_buffer *buffer_info;
@@ -5183,7 +5184,7 @@ static int e1000_tso(struct e1000_ring *tx_ring, struct sk_buff *skb)
 
 	hdr_len = skb_transport_offset(skb) + tcp_hdrlen(skb);
 	mss = skb_shinfo(skb)->gso_size;
-	if (skb->protocol == htons(ETH_P_IP)) {
+	if (protocol == htons(ETH_P_IP)) {
 		struct iphdr *iph = ip_hdr(skb);
 		iph->tot_len = 0;
 		iph->check = 0;
@@ -5231,7 +5232,8 @@ static int e1000_tso(struct e1000_ring *tx_ring, struct sk_buff *skb)
 	return 1;
 }
 
-static bool e1000_tx_csum(struct e1000_ring *tx_ring, struct sk_buff *skb)
+static bool e1000_tx_csum(struct e1000_ring *tx_ring, struct sk_buff *skb,
+			  __be16 protocol)
 {
 	struct e1000_adapter *adapter = tx_ring->adapter;
 	struct e1000_context_desc *context_desc;
@@ -5239,16 +5241,10 @@ static bool e1000_tx_csum(struct e1000_ring *tx_ring, struct sk_buff *skb)
 	unsigned int i;
 	u8 css;
 	u32 cmd_len = E1000_TXD_CMD_DEXT;
-	__be16 protocol;
 
 	if (skb->ip_summed != CHECKSUM_PARTIAL)
 		return false;
 
-	if (skb->protocol == cpu_to_be16(ETH_P_8021Q))
-		protocol = vlan_eth_hdr(skb)->h_vlan_encapsulated_proto;
-	else
-		protocol = skb->protocol;
-
 	switch (protocol) {
 	case cpu_to_be16(ETH_P_IP):
 		if (ip_hdr(skb)->protocol == IPPROTO_TCP)
@@ -5546,6 +5542,7 @@ static netdev_tx_t e1000_xmit_frame(struct sk_buff *skb,
 	int count = 0;
 	int tso;
 	unsigned int f;
+	__be16 protocol = vlan_get_protocol(skb);
 
 	if (test_bit(__E1000_DOWN, &adapter->state)) {
 		dev_kfree_skb_any(skb);
@@ -5620,7 +5617,7 @@ static netdev_tx_t e1000_xmit_frame(struct sk_buff *skb,
 
 	first = tx_ring->next_to_use;
 
-	tso = e1000_tso(tx_ring, skb);
+	tso = e1000_tso(tx_ring, skb, protocol);
 	if (tso < 0) {
 		dev_kfree_skb_any(skb);
 		return NETDEV_TX_OK;
@@ -5628,14 +5625,14 @@ static netdev_tx_t e1000_xmit_frame(struct sk_buff *skb,
 
 	if (tso)
 		tx_flags |= E1000_TX_FLAGS_TSO;
-	else if (e1000_tx_csum(tx_ring, skb))
+	else if (e1000_tx_csum(tx_ring, skb, protocol))
 		tx_flags |= E1000_TX_FLAGS_CSUM;
 
 	/* Old method was to assume IPv4 packet by default if TSO was enabled.
 	 * 82571 hardware supports TSO capabilities for IPv6 as well...
 	 * no longer assume, we must.
 	 */
-	if (skb->protocol == htons(ETH_P_IP))
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
