From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH 6/6] virtio_net: reduce alignment for buffers
Date: Wed, 29 Mar 2017 23:48:56 +0300
Message-ID: <1490820507-8005-7-git-send-email-mst@redhat.com>
References: <1490820507-8005-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, John Fastabend <john.fastabend@gmail.com>,
	virtualization@lists.linux-foundation.org
To: linux-kernel@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1490820507-8005-1-git-send-email-mst@redhat.com>
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

We don't need to align length to any particular
value anymore. Aligning to L1 cache size probably
sill makes sense to reduce false sharing.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 drivers/net/virtio_net.c | 13 +------------
 1 file changed, 1 insertion(+), 12 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 94f94f3..824dd95 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -53,17 +53,6 @@ module_param(gso, bool, 0444);
  */
 DECLARE_EWMA(pkt_len, 0, 64)
 
-/* With mergeable buffers we align buffer address and use the low bits to
- * encode its true size. Buffer size is up to 1 page so we need to align to
- * square root of page size to ensure we reserve enough bits to encode the true
- * size.
- */
-#define MERGEABLE_BUFFER_MIN_ALIGN_SHIFT ((PAGE_SHIFT + 1) / 2)
-
-/* Minimum alignment for mergeable packet buffers. */
-#define MERGEABLE_BUFFER_ALIGN max(L1_CACHE_BYTES, \
-				   1 << MERGEABLE_BUFFER_MIN_ALIGN_SHIFT)
-
 #define VIRTNET_DRIVER_VERSION "1.0.0"
 
 struct virtnet_stats {
@@ -849,7 +838,7 @@ static unsigned int get_mergeable_buf_len(struct ewma_pkt_len *avg_pkt_len)
 
 	len = hdr_len + clamp_t(unsigned int, ewma_pkt_len_read(avg_pkt_len),
 			GOOD_PACKET_LEN, PAGE_SIZE - hdr_len);
-	return ALIGN(len, MERGEABLE_BUFFER_ALIGN);
+	return ALIGN(len, L1_CACHE_BYTES);
 }
 
 static int add_recvbuf_mergeable(struct virtnet_info *vi,
-- 
MST
