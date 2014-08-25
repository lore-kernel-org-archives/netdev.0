From: Vladislav Yasevich <vyasevich@gmail.com>
Subject: [PATCH v2 6/8] i40evf: Fix TSO and hw checksums for
	non-accelerated vlan packets.
Date: Mon, 25 Aug 2014 10:34:53 -0400
Message-ID: <1408977295-9162-7-git-send-email-vyasevic@redhat.com>
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
which will continue to support TSO and hw checksums.

In such situation the packet passed down the the device will contain
a vlan header and skb->protocol will be set to ETH_P_8021Q.
The device assumes that skb->protocol contains network protocol
value and uses that value to set up TSO and checksum information.
This results in corrupted frames sent on the wire.

This patch extract the protocol value correctly and corrects TSO
and checksums for non-accelerated traffic.

Fix this by using vlan_get_protocol() helper.

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
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
index 79bf96c..95a3ec2 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
@@ -1597,7 +1597,7 @@ static netdev_tx_t i40e_xmit_frame_ring(struct sk_buff *skb,
 		goto out_drop;
 
 	/* obtain protocol of skb */
-	protocol = skb->protocol;
+	protocol = vlan_get_protocol(skb);
 
 	/* record the location of the first descriptor for this packet */
 	first = &tx_ring->tx_bi[tx_ring->next_to_use];
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
