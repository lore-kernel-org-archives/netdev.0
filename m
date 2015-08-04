From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 08/18] netfilter: xtables: don't save/restore jumpstack offset
Date: Tue,  4 Aug 2015 12:02:38 +0200
Message-ID: <1438682568-8346-9-git-send-email-pablo@netfilter.org>
References: <1438682568-8346-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1438682568-8346-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Westphal <fw@strlen.de>

In most cases there is no reentrancy into ip/ip6tables.

For skbs sent by REJECT or SYNPROXY targets, there is one level
of reentrancy, but its not relevant as those targets issue an absolute
verdict, i.e. the jumpstack can be clobbered since its not used
after the target issues absolute verdict (ACCEPT, DROP, STOLEN, etc).

So the only special case where it is relevant is the TEE target, which
returns XT_CONTINUE.

This patch changes ip(6)_do_table to always use the jump stack starting
from 0.

When we detect we're operating on an skb sent via TEE (percpu
nf_skb_duplicated is 1) we switch to an alternate stack to leave
the original one alone.

Since there is no TEE support for arptables, it doesn't need to
test if tee is active.

The jump stack overflow tests are no longer needed as well --
since ->stacksize is the largest call depth we cannot exceed it.

A much better alternative to the external jumpstack would be to just
declare a jumps[32] stack on the local stack frame, but that would mean
we'd have to reject iptables rulesets that used to work before.

Another alternative would be to start rejecting rulesets with a larger
call depth, e.g. 1000 -- in this case it would be feasible to allocate the
entire stack in the percpu area which would avoid one dereference.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/netfilter/x_tables.h |    1 -
 net/ipv4/netfilter/arp_tables.c    |   11 +++--------
 net/ipv4/netfilter/ip_tables.c     |   37 +++++++++++++++++++-----------------
 net/ipv6/netfilter/ip6_tables.c    |   26 +++++++++++++------------
 net/netfilter/x_tables.c           |   22 ++++++++++-----------
 5 files changed, 48 insertions(+), 49 deletions(-)

diff --git a/include/linux/netfilter/x_tables.h b/include/linux/netfilter/x_tables.h
index 286098a..1492845 100644
--- a/include/linux/netfilter/x_tables.h
+++ b/include/linux/netfilter/x_tables.h
@@ -222,7 +222,6 @@ struct xt_table_info {
 	 * @stacksize jumps (number of user chains) can possibly be made.
 	 */
 	unsigned int stacksize;
-	unsigned int __percpu *stackptr;
 	void ***jumpstack;
 
 	unsigned char entries[0] __aligned(8);
diff --git a/net/ipv4/netfilter/arp_tables.c b/net/ipv4/netfilter/arp_tables.c
index ae6d0a1..969fdbe 100644
--- a/net/ipv4/netfilter/arp_tables.c
+++ b/net/ipv4/netfilter/arp_tables.c
@@ -280,6 +280,9 @@ unsigned int arpt_do_table(struct sk_buff *skb,
 	table_base = private->entries;
 	jumpstack  = (struct arpt_entry **)private->jumpstack[cpu];
 
+	/* No TEE support for arptables, so no need to switch to alternate
+	 * stack.  All targets that reenter must return absolute verdicts.
+	 */
 	e = get_entry(table_base, private->hook_entry[hook]);
 
 	acpar.in      = state->in;
@@ -325,11 +328,6 @@ unsigned int arpt_do_table(struct sk_buff *skb,
 			}
 			if (table_base + v
 			    != arpt_next_entry(e)) {
-
-				if (stackidx >= private->stacksize) {
-					verdict = NF_DROP;
-					break;
-				}
 				jumpstack[stackidx++] = e;
 			}
 
@@ -337,9 +335,6 @@ unsigned int arpt_do_table(struct sk_buff *skb,
 			continue;
 		}
 
-		/* Targets which reenter must return
-		 * abs. verdicts
-		 */
 		acpar.target   = t->u.kernel.target;
 		acpar.targinfo = t->data;
 		verdict = t->u.kernel.target->target(skb, &acpar);
diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index 5e44b35..a2e4b01 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -296,12 +296,13 @@ ipt_do_table(struct sk_buff *skb,
 	const char *indev, *outdev;
 	const void *table_base;
 	struct ipt_entry *e, **jumpstack;
-	unsigned int *stackptr, origptr, cpu;
+	unsigned int stackidx, cpu;
 	const struct xt_table_info *private;
 	struct xt_action_param acpar;
 	unsigned int addend;
 
 	/* Initialization */
+	stackidx = 0;
 	ip = ip_hdr(skb);
 	indev = state->in ? state->in->name : nulldevname;
 	outdev = state->out ? state->out->name : nulldevname;
@@ -331,13 +332,20 @@ ipt_do_table(struct sk_buff *skb,
 	smp_read_barrier_depends();
 	table_base = private->entries;
 	jumpstack  = (struct ipt_entry **)private->jumpstack[cpu];
-	stackptr   = per_cpu_ptr(private->stackptr, cpu);
-	origptr    = *stackptr;
+
+	/* Switch to alternate jumpstack if we're being invoked via TEE.
+	 * TEE issues XT_CONTINUE verdict on original skb so we must not
+	 * clobber the jumpstack.
+	 *
+	 * For recursion via REJECT or SYNPROXY the stack will be clobbered
+	 * but it is no problem since absolute verdict is issued by these.
+	 */
+	jumpstack += private->stacksize * __this_cpu_read(nf_skb_duplicated);
 
 	e = get_entry(table_base, private->hook_entry[hook]);
 
-	pr_debug("Entering %s(hook %u); sp at %u (UF %p)\n",
-		 table->name, hook, origptr,
+	pr_debug("Entering %s(hook %u), UF %p\n",
+		 table->name, hook,
 		 get_entry(table_base, private->underflow[hook]));
 
 	do {
@@ -383,28 +391,24 @@ ipt_do_table(struct sk_buff *skb,
 					verdict = (unsigned int)(-v) - 1;
 					break;
 				}
-				if (*stackptr <= origptr) {
+				if (stackidx == 0) {
 					e = get_entry(table_base,
 					    private->underflow[hook]);
 					pr_debug("Underflow (this is normal) "
 						 "to %p\n", e);
 				} else {
-					e = jumpstack[--*stackptr];
+					e = jumpstack[--stackidx];
 					pr_debug("Pulled %p out from pos %u\n",
-						 e, *stackptr);
+						 e, stackidx);
 					e = ipt_next_entry(e);
 				}
 				continue;
 			}
 			if (table_base + v != ipt_next_entry(e) &&
 			    !(e->ip.flags & IPT_F_GOTO)) {
-				if (*stackptr >= private->stacksize) {
-					verdict = NF_DROP;
-					break;
-				}
-				jumpstack[(*stackptr)++] = e;
+				jumpstack[stackidx++] = e;
 				pr_debug("Pushed %p into pos %u\n",
-					 e, *stackptr - 1);
+					 e, stackidx - 1);
 			}
 
 			e = get_entry(table_base, v);
@@ -423,9 +427,8 @@ ipt_do_table(struct sk_buff *skb,
 			/* Verdict */
 			break;
 	} while (!acpar.hotdrop);
-	pr_debug("Exiting %s; resetting sp from %u to %u\n",
-		 __func__, *stackptr, origptr);
-	*stackptr = origptr;
+	pr_debug("Exiting %s; sp at %u\n", __func__, stackidx);
+
  	xt_write_recseq_end(addend);
  	local_bh_enable();
 
diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index baf0321..531281f 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -324,12 +324,13 @@ ip6t_do_table(struct sk_buff *skb,
 	const char *indev, *outdev;
 	const void *table_base;
 	struct ip6t_entry *e, **jumpstack;
-	unsigned int *stackptr, origptr, cpu;
+	unsigned int stackidx, cpu;
 	const struct xt_table_info *private;
 	struct xt_action_param acpar;
 	unsigned int addend;
 
 	/* Initialization */
+	stackidx = 0;
 	indev = state->in ? state->in->name : nulldevname;
 	outdev = state->out ? state->out->name : nulldevname;
 	/* We handle fragments by dealing with the first fragment as
@@ -357,8 +358,15 @@ ip6t_do_table(struct sk_buff *skb,
 	cpu        = smp_processor_id();
 	table_base = private->entries;
 	jumpstack  = (struct ip6t_entry **)private->jumpstack[cpu];
-	stackptr   = per_cpu_ptr(private->stackptr, cpu);
-	origptr    = *stackptr;
+
+	/* Switch to alternate jumpstack if we're being invoked via TEE.
+	 * TEE issues XT_CONTINUE verdict on original skb so we must not
+	 * clobber the jumpstack.
+	 *
+	 * For recursion via REJECT or SYNPROXY the stack will be clobbered
+	 * but it is no problem since absolute verdict is issued by these.
+	 */
+	jumpstack += private->stacksize * __this_cpu_read(nf_skb_duplicated);
 
 	e = get_entry(table_base, private->hook_entry[hook]);
 
@@ -406,20 +414,16 @@ ip6t_do_table(struct sk_buff *skb,
 					verdict = (unsigned int)(-v) - 1;
 					break;
 				}
-				if (*stackptr <= origptr)
+				if (stackidx == 0)
 					e = get_entry(table_base,
 					    private->underflow[hook]);
 				else
-					e = ip6t_next_entry(jumpstack[--*stackptr]);
+					e = ip6t_next_entry(jumpstack[--stackidx]);
 				continue;
 			}
 			if (table_base + v != ip6t_next_entry(e) &&
 			    !(e->ipv6.flags & IP6T_F_GOTO)) {
-				if (*stackptr >= private->stacksize) {
-					verdict = NF_DROP;
-					break;
-				}
-				jumpstack[(*stackptr)++] = e;
+				jumpstack[stackidx++] = e;
 			}
 
 			e = get_entry(table_base, v);
@@ -437,8 +441,6 @@ ip6t_do_table(struct sk_buff *skb,
 			break;
 	} while (!acpar.hotdrop);
 
-	*stackptr = origptr;
-
  	xt_write_recseq_end(addend);
  	local_bh_enable();
 
diff --git a/net/netfilter/x_tables.c b/net/netfilter/x_tables.c
index 4db7d60..154447e 100644
--- a/net/netfilter/x_tables.c
+++ b/net/netfilter/x_tables.c
@@ -67,9 +67,6 @@ static const char *const xt_prefix[NFPROTO_NUMPROTO] = {
 	[NFPROTO_IPV6]   = "ip6",
 };
 
-/* Allow this many total (re)entries. */
-static const unsigned int xt_jumpstack_multiplier = 2;
-
 /* Registration hooks for targets. */
 int xt_register_target(struct xt_target *target)
 {
@@ -688,8 +685,6 @@ void xt_free_table_info(struct xt_table_info *info)
 		kvfree(info->jumpstack);
 	}
 
-	free_percpu(info->stackptr);
-
 	kvfree(info);
 }
 EXPORT_SYMBOL(xt_free_table_info);
@@ -737,10 +732,6 @@ static int xt_jumpstack_alloc(struct xt_table_info *i)
 	unsigned int size;
 	int cpu;
 
-	i->stackptr = alloc_percpu(unsigned int);
-	if (i->stackptr == NULL)
-		return -ENOMEM;
-
 	size = sizeof(void **) * nr_cpu_ids;
 	if (size > PAGE_SIZE)
 		i->jumpstack = vzalloc(size);
@@ -753,8 +744,17 @@ static int xt_jumpstack_alloc(struct xt_table_info *i)
 	if (i->stacksize == 0)
 		return 0;
 
-	i->stacksize *= xt_jumpstack_multiplier;
-	size = sizeof(void *) * i->stacksize;
+	/* Jumpstack needs to be able to record two full callchains, one
+	 * from the first rule set traversal, plus one table reentrancy
+	 * via -j TEE without clobbering the callchain that brought us to
+	 * TEE target.
+	 *
+	 * This is done by allocating two jumpstacks per cpu, on reentry
+	 * the upper half of the stack is used.
+	 *
+	 * see the jumpstack setup in ipt_do_table() for more details.
+	 */
+	size = sizeof(void *) * i->stacksize * 2u;
 	for_each_possible_cpu(cpu) {
 		if (size > PAGE_SIZE)
 			i->jumpstack[cpu] = vmalloc_node(size,
-- 
1.7.10.4

