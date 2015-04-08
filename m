From: Vitaly Kuznetsov <vkuznets@redhat.com>
Subject: [PATCH 1/2] hv_netvsc: use single existing drop path in
 netvsc_start_xmit
Date: Wed,  8 Apr 2015 17:54:05 +0200
Message-ID: <1428508446-18423-2-git-send-email-vkuznets@redhat.com>
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

... which validly uses dev_kfree_skb_any() instead of dev_kfree_skb().

Setting ret to -EFAULT and -ENOMEM have no real meaning here (we need to set
it to anything but -EAGAIN) as we drop the packet and return NETDEV_TX_OK
anyway.

Signed-off-by: Vitaly Kuznetsov <vkuznets@redhat.com>
---
 drivers/net/hyperv/netvsc_drv.c | 14 ++++++--------
 1 file changed, 6 insertions(+), 8 deletions(-)

diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index e5fa094..9e4230d 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -370,7 +370,7 @@ not_ip:
 static int netvsc_start_xmit(struct sk_buff *skb, struct net_device *net)
 {
 	struct net_device_context *net_device_ctx = netdev_priv(net);
-	struct hv_netvsc_packet *packet;
+	struct hv_netvsc_packet *packet = NULL;
 	int ret;
 	unsigned int num_data_pgs;
 	struct rndis_message *rndis_msg;
@@ -396,9 +396,8 @@ static int netvsc_start_xmit(struct sk_buff *skb, struct net_device *net)
 	num_data_pgs = netvsc_get_slots(skb) + 2;
 	if (num_data_pgs > MAX_PAGE_BUFFER_COUNT) {
 		netdev_err(net, "Packet too big: %u\n", skb->len);
-		dev_kfree_skb(skb);
-		net->stats.tx_dropped++;
-		return NETDEV_TX_OK;
+		ret = -EFAULT;
+		goto drop;
 	}
 
 	pkt_sz = sizeof(struct hv_netvsc_packet) + RNDIS_AND_PPI_SIZE;
@@ -408,9 +407,8 @@ static int netvsc_start_xmit(struct sk_buff *skb, struct net_device *net)
 		if (!packet) {
 			/* out of memory, drop packet */
 			netdev_err(net, "unable to alloc hv_netvsc_packet\n");
-			dev_kfree_skb(skb);
-			net->stats.tx_dropped++;
-			return NETDEV_TX_OK;
+			ret = -ENOMEM;
+			goto drop;
 		}
 		packet->part_of_skb = false;
 	} else {
@@ -574,7 +572,7 @@ drop:
 		net->stats.tx_bytes += skb_length;
 		net->stats.tx_packets++;
 	} else {
-		if (!packet->part_of_skb)
+		if (packet && !packet->part_of_skb)
 			kfree(packet);
 		if (ret != -EAGAIN) {
 			dev_kfree_skb_any(skb);
-- 
1.9.3
