From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCHv3 1/6] skbuff: add an api to orphan frags
Date: Fri, 20 Jul 2012 22:23:07 +0300
Message-ID: <b39e1550258a76085f15ff99dae7f3e265598d8b.1342812067.git.mst@redhat.com>
References: <cover.1342812067.git.mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jason Wang <jasowang@redhat.com>, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	ebiederm@xmission.com, davem@davemloft.net
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <cover.1342812067.git.mst@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Many places do
       if ((skb_shinfo(skb)->tx_flags & SKBTX_DEV_ZEROCOPY))
		skb_copy_ubufs(skb, gfp_mask);
to copy and invoke frag destructors if necessary.
Add an inline helper for this.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 include/linux/skbuff.h | 16 ++++++++++++++++
 1 file changed, 16 insertions(+)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 642cb73..d205c4b 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1667,6 +1667,22 @@ static inline void skb_orphan(struct sk_buff *skb)
 }
 
 /**
+ *	skb_orphan_frags - orphan the frags contained in a buffer
+ *	@skb: buffer to orphan frags from
+ *	@gfp_mask: allocation mask for replacement pages
+ *
+ *	For each frag in the SKB which needs a destructor (i.e. has an
+ *	owner) create a copy of that frag and release the original
+ *	page by calling the destructor.
+ */
+static inline int skb_orphan_frags(struct sk_buff *skb, gfp_t gfp_mask)
+{
+	if (likely(!(skb_shinfo(skb)->tx_flags & SKBTX_DEV_ZEROCOPY)))
+		return 0;
+	return skb_copy_ubufs(skb, gfp_mask);
+}
+
+/**
  *	__skb_queue_purge - empty a list
  *	@list: list to empty
  *
-- 
MST
