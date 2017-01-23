From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH] virtio_net: fix PAGE_SIZE > 64k
Date: Mon, 23 Jan 2017 19:06:11 +0200
Message-ID: <1485189896-20327-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jason Wang <jasowang@redhat.com>,
        virtualization@lists.linux-foundation.org, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I don't have any guests with PAGE_SIZE > 64k but the
code seems to be clearly broken in that case
as PAGE_SIZE / MERGEABLE_BUFFER_ALIGN will need
more than 8 bit and so the code in mergeable_ctx_to_buf_address
does not give us the actual true size.

Cc: John Fastabend <john.fastabend@gmail.com>
Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---

Lightly tested on x86 only.

 drivers/net/virtio_net.c | 10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 4a10500..5e3b07e 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -48,8 +48,16 @@ module_param(gso, bool, 0444);
  */
 DECLARE_EWMA(pkt_len, 1, 64)
 
+/* With mergeable buffers we align buffer address and use the low bits to
+ * encode its true size. Buffer size is up to 1 page so we need to align to
+ * square root of page size to ensure we reserve enough bits to encode the true
+ * size.
+ */
+#define MERGEABLE_BUFFER_MIN_ALIGN_SHIFT ((PAGE_SHIFT + 1) / 2)
+
 /* Minimum alignment for mergeable packet buffers. */
-#define MERGEABLE_BUFFER_ALIGN max(L1_CACHE_BYTES, 256)
+#define MERGEABLE_BUFFER_ALIGN max(L1_CACHE_BYTES, \
+				   1U << MERGEABLE_BUFFER_MIN_ALIGN_SHIFT)
 
 #define VIRTNET_DRIVER_VERSION "1.0.0"
 
-- 
MST
