From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [PATCH net-next v4 1/6] bonding: simplify and use RCU protection
 for 3ad xmit path
Date: Mon, 9 Sep 2013 11:57:52 +0200
Message-ID: <20130909095752.GC2048@redhat.com>
References: <52298407.9040103@huawei.com>
 <20130907142041.GA20237@redhat.com>
 <522B3BF1.2020208@redhat.com>
 <20130907150350.GF26163@redhat.com>
 <522C13A3.9090206@gmail.com>
 <522D8DB5.1030302@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: Nikolay Aleksandrov <nikolay@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:9064 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751275Ab3IIJ7e (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Sep 2013 05:59:34 -0400
Content-Disposition: inline
In-Reply-To: <522D8DB5.1030302@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 09, 2013 at 04:58:29PM +0800, Ding Tianhong wrote:
>On 2013/9/8 14:05, Ding Tianhong wrote:
>
>Hi Veaceslav and Nik:
>
>please take a moment to reveiw the function just modify for bond_XXX_rcu,
>and give me some advice. thanks for the help again.:)
>
>+#define bond_first_slave_rcu(bond) \
>+   list_first_or_null_rcu(&(bond)->slave_list, struct slave, list);
>+#define bond_last_slave_rcu(bond) \
>+   ({struct list_head *__slave_list = &(bond)->slave_list; \
>+    struct list_head __rcu *__prev = \
>+    (*((struct list_head __rcu **)(&(__slave_list)->prev)));\
>+    likely(__slave_list != __prev) ? \
>+    container_of(__prev, struct slave, list) : NULL;})

Please take a look at Nikolay's reply to my RCU email -
http://www.spinics.net/lists/netdev/msg249805.html . And mine also, to his
email. In short - RCU doesn't guarantee ->prev, so better take the approach
of eliminating bond_last/prev_slave completely.

>+
> #define bond_is_first_slave(bond, pos) ((pos)->list.prev == &(bond)->slave_list)
> #define bond_is_last_slave(bond, pos) ((pos)->list.next == &(bond)->slave_list)
>
>@@ -93,6 +117,29 @@
>    (bond_is_first_slave(bond, pos) ? bond_last_slave(bond) : \
>                      bond_to_slave((pos)->list.prev))
>
>+/* Since bond_first/last_slave_rcu can return NULL, these can return NULL too */
>+#define bond_next_slave_rcu(bond, pos) \
>+   ({struct list_head *__slave_list = &(bond)->slave_list; \
>+    struct list_head __rcu *__next = list_next_rcu(__slave_list); \
>+    struct list_head *__pos_list = &(pos)->list; \
>+    struct list_head __rcu *__pos_next = list_next_rcu(__pos_list); \
>+    likely(__pos_next != __slave_list) ? \
>+    container_of(__pos_next, struct slave, list) : \
>+    container_of(__next, struct slave, list); \
>+    })

Nice, but can be shortened - we know that pos won't go away.

>+
>+#define bond_prev_slave_rcu(bond, pos) \
>+   ({struct list_head *__slave_list = &(bond)->slave_list; \
>+    struct list_head __rcu *__prev = \
>+    (*((struct list_head __rcu **)(&(__slave_list)->prev)));\
>+    struct list_head *__pos_list = &(pos)->list; \
>+    struct list_head __rcu *__pos_prev = (__pos_list->prev != LIST_POISON2) ? \
>+    (*((struct list_head __rcu **)(&(__pos_list)->prev))) : NULL; \
>+    likely(__pos_prev != __slave_list) ? \
>+    ((__pos_prev) ? list_entry_rcu(__pos_prev, struct slave, list) : NULL;) : \
>+    (list_entry_rcu(__prev, struct slave, list)); \
>+    })

Same remark as above about prev.

>+
>
>
>-#define bond_for_each_slave_from(bond, pos, cnt, start) \
>-   for (cnt = 0, pos = start; pos && cnt < (bond)->slave_cnt; \
>-        cnt++, pos = bond_next_slave(bond, pos))
>-
>+#define bond_for_each_slave_from(bond, pos, start) \
>+   for (pos = start; pos; (pos = bond_next_slave(bond, pos)) != start ? \
>+       (pos) : (pos = NULL))
>+
>+#define bond_for_each_slave_from_rcu(bond, pos, start) \
>+   for ({struct list_head *__start = &(start)->list; \
>+        struct list_head *__slave_list = &(bond)->slave_list; \
>+        pos = list_entry_rcu(__start, struct slave, list);}; \
>+        pos; \
>+        {struct list_head __rcu *__next = list_next_rcu(pos->next); \
>+        __next != __slave_list ? \
>+        __next : __next = list_next_rcu(__next->next); \
>+        __next != __start ? \
>+        pos = list_entry_rcu(__next, struct slave, list) : \
>+        pos = NULL; \
>+        })

Jeez, I don't even want to review it. It's too complex and too hard to
maintain, even if it works. Can you please make something shorter/easier to
understand?

>+
>
>Best regards
>Ding
>
>
>>> --
>>> To unsubscribe from this list: send the line "unsubsc ribe netdev" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at http://vger.kernel.org/majordomo-info.html
>>>
>>
>>
>> .
>>
>
>
