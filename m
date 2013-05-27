From: Roman Gushchin <klamm@yandex-team.ru>
Subject: Re: [PATCH v2] rcu: fix a race in hlist_nulls_for_each_entry_rcu
 macro
Date: Mon, 27 May 2013 21:55:29 +0400
Message-ID: <51A39E11.5020405@yandex-team.ru>
References: <519B8908.9080007@yandex-team.ru> <1369150693.3301.233.camel@edumazet-glaptop> <519BB90B.6080706@yandex-team.ru> <1369188080.3301.268.camel@edumazet-glaptop> <1369201765.3301.299.camel@edumazet-glaptop> <519CB2D8.103@yandex-team.ru> <1369225837.3301.324.camel@edumazet-glaptop> <519CC2FB.2010006@yandex-team.ru> <20130522174532.GC3431@linux.vnet.ibm.com> <519D19DA.50400@yandex-team.ru> <20130525113715.GA3795@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Dipankar Sarma <dipankar@in.ibm.com>, zhmurov@yandex-team.ru,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: paulmck@linux.vnet.ibm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130525113715.GA3795@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi, Paul!

> On 25.05.2013 15:37, Paul E. McKenney wrote:
>> Again, I believe that your retry logic needs to extend back into the
>> calling function for your some_func() example above.

And what do you think about the following approach (diff below)?

It seems to me, it's enough clear (especially with good accompanying comments)
and produces a good binary code (without significant overhead).
Also, we will remove a hidden reef in using rcu-protected (h)list traverses with restarts.

diff --git a/include/linux/rculist.h b/include/linux/rculist.h
index 6f95e24..8d8b1eb 100644
--- a/include/linux/rculist.h
+++ b/include/linux/rculist.h
@@ -269,7 +269,8 @@ static inline void list_splice_init_rcu(struct list_head *list,
   * as long as the traversal is guarded by rcu_read_lock().
   */
  #define list_for_each_entry_rcu(pos, head, member) \
-       for (pos = list_entry_rcu((head)->next, typeof(*pos), member); \
+       for (ACCESS_ONCE(*(head)), \
+               pos = list_entry_rcu((head)->next, typeof(*pos), member); \
                 &pos->member != (head); \
                 pos = list_entry_rcu(pos->member.next, typeof(*pos), member))

@@ -459,7 +460,8 @@ static inline void hlist_add_after_rcu(struct hlist_node *prev,
   * as long as the traversal is guarded by rcu_read_lock().
   */
  #define hlist_for_each_entry_rcu(tpos, pos, head, member)              \
-       for (pos = rcu_dereference_raw(hlist_first_rcu(head));          \
+       for (ACCESS_ONCE(*(head)),                                      \
+               pos = rcu_dereference_raw(hlist_first_rcu(head));       \
                 pos &&                                                   \
                 ({ tpos = hlist_entry(pos, typeof(*tpos), member); 1; }); \
                 pos = rcu_dereference_raw(hlist_next_rcu(pos)))
@@ -476,7 +478,7 @@ static inline void hlist_add_after_rcu(struct hlist_node *prev,
   * as long as the traversal is guarded by rcu_read_lock().
   */
  #define hlist_for_each_entry_rcu_bh(tpos, pos, head, member)            \
-       for (pos = rcu_dereference_bh((head)->first);                    \
+       for (ACCESS_ONCE(*(head)), pos = rcu_dereference_bh((head)->first); \
                 pos &&                                                   \
                 ({ tpos = hlist_entry(pos, typeof(*tpos), member); 1; }); \
                 pos = rcu_dereference_bh(pos->next))
diff --git a/include/linux/rculist_nulls.h b/include/linux/rculist_nulls.h
index 2ae1371..4af5ee5 100644
--- a/include/linux/rculist_nulls.h
+++ b/include/linux/rculist_nulls.h
@@ -107,7 +107,8 @@ static inline void hlist_nulls_add_head_rcu(struct hlist_nulls_node *n,
   *
   */
  #define hlist_nulls_for_each_entry_rcu(tpos, pos, head, member)                        \
-       for (pos = rcu_dereference_raw(hlist_nulls_first_rcu(head));            \
+       for (ACCESS_ONCE(*(head)),                                              \
+               pos = rcu_dereference_raw(hlist_nulls_first_rcu(head));         \
                 (!is_a_nulls(pos)) &&                                           \
                 ({ tpos = hlist_nulls_entry(pos, typeof(*tpos), member); 1; }); \
                 pos = rcu_dereference_raw(hlist_nulls_next_rcu(pos)))

---

Thanks!

Regards,
Roman
