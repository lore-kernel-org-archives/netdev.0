From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCHv3 net-next 8/8] vhost-net: reduce vq polling on tx zerocopy
Date: Thu, 1 Nov 2012 21:16:55 +0200
Message-ID: <9cc8a915e1faeccc79a7f34c9018e6390f34d800.1351797353.git.mst@redhat.com>
References: <cover.1351797353.git.mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vlad Yasevich <vyasevic@redhat.com>,
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
In-Reply-To: <cover.1351797353.git.mst@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It seems that to avoid deadlocks it is enough to poll vq before
 we are going to use the last buffer.  This is faster than
c70aa540c7a9f67add11ad3161096fb95233aa2e.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 drivers/vhost/net.c | 14 ++++++++++++--
 1 file changed, 12 insertions(+), 2 deletions(-)

diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
index 93f2d67..28ad775 100644
--- a/drivers/vhost/net.c
+++ b/drivers/vhost/net.c
@@ -197,8 +197,18 @@ static void vhost_zerocopy_callback(struct ubuf_info *ubuf, bool success)
 {
 	struct vhost_ubuf_ref *ubufs = ubuf->ctx;
 	struct vhost_virtqueue *vq = ubufs->vq;
-
-	vhost_poll_queue(&vq->poll);
+	int cnt = atomic_read(&ubufs->kref.refcount);
+
+	/*
+	 * Trigger polling thread if guest stopped submitting new buffers:
+	 * in this case, the refcount after decrement will eventually reach 1
+	 * so here it is 2.
+	 * We also trigger polling periodically after each 16 packets
+	 * (the value 16 here is more or less arbitrary, it's tuned to trigger
+	 * less than 10% of times).
+	 */
+	if (cnt <= 2 || !(cnt % 16))
+		vhost_poll_queue(&vq->poll);
 	/* set len to mark this desc buffers done DMA */
 	vq->heads[ubuf->desc].len = success ?
 		VHOST_DMA_DONE_LEN : VHOST_DMA_FAILED_LEN;
-- 
MST
