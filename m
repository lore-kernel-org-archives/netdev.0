From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH V2 4/6] vhost_net: determine whether or not to use zerocopy at
	one time
Date: Fri, 30 Aug 2013 12:29:20 +0800
Message-ID: <1377836962-49780-5-git-send-email-jasowang@redhat.com>
References: <1377836962-49780-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: mst@redhat.com, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1377836962-49780-1-git-send-email-jasowang@redhat.com>
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

Currently, even if the packet length is smaller than VHOST_GOODCOPY_LEN, if
upend_idx != done_idx we still set zcopy_used to true and rollback this choice
later. This could be avoided by determine zerocopy once by checking all
conditions at one time before.

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/vhost/net.c |   46 +++++++++++++++++++---------------------------
 1 files changed, 19 insertions(+), 27 deletions(-)

diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
index 8a6dd0d..ff60c2a 100644
--- a/drivers/vhost/net.c
+++ b/drivers/vhost/net.c
@@ -404,43 +404,35 @@ static void handle_tx(struct vhost_net *net)
 			       iov_length(nvq->hdr, s), hdr_size);
 			break;
 		}
-		zcopy_used = zcopy && (len >= VHOST_GOODCOPY_LEN ||
-				       nvq->upend_idx != nvq->done_idx);
+
+		zcopy_used = zcopy && len >= VHOST_GOODCOPY_LEN
+			&& (nvq->upend_idx + 1) % UIO_MAXIOV != nvq->done_idx
+			&& vhost_net_tx_select_zcopy(net);
 
 		/* use msg_control to pass vhost zerocopy ubuf info to skb */
 		if (zcopy_used) {
+			struct ubuf_info *ubuf;
+			ubuf = nvq->ubuf_info + nvq->upend_idx;
+
 			vq->heads[nvq->upend_idx].id = head;
-			if (!vhost_net_tx_select_zcopy(net) ||
-			    len < VHOST_GOODCOPY_LEN) {
-				/* copy don't need to wait for DMA done */
-				vq->heads[nvq->upend_idx].len =
-							VHOST_DMA_DONE_LEN;
-				msg.msg_control = NULL;
-				msg.msg_controllen = 0;
-				ubufs = NULL;
-			} else {
-				struct ubuf_info *ubuf;
-				ubuf = nvq->ubuf_info + nvq->upend_idx;
-
-				vq->heads[nvq->upend_idx].len =
-					VHOST_DMA_IN_PROGRESS;
-				ubuf->callback = vhost_zerocopy_callback;
-				ubuf->ctx = nvq->ubufs;
-				ubuf->desc = nvq->upend_idx;
-				msg.msg_control = ubuf;
-				msg.msg_controllen = sizeof(ubuf);
-				ubufs = nvq->ubufs;
-				kref_get(&ubufs->kref);
-			}
+			vq->heads[nvq->upend_idx].len = VHOST_DMA_IN_PROGRESS;
+			ubuf->callback = vhost_zerocopy_callback;
+			ubuf->ctx = nvq->ubufs;
+			ubuf->desc = nvq->upend_idx;
+			msg.msg_control = ubuf;
+			msg.msg_controllen = sizeof(ubuf);
+			ubufs = nvq->ubufs;
+			kref_get(&ubufs->kref);
 			nvq->upend_idx = (nvq->upend_idx + 1) % UIO_MAXIOV;
-		} else
+		} else {
 			msg.msg_control = NULL;
+			ubufs = NULL;
+		}
 		/* TODO: Check specific error and bomb out unless ENOBUFS? */
 		err = sock->ops->sendmsg(NULL, sock, &msg, len);
 		if (unlikely(err < 0)) {
 			if (zcopy_used) {
-				if (ubufs)
-					vhost_net_ubuf_put(ubufs);
+				vhost_net_ubuf_put(ubufs);
 				nvq->upend_idx = ((unsigned)nvq->upend_idx - 1)
 					% UIO_MAXIOV;
 			}
-- 
1.7.1
