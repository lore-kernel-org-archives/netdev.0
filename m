From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH for-3.19] vhost/net: fix up num_buffers endian-ness
Date: Tue, 3 Feb 2015 11:07:06 +0200
Message-ID: <1422896842-19186-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, netdev@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	viro@ZenIV.linux.org.uk, David Miller <davem@davemloft.net>
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

In virtio 1.0 mode, when mergeable buffers are enabled on a big-endian
host, num_buffers wasn't byte-swapped correctly, so large incoming
packets got corrupted.

To fix, fill it in within hdr - this also makes sure it gets
the correct type.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---

It seems important to get this into 3.19, otherwise
VIRTIO_1 feature bit is unreliable.

Dave, do you plan another pull request for 3.19?
If yes pls merge this, if not pls let me know and I'll try to
send it to Linus directly.


 drivers/vhost/net.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
index d415d69..9484d56 100644
--- a/drivers/vhost/net.c
+++ b/drivers/vhost/net.c
@@ -650,8 +650,10 @@ static void handle_rx(struct vhost_net *net)
 			break;
 		}
 		/* TODO: Should check and handle checksum. */
+
+		hdr.num_buffers = cpu_to_vhost16(vq, headcount);
 		if (likely(mergeable) &&
-		    memcpy_toiovecend(nvq->hdr, (unsigned char *)&headcount,
+		    memcpy_toiovecend(nvq->hdr, (void *)&hdr.num_buffers,
 				      offsetof(typeof(hdr), num_buffers),
 				      sizeof hdr.num_buffers)) {
 			vq_err(vq, "Failed num_buffers write");
-- 
MST
