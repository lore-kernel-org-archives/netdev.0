From: Vitaly Kuznetsov <vkuznets@redhat.com>
Subject: [PATCH 2/2] hv_netvsc: try linearizing big SKBs before dropping them
Date: Wed,  8 Apr 2015 17:54:06 +0200
Message-ID: <1428508446-18423-3-git-send-email-vkuznets@redhat.com>
References: <1428508446-18423-1-git-send-email-vkuznets@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@linuxdriverproject.org, Jason Wang <jasowang@redhat.com>,
 linux-kernel@vger.kernel.org
To: "K. Y. Srinivasan" <kys@microsoft.com>,
 Haiyang Zhang <haiyangz@microsoft.com>, netdev@vger.kernel.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1428508446-18423-1-git-send-email-vkuznets@redhat.com>
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

In netvsc_start_xmit() we can handle packets which are scattered around not
more than MAX_PAGE_BUFFER_COUNT-2 pages. It is, however, easy to create a
packet which is not big in size but occupies more pages (e.g. if it uses frags
on compound pages boundaries). When we drop such packet it cases sender to try
resending it but in most cases it will try resending the same packet which will
also get dropped, this will cause the particular connection to stick. To solve
the issue we can try linearizing skb.

Signed-off-by: Vitaly Kuznetsov <vkuznets@redhat.com>
---
 drivers/net/hyperv/netvsc_drv.c | 25 ++++++++++++++++++++-----
 1 file changed, 20 insertions(+), 5 deletions(-)

diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index 9e4230d..4487167 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -377,27 +377,42 @@ static int netvsc_start_xmit(struct sk_buff *skb, struct net_device *net)
 	struct rndis_packet *rndis_pkt;
 	u32 rndis_msg_size;
 	bool isvlan;
+	bool linear = false;
 	struct rndis_per_packet_info *ppi;
 	struct ndis_tcp_ip_checksum_info *csum_info;
 	struct ndis_tcp_lso_info *lso_info;
 	int  hdr_offset;
 	u32 net_trans_info;
 	u32 hash;
-	u32 skb_length = skb->len;
-	u32 head_room = skb_headroom(skb);
+	u32 skb_length;
+	u32 head_room;
 	u32 pkt_sz;
 	struct hv_page_buffer page_buf[MAX_PAGE_BUFFER_COUNT];
 
 
 	/* We will atmost need two pages to describe the rndis
 	 * header. We can only transmit MAX_PAGE_BUFFER_COUNT number
-	 * of pages in a single packet.
+	 * of pages in a single packet. If skb is scattered around
+	 * more pages we try linearizing it.
 	 */
+
+check_size:
+	skb_length = skb->len;
+	head_room = skb_headroom(skb);
 	num_data_pgs = netvsc_get_slots(skb) + 2;
-	if (num_data_pgs > MAX_PAGE_BUFFER_COUNT) {
-		netdev_err(net, "Packet too big: %u\n", skb->len);
+	if (num_data_pgs > MAX_PAGE_BUFFER_COUNT && linear) {
+		net_alert_ratelimited("packet too big: %u pages (%u bytes)\n",
+				      num_data_pgs, skb->len);
 		ret = -EFAULT;
 		goto drop;
+	} else if (num_data_pgs > MAX_PAGE_BUFFER_COUNT) {
+		if (skb_linearize(skb)) {
+			net_alert_ratelimited("failed to linearize skb\n");
+			ret = -ENOMEM;
+			goto drop;
+		}
+		linear = true;
+		goto check_size;
 	}
 
 	pkt_sz = sizeof(struct hv_netvsc_packet) + RNDIS_AND_PPI_SIZE;
-- 
1.9.3
