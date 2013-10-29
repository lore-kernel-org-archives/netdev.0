From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net-next] virtio_net: migrate mergeable rx buffers to
	page frag allocators
Date: Tue, 29 Oct 2013 14:27:11 +0800
Message-ID: <526F553F.8060708@redhat.com>
References: <1383000258-1458-1-git-send-email-mwdalton@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org,
	Daniel Borkmann <dborkman@redhat.com>,
	virtualization@lists.linux-foundation.org,
	Eric Dumazet <edumazet@google.com>
To: Michael Dalton <mwdalton@google.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1383000258-1458-1-git-send-email-mwdalton@google.com>
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

On 10/29/2013 06:44 AM, Michael Dalton wrote:
> The virtio_net driver's mergeable receive buffer allocator
> uses 4KB packet buffers. For MTU-sized traffic, SKB truesize
> is > 4KB but only ~1500 bytes of the buffer is used to store
> packet data, reducing the effective TCP window size
> substantially. This patch addresses the performance concerns
> with mergeable receive buffers by allocating MTU-sized packet
> buffers using page frag allocators. If more than MAX_SKB_FRAGS
> buffers are needed, the SKB frag_list is used.
>
> Signed-off-by: Michael Dalton <mwdalton@google.com>

Do you have any perf numberf of this patch? Have a glance of the patch,
looks like it will hurt the performance of large GSO packet. Always
allocating 1500 bytes mean a virtqueue can only hold about 4 full size
gso packets, and frag list will introduce extra overheads on skb
allocation. I just test it on my desktop, performance of full size gso
packet drops about 10%.

Mergeable buffer is a good balance between performance and the space it
occupies. If you just want a ~1500 bytes packet to be received, you can
just disable the mergeable buffer and just use small packet.

Alternatively, a simpler way is just use build_skb() and head frag to
build the skb directly on the page for medium size packets (small
packets were still copied) like following patch (may need more work
since vnet header is too short for NET_SKB_PAD). This can reduce the
truesize while keep the performance for large GSO packet.

---
 drivers/net/virtio_net.c |   48
++++++++++++++++++++++++++++++---------------
 1 files changed, 32 insertions(+), 16 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 3c23fdc..4c7ad89 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -239,16 +239,12 @@ static struct sk_buff *page_to_skb(struct
receive_queue *rq,
     struct skb_vnet_hdr *hdr;
     unsigned int copy, hdr_len, offset;
     char *p;
+    int skb_size = SKB_DATA_ALIGN(len) +
+               SKB_DATA_ALIGN(sizeof(struct skb_shared_info));
+    bool frag;
 
     p = page_address(page);
 
-    /* copy small packet so we can reuse these pages for small data */
-    skb = netdev_alloc_skb_ip_align(vi->dev, GOOD_COPY_LEN);
-    if (unlikely(!skb))
-        return NULL;
-
-    hdr = skb_vnet_hdr(skb);
-
     if (vi->mergeable_rx_bufs) {
         hdr_len = sizeof hdr->mhdr;
         offset = hdr_len;
@@ -257,18 +253,38 @@ static struct sk_buff *page_to_skb(struct
receive_queue *rq,
         offset = sizeof(struct padded_vnet_hdr);
     }
 
-    memcpy(hdr, p, hdr_len);
-
     len -= hdr_len;
     p += offset;
 
-    copy = len;
-    if (copy > skb_tailroom(skb))
-        copy = skb_tailroom(skb);
-    memcpy(skb_put(skb, copy), p, copy);
+    frag = (len > GOOD_COPY_LEN) && (skb_size <= PAGE_SIZE) &&
+        vi->mergeable_rx_bufs;
+    if (frag) {
+        skb = build_skb(page_address(page), skb_size);
+        if (unlikely(!skb))
+            return NULL;
+
+        skb_reserve(skb, offset);
+        skb_put(skb, len);
+        len = 0;
+    } else {
+        /* copy small packet so we can reuse these pages for small data
+         */
+        skb = netdev_alloc_skb_ip_align(vi->dev, GOOD_COPY_LEN);
+        if (unlikely(!skb))
+            return NULL;
+
+        copy = len;
+        if (copy > skb_tailroom(skb))
+            copy = skb_tailroom(skb);
+        memcpy(skb_put(skb, copy), p, copy);
+
+        len -= copy;
+        offset += copy;
+    }
+
+    hdr = skb_vnet_hdr(skb);
 
-    len -= copy;
-    offset += copy;
+    memcpy(hdr, page_address(page), hdr_len);
 
     /*
      * Verify that we can indeed put this data into a skb.
@@ -288,7 +304,7 @@ static struct sk_buff *page_to_skb(struct
receive_queue *rq,
         offset = 0;
     }
 
-    if (page)
+    if (page && !frag)
         give_pages(rq, page);
 
     return skb;
-- 
1.7.1
