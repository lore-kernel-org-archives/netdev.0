From: Michael Dalton <mwdalton@google.com>
Subject: [PATCH net-next 1/4] virtio-net: mergeable buffer size should include
	virtio-net header
Date: Tue, 12 Nov 2013 14:21:22 -0800
Message-ID: <1384294885-6444-1-git-send-email-mwdalton@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Michael Dalton <mwdalton@google.com>, "Michael S. Tsirkin" <mst@redhat.com>,
	netdev@vger.kernel.org, Daniel Borkmann <dborkman@redhat.com>,
	virtualization@lists.linux-foundation.org,
	Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

Commit 2613af0ed18a ("virtio_net: migrate mergeable rx buffers to page
frag allocators") changed the mergeable receive buffer size from PAGE_SIZE
to MTU-size. However, the merge buffer size does not take into account the
size of the virtio-net header. Consequently, packets that are MTU-size
will take two buffers intead of one (to store the virtio-net header),
substantially decreasing the throughput of MTU-size traffic due to TCP
window / SKB truesize effects.

This commit changes the mergeable buffer size to include the virtio-net
header. The buffer size is cacheline-aligned because skb_page_frag_refill
will not automatically align the requested size.

Benchmarks taken from an average of 5 netperf 30-second TCP_STREAM runs
between two QEMU VMs on a single physical machine. Each VM has two VCPUs and
vhost enabled. All VMs and vhost threads run in a single 4 CPU cgroup
cpuset, using cgroups to ensure that other processes in the system will not
be scheduled on the benchmark CPUs. Transmit offloads and mergeable receive
buffers are enabled, but guest_tso4 / guest_csum are explicitly disabled to
force MTU-sized packets on the receiver.

next-net trunk before 2613af0ed18a (PAGE_SIZE buf): 3861.08Gb/s
net-next trunk (MTU 1500- packet uses two buf due to size bug): 4076.62Gb/s
net-next trunk (MTU 1480- packet fits in one buf): 6301.34Gb/s
net-next trunk w/ size fix (MTU 1500 - packet fits in one buf): 6445.44Gb/s

Suggested-by: Eric Northup <digitaleric@google.com>
Signed-off-by: Michael Dalton <mwdalton@google.com>
---
 drivers/net/virtio_net.c | 30 ++++++++++++++++--------------
 1 file changed, 16 insertions(+), 14 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 01f4eb5..69fb225 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -36,7 +36,10 @@ module_param(csum, bool, 0444);
 module_param(gso, bool, 0444);
 
 /* FIXME: MTU in config. */
-#define MAX_PACKET_LEN (ETH_HLEN + VLAN_HLEN + ETH_DATA_LEN)
+#define GOOD_PACKET_LEN (ETH_HLEN + VLAN_HLEN + ETH_DATA_LEN)
+#define MERGE_BUFFER_LEN (ALIGN(GOOD_PACKET_LEN + \
+                                sizeof(struct virtio_net_hdr_mrg_rxbuf), \
+                                L1_CACHE_BYTES))
 #define GOOD_COPY_LEN	128
 
 #define VIRTNET_DRIVER_VERSION "1.0.0"
@@ -314,10 +317,10 @@ static int receive_mergeable(struct receive_queue *rq, struct sk_buff *head_skb)
 			head_skb->dev->stats.rx_length_errors++;
 			return -EINVAL;
 		}
-		if (unlikely(len > MAX_PACKET_LEN)) {
+		if (unlikely(len > MERGE_BUFFER_LEN)) {
 			pr_debug("%s: rx error: merge buffer too long\n",
 				 head_skb->dev->name);
-			len = MAX_PACKET_LEN;
+			len = MERGE_BUFFER_LEN;
 		}
 		if (unlikely(num_skb_frags == MAX_SKB_FRAGS)) {
 			struct sk_buff *nskb = alloc_skb(0, GFP_ATOMIC);
@@ -336,18 +339,17 @@ static int receive_mergeable(struct receive_queue *rq, struct sk_buff *head_skb)
 		if (curr_skb != head_skb) {
 			head_skb->data_len += len;
 			head_skb->len += len;
-			head_skb->truesize += MAX_PACKET_LEN;
+			head_skb->truesize += MERGE_BUFFER_LEN;
 		}
 		page = virt_to_head_page(buf);
 		offset = buf - (char *)page_address(page);
 		if (skb_can_coalesce(curr_skb, num_skb_frags, page, offset)) {
 			put_page(page);
 			skb_coalesce_rx_frag(curr_skb, num_skb_frags - 1,
-					     len, MAX_PACKET_LEN);
+					     len, MERGE_BUFFER_LEN);
 		} else {
 			skb_add_rx_frag(curr_skb, num_skb_frags, page,
-					offset, len,
-					MAX_PACKET_LEN);
+					offset, len, MERGE_BUFFER_LEN);
 		}
 		--rq->num;
 	}
@@ -383,7 +385,7 @@ static void receive_buf(struct receive_queue *rq, void *buf, unsigned int len)
 		struct page *page = virt_to_head_page(buf);
 		skb = page_to_skb(rq, page,
 				  (char *)buf - (char *)page_address(page),
-				  len, MAX_PACKET_LEN);
+				  len, MERGE_BUFFER_LEN);
 		if (unlikely(!skb)) {
 			dev->stats.rx_dropped++;
 			put_page(page);
@@ -471,11 +473,11 @@ static int add_recvbuf_small(struct receive_queue *rq, gfp_t gfp)
 	struct skb_vnet_hdr *hdr;
 	int err;
 
-	skb = __netdev_alloc_skb_ip_align(vi->dev, MAX_PACKET_LEN, gfp);
+	skb = __netdev_alloc_skb_ip_align(vi->dev, GOOD_PACKET_LEN, gfp);
 	if (unlikely(!skb))
 		return -ENOMEM;
 
-	skb_put(skb, MAX_PACKET_LEN);
+	skb_put(skb, GOOD_PACKET_LEN);
 
 	hdr = skb_vnet_hdr(skb);
 	sg_set_buf(rq->sg, &hdr->hdr, sizeof hdr->hdr);
@@ -542,20 +544,20 @@ static int add_recvbuf_mergeable(struct receive_queue *rq, gfp_t gfp)
 	int err;
 
 	if (gfp & __GFP_WAIT) {
-		if (skb_page_frag_refill(MAX_PACKET_LEN, &vi->alloc_frag,
+		if (skb_page_frag_refill(MERGE_BUFFER_LEN, &vi->alloc_frag,
 					 gfp)) {
 			buf = (char *)page_address(vi->alloc_frag.page) +
 			      vi->alloc_frag.offset;
 			get_page(vi->alloc_frag.page);
-			vi->alloc_frag.offset += MAX_PACKET_LEN;
+			vi->alloc_frag.offset += MERGE_BUFFER_LEN;
 		}
 	} else {
-		buf = netdev_alloc_frag(MAX_PACKET_LEN);
+		buf = netdev_alloc_frag(MERGE_BUFFER_LEN);
 	}
 	if (!buf)
 		return -ENOMEM;
 
-	sg_init_one(rq->sg, buf, MAX_PACKET_LEN);
+	sg_init_one(rq->sg, buf, MERGE_BUFFER_LEN);
 	err = virtqueue_add_inbuf(rq->vq, rq->sg, 1, buf, gfp);
 	if (err < 0)
 		put_page(virt_to_head_page(buf));
-- 
1.8.4.1
