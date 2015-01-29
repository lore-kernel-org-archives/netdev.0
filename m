From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: [PATCH net 3/4] ixgbe: Fix checksum error when using
	stacked vlan
Date: Thu, 29 Jan 2015 20:37:09 +0900
Message-ID: <1422531430-32012-4-git-send-email-makita.toshiaki@lab.ntt.co.jp>
References: <1422531430-32012-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
To: "David S . Miller" <davem@davemloft.net>, Linux NICS <linux.nics@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1422531430-32012-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

When a skb has multiple vlans and it is CHECKSUM_PARTIAL,
ixgbe_tx_csum() fails to get the network protocol and checksum related
descriptor fields are not configured correctly because skb->protocol
doesn't show the L3 protocol in this case.

Use vlan_get_protocol() to get the proper network protocol.

Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 2ed2c7d..67b02bd 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -7227,11 +7227,11 @@ netdev_tx_t ixgbe_xmit_frame_ring(struct sk_buff *skb,
 		if (!vhdr)
 			goto out_drop;
 
-		protocol = vhdr->h_vlan_encapsulated_proto;
 		tx_flags |= ntohs(vhdr->h_vlan_TCI) <<
 				  IXGBE_TX_FLAGS_VLAN_SHIFT;
 		tx_flags |= IXGBE_TX_FLAGS_SW_VLAN;
 	}
+	protocol = vlan_get_protocol(skb);
 
 	if (unlikely(skb_shinfo(skb)->tx_flags & SKBTX_HW_TSTAMP) &&
 	    adapter->ptp_clock &&
-- 
1.8.1.2



------------------------------------------------------------------------------
Dive into the World of Parallel Programming. The Go Parallel Website,
sponsored by Intel and developed in partnership with Slashdot Media, is your
hub for all things parallel software development, from weekly thought
leadership blogs to news, videos, case studies, tutorials and more. Take a
look and join the conversation now. http://goparallel.sourceforge.net/
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
