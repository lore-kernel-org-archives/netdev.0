From: Roman Gushchin <klamm@yandex-team.ru>
Subject: Re: [PATCH v2] rcu: fix a race in hlist_nulls_for_each_entry_rcu
 macro
Date: Wed, 22 May 2013 15:58:16 +0400
Message-ID: <519CB2D8.103@yandex-team.ru>
References: <519B38EC.90401@yandex-team.ru>  <20130521120906.GD3578@linux.vnet.ibm.com>  <1369143885.3301.221.camel@edumazet-glaptop>  <519B8908.9080007@yandex-team.ru>  <1369150693.3301.233.camel@edumazet-glaptop>  <519BB90B.6080706@yandex-team.ru>  <1369188080.3301.268.camel@edumazet-glaptop> <1369201765.3301.299.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: paulmck@linux.vnet.ibm.com, Dipankar Sarma <dipankar@in.ibm.com>,
	zhmurov@yandex-team.ru, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from forward-corp1f.mail.yandex.net ([95.108.130.40]:56816 "EHLO
	forward-corp1f.mail.yandex.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754174Ab3EVL60 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 May 2013 07:58:26 -0400
In-Reply-To: <1369201765.3301.299.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 22.05.2013 09:49, Eric Dumazet wrote:
> On Tue, 2013-05-21 at 19:01 -0700, Eric Dumazet wrote:
>
>> Please use ACCESS_ONCE(), which is the standard way to deal with this,
>> and remove the rcu_dereference_raw() in
>> hlist_nulls_for_each_entry_rcu()
>>
>> something like : (for the nulls part only)
>
> Thinking a bit more about this, I am a bit worried by other uses of
> ACCESS_ONCE(ptr->field)
>
> rcu_dereference(ptr->field) intent is to reload ptr->field every time
> from memory.

Exactly.

>
> Do we really need a
>
> #define ACCESS_FIELD_ONCE(PTR, FIELD) (((volatile typeof(*PTR) *)PTR)->FIELD)
>
> #define ACCESS_ONCE(x) (*(volatile typeof(x) *)&(x))
>
> and change all rcu_dererence(ptr->field) occurrences ?

Yes.
But not all: only "head->first". The node variable (or any other iterator) is
always a local variable that changes every cycle. So, we can rely on gcc here.

>
> I probably miss something obvious.
>
> Anyway, following patch seems to also solve the problem, I need a sleep to understand why.
>
>   	struct hlist_nulls_node *node;
> @@ -420,7 +420,7 @@ static struct sock *udp4_lib_lookup2(struct net *net,
>   begin:
>   	result = NULL;
>   	badness = 0;
> -	udp_portaddr_for_each_entry_rcu(sk, node, &hslot2->head) {
> +	udp_portaddr_for_each_entry_rcu(sk, node, head) {
>   		score = compute_score2(sk, net, saddr, sport,
>   				      daddr, hnum, dif);
>   		if (score > badness) {


IMHO, it doesn't solve.
Ok, ok, it can actually solve, as fast ANY modification of related code.
For instance, adding something like
	unsigned int c = 0;
	udp_portaddr_for_each_entry_rcu(sk, node, &hslot2->head) {
		...
		c++;
		if (c > 1000000)
			printk(...);
	}
also "solves" the problem.

It looks like, that it's semantically strange to use the ACCESS_(FIELD)_ONCE
macro for telling gcc to reread something every time.
So, I created corresponding rcu_dereference_field(_raw/_bh) macros.

Please, find my third attempt to create a patch below.

Regards,
Roman

-----------------------------------------------------------------------

rcu: fix a race in rcu lists traverse macros

Some network functions (udp4_lib_lookup2(), for instance) use the
rcu lists traverse macros (hlist_nulls_for_each_entry_rcu, for instance)
in a way that assumes restarting of a loop. In this case, it is strictly
necessary to reread the head->first value from the memory before each scan.
Without additional hints, gcc caches this value in a register. In this case,
if a cached node is moved to another chain during the scan, we can loop
forever getting wrong nulls values and restarting the loop uninterruptedly.

Signed-off-by: Roman Gushchin <klamm@yandex-team.ru>
Reported-by: Boris Zhmurov <zhmurov@yandex-team.ru>
---
  include/linux/compiler.h      | 6 ++++++
  include/linux/rculist.h       | 9 +++++----
  include/linux/rculist_nulls.h | 2 +-
  include/linux/rcupdate.h      | 9 +++++++++
  4 files changed, 21 insertions(+), 5 deletions(-)

diff --git a/include/linux/compiler.h b/include/linux/compiler.h
index 92669cd..4109fab 100644
--- a/include/linux/compiler.h
+++ b/include/linux/compiler.h
@@ -351,6 +351,12 @@ void ftrace_likely_update(struct ftrace_branch_data *f, int val, int expect);
   */
  #define ACCESS_ONCE(x) (*(volatile typeof(x) *)&(x))

+/*
+ * Same as ACCESS_ONCE(), but used for accessing field of a structure.
+ * The main goal is preventing compiler to store &ptr->field in a register.
+ */
+#define ACCESS_FIELD_ONCE(PTR, FIELD) (((volatile typeof(*PTR) *)PTR)->FIELD)
+
  /* Ignore/forbid kprobes attach on very low level functions marked by this attribute: */
  #ifdef CONFIG_KPROBES
  # define __kprobes	__attribute__((__section__(".kprobes.text")))
diff --git a/include/linux/rculist.h b/include/linux/rculist.h
index 8089e35..7582cfe 100644
--- a/include/linux/rculist.h
+++ b/include/linux/rculist.h
@@ -282,7 +282,8 @@ static inline void list_splice_init_rcu(struct list_head *list,
   * as long as the traversal is guarded by rcu_read_lock().
   */
  #define list_for_each_entry_rcu(pos, head, member) \
-	for (pos = list_entry_rcu((head)->next, typeof(*pos), member); \
+	for (pos = list_entry_rcu(ACCESS_FIELD_ONCE(head, next), \
+				  typeof(*pos), member); \
  		&pos->member != (head); \
  		pos = list_entry_rcu(pos->member.next, typeof(*pos), member))

@@ -439,7 +440,7 @@ static inline void hlist_add_after_rcu(struct hlist_node *prev,
  }

  #define __hlist_for_each_rcu(pos, head)				\
-	for (pos = rcu_dereference(hlist_first_rcu(head));	\
+	for (pos = rcu_dereference_field(head, first);		\
  	     pos;						\
  	     pos = rcu_dereference(hlist_next_rcu(pos)))

@@ -454,7 +455,7 @@ static inline void hlist_add_after_rcu(struct hlist_node *prev,
   * as long as the traversal is guarded by rcu_read_lock().
   */
  #define hlist_for_each_entry_rcu(pos, head, member)			\
-	for (pos = hlist_entry_safe (rcu_dereference_raw(hlist_first_rcu(head)),\
+	for (pos = hlist_entry_safe(rcu_dereference_field_raw(head, first), \
  			typeof(*(pos)), member);			\
  		pos;							\
  		pos = hlist_entry_safe(rcu_dereference_raw(hlist_next_rcu(\
@@ -471,7 +472,7 @@ static inline void hlist_add_after_rcu(struct hlist_node *prev,
   * as long as the traversal is guarded by rcu_read_lock().
   */
  #define hlist_for_each_entry_rcu_bh(pos, head, member)			\
-	for (pos = hlist_entry_safe(rcu_dereference_bh(hlist_first_rcu(head)),\
+	for (pos = hlist_entry_safe(rcu_dereference_field_bh(head, first), \
  			typeof(*(pos)), member);			\
  		pos;							\
  		pos = hlist_entry_safe(rcu_dereference_bh(hlist_next_rcu(\
diff --git a/include/linux/rculist_nulls.h b/include/linux/rculist_nulls.h
index 2ae1371..ef431b4 100644
--- a/include/linux/rculist_nulls.h
+++ b/include/linux/rculist_nulls.h
@@ -107,7 +107,7 @@ static inline void hlist_nulls_add_head_rcu(struct hlist_nulls_node *n,
   *
   */
  #define hlist_nulls_for_each_entry_rcu(tpos, pos, head, member)			\
-	for (pos = rcu_dereference_raw(hlist_nulls_first_rcu(head));		\
+	for (pos = rcu_dereference_field_raw(head, first);			\
  		(!is_a_nulls(pos)) &&						\
  		({ tpos = hlist_nulls_entry(pos, typeof(*tpos), member); 1; }); \
  		pos = rcu_dereference_raw(hlist_nulls_next_rcu(pos)))
diff --git a/include/linux/rcupdate.h b/include/linux/rcupdate.h
index 4ccd68e..6fef0c2 100644
--- a/include/linux/rcupdate.h
+++ b/include/linux/rcupdate.h
@@ -640,6 +640,9 @@ static inline void rcu_preempt_sleep_check(void)

  #define rcu_dereference_raw(p) rcu_dereference_check(p, 1) /*@@@ needed? @@@*/

+#define rcu_dereference_field_raw(PTR, FIELD) \
+		rcu_dereference_raw(ACCESS_FIELD_ONCE(PTR, FIELD))
+
  /**
   * rcu_access_index() - fetch RCU index with no dereferencing
   * @p: The index to read
@@ -704,6 +707,9 @@ static inline void rcu_preempt_sleep_check(void)
   */
  #define rcu_dereference(p) rcu_dereference_check(p, 0)

+#define rcu_dereference_field(PTR, FIELD)		\
+	rcu_dereference(ACCESS_FIELD_ONCE(PTR, FIELD))
+
  /**
   * rcu_dereference_bh() - fetch an RCU-bh-protected pointer for dereferencing
   * @p: The pointer to read, prior to dereferencing
@@ -712,6 +718,9 @@ static inline void rcu_preempt_sleep_check(void)
   */
  #define rcu_dereference_bh(p) rcu_dereference_bh_check(p, 0)

+#define rcu_dereference_field_bh(PTR, FIELD)			\
+	rcu_dereference_bh(ACCESS_FIELD_ONCE(PTR, FIELD))
+
  /**
   * rcu_dereference_sched() - fetch RCU-sched-protected pointer for dereferencing
   * @p: The pointer to read, prior to dereferencing
-- 
1.8.1.2
