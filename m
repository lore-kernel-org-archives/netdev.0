From: Gregory Haskins <ghaskins@novell.com>
Subject: [RFC PATCH] net: add dataref destructor to sk_buff
Date: Fri, 02 Oct 2009 10:20:00 -0400
Message-ID: <20091002141407.30224.54207.stgit@dev.haskins.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, ghaskins@novell.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(Applies to davem/net-2.6.git:4fdb78d30)

Hi David, netdevs,

The following is an RFC for an attempt at addressing a zero-copy solution.

To be perfectly honest, I have no idea if this is the best solution, or if
there is truly a problem with skb->destructor that requires an alternate
mechanism.  What I do know is that this patch seems to work, and I would
like to see some kind of solution available upstream.  So I thought I would
send my hack out as at least a point of discussion.  FWIW: This has been
tested heavily in my rig and is technically suitable for inclusion after
review as is, if that is decided to be the optimal path forward here.

Thanks for your review and consideration,

Kind regards,
-Greg

----------------------------------------
From: Gregory Haskins <ghaskins@novell.com>
Subject: [RFC PATCH] net: add dataref destructor to sk_buff

What: The skb->destructor field is reportedly unreliable for ensuring
that all shinfo users have dropped their references.  Therefore, we add
a distinct ->release() method for the shinfo structure which is closely
tied to the underlying page resources we want to protect.

Why: We want to add zero-copy transmit support for AlacrityVM guests.
In order to support this, the host kernel must map guest pages directly
into a paged-skb and send it as normal.  put_page() alone is not
sufficient lifetime management since the pages are ultimately allocated
from within the guest.  Therefore, we need higher-level notification
when the skb is finally freed on the host so we can then inject a proper
"tx-complete" event into the guest context.

Signed-off-by: Gregory Haskins <ghaskins@novell.com>
---

 include/linux/skbuff.h |    2 ++
 net/core/skbuff.c      |    9 +++++++++
 2 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index df7b23a..02cdab6 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -207,6 +207,8 @@ struct skb_shared_info {
 	/* Intermediate layers must ensure that destructor_arg
 	 * remains valid until skb destructor */
 	void *		destructor_arg;
+	void *          priv;
+	void           (*release)(struct sk_buff *skb);
 };
 
 /* We divide dataref into two halves.  The higher 16 bits hold references
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 80a9616..a7e40a9 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -219,6 +219,8 @@ struct sk_buff *__alloc_skb(unsigned int size, gfp_t gfp_mask,
 	shinfo->tx_flags.flags = 0;
 	skb_frag_list_init(skb);
 	memset(&shinfo->hwtstamps, 0, sizeof(shinfo->hwtstamps));
+	shinfo->release = NULL;
+	shinfo->priv = NULL;
 
 	if (fclone) {
 		struct sk_buff *child = skb + 1;
@@ -350,6 +352,9 @@ static void skb_release_data(struct sk_buff *skb)
 		if (skb_has_frags(skb))
 			skb_drop_fraglist(skb);
 
+		if (skb_shinfo(skb)->release)
+			skb_shinfo(skb)->release(skb);
+
 		kfree(skb->head);
 	}
 }
@@ -514,6 +519,8 @@ int skb_recycle_check(struct sk_buff *skb, int skb_size)
 	shinfo->tx_flags.flags = 0;
 	skb_frag_list_init(skb);
 	memset(&shinfo->hwtstamps, 0, sizeof(shinfo->hwtstamps));
+	shinfo->release = NULL;
+	shinfo->priv = NULL;
 
 	memset(skb, 0, offsetof(struct sk_buff, tail));
 	skb->data = skb->head + NET_SKB_PAD;
@@ -856,6 +863,8 @@ int pskb_expand_head(struct sk_buff *skb, int nhead, int ntail,
 	skb->hdr_len  = 0;
 	skb->nohdr    = 0;
 	atomic_set(&skb_shinfo(skb)->dataref, 1);
+	skb_shinfo(skb)->release = NULL;
+	skb_shinfo(skb)->priv = NULL;
 	return 0;
 
 nodata:

