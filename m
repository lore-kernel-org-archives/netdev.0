From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [PATCH net-next v4 1/6] bonding: simplify and use RCU protection
 for 3ad xmit path
Date: Sat, 7 Sep 2013 16:20:41 +0200
Message-ID: <20130907142041.GA20237@redhat.com>
References: <52298407.9040103@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	Netdev <netdev@vger.kernel.org>
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:28237 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751140Ab3IGOW1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 7 Sep 2013 10:22:27 -0400
Content-Disposition: inline
In-Reply-To: <52298407.9040103@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 06, 2013 at 03:28:07PM +0800, Ding Tianhong wrote:
...snip...
>+/**
>+ * IMPORTANT: bond_first/last_slave_rcu can return NULL in case of an empty list
>+ * Caller must hold rcu_read_lock
>+ */
>+#define bond_first_slave_rcu(bond) \
>+	(bond_is_empty_rcu(bond) ? NULL : \
>+					bond_to_slave_rcu((bond)->slave_list.next))
>+#define bond_last_slave_rcu(bond) \
>+	(bond_is_empty_rcu(bond) ? NULL : \
>+					bond_to_slave_rcu((bond)->slave_list.prev))
>+

Hi Ding,

I didn't have time to actually go into detail about this last week, and, as
Eric correctly said, RCU is hard even for experienced kernel developers, so
it's really not the easiest part to understand. I, for one, can't say that
I understand it completely, though I know the overall, basic usage.

That being said, I really advise you to go through, first of all,
Documentation/RCU. There are also tons of online materials already written
on this topic - and every one takes its own approach in explaining it.

I'll now try to explain what is wrong with the approach of verifying for
list emptyness while holding only RCU read lock.

First of all, you've replied to one of my emails that, quoting - "the
slave_list will not changed in the rcu_read_lock". This is completely wrong
- rcu_read_lock() is not a lock, in its classical meaning. It allows the
    list, and everything else, to be *modified* (in the most basic case) while
holding it. I.e. if we, concurrently, run list_for_each_entry_rcu() and, on
another CPU, list_del_rcu() - then we might end up holding a reference to
the entry that *was* deleted from the list already. In other words - the
list can be freely modified while we're holding rcu_read_lock().

What rcu_read_lock() *does* guarantee is that the entry we've dereferenced
won't 'go away' - as in - get freed, get deinitialized (in most cases, and
in this one - with slave_list) or whatever else that can stop us from using
it. That's, again, a really broad assumption and there are *lots* of small
things to be taken care of, and, in some cases it's not even true -
however, the basic idea is this - once you rcu_dereference() something -
you can use it while holding rcu_read_lock().

So, again - while holding the rcu_read_lock(), working with a list - the
list itself can change easily, can become empty, or can become non-empty,
or whatever else - even while going through it via
list_for_each_entry_rcu(). However, if we dereference an entry there - we
can use it.

Now, about the list emptiness under rcu_read_lock(). Lets suppose the
following code (imagine that we have list_empty_rcu(), and we're holding
the rcu_read_lock()):

    1 if (!list_empty_rcu(&my_list)) {
    2         do_something(get_first_entry(&my_list));
    3 }

on the 1st line, we verify if the list is not empty - and, sometimes, it
will be true. For example, we'll have only one element there.

Now, after we execute the first line, on another CPU we *remove* the only
remaining element from the list, and thus my_list->next will point to
&my_list - classical empty list.

So, back to the first CPU, when we run our code, we execute
get_first_entry(&my_list) - which, usually, translates to
container_of(my_list->next, ...) - getting the container of the next
element of the list - which is our *head* - and not a valid entry. And we
will, eventually, bug here.

This is exactly what you're doing:

+#define bond_last_slave_rcu(bond) \
+	(bond_is_empty_rcu(bond) ? NULL : \
+					bond_to_slave_rcu((bond)->slave_list.prev))

You first verify if the list is empty - which can be non-empty *in the time
of the verification* - and then get the bond_to_slave_rcu() of the .prev -
when the list can already become empty and the prev will point to the list
head, and not to a valid slave.

That's exactly why we don't have the list_empty_rcu() - because it's
meaningless - cause exactly after it was run the list can become empty or
non-empty. It guarantees us nothing. The only, maybe, slightly useful usage
of it could be some kind of optimization:

   1 rcu_read_lock();
   2 
   3 if (unlikely(list_empty(&bond->slave_list))) {
   4         rcu_read_unlock();
   5         return -ENODEV;
   6 }
   7 
   8 heavy_preparation1(bond);
   9 heavy_preparation2(bond);
  10 ...
  11 
  12 bond_for_each_slave(bond, slave)
  13         do_something_with_a_slave(slave);
  14 
  15 rcu_read_unlock();

Here, as you can see, we must make some heavy (time/memory-consuming)
preparations to the bond *if it has slaves* before working *with each
slave*, and if he doesn't - we can just omit those preparations (if we
can...). But still it's a bit useless, and usually we anyway need proper
RTNL or bond->lock locking before doing something like that.

Back to the real world - to implement the bond_first/last_slave_rcu(), we
*must not* rely on list emptiness before taking the reference to the
first/last element of the list. To make this happen, we *first* take the
reference to list.next/list.prev, and only *after* it we verify if what
we've dereferenced is an actual slave or the list head (i.e. the list was
empty). If it's the list head - then we assume that the list was empty and
return NULL, otherwise - if it's a normal slave - we return the
container_of(what we've dereferenced).

Here's the function that gets the first element in the list:

268 #define list_first_or_null_rcu(ptr, type, member) \
269         ({struct list_head *__ptr = (ptr); \
270           struct list_head __rcu *__next = list_next_rcu(__ptr); \
271           likely(__ptr != __next) ? container_of(__next, type, member) : NULL; \
272         })

As you can see, we first make a copy of the list_head pointer, which we
were given - cause in the meanwhile *it can also, possibly, change*.

269         ({struct list_head *__ptr = (ptr); \

Then we dereference the pointer's copy.next, and also save it - cause it
can *also* change - become (non)empty, for example.

270           struct list_head __rcu *__next = list_next_rcu(__ptr); \

And here comes the rcu magic, actually. We know that the ptr can change,
the ptr.next can also change, however we also know that if ptr.next, when
we've dereferenced it, while holding the rcu_read_lock(), was a normal list
element - then we're sure that this element *will not go away*. Thus,
everything what remained for us is just to verify - is our next pointer the
list head or not? I.e. do we actually have an element in __next, or was the
list empty at that time and we can return NULL? And, of course, if the list
was not empty - we have a valid __next, and we can return its container:

271           likely(__ptr != __next) ? container_of(__next, type, member) : NULL; \

(Also, mind the "likely(__ptr != __next)" - usually, and bonding is a very
good example, we always have at least one element in the list.)

This way, I'd recommend you to do bond_last_slave_rcu() the same way as
here - you, though, might omit saving the slave_list pointer, it's not
needed in case of bonding AFAIK. Something like that (I'm writing it in my
mail editor - so it's only for the reference):

#define bond_last_slave_rcu(bond) \
	({struct list_head *__slave_ptr = list_next_rcu(&bond->slave_list); \
	  likely(__slave_ptr != &bond->slave_list) ? \
		bond_to_slave_rcu(__slave_ptr) : NULL;})


Or, even better (from my POV), add a generic macro to rculist.h (again,
didn't even compile it) - it can be used later on:

diff --git a/include/linux/rculist.h b/include/linux/rculist.h
index f4b1001..37b49d1 100644
--- a/include/linux/rculist.h
+++ b/include/linux/rculist.h
@@ -23,6 +23,7 @@
   * way, we must not access it directly
   */
  #define list_next_rcu(list)	(*((struct list_head __rcu **)(&(list)->next)))
+#define list_prev_rcu(list)	(*((struct list_head __rcu **)(&(list)->prev)))
  
  /*
   * Insert a new entry between two known consecutive entries.
@@ -271,6 +272,12 @@ static inline void list_splice_init_rcu(struct list_head *list,
  	  likely(__ptr != __next) ? container_of(__next, type, member) : NULL; \
  	})
  
+#define list_last_or_null_rcu(ptr, type, member) \
+	({struct list_head *__ptr = (ptr); \
+	  struct list_head __rcu *__last = list_prev_rcu(__ptr); \
+	  likely(__ptr != __last) ? container_of(__prev, type, member) : NULL; \
+	})
+
  /**
   * list_for_each_entry_rcu	-	iterate over rcu list of given type
   * @pos:	the type * to use as a loop cursor.
------- END OF PATCH ------

Anyway, it's up to you.

Hope that helps.
