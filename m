From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH v2] virtio_net: lower limit on buffer size
Date: Fri, 2 Jun 2017 17:54:33 +0300
Message-ID: <1496415192-17031-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "J. Bruce Fields" <bfields@fieldses.org>, netdev@vger.kernel.org,
	Mikulas Patocka <mpatocka@redhat.com>,
	virtualization@lists.linux-foundation.org
To: linux-kernel@vger.kernel.org, David Miller <davem@davemloft.net>
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

commit d85b758f72b0 ("virtio_net: fix support for small rings")
was supposed to increase the buffer size for small rings but had an
unintentional side effect of decreasing it for large rings. This seems
to break some setups - it's not yet clear why, but increasing buffer
size back to what it was before helps.

Fixes: d85b758f72b0 ("virtio_net: fix support for small rings")
Reported-by: Mikulas Patocka <mpatocka@redhat.com>
Reported-by: "J. Bruce Fields" <bfields@fieldses.org>
Tested-by: Mikulas Patocka <mpatocka@redhat.com>
Tested-by: "J. Bruce Fields" <bfields@fieldses.org>
Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---

Patch tested, pls merge.

changes from v2:
	commit log tweaks to address comments by Sergei Shtylyov

 drivers/net/virtio_net.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 87b5c20..60abb5d 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -842,7 +842,7 @@ static unsigned int get_mergeable_buf_len(struct receive_queue *rq,
 	unsigned int len;
 
 	len = hdr_len + clamp_t(unsigned int, ewma_pkt_len_read(avg_pkt_len),
-				rq->min_buf_len - hdr_len, PAGE_SIZE - hdr_len);
+				rq->min_buf_len, PAGE_SIZE - hdr_len);
 	return ALIGN(len, L1_CACHE_BYTES);
 }
 
@@ -2039,7 +2039,8 @@ static unsigned int mergeable_min_buf_len(struct virtnet_info *vi, struct virtqu
 	unsigned int buf_len = hdr_len + ETH_HLEN + VLAN_HLEN + packet_len;
 	unsigned int min_buf_len = DIV_ROUND_UP(buf_len, rq_size);
 
-	return max(min_buf_len, hdr_len);
+	return max(max(min_buf_len, hdr_len) - hdr_len,
+		   (unsigned int)GOOD_PACKET_LEN);
 }
 
 static int virtnet_find_vqs(struct virtnet_info *vi)
-- 
MST
