From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH net 3/3] virtio-net: fix resources leaking when fail to
	allocate frag skb
Date: Wed, 20 Nov 2013 17:07:27 +0800
Message-ID: <1384938447-3775-3-git-send-email-jasowang@redhat.com>
References: <1384938447-3775-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Michael Dalton <mwdalton@google.com>, Eric Dumazet <edumazet@google.com>
To: rusty@rustcorp.com.au, mst@redhat.com,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1384938447-3775-1-git-send-email-jasowang@redhat.com>
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

When we fail to allocate a frag skb, we need put the refcnt of the page and drop
the rest of the buffers. Otherwise the page was leaked and driver won't get a
correct head buffer after this failure.

This bug was introduced by commit 2613af0ed18a11d5c566a81f9a6510b73180660a
(virtio_net: migrate mergeable rx buffers to page frag allocators).

Cc: Rusty Russell <rusty@rustcorp.com.au>
Cc: Michael S. Tsirkin <mst@redhat.com>
Cc: Michael Dalton <mwdalton@google.com>
Cc: Eric Dumazet <edumazet@google.com>
Signed-off-by: Jason Wang <jasowang@redhat.com>
---
The patch was needed for 3.12 stable.
---
 drivers/net/virtio_net.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index de1d6ca..f6f1e20 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -339,9 +339,12 @@ static int receive_mergeable(struct receive_queue *rq, struct sk_buff *head_skb)
 				 head_skb->dev->name);
 			len = MERGE_BUFFER_LEN;
 		}
+		page = virt_to_head_page(buf);
 		if (unlikely(num_skb_frags == MAX_SKB_FRAGS)) {
 			struct sk_buff *nskb = alloc_skb(0, GFP_ATOMIC);
 			if (unlikely(!nskb)) {
+				put_page(page);
+				drop_mergeable_buffer(rq, num_buf);
 				head_skb->dev->stats.rx_dropped++;
 				return -ENOMEM;
 			}
@@ -358,7 +361,6 @@ static int receive_mergeable(struct receive_queue *rq, struct sk_buff *head_skb)
 			head_skb->len += len;
 			head_skb->truesize += MERGE_BUFFER_LEN;
 		}
-		page = virt_to_head_page(buf);
 		offset = buf - (char *)page_address(page);
 		if (skb_can_coalesce(curr_skb, num_skb_frags, page, offset)) {
 			put_page(page);
-- 
1.8.3.2
