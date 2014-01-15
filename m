From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH stable-only] virtio-net: fix build on m68k and sparc64
Date: Wed, 15 Jan 2014 10:26:08 +0200
Message-ID: <1389774152-1526-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	David Miller <davem@davemloft.net>, Guenter Roeck <linux@roeck-us.net>
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

As a result of backporting a bugfix, virtio_net started passing void *
to page_address, assuming that it will get silently converted to struct
page *. But this does not happen on architectures where page_address is
a macro, the result is build failure as the macro tries to dereference
void*.

Fix by reordering code slightly, so we always pass
struct page * to page_address.

Reported-by: Guenter Roeck <linux@roeck-us.net>
Tested-by: Guenter Roeck <linux@roeck-us.net>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: David Miller <davem@davemloft.net>
Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---

David, Greg asked that this be put in stable ASAP to avoid
next release being broken.
I still didn't Cc stable directly as I know you prefer to do this
yourself.
Sorry about creating this mess, could you help fast-path it there please?

Thanks!

 drivers/net/virtio_net.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index b8665588..c8d5ee1 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -330,9 +330,9 @@ static struct sk_buff *receive_mergeable(struct net_device *dev,
 					 void *buf,
 					 unsigned int len)
 {
-	struct skb_vnet_hdr *hdr = page_address(buf);
-	int num_buf = hdr->mhdr.num_buffers;
 	struct page *page = buf;
+	struct skb_vnet_hdr *hdr = page_address(page);
+	int num_buf = hdr->mhdr.num_buffers;
 	struct sk_buff *skb = page_to_skb(rq, page, len);
 	int i;
 
-- 
MST
