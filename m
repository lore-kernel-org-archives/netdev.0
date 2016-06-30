From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH net-next V3 1/6] ptr_ring: support zero length ring
Date: Thu, 30 Jun 2016 11:52:54 +0800
Message-ID: <1467258779-3539-2-git-send-email-jasowang@redhat.com>
References: <1467258779-3539-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, eric.dumazet@gmail.com, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: mst@redhat.com, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1467258779-3539-1-git-send-email-jasowang@redhat.com>
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

Sometimes, we need zero length ring. But current code will crash since
we don't do any check before accessing the ring. This patch fixes this.

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 include/linux/ptr_ring.h | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/include/linux/ptr_ring.h b/include/linux/ptr_ring.h
index 562a65e..d78b8b8 100644
--- a/include/linux/ptr_ring.h
+++ b/include/linux/ptr_ring.h
@@ -102,7 +102,7 @@ static inline bool ptr_ring_full_bh(struct ptr_ring *r)
  */
 static inline int __ptr_ring_produce(struct ptr_ring *r, void *ptr)
 {
-	if (r->queue[r->producer])
+	if (unlikely(!r->size) || r->queue[r->producer])
 		return -ENOSPC;
 
 	r->queue[r->producer++] = ptr;
@@ -164,7 +164,9 @@ static inline int ptr_ring_produce_bh(struct ptr_ring *r, void *ptr)
  */
 static inline void *__ptr_ring_peek(struct ptr_ring *r)
 {
-	return r->queue[r->consumer];
+	if (likely(r->size))
+		return r->queue[r->consumer];
+	return NULL;
 }
 
 /* Note: callers invoking this in a loop must use a compiler barrier,
-- 
2.7.4
