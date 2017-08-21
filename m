From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH] vhost: fix end of range for access_ok
Date: Mon, 21 Aug 2017 22:45:07 +0300
Message-ID: <1503344576-8141-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Koichiro Den <den@klaipeden.com>, Jason Wang <jasowang@redhat.com>,
        kvm@vger.kernel.org, virtualization@lists.linux-foundation.org,
        netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

During access_ok checks, addr increases as we iterate over the data
structure, thus addr + len - 1 will point beyond the end of region we
are translating.  Harmless since we then verify that the region covers
addr, but let's not waste cpu cycles.

Reported-by: Koichiro Den <den@klaipeden.com>
Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---

Lightly tested, would appreciate an ack from reporter.

 drivers/vhost/vhost.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index e4613a3..ecd70e4 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -1176,7 +1176,7 @@ static int iotlb_access_ok(struct vhost_virtqueue *vq,
 {
 	const struct vhost_umem_node *node;
 	struct vhost_umem *umem = vq->iotlb;
-	u64 s = 0, size, orig_addr = addr;
+	u64 s = 0, size, orig_addr = addr, last = addr + len - 1;
 
 	if (vhost_vq_meta_fetch(vq, addr, len, type))
 		return true;
@@ -1184,7 +1184,7 @@ static int iotlb_access_ok(struct vhost_virtqueue *vq,
 	while (len > s) {
 		node = vhost_umem_interval_tree_iter_first(&umem->umem_tree,
 							   addr,
-							   addr + len - 1);
+							   last);
 		if (node == NULL || node->start > addr) {
 			vhost_iotlb_miss(vq, addr, access);
 			return false;
-- 
MST
