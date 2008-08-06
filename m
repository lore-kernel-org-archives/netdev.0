From: "Luis R. Rodriguez" <lrodriguez@atheros.com>
Subject: Re: [PATCH 1/4] list.h: Add list_splice_tail() and
	list_splice_tail_init()
Date: Wed, 6 Aug 2008 15:21:26 -0700
Message-ID: <20080806222125.GD9519@tesla>
References: <1217890080-12073-1-git-send-email-lrodriguez@atheros.com> <1217926995.3589.116.camel@twins> <20080806202619.GN5605@tesla>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Peter Zijlstra <peterz@infradead.org>,
	"linville@tuxdriver.com" <linville@tuxdriver.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"torvalds@linux-foundation.org" <torvalds@linux-foundation.org>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"ath9k-devel@lists.ath9k.org" <ath9k-devel@lists.ath9k.org>
To: Luis Rodriguez <Luis.Rodriguez@Atheros.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.atheros.com ([12.36.123.2]:41352 "EHLO mail.atheros.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756418AbYHFWV2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Aug 2008 18:21:28 -0400
Content-Disposition: inline
In-Reply-To: <20080806202619.GN5605@tesla>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 06, 2008 at 01:26:19PM -0700, Luis Rodriguez wrote:
> On Tue, Aug 05, 2008 at 02:03:15AM -0700, Peter Zijlstra wrote:
> > On Mon, 2008-08-04 at 15:48 -0700, Luis R. Rodriguez wrote:
> > > If you are using linked lists for queues list_splice() will not do what
> > > you would expect even if you use the elements passed reversed. We need
> > > to handle these differently. We add list_splice_tail() and
> > > list_splice_tail_init()
> >
> > In the -rt tree we have this:
> >
> > ---
> >     rt: list_splice2
> >
> >     Introduce list_splice2{,_tail}() which will splice a sub-list denoted
> >     by two list items instead of the full list.
> >
> >     Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
> 
> I like your version of list_splice_tail() and list_splice_tail_init()
> more as you re-use __list_splice() and fix it for its use instad of
> adding a new __list_splice_tail(). You also caught some users of
> __list_splice() for tail purposes. Its a good thing both versions
> are functionally equivalent :) otherwise one of us was doing something
> wrong.
> 
> We just need to also clarify list_splice() is for stacks and not
> queues, I can add that. You patch however fails with checkpatch and
> forgot to add kdoc. I'll correct it.
> 
> Last, list_splice2() should go in a separate patch and could use just a
> little bit more documentation as exactly what it does. Also the last
> hunk doesn't apply as 2.6.27 doesn't have lib/lock_list.c yet. To get ath9k
> in 2.6.27 we need list_splice_tail() and list_splice_tail_init(),
> how's this for 2.6.27:

Sorry, I forgot to add my kdoc for list_splice_tail_init(), here it is
with it added:
--
list.h: Add list_splice_tail() and list_splice_tail_init()

If you are using linked lists for queues list_splice() will not do what
you would expect even if you use the elements passed reversed. We need
to handle these differently. We add list_splice_tail() and
list_splice_tail_init().

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Luis R. Rodriguez <lrodriguez@atheros.com>
---
 drivers/dma/ioat_dma.c    |    2 +-
 drivers/usb/host/ehci-q.c |    2 +-
 include/linux/list.h      |   47 ++++++++++++++++++++++++++++++++++++--------
 3 files changed, 40 insertions(+), 11 deletions(-)

diff --git a/drivers/dma/ioat_dma.c b/drivers/dma/ioat_dma.c
index a52156e..bc8c6e3 100644
--- a/drivers/dma/ioat_dma.c
+++ b/drivers/dma/ioat_dma.c
@@ -551,7 +551,7 @@ static dma_cookie_t ioat1_tx_submit(struct dma_async_tx_descriptor *tx)
 	/* write address into NextDescriptor field of last desc in chain */
 	to_ioat_desc(ioat_chan->used_desc.prev)->hw->next =
 							first->async_tx.phys;
-	__list_splice(&new_chain, ioat_chan->used_desc.prev);
+	list_splice_tail(&new_chain, &ioat_chan->used_desc);
 
 	ioat_chan->dmacount += desc_count;
 	ioat_chan->pending += desc_count;
diff --git a/drivers/usb/host/ehci-q.c b/drivers/usb/host/ehci-q.c
index 2622b65..3712b92 100644
--- a/drivers/usb/host/ehci-q.c
+++ b/drivers/usb/host/ehci-q.c
@@ -932,7 +932,7 @@ static struct ehci_qh *qh_append_tds (
 
 			list_del (&qtd->qtd_list);
 			list_add (&dummy->qtd_list, qtd_list);
-			__list_splice (qtd_list, qh->qtd_list.prev);
+			list_splice_tail(qtd_list, &qh->qtd_list);
 
 			ehci_qtd_init(ehci, qtd, qtd->qtd_dma);
 			qh->dummy = qtd;
diff --git a/include/linux/list.h b/include/linux/list.h
index 453916b..a886f27 100644
--- a/include/linux/list.h
+++ b/include/linux/list.h
@@ -215,21 +215,21 @@ static inline int list_is_singular(const struct list_head *head)
 }
 
 static inline void __list_splice(const struct list_head *list,
-				 struct list_head *head)
+				 struct list_head *prev,
+				 struct list_head *next)
 {
 	struct list_head *first = list->next;
 	struct list_head *last = list->prev;
-	struct list_head *at = head->next;
 
-	first->prev = head;
-	head->next = first;
+	first->prev = prev;
+	prev->next = first;
 
-	last->next = at;
-	at->prev = last;
+	last->next = next;
+	next->prev = last;
 }
 
 /**
- * list_splice - join two lists
+ * list_splice - join two lists, this is designed for stacks
  * @list: the new list to add.
  * @head: the place to add it in the first list.
  */
@@ -237,7 +237,19 @@ static inline void list_splice(const struct list_head *list,
 				struct list_head *head)
 {
 	if (!list_empty(list))
-		__list_splice(list, head);
+		__list_splice(list, head, head->next);
+}
+
+/**
+ * list_splice_tail - join two lists, each list being a queue
+ * @list: the new list to add.
+ * @head: the place to add it in the first list.
+ */
+static inline void list_splice_tail(struct list_head *list,
+				struct list_head *head)
+{
+	if (!list_empty(list))
+		__list_splice(list, head->prev, head);
 }
 
 /**
@@ -251,7 +263,24 @@ static inline void list_splice_init(struct list_head *list,
 				    struct list_head *head)
 {
 	if (!list_empty(list)) {
-		__list_splice(list, head);
+		__list_splice(list, head, head->next);
+		INIT_LIST_HEAD(list);
+	}
+}
+
+/**
+ * list_splice_tail_init - join two lists, each list being a queue, and
+ *     reinitialise the emptied list.
+ * @list: the new list to add.
+ * @head: the place to add it in the first list.
+ *
+ * The list at @list is reinitialised
+ */
+static inline void list_splice_tail_init(struct list_head *list,
+					 struct list_head *head)
+{
+	if (!list_empty(list)) {
+		__list_splice(list, head->prev, head);
 		INIT_LIST_HEAD(list);
 	}
 }
-- 
1.5.6.rc2.15.g457bb.dirty

