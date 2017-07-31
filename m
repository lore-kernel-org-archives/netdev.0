From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH net] virtio_net: fix truesize for mergeable buffers
Date: Mon, 31 Jul 2017 21:49:49 +0300
Message-ID: <1501526948-5285-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	Seth Forshee <seth.forshee@canonical.com>,
	David Miller <davem@davemloft.net>
To: linux-kernel@vger.kernel.org
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

Seth Forshee noticed a performance degradation with some workloads.
This turns out to be due to packet drops.  Euan Kemp noticed that this
is because we drop all packets where length exceeds the truesize, but
for some packets we add in extra memory without updating the truesize.
This in turn was kept around unchanged from ab7db91705e95 ("virtio-net:
auto-tune mergeable rx buffer size for improved performance").  That
commit had an internal reason not to account for the extra space: not
enough bits to do it.  No longer true so let's account for the allocated
length exactly.

Many thanks to Seth Forshee for the report and bisecting and Euan Kemp
for debugging the issue.

Fixes: 680557cf79f8 ("virtio_net: rework mergeable buffer handling")
Reported-by: Euan Kemp <euan.kemp@coreos.com>
Tested-by: Euan Kemp <euan.kemp@coreos.com>
Reported-by: Seth Forshee <seth.forshee@canonical.com>
Tested-by: Seth Forshee <seth.forshee@canonical.com>
Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---

This patch is needed on stable as well.

 drivers/net/virtio_net.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index f41ab0e..98f17b0 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -889,21 +889,20 @@ static int add_recvbuf_mergeable(struct virtnet_info *vi,
 
 	buf = (char *)page_address(alloc_frag->page) + alloc_frag->offset;
 	buf += headroom; /* advance address leaving hole at front of pkt */
-	ctx = (void *)(unsigned long)len;
 	get_page(alloc_frag->page);
 	alloc_frag->offset += len + headroom;
 	hole = alloc_frag->size - alloc_frag->offset;
 	if (hole < len + headroom) {
 		/* To avoid internal fragmentation, if there is very likely not
 		 * enough space for another buffer, add the remaining space to
-		 * the current buffer. This extra space is not included in
-		 * the truesize stored in ctx.
+		 * the current buffer.
 		 */
 		len += hole;
 		alloc_frag->offset += hole;
 	}
 
 	sg_init_one(rq->sg, buf, len);
+	ctx = (void *)(unsigned long)len;
 	err = virtqueue_add_inbuf_ctx(rq->vq, rq->sg, 1, buf, ctx, gfp);
 	if (err < 0)
 		put_page(virt_to_head_page(buf));
-- 
MST
