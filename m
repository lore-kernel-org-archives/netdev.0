From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH net 3/9] virtio-net: fix page miscount during XDP linearizing
Date: Fri, 23 Dec 2016 22:37:26 +0800
Message-ID: <1482503852-12438-4-git-send-email-jasowang@redhat.com>
References: <1482503852-12438-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com
To: mst@redhat.com, virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1482503852-12438-1-git-send-email-jasowang@redhat.com>
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

We don't put page during linearizing, the would cause leaking when
xmit through XDP_TX or the packet exceeds PAGE_SIZE. Fix them by
put page accordingly. Also decrease the number of buffers during
linearizing to make sure caller can free buffers correctly when packet
exceeds PAGE_SIZE. With this patch, we won't get OOM after linearize
huge number of packets.

Cc: John Fastabend <john.r.fastabend@intel.com>
Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/net/virtio_net.c | 19 +++++++++++--------
 1 file changed, 11 insertions(+), 8 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index fe4562d..58ad40e 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -483,7 +483,7 @@ static struct sk_buff *receive_big(struct net_device *dev,
  * anymore.
  */
 static struct page *xdp_linearize_page(struct receive_queue *rq,
-				       u16 num_buf,
+				       u16 *num_buf,
 				       struct page *p,
 				       int offset,
 				       unsigned int *len)
@@ -497,7 +497,7 @@ static struct page *xdp_linearize_page(struct receive_queue *rq,
 	memcpy(page_address(page) + page_off, page_address(p) + offset, *len);
 	page_off += *len;
 
-	while (--num_buf) {
+	while (--*num_buf) {
 		unsigned int buflen;
 		unsigned long ctx;
 		void *buf;
@@ -507,19 +507,22 @@ static struct page *xdp_linearize_page(struct receive_queue *rq,
 		if (unlikely(!ctx))
 			goto err_buf;
 
+		buf = mergeable_ctx_to_buf_address(ctx);
+		p = virt_to_head_page(buf);
+		off = buf - page_address(p);
+
 		/* guard against a misconfigured or uncooperative backend that
 		 * is sending packet larger than the MTU.
 		 */
-		if ((page_off + buflen) > PAGE_SIZE)
+		if ((page_off + buflen) > PAGE_SIZE) {
+			put_page(p);
 			goto err_buf;
-
-		buf = mergeable_ctx_to_buf_address(ctx);
-		p = virt_to_head_page(buf);
-		off = buf - page_address(p);
+		}
 
 		memcpy(page_address(page) + page_off,
 		       page_address(p) + off, buflen);
 		page_off += buflen;
+		put_page(p);
 	}
 
 	*len = page_off;
@@ -555,7 +558,7 @@ static struct sk_buff *receive_mergeable(struct net_device *dev,
 		/* This happens when rx buffer size is underestimated */
 		if (unlikely(num_buf > 1)) {
 			/* linearize data for XDP */
-			xdp_page = xdp_linearize_page(rq, num_buf,
+			xdp_page = xdp_linearize_page(rq, &num_buf,
 						      page, offset, &len);
 			if (!xdp_page)
 				goto err_xdp;
-- 
2.7.4
