From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: [PATCH 4/5] net/hyperv: Fix the page buffer when an RNDIS message goes beyond page boundary
Date: Mon, 30 Jan 2012 08:33:37 -0800
Message-ID: <1327941218-12547-4-git-send-email-haiyangz@microsoft.com>
References: <1327941218-12547-1-git-send-email-haiyangz@microsoft.com>
To: haiyangz@microsoft.com, kys@microsoft.com, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from p3plsmtps2ded01.prod.phx3.secureserver.net ([208.109.80.58]:32918
	"HELO p3plsmtps2ded01-01.prod.phx3.secureserver.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1753320Ab2A3QhZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Jan 2012 11:37:25 -0500
In-Reply-To: <1327941218-12547-1-git-send-email-haiyangz@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is a possible data corruption if an RNDIS message goes beyond page
boundary in the sending code path. This patch fixes the problem.

Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
Signed-off-by: K. Y. Srinivasan <kys@microsoft.com>

---
 drivers/net/hyperv/netvsc_drv.c   |    8 ++++----
 drivers/net/hyperv/rndis_filter.c |   13 +++++++++++++
 2 files changed, 17 insertions(+), 4 deletions(-)

diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index af25771..cf5716b 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -151,10 +151,10 @@ static int netvsc_start_xmit(struct sk_buff *skb, struct net_device *net)
 	int ret;
 	unsigned int i, num_pages, npg_data;
 
-	/* Add multipage for skb->data and additional one for RNDIS */
+	/* Add multipages for skb->data and additional 2 for RNDIS */
 	npg_data = (((unsigned long)skb->data + skb_headlen(skb) - 1)
 		>> PAGE_SHIFT) - ((unsigned long)skb->data >> PAGE_SHIFT) + 1;
-	num_pages = skb_shinfo(skb)->nr_frags + npg_data + 1;
+	num_pages = skb_shinfo(skb)->nr_frags + npg_data + 2;
 
 	/* Allocate a netvsc packet based on # of frags. */
 	packet = kzalloc(sizeof(struct hv_netvsc_packet) +
@@ -173,8 +173,8 @@ static int netvsc_start_xmit(struct sk_buff *skb, struct net_device *net)
 				sizeof(struct hv_netvsc_packet) +
 				    (num_pages * sizeof(struct hv_page_buffer));
 
-	/* Setup the rndis header */
-	packet->page_buf_cnt = num_pages;
+	/* If the rndis msg goes beyond 1 page, we will add 1 later */
+	packet->page_buf_cnt = num_pages - 1;
 
 	/* Initialize it from the skb */
 	packet->total_data_buflen = skb->len;
diff --git a/drivers/net/hyperv/rndis_filter.c b/drivers/net/hyperv/rndis_filter.c
index c0aa8b0..6add018 100644
--- a/drivers/net/hyperv/rndis_filter.c
+++ b/drivers/net/hyperv/rndis_filter.c
@@ -776,6 +776,19 @@ int rndis_filter_send(struct hv_device *dev,
 			(unsigned long)rndis_msg & (PAGE_SIZE-1);
 	pkt->page_buf[0].len = rndis_msg_size;
 
+	/* Add one page_buf if the rndis msg goes beyond page boundary */
+	if (pkt->page_buf[0].offset + rndis_msg_size > PAGE_SIZE) {
+		int i;
+		for (i = pkt->page_buf_cnt; i > 1; i--)
+			pkt->page_buf[i] = pkt->page_buf[i-1];
+		pkt->page_buf_cnt++;
+		pkt->page_buf[0].len = PAGE_SIZE - pkt->page_buf[0].offset;
+		pkt->page_buf[1].pfn = virt_to_phys((void *)((ulong)rndis_msg +
+			pkt->page_buf[0].len)) >> PAGE_SHIFT;
+		pkt->page_buf[1].offset = 0;
+		pkt->page_buf[1].len = rndis_msg_size - pkt->page_buf[0].len;
+	}
+
 	/* Save the packet send completion and context */
 	filter_pkt->completion = pkt->completion.send.send_completion;
 	filter_pkt->completion_ctx =
-- 
1.7.7
