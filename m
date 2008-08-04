From: "Luis R. Rodriguez" <lrodriguez-DlyHzToyqoxBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH 2/4] list.h: add list_cut_position()
Date: Mon, 4 Aug 2008 16:13:21 -0700
Message-ID: <20080804231320.GG6447@tesla>
References: <1217890089-12100-1-git-send-email-lrodriguez@atheros.com> <20080804160011.ec964f1f.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Luis Rodriguez <Luis.Rodriguez-R2DSYHpuZhhBDgjK7y7TUQ@public.gmane.org>,
	"linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org" <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	"linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"ath9k-devel-juf53994utBLZpfksSYvnA@public.gmane.org" <ath9k-devel-juf53994utBLZpfksSYvnA@public.gmane.org>
To: Randy Dunlap <randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20080804160011.ec964f1f.randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 04, 2008 at 04:00:11PM -0700, Randy Dunlap wrote:
> On Mon, 4 Aug 2008 15:48:09 -0700 Luis R. Rodriguez wrote:
> 
> > This adds list_cut_position() which lets you cut a list into
> > two lists given a pivot in the list.
> >
> > Signed-off-by: Luis R. Rodriguez <lrodriguez-DlyHzToyqoxBDgjK7y7TUQ@public.gmane.org>
> > ---
> >  include/linux/list.h |   32 ++++++++++++++++++++++++++++++++
> >  1 files changed, 32 insertions(+), 0 deletions(-)
> >
> > diff --git a/include/linux/list.h b/include/linux/list.h
> > index 594f67c..2999b0f 100644
> > --- a/include/linux/list.h
> > +++ b/include/linux/list.h
> > @@ -214,6 +214,38 @@ static inline int list_is_singular(const struct list_head *head)
> >       return !list_empty(head) && (head->next == head->prev);
> >  }
> >
> > +static inline void __list_cut_position(struct list_head *list,
> > +             struct list_head *head, struct list_head *entry)
> > +{
> > +     struct list_head *new_first =
> > +             (entry->next != head) ? entry->next : head;
> > +     list->next = head->next;
> > +     list->next->prev = list;
> > +     list->prev = entry;
> > +     entry->next = list;
> > +     head->next = new_first;
> > +     new_first->prev = head;
> > +}
> > +
> > +/**
> > + * list_cut_position - cut a list into two
> > + * @list: a new list to add all removed entries
> > + * @head: a list with entries
> > + * @entry: an entry within head, could be the head itself
> > + *   and if so we won't won't cut the list
> 
> drop one "won't"

Thanks.

---
 include/linux/list.h |   32 ++++++++++++++++++++++++++++++++
 1 files changed, 32 insertions(+), 0 deletions(-)

diff --git a/include/linux/list.h b/include/linux/list.h
index 594f67c..2999b0f 100644
--- a/include/linux/list.h
+++ b/include/linux/list.h
@@ -214,6 +214,38 @@ static inline int list_is_singular(const struct list_head *head)
 	return !list_empty(head) && (head->next == head->prev);
 }
 
+static inline void __list_cut_position(struct list_head *list,
+		struct list_head *head, struct list_head *entry)
+{
+	struct list_head *new_first =
+		(entry->next != head) ? entry->next : head;
+	list->next = head->next;
+	list->next->prev = list;
+	list->prev = entry;
+	entry->next = list;
+	head->next = new_first;
+	new_first->prev = head;
+}
+
+/**
+ * list_cut_position - cut a list into two
+ * @list: a new list to add all removed entries
+ * @head: a list with entries
+ * @entry: an entry within head, could be the head itself
+ *	and if so we won't cut the list
+ */
+static inline void list_cut_position(struct list_head *list,
+		struct list_head *head, struct list_head *entry)
+{
+	BUG_ON(list_empty(head));
+	if (list_is_singular(head))
+		BUG_ON(head->next != entry && head != entry);
+	if (entry == head)
+		INIT_LIST_HEAD(list);
+	else
+		__list_cut_position(list, head, entry);
+}
+
 static inline void __list_splice(const struct list_head *list,
 				 struct list_head *head)
 {
-- 
1.5.6.rc2.15.g457bb.dirty

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
