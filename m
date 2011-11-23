From: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
Subject: [PATCH] qlge: fix size of external list for TX address descriptors
Date: Wed, 23 Nov 2011 21:10:42 -0200
Message-ID: <1322089842-11694-1-git-send-email-cascardo@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-driver@qlogic.com,
	Ron Mercer <ron.mercer@qlogic.com>,
	Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>,
	Anirban Chakraborty <anirban.chakraborty@qlogic.com>,
	Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When transmiting a fragmented skb, qlge fills a descriptor with the
fragment addresses, after DMA-mapping them. If there are more than eight
fragments, it will use the eighth descriptor as a pointer to an external
list. After mapping this external list, called OAL to a structure
containing more descriptors, it fills it with the extra fragments.

However, considering that systems with pages larger than 8KiB would have
less than 8 fragments, which was true before commit a715dea3c8e, it
defined a macro for the OAL size as 0 in those cases.

Now, if a skb with more than 8 fragments (counting skb->data as one
fragment), this would start overwriting the list of addresses already
mapped and would make the driver fail to properly unmap the right
addresses on architectures with pages larger than 8KiB.

Besides that, the list of mappings was one size too small, since it must
have a mapping for the maxinum number of skb fragments plus one for
skb->data and another for the OAL. So, even on architectures with page
sizes 4KiB and 8KiB, a skb with the maximum number of fragments would
make the driver overwrite its counter for the number of mappings, which,
again, would make it fail to unmap the mapped DMA addresses.

Signed-off-by: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
---
 drivers/net/ethernet/qlogic/qlge/qlge.h |    8 +++-----
 1 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlge/qlge.h b/drivers/net/ethernet/qlogic/qlge/qlge.h
index 8731f79..b8478aa 100644
--- a/drivers/net/ethernet/qlogic/qlge/qlge.h
+++ b/drivers/net/ethernet/qlogic/qlge/qlge.h
@@ -58,10 +58,8 @@
 
 
 #define TX_DESC_PER_IOCB 8
-/* The maximum number of frags we handle is based
- * on PAGE_SIZE...
- */
-#if (PAGE_SHIFT == 12) || (PAGE_SHIFT == 13)	/* 4k & 8k pages */
+
+#if ((MAX_SKB_FRAGS - TX_DESC_PER_IOCB) + 2) > 0
 #define TX_DESC_PER_OAL ((MAX_SKB_FRAGS - TX_DESC_PER_IOCB) + 2)
 #else /* all other page sizes */
 #define TX_DESC_PER_OAL 0
@@ -1353,7 +1351,7 @@ struct tx_ring_desc {
 	struct ob_mac_iocb_req *queue_entry;
 	u32 index;
 	struct oal oal;
-	struct map_list map[MAX_SKB_FRAGS + 1];
+	struct map_list map[MAX_SKB_FRAGS + 2];
 	int map_cnt;
 	struct tx_ring_desc *next;
 };
-- 
1.7.4.4
