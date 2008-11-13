From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH 4/3] rcu: documents rculist_nulls
Date: Thu, 13 Nov 2008 17:02:48 +0100
Message-ID: <491C4FA8.4020704@cosmosbay.com>
References: <4908627C.6030001@acm.org> <490874F2.2060306@cosmosbay.com>	 <49088288.6050805@acm.org> <49088AD1.7040805@cosmosbay.com>	 <20081029163739.GB6732@linux.vnet.ibm.com> <49089BE5.3090705@acm.org>	 <4908A134.4040705@cosmosbay.com> <4908AB3F.1060003@acm.org>	 <20081029185200.GE6732@linux.vnet.ibm.com> <4908C0CD.5050406@cosmosbay.com>	 <20081029201759.GF6732@linux.vnet.ibm.com> <4908DEDE.5030706@cosmosbay.com>	 <4909D551.9080309@cosmosbay.com>  <491C282A.5050802@cosmosbay.com> <1226582997.7685.4786.camel@twins> <491C2F27.2000908@cosmosbay.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080900010500090909000205"
Cc: Corey Minyard <minyard@acm.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	benny+usenet@amorsen.dk,
	Linux Netdev List <netdev@vger.kernel.org>,
	Christoph Lameter <cl@linux-foundation.org>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	Christian Bell <christian@myri.com>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:34695 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751511AbYKMQEH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Nov 2008 11:04:07 -0500
In-Reply-To: <491C2F27.2000908@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------080900010500090909000205
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable

Eric Dumazet a =E9crit :
> Peter Zijlstra a =E9crit :
>> So by not using some memory barriers (would be nice to have it
>> illustrated which ones), we can race and end up on the wrong chain, in=

>> case that happens we detect this by using this per-chain terminator an=
d
>> try again.
>>
>> It would be really good to have it explained in the rculist_nulls.h
>> comments what memory barriers are missing, what races they open, and h=
ow
>> the this special terminator trick closes that race.
>=20
> OK, maybe I should add a Documentation/RCU/rculist_nulls.txt file with
> appropriate examples and documentation.
>=20
> (Say the lookup/insert algorithms, with standard hlist and memory barri=
ers,
> and with hlist_nulls without those two memory barriers.
>=20

[PATCH 4/3] rcu: documents rculist_nulls

Adds Documentation/RCU/rculist_nulls.txt file to describe how 'nulls'
end-of-list can help in some RCU algos.


Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
---
 Documentation/RCU/rculist_nulls.txt |  167 ++++++++++++++++++++++++++
 1 files changed, 167 insertions(+)

--------------080900010500090909000205
Content-Type: text/plain;
 name="rculist_nulls_doc.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="rculist_nulls_doc.patch"

diff --git a/Documentation/RCU/rculist_nulls.txt b/Documentation/RCU/rculist_nulls.txt
new file mode 100644
index 0000000..5db5549
--- /dev/null
+++ b/Documentation/RCU/rculist_nulls.txt
@@ -0,0 +1,167 @@
+Using hlist_nulls to protect read-mostly linked lists and
+objects using SLAB_DESTROY_BY_RCU allocations.
+
+Please read the basics in Documentation/RCU/listRCU.txt
+
+Using special makers (called 'nulls') is a convenient way
+to solve following problem :
+
+A typical RCU linked list managing objects which are
+allocated with SLAB_DESTROY_BY_RCU kmem_cache can
+use following algos :
+
+1) Lookup algo
+--------------
+rcu_read_lock()
+begin:
+obj = lockless_lookup(key);
+if (obj) {
+  if (!try_get_ref(obj)) // might fail for free objects
+    goto begin;
+  /*
+   * Because a writer could delete object, and a writer could
+   * reuse these object before the RCU grace period, we
+   * must check key after geting the reference on object
+   */
+  if (obj->key != key) { // not the object we expected
+     put_ref(obj);
+     goto begin;
+   }
+}
+rcu_read_unlock();
+
+Beware that lockless_lookup(key) cannot use traditional hlist_for_each_entry_rcu()
+but a version with an additional memory barrier (smp_rmb())
+
+lockless_lookup(key)
+{
+   struct hlist_node *node, *next;
+   for (pos = rcu_dereference((head)->first);
+          pos && ({ next = pos->next; smp_rmb(); prefetch(next); 1; }) &&
+          ({ tpos = hlist_entry(pos, typeof(*tpos), member); 1; }); 
+          pos = rcu_dereference(next))
+      if (obj->key == key)
+         return obj;
+   return NULL;
+
+And note the traditional hlist_for_each_entry_rcu() misses this smp_rmb() :
+
+   struct hlist_node *node;
+   for (pos = rcu_dereference((head)->first);
+		pos && ({ prefetch(pos->next); 1; }) &&
+		({ tpos = hlist_entry(pos, typeof(*tpos), member); 1; });
+		pos = rcu_dereference(pos->next))
+      if (obj->key == key)
+         return obj;
+   return NULL;
+}
+
+Quoting Corey Minyard :
+
+"If the object is moved from one list to another list in-between the
+ time the hash is calculated and the next field is accessed, and the
+ object has moved to the end of a new list, the traversal will not
+ complete properly on the list it should have, since the object will
+ be on the end of the new list and there's not a way to tell it's on a
+ new list and restart the list traversal.  I think that this can be
+ solved by pre-fetching the "next" field (with proper barriers) before
+ checking the key."
+
+2) Insert algo :
+----------------
+
+We need to make sure a reader cannot read the new 'obj->obj_next' value
+and previous value of 'obj->key'. Or else, an item could be deleted
+from a chain, and inserted into another chain. If new chain was empty
+before the move, 'next' pointer is NULL, and lockless reader can
+not detect it missed following items in original chain.
+
+/*
+ * Please note that new inserts are done at the head of list,
+ * not in the middle or end.
+ */
+obj = kmem_cache_alloc(...);
+lock_chain(); // typically a spin_lock()
+obj->key = key;
+atomic_inc(&obj->refcnt);
+/*
+ * we need to make sure obj->key is updated before obj->next
+ */
+smp_wmb();
+hlist_add_head_rcu(&obj->obj_node, list);
+unlock_chain(); // typically a spin_unlock()
+
+
+3) Remove algo
+--------------
+Nothing special here, we can use a standard RCU hlist deletion.
+But thanks to SLAB_DESTROY_BY_RCU, beware a deleted object can be reused 
+very very fast (before the end of RCU grace period)
+
+if (put_last_reference_on(obj) {
+   lock_chain(); // typically a spin_lock()
+   hlist_del_init_rcu(&obj->obj_node);
+   unlock_chain(); // typically a spin_unlock()
+   kmem_cache_free(cachep, obj);
+}
+
+
+
+--------------------------------------------------------------------------
+With hlist_nulls we can avoid extra smp_rmb() in lockless_lookup()
+and extra smp_wmb() in insert function.
+
+For example, if we choose to store the slot number as the 'nulls'
+end-of-list marker for each slot of the hash table, we can detect
+a race (some writer did a delete and/or a move of an object
+to another chain) checking the final 'nulls' value if
+the lookup met the end of chain. If final 'nulls' value
+is not the slot number, then we must restart the lookup at
+the begining. If the object was moved to same chain,
+then the reader doesnt care : It might eventually
+scan the list again without harm.
+
+
+1) lookup algo
+
+ head = &table[slot];
+ rcu_read_lock();
+begin:
+ hlist_nulls_for_each_entry_rcu(obj, node, head, member) {
+   if (obj->key == key) {
+      if (!try_get_ref(obj)) // might fail for free objects
+         goto begin;
+      if (obj->key != key) { // not the object we expected
+         put_ref(obj);
+         goto begin;
+      }
+  goto out;
+ }
+/*
+ * if the nulls value we got at the end of this lookup is
+ * not the expected one, we must restart lookup.
+ * We probably met an item that was moved to another chain.
+ */
+ if (get_nulls_value(node) != slot)
+   goto begin;
+ obj = NULL;
+
+out:
+ rcu_read_unlock();
+
+2) Insert function :
+--------------------
+
+/*
+ * Please note that new inserts are done at the head of list,
+ * not in the middle or end.
+ */
+obj = kmem_cache_alloc(cachep);
+lock_chain(); // typically a spin_lock()
+obj->key = key;
+atomic_set(&obj->refcnt, 1);
+/*
+ * insert obj in RCU way (readers might be traversing chain)
+ */
+hlist_nulls_add_head_rcu(&obj->obj_node, list);
+unlock_chain(); // typically a spin_unlock()

--------------080900010500090909000205--
