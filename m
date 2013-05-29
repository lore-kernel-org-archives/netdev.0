From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] rcu: fix a race in hlist_nulls_for_each_entry_rcu
 macro
Date: Wed, 29 May 2013 12:06:27 -0700
Message-ID: <1369854387.5109.77.camel@edumazet-glaptop>
References: <519CB2D8.103@yandex-team.ru>
	  <1369225837.3301.324.camel@edumazet-glaptop>
	  <519CC2FB.2010006@yandex-team.ru>
	  <20130522174532.GC3431@linux.vnet.ibm.com> <519D19DA.50400@yandex-team.ru>
	  <20130525113715.GA3795@linux.vnet.ibm.com>
	  <51A39E11.5020405@yandex-team.ru>
	  <1369699930.3301.494.camel@edumazet-glaptop>
	  <51A47496.6000100@yandex-team.ru>
	  <1369787693.3301.586.camel@edumazet-glaptop>
	  <20130529013111.GS6172@linux.vnet.ibm.com>
	 <1369804097.3301.615.camel@edumazet-glaptop>
	 <51A5D3D9.1000106@yandex-team.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: paulmck@linux.vnet.ibm.com,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Dipankar Sarma <dipankar@in.ibm.com>, zhmurov@yandex-team.ru,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: Roman Gushchin <klamm@yandex-team.ru>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f41.google.com ([209.85.160.41]:58716 "EHLO
	mail-pb0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759607Ab3E2TGa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 May 2013 15:06:30 -0400
In-Reply-To: <51A5D3D9.1000106@yandex-team.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-05-29 at 14:09 +0400, Roman Gushchin wrote:

> Unfortunately, using barrier() can also prevent gcc from making some
> (acceptable) code optimizations, because barrier() has a global effect,
> and everything we want to reload is the (head->first) pointer.
> So, to be absolutely precise, we have to introduce and use
> the ACCESS_FIELD_ONCE() macro.

Yep, ACCESS_ONCE() seems to not work for a field, at least the
ACCESS_ONCE() used in __rcu_dereference_check() 

> 
> In any case, it doesn't look like a big problem.
> In my mind, the best solution is to use the ACCESS_FIELD_ONCE() macro,
> but using barrier() is also an acceptable solution.
> 

True, these lookup functions are usually structured the same around the
hlist_nulls_for_each_entry_rcu() loop.

A barrier() right before the loop seems to be a benefit, the size of
assembly code is reduced by 48 bytes.

And its one of the documented way to handle this kind of problems
(Documentation/atomic_ops.txt line 114)

I guess we should amend this documentation, eventually.

Thanks, please add you "Signed-off-by" if you agree with the patch.


[PATCH] net: force a reload of first item in hlist_nulls_for_each_entry_rcu

Roman Gushchin discovered that udp4_lib_lookup2() was not reloading
first item in the rcu protected list, in case the loop was restarted.

This produced soft lockups as in https://lkml.org/lkml/2013/4/16/37

rcu_dereference(X)/ACCESS_ONCE(X) seem to not work as intended if X is
ptr->field :

In some cases, gcc caches the value or ptr->field in a register.

Use a barrier() to disallow such caching, as documented in
Documentation/atomic_ops.txt line 114

Thanks a lot to Roman for providing analysis and numerous patches.

Diagnosed-by: Roman Gushchin <klamm@yandex-team.ru>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Reported-by: Boris Zhmurov <zhmurov@yandex-team.ru>
---
 include/linux/rculist_nulls.h |    7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/include/linux/rculist_nulls.h b/include/linux/rculist_nulls.h
index 2ae1371..c7557fa 100644
--- a/include/linux/rculist_nulls.h
+++ b/include/linux/rculist_nulls.h
@@ -105,9 +105,14 @@ static inline void hlist_nulls_add_head_rcu(struct hlist_nulls_node *n,
  * @head:	the head for your list.
  * @member:	the name of the hlist_nulls_node within the struct.
  *
+ * The barrier() is needed to make sure compiler doesn't cache first element [1],
+ * as this loop can be restarted [2]
+ * [1] Documentation/atomic_ops.txt around line 114
+ * [2] Documentation/RCU/rculist_nulls.txt around line 146 
  */
 #define hlist_nulls_for_each_entry_rcu(tpos, pos, head, member)			\
-	for (pos = rcu_dereference_raw(hlist_nulls_first_rcu(head));		\
+	for (({barrier();}),							\
+	     pos = rcu_dereference_raw(hlist_nulls_first_rcu(head));		\
 		(!is_a_nulls(pos)) &&						\
 		({ tpos = hlist_nulls_entry(pos, typeof(*tpos), member); 1; }); \
 		pos = rcu_dereference_raw(hlist_nulls_next_rcu(pos)))
