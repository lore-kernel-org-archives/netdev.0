From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH net-next 2/8] skb: api to report errors for zero copy skbs
Date: Mon, 29 Oct 2012 17:49:41 +0200
Message-ID: <ee85ad5053a929c90e0347b6ba33778d96690e9b.1351524501.git.mst@redhat.com>
References: <cover.1351524501.git.mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	Ian Campbell <Ian.Campbell@citrix.com>, kvm@vger.kernel.org,
	"Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org,
	Eric Dumazet <edumazet@google.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <cover.1351524501.git.mst@redhat.com>
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

Orphaning frags for zero copy skbs needs to allocate data in atomic
context so is has a chance to fail. If it does we currently discard
the skb which is safe, but we don't report anything to the caller,
so it can not recover by e.g. disabling zero copy.

Add an API to free skb reporting such errors: this is used
by tun in case orphaning frags fails.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 include/linux/skbuff.h |  1 +
 net/core/skbuff.c      | 19 +++++++++++++++++++
 2 files changed, 20 insertions(+)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 8bac11b..0644432 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -568,6 +568,7 @@ static inline struct rtable *skb_rtable(const struct sk_buff *skb)
 }
 
 extern void kfree_skb(struct sk_buff *skb);
+extern void skb_tx_error(struct sk_buff *skb, int err);
 extern void consume_skb(struct sk_buff *skb);
 extern void	       __kfree_skb(struct sk_buff *skb);
 extern struct kmem_cache *skbuff_head_cache;
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index eb31f6e..ad99c64 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -635,6 +635,25 @@ void kfree_skb(struct sk_buff *skb)
 EXPORT_SYMBOL(kfree_skb);
 
 /**
+ *	kfree_skb_on_error - report an sk_buff xmit error
+ *	@skb: buffer that triggered an error
+ *
+ *	Report xmit error if a device callback is tracking this skb.
+ */
+void skb_tx_error(struct sk_buff *skb, int err)
+{
+	if (skb_shinfo(skb)->tx_flags & SKBTX_DEV_ZEROCOPY) {
+		struct ubuf_info *uarg;
+
+		uarg = skb_shinfo(skb)->destructor_arg;
+		if (uarg->callback)
+			uarg->callback(uarg, err);
+		skb_shinfo(skb)->tx_flags &= ~SKBTX_DEV_ZEROCOPY;
+	}
+}
+EXPORT_SYMBOL(skb_tx_error);
+
+/**
  *	consume_skb - free an skbuff
  *	@skb: buffer to free
  *
-- 
MST
