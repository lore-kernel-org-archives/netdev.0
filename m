From: Mike Waychison <mikew@google.com>
Subject: [RFC PATCH v1 1/2] virtio_net: Pass gfp flags when allocating rx
	buffers.
Date: Wed, 04 Jan 2012 14:52:32 -0800
Message-ID: <20120104225231.18184.96390.stgit@mike2.sea.corp.google.com>
References: <20120104225223.18184.1537.stgit@mike2.sea.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: Rusty Russell <rusty@rustcorp.com.au>,
	"Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120104225223.18184.1537.stgit@mike2.sea.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Currently, the refill path for RX buffers will always allocate the
buffers as GFP_ATOMIC, even if we are in process context.  This will
fail to apply memory pressure as the worker thread will not contribute
to the freeing of memory.

Fix this by changing add_recvbuf_small to use the gfp variant allocator,
__netdev_alloc_skb_ip_align().

Signed-off-by: Mike Waychison <mikew@google.com>
---
 drivers/net/virtio_net.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 2055386..76fe14e 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -156,6 +156,7 @@ static void set_skb_frag(struct sk_buff *skb, struct page *page,
 	*len -= size;
 }
 
+/* Called from bottom half context */
 static struct sk_buff *page_to_skb(struct virtnet_info *vi,
 				   struct page *page, unsigned int len)
 {
@@ -358,7 +359,7 @@ static int add_recvbuf_small(struct virtnet_info *vi, gfp_t gfp)
 	struct skb_vnet_hdr *hdr;
 	int err;
 
-	skb = netdev_alloc_skb_ip_align(vi->dev, MAX_PACKET_LEN);
+	skb = __netdev_alloc_skb_ip_align(vi->dev, MAX_PACKET_LEN, gfp);
 	if (unlikely(!skb))
 		return -ENOMEM;
 
