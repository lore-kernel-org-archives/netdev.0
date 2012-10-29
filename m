From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH net-next 1/8] skb: report completion status for zero copy skbs
Date: Mon, 29 Oct 2012 17:49:37 +0200
Message-ID: <0dc176ed796ff5ac7164b6c18cc75d64c2a2317e.1351524501.git.mst@redhat.com>
References: <cover.1351524501.git.mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Ian Campbell <Ian.Campbell@citrix.com>, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: unlisted-recipients:; (no To-header on input)
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <cover.1351524501.git.mst@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Even if skb is marked for zero copy, net core might still decide
to copy it later which is somewhat slower than a copy in user context:
besides copying the data we need to pin/unpin the pages.

Add a parameter reporting such cases through zero copy callback:
if this happens a lot, device can take this into account
and switch to copying in user context.

This patch updates all users but ignores the passed value for now:
it will be used by follow-up patches.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 drivers/vhost/vhost.c  | 2 +-
 drivers/vhost/vhost.h  | 2 +-
 include/linux/skbuff.h | 4 +++-
 net/core/skbuff.c      | 4 ++--
 4 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index 99ac2cb..92308b6 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -1600,7 +1600,7 @@ void vhost_ubuf_put_and_wait(struct vhost_ubuf_ref *ubufs)
 	kfree(ubufs);
 }
 
-void vhost_zerocopy_callback(struct ubuf_info *ubuf)
+void vhost_zerocopy_callback(struct ubuf_info *ubuf, int zerocopy_status)
 {
 	struct vhost_ubuf_ref *ubufs = ubuf->ctx;
 	struct vhost_virtqueue *vq = ubufs->vq;
diff --git a/drivers/vhost/vhost.h b/drivers/vhost/vhost.h
index 1125af3..eb7263c3 100644
--- a/drivers/vhost/vhost.h
+++ b/drivers/vhost/vhost.h
@@ -191,7 +191,7 @@ bool vhost_enable_notify(struct vhost_dev *, struct vhost_virtqueue *);
 
 int vhost_log_write(struct vhost_virtqueue *vq, struct vhost_log *log,
 		    unsigned int log_num, u64 len);
-void vhost_zerocopy_callback(struct ubuf_info *);
+void vhost_zerocopy_callback(struct ubuf_info *, int);
 int vhost_zerocopy_signal_used(struct vhost_virtqueue *vq);
 
 #define vq_err(vq, fmt, ...) do {                                  \
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 6a2c34e..8bac11b 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -235,11 +235,13 @@ enum {
 /*
  * The callback notifies userspace to release buffers when skb DMA is done in
  * lower device, the skb last reference should be 0 when calling this.
+ * The zerocopy_status argument is 0 if zero copy transmit occurred,
+ * 1 on successful data copy; < 0 on out of memory error.
  * The ctx field is used to track device context.
  * The desc field is used to track userspace buffer index.
  */
 struct ubuf_info {
-	void (*callback)(struct ubuf_info *);
+	void (*callback)(struct ubuf_info *, int zerocopy_status);
 	void *ctx;
 	unsigned long desc;
 };
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 6e04b1f..eb31f6e 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -519,7 +519,7 @@ static void skb_release_data(struct sk_buff *skb)
 
 			uarg = skb_shinfo(skb)->destructor_arg;
 			if (uarg->callback)
-				uarg->callback(uarg);
+				uarg->callback(uarg, 0);
 		}
 
 		if (skb_has_frag_list(skb))
@@ -797,7 +797,7 @@ int skb_copy_ubufs(struct sk_buff *skb, gfp_t gfp_mask)
 	for (i = 0; i < num_frags; i++)
 		skb_frag_unref(skb, i);
 
-	uarg->callback(uarg);
+	uarg->callback(uarg, 1);
 
 	/* skb frags point to kernel buffers */
 	for (i = num_frags - 1; i >= 0; i--) {
-- 
MST
