From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH net-next] vhost_net: conditionally enable tx polling
Date: Tue, 31 Oct 2017 18:27:20 +0800
Message-ID: <1509445640-4085-1-git-send-email-jasowang@redhat.com>
Cc: kvm@vger.kernel.org, virtualization@lists.linux-foundation.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Wei Xu <wexu@redhat.com>,
        Matthew Rosato <mjrosato@linux.vnet.ibm.com>
To: mst@redhat.com, jasowang@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We always poll tx for socket, this is sub optimal since:

- we only want to be notified when sndbuf is available
- this will slightly increase the waitqueue traversing time and more
  important, vhost could not benefit from commit
  commit 9e641bdcfa4e
  ("net-tun: restructure tun_do_read for better sleep/wakeup efficiency")
  even if we've stopped rx polling during handle_rx() since tx poll
  were still left in the waitqueue.

Pktgen from a remote host to VM over mlx4 shows 5.5% improvements on
rx PPS. (from 1.27Mpps to 1.34Mpps)

Cc: Wei Xu <wexu@redhat.com>
Cc: Matthew Rosato <mjrosato@linux.vnet.ibm.com>
Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/vhost/net.c | 11 ++++++++---
 1 file changed, 8 insertions(+), 3 deletions(-)

diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
index 68677d9..286c3e4 100644
--- a/drivers/vhost/net.c
+++ b/drivers/vhost/net.c
@@ -471,6 +471,7 @@ static void handle_tx(struct vhost_net *net)
 		goto out;
 
 	vhost_disable_notify(&net->dev, vq);
+	vhost_net_disable_vq(net, vq);
 
 	hdr_size = nvq->vhost_hlen;
 	zcopy = nvq->ubufs;
@@ -556,6 +557,8 @@ static void handle_tx(struct vhost_net *net)
 					% UIO_MAXIOV;
 			}
 			vhost_discard_vq_desc(vq, 1);
+			if (err == -EAGAIN)
+				vhost_net_enable_vq(net, vq);
 			break;
 		}
 		if (err != len)
@@ -1145,9 +1148,11 @@ static long vhost_net_set_backend(struct vhost_net *n, unsigned index, int fd)
 		r = vhost_vq_init_access(vq);
 		if (r)
 			goto err_used;
-		r = vhost_net_enable_vq(n, vq);
-		if (r)
-			goto err_used;
+		if (index == VHOST_NET_VQ_RX) {
+			r = vhost_net_enable_vq(n, vq);
+			if (r)
+				goto err_used;
+		}
 
 		oldubufs = nvq->ubufs;
 		nvq->ubufs = ubufs;
-- 
2.7.4
