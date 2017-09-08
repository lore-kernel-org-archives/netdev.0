From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH 3/3] net: skb_queue_purge(): lock/unlock the list only
 once
Date: Fri, 8 Sep 2017 09:51:23 -0700
Message-ID: <20170908095123.098ee101@xeon-e3>
References: <45aab5effc0c424a992646a97cf2ec14-mfwitten@gmail.com>
        <60c8906b751d4915be456009c220516e-mfwitten@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Michael Witten <mfwitten@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <60c8906b751d4915be456009c220516e-mfwitten@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 08 Sep 2017 05:06:30 -0000
Michael Witten <mfwitten@gmail.com> wrote:

> Date: Thu, 7 Sep 2017 20:07:40 +0000
> With this commit, the list's lock is locked/unlocked only once
> for the duration of `skb_queue_purge()'.
> 
> Hitherto, the list's lock has been locked/unlocked every time
> an item is dequeued; this seems not only inefficient, but also
> incorrect, as the whole point of `skb_queue_purge()' is to clear
> the list, presumably without giving anything else a chance to
> manipulate the list in the interim.
> 
> Signed-off-by: Michael Witten <mfwitten@gmail.com>
> ---
>  net/core/skbuff.c | 6 +++++-
>  1 file changed, 5 insertions(+), 1 deletion(-)
> 
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index 68065d7d383f..66c0731a2a5f 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -2834,9 +2834,13 @@ EXPORT_SYMBOL(skb_dequeue_tail);
>   */
>  void skb_queue_purge(struct sk_buff_head *list)
>  {
> +	unsigned long flags;
>  	struct sk_buff *skb;
> -	while ((skb = skb_dequeue(list)) != NULL)
> +
> +	spin_lock_irqsave(&list->lock, flags);
> +	while ((skb = __skb_dequeue(list)) != NULL)
>  		kfree_skb(skb);
> +	spin_unlock_irqrestore(&list->lock, flags);
>  }
>  EXPORT_SYMBOL(skb_queue_purge);
>  

As Eric said, this won't work.

Instead why not introduce something list splice which moves next/prev
of list head to a local list on  the stack.

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 68065d7d383f..4988b6efdcc8 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -2824,6 +2824,44 @@ struct sk_buff *skb_dequeue_tail(struct sk_buff_head *list)
 }
 EXPORT_SYMBOL(skb_dequeue_tail);
 
+static void __skb_splice(const struct sk_buff_head *list,
+			 struct sk_buff *prev,
+			 struct sk_buff *next)
+{
+	struct sk_buff *first = list->next;
+	struct sk_buff *last = list->prev;
+
+	list->qlen = 0;
+
+	first->prev = prev;
+	prev->next = first;
+
+	list->next = next;
+	next->prev = last;
+}
+
+/**
+ *	skb_splice - join two lists, and initialize the emptied list
+ *	@list: the new list to add
+ *	@head: the pace to add it in the first list
+ *
+ *	Take the first list (@list) and merge it onto the
+ *	head of existing list (@head).
+ */
+static void skb_splice_init(const struct sk_buff_head *list,
+			    struct sk_buff_head *head)
+{
+	unsigned long flags;
+
+	spin_lock_irqsave(&list->lock, flags);
+	if (list->qlen > 0) {
+		head->qlen += list->qlen;
+		__skb_splice(list, head, head->next);
+		__skb_queue_head_init(list);
+	}
+	spin_unlock_irqrestore(&list->lock, flags);
+}
+
 /**
  *	skb_queue_purge - empty a list
  *	@list: list to empty
@@ -2835,7 +2873,12 @@ EXPORT_SYMBOL(skb_dequeue_tail);
 void skb_queue_purge(struct sk_buff_head *list)
 {
 	struct sk_buff *skb;
-	while ((skb = skb_dequeue(list)) != NULL)
+	struct skb_buff_head tmp;
+
+	__skb_queue_head_init(&tmp);
+	skb_splice_init(list, &tmp);
+
+	while ((skb = __skb_dequeue(list)) != NULL)
 		kfree_skb(skb);
 }
 EXPORT_SYMBOL(skb_queue_purge);
