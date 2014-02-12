From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH net] vhost_net: do not report a used len larger than receive
	buffer size
Date: Wed, 12 Feb 2014 13:57:46 +0800
Message-ID: <1392184666-17616-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: mst@redhat.com, kvm@vger.kernel.org, virtio-dev@lists.oasis-open.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
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

Currently, even if the packet were truncated by lower socket, we still
report the packet size as the used len which may confuse guest
driver. Fixes this by returning the size of guest receive buffer instead.

Fixes 3a4d5c94e959359ece6d6b55045c3f046677f55c
(vhost_net: a kernel-level virtio server)

Cc: Michael S. Tsirkin <mst@redhat.com>
Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/vhost/net.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
index 9a68409..06268a0 100644
--- a/drivers/vhost/net.c
+++ b/drivers/vhost/net.c
@@ -525,7 +525,8 @@ static int get_rx_bufs(struct vhost_virtqueue *vq,
 		++headcount;
 		seg += in;
 	}
-	heads[headcount - 1].len += datalen;
+	if (likely(datalen < 0))
+		heads[headcount - 1].len += datalen;
 	*iovcount = seg;
 	if (unlikely(log))
 		*log_num = nlogs;
-- 
1.8.3.2
