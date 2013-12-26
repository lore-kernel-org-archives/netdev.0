From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH stable v2 3/3] virtio_net: don't leak memory or block when
	too many frags
Date: Thu, 26 Dec 2013 15:32:55 +0200
Message-ID: <1388064752-15734-4-git-send-email-mst@redhat.com>
References: <1388064752-15734-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org,
	David Miller <davem@davemloft.net>, Michael Dalton <mwdalton@google.com>
To: netdev@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1388064752-15734-1-git-send-email-mst@redhat.com>
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

We leak an skb when there are too many frags,
we also stop processing the packet in the middle,
the result is almost sure to be loss of networking.

Reported-by: Michael Dalton <mwdalton@google.com>
Acked-by: Michael Dalton <mwdalton@google.com>
Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 drivers/net/virtio_net.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index c0ed6d5..b8665588 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -344,7 +344,7 @@ static struct sk_buff *receive_mergeable(struct net_device *dev,
 		if (i >= MAX_SKB_FRAGS) {
 			pr_debug("%s: packet too long\n", skb->dev->name);
 			skb->dev->stats.rx_length_errors++;
-			return NULL;
+			goto err_frags;
 		}
 		page = virtqueue_get_buf(rq->vq, &len);
 		if (!page) {
@@ -365,6 +365,7 @@ static struct sk_buff *receive_mergeable(struct net_device *dev,
 err_skb:
 	give_pages(rq, page);
 	while (--num_buf) {
+err_frags:
 		buf = virtqueue_get_buf(rq->vq, &len);
 		if (unlikely(!buf)) {
 			pr_debug("%s: rx error: %d buffers missing\n",
-- 
MST
