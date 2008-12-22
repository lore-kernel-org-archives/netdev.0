From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH][RFC 23/23]: Support for zero-copy TCP transmit of user space data
Date: Mon, 22 Dec 2008 11:13:22 +1030
Message-ID: <200812221113.24044.rusty@rustcorp.com.au>
References: <494C0255.8010208@goop.org> <20081220103209.GA23632@ioremap.net> <494D49E6.9000703@goop.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Evgeniy Polyakov <zbr@ioremap.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Vladislav Bolkhovitin <vst@vlnb.net>,
	linux-scsi@vger.kernel.org,
	James Bottomley <James.Bottomley@hansenpartnership.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>,
	Mike Christie <michaelc@cs.wisc.edu>,
	Jeff Garzik <jeff@garzik.org>,
	Boaz Harrosh <bharrosh@panasas.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	linux-kernel@vger.kernel.org, scst-devel@lists.sourceforge.net,
	Bart Van Assche <bart.vanassche@gmail.com>,
	"Nicholas A. Bellinger" <nab@linux-iscsi.org>,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Jeremy Fitzhardinge <jeremy@goop.org>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <494D49E6.9000703@goop.org>
Content-Disposition: inline
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sunday 21 December 2008 06:09:18 Jeremy Fitzhardinge wrote:
> Evgeniy Polyakov wrote:
> > Things should work fine, since pskb_expand_head() copies whole shared
> > info structure (and thus will copy destructor), get all pages and then
> > copy all pointers into the new skb, and then release old skb's data.
> >
> > So destructor for the pages should not rely on which skb it is called on
> > and check if pages are about to be really freed (i.e. check theirs
> > reference counter).
> >   
> 
> OK.
> 
> > __pskb_pull_tail() is tricky, it just puts some pages it does not want
> > to be present in the skb, but it could be possible to add there
> > destructor callback from the original skb with partial flag (or just
> > having destructor with two parameters: skb and page, and if page is not
> > NULL, then actually only given page is freed, otherwise the whole skb).
> >   
> 
> Yes, that doesn't sound too bad.

That would be one approach.  Actually, my patch solved this by keeping a
parent ref in various cases if the parent had a destructor: we only destroy
the parent when all the clones are gone.

Here's the patch for reference:

net: add destructor for skb data.

If we want to notify something when an skb is truly finished (such as
for tun vringfd support), we need a destructor on the data.

This turns out to be slightly non-trivial as fragments from one skb
get copied to another skb: if the first skb has a destructor (or its
parent does) we need to keep a reference to it and destroy it only
when (all the) children are destroyed.  We add an 'orig' pointer to
the skb_shared_info to do this.

But there's currently no way to get from the shinfo to the head (to
kfree it), so we add a 'len' field.  A better alternative to this
might be to move the skb_shared_info to before the head of the skb data.

Note that the destructor is responsible for calling kfree: for the tun
device, this is critical since the destructor can be called from any
context and it has to do a copy_to_user, so it queues the skb.

Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
---
 include/linux/skbuff.h |    9 ++++++
 net/core/skbuff.c      |   66 ++++++++++++++++++++++++++++++++++++++++---------
 2 files changed, 64 insertions(+), 11 deletions(-)

diff -r 3948a0050f81 include/linux/skbuff.h
--- a/include/linux/skbuff.h	Tue May 06 21:18:01 2008 +1000
+++ b/include/linux/skbuff.h	Thu May 08 13:12:47 2008 +1000
@@ -146,8 +146,12 @@ struct skb_shared_info {
 	unsigned short	gso_segs;
 	unsigned short  gso_type;
 	__be32          ip6_frag_id;
+	unsigned int	len; /* Subtract from this shinfo to find skb->head */
 	struct sk_buff	*frag_list;
 	skb_frag_t	frags[MAX_SKB_FRAGS];
+	struct skb_shared_info *orig;
+	/* This is responsible for kfree() of header. */
+	void		(*destructor)(struct skb_shared_info *);
 };
 
 /* We divide dataref into two halves.  The higher 16 bits hold references
@@ -827,6 +831,11 @@ static inline void skb_fill_page_desc(st
 #define SKB_PAGE_ASSERT(skb) 	BUG_ON(skb_shinfo(skb)->nr_frags)
 #define SKB_FRAG_ASSERT(skb) 	BUG_ON(skb_shinfo(skb)->frag_list)
 #define SKB_LINEAR_ASSERT(skb)  BUG_ON(skb_is_nonlinear(skb))
+
+static inline unsigned char *skb_shinfo_to_head(struct skb_shared_info *shinfo)
+{
+	return (unsigned char *)shinfo - shinfo->len;
+}
 
 #ifdef NET_SKBUFF_DATA_USES_OFFSET
 static inline unsigned char *skb_tail_pointer(const struct sk_buff *skb)
diff -r 3948a0050f81 net/core/skbuff.c
--- a/net/core/skbuff.c	Tue May 06 21:18:01 2008 +1000
+++ b/net/core/skbuff.c	Thu May 08 13:12:47 2008 +1000
@@ -218,6 +218,9 @@ struct sk_buff *__alloc_skb(unsigned int
 	shinfo->gso_type = 0;
 	shinfo->ip6_frag_id = 0;
 	shinfo->frag_list = NULL;
+	shinfo->destructor = NULL;
+	shinfo->orig = NULL;
+	shinfo->len = skb_end_pointer(skb) - skb->head;
 
 	if (fclone) {
 		struct sk_buff *child = skb + 1;
@@ -311,21 +314,53 @@ static void skb_clone_fraglist(struct sk
 		skb_get(list);
 }
 
+static void shinfo_put(struct skb_shared_info *shinfo, bool nohdr, bool clone)
+{
+	struct skb_shared_info *orig;
+
+	do {
+		if (clone &&
+		    atomic_sub_return(nohdr ? (1 << SKB_DATAREF_SHIFT) + 1 : 1,
+				      &shinfo->dataref)) {
+			return;
+		}
+
+		if (shinfo->nr_frags) {
+			int i;
+			for (i = 0; i < shinfo->nr_frags; i++)
+				put_page(shinfo->frags[i].page);
+		}
+
+		if (shinfo->frag_list)
+			skb_drop_list(&shinfo->frag_list);
+
+		orig = shinfo->orig;
+		if (shinfo->destructor)
+			shinfo->destructor(shinfo);
+		else
+			kfree(skb_shinfo_to_head(shinfo));
+
+		/* We hold a payload reference to our parent. */
+		nohdr = true;
+		clone = true;
+	} while ((shinfo = orig) != NULL);
+}
+
 static void skb_release_data(struct sk_buff *skb)
 {
-	if (!skb->cloned ||
-	    !atomic_sub_return(skb->nohdr ? (1 << SKB_DATAREF_SHIFT) + 1 : 1,
-			       &skb_shinfo(skb)->dataref)) {
-		if (skb_shinfo(skb)->nr_frags) {
-			int i;
-			for (i = 0; i < skb_shinfo(skb)->nr_frags; i++)
-				put_page(skb_shinfo(skb)->frags[i].page);
-		}
+	shinfo_put(skb_shinfo(skb), skb->nohdr, skb->cloned);
+}
 
-		if (skb_shinfo(skb)->frag_list)
-			skb_drop_fraglist(skb);
+/* Now hold reference to older data, if has a destructor (recursively). */
+static void skb_ref_data_parent(struct sk_buff *parent,
+				struct skb_shared_info *shinfo)
+{
+	struct skb_shared_info *pshinfo = skb_shinfo(parent);
 
-		kfree(skb->head);
+	if (pshinfo->destructor || pshinfo->orig) {
+		shinfo->orig = pshinfo;
+		atomic_add((1 << SKB_DATAREF_SHIFT) + 1, &pshinfo->dataref);
+		parent->cloned = 1;
 	}
 }
 
@@ -656,6 +691,7 @@ struct sk_buff *pskb_copy(struct sk_buff
 			get_page(skb_shinfo(n)->frags[i].page);
 		}
 		skb_shinfo(n)->nr_frags = i;
+		skb_ref_data_parent(skb, skb_shinfo(n));
 	}
 
 	if (skb_shinfo(skb)->frag_list) {
@@ -721,6 +757,8 @@ int pskb_expand_head(struct sk_buff *skb
 	if (skb_shinfo(skb)->frag_list)
 		skb_clone_fraglist(skb);
 
+	skb_ref_data_parent(skb, (void *)(data + size));
+
 	skb_release_data(skb);
 
 	off = (data + nhead) - skb->head;
@@ -743,6 +781,8 @@ int pskb_expand_head(struct sk_buff *skb
 	skb->hdr_len  = 0;
 	skb->nohdr    = 0;
 	atomic_set(&skb_shinfo(skb)->dataref, 1);
+	skb_shinfo(skb)->len = skb_end_pointer(skb) - skb->head;
+	skb_shinfo(skb)->destructor = NULL;
 	return 0;
 
 nodata:
@@ -1962,6 +2002,8 @@ void skb_split(struct sk_buff *skb, stru
 		skb_split_inside_header(skb, skb1, len, pos);
 	else		/* Second chunk has no header, nothing to copy. */
 		skb_split_no_header(skb, skb1, len, pos);
+
+	skb_ref_data_parent(skb, skb_shinfo(skb1));
 }
 
 /**
@@ -2334,6 +2376,8 @@ struct sk_buff *skb_segment(struct sk_bu
 		nskb->data_len = len - hsize;
 		nskb->len += nskb->data_len;
 		nskb->truesize += nskb->data_len;
+
+		skb_ref_data_parent(skb, skb_shinfo(nskb));
 	} while ((offset += len) < skb->len);
 
 	return segs;
