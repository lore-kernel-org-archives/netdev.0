From: Jakub Kicinski <kubakici@wp.pl>
Subject: [PATCH net-next 05/10] ixgbe: never generate both
	software and hardware timestamps
Date: Fri, 14 Mar 2014 18:34:36 +0100
Message-ID: <1394818481-7652-6-git-send-email-kubakici@wp.pl>
References: <1394818481-7652-1-git-send-email-kubakici@wp.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jakub Kicinski <kubakici@wp.pl>, netdev@vger.kernel.org,
	e1000-devel@lists.sourceforge.net
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1394818481-7652-1-git-send-email-kubakici@wp.pl>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

skb_tx_timestamp() does not report software time stamp
if SKBTX_IN_PROGRESS is set. According to timestamping.txt
software time stamps are a fallback and should not be
generated if hardware time stamp is provided.

Move call to skb_tx_timestamp() after setting
SKBTX_IN_PROGRESS.

Signed-off-by: Jakub Kicinski <kubakici@wp.pl>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 851c413..f6ac11c 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -7031,8 +7031,6 @@ netdev_tx_t ixgbe_xmit_frame_ring(struct sk_buff *skb,
 		tx_flags |= IXGBE_TX_FLAGS_SW_VLAN;
 	}
 
-	skb_tx_timestamp(skb);
-
 	if (unlikely(skb_shinfo(skb)->tx_flags & SKBTX_HW_TSTAMP)) {
 		skb_shinfo(skb)->tx_flags |= SKBTX_IN_PROGRESS;
 		tx_flags |= IXGBE_TX_FLAGS_TSTAMP;
@@ -7043,6 +7041,8 @@ netdev_tx_t ixgbe_xmit_frame_ring(struct sk_buff *skb,
 		schedule_work(&adapter->ptp_tx_work);
 	}
 
+	skb_tx_timestamp(skb);
+
 #ifdef CONFIG_PCI_IOV
 	/*
 	 * Use the l2switch_enable flag - would be false if the DMA
-- 
1.8.5.3


------------------------------------------------------------------------------
Learn Graph Databases - Download FREE O'Reilly Book
"Graph Databases" is the definitive new guide to graph databases and their
applications. Written by three acclaimed leaders in the field,
this first edition is now available. Download your free book today!
http://p.sf.net/sfu/13534_NeoTech
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
