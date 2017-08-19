From: Koichiro Den <den@klaipeden.com>
Subject: [PATCH 2/2] vhost-net: revert vhost_exceeds_maxpend logic to its original
Date: Sat, 19 Aug 2017 15:41:29 +0900
Message-ID: <20170819064129.27272-1-den@klaipeden.com>
Cc: kvm@vger.kernel.org, virtualization@lists.linux-foundation.org,
        netdev@vger.kernel.org
To: mst@redhat.com, jasowang@redhat.com
Return-path: <kvm-owner@vger.kernel.org>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

To depend on vq.num and the usage of VHOST_MAX_PEND is not succinct
and in some case unexpected, so revert its logic part only.

Signed-off-by: Koichiro Den <den@klaipeden.com>
---
 drivers/vhost/net.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
index 06d044862e58..99cf99b308a7 100644
--- a/drivers/vhost/net.c
+++ b/drivers/vhost/net.c
@@ -433,11 +433,15 @@ static int vhost_net_tx_get_vq_desc(struct vhost_net *net,
 
 static bool vhost_exceeds_maxpend(struct vhost_net *net)
 {
+	int num_pends;
 	struct vhost_net_virtqueue *nvq = &net->vqs[VHOST_NET_VQ_TX];
 	struct vhost_virtqueue *vq = &nvq->vq;
 
-	return (nvq->upend_idx + vq->num - VHOST_MAX_PEND) % UIO_MAXIOV
-		== nvq->done_idx;
+	num_pends = likely(nvq->upend_idx >= nvq->done_idx) ?
+		(nvq->upend_idx - nvq->done_idx) :
+		(nvq->upend_idx + UIO_MAXIOV - nvq->done_idx);
+
+	return num_pends > VHOST_MAX_PEND;
 }
 
 /* Expects to be always run from workqueue - which acts as
-- 
2.9.4
