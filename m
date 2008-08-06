From: "Luis R. Rodriguez" <lrodriguez@atheros.com>
Subject: Re: [PATCH 2/4] list.h: add list_cut_position()
Date: Wed, 6 Aug 2008 11:45:20 -0700
Message-ID: <20080806184520.GK5605@tesla>
References: <1217890089-12100-1-git-send-email-lrodriguez@atheros.com>
	<20080804160011.ec964f1f.randy.dunlap@oracle.com>
	<20080804231320.GG6447@tesla>
	<ef1cd66f0808050152g1dd8b96cl2df820607d480f0f@mail.gmail.com>
	<20080806182724.GI5605@tesla>
	<23052053.1218047754579.JavaMail.oracle@acsmt304.oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "ath9k-devel@venema.h4ckr.net" <ath9k-devel@venema.h4ckr.net>,
	Jochen =?iso-8859-1?B?Vm/f?= <jochen.voss@googlemail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linville@tuxdriver.com" <linville@tuxdriver.com>,
	Luis Rodriguez <Luis.Rodriguez@Atheros.com>,
	"torvalds@linux-foundation.org" <torvalds@linux-foundation.org>
To: Randy Dunlap <randy.dunlap@oracle.com>
Return-path: <ath9k-devel-bounces@lists.ath9k.org>
Content-Disposition: inline
In-Reply-To: <23052053.1218047754579.JavaMail.oracle@acsmt304.oracle.com>
List-Unsubscribe: <https://lists.ath9k.org/mailman/listinfo/ath9k-devel>,
	<mailto:ath9k-devel-request@lists.ath9k.org?subject=unsubscribe>
List-Archive: <http://lists.ath9k.org/pipermail/ath9k-devel>
List-Post: <mailto:ath9k-devel@lists.ath9k.org>
List-Help: <mailto:ath9k-devel-request@lists.ath9k.org?subject=help>
List-Subscribe: <https://lists.ath9k.org/mailman/listinfo/ath9k-devel>,
	<mailto:ath9k-devel-request@lists.ath9k.org?subject=subscribe>
Sender: ath9k-devel-bounces@lists.ath9k.org
Errors-To: ath9k-devel-bounces@lists.ath9k.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 06, 2008 at 11:35:54AM -0700, Randy Dunlap wrote:
> > This adds list_cut_position() which lets you cut a list into
> > two lists given a pivot in the list.
> >
> > Signed-off-by: Luis R. Rodriguez <lrodriguez@atheros.com>
> >
> > diff --git a/include/linux/list.h b/include/linux/list.h
> > index 453916b..6c02a83 100644
> > --- a/include/linux/list.h
> > +++ b/include/linux/list.h
> > @@ -214,6 +214,46 @@ static inline int list_is_singular(const
> > struct list_head *head)
> >       return !list_empty(head) && (head->next == head->prev);
> >  }
> >
> > +static inline void __list_cut_position(struct list_head *list,
> > +             struct list_head *head, struct list_head *entry)
> > +{
> > +     struct list_head *new_first = entry->next;
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
> > + *
> > + * This helper moves the initial part of @head, up to and
> > + * including @entry, from @head to @list. You should
> > + * pass on @entry an element you know is on @head. @list
> > + * should be an empty list or a list you do not care about
> > + * losing its data.
> > + *
> > + * @list: a new list to add all removed entries
> > + * @head: a list with entries
> > + * @entry: an entry within head, could be the head itself
> > + *   and if so we won't cut the list
> > + */
> 
> For kernel-doc notation, the parameters need to follow the function name+short description.
> After that, a longer description can be added.  I.e., please move the parameters up to
> above the longer description...

Bleh, sorry, we need to fix some more kdoc in mac80211 too then.

OK here's the new one.
--

This adds list_cut_position() which lets you cut a list into
two lists given a pivot in the list.

Signed-off-by: Luis R. Rodriguez <lrodriguez@atheros.com>

diff --git a/include/linux/list.h b/include/linux/list.h
index 453916b..3b0ac8c 100644
--- a/include/linux/list.h
+++ b/include/linux/list.h
@@ -214,6 +214,46 @@ static inline int list_is_singular(const struct list_head *head)
 	return !list_empty(head) && (head->next == head->prev);
 }
 
+static inline void __list_cut_position(struct list_head *list,
+		struct list_head *head, struct list_head *entry)
+{
+	struct list_head *new_first = entry->next;
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
+ *
+ * This helper moves the initial part of @head, up to and
+ * including @entry, from @head to @list. You should
+ * pass on @entry an element you know is on @head. @list
+ * should be an empty list or a list you do not care about
+ * losing its data.
+ *
+ */
+static inline void list_cut_position(struct list_head *list,
+		struct list_head *head, struct list_head *entry)
+{
+	if (list_empty(head))
+		return;
+	if (list_is_singular(head) &&
+		(head->next != entry && head != entry))
+		return;
+	if (entry == head)
+		INIT_LIST_HEAD(list);
+	else
+		__list_cut_position(list, head, entry);
+}
+
 static inline void __list_splice(const struct list_head *list,
 				 struct list_head *head)
 {
