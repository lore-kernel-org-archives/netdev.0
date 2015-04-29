From: "K. Y. Srinivasan" <kys@microsoft.com>
Subject: [PATCH V2 net 1/1] hv_netvsc: Fix a bug in netvsc_start_xmit()
Date: Tue, 28 Apr 2015 17:59:48 -0700
Message-ID: <1430269188-31701-1-git-send-email-kys@microsoft.com>
Cc: "K. Y. Srinivasan" <kys@microsoft.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, devel@linuxdriverproject.org,
	olaf@aepfle.de, apw@canonical.com, jasowang@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commit b08cc79155fc26d0d112b1470d1ece5034651a4b eliminated memory
allocation in the packet send path:

    "hv_netvsc: Eliminate memory allocation in the packet send path

    The network protocol used to communicate with the host is the remote ndis (rndis)
    protocol. We need to decorate each outgoing packet with a rndis header and
    additional rndis state (rndis per-packet state). To manage this state, we
    currently allocate memory in the transmit path. Eliminate this allocation by
    requesting additional head room in the skb."

This commit introduced a bug since it did not account for the case if the skb
was cloned. Fix this bug.


Signed-off-by: K. Y. Srinivasan <kys@microsoft.com>
---
	V2: Used skb_cow_head() based on Dave Miller's feedback
	V2: Fixed up the commit log based on feedback from Sergei Shtylyov

 drivers/net/hyperv/hyperv_net.h |    1 -
 drivers/net/hyperv/netvsc.c     |    5 -----
 drivers/net/hyperv/netvsc_drv.c |   27 +++++++--------------------
 3 files changed, 7 insertions(+), 26 deletions(-)

diff --git a/drivers/net/hyperv/hyperv_net.h b/drivers/net/hyperv/hyperv_net.h
index a10b316..ae04eb5 100644
--- a/drivers/net/hyperv/hyperv_net.h
+++ b/drivers/net/hyperv/hyperv_net.h
@@ -128,7 +128,6 @@ struct ndis_tcp_ip_checksum_info;
 struct hv_netvsc_packet {
 	/* Bookkeeping stuff */
 	u32 status;
-	bool part_of_skb;
 
 	bool is_data_pkt;
 	bool xmit_more; /* from skb */
diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
index 2e8ad06..6d0ac8f 100644
--- a/drivers/net/hyperv/netvsc.c
+++ b/drivers/net/hyperv/netvsc.c
@@ -889,11 +889,6 @@ int netvsc_send(struct hv_device *device,
 		} else {
 			packet->page_buf_cnt = 0;
 			packet->total_data_buflen += msd_len;
-			if (!packet->part_of_skb) {
-				skb = (struct sk_buff *)(unsigned long)packet->
-				       send_completion_tid;
-				packet->send_completion_tid = 0;
-			}
 		}
 
 		if (msdp->pkt)
diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index a3a9d38..19037a6 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -235,9 +235,6 @@ void netvsc_xmit_completion(void *context)
 	struct sk_buff *skb = (struct sk_buff *)
 		(unsigned long)packet->send_completion_tid;
 
-	if (!packet->part_of_skb)
-		kfree(packet);
-
 	if (skb)
 		dev_kfree_skb_any(skb);
 }
@@ -389,7 +386,6 @@ static int netvsc_start_xmit(struct sk_buff *skb, struct net_device *net)
 	u32 net_trans_info;
 	u32 hash;
 	u32 skb_length;
-	u32 head_room;
 	u32 pkt_sz;
 	struct hv_page_buffer page_buf[MAX_PAGE_BUFFER_COUNT];
 
@@ -402,7 +398,6 @@ static int netvsc_start_xmit(struct sk_buff *skb, struct net_device *net)
 
 check_size:
 	skb_length = skb->len;
-	head_room = skb_headroom(skb);
 	num_data_pgs = netvsc_get_slots(skb) + 2;
 	if (num_data_pgs > MAX_PAGE_BUFFER_COUNT && linear) {
 		net_alert_ratelimited("packet too big: %u pages (%u bytes)\n",
@@ -421,20 +416,14 @@ check_size:
 
 	pkt_sz = sizeof(struct hv_netvsc_packet) + RNDIS_AND_PPI_SIZE;
 
-	if (head_room < pkt_sz) {
-		packet = kmalloc(pkt_sz, GFP_ATOMIC);
-		if (!packet) {
-			/* out of memory, drop packet */
-			netdev_err(net, "unable to alloc hv_netvsc_packet\n");
-			ret = -ENOMEM;
-			goto drop;
-		}
-		packet->part_of_skb = false;
-	} else {
-		/* Use the headroom for building up the packet */
-		packet = (struct hv_netvsc_packet *)skb->head;
-		packet->part_of_skb = true;
+	ret = skb_cow_head(skb, pkt_sz);
+	if (ret) {
+		netdev_err(net, "unable to alloc hv_netvsc_packet\n");
+		ret = -ENOMEM;
+		goto drop;
 	}
+	/* Use the headroom for building up the packet */
+	packet = (struct hv_netvsc_packet *)skb->head;
 
 	packet->status = 0;
 	packet->xmit_more = skb->xmit_more;
@@ -591,8 +580,6 @@ drop:
 		net->stats.tx_bytes += skb_length;
 		net->stats.tx_packets++;
 	} else {
-		if (packet && !packet->part_of_skb)
-			kfree(packet);
 		if (ret != -EAGAIN) {
 			dev_kfree_skb_any(skb);
 			net->stats.tx_dropped++;
-- 
1.7.4.1
