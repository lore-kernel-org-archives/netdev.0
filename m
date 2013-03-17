From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH net] vhost/net: fix heads usage of ubuf_info
Date: Sun, 17 Mar 2013 14:46:09 +0200
Message-ID: <20130317124609.GA25967@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"Nicholas A. Bellinger" <nab@risingtidesystems.com>,
	virtualization@lists.linux-foundation.org, stable@kernel.org,
	Basil Gor <basil.gor@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
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

ubuf info allocator uses guest controlled head as an index,
so a malicious guest could put the same head entry in the ring twice,
and we will get two callbacks on the same value.
To fix use upend_idx which is guaranteed to be unique.

Reported-by: Rusty Russell <rusty@rustcorp.com.au>
Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
Cc: stable@kernel.org
---

Rusty's working on switching to allocating ubufs dynamically
but that's not 3.9 material.
This patch is against latest net master,
needed for 3.9-rc2 and older kernels.

 drivers/vhost/net.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
index 959b1cd..ec6fb3f 100644
--- a/drivers/vhost/net.c
+++ b/drivers/vhost/net.c
@@ -339,7 +339,8 @@ static void handle_tx(struct vhost_net *net)
 				msg.msg_controllen = 0;
 				ubufs = NULL;
 			} else {
-				struct ubuf_info *ubuf = &vq->ubuf_info[head];
+				struct ubuf_info *ubuf;
+				ubuf = vq->ubuf_info + vq->upend_idx;
 
 				vq->heads[vq->upend_idx].len =
 					VHOST_DMA_IN_PROGRESS;
-- 
MST
