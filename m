From: Jason Wang <jasowang@redhat.com>
Subject: [V2 PATCH 6/9] vhost_net: zerocopy: fix possible NULL pointer
 dereference of vq->bufs
Date: Wed, 02 May 2012 11:42:23 +0800
Message-ID: <20120502034223.11782.31222.stgit@amd-6168-8-1.englab.nay.redhat.com>
References: <20120502033901.11782.13157.stgit@amd-6168-8-1.englab.nay.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: eric.dumazet@gmail.com, mst@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, ebiederm@xmission.com,
	davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120502033901.11782.13157.stgit@amd-6168-8-1.englab.nay.redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When we want to disable vhost_net backend while there's a tx work, a possible
NULL pointer defernece may happen we we try to deference the vq->bufs after
vhost_net_set_backend() assign a NULL to it.

As suggested by Michael, fix this by checking the vq->bufs instead of
vhost_sock_zcopy().
---
 drivers/vhost/net.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
index f0da2c3..ffdc0d8 100644
--- a/drivers/vhost/net.c
+++ b/drivers/vhost/net.c
@@ -166,7 +166,7 @@ static void handle_tx(struct vhost_net *net)
 	if (wmem < sock->sk->sk_sndbuf / 2)
 		tx_poll_stop(net);
 	hdr_size = vq->vhost_hlen;
-	zcopy = vhost_sock_zcopy(sock);
+	zcopy = vq->ubufs;
 
 	for (;;) {
 		/* Release DMAs done buffers first */
