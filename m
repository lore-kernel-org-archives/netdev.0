From: Michael Dalton <mwdalton@google.com>
Subject: [PATCH net-next v3 1/5] net: allow > 0 order atomic page alloc in
	skb_page_frag_refill
Date: Thu, 16 Jan 2014 01:38:42 -0800
Message-ID: <1389865126-26225-1-git-send-email-mwdalton@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Michael Dalton <mwdalton@google.com>, "Michael S. Tsirkin" <mst@redhat.com>,
	netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
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

skb_page_frag_refill currently permits only order-0 page allocs
unless GFP_WAIT is used. Change skb_page_frag_refill to attempt
higher-order page allocations whether or not GFP_WAIT is used. If
memory cannot be allocated, the allocator will fall back to
successively smaller page allocs (down to order-0 page allocs).

This change brings skb_page_frag_refill in line with the existing
page allocation strategy employed by netdev_alloc_frag, which attempts
higher-order page allocations whether or not GFP_WAIT is set, falling
back to successively lower-order page allocations on failure. Part
of migration of virtio-net to per-receive queue page frag allocators.

Acked-by: Michael S. Tsirkin <mst@redhat.com>
Acked-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Michael Dalton <mwdalton@google.com>
---
 net/core/sock.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/net/core/sock.c b/net/core/sock.c
index 85ad6f0..b3f7ee3 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1836,9 +1836,7 @@ bool skb_page_frag_refill(unsigned int sz, struct page_frag *pfrag, gfp_t prio)
 		put_page(pfrag->page);
 	}
 
-	/* We restrict high order allocations to users that can afford to wait */
-	order = (prio & __GFP_WAIT) ? SKB_FRAG_PAGE_ORDER : 0;
-
+	order = SKB_FRAG_PAGE_ORDER;
 	do {
 		gfp_t gfp = prio;
 
-- 
1.8.5.2
