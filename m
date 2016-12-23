From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH net 5/9] virtio-net: unbreak csumed packets for XDP_PASS
Date: Fri, 23 Dec 2016 22:37:28 +0800
Message-ID: <1482503852-12438-6-git-send-email-jasowang@redhat.com>
References: <1482503852-12438-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com
To: mst@redhat.com, virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1482503852-12438-1-git-send-email-jasowang@redhat.com>
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

We drop csumed packet when do XDP for packets. This breaks
XDP_PASS when GUEST_CSUM is supported. Fix this by allowing csum flag
to be set. With this patch, simple TCP works for XDP_PASS.

Cc: John Fastabend <john.r.fastabend@intel.com>
Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/net/virtio_net.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 470293e..0778dc8 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -440,7 +440,7 @@ static struct sk_buff *receive_big(struct net_device *dev,
 		struct virtio_net_hdr_mrg_rxbuf *hdr = buf;
 		u32 act;
 
-		if (unlikely(hdr->hdr.gso_type || hdr->hdr.flags))
+		if (unlikely(hdr->hdr.gso_type))
 			goto err_xdp;
 		act = do_xdp_prog(vi, rq, xdp_prog, page, 0, len);
 		switch (act) {
@@ -572,7 +572,7 @@ static struct sk_buff *receive_mergeable(struct net_device *dev,
 		 * the receive path after XDP is loaded. In practice I
 		 * was not able to create this condition.
 		 */
-		if (unlikely(hdr->hdr.gso_type || hdr->hdr.flags))
+		if (unlikely(hdr->hdr.gso_type))
 			goto err_xdp;
 
 		act = do_xdp_prog(vi, rq, xdp_prog, xdp_page, offset, len);
-- 
2.7.4
