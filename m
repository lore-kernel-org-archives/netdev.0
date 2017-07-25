From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net 1/1] Revert "netvsc: optimize calculation of number of
 slots"
Date: Mon, 24 Jul 2017 21:03:19 -0700
Message-ID: <20170725040319.5969-2-sthemmin@microsoft.com>
References: <20170725040319.5969-1-sthemmin@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@linuxdriverproject.org, netdev@vger.kernel.org
To: kys@microsoft.com,
	haiyangz@microsoft.com,
	sthemmin@microsoft.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <20170725040319.5969-1-sthemmin@microsoft.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

The logic for computing page buffer scatter does not take into
account the impact of compound pages. Therefore the optimization
to compute number of slots was incorrect and could cause stack
corruption a skb was sent with lots of fragments from huge pages.

This reverts commit 60b86665af0dfbeebda8aae43f0ba451cd2dcfe5.

Fixes: 60b86665af0d ("netvsc: optimize calculation of number of slots")
Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 drivers/net/hyperv/netvsc_drv.c | 43 +++++++++++++++++++++++++++++++----------
 1 file changed, 33 insertions(+), 10 deletions(-)

diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index 63c98bbbc596..0d78727f1a14 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -315,14 +315,34 @@ static u32 init_page_array(void *hdr, u32 len, struct sk_buff *skb,
 	return slots_used;
 }
 
-/* Estimate number of page buffers neede to transmit
- * Need at most 2 for RNDIS header plus skb body and fragments.
- */
-static unsigned int netvsc_get_slots(const struct sk_buff *skb)
+static int count_skb_frag_slots(struct sk_buff *skb)
+{
+	int i, frags = skb_shinfo(skb)->nr_frags;
+	int pages = 0;
+
+	for (i = 0; i < frags; i++) {
+		skb_frag_t *frag = skb_shinfo(skb)->frags + i;
+		unsigned long size = skb_frag_size(frag);
+		unsigned long offset = frag->page_offset;
+
+		/* Skip unused frames from start of page */
+		offset &= ~PAGE_MASK;
+		pages += PFN_UP(offset + size);
+	}
+	return pages;
+}
+
+static int netvsc_get_slots(struct sk_buff *skb)
 {
-	return PFN_UP(offset_in_page(skb->data) + skb_headlen(skb))
-		+ skb_shinfo(skb)->nr_frags
-		+ 2;
+	char *data = skb->data;
+	unsigned int offset = offset_in_page(data);
+	unsigned int len = skb_headlen(skb);
+	int slots;
+	int frag_slots;
+
+	slots = DIV_ROUND_UP(offset + len, PAGE_SIZE);
+	frag_slots = count_skb_frag_slots(skb);
+	return slots + frag_slots;
 }
 
 static u32 net_checksum_info(struct sk_buff *skb)
@@ -360,18 +380,21 @@ static int netvsc_start_xmit(struct sk_buff *skb, struct net_device *net)
 	struct hv_page_buffer page_buf[MAX_PAGE_BUFFER_COUNT];
 	struct hv_page_buffer *pb = page_buf;
 
-	/* We can only transmit MAX_PAGE_BUFFER_COUNT number
+	/* We will atmost need two pages to describe the rndis
+	 * header. We can only transmit MAX_PAGE_BUFFER_COUNT number
 	 * of pages in a single packet. If skb is scattered around
 	 * more pages we try linearizing it.
 	 */
-	num_data_pgs = netvsc_get_slots(skb);
+
+	num_data_pgs = netvsc_get_slots(skb) + 2;
+
 	if (unlikely(num_data_pgs > MAX_PAGE_BUFFER_COUNT)) {
 		++net_device_ctx->eth_stats.tx_scattered;
 
 		if (skb_linearize(skb))
 			goto no_memory;
 
-		num_data_pgs = netvsc_get_slots(skb);
+		num_data_pgs = netvsc_get_slots(skb) + 2;
 		if (num_data_pgs > MAX_PAGE_BUFFER_COUNT) {
 			++net_device_ctx->eth_stats.tx_too_big;
 			goto drop;
-- 
2.11.0
