From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH 1/3] rcu: Introduce hlist_nulls variant of hlist
Date: Thu, 13 Nov 2008 14:14:18 +0100
Message-ID: <491C282A.5050802@cosmosbay.com>
References: <4908627C.6030001@acm.org> <490874F2.2060306@cosmosbay.com> <49088288.6050805@acm.org> <49088AD1.7040805@cosmosbay.com> <20081029163739.GB6732@linux.vnet.ibm.com> <49089BE5.3090705@acm.org> <4908A134.4040705@cosmosbay.com> <4908AB3F.1060003@acm.org> <20081029185200.GE6732@linux.vnet.ibm.com> <4908C0CD.5050406@cosmosbay.com> <20081029201759.GF6732@linux.vnet.ibm.com> <4908DEDE.5030706@cosmosbay.com> <4909D551.9080309@cosmosbay.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060104040500010903080803"
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	benny+usenet@amorsen.dk,
	Linux Netdev List <netdev@vger.kernel.org>,
	Christoph Lameter <cl@linux-foundation.org>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Christian Bell <christian@myri.com>
To: Corey Minyard <minyard@acm.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:43306 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752070AbYKMNPH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Nov 2008 08:15:07 -0500
In-Reply-To: <4909D551.9080309@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------060104040500010903080803
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

hlist uses NULL value to finish a chain.

hlist_nulls variant use the low order bit set to 1 to signal an end-of-list marker.

This allows to store many different end markers, so that some RCU lockless
algos (used in TCP/UDP stack for example) can save some memory barriers in
fast paths.

Two new files are added :

include/linux/list_nulls.h
  - mimics hlist part of include/linux/list.h, derived to hlist_nulls variant

include/linux/rculist_nulls.h
  - mimics hlist part of include/linux/rculist.h, derived to hlist_nulls variant

   Only four helpers are declared for the moment :

     hlist_nulls_del_init_rcu(), hlist_nulls_del_rcu(),
     hlist_nulls_add_head_rcu() and hlist_nulls_for_each_entry_rcu()

prefetches() were removed, since an end of list is not anymore NULL value.
prefetches() could trigger useless (and possibly dangerous) memory transactions.

Example of use (extracted from __udp4_lib_lookup())

	struct sock *sk, *result;
        struct hlist_nulls_node *node;
        unsigned short hnum = ntohs(dport);
        unsigned int hash = udp_hashfn(net, hnum);
        struct udp_hslot *hslot = &udptable->hash[hash];
        int score, badness;

        rcu_read_lock();
begin:
        result = NULL;
        badness = -1;
        sk_nulls_for_each_rcu(sk, node, &hslot->head) {
                score = compute_score(sk, net, saddr, hnum, sport,
                                      daddr, dport, dif);
                if (score > badness) {
                        result = sk;
                        badness = score;
                }
        }
        /*
         * if the nulls value we got at the end of this lookup is
         * not the expected one, we must restart lookup.
         * We probably met an item that was moved to another chain.
         */
        if (get_nulls_value(node) != hash)
                goto begin;

        if (result) {
                if (unlikely(!atomic_inc_not_zero(&result->sk_refcnt)))
                        result = NULL;
                else if (unlikely(compute_score(result, net, saddr, hnum, sport,
                                  daddr, dport, dif) < badness)) {
                        sock_put(result);
                        goto begin;
                }
        }
        rcu_read_unlock();
        return result;

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
---
 include/linux/list_nulls.h    |   94 +++++++++++++++++++++++++++
 include/linux/rculist_nulls.h |  110 ++++++++++++++++++++++++++++++++
 2 files changed, 204 insertions(+)

--------------060104040500010903080803
Content-Type: text/plain;
 name="nulls.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="nulls.patch"

diff --git a/include/linux/list_nulls.h b/include/linux/list_nulls.h
new file mode 100644
index 0000000..856dee8
--- /dev/null
+++ b/include/linux/list_nulls.h
@@ -0,0 +1,94 @@
+#ifndef _LINUX_LIST_NULLS_H
+#define _LINUX_LIST_NULLS_H
+
+/*
+ * Special version of lists, where end of list is not a NULL pointer,
+ * but a 'nulls' marker, which can have many different values.
+ * (up to 2^31 different values guaranteed on all platforms)
+ *
+ * In the standard hlist, termination of a list is the NULL pointer.
+ * In this special 'nulls' variant, we use the fact that objects stored in
+ * a list are aligned on a word (4 or 8 bytes alignment).
+ * We therefore use the last significant bit of 'ptr' :
+ * Set to 1 : This is a 'nulls' end-of-list marker (ptr >> 1)
+ * Set to 0 : This is a pointer to some object (ptr)
+ */
+
+struct hlist_nulls_head {
+	struct hlist_nulls_node *first;
+};
+
+struct hlist_nulls_node {
+	struct hlist_nulls_node *next, **pprev;
+};
+#define INIT_HLIST_NULLS_HEAD(ptr, nulls) \
+	((ptr)->first = (struct hlist_nulls_node *) (1UL | (((long)nulls) << 1)))
+
+#define hlist_nulls_entry(ptr, type, member) container_of(ptr,type,member)
+/**
+ * ptr_is_a_nulls - Test if a ptr is a nulls
+ * @ptr: ptr to be tested
+ *
+ */
+static inline int is_a_nulls(const struct hlist_nulls_node *ptr)
+{
+	return ((unsigned long)ptr & 1);
+}
+
+/**
+ * get_nulls_value - Get the 'nulls' value of the end of chain
+ * @ptr: end of chain
+ *
+ * Should be called only if is_a_nulls(ptr);
+ */
+static inline unsigned long get_nulls_value(const struct hlist_nulls_node *ptr)
+{
+	return ((unsigned long)ptr) >> 1;
+}
+
+static inline int hlist_nulls_unhashed(const struct hlist_nulls_node *h)
+{
+	return !h->pprev;
+}
+
+static inline int hlist_nulls_empty(const struct hlist_nulls_head *h)
+{
+	return is_a_nulls(h->first);
+}
+
+static inline void __hlist_nulls_del(struct hlist_nulls_node *n)
+{
+	struct hlist_nulls_node *next = n->next;
+	struct hlist_nulls_node **pprev = n->pprev;
+	*pprev = next;
+	if (!is_a_nulls(next))
+		next->pprev = pprev;
+}
+
+/**
+ * hlist_nulls_for_each_entry	- iterate over list of given type
+ * @tpos:	the type * to use as a loop cursor.
+ * @pos:	the &struct hlist_node to use as a loop cursor.
+ * @head:	the head for your list.
+ * @member:	the name of the hlist_node within the struct.
+ *
+ */
+#define hlist_nulls_for_each_entry(tpos, pos, head, member)		       \
+	for (pos = (head)->first;					       \
+	     (!is_a_nulls(pos)) &&					       \
+		({ tpos = hlist_nulls_entry(pos, typeof(*tpos), member); 1;}); \
+	     pos = pos->next)
+
+/**
+ * hlist_nulls_for_each_entry_from - iterate over a hlist continuing from current point
+ * @tpos:	the type * to use as a loop cursor.
+ * @pos:	the &struct hlist_node to use as a loop cursor.
+ * @member:	the name of the hlist_node within the struct.
+ *
+ */
+#define hlist_nulls_for_each_entry_from(tpos, pos, member)	\
+	for (; (!is_a_nulls(pos)) && 				\
+		({ tpos = hlist_nulls_entry(pos, typeof(*tpos), member); 1;}); \
+	     pos = pos->next)
+
+#endif
diff --git a/include/linux/rculist_nulls.h b/include/linux/rculist_nulls.h
new file mode 100644
index 0000000..b185ac4
--- /dev/null
+++ b/include/linux/rculist_nulls.h
@@ -0,0 +1,110 @@
+#ifndef _LINUX_RCULIST_NULLS_H
+#define _LINUX_RCULIST_NULLS_H
+
+#ifdef __KERNEL__
+
+/*
+ * RCU-protected list version
+ */
+#include <linux/list_nulls.h>
+#include <linux/rcupdate.h>
+
+/**
+ * hlist_nulls_del_init_rcu - deletes entry from hash list with re-initialization
+ * @n: the element to delete from the hash list.
+ *
+ * Note: hlist_nulls_unhashed() on the node return true after this. It is
+ * useful for RCU based read lockfree traversal if the writer side
+ * must know if the list entry is still hashed or already unhashed.
+ *
+ * In particular, it means that we can not poison the forward pointers
+ * that may still be used for walking the hash list and we can only
+ * zero the pprev pointer so list_unhashed() will return true after
+ * this.
+ *
+ * The caller must take whatever precautions are necessary (such as
+ * holding appropriate locks) to avoid racing with another
+ * list-mutation primitive, such as hlist_nulls_add_head_rcu() or
+ * hlist_nulls_del_rcu(), running on this same list.  However, it is
+ * perfectly legal to run concurrently with the _rcu list-traversal
+ * primitives, such as hlist_nulls_for_each_entry_rcu().
+ */
+static inline void hlist_nulls_del_init_rcu(struct hlist_nulls_node *n)
+{
+	if (!hlist_nulls_unhashed(n)) {
+		__hlist_nulls_del(n);
+		n->pprev = NULL;
+	}
+}
+
+/**
+ * hlist_nulls_del_rcu - deletes entry from hash list without re-initialization
+ * @n: the element to delete from the hash list.
+ *
+ * Note: hlist_nulls_unhashed() on entry does not return true after this,
+ * the entry is in an undefined state. It is useful for RCU based
+ * lockfree traversal.
+ *
+ * In particular, it means that we can not poison the forward
+ * pointers that may still be used for walking the hash list.
+ *
+ * The caller must take whatever precautions are necessary
+ * (such as holding appropriate locks) to avoid racing
+ * with another list-mutation primitive, such as hlist_nulls_add_head_rcu()
+ * or hlist_nulls_del_rcu(), running on this same list.
+ * However, it is perfectly legal to run concurrently with
+ * the _rcu list-traversal primitives, such as
+ * hlist_nulls_for_each_entry().
+ */
+static inline void hlist_nulls_del_rcu(struct hlist_nulls_node *n)
+{
+	__hlist_nulls_del(n);
+	n->pprev = LIST_POISON2;
+}
+
+/**
+ * hlist_nulls_add_head_rcu
+ * @n: the element to add to the hash list.
+ * @h: the list to add to.
+ *
+ * Description:
+ * Adds the specified element to the specified hlist_nulls,
+ * while permitting racing traversals.
+ *
+ * The caller must take whatever precautions are necessary
+ * (such as holding appropriate locks) to avoid racing
+ * with another list-mutation primitive, such as hlist_nulls_add_head_rcu()
+ * or hlist_nulls_del_rcu(), running on this same list.
+ * However, it is perfectly legal to run concurrently with
+ * the _rcu list-traversal primitives, such as
+ * hlist_nulls_for_each_entry_rcu(), used to prevent memory-consistency
+ * problems on Alpha CPUs.  Regardless of the type of CPU, the
+ * list-traversal primitive must be guarded by rcu_read_lock().
+ */
+static inline void hlist_nulls_add_head_rcu(struct hlist_nulls_node *n,
+					struct hlist_nulls_head *h)
+{
+	struct hlist_nulls_node *first = h->first;
+
+	n->next = first;
+	n->pprev = &h->first;
+	rcu_assign_pointer(h->first, n);
+	if (!is_a_nulls(first))
+		first->pprev = &n->next;
+}
+/**
+ * hlist_nulls_for_each_entry_rcu - iterate over rcu list of given type
+ * @tpos:	the type * to use as a loop cursor.
+ * @pos:	the &struct hlist_nulls_node to use as a loop cursor.
+ * @head:	the head for your list.
+ * @member:	the name of the hlist_nulls_node within the struct.
+ *
+ */
+#define hlist_nulls_for_each_entry_rcu(tpos, pos, head, member) \
+	for (pos = rcu_dereference((head)->first);			 \
+		(!is_a_nulls(pos)) && 			\
+		({ tpos = hlist_nulls_entry(pos, typeof(*tpos), member); 1; }); \
+		pos = rcu_dereference(pos->next))
+
+#endif
+#endif

--------------060104040500010903080803--
