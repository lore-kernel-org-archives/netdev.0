From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH net V2] vhost_net: correctly check tx avail during rx busy polling
Date: Tue,  5 Sep 2017 09:22:05 +0800
Message-ID: <1504574525-4711-1-git-send-email-jasowang@redhat.com>
Cc: kvm@vger.kernel.org, virtualization@lists.linux-foundation.org,
        linux-kernel@vger.kernel.org
To: mst@redhat.com, jasowang@redhat.com, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We check tx avail through vhost_enable_notify() in the past which is
wrong since it only checks whether or not guest has filled more
available buffer since last avail idx synchronization which was just
done by vhost_vq_avail_empty() before. What we really want is checking
pending buffers in the avail ring. Fix this by calling
vhost_vq_avail_empty() instead.

This issue could be noticed by doing netperf TCP_RR benchmark as
client from guest (but not host). With this fix, TCP_RR from guest to
localhost restores from 1375.91 trans per sec to 55235.28 trans per
sec on my laptop (Intel(R) Core(TM) i7-5600U CPU @ 2.60GHz).

Fixes: 030881372460 ("vhost_net: basic polling support")
Signed-off-by: Jason Wang <jasowang@redhat.com>
---
- The patch is needed for -stable
- Changes from V1: enable vq notification when needed
---
 drivers/vhost/net.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
index 06d0448..1c75572 100644
--- a/drivers/vhost/net.c
+++ b/drivers/vhost/net.c
@@ -634,8 +634,13 @@ static int vhost_net_rx_peek_head_len(struct vhost_net *net, struct sock *sk)
 
 		preempt_enable();
 
-		if (vhost_enable_notify(&net->dev, vq))
+		if (!vhost_vq_avail_empty(&net->dev, vq))
 			vhost_poll_queue(&vq->poll);
+		else if (unlikely(vhost_enable_notify(&net->dev, vq))) {
+			vhost_disable_notify(&net->dev, vq);
+			vhost_poll_queue(&vq->poll);
+		}
+
 		mutex_unlock(&vq->mutex);
 
 		len = peek_head_len(rvq, sk);
-- 
2.7.4
