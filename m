From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH net-next V2 1/2] net: introduce skb_coalesce_rx_frag()
Date: Thu, 31 Oct 2013 19:47:06 +0800
Message-ID: <1383220027-12278-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kmindg@gmail.com
To: davem@davemloft.net, edumazet@google.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, rusty@rustcorp.com.au, mst@redhat.com,
	mwdalton@google.com, virtualization@lists.linux-foundation.org
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

Sometimes we need to coalesce the rx frags to avoid frag list. One example is
virtio-net driver which tries to use small frags for both MTU sized packet and
GSO packet. So this patch introduce skb_coalesce_rx_frag() to do this.

Cc: Rusty Russell <rusty@rustcorp.com.au>
Cc: Michael S. Tsirkin <mst@redhat.com>
Cc: Michael Dalton <mwdalton@google.com>
Cc: Eric Dumazet <edumazet@google.com>
Acked-by: Michael S. Tsirkin <mst@redhat.com>
Signed-off-by: Jason Wang <jasowang@redhat.com>
---
Changes from V1:
- remove the useless off parameter.
---
 include/linux/skbuff.h |  3 +++
 net/core/skbuff.c      | 13 +++++++++++++
 2 files changed, 16 insertions(+)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 2c15497..fffaeaf 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1372,6 +1372,9 @@ static inline void skb_fill_page_desc(struct sk_buff *skb, int i,
 void skb_add_rx_frag(struct sk_buff *skb, int i, struct page *page, int off,
 		     int size, unsigned int truesize);
 
+void skb_coalesce_rx_frag(struct sk_buff *skb, int i, int size,
+			  unsigned int truesize);
+
 #define SKB_PAGE_ASSERT(skb) 	BUG_ON(skb_shinfo(skb)->nr_frags)
 #define SKB_FRAG_ASSERT(skb) 	BUG_ON(skb_has_frag_list(skb))
 #define SKB_LINEAR_ASSERT(skb)  BUG_ON(skb_is_nonlinear(skb))
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 0ab32fa..87670e1 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -476,6 +476,19 @@ void skb_add_rx_frag(struct sk_buff *skb, int i, struct page *page, int off,
 }
 EXPORT_SYMBOL(skb_add_rx_frag);
 
+void skb_coalesce_rx_frag(struct sk_buff *skb, int i, int size,
+			  unsigned int truesize)
+{
+	skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
+
+	skb_frag_size_add(frag, size);
+	skb->len += size;
+	skb->data_len += size;
+	skb->truesize += truesize;
+	skb_frag_unref(skb, i);
+}
+EXPORT_SYMBOL(skb_coalesce_rx_frag);
+
 static void skb_drop_list(struct sk_buff **listp)
 {
 	kfree_skb_list(*listp);
-- 
1.8.1.2
